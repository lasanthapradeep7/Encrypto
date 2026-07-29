// ignore_for_file: unused_field

// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_state_message.dart';
import 'package:encrypto/services/api_service.dart';
import 'security_details_page.dart';
import 'package:encrypto/services/session_service.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({
    super.key,
    required this.onOpenWorkflow,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _fetchIntruderIncidents();
  }

  Future<void> _fetchIntruderIncidents() async {
    try {
      debugPrint('NEW SECURITY PAGE CODE IS RUNNING');
      final result = await ApiService.getSecurityIncidents();

      if (result['status'] != 200) {
        throw Exception(
          result['body']?['detail'] ?? 'Failed to load incidents',
        );
      }

      final rawIncidents = (result['body']?['incidents'] as List?) ?? [];

      debugPrint(rawIncidents.toString());

      if (!mounted) return;

      setState(() {
        _incidents = rawIncidents
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          onNotificationsPressed: widget.onOpenNotifications,
          onSettingsPressed: widget.onOpenSettings,
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
                        child: Icon(Icons.shield_outlined, size: 22),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Intruder Alert',
                              style: textTheme.titleLarge?.copyWith(
                                color: context.encryptoColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            Text(
                              'Review failed access attempts',
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
                      _RiskBadge(),
                    ],
                  ),
                  SizedBox(height: 20),
                  EncryptionSurfaceCard(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _AlertIcon(),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_incidents.length} attempts blocked',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: context.encryptoColors.textPrimary,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  Text(
                                    'Last attempt detected 2 min ago',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.52,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _SectionTitle('Intruder Photos'),
                        SizedBox(height: 12),
                        _IntruderPhotoStrip(incidents: _incidents),
                        if (_incidents.isNotEmpty) ...[
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppGradients.accentHorizontal,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppShadows.accent,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SecurityDetailsPage(
                                        incidents: _incidents,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.visibility_outlined),
                                label: Text('More Details'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  textStyle: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  _SectionTitle('Failed Login Attempts'),
                  SizedBox(height: 12),
                  _LoginAttemptList(incidents: _incidents),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.34)),
      ),
      child: Text(
        'High risk',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.warning,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _AlertIcon extends StatelessWidget {
  const _AlertIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: AppGradients.accentHorizontal,
        borderRadius: BorderRadius.circular(15),
        boxShadow: AppShadows.accent,
      ),
      child: Icon(Icons.gpp_maybe_outlined, color: Colors.white, size: 24),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: context.encryptoColors.textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _IntruderPhotoStrip extends StatelessWidget {
  const _IntruderPhotoStrip({required this.incidents});

  final List<Map<String, dynamic>> incidents;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return EncryptionStateMessage(
        icon: Icons.no_photography_outlined,
        title: 'No intruder photos',
        message: 'Captured photos from blocked attempts will appear here.',
        compact: true,
        showSurface: false,
        accentColor: AppColors.success,
      );
    }

    return SizedBox(
      height: 148,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        children: [
          for (var index = 0; index < incidents.length; index++) ...[
            _IntruderNetworkPhotoCard(incident: incidents[index]),
            if (index != incidents.length - 1) SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

class _IntruderPhotoCard extends StatelessWidget {
  const _IntruderPhotoCard({
    required this.initials,
    required this.icon,
    required this.gradient,
    required this.accent,
  });

  final String initials;
  final IconData icon;
  final Gradient gradient;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: context.encryptoColors.shadow.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -16,
            child: Icon(
              icon,
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.48),
              size: 136,
            ),
          ),
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.encryptoColors.shadow.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accent.withValues(alpha: 0.42)),
              ),
              child: Text(
                initials,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.encryptoColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    context.encryptoColors.shadow.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 12,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Captured',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.encryptoColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntruderNetworkPhotoCard extends StatelessWidget {
  const _IntruderNetworkPhotoCard({required this.incident});

  final Map<String, dynamic> incident;

  @override
  Widget build(BuildContext context) {
    final incidentId = incident['id'];

    final imageUrl = ApiService.securityIncidentImageUrl(incidentId);

    return Container(
      width: 146,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.14),
        ),
      ),
      child: FutureBuilder<String?>(
        future: SessionService.getAccessToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final token = snapshot.data;

          if (token == null || token.isEmpty) {
            return Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: context.encryptoColors.textSecondary,
              ),
            );
          }

          return Image.network(
            imageUrl,
            headers: {'Authorization': 'Bearer $token'},
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: context.encryptoColors.textSecondary,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LoginAttemptList extends StatelessWidget {
  const _LoginAttemptList({required this.incidents});

  final List<Map<String, dynamic>> incidents;

  @override
  Widget build(BuildContext context) {
    if (incidents.isEmpty) {
      return EncryptionStateMessage(
        icon: Icons.verified_user_outlined,
        title: 'No failed login attempts',
        message: 'Your vault has no blocked access attempts.',
        compact: true,
        accentColor: AppColors.success,
      );
    }

    final attempts = incidents.map((incident) {
      final incidentType = (incident['incident_type'] ?? '')
          .toString()
          .toLowerCase();

      final method = incidentType.contains('biometric') ? 'Biometric' : 'PIN';

      final createdAt = DateTime.tryParse(
        (incident['created_at'] ?? '').toString(),
      )?.toLocal();

      final date = createdAt == null
          ? 'Unknown date'
          : '${createdAt.day.toString().padLeft(2, '0')}/'
                '${createdAt.month.toString().padLeft(2, '0')}/'
                '${createdAt.year}';

      final time = createdAt == null
          ? 'Unknown time'
          : '${createdAt.hour.toString().padLeft(2, '0')}:'
                '${createdAt.minute.toString().padLeft(2, '0')}';

      return _LoginAttempt(date: date, time: time, method: method);
    }).toList();

    return Column(
      children: [
        for (var index = 0; index < attempts.length; index++) ...[
          _LoginAttemptTile(attempt: attempts[index]),
          if (index != attempts.length - 1) SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _LoginAttempt {
  _LoginAttempt({required this.date, required this.time, required this.method});

  final String date;
  final String time;
  final String method;
}

class _LoginAttemptTile extends StatelessWidget {
  const _LoginAttemptTile({required this.attempt});

  final _LoginAttempt attempt;

  Color get _methodColor {
    return attempt.method == 'PIN' ? AppColors.warning : AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(minHeight: 58),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: encryptoCardGradient(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _methodColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              attempt.method == 'PIN'
                  ? Icons.pin_outlined
                  : Icons.fingerprint_rounded,
              color: _methodColor,
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  attempt.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.encryptoColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  attempt.time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.54,
                    ),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          _MethodBadge(label: attempt.method, color: _methodColor),
        ],
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 78),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
