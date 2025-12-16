import 'package:syncfusion_flutter_core/theme.dart';
import '../features/theme/services/theme_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

SfCalendarThemeData themeData(BuildContext context) {
  final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
  return SfCalendarThemeData(
    backgroundColor: themeNotifier.needTransparentBG
        ? Colors.transparent
        : Theme.of(context).colorScheme.surface,
    headerBackgroundColor: Theme.of(context).colorScheme.surfaceContainer
        .withValues(alpha: themeNotifier.needTransparentBG ? 0.5 : 1),
    headerTextStyle: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    todayHighlightColor: Theme.of(context).colorScheme.primary,
    viewHeaderBackgroundColor: Theme.of(context).colorScheme.surfaceContainer
        .withValues(alpha: themeNotifier.needTransparentBG ? 0.5 : 1),
  );
}
