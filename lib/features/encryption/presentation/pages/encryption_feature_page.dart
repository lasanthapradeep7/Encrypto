import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

enum EncryptionMode { encrypt, decrypt, steganography }

enum _WorkflowStage { setup, processing, success }

class EncryptionFeaturePage extends StatefulWidget {
  const EncryptionFeaturePage({
    super.key,
    required this.mode,
    required this.onBackPressed,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final EncryptionMode mode;
  final VoidCallback onBackPressed;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  @override
  State<EncryptionFeaturePage> createState() => _EncryptionFeaturePageState();
}

class _EncryptionFeaturePageState extends State<EncryptionFeaturePage> {
  _WorkflowStage _stage = _WorkflowStage.setup;
  Timer? _completionTimer;
  EncryptionMode _activeMode = EncryptionMode.encrypt;

  @override
  void initState() {
    super.initState();
    _activeMode = widget.mode;
  }

  @override
  void didUpdateWidget(covariant EncryptionFeaturePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _activeMode = widget.mode;
      _resetFlow();
    }
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  void _resetFlow() {
    _completionTimer?.cancel();
    setState(() => _stage = _WorkflowStage.setup);
  }

  void _setMode(EncryptionMode mode) {
    if (_activeMode == mode) return;
    _completionTimer?.cancel();
    setState(() {
      _activeMode = mode;
      _stage = _WorkflowStage.setup;
    });
  }

  void _startWorkflow() {
    _completionTimer?.cancel();
    setState(() => _stage = _WorkflowStage.processing);

    _completionTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _stage = _WorkflowStage.success);
    });
  }

  void _cancelWorkflow() {
    _completionTimer?.cancel();
    setState(() => _stage = _WorkflowStage.setup);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EncryptoTopBar(
          showBackButton: true,
          onBackPressed: widget.onBackPressed,
          onProfilePressed: widget.onOpenProfile,
          onNotificationsPressed: widget.onOpenNotifications,
          onSettingsPressed: widget.onOpenSettings,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_stage) {
              _WorkflowStage.setup => _SetupView(
                key: const ValueKey('setup'),
                mode: _activeMode,
                onModeChanged: _setMode,
                onStartPressed: _startWorkflow,
              ),
              _WorkflowStage.processing => _ProcessingView(
                key: const ValueKey('processing'),
                mode: _activeMode,
                onCancelPressed: _cancelWorkflow,
              ),
              _WorkflowStage.success => _SuccessView(
                key: const ValueKey('success'),
                mode: _activeMode,
                onRepeatPressed: _resetFlow,
              ),
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Setup view
// ---------------------------------------------------------------------------
class _SetupView extends StatelessWidget {
  const _SetupView({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.onStartPressed,
  });

  final EncryptionMode mode;
  final ValueChanged<EncryptionMode> onModeChanged;
  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: EncryptionContentContainer(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              switch (mode) {
                EncryptionMode.encrypt => 'Encrypt & Decrypt',
                EncryptionMode.decrypt => 'Encrypt & Decrypt',
                EncryptionMode.steganography => 'Steganography',
              },
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            if (mode != EncryptionMode.steganography) ...[
              const SizedBox(height: 18),
              _SegmentedModeControl(mode: mode, onChanged: onModeChanged),
            ],
            const SizedBox(height: 22),
            switch (mode) {
              EncryptionMode.encrypt => _EncryptSetupContent(
                onStartPressed: onStartPressed,
              ),
              EncryptionMode.decrypt => _DecryptSetupContent(
                onStartPressed: onStartPressed,
              ),
              EncryptionMode.steganography => _SteganographySetupContent(
                onStartPressed: onStartPressed,
              ),
            },
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Encrypt setup
// ---------------------------------------------------------------------------
class _EncryptSetupContent extends StatelessWidget {
  const _EncryptSetupContent({required this.onStartPressed});

  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(label: 'Cover image', icon: Icons.image_outlined),
        const SizedBox(height: 10),
        const _UploadCard(
          label: 'Upload Cover Image',
          hint: 'JPG, PNG up to 20MB',
          icon: Icons.image_rounded,
        ),
        const SizedBox(height: 14),
        _SectionLabel(
          label: 'Encrypted file',
          icon: Icons.file_present_rounded,
        ),
        const SizedBox(height: 10),
        const _UploadCard(
          label: 'Upload Encrypted File',
          hint: 'Any file type',
          icon: Icons.lock_outlined,
        ),
        const SizedBox(height: 22),
        _SectionLabel(label: 'Encryption method', icon: Icons.settings_rounded),
        const SizedBox(height: 12),
        const _OptionRow(
          label: 'Biometric',
          icon: Icons.fingerprint_rounded,
          color: Color(0xFF60A5FA),
        ),
        const SizedBox(height: 8),
        const _OptionRow(
          label: 'Password',
          icon: Icons.lock_rounded,
          color: Color(0xFFA78BFA),
        ),
        const SizedBox(height: 8),
        const _OptionRow(
          label: 'Auto-generated Key',
          icon: Icons.key_rounded,
          color: Color(0xFF34D399),
        ),
        const SizedBox(height: 22),
        _GradientCTAButton(
          label: 'Start Encryption',
          onPressed: onStartPressed,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Decrypt setup
// ---------------------------------------------------------------------------
class _DecryptSetupContent extends StatefulWidget {
  const _DecryptSetupContent({required this.onStartPressed});

  final VoidCallback onStartPressed;

  @override
  State<_DecryptSetupContent> createState() => _DecryptSetupContentState();
}

class _DecryptSetupContentState extends State<_DecryptSetupContent> {
  bool _obscurePassword = true;
  bool _retrieveHiddenData = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(label: 'Select file', icon: Icons.file_present_rounded),
        const SizedBox(height: 10),
        const _UploadCard(
          label: 'Upload Encrypted File',
          hint: 'Drop your file here',
          icon: Icons.lock_outlined,
        ),
        const SizedBox(height: 18),
        _SectionLabel(label: 'Decryption key', icon: Icons.key_rounded),
        const SizedBox(height: 10),
        TextField(
          obscureText: _obscurePassword,
          style: textTheme.bodyLarge?.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter password or key',
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Warning banner
        _WarningBanner(
          text: 'After 3 wrong attempts, you will be automatically logged out.',
        ),
        const SizedBox(height: 14),
        // Checkbox for hidden data
        GestureDetector(
          onTap: () =>
              setState(() => _retrieveHiddenData = !_retrieveHiddenData),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.92,
                child: Checkbox(
                  value: _retrieveHiddenData,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _retrieveHiddenData = value);
                  },
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.accent;
                    }
                    return Colors.white.withValues(alpha: 0.1);
                  }),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
              ),
              Expanded(
                child: Text(
                  'Retrieve hidden steganography data',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _GradientCTAButton(
          label: 'Decrypt File',
          onPressed: widget.onStartPressed,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Steganography setup
// ---------------------------------------------------------------------------
class _SteganographySetupContent extends StatelessWidget {
  const _SteganographySetupContent({required this.onStartPressed});

  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(
          label: 'Hide data in image',
          icon: Icons.hide_image_rounded,
        ),
        const SizedBox(height: 10),
        const _UploadCard(
          label: 'Upload Cover Image',
          hint: 'The carrier image',
          icon: Icons.image_rounded,
        ),
        const SizedBox(height: 10),
        const _UploadCard(
          label: 'Upload Encrypted File',
          hint: 'Data to hide',
          icon: Icons.lock_outlined,
        ),
        const SizedBox(height: 18),
        _GradientCTAButton(label: 'Hide Data', onPressed: onStartPressed),
        const SizedBox(height: 22),
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Retrieve hidden data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionLabel(label: 'Stego image', icon: Icons.image_search_rounded),
        const SizedBox(height: 10),
        const _UploadCard(
          label: 'Upload Stego Image',
          hint: 'Image with hidden data',
          icon: Icons.image_search_rounded,
        ),
        const SizedBox(height: 18),
        _GradientCTAButton(label: 'Extract & Share', onPressed: onStartPressed),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Processing view
// ---------------------------------------------------------------------------
class _ProcessingView extends StatelessWidget {
  const _ProcessingView({
    super.key,
    required this.mode,
    required this.onCancelPressed,
  });

  final EncryptionMode mode;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: EncryptionContentContainer(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              switch (mode) {
                EncryptionMode.encrypt => 'Processing Encryption',
                EncryptionMode.decrypt => 'Processing Decryption',
                EncryptionMode.steganography => 'Processing Steganography',
              },
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            _AnimatedProcessingIllustration(mode: mode),
            const SizedBox(height: 20),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (b) =>
                  AppGradients.accentHorizontal.createShader(b),
              child: Text(
                '78%',
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 64,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              switch (mode) {
                EncryptionMode.encrypt => 'Encrypting file…',
                EncryptionMode.decrypt => 'Decrypting file…',
                EncryptionMode.steganography => 'Processing…',
              },
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '1.8 MB',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 26),
            EncryptionSurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ProgressStep(
                    label: 'Initializing AI key',
                    state: _StepState.done,
                  ),
                  const SizedBox(height: 10),
                  _ProgressStep(
                    label: switch (mode) {
                      EncryptionMode.encrypt => 'Applying steganography',
                      EncryptionMode.decrypt => 'Retrieving hidden data',
                      EncryptionMode.steganography => 'Applying hidden data',
                    },
                    state: _StepState.active,
                  ),
                  const SizedBox(height: 10),
                  _ProgressStep(
                    label: switch (mode) {
                      EncryptionMode.encrypt => 'Encrypting data',
                      EncryptionMode.decrypt => 'Decrypting file',
                      EncryptionMode.steganography => 'Hiding data',
                    },
                    state: _StepState.pending,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onCancelPressed,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.8),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Success view
// ---------------------------------------------------------------------------
class _SuccessView extends StatefulWidget {
  const _SuccessView({
    super.key,
    required this.mode,
    required this.onRepeatPressed,
  });

  final EncryptionMode mode;
  final VoidCallback onRepeatPressed;

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> {
  bool _alwaysUpload = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: EncryptionContentContainer(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              switch (widget.mode) {
                EncryptionMode.encrypt => 'Encryption Complete!',
                EncryptionMode.decrypt => 'Decryption Complete!',
                EncryptionMode.steganography => 'Steganography Complete!',
              },
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _AnimatedSuccessIllustration(mode: widget.mode),
            const SizedBox(height: 16),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (b) => AppGradients.success.createShader(b),
              child: Text(
                '100%',
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 64,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              switch (widget.mode) {
                EncryptionMode.encrypt => 'File successfully encrypted.',
                EncryptionMode.decrypt => 'File successfully decrypted.',
                EncryptionMode.steganography => 'Data successfully hidden.',
              },
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),
            if (widget.mode == EncryptionMode.decrypt) ...[
              EncryptionSurfaceCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF60A5FA),
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This file is private. Only download or share via secure channels.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _GradientCTAButton(
                label: 'Share File',
                icon: Icons.share_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ] else ...[
              _GradientCTAButton(
                label: 'Save File Locally',
                icon: Icons.save_alt_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              _GradientCTAButton(
                label: 'Upload to Cloud',
                icon: Icons.cloud_upload_rounded,
                gradient: AppGradients.success,
                onPressed: () {},
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _alwaysUpload,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _alwaysUpload = value);
                    },
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.accent;
                      }
                      return Colors.white.withValues(alpha: 0.1);
                    }),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  Text(
                    'Always upload to cloud',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: widget.onRepeatPressed,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Start over'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.8),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upload card — dashed border with gradient
// ---------------------------------------------------------------------------
class _UploadCard extends StatefulWidget {
  const _UploadCard({
    required this.label,
    required this.hint,
    required this.icon,
  });

  final String label;
  final String hint;
  final IconData icon;

  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _hovered ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _hovered
                ? AppColors.accent.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.2),
            radius: 18,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 86,
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.accent.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (b) =>
                      AppGradients.accentHorizontal.createShader(b),
                  child: Icon(widget.icon, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.hint,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Premium segmented control
// ---------------------------------------------------------------------------
class _SegmentedModeControl extends StatelessWidget {
  const _SegmentedModeControl({required this.mode, required this.onChanged});

  final EncryptionMode mode;
  final ValueChanged<EncryptionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _SegmentedButton(
            label: 'Encrypt',
            icon: Icons.lock_rounded,
            selected: mode == EncryptionMode.encrypt,
            onTap: () => onChanged(EncryptionMode.encrypt),
          ),
          _SegmentedButton(
            label: 'Decrypt',
            icon: Icons.lock_open_rounded,
            selected: mode == EncryptionMode.decrypt,
            onTap: () => onChanged(EncryptionMode.decrypt),
          ),
        ],
      ),
    );
  }
}

class _SegmentedButton extends StatelessWidget {
  const _SegmentedButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(4),
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.accentHorizontal : null,
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected ? AppShadows.accent : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Option row (radio select for encryption method)
// ---------------------------------------------------------------------------
class _OptionRow extends StatefulWidget {
  const _OptionRow({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  State<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<_OptionRow> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: _selected
              ? widget.color.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selected
                ? widget.color.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.10),
            width: _selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _selected
                    ? widget.color.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: 14,
                color: _selected
                    ? widget.color
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.75),
                  fontWeight: _selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selected ? widget.color : Colors.transparent,
                border: Border.all(
                  color: _selected
                      ? widget.color
                      : Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: _selected
                  ? const Icon(Icons.check, size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress step with status icons
// ---------------------------------------------------------------------------
enum _StepState { done, active, pending }

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.label, required this.state});

  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (icon, color) = switch (state) {
      _StepState.done => (Icons.check_circle_rounded, AppColors.success),
      _StepState.active => (Icons.radio_button_on_rounded, AppColors.accent),
      _StepState.pending => (
        Icons.radio_button_off_rounded,
        Colors.white.withValues(alpha: 0.3),
      ),
    };

    return Row(
      children: [
        // Left accent line
        Container(
          width: 3,
          height: 32,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: state == _StepState.pending
                ? Colors.white.withValues(alpha: 0.10)
                : color.withValues(alpha: 0.7),
          ),
        ),
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: state == _StepState.pending
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white,
              fontWeight: state == _StepState.active
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
        if (state == _StepState.active)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gradient CTA button
// ---------------------------------------------------------------------------
class _GradientCTAButton extends StatelessWidget {
  const _GradientCTAButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.gradient = AppGradients.accentHorizontal,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled
              ? const LinearGradient(
                  colors: [Color(0x22FFFFFF), Color(0x16FFFFFF)],
                )
              : gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: disabled ? [] : AppShadows.accent,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                )
              : Text(label),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Warning banner
// ---------------------------------------------------------------------------
class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated processing illustration
// ---------------------------------------------------------------------------
class _AnimatedProcessingIllustration extends StatefulWidget {
  const _AnimatedProcessingIllustration({required this.mode});

  final EncryptionMode mode;

  @override
  State<_AnimatedProcessingIllustration> createState() =>
      _AnimatedProcessingIllustrationState();
}

class _AnimatedProcessingIllustrationState
    extends State<_AnimatedProcessingIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final illustrationIcon = switch (widget.mode) {
      EncryptionMode.encrypt => Icons.shield_rounded,
      EncryptionMode.decrypt => Icons.lock_open_rounded,
      EncryptionMode.steganography => Icons.auto_awesome,
    };

    return SizedBox(
      height: 180,
      width: 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Rotating ring
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.transparent, width: 0),
                  ),
                  child: CustomPaint(
                    painter: _ArcPainter(
                      color: AppColors.accent.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
              // Core icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppGradients.processing,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.accentGlow,
                  ),
                  child: Icon(illustrationIcon, color: Colors.white, size: 44),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated success illustration
// ---------------------------------------------------------------------------
class _AnimatedSuccessIllustration extends StatefulWidget {
  const _AnimatedSuccessIllustration({required this.mode});

  final EncryptionMode mode;

  @override
  State<_AnimatedSuccessIllustration> createState() =>
      _AnimatedSuccessIllustrationState();
}

class _AnimatedSuccessIllustrationState
    extends State<_AnimatedSuccessIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer glow
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Inner ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                ),
              ),
              // Core
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppGradients.success,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom arc painter for rotating ring
// ---------------------------------------------------------------------------
class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, 0, math.pi * 1.4, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Dashed border painter for upload cards
// ---------------------------------------------------------------------------
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
