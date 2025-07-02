// lib/features/appointments/appointment_list_item.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:intl/intl.dart';

/// Um widget que exibe as informações de um único agendamento em um Card.
class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  const AppointmentListItem({super.key, required this.appointment});

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
