import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/services/auth/auth_service.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/widgets/skin_icon_widget.dart';

class EmptyPlaceholder extends StatelessWidget {
  EmptyPlaceholder({
    super.key,
    this.title,
    required this.onRetry,
  });
  final String? title;
  final VoidCallback onRetry;
  final AuthService authService = AuthService();

  Future<void> _onRetry() async {
    await authService.refreshCookies();
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
                imageKey: 'global.empty_icon',
                fallbackIcon: Symbols.playlist_remove_rounded,
                size: 96,
                iconSize: 75,
                fallbackIconColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fallbackIconBackgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 8),
              Text(title ?? 'No data available', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
