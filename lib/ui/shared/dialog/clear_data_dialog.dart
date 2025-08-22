import 'package:flutter/material.dart';
import '../../../services/shared/storage_client.dart';
import '../../../services/auth/auth_service.dart';
import '../navigations/app_navigation_controller.dart';

void showClearDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text(
          'Clear User Data',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: const Text('Are you sure you want to clear all user data?\nThis action cannot be undone and will delete ALL your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await AuthService().logout();
              StorageClient.instance.deleteAll();
              if (context.mounted) {
                // Ensure global navigation state is cleared and remove all routes
                AppNavigationController.reset();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      );
    },
  );
}
