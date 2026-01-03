
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opencms/features/theme/services/theme_services.dart';
import 'classroom_calendar_data_source.dart';

class FreeClassroomDetailDialog extends StatelessWidget {
  final ClassroomAppointment appointment;
  final ThemeNotifier themeNotifier;

  const FreeClassroomDetailDialog({
    super.key,
    required this.appointment,
    required this.themeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
      ),
      clipBehavior: Clip.antiAlias,
      title: Text('${appointment.classroom} - ${appointment.subject}'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetailRow('Classroom', appointment.classroom),
          _buildDetailRow('Period', 'Period ${appointment.period}'),
          _buildDetailRow(
            'Time',
            '${DateFormat('HH:mm').format(appointment.startTime)} - ${DateFormat('HH:mm').format(appointment.endTime)}',
          ),
          _buildDetailRow(
            'Date',
            DateFormat('MMM dd, yyyy').format(appointment.startTime),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
