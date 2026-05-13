import 'dart:async';

import 'package:flutter/material.dart';

import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';

enum EncryptionMode { encrypt, decrypt, steganography }

enum _WorkflowStage { setup, processing, success }

class EncryptionFeaturePage extends StatefulWidget {
  const EncryptionFeaturePage({
    super.key,
    required this.mode,
    required this.onBackPressed,
  });

  final EncryptionMode mode;
  final VoidCallback onBackPressed;

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
    setState(() {
      _stage = _WorkflowStage.setup;
    });
  }

  void _setMode(EncryptionMode mode) {
    if (_activeMode == mode) {
      return;
    }

    _completionTimer?.cancel();
    setState(() {
      _activeMode = mode;
      _stage = _WorkflowStage.setup;
    });
  }

  void _startWorkflow() {
    _completionTimer?.cancel();
    setState(() {
      _stage = _WorkflowStage.processing;
    });

    _completionTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _stage = _WorkflowStage.success;
      });
    });
  }

  void _cancelWorkflow() {
    _completionTimer?.cancel();
    setState(() {
      _stage = _WorkflowStage.setup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EncryptoTopBar(
          showBackButton: true,
          onBackPressed: widget.onBackPressed,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
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
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              switch (mode) {
                EncryptionMode.encrypt => 'Encrypt and Decrypt',
                EncryptionMode.decrypt => 'Encrypt and Decrypt',
                EncryptionMode.steganography => 'Steganography',
              },
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
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

class _EncryptSetupContent extends StatelessWidget {
  const _EncryptSetupContent({required this.onStartPressed});

  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Photo or File',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const _UploadCard(label: 'Upload Cover Image'),
        const SizedBox(height: 18),
        Text(
          'Scan Document',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const _UploadCard(label: 'Upload Encrypted File'),
        const SizedBox(height: 22),
        Text(
          'Encryption Option',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        const _OptionRow(label: 'Bio-metric'),
        const SizedBox(height: 6),
        const _OptionRow(label: 'Password'),
        const SizedBox(height: 6),
        const _OptionRow(label: 'Auto-gen Key'),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onStartPressed, child: const Text('Start')),
      ],
    );
  }
}

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
        Text(
          'Select Photo or File',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const _UploadCard(label: 'Upload Cover Image'),
        const SizedBox(height: 18),
        Text(
          'Enter the Key',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: widget.onStartPressed,
          child: const Text('Decrypt'),
        ),
        const SizedBox(height: 14),
        _InfoRow(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF0A44D),
          text: 'Used wrong key after 3 times you auto logout the app.',
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(-8, -6),
              child: Checkbox(
                value: _retrieveHiddenData,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _retrieveHiddenData = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 7),
                child: Text(
                  'Retrieve hidden data (if steganography applied)',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SteganographySetupContent extends StatelessWidget {
  const _SteganographySetupContent({required this.onStartPressed});

  final VoidCallback onStartPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hide Data in Image',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const _UploadCard(label: 'Upload Cover Image'),
        const SizedBox(height: 14),
        const _UploadCard(label: 'Upload Encrypted File'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onStartPressed,
          child: const Text('Hide Data'),
        ),
        const SizedBox(height: 24),
        Text(
          'Retrieve Hidden Data',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        const _UploadCard(label: 'Upload Stego Image'),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: onStartPressed,
          child: const Text('Share File'),
        ),
      ],
    );
  }
}

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
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const SizedBox(height: 4),
          Text(
            switch (mode) {
              EncryptionMode.encrypt => 'Processing Encryption',
              EncryptionMode.decrypt => 'Processing Decryption',
              EncryptionMode.steganography => 'Processing Steganography',
            },
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          _ProcessingIllustration(mode: mode),
          const SizedBox(height: 18),
          Text(
            '78 %',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            switch (mode) {
              EncryptionMode.encrypt => 'File to Encrypting',
              EncryptionMode.decrypt => 'File to Decrypting',
              EncryptionMode.steganography => 'File to Processing',
            },
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '1.8 MB',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 24),
          _ProgressStep(label: 'Initializing AI Key...'),
          const SizedBox(height: 10),
          _ProgressStep(
            label: switch (mode) {
              EncryptionMode.encrypt => 'Applying to Steganography...',
              EncryptionMode.decrypt => 'Retrieving Steganography Data...',
              EncryptionMode.steganography => 'Applying Hidden Data...',
            },
          ),
          const SizedBox(height: 10),
          _ProgressStep(
            label: switch (mode) {
              EncryptionMode.encrypt => 'Encrypting Data...',
              EncryptionMode.decrypt => 'Decrypting File...',
              EncryptionMode.steganography => 'Hiding Data...',
            },
          ),
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: onCancelPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          const SizedBox(height: 4),
          Text(
            switch (widget.mode) {
              EncryptionMode.encrypt => 'Encryption Successful !',
              EncryptionMode.decrypt => 'Decryption Successful !',
              EncryptionMode.steganography => 'Steganography Successful !',
            },
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _SuccessIllustration(mode: widget.mode),
          const SizedBox(height: 16),
          Text(
            '100 %',
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            switch (widget.mode) {
              EncryptionMode.encrypt => 'The File has been Encrypted.',
              EncryptionMode.decrypt => 'The File has been Decrypted.',
              EncryptionMode.steganography => 'The Data has been Hidden.',
            },
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.mode == EncryptionMode.decrypt) ...[
            const SizedBox(height: 22),
            Text(
              'You can\'t share this. Only private things.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Do you want to share or download this ?',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Share File'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Download'),
            ),
          ] else ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save File Locally'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Upload to Cloud'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _alwaysUpload,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _alwaysUpload = value;
                    });
                  },
                ),
                Text(
                  'Always Upload to Cloud',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onRepeatPressed,
              child: const Text('Share File'),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFBEC2C9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.file_upload_outlined,
              color: Colors.white,
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedModeControl extends StatelessWidget {
  const _SegmentedModeControl({required this.mode, required this.onChanged});

  final EncryptionMode mode;
  final ValueChanged<EncryptionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _SegmentedButton(
            label: 'Encrypt',
            selected: mode == EncryptionMode.encrypt,
            onTap: () => onChanged(EncryptionMode.encrypt),
          ),
          _SegmentedButton(
            label: 'Decrypt',
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
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProcessingIllustration extends StatelessWidget {
  const _ProcessingIllustration({required this.mode});

  final EncryptionMode mode;

  @override
  Widget build(BuildContext context) {
    final illustrationIcon = switch (mode) {
      EncryptionMode.encrypt => Icons.shield_outlined,
      EncryptionMode.decrypt => Icons.lock_open_rounded,
      EncryptionMode.steganography => Icons.auto_awesome,
    };

    return SizedBox(
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 118,
            height: 138,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCFD6EA),
                  Color(0xFF7A88A9),
                  Color(0xFF495879),
                ],
              ),
              borderRadius: BorderRadius.circular(34),
            ),
            child: Icon(illustrationIcon, color: Colors.white, size: 58),
          ),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SuccessIllustration extends StatelessWidget {
  const _SuccessIllustration({required this.mode});

  final EncryptionMode mode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 158,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 118,
            height: 138,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFCFD6EA),
                  Color(0xFF7A88A9),
                  Color(0xFF495879),
                ],
              ),
              borderRadius: BorderRadius.circular(34),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 58,
            ),
          ),
          Positioned(
            right: 14,
            top: 24,
            child: Icon(
              Icons.pan_tool_alt_outlined,
              color: Colors.white.withValues(alpha: 0.9),
              size: 42,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Icon(
              Icons.pan_tool_alt_outlined,
              color: Colors.white.withValues(alpha: 0.9),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
