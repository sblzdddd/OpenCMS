import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../data/models/notification/daily_bulletin_response.dart' as cms;
import '../../services/theme/theme_services.dart';
import '../../services/notification/daily_bulletin_service.dart';
import '../shared/scaled_ink_well.dart';
import '../shared/views/adaptive_list_detail_layout.dart';
import '../web_cms/web_cms_content.dart';
import '../../pages/actions/web_cms.dart';

class AdaptiveDailyBulletinLayout extends StatelessWidget {
  final List<cms.DailyBulletin> dailyBulletins;
  final Function(cms.DailyBulletin) onDailyBulletinSelected;
  final cms.DailyBulletin? selectedDailyBulletin;
  final double breakpoint;

  const AdaptiveDailyBulletinLayout({
    super.key,
    required this.dailyBulletins,
    required this.onDailyBulletinSelected,
    this.selectedDailyBulletin,
    this.breakpoint = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveListDetailLayout<cms.DailyBulletin>(
      items: dailyBulletins,
      selectedItem: selectedDailyBulletin,
      onItemSelected: onDailyBulletinSelected,
      breakpoint: breakpoint,
      itemBuilder: (dailyBulletin, isSelected) => _buildDailyBulletinItem(dailyBulletin, isSelected, context),
      detailBuilder: (dailyBulletin) => _buildDailyBulletinDetail(dailyBulletin, context),
    );
  }

  Future<void> _navigateToDailyBulletinDetail(cms.DailyBulletin dailyBulletin, BuildContext context) async {
    final contentUrl = await DailyBulletinService().getDailyBulletinContentUrl(dailyBulletin.id);
    if (context.mounted) {
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
  }

  Widget _buildDailyBulletinItem(cms.DailyBulletin dailyBulletin, bool isSelected, BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    
    return Material(
      color: Colors.transparent,
      child: ScaledInkWell(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        background: (inkWell) => Material(
          color: isSelected
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : themeNotifier.needTransparentBG && !themeNotifier.isDarkMode
              ? Theme.of(context).colorScheme.surfaceBright.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.8),
          borderRadius: themeNotifier.getBorderRadiusAll(1),
          child: inkWell,
        ),
        onTap: () {
          onDailyBulletinSelected(dailyBulletin);
          // In mobile mode, navigate to detail page
          if (MediaQuery.of(context).size.width < breakpoint) {
            _navigateToDailyBulletinDetail(dailyBulletin, context);
          }
        },
        borderRadius: themeNotifier.getBorderRadiusAll(1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: themeNotifier.getBorderRadiusAll(1),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
              width: 1,
            ),
          ),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            title: Text(
              dailyBulletin.title,
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
            trailing: const Icon(Symbols.arrow_forward_ios_rounded, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyBulletinDetail(cms.DailyBulletin dailyBulletin, BuildContext context) {
    return FutureBuilder<String>(
      future: DailyBulletinService().getDailyBulletinContentUrl(dailyBulletin.id),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load daily bulletin content',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
          key: ValueKey(dailyBulletin.id),
          initialUrl: snapshot.data,
          windowTitle: dailyBulletin.title,
          isWideScreen: true,
        );
      },
    );
  }

}
