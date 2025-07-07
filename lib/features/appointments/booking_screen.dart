// lib/features/appointments/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_studio_app/models/artist.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Artist artist;
  const BookingScreen({super.key, required this.artist});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Artist _latestArtistData;
  bool _isArtistDataLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  TimeOfDay? _selectedTime;
  List<TimeOfDay> _availableTimeSlots = [];
  bool _isLoadingTimes = false;
  bool _isBooking = false;

  final Map<String, int> _dayOfWeekMap = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  @override
  void initState() {
    super.initState();
    _fetchLatestArtistData();
  }

  Future<void> _fetchLatestArtistData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('studios')
          .doc(widget.artist.uid)
          .get();
      if (doc.exists) {
        _latestArtistData = Artist.fromMap(doc.data()!);
        if (_isDayEnabled(DateTime.now())) {
          _selectedDay = _focusedDay;
          _generateAvailableTimeSlots(_selectedDay!);
        }
      } else {
        _latestArtistData = widget.artist;
      }
    } catch (e) {
      _latestArtistData = widget.artist;
      print("Erro ao buscar dados do artista: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isArtistDataLoading = false;
        });
      }
    }
  }

  bool _isDayEnabled(DateTime day) {
    final enabledWeekdays = _latestArtistData.workingDays
        .map((dayString) => _dayOfWeekMap[dayString])
        .toSet();
    return enabledWeekdays.contains(day.weekday);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _generateAvailableTimeSlots(DateTime day) async {
    setState(() {
      _isLoadingTimes = true;
      _availableTimeSlots = [];
      _selectedTime = null;
    });
    try {
      final startTime = _parseTime(_latestArtistData.startTime ?? '09:00');
      final endTime = _parseTime(_latestArtistData.endTime ?? '18:00');
      // Agora o 'sessionDurationInHours' existe no modelo Artist e não dará erro.
      final sessionDuration =
          Duration(hours: _latestArtistData.sessionDurationInHours);

      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('artistId', isEqualTo: _latestArtistData.uid)
          .where('dateTime', isGreaterThanOrEqualTo: startOfDay)
          .where('dateTime', isLessThan: endOfDay)
          .get();

      final bookedTimes = querySnapshot.docs
          .map((doc) =>
              TimeOfDay.fromDateTime(Appointment.fromFirestore(doc).dateTime))
          .toSet();

      List<TimeOfDay> potentialSlots = [];
      DateTime currentTime = startOfDay
          .add(Duration(hours: startTime.hour, minutes: startTime.minute));
      DateTime workEndTime = startOfDay
          .add(Duration(hours: endTime.hour, minutes: endTime.minute));

      while (currentTime
          .add(sessionDuration)
          .isBefore(workEndTime.add(const Duration(seconds: 1)))) {
        potentialSlots.add(TimeOfDay.fromDateTime(currentTime));
        currentTime = currentTime.add(sessionDuration);
      }

      final availableSlots = potentialSlots
          .where((slot) => !bookedTimes.any((booked) =>
              booked.hour == slot.hour && booked.minute == slot.minute))
          .toList();

      setState(() {
        _availableTimeSlots = availableSlots;
      });
    } finally {
      setState(() {
        _isLoadingTimes = false;
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDay == null || _selectedTime == null) return;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isBooking = true);
    try {
      final bookingDateTime = DateTime(_selectedDay!.year, _selectedDay!.month,
          _selectedDay!.day, _selectedTime!.hour, _selectedTime!.minute);
      final newAppointment = {
        'artistId': _latestArtistData.uid,
        'artistName': _latestArtistData.studioName,
        'clientId': currentUser.uid,
        'clientName': currentUser.displayName ?? 'Utilizador sem nome',
        'dateTime': Timestamp.fromDate(bookingDateTime),
        'status': 'pending',
      };
      await FirebaseFirestore.instance
          .collection('appointments')
          .add(newAppointment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Solicitação de agendamento enviada com sucesso!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao confirmar agendamento: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isArtistDataLoading
            ? 'A carregar...'
            : 'Agendar com ${_latestArtistData.studioName}'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: _selectedDay != null && _selectedTime != null
          ? FloatingActionButton.extended(
              onPressed: _isBooking ? null : _confirmBooking,
              label: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Solicitar Horário"),
              icon: _isBooking ? null : const Icon(Icons.check),
            )
          : null,
      body: _isArtistDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selecione uma data",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: TableCalendar(
                      locale: 'pt_BR',
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      enabledDayPredicate: _isDayEnabled,
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!_isDayEnabled(selectedDay)) return;
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _generateAvailableTimeSlots(selectedDay);
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      calendarStyle: CalendarStyle(
                          disabledTextStyle: TextStyle(color: Colors.grey[600]),
                          todayDecoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.5),
                              shape: BoxShape.circle),
                          selectedDecoration: const BoxDecoration(
                              color: Colors.purple, shape: BoxShape.circle)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedDay != null)
                    Text(
                        "Horários para ${DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDay!)}:",
                        style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  if (_selectedDay != null)
                    Text(
                      "Cada horário representa um bloco de ${_latestArtistData.sessionDurationInHours} hora(s).",
                      style: const TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 16),
                  if (_isLoadingTimes)
                    const Center(child: CircularProgressIndicator())
                  else if (!_isLoadingTimes &&
                      _availableTimeSlots.isEmpty &&
                      _selectedDay != null)
                    const Center(
                        child:
                            Text("Nenhum horário disponível para esta data."))
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableTimeSlots.map((time) {
                        final isSelected = _selectedTime == time;
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.purple : Colors.grey[800],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: Text(time.format(context),
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
