import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state persistence using [SharedPreferences].
class OnboardingService {
  OnboardingService._();

  static const String _onboardingKey = 'onboarding_completed';

  /// Check if the user has completed the onboarding.
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  /// Mark onboarding as completed.
  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  /// Reset onboarding state (useful for testing).
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
  }
}
