import 'package:flutter/material.dart';

/// A global replacement for [InkWell] that shrinks on press.
/// Drop-in compatible with InkWell.
class ScaledInkWell extends StatefulWidget {
  const ScaledInkWell({
    super.key,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onTapDown,
    this.onTapCancel,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.autofocus = false,
    this.mouseCursor,
    this.child,
    this.background,
    this.scaleDownFactor = 0.93,
    this.duration = const Duration(milliseconds: 100),
    this.margin,
  });

  final Widget? child;
  final Widget Function(Widget inkWell)? background;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onDoubleTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapCancelCallback? onTapCancel;

  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final Color? splashColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final double? radius;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;

  final bool enableFeedback;
  final bool excludeFromSemantics;

  final FocusNode? focusNode;
  final bool canRequestFocus;
  final bool autofocus;
  final MouseCursor? mouseCursor;

  /// Scale factor applied while pressed
  final double scaleDownFactor;

  /// Duration of the scale animation
  final Duration duration;

  /// The margin around the widget, similar to Card's margin
  final EdgeInsetsGeometry? margin;

  @override
  State<ScaledInkWell> createState() => _ScaledInkWellState();
}

class _ScaledInkWellState extends State<ScaledInkWell> {
  bool _pressed = false;

  void _handleHighlightChanged(bool value) {
    setState(() => _pressed = value);
  }

  Widget _buildInkWell() {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onTapDown: widget.onTapDown,
      onTapCancel: widget.onTapCancel,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      highlightColor: widget.highlightColor,
      overlayColor: widget.overlayColor,
      splashColor: widget.splashColor,
      splashFactory: widget.splashFactory,
      radius: widget.radius,
      borderRadius: widget.borderRadius,
      customBorder: widget.customBorder,
      enableFeedback: widget.enableFeedback,
      excludeFromSemantics: widget.excludeFromSemantics,
      focusNode: widget.focusNode,
      canRequestFocus: widget.canRequestFocus,
      autofocus: widget.autofocus,
      mouseCursor: widget.mouseCursor,
      onHighlightChanged: _handleHighlightChanged,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inkWell = AnimatedScale(
      scale: _pressed ? widget.scaleDownFactor : 1.0,
      duration: widget.duration,
      curve: Curves.easeOutQuad,
      child: widget.background != null
          ? widget.background!(_buildInkWell())
          : _buildInkWell(),
    );

    return widget.margin != null
        ? Padding(padding: widget.margin!, child: inkWell)
        : inkWell;
  }
}
