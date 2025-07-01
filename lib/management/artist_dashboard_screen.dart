// lib/management/artist_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/management/portfolio_manager_screen.dart';

class ArtistDashboardScreen extends StatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen> {
  // Controladores para os campos de texto de horário
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Mapa para guardar o estado de seleção de cada dia da semana
  final Map<String, bool> _workingDays = {
    'monday': false,
    'tuesday': false,
    'wednesday': false,
    'thursday': false,
    'friday': false,
    'saturday': false,
    'sunday': false,
  };

  // Mapa para traduzir os nomes dos dias para português
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
    // Carrega a disponibilidade existente do artista quando o ecrã é iniciado
    _loadAvailability();
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // Carrega os dados de disponibilidade do Firestore
  Future<void> _loadAvailability() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await _db.collection("studios").doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _startTimeController.text = data['startTime'] ?? '';
        _endTimeController.text = data['endTime'] ?? '';

        // Carrega os dias de trabalho guardados
        final List<String> savedDays =
            List<String>.from(data['workingDays'] ?? []);
        // Atualiza o nosso mapa de seleção com os dias guardados
        for (var day in _workingDays.keys) {
          _workingDays[day] = savedDays.contains(day);
        }
      }
    } catch (e) {
      // Trata erros
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Guarda a nova disponibilidade no Firestore
  Future<void> _saveAvailability() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    // Cria uma lista apenas com os dias que foram selecionados (onde o valor é 'true')
    final selectedDays = _workingDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Dados a serem atualizados no documento do artista
    final availabilityData = {
      'workingDays': selectedDays,
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
    };

    try {
      // Usamos 'update' em vez de 'set' para não apagar os outros campos do documento
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gerir Portfólio"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PortfolioManagerScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Gerir Disponibilidade",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // SELEÇÃO DOS DIAS DA SEMANA
                  const Text("Dias de Trabalho:",
                      style: TextStyle(fontSize: 16)),
                  ..._workingDays.keys.map((day) {
                    return CheckboxListTile(
                      title: Text(_dayTranslations[day]!),
                      value: _workingDays[day],
                      onChanged: (bool? value) {
                        setState(() {
                          _workingDays[day] = value!;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 16),

                  // HORÁRIOS DE TRABALHO
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
            ),
    );
  }
}
