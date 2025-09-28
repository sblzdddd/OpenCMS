import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// A custom SingleChildScrollView that sets BouncingScrollPhysics by default
class CustomChildScrollView extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final HitTestBehavior hitTestBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Axis scrollDirection;
  final bool primary;

  const CustomChildScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.primary = false,
    this.controller,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      controller: controller,
      padding: padding,
      reverse: reverse,
      physics: const BouncingScrollPhysics(),
      primary: primary,
      dragStartBehavior: dragStartBehavior,
      clipBehavior: clipBehavior,
      restorationId: restorationId,
      keyboardDismissBehavior: keyboardDismissBehavior,
      hitTestBehavior: hitTestBehavior,
      child: child,
    );
  }
}
