import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

class AuthRepository extends ChangeNotifier {
  AuthRepository._(this._usersBox, this._sessionBox);

  static const _usersBoxName = 'auth_users_box';
  static const _sessionBoxName = 'auth_session_box';
  static const _currentUserKey = 'current_user_email';

  final Box<UserModel> _usersBox;
  final Box<String> _sessionBox;

  UserModel? _currentUser;

  static Future<AuthRepository> init() async {
    final adapter = UserModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    final usersBox = await Hive.openBox<UserModel>(_usersBoxName);
    final sessionBox = await Hive.openBox<String>(_sessionBoxName);
    final repository = AuthRepository._(usersBox, sessionBox);
    await repository.restoreSession();
    return repository;
  }

  UserModel? get currentUser => _currentUser;

  Future<UserModel> registerUser({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (_usersBox.containsKey(normalizedEmail)) {
      throw const AuthException('Ya existe una cuenta con este correo.');
    }

    final hashedPassword = _hashPassword(password);
    final user = UserModel(
      email: normalizedEmail,
      passwordHash: hashedPassword,
    );

    await _usersBox.put(normalizedEmail, user);
    await _persistCurrentUser(user);
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final storedUser = _usersBox.get(normalizedEmail);
    final hashedPassword = _hashPassword(password);

    if (storedUser == null || storedUser.passwordHash != hashedPassword) {
      throw const AuthException('Credenciales inválidas.');
    }

    await _persistCurrentUser(storedUser);
    return storedUser;
  }

  Future<void> logout() async {
    if (_currentUser == null) {
      return;
    }

    _currentUser = null;
    await _sessionBox.delete(_currentUserKey);
    notifyListeners();
  }

  Future<void> restoreSession() async {
    final savedEmail = _sessionBox.get(_currentUserKey);
    if (savedEmail == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    final storedUser = _usersBox.get(savedEmail);
    if (storedUser == null) {
      _currentUser = null;
      await _sessionBox.delete(_currentUserKey);
      notifyListeners();
      return;
    }

    _currentUser = storedUser;
    notifyListeners();
  }

  Future<void> _persistCurrentUser(UserModel user) async {
    _currentUser = user;
    await _sessionBox.put(_currentUserKey, user.email);
    notifyListeners();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _hashPassword(String password) {
    final normalized = password.trim();
    final bytes = utf8.encode(normalized);
    return sha256.convert(bytes).toString();
  }
}
