import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:intl/intl.dart';

/// Um widget que exibe as informações de um único agendamento em um Card.
class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  const AppointmentListItem({super.key, required this.appointment});

  //-- NOVA FUNÇÃO --
  // Exibe o meni de opções (Modal Bottom Sheet) quando um item é tocado.
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Para o menu ter a altura mínima
            children: [
              Text(
                'Opções para o Agendamento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              // -- LÓGICA ADICIONAL --
              // Mostra o botão de cancelar apenas se o status for 'pending'.
              if (appointment.status == 'pending')
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.red),
                  title: const Text('Cancelar Agendamento'),
                  onTap: () {
                    //Fecha o menu e chama a função para cancelar.
                    Navigator.pop(context);
                    _cancelAppointment(context);
                  },
                ),
              if (appointment.status == 'pending')
                ListTile(
                  leading: const Icon(Icons.edit_calendar, color: Colors.blue),
                  title: const Text('Alterar Data (Em breve)'),
                  onTap: () {
                    //Placeholder para a funcionalidade de alterar a data.
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Funcionalidade de alterar data será implementada')));
                  },
                ),
              //Se o agendamento já foi confirmado, mostra uma mensagem.
              if (appointment.status == 'confirmed')
                const ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Este agendamento está confirmado.'),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // -- NOVA FUNÇÃO --
  // Atualiza o status do agendamento para 'cancelled' no Firestore.
  Future<void> _cancelAppointment(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(appointment.id) // Usa o ID do documento para encontrá-lo
          .update({'status': 'cancelled'}); // Atualiza apenas o campo 'status'

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento cancelado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERro ao cancelar agendamento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mantém a formatação de data e hora que já estava funcionando.
    // Ex: terça-feira, 1 de julho de 2025
    final formattedDate =
        DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(appointment.dateTime);
    // Ex: 15:00
    final formattedTime = DateFormat.Hm('pt_BR').format(appointment.dateTime);

    // --- CORREÇÃO APLICADA AQUI ---
    // 1. O Card agora é envolvido por um InkWell para capturar o evento de toque (onTap)
    //    e fornecer um efeito visual de clique (ripple).
    return InkWell(
      onTap: () {
        // 2. Ação a ser executada quando o item for tocado.
        //    Por enquanto, exibimos uma SnackBar como placeholder.
        //    No futuro, você pode substituir isso por uma navegação para uma tela de detalhes
        //    ou um diálogo com opções como "Cancelar Agendamento".
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Detalhes para o agendamento com ${appointment.artistName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      // Para o efeito de clique ter as bordas arredondadas do Card.
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        // Adicionamos um pouco mais de margem para o efeito de clique não ficar colado nos cantos.
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior:
            Clip.antiAlias, // Garante que o conteúdo respeite as bordas.
        elevation: 2,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          leading: const CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.calendar_month, color: Colors.white),
          ),
          title: Text(
            'Agendamento com ${appointment.artistName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('$formattedDate\nàs $formattedTime'),
          isThreeLine:
              true, // Permite mais espaço para o subtítulo com quebra de linha.
          trailing: Text(
            appointment.status,
            style: TextStyle(
              color: _getStatusColor(appointment.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// Retorna uma cor baseada no status do agendamento.
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
