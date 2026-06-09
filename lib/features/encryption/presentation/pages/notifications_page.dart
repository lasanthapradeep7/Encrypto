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
  final List<_NotificationItem> _newItems = [
    _NotificationItem(
      icon: Icons.description_rounded,
      title: 'Encryption complete',
      body: 'File "document.pdf" was encrypted using AES-256.',
      time: '2 min ago',
      color: AppColors.accent,
      unread: true,
      hasActions: true,
    ),
    _NotificationItem(
      icon: Icons.image_rounded,
      title: 'Steganography encryption done',
      body: 'Hidden data successfully extracted from an image.',
      time: '12 min ago',
      color: const Color(0xFFA78BFA),
      unread: true,
      hasActions: true,
    ),
    _NotificationItem(
      icon: Icons.cloud_off_rounded,
      title: 'Cloud sync failed',
      body: 'Unable to upload data to cloud storage.',
      time: '12 min ago',
      color: AppColors.warning,
      unread: true,
      hasActions: true,
    ),
  ];

  final List<_NotificationItem> _todayItems = [
    _NotificationItem(
      icon: Icons.fingerprint_rounded,
      title: 'Intruder alert: Failed biometric attempt',
      body: 'An intruder alert was triggered due to failed facematch.',
      time: '25/03/2026',
      color: AppColors.error,
    ),
    _NotificationItem(
      icon: Icons.key_rounded,
      title: 'Key rotation reminder',
      body: 'Remember to rotate your encryption key regularly.',
      time: '24/03/2026',
      color: AppColors.accent,
    ),
    _NotificationItem(
      icon: Icons.fingerprint_rounded,
      title: 'Intruder alert: Failed biometric attempt',
      body: 'An intruder alert was triggered due to failed facematch.',
      time: '24/03/2026',
      color: AppColors.error,
    ),
  ];

  int get _unreadCount =>
      [..._newItems, ..._todayItems].where((item) => item.unread).length;

  void _markRead(_NotificationItem item) {
    setState(() => item.unread = false);
  }

  void _mute(_NotificationItem item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.title} muted')));
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
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              'Security updates and vault activity',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _UnreadBadge(count: _unreadCount),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _NotificationSection(
                    title: 'New',
                    items: _newItems,
                    onMarkRead: _markRead,
                    onMute: _mute,
                  ),
                  const SizedBox(height: 18),
                  _NotificationSection(
                    title: 'Today',
                    items: _todayItems,
                    onMarkRead: _markRead,
                    onMute: _mute,
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
    this.hasActions = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;
  final bool hasActions;
  bool unread;
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.34)),
      ),
      child: Text(
        '$count new',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.title,
    required this.items,
    required this.onMarkRead,
    required this.onMute,
  });

  final String title;
  final List<_NotificationItem> items;
  final ValueChanged<_NotificationItem> onMarkRead;
  final ValueChanged<_NotificationItem> onMute;

  @override
  Widget build(BuildContext context) {
    return EncryptionSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Text(
                '${items.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < items.length; index++) ...[
            _NotificationTile(
              item: items[index],
              onMarkRead: () => onMarkRead(items[index]),
              onMute: () => onMute(items[index]),
            ),
            if (index != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onMarkRead,
    required this.onMute,
  });

  final _NotificationItem item;
  final VoidCallback onMarkRead;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.unread ? onMarkRead : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.unread
                ? Colors.white.withValues(alpha: 0.09)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.unread
                  ? item.color.withValues(alpha: 0.34)
                  : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(item: item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        if (item.unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.56),
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    item.hasActions
                        ? _NotificationActions(
                            item: item,
                            onMarkRead: onMarkRead,
                            onMute: onMute,
                          )
                        : _NotificationTime(time: item.time),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.34)),
      ),
      child: Icon(item.icon, color: item.color, size: 20),
    );
  }
}

class _NotificationActions extends StatelessWidget {
  const _NotificationActions({
    required this.item,
    required this.onMarkRead,
    required this.onMute,
  });

  final _NotificationItem item;
  final VoidCallback onMarkRead;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionChipButton(
          label: item.unread ? 'Mark read' : 'Read',
          onTap: item.unread ? onMarkRead : null,
        ),
        const SizedBox(width: 8),
        _ActionChipButton(label: 'Mute', onTap: onMute),
        const Spacer(),
        _NotificationTime(time: item.time),
      ],
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: enabled ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.12 : 0.06),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: enabled ? 0.82 : 0.36),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _NotificationTime extends StatelessWidget {
  const _NotificationTime({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.46),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}
