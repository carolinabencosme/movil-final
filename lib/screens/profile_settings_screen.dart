import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../services/auth_repository.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    required this.controller,
  });

  final AuthController controller;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.controller.currentEmail ?? '',
    );
    _passwordController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ProfileSettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentEmail = widget.controller.currentEmail ?? '';
    if (_emailController.text != currentEmail) {
      _emailController.text = currentEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final isLoading = widget.controller.isLoading;
          final textTheme = Theme.of(context).textTheme;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'Actualiza tu información de acceso.',
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Puedes cambiar tu correo electrónico o establecer una nueva contraseña. Los cambios se aplican inmediatamente.',
                style: textTheme.bodyMedium,
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
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
                        hintText: 'ash.ketchum@poke.app',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña (opcional)',
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
                      onPressed: isLoading ? null : _submit,
                      child: const Text('Guardar cambios'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _togglePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final controller = widget.controller;
    final currentEmail = controller.currentEmail;
    if (currentEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay información de usuario disponible.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    try {
      await controller.updateProfile(
        email: currentEmail,
        newEmail: newEmail,
        newPassword: newPassword.isEmpty ? null : newPassword,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente.'),
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible actualizar el perfil.'),
        ),
      );
    }
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
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return null;
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
}
