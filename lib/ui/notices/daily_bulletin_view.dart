import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/theme/theme_services.dart';
import '../../data/models/notification/daily_bulletin_response.dart' as cms;
import '../../services/notification/daily_bulletin_service.dart';
import '../shared/views/refreshable_view.dart';
import '../../pages/actions/web_cms.dart';

class DailyBulletinView extends StatefulWidget {
  const DailyBulletinView({super.key});

  @override
  State<DailyBulletinView> createState() => _DailyBulletinViewState();
}

class _DailyBulletinViewState extends RefreshableView<DailyBulletinView> {
  final DailyBulletinService _dailyBulletinService = DailyBulletinService();
  List<cms.DailyBulletin>? _dailyBulletins;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dailyBulletins = await _dailyBulletinService.getDailyBulletinsList(date: date, refresh: refresh);
    setState(() {
      _dailyBulletins = dailyBulletins;
    });
  }

  Future<void> _navigateToDailyBulletinDetail(cms.DailyBulletin dailyBulletin) async {
    final contentUrl = await _dailyBulletinService.getDailyBulletinContentUrl(dailyBulletin.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebCmsPage(
          initialUrl: contentUrl,
          windowTitle: dailyBulletin.title,
        ),
      ),
    );
  }

  Widget _buildDailyBulletinItem(cms.DailyBulletin dailyBulletin) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          dailyBulletin.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: themeNotifier.getBorderRadiusAll(999),
                  ),
                  child: Text(
                    dailyBulletin.department,
                    style: TextStyle(
                      fontSize: 12, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToDailyBulletinDetail(dailyBulletin),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_dailyBulletins == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: _dailyBulletins!.length,
      itemBuilder: (context, index) {
        return _buildDailyBulletinItem(_dailyBulletins![index]);
      },
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No daily bulletins available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for new daily bulletins',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get errorTitle => 'Error loading daily bulletins';

  @override
  bool get isEmpty => _dailyBulletins == null || _dailyBulletins!.isEmpty;
}
