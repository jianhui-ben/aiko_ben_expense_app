import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/user.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/user_bootstrap.dart';
import 'package:flutter/material.dart';

import '../../shared/loading.dart';

class SignIn extends StatefulWidget {
  final VoidCallback toggleView;

  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String emailErrorText = "The email can't be empty";
  final String passwordErrorText =
      'The password has to be longer than 5 characters';
  String _errorText = '';
  bool loading = false;

  Future<void> signInWithEmailAndPassword() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
    if (result is! User?) {
      if (mounted) {
        setState(() {
          _errorText = result.toString();
        });
      }
    } else if (result != null) {
      _errorText = '';
      await UserBootstrap().ensureUserDocument(
        result.uid,
        displayName: _auth.currentUser?.displayName,
        email: _auth.currentUser?.email,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    dynamic result = await _auth.signInWithGoogle();
    if (result is! User?) {
      if (mounted) {
        setState(() {
          _errorText = result.toString();
        });
      }
    } else if (result != null) {
      _errorText = '';
      final name = _auth.currentUser?.displayName ?? 'google signin';
      await UserBootstrap().ensureUserDocument(
        result.uid,
        displayName: name,
        email: _auth.currentUser?.email,
      );
    }
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
                Text('Aiko', style: theme.textTheme.headlineLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('Track together', style: theme.textTheme.bodyMedium),
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
                if (_errorText.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(_errorText, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  )),
                ],
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => loading = true);
                    await signInWithEmailAndPassword();
                    if (mounted) setState(() => loading = false);
                  },
                  child: const Text('Sign in'),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: () async {
                    setState(() => loading = true);
                    await signInWithGoogle();
                    if (mounted) setState(() => loading = false);
                  },
                  child: const Text('Continue with Google'),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No account?', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: widget.toggleView,
                      child: const Text('Sign up'),
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
