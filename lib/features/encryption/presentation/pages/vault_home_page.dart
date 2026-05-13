import 'package:flutter/material.dart';

import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class VaultHomePage extends StatelessWidget {
  const VaultHomePage({
    super.key,
    required this.onOpenWorkflow,
    required this.onOpenSteganographyWorkflow,
  });

  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenSteganographyWorkflow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const EncryptoTopBar(),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Secure Vault',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage protected files, sessions, and recent activity.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  EncryptionSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vault summary',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _SummaryRow(label: 'Encrypted files', value: '24'),
                        const SizedBox(height: 12),
                        const _SummaryRow(label: 'Cloud synced', value: '18'),
                        const SizedBox(height: 12),
                        const _SummaryRow(
                          label: 'Protected sessions',
                          value: '6',
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
                          'Quick actions',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _VaultActionButton(
                          label: 'Start encryption workflow',
                          icon: Icons.play_arrow_rounded,
                          onPressed: onOpenWorkflow,
                        ),
                        const SizedBox(height: 12),
                        _VaultActionButton(
                          label: 'Open steganography',
                          icon: Icons.auto_awesome_rounded,
                          onPressed: onOpenSteganographyWorkflow,
                        ),
                        const SizedBox(height: 12),
                        const _VaultActionButton(
                          label: 'Browse recent vault items',
                          icon: Icons.folder_open_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _VaultActionButton extends StatelessWidget {
  const _VaultActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
