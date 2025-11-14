import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pokedex/core/services/onboarding_service.dart';

void main() {
  group('OnboardingService', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('isOnboardingCompleted returns false by default', () async {
      final result = await OnboardingService.isOnboardingCompleted();
      expect(result, false);
    });

    test('setOnboardingCompleted marks onboarding as completed', () async {
      await OnboardingService.setOnboardingCompleted();
      final result = await OnboardingService.isOnboardingCompleted();
      expect(result, true);
    });

    test('resetOnboarding clears onboarding status', () async {
      await OnboardingService.setOnboardingCompleted();
      expect(await OnboardingService.isOnboardingCompleted(), true);

      await OnboardingService.resetOnboarding();
      expect(await OnboardingService.isOnboardingCompleted(), false);
    });
  });
}
