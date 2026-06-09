import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Lasantha Pradee');
  final _emailController = TextEditingController(text: 'lasantha@example.com');
  final _roleController = TextEditingController(text: 'Vault owner');
  bool _biometricUnlock = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: EncryptionContentContainer(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PageHeader(
                      icon: Icons.person_outline_rounded,
                      title: 'Profile',
                      subtitle: 'Manage your identity and account access',
                    ),
                    const SizedBox(height: 20),
                    EncryptionSurfaceCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: AppGradients.accentHorizontal,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppShadows.accent,
                                ),
                                child: Text(
                                  'LP',
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Primary account',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last verified today',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.58,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _ProfileField(
                            controller: _nameController,
                            label: 'Display name',
                            icon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.trim().length < 2) {
                                return 'Enter a valid display name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _ProfileField(
                            controller: _emailController,
                            label: 'Email address',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (!email.contains('@') ||
                                  !email.contains('.')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _ProfileField(
                            controller: _roleController,
                            label: 'Account role',
                            icon: Icons.verified_user_outlined,
                          ),
                          const SizedBox(height: 16),
                          _SwitchRow(
                            icon: Icons.fingerprint_rounded,
                            label: 'Biometric unlock',
                            subtitle: 'Allow quick profile verification',
                            value: _biometricUnlock,
                            onChanged: (value) {
                              setState(() => _biometricUnlock = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    EncryptionSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account health',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _HealthItem(
                            icon: Icons.lock_clock_rounded,
                            label: 'Master key age',
                            value: '18 days',
                            color: Color(0xFF60A5FA),
                          ),
                          const SizedBox(height: 10),
                          const _HealthItem(
                            icon: Icons.devices_rounded,
                            label: 'Trusted devices',
                            value: '3 active',
                            color: Color(0xFF34D399),
                          ),
                          const SizedBox(height: 10),
                          const _HealthItem(
                            icon: Icons.cloud_done_rounded,
                            label: 'Recovery backup',
                            value: 'Synced',
                            color: Color(0xFFA78BFA),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppGradients.accentHorizontal,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.accent,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              AppGradients.accentHorizontal.createShader(bounds),
          child: Icon(icon, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.62)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.56),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
        border: _inputBorder(Colors.white.withValues(alpha: 0.14)),
        enabledBorder: _inputBorder(Colors.white.withValues(alpha: 0.14)),
        focusedBorder: _inputBorder(AppColors.accent, width: 1.8),
        errorBorder: _inputBorder(AppColors.error, width: 1.4),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.8),
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.52),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.accent,
        ),
      ],
    );
  }
}

class _HealthItem extends StatelessWidget {
  const _HealthItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
