import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import 'navigations/app_navigation_controller.dart';


void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No No No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await AuthService().logout();
              if (context.mounted) {
                // Ensure global navigation state is cleared and remove all routes
                AppNavigationController.reset();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes Yes Yes'),
          ),
        ],
      );
    },
  );
}