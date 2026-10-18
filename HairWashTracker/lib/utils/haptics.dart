import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Central haptic vocabulary.
///
/// Widgets call these helpers instead of [HapticFeedback] directly so the
/// intensity of a given interaction stays consistent app-wide, and so a
/// platform without a haptic engine degrades to a logged no-op instead of
/// an unhandled exception.
class Haptics {
  Haptics._();

  static Future<void> lightHaptic() => _play(HapticFeedback.lightImpact, 'light');

  static Future<void> mediumHaptic() =>
      _play(HapticFeedback.mediumImpact, 'medium');

  static Future<void> heavyHaptic() => _play(HapticFeedback.heavyImpact, 'heavy');

  static Future<void> selectionHaptic() =>
      _play(HapticFeedback.selectionClick, 'selection');

  /// Two light pulses plus a medium confirmation: completion feedback that
  /// stays under the 200 ms motion budget.
  static Future<void> successHaptic() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (success): $e');
    }
  }

  static Future<void> errorHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback error (error): $e');
    }
  }

  static Future<void> _play(
      Future<void> Function() feedback, String label) async {
    try {
      await feedback();
    } catch (e) {
      debugPrint('Haptic feedback error ($label): $e');
    }
  }
}
