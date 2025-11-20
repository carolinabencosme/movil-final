import 'package:flutter/material.dart';

/// Controller for managing onboarding state and navigation
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required this.pageController,
    required this.totalPages,
  });

  final PageController pageController;
  final int totalPages;

  int _currentPage = 0;

  int get currentPage => _currentPage;

  bool get isLastPage => _currentPage == totalPages - 1;

  /// Update the current page index
  void updatePage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  /// Navigate to the next page
  void nextPage() {
    if (!isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Navigate to a specific page
  void jumpToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
