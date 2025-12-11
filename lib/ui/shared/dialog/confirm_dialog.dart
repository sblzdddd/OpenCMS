import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../services/theme/theme_services.dart';
import '../../navigations/app_navigation_controller.dart';

void showConfirmationDialog(
  BuildContext context,
  String title,
  String message,
  Future<void> Function(BuildContext) onConfirm,
) {
  final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: themeNotifier.getBorderRadiusAll(1.5),
        ),
        clipBehavior: Clip.antiAlias,
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No No No'),
          ),
          ElevatedButton(
            onPressed: () => onConfirm(dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes Yes Yes'),
          ),
        ],
      );
    },
  );
}

void showLogoutDialog(BuildContext context) {
  showConfirmationDialog(
    context,
    'Logout',
    'Are you sure you want to logout?',
    (dialogContext) async {
      Navigator.of(dialogContext).pop();
      await di<AuthService>().logout();
      if (context.mounted) {
        // Ensure global navigation state is cleared and remove all routes
        AppNavigationController.reset();

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    },
  );
}

void showClearDataDialog(BuildContext context) {
  showConfirmationDialog(
    context,
    'Clear Data',
    'Are you sure you want to clear all user data?\nThis action cannot be undone and will delete ALL your data.',
    (dialogContext) async {
      Navigator.of(dialogContext).pop();
      await di<AuthService>().logout();
      if (context.mounted) {
        // Ensure global navigation state is cleared and remove all routes
        AppNavigationController.reset();

        // Ensure window close prevention is maintained after logout
        if (defaultTargetPlatform == TargetPlatform.windows) {
          await windowManager.setPreventClose(true);
        }
        if (!context.mounted) {
          debugPrint('ClearDataDialog: Context is not mounted');
          return;
        }
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    },
  );
}
