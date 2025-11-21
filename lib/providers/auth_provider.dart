import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_repository.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'authRepositoryProvider must be overridden in ProviderScope',
  );
});

/// Provider for AuthController
final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository: repository);
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

/// Provider for loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isLoading;
});

/// Provider for error message
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).errorMessage;
});

/// Provider for current user email
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).currentEmail;
});
