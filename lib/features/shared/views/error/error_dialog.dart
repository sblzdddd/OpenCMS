import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import 'package:opencms/features/shared/views/widgets/custom_scroll_view.dart';
import 'package:opencms/features/shared/views/custom_snackbar/snackbar_utils.dart';

/// Reusable error dialog component with text copy functionality
class ErrorDialog extends StatelessWidget {
  /// Title of the dialog
  final String title;

  /// Error message to display
  final String message;

  /// Optional additional data to include in details
  final Map<String, dynamic>? additionalData;

  /// Whether to show the copy button
  final bool showCopyButton;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.additionalData,
    this.showCopyButton = true,
  });

  /// Show the error dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    Map<String, dynamic>? additionalData,
    bool showCopyButton = true,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ErrorDialog(
        title: title,
        message: message,
        additionalData: additionalData,
        showCopyButton: showCopyButton,
      ),
    );
  }

  /// Build formatted details string for display and copying
  String _buildDetails() {
    try {
      final data = <String, dynamic>{
        'message': message,
        if (additionalData != null) ...additionalData!,
      };
      return JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return 'message: $message';
    }
  }

  /// Copy details to clipboard and show confirmation
  void _copyDetails(BuildContext context, String details) {
    Clipboard.setData(ClipboardData(text: details));
    Navigator.of(context).pop();
    SnackbarUtils.showSuccess(context, 'Error details copied');
  }

  @override
  Widget build(BuildContext context) {
    final details = _buildDetails();
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: themeNotifier.getBorderRadiusAll(1.5),
      ),
      clipBehavior: Clip.antiAlias,
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: CustomChildScrollView(child: SelectableText(details)),
      ),
      actions: [
        if (showCopyButton)
          TextButton(
            onPressed: () => _copyDetails(context, details),
            child: const Text('Copy details'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
