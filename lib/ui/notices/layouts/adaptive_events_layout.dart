import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opencms/features/auth/login_state.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:provider/provider.dart';
import '../../../data/models/events/student_event.dart';
import '../../../services/theme/theme_services.dart';
import '../../shared/selectable_item_wrapper.dart';
import '../../web_cms/web_cms_content.dart';
import '../../shared/views/list_section.dart';
import '../../../pages/actions/web_cms.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';

class AdaptiveEventsLayout extends StatelessWidget {
  final List<StudentEvent> studentLedEvents;
  final List<StudentEvent> studentUnstaffedEvents;
  final Function(StudentEvent) onEventSelected;
  final StudentEvent? selectedEvent;
  final double breakpoint;

  const AdaptiveEventsLayout({
    super.key,
    required this.studentLedEvents,
    required this.studentUnstaffedEvents,
    required this.onEventSelected,
    this.selectedEvent,
    this.breakpoint = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= breakpoint;

    if (isWideScreen) {
      return _buildWideScreenLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildWideScreenLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - List with sections
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [Expanded(child: _buildEventsList(context))],
            ),
          ),
        ),
        // Right side - Details
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: selectedEvent != null
                ? _buildEventDetail(selectedEvent!, context)
                : _buildEmptySelectionView(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(children: [Expanded(child: _buildEventsList(context))]);
  }

  Widget _buildEventsList(BuildContext context) {
    return CustomChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student-Led Events section
          if (studentLedEvents.isNotEmpty)
            ListSection(
              title: 'Student-Led Events',
              icon: Symbols.person_rounded,
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              children: studentLedEvents
                  .map((event) => _buildEventItem(event, context))
                  .toList(),
            ),

          // Student-Unstaffed Events section
          if (studentUnstaffedEvents.isNotEmpty)
            ListSection(
              title: 'Student-Unstaffed Events',
              icon: Symbols.person_rounded,
              padding: const EdgeInsets.only(left: 16, bottom: 12, top: 12),
              children: studentUnstaffedEvents
                  .map((event) => _buildEventItem(event, context))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEventItem(StudentEvent event, BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final isSelected = selectedEvent == event;

    return SelectableItemWrapper(
      isSelected: isSelected,
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      onTap: () {
        onEventSelected(event);
        if (MediaQuery.of(context).size.width < breakpoint || kIsWeb) {
          _navigateToEventDetail(event, context);
        }
      },
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.dateTime,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: event.type == StudentEventType.led
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    borderRadius: themeNotifier.getBorderRadiusAll(999),
                  ),
                  child: Text(
                    event.applicant,
                    style: TextStyle(
                      fontSize: 12,
                      color: event.type == StudentEventType.led
                          ? Colors.blue
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Symbols.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  Widget _buildEventDetail(StudentEvent event, BuildContext context) {
    return FutureBuilder<String>(
      future: _getEventDetailUrl(event),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error_outline_rounded,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load event content',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if the widget is still mounted before building WebCmsContent
        if (!context.mounted) {
          return const SizedBox.shrink();
        }

        return WebCmsContent(
          key: ValueKey(event.id),
          initialUrl: snapshot.data,
          windowTitle: event.title,
          isWideScreen: true,
        );
      },
    );
  }

  Future<String> _getEventDetailUrl(StudentEvent event) async {
    final username = di<LoginState>().currentUsername;
    if (username.isEmpty) {
      throw Exception('Missing username. Please login again.');
    }

    if (event.type == StudentEventType.led) {
      return 'https://www.a'
          'l'
          'eve'
          'l.co'
          'm.cn/user/$username/sl_event/view/${event.id}/';
    } else {
      return 'https://www.a'
          'l'
          'eve'
          'l.co'
          'm.cn/user/$username/su_event/view/${event.id}/';
    }
  }

  Future<void> _navigateToEventDetail(
    StudentEvent event,
    BuildContext context,
  ) async {
    final detailUrl = await _getEventDetailUrl(event);
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WebCmsPage(initialUrl: detailUrl, windowTitle: event.title),
        ),
      );
    }
  }

  Widget _buildEmptySelectionView(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Symbols.touch_app_rounded,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Select an event',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an event from the list to view details',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
