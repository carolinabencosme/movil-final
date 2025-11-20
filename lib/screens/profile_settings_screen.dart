import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_repository.dart';
import 'package:pokedex/l10n/app_localizations.dart';

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

  AppLocalizations get l10n => AppLocalizations.of(context)!;

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
        title: Text(l10n.settingsEditProfile),
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
                l10n.authUpdateInfoTitle,
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.authUpdateInfoSubtitle,
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
                        labelText: l10n.authNewPasswordOptionalLabel,
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
                      child: Text(l10n.settingsSaveChanges),
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
        SnackBar(
          content: Text(l10n.authSnackbarNoUser),
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
        SnackBar(
          content: Text(l10n.authProfileUpdated),
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
        SnackBar(
          content: Text(l10n.authProfileUpdateError),
        ),
      );
    }
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
    final password = value?.trim() ?? '';
    if (password.isEmpty) {
      return null;
    }

    if (password.length < 6) {
      return l10n.authPasswordLength;
    }

    if (!RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[A-Za-z]').hasMatch(password)) {
      return l10n.authPasswordStrongSuggestion;
    }

    return null;
  }
}
