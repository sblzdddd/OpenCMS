import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/theme/theme_services.dart';
import '../../data/models/notification/daily_bulletin_response.dart' as cms;
import '../../services/notification/daily_bulletin_service.dart';
import '../shared/views/refreshable_view.dart';
import 'adaptive_daily_bulletin_layout.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DailyBulletinView extends StatefulWidget {
  const DailyBulletinView({super.key});

  @override
  State<DailyBulletinView> createState() => _DailyBulletinViewState();
}

class _DailyBulletinViewState extends RefreshableView<DailyBulletinView> {
  final DailyBulletinService _dailyBulletinService = DailyBulletinService();
  List<cms.DailyBulletin>? _dailyBulletins;
  cms.DailyBulletin? _selectedDailyBulletin;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dailyBulletins = await _dailyBulletinService.getDailyBulletinsList(date: date, refresh: refresh);
    setState(() {
      _dailyBulletins = dailyBulletins;
    });
  }


  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_dailyBulletins == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AdaptiveDailyBulletinLayout(
      dailyBulletins: _dailyBulletins!,
      selectedDailyBulletin: _selectedDailyBulletin,
      onDailyBulletinSelected: (dailyBulletin) {
        setState(() {
          _selectedDailyBulletin = dailyBulletin;
        });
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
                Symbols.notifications_none_rounded,
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
