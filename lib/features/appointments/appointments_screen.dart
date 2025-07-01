// lib/features/appointments/appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:pc_studio_app/features/appointments/appointment_list_item.dart'; // 1. Importamos o nosso novo widget

/// Tela que exibe uma lista de agendamentos para o utilizador atual.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // Obtém a instância do utilizador atual do Firebase Auth.
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Agendamentos"),
        backgroundColor: Colors.transparent,
      ),
      // Verificamos se há um utilizador com sessão iniciada.
      body: currentUser == null
          // Se não houver, mostra uma mensagem para fazer login.
          ? const Center(
              child: Text("Faça login para ver os seus agendamentos."),
            )
          // Se houver, usamos um StreamBuilder para ouvir os dados em tempo real.
          : StreamBuilder<QuerySnapshot>(
              // 2. AQUI ESTÁ A NOSSA CONSULTA AO FIREBASE:
              //    - Vai à coleção 'appointments'.
              //    - Filtra para obter apenas os documentos onde o 'clientId' é igual ao UID do nosso utilizador.
              //    - Ordena os resultados pela data, dos mais recentes para os mais antigos.
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('clientId', isEqualTo: currentUser!.uid)
                  .orderBy('dateTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Se o snapshot tiver um erro (ex: problema de permissão)
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Ocorreu um erro: ${snapshot.error}"));
                }

                // Enquanto os dados estão a ser carregados
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Se não houver dados ou a lista de documentos estiver vazia
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Você ainda não possui agendamentos.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Se tudo correu bem, temos os dados!
                final appointmentDocs = snapshot.data!.docs;

                // 3. Usamos um ListView.builder para construir a lista de forma eficiente.
                return ListView.builder(
                  itemCount: appointmentDocs.length,
                  itemBuilder: (context, index) {
                    // Para cada documento, criamos um objeto Appointment.
                    final appointment =
                        Appointment.fromFirestore(appointmentDocs[index]);
                    // E usamos o nosso widget AppointmentListItem para exibi-lo.
                    return AppointmentListItem(appointment: appointment);
                  },
                );
              },
            ),
    );
  }
}
