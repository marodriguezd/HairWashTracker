import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated Mesh Gradient Background
/// 
/// Creates a flowing, animated mesh gradient with soft lavender, sage green, and cream colors.
/// The animation is subtle and calming, not distracting.
class AnimatedMeshGradient extends StatefulWidget {
  final Widget child;
  
  const AnimatedMeshGradient({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedMeshGradient> createState() => _AnimatedMeshGradientState();
}

class _AnimatedMeshGradientState extends State<AnimatedMeshGradient>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;
  
  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _controller2 = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _controller3 = AnimationController(vsync: this, duration: const Duration(seconds: 18));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller1.repeat();
        _controller2.repeat();
        _controller3.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller1.stop();
    _controller2.stop();
    _controller3.stop();
    
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      const lavender = Color(0xFFE8D5E8);
      const sageGreen = Color(0xFFC5D5C5);
      const cream = Color(0xFFF5F1E8);
      const softBlue = Color(0xFFD5E3E8);
      
      return AnimatedBuilder(
        animation: Listenable.merge([_controller1, _controller2, _controller3]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  0.3 + 0.4 * sin(_controller1.value * 2 * pi),
                  0.3 + 0.4 * cos(_controller1.value * 2 * pi),
                ),
                radius: 1.2,
                colors: [
                  Color.lerp(lavender, cream, 0.5 + 0.3 * sin(_controller2.value * 2 * pi))!,
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    -0.3 + 0.4 * cos(_controller2.value * 2 * pi),
                    0.7 + 0.3 * sin(_controller2.value * 2 * pi),
                  ),
                  radius: 1.0,
                  colors: [
                    Color.lerp(sageGreen, softBlue, 0.5 + 0.3 * cos(_controller1.value * 2 * pi))!,
                    Colors.transparent,
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.7 + 0.3 * sin(_controller3.value * 2 * pi),
                      -0.2 + 0.4 * cos(_controller3.value * 2 * pi),
                    ),
                    radius: 0.9,
                    colors: [
                      Color.lerp(cream, lavender, 0.4 + 0.3 * sin(_controller3.value * 2 * pi))!,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: widget.child,
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('AnimatedMeshGradient build error: $e');
      return Container(
        color: const Color(0xFFFDF8FB),
        child: widget.child,
      );
    }
  }
}

/// Simple animated gradient background for a more static look
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? const [
      Color(0xFFE8D5E8), // Soft lavender
      Color(0xFFF5F1E8), // Cream
      Color(0xFFC5D5C5), // Sage green
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colors[0], colors[1], _controller.value)!,
                Color.lerp(colors[1], colors[2], _controller.value)!,
                Color.lerp(colors[2], colors[0], _controller.value)!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Animation durations and curves for consistent use throughout the app
class AnimationConstants {
  AnimationConstants._();

  // Durations - Phase 7 naming convention
  static const Duration quickDuration = Duration(milliseconds: 150);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // Legacy durations (for backward compatibility)
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(seconds: 15);

  // Spring Curves - Soft and calming motion
  static const Curve softSpring = Curves.fastEaseInToSlowEaseOut;
  static const Curve bouncySpring = Curves.elasticOut;
  static const Curve smoothEase = Curves.easeInOutCubic;

  // Legacy curves (for backward compatibility)
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve elasticOut = Curves.elasticOut;
}

/// Spring curve definitions with customizable parameters
class SpringCurves {
  SpringCurves._();

  /// Gentle spring for subtle UI element motion
  /// Uses a softer damping for calming, pleasant movement
  static const Cubic softSpring = Cubic(0.25, 0.46, 0.45, 0.94);

  /// Playful spring for interactive elements
  /// More bouncy but still pleasant
  static const Cubic bouncySpring = Cubic(0.68, -0.55, 0.265, 1.55);

  /// Standard smooth ease for general transitions
  static const Cubic smoothEase = Cubic(0.4, 0.0, 0.2, 1.0);
}

/// Stagger animation helpers for sequential reveals
class StaggerAnimations {
  StaggerAnimations._();

  /// Creates a staggered list animation effect using flutter_animate
  /// 
  /// [index] - The index of the item in the list
  /// [delay] - Base delay between items (default: 50ms)
  /// [duration] - Animation duration (default: 300ms)
  static Animate staggeredListAnimation(
    Widget child, {
    required int index,
    Duration delay = const Duration(milliseconds: 50),
    Duration duration = AnimationConstants.normalDuration,
  }) {
    return child.animate().fadeIn(
          duration: duration,
          delay: delay * index,
          curve: SpringCurves.softSpring,
        );
  }

