// lib/features/appointments/service_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/models/artist.dart';
import 'package:pc_studio_app/models/tattoo_service.dart';
import 'package:pc_studio_app/features/appointments/booking_screen.dart';

/// Tela onde o cliente seleciona qual serviço deseja agendar antes de ver o calendário.
class ServiceSelectionScreen extends StatefulWidget {
  final Artist artist;

  const ServiceSelectionScreen({super.key, required this.artist});

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  // Guarda o serviço que o cliente selecionou.
  TattooService? _selectedService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Escolha o Serviço"),
        backgroundColor: Colors.transparent,
      ),
      // O botão flutuante para continuar só fica ativo se um serviço for selecionado.
      floatingActionButton: _selectedService != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navega para a tela de agendamento (calendário), passando o artista E o serviço selecionado.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(
                      artist: widget.artist,
                      selectedService:
                          _selectedService!, // Passamos o serviço escolhido
                    ),
                  ),
                );
              },
              label: const Text("Continuar"),
              icon: const Icon(Icons.arrow_forward),
            )
          : null,
      body: StreamBuilder<QuerySnapshot>(
        // Busca a lista de serviços da subcoleção do artista.
        stream: FirebaseFirestore.instance
            .collection('studios')
            .doc(widget.artist.uid)
            .collection('services')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text("Erro ao carregar serviços."));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child:
                    Text("Este artista ainda não cadastrou nenhum serviço."));
          }

          // Constrói a lista de serviços selecionáveis.
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final service =
                  TattooService.fromFirestore(snapshot.data!.docs[index]);

              // Usamos um RadioListTile para uma seleção clara de item único.
              return RadioListTile<TattooService>(
                title: Text("${service.style} - ${service.size}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "Duração estimada: ${service.durationInHours} hora(s)"),
                value: service,
                groupValue: _selectedService,
                onChanged: (TattooService? value) {
                  setState(() {
                    _selectedService = value;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
