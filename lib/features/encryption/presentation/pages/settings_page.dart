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
  bool _autoLock = true;
  bool _cloudBackup = false;
  bool _metadataScrub = true;
  double _autoLockMinutes = 5;
  String _encryptionMode = 'AES-256';

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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SettingsHeader(textTheme: textTheme),
                  const SizedBox(height: 20),
                  EncryptionSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          icon: Icons.security_rounded,
                          label: 'Security defaults',
                        ),
                        const SizedBox(height: 14),
                        _SettingsSwitch(
                          label: 'Auto-lock vault',
                          subtitle: 'Require re-authentication after idle time',
                          value: _autoLock,
                          onChanged: (value) {
                            setState(() => _autoLock = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        AnimatedOpacity(
                          opacity: _autoLock ? 1 : 0.42,
                          duration: const Duration(milliseconds: 180),
                          child: IgnorePointer(
                            ignoring: !_autoLock,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lock after ${_autoLockMinutes.round()} minutes',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Slider(
                                  value: _autoLockMinutes,
                                  min: 1,
                                  max: 30,
                                  divisions: 29,
                                  label: '${_autoLockMinutes.round()} min',
                                  onChanged: (value) {
                                    setState(() => _autoLockMinutes = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 24,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        _SettingsSwitch(
                          label: 'Scrub file metadata',
                          subtitle: 'Remove EXIF and document fingerprints',
                          value: _metadataScrub,
                          onChanged: (value) {
                            setState(() => _metadataScrub = value);
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
                        _SectionTitle(
                          icon: Icons.tune_rounded,
                          label: 'Encryption preferences',
                        ),
                        const SizedBox(height: 14),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'AES-256',
                              label: Text('AES-256'),
                              icon: Icon(Icons.lock_rounded),
                            ),
                            ButtonSegment<String>(
                              value: 'Hybrid',
                              label: Text('Hybrid'),
                              icon: Icon(Icons.hub_rounded),
                            ),
                          ],
                          selected: {_encryptionMode},
                          onSelectionChanged: (selection) {
                            setState(() => _encryptionMode = selection.first);
                          },
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return Colors.white.withValues(alpha: 0.62);
                            }),
                            backgroundColor: WidgetStateProperty.resolveWith((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.accent;
                              }
                              return Colors.white.withValues(alpha: 0.06);
                            }),
                            side: WidgetStatePropertyAll(
                              BorderSide(
                                color: Colors.white.withValues(alpha: 0.14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SettingsSwitch(
                          label: 'Cloud backup',
                          subtitle: 'Store encrypted recovery copies',
                          value: _cloudBackup,
                          onChanged: (value) {
                            setState(() => _cloudBackup = value);
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
                        _SectionTitle(
                          icon: Icons.info_outline_rounded,
                          label: 'Application',
                        ),
                        const SizedBox(height: 14),
                        const _SettingsDetail(label: 'Version', value: '1.0.0'),
                        const SizedBox(height: 10),
                        const _SettingsDetail(
                          label: 'Local vault policy',
                          value: 'Device-only by default',
                        ),
                      ],
                    ),
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              AppGradients.accentHorizontal.createShader(bounds),
          child: const Icon(Icons.settings_outlined, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Control vault behavior and encryption defaults',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              AppGradients.accentHorizontal.createShader(bounds),
          child: Icon(icon, size: 17),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
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

class _SettingsDetail extends StatelessWidget {
  const _SettingsDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.62),
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
