import 'dart:async';

import 'package:flutter/material.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class AuthRepository {
  AuthRepository();

  final Map<String, String> _users = {
    'trainer@poke.app': 'pikachu123',
  };

  Future<void> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalizedEmail = email.trim().toLowerCase();
    final storedPassword = _users[normalizedEmail];
    if (storedPassword == null || storedPassword != password.trim()) {
      throw const AuthException('Credenciales inválidas.');
    }
  }

  Future<void> register(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final normalizedEmail = email.trim().toLowerCase();
    if (_users.containsKey(normalizedEmail)) {
      throw const AuthException('Ya existe una cuenta con este correo.');
    }

    _users[normalizedEmail] = password.trim();
  }
}

class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentEmail;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentEmail => _currentEmail;

  Future<bool> login({required String email, required String password}) async {
    if (_isLoading) {
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.login(email, password);
      _currentEmail = email.trim();
      _isAuthenticated = true;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isAuthenticated = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.register(email, password);
      _currentEmail = email.trim();
      _isAuthenticated = true;
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isAuthenticated = false;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    if (!_isAuthenticated) {
      return;
    }

    _isAuthenticated = false;
    _currentEmail = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null,
        'AuthScope.of() called with a context that does not contain an AuthScope.');
    return scope!.notifier!;
  }

  static AuthController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
  }
}
