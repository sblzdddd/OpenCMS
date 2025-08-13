import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Custom snackbar widget with slide down/up animation and right top positioning
class CustomSnackbar extends StatefulWidget {
  final int id;
  final String title;
  final String? message;
  final Color iconColor;
  final IconData icon;
  final double elevation;
  final Future<void> Function() onDismiss;
  final int Function() getPosition;
  final void Function(CustomSnackbarState)? onStateCreated;
  
  const CustomSnackbar({
    super.key,
    required this.id,
    required this.title,
    this.message,
    required this.iconColor,
    required this.icon,
    required this.elevation,
    required this.onDismiss,
    required this.getPosition,
    this.onStateCreated,
  });

  @override
  State<CustomSnackbar> createState() => CustomSnackbarState();
}

class CustomSnackbarState extends State<CustomSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  static const double _snackbarHeight = 60.0; // Approximate height including spacing
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuint,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // Notify parent about state creation
    widget.onStateCreated?.call(this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Public method to trigger dismiss animation
  Future<void> dismiss() async {
    await _dismiss();
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return; // Prevent multiple dismissals
    _isDismissing = true;
    
    // Animate slide up and fade out
    await _animationController.reverse();
    
    // Only call onDismiss after animation completes
    if (mounted) {
      await widget.onDismiss();
    }
  }

  // Calculate current position based on callback function
  double _calculateTopPosition(BuildContext context) {
    return MediaQuery.of(context).padding.top + 20 + (widget.getPosition() * _snackbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _calculateTopPosition(context),
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Material(
                elevation: widget.elevation,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                    minWidth: 200,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add spacing between snackbars
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.message != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.message!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Symbols.close_rounded,
                              color: Colors.grey[400],
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
