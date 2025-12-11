import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/auth/services/token_refresh_service.dart';
import 'package:opencms/features/core/di/locator.dart';
import 'package:opencms/ui/shared/widgets/custom_scroll_view.dart';
import 'package:opencms/ui/shared/widgets/skin_icon_widget.dart';

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key, this.title, required this.onRetry});
  final String? title;
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
                imageKey: 'global.empty_icon',
                fallbackIcon: Symbols.playlist_remove_rounded,
                size: 96,
                iconSize: 75,
                fallbackIconColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fallbackIconBackgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 8),
              Text(
                title ?? 'No data available',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              ElevatedButton(onPressed: _onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
