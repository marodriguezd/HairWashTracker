import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Haptic feedback utilities for the Hair Wash Tracker app
///
/// Provides soft, pleasant haptic patterns that enhance the user experience
/// without being jarring or distracting.
class Haptics {
  Haptics._();

  /// Light haptic feedback for subtle touches and hover states
  ///
  /// Use for: Hover effects, light touches, subtle UI interactions
  static Future<void> lightHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (light): $e');
    }
  }

  /// Medium haptic feedback for standard interactions
  ///
  /// Use for: Button presses, toggles, standard user actions
  static Future<void> mediumHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (medium): $e');
    }
  }

  /// Heavy haptic feedback for important actions
  ///
  /// Use for: Deletions, confirmations, significant state changes
  static Future<void> heavyHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (heavy): $e');
    }
  }

  /// Selection haptic feedback for selection changes
  ///
  /// Use for: Date picking, value selection, picker changes
  static Future<void> selectionHaptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic feedback error (selection): $e');
    }
  }

  /// Success haptic pattern - two light pulses followed by medium confirmation
  ///
  /// Use for: Successful operations, completions, achievements
  static Future<void> successHaptic() async {
    try {
      // First pulse - light
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));

      // Second pulse - light
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));

      // Final confirmation - medium
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (success): $e');
    }
  }

  /// Error haptic pattern - short double pulse
  ///
  /// Use for: Errors, validation failures, unsuccessful operations
  static Future<void> errorHaptic() async {
    try {
      // Error pattern - two quick heavy impacts
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (error): $e');
    }
  }

  /// Warning haptic pattern - single medium pulse
  ///
  /// Use for: Warnings, important notifications, attention needed
  static Future<void> warningHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (warning): $e');
    }
  }

  /// Long press haptic feedback
  ///
  /// Use for: Context menus, secondary actions on long press
  static Future<void> longPressHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (long press): $e');
    }
  }
}

/// Extension methods for easier haptic integration with widgets
extension HapticWidgetExtensions on Widget {
  /// Wraps widget with light haptic on tap
  Widget withLightHaptic({
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    if (!enabled) return this;

    return GestureDetector(
      onTap: () {
        Haptics.lightHaptic();
        onTap?.call();
      },
      child: this,
    );
  }

  /// Wraps widget with medium haptic on tap
  Widget withMediumHaptic({
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    if (!enabled) return this;

    return GestureDetector(
      onTap: () {
        Haptics.mediumHaptic();
        onTap?.call();
      },
      child: this,
    );
  }

  /// Wraps widget with selection haptic on tap
  Widget withSelectionHaptic({
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    if (!enabled) return this;

    return GestureDetector(
      onTap: () {
        Haptics.selectionHaptic();
        onTap?.call();
      },
      child: this,
    );
  }
}

/// Haptic feedback controller for managing haptic state
class HapticController extends ChangeNotifier {
  bool _enabled = true;

  /// Whether haptic feedback is enabled
  bool get enabled => _enabled;

  /// Enable or disable haptic feedback
  set enabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      notifyListeners();
    }
  }

  /// Toggle haptic feedback on/off
  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }

  /// Trigger light haptic if enabled
  Future<void> light() async {
    if (_enabled) await Haptics.lightHaptic();
  }

  /// Trigger medium haptic if enabled
  Future<void> medium() async {
    if (_enabled) await Haptics.mediumHaptic();
  }

  /// Trigger heavy haptic if enabled
  Future<void> heavy() async {
    if (_enabled) await Haptics.heavyHaptic();
  }

  /// Trigger selection haptic if enabled
  Future<void> selection() async {
    if (_enabled) await Haptics.selectionHaptic();
  }

  /// Trigger success haptic if enabled
  Future<void> success() async {
    if (_enabled) await Haptics.successHaptic();
  }

  /// Trigger error haptic if enabled
  Future<void> error() async {
    if (_enabled) await Haptics.errorHaptic();
  }
}
