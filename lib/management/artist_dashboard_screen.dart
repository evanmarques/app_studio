import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pc_studio_app/management/portfolio_manager_screen.dart';

// Tela de painel para o artista gerenciar seu perfil.
class ArtistDashboardScreen extends StatefulWidget {
  const ArtistDashboardScreen({super.key});

  @override
  State<ArtistDashboardScreen> createState() => _ArtistDashboardScreenState();
}

class _ArtistDashboardScreenState extends State<ArtistDashboardScreen> {
  // Controladores para os campos de texto de horário.
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  // Instâncias dos serviços do Firebase.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Assim que a tela é iniciada, carrega os horários já salvos.
    _loadSchedule();
  }

  // Limpa os controladores para liberar memória.
  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  // Carrega os horários salvos no Firestore para preencher os campos.
  Future<void> _loadSchedule() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await _db
          .collection("studios")
          .doc(userId)
          .collection("availability")
          .doc("default")
          .get();
      if (doc.exists) {
        _startTimeController.text = doc.data()?['startTime'] ?? '';
        _endTimeController.text = doc.data()?['endTime'] ?? '';
      }
    } catch (e) {
      // Trata possíveis erros de busca no banco.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Salva os novos horários no Firestore.
  Future<void> _saveSchedule() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _isLoading = true;
    });

    final availability = {
      "startTime": _startTimeController.text.trim(),
      "endTime": _endTimeController.text.trim(),
    };

    try {
      await _db
          .collection("studios")
          .doc(userId)
          .collection("availability")
          .doc("default")
          .set(availability);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Horários salvos com sucesso!")));
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
      // Mostra um indicador de progresso enquanto carrega os dados iniciais.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Botão para gerenciar o portfólio.
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gerenciar Portfólio"),
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

                  // Seção de gerenciamento de horário.
                  const Text(
                    "Gerenciar Horários de Trabalho",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
                    onPressed: _saveSchedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Salvar Horários",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
