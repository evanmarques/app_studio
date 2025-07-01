// lib/features/appointments/appointment_list_item.dart

import 'package:flutter/material.dart';
import 'package:pc_studio_app/models/appointment.dart';
import 'package:intl/intl.dart'; // Para formatar a data e hora

/// Um widget que exibe as informações de um único agendamento em um Card.
class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  const AppointmentListItem({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    // Formata a data para um formato legível, ex: "Ter, 30 de Junho de 2025"
    final formattedDate =
        DateFormat.yMMMMEEEEd('pt_BR').format(appointment.dateTime);
    // Formata a hora, ex: "15:00"
    final formattedTime = DateFormat.Hm('pt_BR').format(appointment.dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.calendar_month, color: Colors.white),
        ),
        title: Text(
          'Agendamento com ${appointment.artistName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$formattedDate às $formattedTime'),
        trailing: Text(
          appointment.status,
          style: TextStyle(
            color: _getStatusColor(appointment.status),
            fontWeight: FontWeight.bold,
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
