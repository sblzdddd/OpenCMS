import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/data/constants/period_constants.dart';
import 'package:opencms/ui/shared/academic_year_dropdown.dart';
import 'package:opencms/ui/shared/views/refreshable_page.dart';
import '../../data/models/homework/homework_response.dart';
import '../../services/homework/homework_service.dart';
import '../../services/homework/completed_homework_service.dart';
import '../../ui/homework/homework_card.dart';

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends RefreshablePage<HomeworkPage> {
  HomeworkResponse? _homeworkResponse;
  late AcademicYear _selectedYear;
  bool _showSettings = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expandedCardIds = <int>{};
  List<HomeworkItem> _filteredHomeworkItems = [];
  bool _showCompleted = false;
  Set<String> _completedKeys = {};

  @override
  void initState() {
    _selectedYear = PeriodConstants.getAcademicYears().first;
    super.initState();
    _loadCompleted();
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
    });
    _refreshFilteredList();
  }

  @override
  String get appBarTitle => 'Homework';

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

  Future<void> _loadCompleted() async {
    final completed = await CompletedHomeworkService.getCompletedHomeworks();
    setState(() {
      _completedKeys = completed
          .map((e) => '${e.courseName}|||${e.title}')
          .toSet();
    });
    _refreshFilteredList();
  }

  String _keyFor(HomeworkItem hw) => '${hw.courseName}|||${hw.title}';

  void _refreshFilteredList() {
    if (_homeworkResponse == null) return;

    final query = _searchController.text.toLowerCase();
    List<HomeworkItem> list = _homeworkResponse!.homeworkItems.where((homework) {
      final matchesQuery = query.isEmpty
          ? true
          : (homework.courseName.toLowerCase().contains(query) ||
             homework.title.toLowerCase().contains(query) ||
             homework.teacherName.toLowerCase().contains(query) ||
             homework.categoryText.toLowerCase().contains(query));
      if (!matchesQuery) return false;

      if (_showCompleted) return true;
      return !_completedKeys.contains(_keyFor(homework));
    }).toList();

    setState(() {
      _filteredHomeworkItems = list;
    });
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildHomeworkList()),
        ],
      ),
    );
  }

  @override
  Widget buildPageContent(BuildContext context) {
    // This method is not used since we override buildContent
    return const SizedBox.shrink();
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilterChip(
              label: const Text('completed'),
              selected: _showCompleted,
              onSelected: (val) {
                setState(() {
                  _showCompleted = val;
                });
                _loadCompleted();
              },
            ),
            const SizedBox(width: 12),
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
    _refreshFilteredList();
  }

  Widget _buildHomeworkList() {
    return ListView.builder(
      itemCount: _filteredHomeworkItems.length,
      itemBuilder: (context, index) {
        final homework = _filteredHomeworkItems[index];
        return HomeworkCard(
          key: ValueKey('${homework.courseName}|||${homework.title}'),
          homework: homework,
          index: index,
          isExpanded: _expandedCardIds.contains(index),
          onTap: () => _toggleCardExpansion(index),
          selectedYearDisplayName: _selectedYear.displayName,
          onCompletionStatusChanged: _loadCompleted,
        );
      },
    );
  }


  
  @override
  Widget buildEmptyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Symbols.assignment_rounded, size: 64),
                  const SizedBox(height: 16),
                  Text('No homework found', style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    'Try adjusting your filters or check back later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
