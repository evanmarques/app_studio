// lib/features/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:pc_studio_app/features/appointments/appointment_list_item.dart';
import 'package:intl/intl.dart';

/// Tela que exibe agendamentos. A sua funcionalidade adapta-se
/// se o utilizador com sessão iniciada é um cliente ou um artista.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isArtist = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  /// Verifica no Firestore se o utilizador atual tem um perfil de estúdio.
  Future<void> _checkUserRole() async {
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }
    final studioDoc = await FirebaseFirestore.instance
        .collection('studios')
        .doc(currentUser!.uid)
        .get();

    if (mounted) {
      setState(() {
        _isArtist = studioDoc.exists;
        _isLoading = false;
      });
    }
  }

  /// Lógica para cancelar um agendamento (usada pelo cliente).
  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': 'cancelled'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento cancelado com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cancelar o agendamento: $e')),
        );
      }
    }
  }

  /// Lógica para o artista atualizar o status de um agendamento.
  Future<void> _updateAppointmentStatus(
      String appointmentId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
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
        title: Text(_isArtist ? "Agenda do Estúdio" : "Meus Agendamentos"),
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
              ? const Center(
                  child: Text("Faça login para ver os seus agendamentos."))
              : _isArtist
                  ? _buildArtistView()
                  : _buildClientView(),
    );
  }

  /// Constrói a UI para um cliente comum.
  Widget _buildClientView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('clientId', isEqualTo: currentUser!.uid)
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Ocorreu um erro: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(
              child: Text("Você ainda não possui agendamentos."));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final appointment =
                Appointment.fromFirestore(snapshot.data!.docs[index]);
            return AppointmentListItem(
              appointment: appointment,
              onCancel: _cancelAppointment,
            );
          },
        );
      },
    );
  }

  /// Constrói a UI para o artista, com abas para diferentes status.
  Widget _buildArtistView() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Pendentes'),
              Tab(text: 'Confirmados'),
              Tab(text: 'Histórico'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAppointmentsListForArtist(status: ['pending']),
                _buildAppointmentsListForArtist(status: ['confirmed']),
                _buildAppointmentsListForArtist(status: [
                  'cancelled',
                  'completed'
                ]), // Histórico inclui cancelados e concluídos
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget que busca e constrói uma lista de agendamentos para o artista, filtrada por status.
  Widget _buildAppointmentsListForArtist({required List<String> status}) {
    return StreamBuilder<QuerySnapshot>(
      // 2. CONSULTA ATUALIZADA para usar o operador 'whereIn'
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('artistId', isEqualTo: currentUser!.uid)
          .where('status', whereIn: status)
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Ocorreu um erro: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("Nenhum agendamento encontrado."));

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final appointment =
                Appointment.fromFirestore(snapshot.data!.docs[index]);
            // A UI para o item da lista do artista
            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text("Cliente: ${appointment.clientName}"),
                // 3. O DateFormat agora é reconhecido por causa do import adicionado
                subtitle: Text(DateFormat('dd/MM/yyyy \'às\' HH:mm', 'pt_BR')
                    .format(appointment.dateTime)),
                // Se for pendente, mostra os botões de ação.
                trailing: appointment.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateAppointmentStatus(
                                  appointment.id, 'confirmed')),
                          IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateAppointmentStatus(
                                  appointment.id, 'cancelled')),
                        ],
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
