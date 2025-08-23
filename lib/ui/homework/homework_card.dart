import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../data/models/homework/homework_response.dart';
import '../../services/homework/completed_homework_service.dart';

class HomeworkCard extends StatefulWidget {
  final HomeworkItem homework;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;
  final String selectedYearDisplayName;
  final VoidCallback? onCompletionStatusChanged;

  const HomeworkCard({
    super.key,
    required this.homework,
    required this.index,
    required this.isExpanded,
    required this.onTap,
    required this.selectedYearDisplayName,
    this.onCompletionStatusChanged,
  });

  @override
  State<HomeworkCard> createState() => _HomeworkCardState();
}

class _HomeworkCardState extends State<HomeworkCard> {
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  @override
  void didUpdateWidget(covariant HomeworkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homework.courseName != widget.homework.courseName ||
        oldWidget.homework.title != widget.homework.title) {
      _checkCompletionStatus();
    }
  }

  Future<void> _checkCompletionStatus() async {
    final completed = await CompletedHomeworkService.isHomeworkCompleted(
      widget.homework,
    );
    if (mounted) {
      setState(() {
        _isCompleted = completed;
      });
    }
  }

  void _addToCalendar() {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      // TODO: Add schedule support for desktop platforms
      return;
    }
    final startDate = DateTime(
      widget.homework.assignedDate.year,
      widget.homework.assignedDate.month,
      widget.homework.assignedDate.day,
    );
    final endDate = DateTime(
      widget.homework.dueDate.year,
      widget.homework.dueDate.month,
      widget.homework.dueDate.day,
    );
    final event = Event(
      title: '${widget.homework.courseName} Homework',
      description: widget.homework.title,
      location: "SCIE",
      startDate: startDate,
      endDate: endDate,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  Future<void> _markAsDone() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isCompleted) {
        await CompletedHomeworkService.markHomeworkNotCompleted(
          widget.homework,
        );
        setState(() {
          _isCompleted = false;
        });
      } else {
        await CompletedHomeworkService.markHomeworkCompleted(widget.homework);
        setState(() {
          _isCompleted = true;
        });
      }

      // Notify parent about completion status change
      widget.onCompletionStatusChanged?.call();
    } catch (e) {
      print('Error toggling homework completion: $e');
      // Show error message to user if needed
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
    final isOverdue = widget.homework.isOverdue;
    final daysUntilDue = widget.homework.daysUntilDue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: _isCompleted ? 0.5 : 1,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with course name and expand/collapse button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.homework.courseName,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.primary,
                          decoration: _isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          decorationThickness: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      widget.isExpanded
                          ? Symbols.expand_less_rounded
                          : Symbols.expand_more_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Title with strikethrough if completed
                Text(
                  widget.homework.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    decoration: _isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Theme.of(context).colorScheme.primary,
                    decorationThickness: 2,
                  ),
                ),

                const SizedBox(height: 12),

                // Basic info (always visible)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isOverdue
                                    ? Symbols.warning_rounded
                                    : Symbols.info_rounded,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  isOverdue
                                      ? 'Overdue by ${daysUntilDue.abs()} days'
                                      : daysUntilDue > 0
                                      ? 'Due in $daysUntilDue days'
                                      : 'Due today',
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Symbols.person_rounded, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.homework.teacherName,
                                  style: TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Expanded detailed info
                if (widget.isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildDetailedInfo(
                    widget.homework,
                    widget.selectedYearDisplayName,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedInfo(
    HomeworkItem homework,
    String selectedYearDisplayName,
  ) {
    return Column(
      children: [
        // Row 1: Assigned Date and Status
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.calendar_today_rounded,
                label: 'Assigned Date',
                value:
                    '${homework.assignedDate.year}/${homework.assignedDate.month}/${homework.assignedDate.day}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.assignment_rounded,
                label: 'Status',
                value: homework.isOverdue ? 'Overdue' : 'Active',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 2: Priority and Type
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.schedule_rounded,
                label: 'Due Date',
                value:
                    '${homework.dueDate.year}/${homework.dueDate.month}/${homework.dueDate.day}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.type_specimen_rounded,
                label: 'Type',
                value: homework.categoryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 3: Course Code and Semester
        Row(
          children: [
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.school_rounded,
                label: 'Teacher',
                value: homework.teacherName,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.schedule_rounded,
                label: 'Semester',
                value: selectedYearDisplayName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _addToCalendar();
                },
                child: Row(
                  children: [
                    Icon(Symbols.calendar_today_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text('Add to Calendar'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _markAsDone,
                child: _isLoading
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        children: [
                          Icon(
                            _isCompleted
                                ? Symbols.check_circle_rounded
                                : Symbols.radio_button_unchecked_rounded,
                            size: 16,
                            color: _isCompleted
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isCompleted ? 'Mark as Undone' : 'Mark as Done',
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
