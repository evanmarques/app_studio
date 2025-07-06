// lib/management/artist_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/management/portfolio_manager_screen.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:intl/intl.dart';

class ArtistDashboardScreen extends StatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen> {
  // --- O SEU CÓDIGO EXISTENTE PARA GERIR DISPONIBILIDADE FOI MANTIDO ---
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  final Map<String, bool> _workingDays = {
    'monday': false,
    'tuesday': false,
    'wednesday': false,
    'thursday': false,
    'friday': false,
    'saturday': false,
    'sunday': false,
  };

  final Map<String, String> _dayTranslations = {
    'monday': 'Segunda-feira',
    'tuesday': 'Terça-feira',
    'wednesday': 'Quarta-feira',
    'thursday': 'Quinta-feira',
    'friday': 'Sexta-feira',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await _db.collection("studios").doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _startTimeController.text = data['startTime'] ?? '';
        _endTimeController.text = data['endTime'] ?? '';
        final List<String> savedDays =
            List<String>.from(data['workingDays'] ?? []);
        for (var day in _workingDays.keys) {
          _workingDays[day] = savedDays.contains(day);
        }
      }
    } catch (e) {
      // Tratar erros se necessário
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAvailability() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    setState(() => _isLoading = true);
    final selectedDays = _workingDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    final availabilityData = {
      'workingDays': selectedDays,
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
    };
    try {
      await _db.collection("studios").doc(userId).update(availabilityData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Disponibilidade salva com sucesso!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao salvar: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // --- FIM DO SEU CÓDIGO EXISTENTE ---

  /// Função para atualizar o status de um agendamento (confirmar ou cancelar).
  Future<void> _updateAppointmentStatus(
      String appointmentId, String newStatus) async {
    try {
      await _db
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Agendamento ${newStatus == 'confirmed' ? 'confirmado' : 'recusado'}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar agendamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Artista"),
        backgroundColor: Colors.transparent,
      ),
      // O corpo principal agora é um ListView para permitir a rolagem de todas as seções.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- SEÇÃO DE SOLICITAÇÕES PENDENTES ---
                const Text(
                  "Solicitações Pendentes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Este widget irá construir a lista de agendamentos pendentes.
                _buildPendingAppointmentsList(),
                const SizedBox(height: 32),

                // --- SUA SEÇÃO EXISTENTE PARA GERIR DISPONIBILIDADE ---
                const Text(
                  "Gerir Disponibilidade e Perfil",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gerir Portfólio"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PortfolioManagerScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey[700]!),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Dias de Trabalho:", style: TextStyle(fontSize: 16)),
                // O seu código para os Checkboxes dos dias da semana.
                ..._workingDays.keys.map((day) {
                  return CheckboxListTile(
                    title: Text(_dayTranslations[day]!),
                    value: _workingDays[day],
                    onChanged: (bool? value) {
                      setState(() => _workingDays[day] = value!);
                    },
                  );
                }),
                const SizedBox(height: 16),
                // Os seus campos de texto para os horários.
                TextField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(
                      labelText: "Horário de Início (ex: 09:00)",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                      labelText: "Horário de Fim (ex: 18:00)",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                // O seu botão para salvar a disponibilidade.
                ElevatedButton(
                  onPressed: _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Salvar Disponibilidade",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
    );
  }

  // --- WIDGET ATUALIZADO ---
  // Usa um StreamBuilder para buscar e exibir os agendamentos pendentes.
  Widget _buildPendingAppointmentsList() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      // Esta consulta irá agora funcionar corretamente com o novo índice.
      stream: _db
          .collection('appointments')
          .where('artistId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('dateTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text("Erro ao buscar solicitações: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text("Nenhuma solicitação pendente.")),
          );
        }

        final appointments = snapshot.data!.docs;

        // Usamos um ListView.builder para criar os itens da lista.
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = Appointment.fromFirestore(appointments[index]);
            final formattedDate = DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR')
                .format(appointment.dateTime);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(appointment.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formattedDate),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () =>
                          _updateAppointmentStatus(appointment.id, 'confirmed'),
                      tooltip: 'Confirmar',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () =>
                          _updateAppointmentStatus(appointment.id, 'cancelled'),
                      tooltip: 'Recusar',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
