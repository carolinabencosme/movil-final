import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.controller,
  });

  final AuthController controller;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (widget.controller.isAuthenticated) {
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
      },
    );
  }

  MaterialPageRoute<void> _buildLoginRoute() {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: LoginScreen.routeName),
      builder: (context) {
        return LoginScreen(
          controller: widget.controller,
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
          controller: widget.controller,
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
