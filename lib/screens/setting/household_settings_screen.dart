import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/household.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/services/household_service.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HouseholdSettingsScreen extends StatefulWidget {
  final String householdId;

  const HouseholdSettingsScreen({super.key, required this.householdId});

  @override
  State<HouseholdSettingsScreen> createState() =>
      _HouseholdSettingsScreenState();
}

class _HouseholdSettingsScreenState extends State<HouseholdSettingsScreen> {
  final HouseholdService _service = HouseholdService();
  final AuthService _auth = AuthService();
  bool _actionLoading = false;

  String get _currentUid => _auth.currentUser!.uid;

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _actionLoading = true);
    try {
      await action();
    } on HouseholdException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _confirmTransferOwnership(HouseholdMember partner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make ${partner.displayName} the owner?'),
        content: Text(
          '${partner.displayName} will become the owner and can manage the '
          'household name and invite code. You\'ll become a regular member.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Transfer ownership'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runAction(() => _service.transferOwnership(
          householdId: widget.householdId,
          currentOwnerUid: _currentUid,
          newOwnerUid: partner.uid,
        ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${partner.displayName} is now the owner.')),
      );
    }
  }

  Future<void> _confirmLeave(Household household, bool isSoleMember) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Leave "${household.name}"?',
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You can create or join another household afterward.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '• Shared expenses, budget, and categories stay with this household',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '• You can rejoin later with the invite code',
                style: theme.textTheme.bodyMedium,
              ),
              if (isSoleMember) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '• No one will have access until someone joins with the code',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Leave household'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;

    await _runAction(() => _service.leaveHousehold(
          uid: _currentUid,
          householdId: widget.householdId,
        ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You left the household')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Household')),
      body: StreamBuilder<Household?>(
        stream: _service.householdStream(widget.householdId),
        builder: (context, householdSnap) {
          if (!householdSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final household = householdSnap.data;
          if (household == null) {
            return const Center(child: Text('Household not found.'));
          }

          return StreamBuilder<List<HouseholdMember>>(
            stream: _service.membersStream(widget.householdId),
            builder: (context, membersSnap) {
              final membersLoaded = membersSnap.hasData;
              final members = membersSnap.data ?? [];
              HouseholdMember? currentMember;
              for (final m in members) {
                if (m.uid == _currentUid) {
                  currentMember = m;
                  break;
                }
              }
              final isOwner = currentMember?.isOwner ?? false;
              final otherMembers =
                  members.where((m) => m.uid != _currentUid).toList();
              final hasPartner = otherMembers.isNotEmpty;
              final canLeave = membersLoaded && (!isOwner || !hasPartner);
              final partner = hasPartner ? otherMembers.first : null;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(household.name,
                                  style: theme.textTheme.titleMedium),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: _actionLoading
                                  ? null
                                  : () => _editName(context, household),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite code', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                household.inviteCode,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(letterSpacing: 4),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: household.inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Invite code copied')),
                                );
                              },
                            ),
                          ],
                        ),
                        Text('Share this code so your partner can join.',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Members', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  if (!membersLoaded)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text('No members yet.'),
                    )
                  else
                    ...members.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                MemberAvatar(name: m.displayName, size: 40),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    m.uid == _currentUid
                                        ? '${m.displayName} (You)'
                                        : m.displayName,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                if (m.isOwner)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Text('Owner',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                                color: AppColors.primary)),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  if (membersLoaded && isOwner && hasPartner && partner != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text('Ownership', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'You\'re the owner of this household. Transfer '
                            'ownership before leaving if your partner should '
                            'manage it.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          OutlinedButton(
                            onPressed: _actionLoading
                                ? null
                                : () => _confirmTransferOwnership(partner),
                            child: Text('Make ${partner.displayName} the owner'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (membersLoaded) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Text('Change household', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Leave this household to create or join a different '
                          'one. Shared expenses stay with this household.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (!canLeave && partner != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Transfer ownership to ${partner.displayName} before leaving.',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton(
                          onPressed: _actionLoading || !canLeave
                              ? null
                              : () => _confirmLeave(
                                    household,
                                    members.length <= 1,
                                  ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: _actionLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Change household'),
                        ),
                      ],
                    ),
                  ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editName(BuildContext context, Household household) async {
    final controller = TextEditingController(text: household.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Household name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null && newName.isNotEmpty) {
      await _service.updateHouseholdName(household.id, newName);
    }
  }
}
