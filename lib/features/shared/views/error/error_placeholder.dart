import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/di/locator.dart';
import '../dialog/confirm_dialog.dart';
import 'package:opencms/features/shared/views/widgets/custom_scroll_view.dart';
import 'package:opencms/features/theme/views/widgets/skin_icon_widget.dart';

class ErrorPlaceholder extends StatelessWidget {
  const ErrorPlaceholder({
    super.key,
    required this.title,
    required this.errorMessage,
    required this.onRetry,
  });
  final String title;
  final String errorMessage;
  final VoidCallback onRetry;

  Future<void> _onRetry() async {
    await di<TokenRefreshService>().refreshNewToken();
    onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SkinIcon(
                imageKey: 'global.error_icon',
                fallbackIcon: Symbols.error_outline,
                size: 96,
                iconSize: 96,
                fallbackIconColor: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),

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
