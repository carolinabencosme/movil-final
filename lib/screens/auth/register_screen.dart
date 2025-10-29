import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.controller,
    required this.onShowLogin,
  });

  static const String routeName = '/register';

  final AuthController controller;
  final VoidCallback onShowLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
                  child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.catching_pokemon,
                            size: 48,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Crea tu cuenta',
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Regístrate para sincronizar tus equipos y colecciones en todos tus dispositivos.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          if (widget.controller.isLoading)
                            const LinearProgressIndicator(),
                          if (widget.controller.isLoading)
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
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'entrenador@poke.app',
                                    prefixIcon: Icon(Icons.mail_outline),
                                  ),
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.next,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
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
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmController,
                                  textInputAction: TextInputAction.done,
                                  obscureText: _obscureConfirmation,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar contraseña',
                                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmation
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: _toggleConfirmation,
                                    ),
                                  ),
                                  validator: _validateConfirmation,
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: widget.controller.isLoading
                                      ? null
                                      : _submit,
                                  child: const Text('Crear cuenta'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: widget.controller.isLoading
                                ? null
                                : widget.onShowLogin,
                            child: const Text('¿Ya tienes una cuenta? Inicia sesión'),
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
    final success = await widget.controller.register(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted || success) {
      return;
    }

    final message = widget.controller.errorMessage ??
        'No pudimos crear tu cuenta. Inténtalo más tarde.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmation() {
    setState(() {
      _obscureConfirmation = !_obscureConfirmation;
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }

    final hasAt = email.contains('@');
    final segments = email.split('@');
    final hasDomain = segments.length == 2 && segments[1].contains('.');
    if (!hasAt || !hasDomain) {
      return 'Formato de correo inválido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Ingresa una contraseña segura.';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Usa letras y números para una contraseña más fuerte.';
    }

    return null;
  }

  String? _validateConfirmation(String? value) {
    final confirmation = value ?? '';
    if (confirmation != _passwordController.text) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }
}
