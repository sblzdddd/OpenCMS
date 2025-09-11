/// Profile information card widget
library;

import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? valueColor;
  final bool isClickable;
  final bool isCompact;
  final VoidCallback? onTap;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.valueColor,
    this.isClickable = false,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: isCompact ? 32 : 40,
                height: isCompact ? 32 : 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: isCompact ? 16 : 20,
                ),
              ),
              
              SizedBox(width: isCompact ? 12 : 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: (isCompact 
                          ? Theme.of(context).textTheme.bodySmall 
                          : Theme.of(context).textTheme.bodySmall)?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: isCompact ? 11 : null,
                      ),
                    ),
                    SizedBox(height: isCompact ? 2 : 4),
                    Text(
                      value,
                      style: (isCompact 
                          ? Theme.of(context).textTheme.bodyMedium 
                          : Theme.of(context).textTheme.bodyLarge)?.copyWith(
                        color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 13 : null,
                      ),
                      maxLines: isCompact ? 1 : null,
                      overflow: isCompact ? TextOverflow.ellipsis : null,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: isCompact ? 1 : 2),
                      Text(
                        subtitle!,
                        style: (isCompact 
                            ? Theme.of(context).textTheme.bodySmall 
                            : Theme.of(context).textTheme.bodySmall)?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: isCompact ? 10 : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Clickable indicator
              if (isClickable) ...[
                SizedBox(width: isCompact ? 4 : 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  size: isCompact ? 16 : 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
