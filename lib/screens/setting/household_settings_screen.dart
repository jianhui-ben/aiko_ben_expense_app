import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/household.dart';
import 'package:aiko_ben_expense_app/services/household_service.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HouseholdSettingsScreen extends StatelessWidget {
  final String householdId;

  const HouseholdSettingsScreen({super.key, required this.householdId});

  @override
  Widget build(BuildContext context) {
    final service = HouseholdService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Household')),
      body: StreamBuilder<Household?>(
        stream: service.householdStream(householdId),
        builder: (context, householdSnap) {
          if (!householdSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final household = householdSnap.data;
          if (household == null) {
            return const Center(child: Text('Household not found.'));
          }

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
                          onPressed: () =>
                              _editName(context, service, household),
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
              StreamBuilder<List<HouseholdMember>>(
                stream: service.membersStream(householdId),
                builder: (context, membersSnap) {
                  final members = membersSnap.data ?? [];
                  if (members.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Text('No members yet.'),
                    );
                  }
                  return Column(
                    children: members
                        .map((m) => AppCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  MemberAvatar(name: m.displayName, size: 40),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(m.displayName,
                                        style: theme.textTheme.titleMedium),
                                  ),
                                  if (m.isOwner)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.sm),
                                      ),
                                      child: Text('Owner',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                                  color: AppColors.primary)),
                                    ),
                                ],
                              ),
                            ))
                        .toList()
                        .expand((w) => [w, const SizedBox(height: AppSpacing.sm)])
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editName(
      BuildContext context, HouseholdService service, Household household) async {
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
    if (newName != null && newName.isNotEmpty) {
      await service.updateHouseholdName(household.id, newName);
    }
  }
}
