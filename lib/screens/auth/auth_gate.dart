import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../core/services/onboarding_service.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final completed = await OnboardingService.isOnboardingCompleted();
    if (mounted) {
      setState(() {
        _onboardingCompleted = completed;
        _isLoading = false;
      });
    }
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_onboardingCompleted) {
      return OnboardingScreen(
        onComplete: _completeOnboarding,
      );
    }

    if (isAuthenticated) {
      return const HomeScreen();
    }

    return Navigator(
      key: _navigatorKey,
      initialRoute: LoginScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RegisterScreen.routeName:
            return _buildRegisterRoute();
          case LoginScreen.routeName:
          default:
            return _buildLoginRoute();
        }
      },
    );
  }

  MaterialPageRoute<void> _buildLoginRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: LoginScreen.routeName),
      builder: (context) {
        return LoginScreen(
          onShowRegister: () {
            final navigatorState = _navigatorKey.currentState;
            if (navigatorState == null) {
              return;
            }
            navigatorState.pushNamed(RegisterScreen.routeName);
          },
        );
      },
    );
  }

  MaterialPageRoute<void> _buildRegisterRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: RegisterScreen.routeName),
      builder: (context) {
        return RegisterScreen(
          onShowLogin: () {
            final navigatorState = _navigatorKey.currentState;
            if (navigatorState == null) {
              return;
            }
            if (navigatorState.canPop()) {
              navigatorState.pop();
            } else {
              navigatorState.pushReplacementNamed(LoginScreen.routeName);
            }
          },
        );
      },
    );
  }
}
