import 'package:flutter/material.dart';

import '../services/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository}) : _repository = repository {
    _repository.addListener(_onRepositoryChanged);
  }

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _repository.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentEmail => _repository.currentUser?.email;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.login(email: email, password: password);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
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
      await _repository.registerUser(email: email, password: password);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_isLoading) {
      return;
    }

    _errorMessage = null;
    await _repository.logout();
  }

  Future<void> updateProfile({
    required String email,
    String? newEmail,
    String? newPassword,
  }) async {
    if (_isLoading) {
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      await _repository.updateProfile(
        email: email,
        newEmail: newEmail,
        newPassword: newPassword,
      );
    } on AuthException catch (error) {
      _errorMessage = error.message;
      throw error;
    } finally {
      _setLoading(false);
    }
  }

  void _onRepositoryChanged() {
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
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
