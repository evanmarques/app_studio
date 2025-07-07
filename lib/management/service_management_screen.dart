// lib/management/service_management_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_studio_app/models/tattoo_service.dart';

/// Tela onde o artista pode gerir os seus serviços (tipos de tatuagem e duração).
class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Retorna a referência para a subcoleção 'services' do artista atual.
  CollectionReference get _servicesCollection {
    final userId = _auth.currentUser!.uid;
    return _db.collection('studios').doc(userId).collection('services');
  }

  /// Mostra um diálogo para adicionar um novo serviço ou editar um existente.
  Future<void> _showServiceDialog({TattooService? service}) async {
    // Se estivermos a editar um serviço, os controladores são preenchidos com os dados existentes.
    final styleController = TextEditingController(text: service?.style ?? '');
    final sizeController = TextEditingController(text: service?.size ?? '');
    final durationController =
        TextEditingController(text: service?.durationInHours.toString() ?? '1');

    // Usamos uma GlobalKey para validar o formulário.
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              service == null ? 'Adicionar Novo Serviço' : 'Editar Serviço'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: styleController,
                    decoration: const InputDecoration(
                        labelText: 'Estilo da Tatuagem (ex: Fineline)'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: sizeController,
                    decoration: const InputDecoration(
                        labelText: 'Tamanho (ex: Pequeno, Médio)'),
                    validator: (value) =>
                        value!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  TextFormField(
                    controller: durationController,
                    decoration:
                        const InputDecoration(labelText: 'Duração (em horas)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Campo obrigatório';
                      if (int.tryParse(value) == null)
                        return 'Insira um número válido';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () {
                // Se o formulário for válido, procede para salvar os dados.
                if (formKey.currentState!.validate()) {
                  _addOrUpdateService(
                    style: styleController.text,
                    size: sizeController.text,
                    duration: int.parse(durationController.text),
                    serviceId: service?.id, // Passa o ID se estivermos a editar
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Adiciona ou atualiza um serviço no Firestore.
  Future<void> _addOrUpdateService({
    required String style,
    required String size,
    required int duration,
    String? serviceId,
  }) async {
    final serviceData = {
      'style': style,
      'size': size,
      'durationInHours': duration,
    };

    try {
      if (serviceId == null) {
        // Se não houver ID, é um novo serviço, então usamos 'add'.
        await _servicesCollection.add(serviceData);
      } else {
        // Se houver um ID, é uma edição, então usamos 'update'.
        await _servicesCollection.doc(serviceId).update(serviceData);
      }
    } catch (e) {
      // Trata possíveis erros
    }
  }

  /// Remove um serviço do Firestore.
  Future<void> _deleteService(String serviceId) async {
    try {
      await _servicesCollection.doc(serviceId).delete();
    } catch (e) {
      // Trata possíveis erros
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerir Serviços'),
        backgroundColor: Colors.transparent,
      ),
      // O botão flutuante abre o diálogo para adicionar um novo serviço.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(),
        tooltip: 'Adicionar Serviço',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // O StreamBuilder ouve as alterações na subcoleção 'services' do artista.
        stream: _servicesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Erro: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum serviço cadastrado.\nClique no botão "+" para adicionar o seu primeiro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Se houver dados, construímos a lista de serviços.
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final service =
                  TattooService.fromFirestore(snapshot.data!.docs[index]);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${service.style} - ${service.size}'),
                  subtitle: Text('Duração: ${service.durationInHours} hora(s)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showServiceDialog(
                            service:
                                service), // Abre o diálogo em modo de edição
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteService(
                            service.id), // Chama a função de remoção
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
