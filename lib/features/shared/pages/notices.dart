import 'package:flutter/material.dart';
import '../views/views/tabbed_page_base.dart';
import '../../notices/views/notifications_view.dart';
import '../../daily_bulletin/views/daily_bulletin_view.dart';
import '../../events/views/events_view.dart';

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      title: 'Notices',
      skinKey: ['notice', 'daily_bulletin', 'events'],
      initialTabIndex: initialTabIndex,
      tabs: const [
        Tab(text: 'Notifications'),
        Tab(text: 'Daily Bulletin'),
        Tab(text: 'Events'),
      ],
      tabViews: [
        const NotificationsView(),
        const DailyBulletinView(),
        const EventsView(),
      ],
    );
  }
}
