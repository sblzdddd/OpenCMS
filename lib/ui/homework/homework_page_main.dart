import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/data/constants/period_constants.dart';
import 'package:opencms/ui/shared/academic_year_dropdown.dart';
import 'package:opencms/ui/shared/views/refreshable_view.dart';
import '../../data/models/homework/homework_response.dart';
import '../../services/homework/homework_service.dart';

class HomeworkPageMain extends StatefulWidget {
  const HomeworkPageMain({super.key});

  @override
  State<HomeworkPageMain> createState() => _HomeworkPageMainState();
}

class _HomeworkPageMainState extends RefreshableView<HomeworkPageMain> {
  HomeworkResponse? _homeworkResponse;
  late AcademicYear _selectedYear;
  bool _showSettings = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedCardIds = <int>{};
  List<HomeworkItem> _filteredHomeworkItems = [];

  @override
  void initState() {
    _selectedYear = PeriodConstants.getAcademicYears().first;
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final response = await HomeworkService().fetchHomework(
      academicYear: _selectedYear.year,
      refresh: refresh,
    );

    setState(() {
      _homeworkResponse = response;
      _filteredHomeworkItems = response.homeworkItems;
    });
  }

  @override
  bool get isEmpty => _homeworkResponse == null || _homeworkResponse!.homeworkItems.isEmpty;

  @override
  String get errorTitle => 'Failed to load homework';

  void _onYearChanged(AcademicYear? year) {
    if (year != null) {
      setState(() {
        _selectedYear = year;
      });
      loadData();
    }
  }

  void _toggleCardExpansion(int cardId) {
    setState(() {
      if (_expandedCardIds.contains(cardId)) {
        _expandedCardIds.remove(cardId);
      } else {
        _expandedCardIds.add(cardId);
      }
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AcademicYearDropdown(
              selectedYear: _selectedYear,
              onChanged: _onYearChanged,
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Toggle settings',
              icon: Icon(Symbols.search_rounded, fill: _showSettings ? 1 : 0),
              onPressed: () {
                setState(() {
                  _showSettings = !_showSettings;
                });
              },
            ),
          ],
        ),
        if (_showSettings) ...[
          _buildSearchFilter(),
          const SizedBox(height: 12),
        ],
        Expanded(child: _buildHomeworkList()),
      ],
    );
  }

  Widget _buildSearchFilter() {
    return Row(
      children: [
        Expanded(
          child: 
            // Search bar
            TextField(
              onChanged: _filterHomework,
              decoration: InputDecoration(
                hintText: 'Search homework...',
                prefixIcon: const Icon(Symbols.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
        ),
      ],
    );
  }

  void _filterHomework(String query) {
    if (_homeworkResponse == null) return;
    
    if (query.isEmpty) {
      setState(() {
        _filteredHomeworkItems = _homeworkResponse!.homeworkItems;
      });
    } else {
      final lowercaseQuery = query.toLowerCase();
      setState(() {
        _filteredHomeworkItems = _homeworkResponse!.homeworkItems.where((homework) {
          return homework.courseName.toLowerCase().contains(lowercaseQuery) ||
                 homework.title.toLowerCase().contains(lowercaseQuery) ||
                 homework.teacherName.toLowerCase().contains(lowercaseQuery) ||
                 homework.categoryText.toLowerCase().contains(lowercaseQuery);
        }).toList();
      });
    }
  }

  Widget _buildHomeworkList() {
    if (_filteredHomeworkItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.assignment_rounded, size: 64),
            SizedBox(height: 16),
            Text('No homework found', style: TextStyle(fontSize: 18)),
            Text(
              'Try adjusting your filters or check back later',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredHomeworkItems.length,
      itemBuilder: (context, index) {
        final homework = _filteredHomeworkItems[index];
        return _buildHomeworkCard(homework, index);
      },
    );
  }

  Widget _buildHomeworkCard(HomeworkItem homework, int index) {
    final isOverdue = homework.isOverdue;
    final daysUntilDue = homework.daysUntilDue;
    final isExpanded = _expandedCardIds.contains(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _toggleCardExpansion(index),
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
                      homework.courseName,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Symbols.expand_less_rounded
                        : Symbols.expand_more_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Title
              Text(
                homework.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14),
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
                                homework.teacherName,
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
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Additional Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildDetailedInfo(homework),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedInfo(HomeworkItem homework) {
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
                value: homework
                    .teacherName, // Assuming this field exists or can be added
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                icon: Symbols.schedule_rounded,
                label: 'Semester',
                value: '${_selectedYear.displayName}',
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
    return Row(
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
                  ).colorScheme.onSurface.withOpacity(0.7),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [Expanded(child: super.build(context))]),
    );
  }
}
