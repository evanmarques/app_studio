// O import do 'cloud_firestore' foi removido, pois este widget não falará mais com a base de dados diretamente.
import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:intl/intl.dart';

/// Um widget que exibe as informações de um único agendamento em um Card.
/// Agora ele é um widget puramente de UI, sem lógica de negócio.
class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  // 1. NOVA FUNÇÃO DE CALLBACK
  // Esta função será passada pela tela pai (AppointmentsScreen) e será chamada
  // quando o utilizador confirmar o cancelamento.
  final Function(String appointmentId) onCancel;

  const AppointmentListItem({
    super.key,
    required this.appointment,
    required this.onCancel,
  });

  // A sua função showOptions foi adaptada para usar o callback.
  void showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Opções para o Agendamento",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              // Mostra o botão de cancelar apenas se o agendamento estiver confirmado.
              if (appointment.status == 'confirmed')
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                  title: const Text('Cancelar Agendamento'),
                  onTap: () {
                    // Primeiro, fecha o menu de opções.
                    Navigator.of(context).pop();
                    // Depois, mostra o diálogo de confirmação.
                    _showCancelConfirmationDialog(context);
                  },
                ),
              // Aqui poderíamos adicionar outras opções no futuro, como "Reagendar".
            ],
          ),
        );
      },
    );
  }

  /// Mostra um diálogo de confirmação antes de cancelar.
  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar Agendamento'),
          content: const Text(
              'Tem a certeza de que deseja cancelar este agendamento?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Voltar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Confirmar Cancelamento'),
              onPressed: () {
                // 2. CHAMA A FUNÇÃO onCancel, passando o ID do agendamento.
                // A responsabilidade de falar com o Firestore é agora da tela pai.
                onCancel(appointment.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat.yMMMMEEEEd('pt_BR').format(appointment.dateTime);
    final formattedTime = DateFormat.Hm('pt_BR').format(appointment.dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        onTap: () => showOptions(
            context), // O ListTile inteiro agora é clicável para mostrar as opções.
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.status).withOpacity(0.2),
          child: Icon(
            _getStatusIcon(appointment.status),
            color: _getStatusColor(appointment.status),
          ),
        ),
        title: Text(
          'Com ${appointment.artistName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$formattedDate às $formattedTime'),
        trailing: Text(
          appointment.status.toUpperCase(),
          style: TextStyle(
            color: _getStatusColor(appointment.status),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.highlight_off;
      case 'pending':
        return Icons.hourglass_top;
      default:
        return Icons.help_outline;
    }
  }
}
