import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/theme.dart';

SfCalendarThemeData themeData(BuildContext context) {
  return SfCalendarThemeData(
    backgroundColor: Theme.of(context).colorScheme.surface,
    headerBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    headerTextStyle: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    todayHighlightColor: Theme.of(context).colorScheme.primary,
    viewHeaderBackgroundColor: Theme.of(context).colorScheme.surfaceContainer,
  );
}
