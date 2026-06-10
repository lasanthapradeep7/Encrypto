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

  bool get _isPrimaryTab => _selectedIndex <= 3;

  void _selectTab(int index) {
    setState(() {
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
    setState(() {
      _selectedIndex = _utilityReturnIndex;
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
