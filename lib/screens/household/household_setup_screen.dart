import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/household_service.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HouseholdSetupScreen extends StatefulWidget {
  const HouseholdSetupScreen({super.key});

  @override
  State<HouseholdSetupScreen> createState() => _HouseholdSetupScreenState();
}

enum _SetupMode { choose, create, join }

class _HouseholdSetupScreenState extends State<HouseholdSetupScreen> {
  final AuthService _auth = AuthService();
  final HouseholdService _households = HouseholdService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  _SetupMode _mode = _SetupMode.choose;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String get _displayName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email ?? 'Member';

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please name your household.');
      return;
    }
    await _run(() => _households.createHousehold(
          uid: _auth.currentUser!.uid,
          displayName: _displayName,
          name: name,
        ));
  }

  Future<void> _join() async {
    await _run(() => _households.joinHousehold(
          uid: _auth.currentUser!.uid,
          displayName: _displayName,
          code: _codeController.text,
        ));
  }

  /// Runs an async household op with loading + error handling.
  /// On success the auth stream picks up the new householdId and the
  /// wrapper routes to the app automatically.
  Future<void> _run(Future<String> Function() op) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await op();
    } on HouseholdException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.huge),
              Icon(Icons.home_rounded,
                  size: 56, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Choose a household',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create a new shared ledger or join one with an invite code.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              if (_error != null) ...[
                Text(_error!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (_mode == _SetupMode.choose) _buildChoose(theme),
              if (_mode == _SetupMode.create) _buildCreate(theme),
              if (_mode == _SetupMode.join) _buildJoin(theme),
              const SizedBox(height: AppSpacing.xxl),
              TextButton(
                onPressed: _loading ? null : () => _auth.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoose(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          onTap: () => setState(() {
            _mode = _SetupMode.create;
            _error = null;
          }),
          child: Row(
            children: [
              const Icon(Icons.add_home_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create household',
                        style: theme.textTheme.titleMedium),
                    Text('Start fresh and invite your partner',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          onTap: () => setState(() {
            _mode = _SetupMode.join;
            _error = null;
          }),
          child: Row(
            children: [
              const Icon(Icons.group_add_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Join with code',
                        style: theme.textTheme.titleMedium),
                    Text('Enter the 6-character invite code',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreate(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Household name',
            hintText: 'e.g. Ben & Aiko',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _loading ? null : _create,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create household'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _loading ? null : () => setState(() => _mode = _SetupMode.choose),
          child: const Text('Back'),
        ),
      ],
    );
  }

  Widget _buildJoin(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            _UpperCaseFormatter(),
          ],
          style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 4),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: 'Invite code',
            hintText: 'ABC123',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: _loading ? null : _join,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Join household'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _loading ? null : () => setState(() => _mode = _SetupMode.choose),
          child: const Text('Back'),
        ),
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
