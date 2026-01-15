import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:opencms/di/locator.dart';
import 'package:opencms/features/auth/services/credentials_storage_service.dart';
import 'package:provider/provider.dart';
import '../../../auth/services/auth_service.dart';
import '../../../theme/services/theme_services.dart';

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
    'Are you sure you want to logout?\n(Restart required)',
    (dialogContext) async {
      Navigator.of(dialogContext).pop();
      // Disable auto-login on explicit logout
      await di<CredentialsStorageService>().setAutoLogin(false);

      // no longer needed due to the implementation of account separation
      // await di<WeightedAverageService>().clearAll();
      
      await di<AuthService>().logout();
      if (context.mounted) {
        Phoenix.rebirth(context);
      } else {
        
      }
    },
  );
}

