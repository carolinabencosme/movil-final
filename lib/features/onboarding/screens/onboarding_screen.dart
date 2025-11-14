import 'package:flutter/material.dart';

import '../../../core/services/onboarding_service.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_page.dart';

/// Main onboarding screen with multiple pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;

  // Onboarding pages configuration
  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Bienvenido a ExploreDex',
      subtitle:
          'Tu compañero definitivo para explorar el mundo Pokémon. Descubre, aprende y conviértete en un maestro.',
      icon: Icons.catching_pokemon,
      color: Color(0xFFE94256),
      secondaryColor: Color(0xFFF2A649),
    ),
    _OnboardingPageData(
      title: 'Explora Pokémon',
      subtitle:
          'Encuentra información detallada sobre cada Pokémon, incluyendo tipos, estadísticas, habilidades y movimientos.',
      icon: Icons.auto_awesome_motion,
      color: Color(0xFF4DA3FF),
      secondaryColor: Color(0xFF3BC9DB),
    ),
    _OnboardingPageData(
      title: 'Mapas y Ubicaciones',
      subtitle:
          'Descubre dónde aparece cada Pokémon en diferentes regiones. Navega por mapas interactivos y encuentra tus favoritos.',
      icon: Icons.travel_explore,
      color: Color(0xFF3BC9DB),
      secondaryColor: Color(0xFF59CD90),
    ),
    _OnboardingPageData(
      title: 'Comparte y Aprende',
      subtitle:
          'Crea tarjetas personalizadas de tus Pokémon favoritos, compártelas con amigos y aprende estrategias de batalla.',
      icon: Icons.auto_fix_high,
      color: Color(0xFF9D4EDD),
      secondaryColor: Color(0xFFFF6F91),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(
      pageController: PageController(),
      totalPages: _pages.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.setOnboardingCompleted();
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with onboarding pages
          PageView.builder(
            controller: _controller.pageController,
            onPageChanged: _controller.updatePage,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return OnboardingPage(
                title: page.title,
                subtitle: page.subtitle,
                icon: page.icon,
                color: page.color,
                secondaryColor: page.secondaryColor,
              );
            },
          ),
          // Bottom navigation (dots and button)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page indicators (dots)
                        _buildPageIndicators(),
                        const SizedBox(height: 32),
                        // Navigation buttons
                        _buildNavigationButtons(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // Skip button (top right)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    // Hide skip button on last page
                    if (_controller.isLastPage) {
                      return const SizedBox.shrink();
                    }
                    return TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Saltar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => _buildDot(index),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _controller.currentPage == index;
    final page = _pages[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 32 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive
            ? page.color
            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _controller.isLastPage;
    final currentPage = _pages[_controller.currentPage];

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isLastPage
            ? _buildStartButton(currentPage.color)
            : _buildContinueButton(currentPage.color),
      ),
    );
  }

  Widget _buildContinueButton(Color color) {
    return ElevatedButton(
      key: const ValueKey('continue'),
      onPressed: _controller.nextPage,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Continuar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 24),
        ],
      ),
    );
  }

  Widget _buildStartButton(Color color) {
    return ElevatedButton(
      key: const ValueKey('start'),
      onPressed: _completeOnboarding,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Comenzar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.rocket_launch, size: 24),
        ],
      ),
    );
  }
}

/// Data class for onboarding page configuration
class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.secondaryColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color? secondaryColor;
}
