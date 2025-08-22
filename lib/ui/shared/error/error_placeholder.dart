import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/services/auth/auth_service.dart';
import '../dialog/logout_dialog.dart';

class ErrorPlaceholder extends StatelessWidget {
  ErrorPlaceholder({
    super.key,
    required this.title,
    required this.errorMessage,
    required this.onRetry,
  });
  final String title;
  final String errorMessage;
  final VoidCallback onRetry;
  final AuthService authService = AuthService();

  Future<void> _onRetry() async {
    await authService.refreshCookies();
    onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showLogoutDialog(context);
                    },
                    child: const Text('Logout'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _onRetry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
