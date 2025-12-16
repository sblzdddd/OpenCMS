import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/theme_services.dart';
import '../../../models/skin.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Card widget for displaying skin information
class SkinCard extends StatelessWidget {
  final Skin skin;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SkinCard({
    super.key,
    required this.skin,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return Card(
      elevation: 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : themeNotifier.needTransparentBG
          ? (!themeNotifier.isDarkMode
                ? Theme.of(
                    context,
                  ).colorScheme.surfaceBright.withValues(alpha: 0.6)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
          : Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      skin.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (skin.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (skin.isDefault)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Default',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                skin.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Updated: ${_formatDate(skin.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Row(
                    children: [
                      if (!skin.isDefault && onEdit != null)
                        ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Symbols.edit_rounded, size: 16),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      if (onDelete != null && !skin.isDefault) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Symbols.delete_rounded, size: 16),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
