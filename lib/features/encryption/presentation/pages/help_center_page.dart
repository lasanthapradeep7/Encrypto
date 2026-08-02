import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/core/theme/theme_controller.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final selectedTheme = ThemeController.instance.isDark
            ? AppTheme.dark
            : AppTheme.light;

        return Theme(
          data: selectedTheme,
          child: Builder(builder: _buildPage),
        );
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.encryptoColors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.encryptoColors.background,
              context.encryptoColors.backgroundEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Go back',
                      style: IconButton.styleFrom(
                        foregroundColor: context.encryptoColors.icon,
                        backgroundColor: context.encryptoColors.surfaceRaised,
                        side: BorderSide(color: context.encryptoColors.border),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Semantics(
                    header: true,
                    child: Text(
                      'Help Center',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: context.encryptoColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how Encrypto protects, restores, and manages your files.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.encryptoColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _QuickStartCard(),
                  const SizedBox(height: 18),
                  const _SectionLabel('How Encrypto works'),
                  const SizedBox(height: 10),
                  const _HelpTopic(
                    icon: Icons.lock_rounded,
                    title: 'Encrypt a file',
                    summary: 'Turn a file into a protected encrypted copy.',
                    steps: [
                      'Open Quick actions and select Encrypt.',
                      'Choose the file you want to protect.',
                      'Select biometric, hybrid, or password protection.',
                      'Complete authentication, then download the encrypted file.',
                    ],
                    note:
                        'Keep the encrypted copy until you have confirmed that it can be decrypted.',
                  ),
                  const _HelpTopic(
                    icon: Icons.lock_open_rounded,
                    title: 'Decrypt a file',
                    summary: 'Restore a file using the same protection method.',
                    steps: [
                      'Select Decrypt and choose the encrypted file.',
                      'Choose the method used when the file was encrypted.',
                      'Authenticate with biometrics or enter the correct password.',
                      'Download the restored file and verify that it opens.',
                    ],
                    note:
                        'A biometric key is linked to the encrypted filename on this device. Renaming the file or clearing app data may prevent automatic key lookup.',
                  ),
                  const _HelpTopic(
                    icon: Icons.hide_image_rounded,
                    title: 'Hide or extract a file',
                    summary:
                        'Use steganography to place a file inside an image.',
                    steps: [
                      'To hide data, select a cover image and the file to hide.',
                      'Run the process and download the generated stego image.',
                      'To recover data, choose the extraction option and select that stego image.',
                      'Download the extracted file when processing finishes.',
                    ],
                    note:
                        'Steganography conceals that data exists; it is not a substitute for encryption. Encrypt sensitive files first.',
                  ),
                  const _HelpTopic(
                    icon: Icons.folder_special_rounded,
                    title: 'Vault and Security',
                    summary:
                        'Review recent files, protection status, and blocked access attempts.',
                    steps: [
                      'Use Vault to find recent uploaded, encrypted, or decrypted files.',
                      'Use Security to review failed access attempts and captured evidence.',
                      'Treat unfamiliar activity as a warning and change your password promptly.',
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('Protect your access'),
                  const SizedBox(height: 10),
                  const _SafetyCard(),
                  const SizedBox(height: 18),
                  const _SectionLabel('Troubleshooting'),
                  const SizedBox(height: 10),
                  const _HelpTopic(
                    icon: Icons.build_circle_outlined,
                    title: 'Common issues',
                    summary: 'Try these checks before repeating a workflow.',
                    steps: [
                      'No biometric key found: use the original encrypted filename and the same device/profile.',
                      'Wrong password or failed decryption: confirm the protection method and check for extra spaces.',
                      'Upload or processing failed: check your internet connection and try again.',
                      'No readable text detected: use a clearer, well-lit image with legible text.',
                      'Missing output: finish the workflow and tap Download before leaving the page.',
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: context.encryptoColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard();

  @override
  Widget build(BuildContext context) {
    return EncryptionSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: AppColors.accent),
              const SizedBox(width: 10),
              Text(
                'Quick start',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.encryptoColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _NumberedStep(
            number: 1,
            text: 'Choose Encrypt, Decrypt, or Stego from Quick actions.',
          ),
          const _NumberedStep(
            number: 2,
            text: 'Select the required file and protection method.',
          ),
          const _NumberedStep(
            number: 3,
            text: 'Complete processing and download the result.',
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.encryptoColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTopic extends StatelessWidget {
  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.summary,
    required this.steps,
    this.note,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> steps;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: context.encryptoColors.surfaceRaised,
          child: ExpansionTile(
            leading: Icon(icon, color: AppColors.accent),
            title: Text(
              title,
              style: TextStyle(
                color: context.encryptoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Text(
              summary,
              style: TextStyle(
                color: context.encryptoColors.textSecondary,
                height: 1.3,
              ),
            ),
            iconColor: AppColors.accent,
            collapsedIconColor: context.encryptoColors.textSecondary,
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: context.encryptoColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            collapsedShape: RoundedRectangleBorder(
              side: BorderSide(color: context.encryptoColors.border),
              borderRadius: BorderRadius.circular(18),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < steps.length; index++)
                _NumberedStep(number: index + 1, text: steps[index]),
              if (note case final value?)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.warning.withValues(alpha: 0.14)
                        : const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.34),
                    ),
                  ),
                  child: Text(
                    'Important: $value',
                    style: TextStyle(
                      color: context.encryptoColors.textPrimary,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    const tips = [
      'Use a unique password of at least 12 characters when possible.',
      'Never share passwords, generated keys, or decrypted files through untrusted channels.',
      'Back up important encrypted files and recovery information separately.',
      'Remember: losing the required key, password, or biometric access can make a file unrecoverable.',
      'Sign out on shared devices and review the Security page regularly.',
    ];
    return EncryptionSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: context.encryptoColors.textSecondary,
                        height: 1.4,
                      ),
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
