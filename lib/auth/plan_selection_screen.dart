import 'package:flutter/material.dart';
import 'package:pc_studio_app/auth/business_register_screen.dart'; // <-- IMPORT ADICIONADO
import 'package:pc_studio_app/models/plan.dart'; // <-- IMPORT ADICIONADO

// Tela para o usuário selecionar um plano de assinatura.
class PlanSelectionScreen extends StatelessWidget {
  const PlanSelectionScreen({super.key});

  // Função auxiliar para navegar para a tela de cadastro.
  void _navigateToRegister(BuildContext context, Plan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessRegisterScreen(selectedPlan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escolha seu Plano"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card para o Plano Free.
            _buildPlanCard(
              context: context,
              planName: "Plano Free",
              price: "R\$ 0,00",
              features: [
                "Cartão de visita digital",
                "Aparece nas buscas do app",
              ],
              onTap: () {
                // --- LÓGICA DE NAVEGAÇÃO ADICIONADA ---
                _navigateToRegister(context, Plan.free);
              },
            ),
            const SizedBox(height: 16),
            // Card para o Plano Básico.
            _buildPlanCard(
              context: context,
              planName: "Plano Básico",
              price: "R\$ 19,90/mês",
              features: [
                "Tudo do plano Free",
                "Upload de foto de perfil",
                "Links para redes sociais",
              ],
              onTap: () {
                // --- LÓGICA DE NAVEGAÇÃO ADICIONADA ---
                _navigateToRegister(context, Plan.basic);
              },
            ),
            const SizedBox(height: 16),
            // Card para o Plano Avançado.
            _buildPlanCard(
              context: context,
              planName: "Plano Avançado",
              price: "R\$ 49,90/mês",
              features: [
                "Tudo do plano Básico",
                "Galeria de portfólio com 10 fotos",
                "Gerenciamento de agenda online",
              ],
              onTap: () {
                // --- LÓGICA DE NAVEGAÇÃO ADICIONADA ---
                _navigateToRegister(context, Plan.advanced);
              },
            ),
            const SizedBox(height: 16),
            // Card para o Plano Premium.
            _buildPlanCard(
              context: context,
              planName: "Plano Premium",
              price: "R\$ 69,90/mês",
              features: [
                "Tudo do plano Avançado",
                "Gestão de Estoque e Vendas",
                "Teste de Tatuagem com AR (Em breve)",
              ],
              onTap: () {
                // --- LÓGICA DE NAVEGAÇÃO ADICIONADA ---
                _navigateToRegister(context, Plan.premium);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir os cards de plano.
  Widget _buildPlanCard({
    required BuildContext context,
    required String planName,
    required String price,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple),
              ),
              const SizedBox(height: 16),
              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(feature,
                                style: const TextStyle(fontSize: 16))),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
