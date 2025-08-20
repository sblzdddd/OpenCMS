import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/models/homework/homework_response.dart';
import '../../../services/homework/homework_service.dart';
import '../../../ui/shared/custom_snackbar/snackbar_utils.dart';

class HomeworkPageMain extends StatefulWidget {
  const HomeworkPageMain({super.key});

  @override
  State<HomeworkPageMain> createState() => _HomeworkPageMainState();
}

class _HomeworkPageMainState extends State<HomeworkPageMain> {
  final HomeworkService _homeworkService = HomeworkService();

  // State variables
  HomeworkResponse? _homeworkResponse;
  bool _isLoading = false;
  bool _showOptions = false;
  int _currentPage = 1;

  // Filter options
  int _selectedAcademicYear = DateTime.now().year;
  String? _selectedCourseId;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  // Controllers
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHomework();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHomework() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _homeworkService.fetchHomework(
        academicYear: _selectedAcademicYear,
        courseId: _selectedCourseId,
        dueDateStart: _selectedStartDate?.toIso8601String().split('T')[0],
        dueDateEnd: _selectedEndDate?.toIso8601String().split('T')[0],
        page: _currentPage,
      );

      if (mounted) {
      setState(() {
          _homeworkResponse = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to fetch homework: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _markAsCompleted(String homeworkId) async {
    try {
      final success = await _homeworkService.markHomeworkCompleted(homeworkId);
      if (success && mounted) {
        SnackbarUtils.showSuccess(context, 'Homework marked as completed!');
        _fetchHomework(); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to mark homework as completed: ${e.toString()}',
        );
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCourseId = null;
      _selectedStartDate = null;
      _selectedEndDate = null;
      _currentPage = 1;
    });
    _fetchHomework();
  }

  void _applyFilters() {
    setState(() {
      _currentPage = 1;
    });
    _fetchHomework();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              // Search bar
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search homework...',
                      prefixIcon: const Icon(Symbols.search_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(Symbols.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _fetchHomework();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      // Implement search functionality if needed
                    },
                  ),
                ),
              ),
              IconButton(
                  icon: Icon(
                    Symbols.settings_rounded,
                    fill: _showOptions ? 1 : 0,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _showOptions = !_showOptions;
                    });
                  },
                  tooltip: 'Toggle Options',
                ),
              const SizedBox(width: 4),
              IconButton(
                  icon: const Icon(Symbols.refresh_rounded, size: 24),
                  onPressed: _fetchHomework,
                tooltip: 'Refresh',
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Options panel
          if (_showOptions) _buildOptionsPanel(),
          if (_showOptions) const SizedBox(height: 16),

          // Homework list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _homeworkResponse == null
                ? const Center(child: Text('No homework data'))
                : _buildHomeworkList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Options',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Academic Year
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedAcademicYear,
                  decoration: const InputDecoration(
                    labelText: 'Academic Year',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - 2 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year-${year + 1}'),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAcademicYear = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date Range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedStartDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedStartDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Symbols.calendar_today_rounded),
                        const SizedBox(width: 8),
                        Text(
                          _selectedStartDate != null
                              ? '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'
                              : 'Start Date',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedEndDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedEndDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Symbols.calendar_today_rounded),
                        const SizedBox(width: 8),
                        Text(
                          _selectedEndDate != null
                              ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                              : 'End Date',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Symbols.clear_rounded),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Symbols.filter_list_rounded),
                label: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkList() {
    if (_homeworkResponse!.homeworkItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.assignment_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No homework found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try adjusting your filters or check back later',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Homework items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _homeworkResponse!.homeworkItems.length,
            itemBuilder: (context, index) {
              final homework = _homeworkResponse!.homeworkItems[index];
              return _buildHomeworkCard(homework);
            },
          ),
        ),

        // Pagination
        if (_homeworkResponse!.totalPages > 1) _buildPagination(),
      ],
    );
  }

  Widget _buildHomeworkCard(HomeworkItem homework) {
    final isOverdue = homework.isOverdue;
    final daysUntilDue = homework.daysUntilDue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.courseCode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: homework.isCompleted
                        ? Colors.green
                        : isOverdue
                        ? Colors.red
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    homework.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                if (!homework.isCompleted)
                OutlinedButton(
                  onPressed: () => _markAsCompleted(homework.id),
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.all(2),
                    overlayColor: Colors.green.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Symbols.check_rounded, size: 16, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              homework.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // 2-column grid for info texts
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Symbols.school_rounded, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              homework.courseCode,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Symbols.category_rounded, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              homework.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Symbols.calendar_today_rounded, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Due: ${homework.dueDate.year}/${homework.dueDate.month}/${homework.dueDate.day}',
                              style: TextStyle(
                                color: isOverdue ? Colors.red : Colors.grey[600],
                                fontSize: 12,
                                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                              ),
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
                          Icon(Symbols.person_rounded, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              homework.teacher,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isOverdue ? Symbols.warning_rounded : Symbols.info_rounded,
                            size: 16,
                            color: isOverdue ? Colors.red : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isOverdue
                                  ? 'Overdue ${daysUntilDue.abs()} days'
                                  : daysUntilDue > 0
                                  ? 'Due in $daysUntilDue days'
                                  : 'Due today',
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue ? Colors.red : Colors.blue,
                                fontWeight: isOverdue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Symbols.schedule_rounded, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Assigned: ${homework.assignedDate.year}/${homework.assignedDate.month}/${homework.assignedDate.day}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _fetchHomework();
                  }
                : null,
            icon: const Icon(Symbols.chevron_left_rounded),
          ),

          Text(
            'Page $_currentPage of ${_homeworkResponse!.totalPages}, ${_homeworkResponse!.totalRecords} total items',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          IconButton(
            onPressed: _currentPage < _homeworkResponse!.totalPages
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _fetchHomework();
                  }
                : null,
            icon: const Icon(Symbols.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
