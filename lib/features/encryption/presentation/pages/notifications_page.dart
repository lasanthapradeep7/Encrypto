import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _items = [
    _NotificationItem(
      icon: Icons.lock_open_rounded,
      title: 'Vault unlocked',
      body: 'A trusted biometric session was started on this device.',
      time: '2 min ago',
      color: AppColors.success,
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.cloud_sync_rounded,
      title: 'Manual sync completed',
      body: '18 encrypted files were verified against cloud backup.',
      time: '26 min ago',
      color: AppColors.accent,
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.key_rounded,
      title: 'Key rotation reminder',
      body: 'Your next master key rotation is scheduled for Friday.',
      time: 'Yesterday',
      color: AppColors.warning,
    ),
    _NotificationItem(
      icon: Icons.devices_rounded,
      title: 'Trusted device added',
      body: 'Windows workstation was approved for vault access.',
      time: 'May 28',
      color: const Color(0xFFA78BFA),
    ),
  ];

  bool _securityAlerts = true;
  bool _workflowUpdates = true;

  int get _unreadCount => _items.where((item) => item.unread).length;

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.unread = false;
      }
    });
  }

  void _toggleRead(_NotificationItem item) {
    setState(() => item.unread = !item.unread);
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
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) =>
                            AppGradients.accentHorizontal.createShader(bounds),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '$_unreadCount unread security updates',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _unreadCount == 0 ? null : _markAllRead,
                        child: const Text('Mark read'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  EncryptionSurfaceCard(
                    child: Column(
                      children: [
                        _PreferenceSwitch(
                          label: 'Security alerts',
                          subtitle: 'Sign-ins, keys and trusted devices',
                          value: _securityAlerts,
                          onChanged: (value) {
                            setState(() => _securityAlerts = value);
                          },
                        ),
                        Divider(
                          height: 22,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        _PreferenceSwitch(
                          label: 'Workflow updates',
                          subtitle: 'Encryption, decryption and sync progress',
                          value: _workflowUpdates,
                          onChanged: (value) {
                            setState(() => _workflowUpdates = value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NotificationTile(
                        item: item,
                        onTap: () => _toggleRead(item),
                      ),
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

class _NotificationItem {
  _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
    this.unread = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  bool unread;
}

class _PreferenceSwitch extends StatelessWidget {
  const _PreferenceSwitch({
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.unread
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.unread
                ? item.color.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (item.unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.time,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.42),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
