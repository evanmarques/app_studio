// lib/features/appointments/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_studio_app/models/artist.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:pc_studio_app/models/tattoo_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Artist artist;
  final TattooService selectedService;

  const BookingScreen({
    super.key,
    required this.artist,
    required this.selectedService,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Variáveis de estado para controlar a UI
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<TimeOfDay> _selectedTimeSlots = [];
  List<TimeOfDay> _availableTimeSlots = [];
  bool _isLoadingTimes = false;
  bool _isBooking = false;

  // Mapa para conversão de dias da semana
  final Map<String, int> _dayOfWeekMap = {
    'monday': DateTime.monday,
    'tuesday': DateTime.tuesday,
    'wednesday': DateTime.wednesday,
    'thursday': DateTime.thursday,
    'friday': DateTime.friday,
    'saturday': DateTime.saturday,
    'sunday': DateTime.sunday,
  };

  /// Verifica se um dia da semana está habilitado no perfil do artista.
  bool _isDayEnabled(DateTime day) {
    final enabledWeekdays = widget.artist.workingDays
        .map((dayString) => _dayOfWeekMap[dayString])
        .toSet();
    return enabledWeekdays.contains(day.weekday);
  }

  /// Converte uma string de hora (ex: "09:00") para um objeto TimeOfDay.
  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Gera a lista de horários disponíveis para um dia.
  Future<void> _generateAvailableTimeSlots(DateTime day) async {
    setState(() {
      _isLoadingTimes = true;
      _availableTimeSlots = [];
      _selectedTimeSlots.clear();
    });
    try {
      final startTime = _parseTime(widget.artist.startTime ?? '09:00');
      final endTime = _parseTime(widget.artist.endTime ?? '18:00');
      final sessionDuration =
          Duration(hours: widget.selectedService.durationInHours);
      final startOfDay = DateTime(day.year, day.month, day.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('artistId', isEqualTo: widget.artist.uid)
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

      if (mounted)
        setState(() {
          _availableTimeSlots = availableSlots;
        });
    } finally {
      if (mounted)
        setState(() {
          _isLoadingTimes = false;
        });
    }
  }

  /// Lida com o toque em um horário, adicionando ou removendo da lista de seleção.
  void _onTimeSlotTapped(TimeOfDay tappedTime) {
    setState(() {
      final isSelected = _selectedTimeSlots.contains(tappedTime);
      if (isSelected) {
        _selectedTimeSlots.remove(tappedTime);
      } else {
        _selectedTimeSlots.add(tappedTime);
      }
      _selectedTimeSlots.sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    });
  }

  /// Valida se os horários selecionados são consecutivos.
  bool _areSelectedSlotsConsecutive() {
    if (_selectedTimeSlots.length <= 1) return true;
    for (int i = 0; i < _selectedTimeSlots.length - 1; i++) {
      final currentSlot = _selectedTimeSlots[i];
      final nextSlot = _selectedTimeSlots[i + 1];
      final currentInMinutes = currentSlot.hour * 60 + currentSlot.minute;
      final nextInMinutes = nextSlot.hour * 60 + nextSlot.minute;
      final expectedNextInMinutes =
          currentInMinutes + (widget.selectedService.durationInHours * 60);
      if (nextInMinutes != expectedNextInMinutes) return false;
    }
    return true;
  }

  /// Salva o novo agendamento no Firestore.
  Future<void> _confirmBooking() async {
    if (_selectedDay == null || _selectedTimeSlots.isEmpty) return;
    if (!_areSelectedSlotsConsecutive()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, selecione apenas horários consecutivos.')));
      return;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isBooking = true);
    try {
      final firstSlot = _selectedTimeSlots.first;
      final bookingDateTime = DateTime(_selectedDay!.year, _selectedDay!.month,
          _selectedDay!.day, firstSlot.hour, firstSlot.minute);
      final totalDuration =
          widget.selectedService.durationInHours * _selectedTimeSlots.length;
      final newAppointment = {
        'artistId': widget.artist.uid,
        'artistName': widget.artist.studioName,
        'clientId': currentUser.uid,
        'clientName': currentUser.displayName ?? 'Utilizador sem nome',
        'dateTime': Timestamp.fromDate(bookingDateTime),
        'status': 'pending',
        'serviceStyle': widget.selectedService.style,
        'serviceSize': widget.selectedService.size,
        'serviceDuration': totalDuration,
      };
      await FirebaseFirestore.instance
          .collection('appointments')
          .add(newAppointment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Solicitação de agendamento enviada com sucesso!')));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao confirmar agendamento: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        _selectedTimeSlots.isNotEmpty && _areSelectedSlotsConsecutive();

    return Scaffold(
      appBar: AppBar(
          title: Text('Agendar com ${widget.artist.studioName}'),
          backgroundColor: Colors.transparent),
      floatingActionButton: canConfirm
          ? FloatingActionButton.extended(
              onPressed: _isBooking ? null : _confirmBooking,
              label: _isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Solicitar Horário(s)"),
              icon: _isBooking ? null : const Icon(Icons.check),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. Selecione uma data",
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
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                  if (_calendarFormat != format)
                    setState(() {
                      _calendarFormat = format;
                    });
                },
                calendarStyle: CalendarStyle(
                  disabledTextStyle: TextStyle(color: Colors.grey[600]),
                  todayDecoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.5),
                      shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(
                      color: Colors.purple, shape: BoxShape.circle),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_selectedDay != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("2. Escolha um ou mais horários",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Serviço selecionado: ${widget.selectedService.style} - ${widget.selectedService.size} (${widget.selectedService.durationInHours}h por bloco).",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingTimes)
                    const Center(child: CircularProgressIndicator())
                  else if (_availableTimeSlots.isEmpty)
                    const Center(
                        child:
                            Text("Nenhum horário disponível para esta data."))
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _availableTimeSlots.map((time) {
                        final isSelected = _selectedTimeSlots.contains(time);
                        return ElevatedButton(
                          onPressed: () => _onTimeSlotTapped(time),
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
                ],
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
