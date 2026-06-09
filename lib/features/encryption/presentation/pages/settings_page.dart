import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _biometricAuthentication = true;
  bool _notificationSound = true;
  bool _cloudSync = false;
  bool _lockScreen = true;

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming soon')));
  }

  void _logout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logout coming soon')));
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
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 34),
                  _SettingsGroup(
                    children: [
                      _SettingsActionRow(
                        label: 'Change password',
                        onTap: () => _showComingSoon('Change password'),
                      ),
                      _SettingsSwitchRow(
                        label: 'Biometric authentication',
                        value: _biometricAuthentication,
                        onChanged: (value) {
                          setState(() => _biometricAuthentication = value);
                        },
                      ),
                      _SettingsActionRow(
                        label: 'Logout',
                        destructive: true,
                        onTap: _logout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
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
                  const SizedBox(height: 38),
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
                      _SettingsActionRow(
                        label: 'Steganography',
                        onTap: () => _showComingSoon('Steganography'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  _SettingsGroup(
                    children: [
                      _SettingsSwitchRow(
                        label: 'Lock Screen',
                        value: _lockScreen,
                        onChanged: (value) {
                          setState(() => _lockScreen = value);
                        },
                      ),
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
        gradient: AppGradients.card,
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1) const _SettingsDivider(),
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
        : Colors.white.withValues(alpha: 0.92);

    return _SettingsRowShell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(child: _SettingsLabel(label, color: color)),
          if (trailingText case final value?) ...[
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.48),
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            destructive ? Icons.logout_rounded : Icons.chevron_right_rounded,
            color: destructive
                ? AppColors.error.withValues(alpha: 0.82)
                : Colors.white.withValues(alpha: 0.46),
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
            inactiveThumbColor: Colors.white.withValues(alpha: 0.80),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
            trackOutlineColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.14),
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
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
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
        color: color ?? Colors.white.withValues(alpha: 0.92),
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
      color: Colors.white.withValues(alpha: 0.20),
    );
  }
}
