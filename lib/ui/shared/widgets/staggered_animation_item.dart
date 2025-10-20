import 'package:flutter/material.dart';

/// A reusable widget that provides staggered animation for list items
/// 
/// This widget applies opacity and scale animations with configurable delay
/// and timing to create smooth staggered animations in lists.
class StaggeredAnimationItem extends StatelessWidget {
  /// The animation controller that drives the animation
  final AnimationController animationController;
  
  /// The index of this item in the list (used for delay calculation)
  final int index;
  
  /// The child widget to animate
  final Widget child;
  
  /// Delay multiplier - controls the spacing between item animations
  /// Default: 0.06 (60ms delay between items for a 1-second animation)
  final double delayMultiplier;
  
  /// The fraction of total animation time each item should animate for
  /// Default: 0.5 (each item animates for 50% of total duration)
  final double animationFraction;
  
  /// The animation curve to use
  final Curve curve;
  
  /// Initial scale value (0.0 to 1.0)
  /// Default: 0.5 (items start at 50% size)
  final double initialScale;
  
  /// Initial opacity value (0.0 to 1.0)
  /// Default: 0.0 (items start transparent)
  final double initialOpacity;

  const StaggeredAnimationItem({
    super.key,
    required this.animationController,
    required this.index,
    required this.child,
    this.delayMultiplier = 0.06,
    this.animationFraction = 0.5,
    this.curve = Curves.easeOutQuart,
    this.initialScale = 0.5,
    this.initialOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final delayFraction = index * delayMultiplier;
        
        final interval = Interval(
          delayFraction,
          (delayFraction + animationFraction).clamp(0.0, 1.0),
          curve: curve,
        );
        
        final animationValue = interval.transform(animationController.value);
        
        final opacity = initialOpacity + (animationValue * (1.0 - initialOpacity));
        final scale = initialScale + (animationValue * (1.0 - initialScale));

        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A convenience widget for creating staggered lists
/// 
/// This widget automatically applies staggered animations to a list of children
class StaggeredAnimationList extends StatefulWidget {
  /// The list of children to animate
  final List<Widget> children;
  
  /// Duration of the entire animation sequence
  final Duration duration;
  
  /// Delay multiplier - controls the spacing between item animations
  final double delayMultiplier;
  
  /// The fraction of total animation time each item should animate for
  final double animationFraction;
  
  /// The animation curve to use
  final Curve curve;
  
  /// Initial scale value for items
  final double initialScale;
  
  /// Initial opacity value for items
  final double initialOpacity;
  
  /// Whether to automatically start the animation
  final bool autoStart;
  
  /// Optional callback when animation completes
  final VoidCallback? onComplete;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 600),
    this.delayMultiplier = 0.06,
    this.animationFraction = 0.5,
    this.curve = Curves.easeOutQuart,
    this.initialScale = 0.5,
    this.initialOpacity = 0.0,
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    if (widget.onComplete != null) {
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete!();
        }
      });
    }
    
    if (widget.autoStart) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Manually start the animation
  void startAnimation() {
    _animationController.forward();
  }

  /// Reset and restart the animation
  void restartAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < widget.children.length; index++)
          StaggeredAnimationItem(
            animationController: _animationController,
            index: index,
            delayMultiplier: widget.delayMultiplier,
            animationFraction: widget.animationFraction,
            curve: widget.curve,
            initialScale: widget.initialScale,
            initialOpacity: widget.initialOpacity,
            child: widget.children[index],
          ),
      ],
    );
  }
}