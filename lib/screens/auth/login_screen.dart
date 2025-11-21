import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.onShowRegister,
  });

  static const String routeName = '/login';

  final VoidCallback onShowRegister;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        theme.brightness == Brightness.dark ? 0.35 : 0.12,
                      ),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.authLoginTitle,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authLoginSubtitle,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      if (ref.watch(authLoadingProvider))
                        const LinearProgressIndicator(),
                      if (ref.watch(authLoadingProvider))
                        const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.authEmailLabel,
                                hintText: l10n.authEmailHint,
                                prefixIcon: const Icon(Icons.mail_outline),
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              textInputAction: TextInputAction.done,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: l10n.authPasswordLabel,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: _togglePassword,
                                ),
                              ),
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed:
                                  ref.watch(authLoadingProvider) ? null : _submit,
                              child: Text(l10n.authLoginButton),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                          TextButton(
                            onPressed: ref.watch(authLoadingProvider)
                                ? null
                                : widget.onShowRegister,
                            child: Text(l10n.authNoAccountCta),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final controller = ref.read(authControllerProvider);
    final success = await controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted || success) {
      return;
    }

    final message =
        ref.read(authErrorProvider) ?? l10n.authLoginError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return l10n.authEmailRequired;
    }

    final hasAt = email.contains('@');
    final segments = email.split('@');
    final hasDomain = segments.length == 2 && segments[1].contains('.');
    if (!hasAt || !hasDomain) {
      return l10n.authEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return l10n.authPasswordRequired;
    }

    if (password.length < 6) {
      return l10n.authPasswordLength;
    }

    return null;
  }
}
