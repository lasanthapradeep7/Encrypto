import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/core/theme/theme_controller.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/auth/presentation/pages/login_page.dart';
import 'package:encrypto/features/encryption/presentation/widgets/profile_dialogs.dart';
import 'package:encrypto/services/session_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationSound = true;
  bool _cloudSync = false;

  Future<void> _setDarkMode(bool enabled) async {
    await ThemeController.instance.setDarkMode(enabled);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled ? 'Dark mode is now on.' : 'Light mode is now on.',
        ),
      ),
    );
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label isn’t available yet. We’re working on it.'),
      ),
    );
  }

  Future<void> _changePassword() async {
    final changed = await showChangePasswordDialog(context);
    if (changed && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password changed successfully.')));
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.encryptoColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.18),
            ),
          ),
          icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 44),
          title: Text(
            'Sign out?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.encryptoColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'You’ll need to sign in again to access your encrypted workspace.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) {
      return;
    }

    await SessionService.clearSession();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          showBackButton: true,
          onBackPressed: widget.onBackPressed,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: EdgeInsets.fromLTRB(28, 28, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: context.encryptoColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 34),
                  _SettingsGroup(
                    children: [
                      _SettingsSwitchRow(
                        label: 'Dark mode',
                        value: ThemeController.instance.isDark,
                        onChanged: _setDarkMode,
                      ),
                    ],
                  ),
                  SizedBox(height: 38),
                  _SettingsGroup(
                    children: [
                      _SettingsActionRow(
                        label: 'Change password',
                        onTap: _changePassword,
                      ),
                      _SettingsActionRow(
                        label: 'Sign out',
                        destructive: true,
                        onTap: _logout,
                      ),
                    ],
                  ),
                  SizedBox(height: 38),
                  _SettingsGroup(
                    children: [
                      _SettingsActionRow(
                        label: 'Notification settings',
                        onTap: () => _showComingSoon('Notification settings'),
                      ),
                      _SettingsSwitchRow(
                        label: 'Notification sound',
                        value: _notificationSound,
                        onChanged: (value) {
                          setState(() => _notificationSound = value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 38),
                  _SettingsGroup(
                    children: [
                      _SettingsSwitchRow(
                        label: 'Cloud sync',
                        value: _cloudSync,
                        onChanged: (value) {
                          setState(() => _cloudSync = value);
                        },
                      ),
                      _SettingsActionRow(
                        label: 'Key management',
                        onTap: () => _showComingSoon('Key management'),
                      ),
                    ],
                  ),
                  SizedBox(height: 38),
                  _SettingsGroup(
                    children: [
                      _SettingsActionRow(
                        label: 'App language',
                        trailingText: 'English',
                        onTap: () => _showComingSoon('App language'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: encryptoCardGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.encryptoColors.shadow.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) _SettingsDivider(),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.label,
    required this.onTap,
    this.trailingText,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? trailingText;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppColors.error.withValues(alpha: 0.92)
        : context.encryptoColors.textPrimary.withValues(alpha: 0.92);

    return _SettingsRowShell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: _SettingsLabel(label, color: color)),
          if (trailingText case final value?) ...[
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.48,
                ),
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            SizedBox(width: 8),
          ],
          Icon(
            destructive ? Icons.logout_rounded : Icons.chevron_right_rounded,
            color: destructive
                ? AppColors.error.withValues(alpha: 0.82)
                : context.encryptoColors.textPrimary.withValues(alpha: 0.46),
            size: destructive ? 20 : 24,
          ),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsRowShell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Expanded(child: _SettingsLabel(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: context.encryptoColors.textPrimary.withValues(
              alpha: 0.80,
            ),
            inactiveTrackColor: context.encryptoColors.textPrimary.withValues(
              alpha: 0.15,
            ),
            trackOutlineColor: WidgetStatePropertyAll(
              context.encryptoColors.textPrimary.withValues(alpha: 0.14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRowShell extends StatelessWidget {
  const _SettingsRowShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 56),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SettingsLabel extends StatelessWidget {
  const _SettingsLabel(this.label, {this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color:
            color ?? context.encryptoColors.textPrimary.withValues(alpha: 0.92),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 22,
      color: context.encryptoColors.textPrimary.withValues(alpha: 0.20),
    );
  }
}
