import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

/// A consistent message for empty, loading, and error states on encryption pages.
class EncryptionStateMessage extends StatelessWidget {
  const EncryptionStateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.showProgress = false,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    this.showSurface = true,
    this.accentColor = AppColors.accent,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction must be supplied together.',
       );

  final IconData icon;
  final String title;
  final String message;
  final bool showProgress;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  final bool showSurface;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: compact ? 20 : 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 48 : 56,
            height: compact ? 48 : 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.28)),
            ),
            child: showProgress
                ? SizedBox(
                    width: compact ? 20 : 24,
                    height: compact ? 20 : 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: accentColor,
                    ),
                  )
                : Icon(icon, color: accentColor, size: compact ? 23 : 26),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: context.encryptoColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.58),
              height: 1.4,
            ),
          ),
          if (actionLabel != null) ...[
            SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );

    if (!showSurface) {
      return content;
    }

    return EncryptionSurfaceCard(padding: EdgeInsets.zero, child: content);
  }
}
