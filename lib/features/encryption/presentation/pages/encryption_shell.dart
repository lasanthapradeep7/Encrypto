import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/pages/encrypt_home_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/encryption_feature_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/notifications_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/profile_page.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/pages/security_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/settings_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/vault_home_page.dart';
import 'package:encrypto/services/api_service.dart';
import 'package:encrypto/services/session_service.dart';

class EncryptionShell extends StatefulWidget {
  const EncryptionShell({super.key});

  @override
  State<EncryptionShell> createState() => _EncryptionShellState();
}

class _EncryptionShellState extends State<EncryptionShell> {
  int _selectedIndex = 0;
  int _utilityReturnIndex = 0;
  int _workflowReturnIndex = 1;
  EncryptionMode _workflowMode = EncryptionMode.encrypt;
  int _workflowResetToken = 0;
  int _vaultRefreshToken = 0;

  bool _checkingSecurityAlert = false;

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkForSecurityAlert();
  });
}

  bool get _isPrimaryTab => _selectedIndex <= 3;

  Future<void> _checkForSecurityAlert() async {
  if (_checkingSecurityAlert) return;

  _checkingSecurityAlert = true;

  try {
    final result = await ApiService.getSecurityIncidents();

    if (!mounted || result['status'] != 200) {
      return;
    }

    final body = result['body'];

    if (body is! Map<String, dynamic>) {
      return;
    }

    final incidents = body['incidents'];

    if (incidents is! List || incidents.isEmpty) {
      return;
    }

    final latestIncident = Map<String, dynamic>.from(
      incidents.first as Map,
    );

    final latestIncidentId = int.tryParse(
      latestIncident['id'].toString(),
    );

    if (latestIncidentId == null) {
      return;
    }

    final rawCreatedAt =
    latestIncident['created_at']?.toString();

final securityWindowStartedAt =
    SessionService.getSecurityWindowStartedAt();

if (rawCreatedAt != null &&
    securityWindowStartedAt != null) {
  final hasTimezone = RegExp(
    r'(Z|[+-]\d{2}:\d{2})$',
  ).hasMatch(rawCreatedAt);

  final incidentTime = DateTime.tryParse(
    hasTimezone ? rawCreatedAt : '${rawCreatedAt}Z',
  )?.toLocal();

  if (incidentTime == null ||
      incidentTime.isBefore(securityWindowStartedAt)) {
    await SessionService.saveLastSeenSecurityIncidentId(
      latestIncidentId,
    );
    return;
  }
}

    final lastSeenIncidentId =
        await SessionService.getLastSeenSecurityIncidentId();

    if (!mounted) return;

    if (lastSeenIncidentId != null &&
        latestIncidentId <= lastSeenIncidentId) {
      return;
    }

    await SessionService.saveLastSeenSecurityIncidentId(
  latestIncidentId,
);

if (!mounted) return;

await _showSecurityAlert(
  incident: latestIncident,
  incidentId: latestIncidentId,
);
  } catch (error) {
    debugPrint('Security alert check failed: $error');
  } finally {
    _checkingSecurityAlert = false;
  }
}

Future<void> _showSecurityAlert({
  required Map<String, dynamic> incident,
  required int incidentId,
}) async {
  final reason =
      incident['reason']?.toString() ??
      'An unauthorized login attempt was detected.';

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: AppColors.backgroundStart,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.redAccent.withValues(alpha: 0.45),
            ),
          ),
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
            size: 48,
          ),
          title: const Text(
            'Unauthorized Access Detected',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Someone attempted to access your account.\n\n'
            '$reason\n\n'
            'A security photo and attempt details were recorded.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.45,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _selectTab(2);
              },
              icon: const Icon(Icons.security_rounded),
              label: const Text('View Security'),
            ),
          ],
        ),
      );
    },
  );
}

 void _selectTab(int index) {
  setState(() {
    if (index == 0) {
      _vaultRefreshToken++;
    }

    _selectedIndex = index;
  });
}

  void _openWorkflow(EncryptionMode mode, {int returnIndex = 1}) {
    setState(() {
      _workflowMode = mode;
      _workflowReturnIndex = returnIndex;
      _workflowResetToken++;
      _selectedIndex = 6;
    });
  }

  void _openUtilityPage(int index) {
    setState(() {
      _utilityReturnIndex = _selectedIndex;
      _selectedIndex = index;
    });
  }
void _closeUtilityPage() {
  _selectTab(_utilityReturnIndex);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundStart,
      extendBody: true,
      body: Stack(
        children: [
          const _Backdrop(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      VaultHomePage(
                        key: ValueKey<int>(
                          _vaultRefreshToken,
                        ),
                        onOpenWorkflow: () =>
                            _openWorkflow(
                              EncryptionMode.encrypt,
                            ),
                        onOpenSteganographyWorkflow: () =>
                            _openWorkflow(EncryptionMode.steganography),
                        onOpenProfile: () => _selectTab(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                      EncryptHomePage(
                        onEncryptTap: () =>
                            _openWorkflow(EncryptionMode.encrypt),
                        onDecryptTap: () =>
                            _openWorkflow(EncryptionMode.decrypt),
                        onSteganographyTap: () =>
                            _openWorkflow(EncryptionMode.steganography),
                        onOpenProfile: () => _selectTab(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                      SecurityPage(
                        onOpenWorkflow: () => _openWorkflow(
                          EncryptionMode.decrypt,
                          returnIndex: 2,
                        ),
                        onOpenProfile: () => _selectTab(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                      const ProfilePage(showBackButton: false),
                      NotificationsPage(onBackPressed: _closeUtilityPage),
                      SettingsPage(onBackPressed: _closeUtilityPage),
                      EncryptionFeaturePage(
                        key: ValueKey<int>(_workflowResetToken),
                        mode: _workflowMode,
                        onBackPressed: () => _selectTab(_workflowReturnIndex),
                        onOpenProfile: () => _selectTab(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                    ],
                  ),
                ),
                if (_isPrimaryTab)
                  EncryptionBottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onItemSelected: _selectTab,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050608), Color(0xFF0B0B0D)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
