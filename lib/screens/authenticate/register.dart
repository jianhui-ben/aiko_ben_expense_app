import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/screens/authenticate/auth_header.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/user_bootstrap.dart';
import 'package:flutter/material.dart';

import '../../shared/loading.dart';

class Register extends StatefulWidget {
  final VoidCallback toggleView;

  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String emailErrorText = "The email can't be empty";
  final String passwordErrorText =
      'The password has to be longer than 5 characters';
  String _errorText = '';
  bool loading = false;

  String _formatAuthError(dynamic error) {
    final message = error.toString();
    final match = RegExp(r'\] (.+)$').firstMatch(message);
    return match?.group(1) ?? message;
  }

  Future<void> signUpWithEmailAndPassword() async {
    final String email = emailController.text;
    final String password = passwordController.text;
    final String useName = userNameController.text;

    final dynamic result =
        await _auth.registerWithEmailAndPassword(email, password, useName);
    if (result is! User) {
      if (mounted) {
        setState(() {
          _errorText = _formatAuthError(result);
        });
      }
      return;
    }

    await UserBootstrap().ensureUserDocument(
      result.uid,
      displayName: useName,
      email: email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) return Loading();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.huge),
                const AuthHeader(
                  title: 'Create account',
                  subtitle: 'Set up your shared household',
                ),
                const SizedBox(height: AppSpacing.xxxl),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return emailErrorText;
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return passwordErrorText;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: userNameController,
                  decoration: const InputDecoration(labelText: 'Name / Alias'),
                ),
                if (_errorText.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => loading = true);
                    try {
                      await signUpWithEmailAndPassword();
                    } finally {
                      if (mounted) setState(() => loading = false);
                    }
                  },
                  child: const Text('Sign up'),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Have an account?', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: widget.toggleView,
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
