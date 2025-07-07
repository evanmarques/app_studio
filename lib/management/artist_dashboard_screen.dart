// lib/management/artist_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/management/portfolio_manager_screen.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:pc_studio_app/models/plan.dart';
import 'package:intl/intl.dart';

class ArtistDashboardScreen extends StatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen> {
  // --- CONTROLADORES E ESTADO PARA TODAS AS FUNCIONALIDADES ---
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  // Controlador para a duração da sessão, REINTRODUZIDO
  final _sessionDurationController = TextEditingController(text: '1');

  // Estado para guardar o plano do artista, necessário para mostrar/ocultar o campo de duração
  Plan _artistPlan = Plan.free;

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
    // A função de load agora busca todos os dados do artista de uma vez
    _loadArtistData();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _sessionDurationController.dispose(); // Limpeza do novo controlador
    super.dispose();
  }

  /// Carrega todos os dados do estúdio: disponibilidade, duração da sessão e plano.
  Future<void> _loadArtistData() async {
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
        // Carrega a duração da sessão e o plano do artista
        _sessionDurationController.text =
            (data['sessionDurationInHours'] ?? 1).toString();
        _artistPlan = Plan.values.firstWhere(
          (e) => e.name == (data['plan'] ?? 'free'),
          orElse: () => Plan.free,
        );
      }
    } catch (e) {
      print("Erro ao carregar dados do artista: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Salva todas as configurações de disponibilidade.
  Future<void> _saveAvailability() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    setState(() => _isLoading = true);
    final selectedDays = _workingDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Agora inclui a duração da sessão nos dados a serem salvos
    final availabilityData = {
      'workingDays': selectedDays,
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
      'sessionDurationInHours':
          int.tryParse(_sessionDurationController.text) ?? 1,
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

  /// Atualiza o status de um agendamento.
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              // O corpo principal é um ListView para permitir rolagem de todas as seções
              padding: const EdgeInsets.all(16.0),
              children: [
                // A secção de "Solicitações Pendentes" que tínhamos implementado permanece aqui
                const Text("Solicitações Pendentes",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildPendingAppointmentsList(),
                const SizedBox(height: 32),

                // A secção de gestão foi unificada
                const Text("Gerir Disponibilidade e Perfil",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gerir Portfólio"),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PortfolioManagerScreen())),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[700]!)),
                ),
                const SizedBox(height: 24),

                // CAMPO DE DURAÇÃO DA SESSÃO REINTRODUZIDO
                // Ele só aparece se o plano do artista não for o "Free"
                if (_artistPlan != Plan.free)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _sessionDurationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Duração da sessão (em horas)",
                          border: OutlineInputBorder(),
                          helperText:
                              "Ex: 1 para uma hora, 2 para duas horas, etc."),
                    ),
                  ),

                // Resto do formulário de disponibilidade
                const Text("Dias de Trabalho:", style: TextStyle(fontSize: 16)),
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
                TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                        labelText: "Horário de Início (ex: 09:00)",
                        border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                        labelText: "Horário de Fim (ex: 18:00)",
                        border: OutlineInputBorder())),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveAvailability,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Salvar Disponibilidade",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
    );
  }

  /// Widget que busca e exibe os agendamentos pendentes.
  Widget _buildPendingAppointmentsList() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('appointments')
          .where('artistId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('dateTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Erro: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Center(child: Text("Nenhuma solicitação pendente.")));

        final appointments = snapshot.data!.docs;
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
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _updateAppointmentStatus(
                            appointment.id, 'confirmed'),
                        tooltip: 'Confirmar'),
                    IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _updateAppointmentStatus(
                            appointment.id, 'cancelled'),
                        tooltip: 'Recusar'),
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
