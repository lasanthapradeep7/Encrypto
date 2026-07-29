// ignore_for_file: unused_field

import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_state_message.dart';
import 'package:encrypto/services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _newItems = [];
  final List<_NotificationItem> _todayItems = [];

  bool _loadingNotifications = true;
  String? _notificationError;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await ApiService.getSecurityIncidents();

      if (!mounted) return;

      if (result['status'] != 200 || result['body'] is! Map) {
        setState(() {
          _loadingNotifications = false;
          _notificationError = 'Unable to load notifications';
        });
        return;
      }

      final body = Map<String, dynamic>.from(result['body'] as Map);

      final rawIncidents = body['incidents'];

      final incidents = rawIncidents is List
          ? rawIncidents
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList()
          : <Map<String, dynamic>>[];

      final notificationItems = <_NotificationItem>[];

      for (var index = 0; index < incidents.length; index++) {
        notificationItems.add(
          _notificationFromIncident(incidents[index], unread: index < 3),
        );
      }

      setState(() {
        _newItems
          ..clear()
          ..addAll(notificationItems.take(3));

        _todayItems
          ..clear()
          ..addAll(notificationItems.skip(3));

        _loadingNotifications = false;
        _notificationError = null;
      });
    } catch (error) {
      debugPrint('Notifications loading failed: $error');

      if (!mounted) return;

      setState(() {
        _loadingNotifications = false;
        _notificationError = 'Unable to load notifications';
      });
    }
  }

  _NotificationItem _notificationFromIncident(
    Map<String, dynamic> incident, {
    required bool unread,
  }) {
    final incidentType =
        incident['incident_type']?.toString().toLowerCase() ?? '';

    final isBiometric = incidentType.contains('biometric');

    final reason =
        incident['reason']?.toString() ??
        'Unauthorized access attempt detected';

    return _NotificationItem(
      icon: isBiometric
          ? Icons.fingerprint_rounded
          : Icons.warning_amber_rounded,
      title: isBiometric
          ? 'Intruder alert: Biometric attempt'
          : 'Intruder alert: Failed login attempt',
      body: reason,
      time: _formatIncidentTime(incident['created_at']?.toString()),
      color: AppColors.error,
      unread: unread,
      hasActions: true,
    );
  }

  String _formatIncidentTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return 'Unknown date';
    }

    final dateTime = DateTime.tryParse(rawDate)?.toLocal();

    if (dateTime == null) {
      return rawDate;
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year}  $hour:$minute';
  }

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
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) =>
                            AppGradients.accentHorizontal.createShader(bounds),
                        child: Icon(Icons.notifications_none_rounded, size: 22),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: textTheme.titleLarge?.copyWith(
                                color: context.encryptoColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              'Security updates and vault activity',
                              style: textTheme.bodySmall?.copyWith(
                                color: context.encryptoColors.textPrimary
                                    .withValues(alpha: 0.58),
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
                  SizedBox(height: 20),
                  if (_loadingNotifications)
                    EncryptionStateMessage(
                      icon: Icons.sync_rounded,
                      title: 'Loading notifications',
                      message: 'Checking for your latest security updates.',
                      showProgress: true,
                    )
                  else if (_notificationError != null)
                    EncryptionStateMessage(
                      icon: Icons.cloud_off_rounded,
                      title: 'Couldn’t load notifications',
                      message: 'Check your connection and try again.',
                      actionLabel: 'Try again',
                      onAction: _loadNotifications,
                    )
                  else if (_newItems.isEmpty && _todayItems.isEmpty)
                    EncryptionStateMessage(
                      icon: Icons.notifications_none_rounded,
                      title: 'You’re all caught up',
                      message:
                          'Security alerts and vault activity will appear here.',
                    )
                  else ...[
                    _NotificationSection(
                      title: 'New',
                      items: _newItems,
                      onMarkRead: _markRead,
                      onMute: _mute,
                    ),
                    if (_todayItems.isNotEmpty) ...[
                      SizedBox(height: 18),
                      _NotificationSection(
                        title: 'Earlier',
                        items: _todayItems,
                        onMarkRead: _markRead,
                        onMute: _mute,
                      ),
                    ],
                  ],
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.encryptoColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              Spacer(),
              Text(
                '${items.length}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.48,
                  ),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          for (var index = 0; index < items.length; index++) ...[
            _NotificationTile(
              item: items[index],
              onMarkRead: () => onMarkRead(items[index]),
              onMute: () => onMute(items[index]),
            ),
            if (index != items.length - 1) SizedBox(height: 10),
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
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.unread
                ? context.encryptoColors.textPrimary.withValues(alpha: 0.09)
                : context.encryptoColors.textPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.unread
                  ? item.color.withValues(alpha: 0.34)
                  : context.encryptoColors.textPrimary.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(item: item),
              SizedBox(width: 12),
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
                              color: context.encryptoColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        if (item.unread) ...[
                          SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: context.encryptoColors.textPrimary.withValues(
                          alpha: 0.56,
                        ),
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 10),
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
        SizedBox(width: 8),
        _ActionChipButton(label: 'Mute', onTap: onMute),
        Spacer(),
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
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: context.encryptoColors.textPrimary.withValues(
            alpha: enabled ? 0.08 : 0.04,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: context.encryptoColors.textPrimary.withValues(
              alpha: enabled ? 0.12 : 0.06,
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.encryptoColors.textPrimary.withValues(
              alpha: enabled ? 0.82 : 0.36,
            ),
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
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.46),
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}
