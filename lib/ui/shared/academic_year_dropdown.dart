import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../data/constants/periods.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';

/// Reusable academic year dropdown component with consistent styling
class AcademicYearDropdown extends StatelessWidget {
  /// Currently selected academic year
  final AcademicYear? selectedYear;
  
  /// Callback when year selection changes
  final ValueChanged<AcademicYear?>? onChanged;
  
  /// Whether the dropdown is enabled
  final bool enabled;
  
  /// Custom padding for the dropdown
  final EdgeInsetsGeometry? padding;
  
  /// Custom elevation for the dropdown
  final int elevation;
  
  /// Custom border radius for the dropdown
  final BorderRadius? borderRadius;
  
  /// Whether to show the underline
  final bool showUnderline;
  
  /// Custom icon for the dropdown
  final Widget? icon;
  
  /// Whether to show a label above the dropdown
  final String? label;
  
  /// Whether the dropdown should be expanded to fill available width
  final bool isExpanded;

  const AcademicYearDropdown({
    super.key,
    this.selectedYear,
    this.onChanged,
    this.enabled = true,
    this.padding,
    this.elevation = 1,
    this.borderRadius,
    this.showUnderline = false,
    this.icon,
    this.label,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    final defaultPadding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    );
    
    final defaultBorderRadius = themeNotifier.getBorderRadiusAll(0.75);
    
    final defaultIcon = const Icon(Symbols.arrow_drop_down_rounded);

    Widget dropdown = DropdownButton<AcademicYear>(
      padding: padding ?? defaultPadding,
      elevation: elevation,
      borderRadius: borderRadius ?? defaultBorderRadius,
      value: selectedYear,
      onChanged: enabled ? onChanged : null,
      isExpanded: isExpanded,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      items: PeriodConstants.getAcademicYears()
          .map(
            (year) => DropdownMenuItem(
              value: year,
              child: Text(year.displayName),
            ),
          )
          .toList(),
      underline: showUnderline ? null : Container(),
      icon: icon ?? defaultIcon,
    );

    // Wrap with label if provided
    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          dropdown,
        ],
      );
    }

    return dropdown;
  }
}