  /// Creates a combined fade + slide animation
  /// 
  /// [slideBegin] - Starting offset for slide (default: 30px down)
  /// [duration] - Animation duration
  static Animate fadeSlideAnimation(
    Widget child, {
    Offset slideBegin = const Offset(0, 30),
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
  }) {
    return child
        .animate()
        .fadeIn(duration: duration, delay: delay, curve: SpringCurves.smoothEase)
        .slide(
          begin: slideBegin,
          duration: duration,
          delay: delay,
          curve: SpringCurves.softSpring,
        );
  }

  /// Creates a combined scale + fade animation
  /// 
  /// [scaleBegin] - Starting scale value (default: 0.9)
  /// [duration] - Animation duration
  static Animate scaleFadeAnimation(
    Widget child, {
    double scaleBegin = 0.9,
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
  }) {
    return child
        .animate()
        .fadeIn(duration: duration, delay: delay, curve: SpringCurves.smoothEase)
        .scale(
          begin: Offset(scaleBegin, scaleBegin),
          end: const Offset(1.0, 1.0),
          duration: duration,
          delay: delay,
          curve: SpringCurves.softSpring,
        );
  }
}

/// Widget extension methods for common animations
extension AnimationWidgetExtensions on Widget {
  /// Quick fade in animation
  Animate fadeIn({
    Duration duration = AnimationConstants.quickDuration,
    Duration? delay,
    Curve curve = SpringCurves.smoothEase,
  }) {
    return animate().fadeIn(duration: duration, delay: delay, curve: curve);
  }

  /// Slide up animation from bottom
  Animate slideUp({
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
    double offset = 50,
    Curve curve = SpringCurves.softSpring,
  }) {
    return animate().slide(
      begin: Offset(0, offset),
      end: Offset.zero,
      duration: duration,
      delay: delay,
      curve: curve,
    );
  }

  /// Scale in animation from 0.9 to 1.0
  Animate scaleIn({
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
    double begin = 0.9,
    Curve curve = SpringCurves.softSpring,
  }) {
    return animate().scale(
      begin: Offset(begin, begin),
      end: const Offset(1.0, 1.0),
      duration: duration,
      delay: delay,
      curve: curve,
    );
  }

  /// Apply soft spring curve to any animation
  Animate softSpring({
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
  }) {
    return animate().custom(
      duration: duration,
      delay: delay,
      builder: (context, value, child) => child,
    );
  }

  /// Combined fade + slide up for list items
  Animate fadeSlideUp({
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
    double slideOffset = 30,
  }) {
    return StaggerAnimations.fadeSlideAnimation(
      this,
      slideBegin: Offset(0, slideOffset),
      duration: duration,
      delay: delay,
    );
  }

  /// Combined scale + fade for emphasis
  Animate scaleFadeIn({
    Duration duration = AnimationConstants.normalDuration,
    Duration? delay,
    double scaleBegin = 0.9,
  }) {
    return StaggerAnimations.scaleFadeAnimation(
      this,
      scaleBegin: scaleBegin,
      duration: duration,
      delay: delay,
    );
  }
}

/// Custom page transition animations
class PageTransitions {
  PageTransitions._();

  /// Soft slide + fade page transition
  static Route<T> softSlideFade<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: SpringCurves.smoothEase,
        );
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: SpringCurves.softSpring,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.quickDuration,
    );
  }

  /// Shared axis transition for related pages
  static Route<T> sharedAxis<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          child: child,
        );
      },
      transitionDuration: AnimationConstants.normalDuration,
      reverseTransitionDuration: AnimationConstants.quickDuration,
    );
  }
}

/// Shared axis transition types
enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

/// Shared axis transition widget implementation
class SharedAxisTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const SharedAxisTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return _buildHorizontalTransition();
      case SharedAxisTransitionType.vertical:
        return _buildVerticalTransition();
      case SharedAxisTransitionType.scaled:
        return _buildScaledTransition();
    }
  }

  Widget _buildHorizontalTransition() {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: SpringCurves.softSpring,
    ));
    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: SpringCurves.smoothEase,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }

  Widget _buildVerticalTransition() {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: SpringCurves.softSpring,
    ));
    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: SpringCurves.smoothEase,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }

  Widget _buildScaledTransition() {
    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: SpringCurves.softSpring,
    ));
    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: SpringCurves.smoothEase,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: child,
      ),
    );
  }
}
