import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/widgets/profile_dialogs.dart';
import 'package:encrypto/features/encryption/presentation/pages/help_center_page.dart';
import 'package:encrypto/services/session_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.onBackPressed,
    this.onNotificationsPressed,
    this.onSettingsPressed,
    this.showBackButton = true,
  });

  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationsPressed;
  final VoidCallback? onSettingsPressed;
  final bool showBackButton;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _cloudSync = false;
  //User details
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final email = await SessionService.getUserEmail();
    final savedName = await SessionService.getUserName();

    if (!mounted) return;

    final emailValue = email ?? '';
    final emailName = emailValue.split('@').first;

    final formattedName = emailName
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');

    setState(() {
      _userEmail = emailValue.isEmpty ? 'No email available' : emailValue;
      _userName = savedName?.trim().isNotEmpty == true
          ? savedName!.trim()
          : (formattedName.isEmpty ? 'Vault User' : formattedName);
    });
  }

  Future<void> _editProfile() async {
    final updated = await showEditProfileDialog(
      context: context,
      initialName: _userName,
      initialEmail: _userEmail,
    );
    if (!updated || !mounted) return;
    await _loadUserProfile();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated successfully.')));
    }
  }

  Future<void> _changePassword() async {
    final changed = await showChangePasswordDialog(context);
    if (changed && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password changed successfully.')));
    }
  }

  void _showComingSoon(String label) {
    final messages = <String, String>{
      'Edit Profile':
          'Profile editing options are available from this section.',
      'Change password':
          'Password changes require current password verification.',
      'Language': 'English is currently selected as the application language.',
      'Invite Friends':
          'Share Encrypto with friends and help them protect their files.',
    };

    showDialog<void>(
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
          title: Text(
            label,
            style: TextStyle(
              color: context.encryptoColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            messages[label] ?? '$label is available in a future update.',
            style: TextStyle(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          showBackButton: widget.showBackButton,
          onBackPressed: widget.onBackPressed,
          onNotificationsPressed: widget.onNotificationsPressed,
          onSettingsPressed: widget.onSettingsPressed,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'User Profile',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: context.encryptoColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 22),
                  _ProfileHero(name: _userName, email: _userEmail),
                  SizedBox(height: 28),
                  Text(
                    'Personal Information',
                    style: textTheme.titleMedium?.copyWith(
                      color: context.encryptoColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 14),
                  _ProfileMenuGroup(
                    children: [
                      _ProfileActionTile(
                        icon: Icons.manage_accounts_outlined,
                        label: 'Edit Profile',
                        onTap: _editProfile,
                      ),
                      _ProfileActionTile(
                        icon: Icons.password_rounded,
                        label: 'Change password',
                        onTap: _changePassword,
                      ),
                      _ProfileSwitchTile(
                        icon: Icons.cloud_sync_rounded,
                        label: 'Cloud sync',
                        value: _cloudSync,
                        onChanged: (value) {
                          setState(() => _cloudSync = value);
                        },
                      ),
                      _ProfileActionTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailingText: 'English',
                        onTap: () => _showComingSoon('Language'),
                      ),
                      _ProfileActionTile(
                        icon: Icons.group_add_outlined,
                        label: 'Invite Friends',
                        onTap: () => _showComingSoon('Invite Friends'),
                      ),
                      _ProfileActionTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help Center',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HelpCenterPage(),
                            ),
                          );
                        },
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.accent,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.86)
                      : AppColors.accent.withValues(alpha: 0.32),
                  width: isDark ? 4 : 3,
                ),
                boxShadow: isDark
                    ? AppShadows.accentGlow
                    : [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.24),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
              ),
              child: Icon(Icons.person_rounded, color: Colors.white, size: 46),
            ),
            Positioned(
              right: 6,
              bottom: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.backgroundStart
                        : context.encryptoColors.background,
                    width: 3,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: context.encryptoColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 2),
        Text(
          email,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.46),
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.34)),
          ),
          child: Text(
            'Vault owner',
            style: textTheme.labelMedium?.copyWith(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.88),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuGroup extends StatelessWidget {
  const _ProfileMenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return _ProfileTileShell(
      onTap: onTap,
      child: Row(
        children: [
          _TileIcon(icon: icon),
          SizedBox(width: 12),
          Expanded(child: _TileLabel(label)),
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
            Icons.chevron_right_rounded,
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.56),
            size: 26,
          ),
        ],
      ),
    );
  }
}

class _ProfileSwitchTile extends StatelessWidget {
  const _ProfileSwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ProfileTileShell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          _TileIcon(icon: icon),
          SizedBox(width: 12),
          Expanded(child: _TileLabel(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: context.encryptoColors.textPrimary.withValues(
              alpha: 0.82,
            ),
            inactiveTrackColor: context.encryptoColors.textPrimary.withValues(
              alpha: 0.16,
            ),
            trackOutlineColor: WidgetStatePropertyAll(
              context.encryptoColors.textPrimary.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTileShell extends StatelessWidget {
  const _ProfileTileShell({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: encryptoCardGradient(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 58),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) =>
          AppGradients.accentHorizontal.createShader(bounds),
      child: Icon(icon, size: 22),
    );
  }
}

class _TileLabel extends StatelessWidget {
  const _TileLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.92),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}
