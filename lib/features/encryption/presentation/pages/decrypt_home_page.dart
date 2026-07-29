import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

class DecryptHomePage extends StatelessWidget {
  const DecryptHomePage({
    super.key,
    required this.onBackPressed,
    required this.onOpenDecryptFlow,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onOpenDecryptFlow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(showBackButton: true, onBackPressed: onBackPressed),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Decrypt files',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: context.encryptoColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 26),
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.12,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_open_rounded,
                      size: 84,
                      color: context.encryptoColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Text(
                  'Upload an encrypted file and restore it securely.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.84,
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.06,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      _MiniRow(label: 'Encrypted file'),
                      SizedBox(height: 12),
                      _MiniRow(label: 'Private key / password'),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onOpenDecryptFlow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Decrypt Now'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.upload_file_rounded, color: Colors.white),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.encryptoColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
