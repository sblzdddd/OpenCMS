import 'package:flutter/material.dart';
import 'custom_snackbar.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Information about an active snackbar
class SnackbarInfo {
  final int id;
  final OverlayEntry overlayEntry;
  CustomSnackbarState? snackbarState;

  SnackbarInfo({
    required this.id,
    required this.overlayEntry,
    this.snackbarState,
  });
}

/// Utility class for showing different types of snackbars with consistent styling
class SnackbarUtils {
  // Track active snackbars for positioning
  static final List<SnackbarInfo> _activeSnackbars = [];
  static int _nextId = 0;
  /// Show a general information snackbar (blue theme)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    bool persist = false,
    double elevation = 3,
  }) {
    _showSnackbar(
      context,
      message,
      iconColor: Colors.blue,
      icon: Symbols.info_rounded,
      duration: duration,
      persist: persist,
      elevation: elevation,
    );
  }

  /// Show a success snackbar (green theme)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 1),
    bool persist = false,
    double elevation = 3,
  }) {
    _showSnackbar(
      context,
      message,
      iconColor: Colors.green,
      icon: Symbols.check_circle_rounded,
      duration: duration,
      persist: persist,
      elevation: elevation,
    );
  }

  /// Show a warning snackbar (orange theme)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    bool persist = false,
    double elevation = 3,
  }) {
    _showSnackbar(
      context,
      message,
      iconColor: Colors.orange,
      icon: Symbols.warning_rounded,
      duration: duration,
      persist: persist,
      elevation: elevation,
    );
  }

  /// Show an error snackbar (red theme)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    bool persist = false,
    double elevation = 3,
  }) {
    _showSnackbar(
      context,
      message,
      iconColor: Colors.red,
      icon: Symbols.error_rounded,
      duration: duration,
      persist: persist,
      elevation: elevation,
    );
  }

  /// Internal method to show snackbar with consistent styling
  static void _showSnackbar(
    BuildContext context,
    String title, {
    String? message,
    required Color iconColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    bool persist = false,
    double elevation = 3,
  }) {
    _showCustomSnackbar(
      context: context,
      title: title,
      message: message,
      iconColor: iconColor,
      icon: icon,
      duration: duration,
      persist: persist,
      elevation: elevation,
    );
  }

  /// Custom snackbar implementation with right top corner positioning
  static void _showCustomSnackbar({
    required BuildContext context,
    required String title,
    String? message,
    required Color iconColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    bool persist = false,
    double elevation = 3,
  }) {
    late OverlayEntry overlayEntry;
    final int snackbarId = _nextId++;
    
    late SnackbarInfo snackbarInfo;
    
    overlayEntry = OverlayEntry(
      builder: (context) => CustomSnackbar(
        id: snackbarId,
        title: title,
        message: message,
        iconColor: iconColor,
        icon: icon,
        elevation: elevation,
        getPosition: () => getSnackbarPosition(snackbarId),
        onStateCreated: (state) {
          snackbarInfo.snackbarState = state;
        },
        onDismiss: () async {
          await _removeSnackbar(snackbarId);
        },
      ),
    );

    snackbarInfo = SnackbarInfo(
      id: snackbarId,
      overlayEntry: overlayEntry,
    );

    _activeSnackbars.add(snackbarInfo);
    Overlay.of(context).insert(overlayEntry);

    if (!persist) {
      Future.delayed(duration, () async {
        if (overlayEntry.mounted && snackbarInfo.snackbarState != null) {
          await snackbarInfo.snackbarState!.dismiss();
        }
      });
    }
  }

  /// Remove snackbar and update positions of remaining ones
  static Future<void> _removeSnackbar(int snackbarId) async {
    final index = _activeSnackbars.indexWhere((info) => info.id == snackbarId);
    if (index == -1) return;

    final snackbarInfo = _activeSnackbars[index];
    
    // Remove from active list
    _activeSnackbars.removeAt(index);
    
    // Remove the overlay entry
    if (snackbarInfo.overlayEntry.mounted) {
      snackbarInfo.overlayEntry.remove();
    }

    // Update positions of remaining snackbars
    _updateSnackbarPositions();
  }

  /// Update positions of all active snackbars
  static void _updateSnackbarPositions() {
    for (final snackbarInfo in _activeSnackbars) {
      if (snackbarInfo.overlayEntry.mounted) {
        snackbarInfo.overlayEntry.markNeedsBuild();
      }
    }
  }

  /// Get the current position index for a snackbar
  static int getSnackbarPosition(int snackbarId) {
    final index = _activeSnackbars.indexWhere((info) => info.id == snackbarId);
    return index >= 0 ? index : 0;
  }

  /// Manually dismiss a specific snackbar with animation
  static Future<void> dismissSnackbar(int snackbarId) async {
    final index = _activeSnackbars.indexWhere((info) => info.id == snackbarId);
    if (index == -1) return;

    final snackbarInfo = _activeSnackbars[index];
    if (snackbarInfo.snackbarState != null) {
      await snackbarInfo.snackbarState!.dismiss();
    }
  }

  /// Dismiss all active snackbars with animation
  static Future<void> dismissAllSnackbars() async {
    final snackbars = List<SnackbarInfo>.from(_activeSnackbars);
    for (final snackbarInfo in snackbars) {
      if (snackbarInfo.snackbarState != null) {
        await snackbarInfo.snackbarState!.dismiss();
      }
    }
  }
}
