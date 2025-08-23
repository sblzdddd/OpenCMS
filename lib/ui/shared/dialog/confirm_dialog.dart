import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/shared/storage_client.dart';
import '../navigations/app_navigation_controller.dart';

void showConfirmationDialog(BuildContext context, String title, String message, Future<void> Function(BuildContext) onConfirm) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
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
  showConfirmationDialog(context, 'Logout', 'Are you sure you want to logout?', (dialogContext) async {
    Navigator.of(dialogContext).pop();
    await AuthService().logout();
    if (context.mounted) {
      // Ensure global navigation state is cleared and remove all routes
      AppNavigationController.reset();
      
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  });
}

void showClearDataDialog(BuildContext context) {
  showConfirmationDialog(context, 'Clear Data', 'Are you sure you want to clear all user data?\nThis action cannot be undone and will delete ALL your data.', (dialogContext) async {
    Navigator.of(dialogContext).pop();
    await AuthService().logout();
    StorageClient.instance.deleteAll();
    if (context.mounted) {
      // Ensure global navigation state is cleared and remove all routes
      AppNavigationController.reset();
      
      // Ensure window close prevention is maintained after logout
      if (defaultTargetPlatform == TargetPlatform.windows) {
        await windowManager.setPreventClose(true);
      }
      if(!context.mounted) {
        print('ClearDataDialog: Context is not mounted');
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  });
}
