import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/models/user.dart' as my_app_user;
import 'package:aiko_ben_expense_app/screens/setting/account_screen.dart';
import 'package:aiko_ben_expense_app/screens/setting/category_setting_screen.dart';
import 'package:aiko_ben_expense_app/screens/setting/household_settings_screen.dart';
import 'package:aiko_ben_expense_app/screens/setting/notification_settings.dart';
import 'package:aiko_ben_expense_app/services/auth_service.dart';
import 'package:aiko_ben_expense_app/shared/loading.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_scaffold.dart';
import 'package:aiko_ben_expense_app/shared/widgets/member_avatar.dart';
import 'package:aiko_ben_expense_app/shared/widgets/section_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.userChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        final User? user = snapshot.data;
        final displayName = (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!
            : 'User';
        final email = user?.email ?? '';

        return AppScaffold(
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              Column(
                children: [
                  MemberAvatar(name: displayName, size: 72),
                  const SizedBox(height: AppSpacing.md),
                  Text(displayName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(email,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
              const SectionHeader(title: 'ACCOUNT'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.account_circle_outlined,
                    title: 'Account',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountScreen()),
                      );
                      await _auth.currentUser?.reload();
                    },
                  ),
                  const Divider(height: 1, indent: AppSpacing.huge),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationSettings()),
                      );
                    },
                  ),
                ],
              ),
              const SectionHeader(title: 'PREFERENCES'),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.category_outlined,
                    title: 'Category Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategorySettingScreen()),
                      );
                    },
                  ),
                  Builder(builder: (context) {
                    final householdId =
                        Provider.of<my_app_user.User?>(context)?.householdId;
                    if (householdId == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const Divider(height: 1, indent: AppSpacing.huge),
                        _SettingsTile(
                          icon: Icons.home_outlined,
                          title: 'Household',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HouseholdSettingsScreen(
                                    householdId: householdId),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextButton(
                onPressed: () async {
                  await _auth.signOut();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                child: const Text('Log Out'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Material(
          color: Colors.transparent,
          child: Column(children: children),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    );
  }
}
