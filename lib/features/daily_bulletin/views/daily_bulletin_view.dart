import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/services/theme_services.dart';
import '../models/daily_bulletin_response.dart' as cms;
import '../services/daily_bulletin_service.dart';
import '../../shared/views/views/refreshable_view.dart';
import 'adaptive_daily_bulletin_layout.dart';

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
    final dailyBulletins = await _dailyBulletinService.getDailyBulletinsList(
      date: date,
      refresh: refresh,
    );
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
  String get emptyTitle => 'No daily bulletins available';

  @override
  String get errorTitle => 'Error loading daily bulletins';

  @override
  bool get isEmpty => _dailyBulletins == null || _dailyBulletins!.isEmpty;
}
