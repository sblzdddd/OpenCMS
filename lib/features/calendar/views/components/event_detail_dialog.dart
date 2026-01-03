import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../../models/calendar.dart';
import '../../services/calendar_service.dart';

final _logger = Logger('EventDetailDialog');

class EventDetailDialog extends StatefulWidget {
  final SchoolCalendarAppointment appointment;
  final CalendarService calendarService;

  const EventDetailDialog({
    super.key,
    required this.appointment,
    required this.calendarService,
  });

  static Future<void> show(
    BuildContext context,
    SchoolCalendarAppointment appointment,
    CalendarService calendarService,
  ) {
    return showDialog(
      context: context,
      builder: (context) => EventDetailDialog(
        appointment: appointment,
        calendarService: calendarService,
      ),
    );
  }

  @override
  State<EventDetailDialog> createState() => _EventDetailDialogState();
}

class _EventDetailDialogState extends State<EventDetailDialog> {
  CalendarDetailResponse? _detail;
  String? _comment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final event = widget.appointment.sourceEvent;

    try {
      _detail = await widget.calendarService.getCalendarDetail(eventId: event.id);

      // Try to get comment based on event kind
      String commentKind = '';
      switch (event.kind) {
        case 'fieldtrip':
          commentKind = 'ft_title';
          break;
        case 'fixture':
          commentKind = 'fv_title';
          break;
        case 'visit_event':
          commentKind = 've_title';
          break;
        case 'sl_event':
          commentKind = 'sle_title';
          break;
        case 'su_event':
          commentKind = 'sue_title';
          break;
      }

      if (commentKind.isNotEmpty) {
        final commentResponse = await widget.calendarService.getCalendarComment(
          eventId: event.id,
          kind: commentKind,
        );
        _comment = commentResponse.content;
      }
    } catch (e) {
      _logger.severe('Failed to fetch event details: $e');
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
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final event = widget.appointment.sourceEvent;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
      ),
      clipBehavior: Clip.antiAlias,
      title: Text(event.title),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Type', event.eventType),
                  _buildDetailRow('Category', event.cat),
                  _buildDetailRow(
                    'Date',
                    widget.appointment.from.toString().split(' ')[0],
                  ),
                  if (event.isPostponed) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: themeNotifier.getBorderRadiusAll(0.25),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Symbols.schedule_rounded,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'This event has been postponed',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_detail != null) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (_detail!.location.isNotEmpty)
                      _buildDetailRow('Location', _detail!.location),
                    if (_detail!.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Description:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(_detail!.content),
                    ],
                  ],
                  if (_comment != null && _comment!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Additional Information:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(_comment!),
                  ],
                ],
              ),
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
