import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/pages/encryption_feature_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/notifications_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/profile_page.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/pages/security_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/settings_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/vault_home_page.dart';

class EncryptionShell extends StatefulWidget {
  const EncryptionShell({super.key});

  @override
  State<EncryptionShell> createState() => _EncryptionShellState();
}

class _EncryptionShellState extends State<EncryptionShell> {
  int _selectedIndex = 0;
  int _lastPrimaryIndex = 0;
  EncryptionMode _workflowMode = EncryptionMode.encrypt;
  int _workflowResetToken = 0;

  bool get _isPrimaryTab => _selectedIndex <= 2;

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _lastPrimaryIndex = index;
    });
  }

  void _openWorkflow(EncryptionMode mode) {
    setState(() {
      _workflowMode = mode;
      _workflowResetToken++;
      _selectedIndex = 1;
      _lastPrimaryIndex = 1;
    });
  }

  void _openUtilityPage(int index) {
    setState(() {
      if (_isPrimaryTab) {
        _lastPrimaryIndex = _selectedIndex;
      }
      _selectedIndex = index;
    });
  }

  void _closeUtilityPage() {
    setState(() {
      _selectedIndex = _lastPrimaryIndex;
    });
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
                        onOpenWorkflow: () =>
                            _openWorkflow(EncryptionMode.encrypt),
                        onOpenSteganographyWorkflow: () =>
                            _openWorkflow(EncryptionMode.steganography),
                        onOpenProfile: () => _openUtilityPage(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                      EncryptionFeaturePage(
                        key: ValueKey<int>(_workflowResetToken),
                        mode: _workflowMode,
                        onBackPressed: () => _selectTab(0),
                        onOpenProfile: () => _openUtilityPage(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                      SecurityPage(
                        onOpenWorkflow: () =>
                            _openWorkflow(EncryptionMode.decrypt),
                        onOpenProfile: () => _openUtilityPage(3),
                        onOpenNotifications: () => _openUtilityPage(4),
                        onOpenSettings: () => _openUtilityPage(5),
                      ),
                      ProfilePage(onBackPressed: _closeUtilityPage),
                      NotificationsPage(onBackPressed: _closeUtilityPage),
                      SettingsPage(onBackPressed: _closeUtilityPage),
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
