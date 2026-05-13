import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/pages/encryption_feature_page.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/pages/security_page.dart';
import 'package:encrypto/features/encryption/presentation/pages/vault_home_page.dart';

class EncryptionShell extends StatefulWidget {
  const EncryptionShell({super.key});

  @override
  State<EncryptionShell> createState() => _EncryptionShellState();
}

class _EncryptionShellState extends State<EncryptionShell> {
  int _selectedIndex = 0;
  EncryptionMode _workflowMode = EncryptionMode.encrypt;
  int _workflowResetToken = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openWorkflow(EncryptionMode mode) {
    setState(() {
      _workflowMode = mode;
      _workflowResetToken++;
      _selectedIndex = 1;
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
                      ),
                      EncryptionFeaturePage(
                        key: ValueKey<int>(_workflowResetToken),
                        mode: _workflowMode,
                        onBackPressed: () => _selectTab(0),
                      ),
                      SecurityPage(
                        onOpenWorkflow: () =>
                            _openWorkflow(EncryptionMode.decrypt),
                      ),
                    ],
                  ),
                ),
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
