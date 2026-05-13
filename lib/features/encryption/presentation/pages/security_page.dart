import 'package:flutter/material.dart';

import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key, required this.onOpenWorkflow});

  final VoidCallback onOpenWorkflow;

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
                    'Security center',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Monitor biometric access, keys, and secure sharing policies.',
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
                          'Protection status',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _SecurityStatusRow(
                          label: 'Biometric lock',
                          value: 'Enabled',
                        ),
                        const SizedBox(height: 12),
                        const _SecurityStatusRow(
                          label: 'Cloud sync policy',
                          value: 'Manual',
                        ),
                        const SizedBox(height: 12),
                        const _SecurityStatusRow(
                          label: 'Key rotation',
                          value: 'Scheduled',
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
                          'Actions',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SecurityActionButton(
                          label: 'Open encryption workflow',
                          icon: Icons.lock_rounded,
                          onPressed: onOpenWorkflow,
                        ),
                        const SizedBox(height: 12),
                        const _SecurityActionButton(
                          label: 'Review trusted devices',
                          icon: Icons.devices_rounded,
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

class _SecurityStatusRow extends StatelessWidget {
  const _SecurityStatusRow({required this.label, required this.value});

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

class _SecurityActionButton extends StatelessWidget {
  const _SecurityActionButton({
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
