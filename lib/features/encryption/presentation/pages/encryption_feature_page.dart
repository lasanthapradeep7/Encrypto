// ignore_for_file: use_build_context_synchronously

// ignore_for_file: unused_element

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:encrypto/core/network/network_error_message.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import '../../../../services/api_service.dart';
import '../../../../services/ocr_service.dart';
import 'package:encrypto/services/biometric_key_service.dart';
import '../../../../services/ocr_api_service.dart';

enum EncryptionMode { encrypt, decrypt, steganography }

enum ProtectionMethod { biometric, hybrid, passwordOnly }

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

  // Selected file details
  String? _selectedFilePath;
  String? _selectedFileName;

  // Steganography file details
  String? _stegoCoverImagePath;
  String? _stegoCoverImageName;
  String? _stegoFilePath;
  String? _stegoFileName;
  String? _stegoExtractImagePath;
  String? _stegoExtractImageName;
  String? _stegoDownloadFileName;

  // Key / controller for inputs
  String? _generatedKey;
  final _keyController = TextEditingController();

  ProtectionMethod _protectionMethod = ProtectionMethod.biometric;

  final TextEditingController _hybridPasswordController =
      TextEditingController();

  final TextEditingController _hybridConfirmPasswordController =
      TextEditingController();

  final TextEditingController _stegoPasswordController =
      TextEditingController();

  final TextEditingController _stegoConfirmPasswordController =
      TextEditingController();

  // Dynamic progress indicators
  _StepState _step1State = _StepState.pending;
  _StepState _step2State = _StepState.pending;
  _StepState _step3State = _StepState.pending;
  String _progressPercentage = '0%';
  String _currentProgressLabel = '';
  String _fileSizeLabel = '0.0 KB';
  int? _processedFileId;
  Map<String, dynamic>? _aiAnalysis;
  bool _isAiAnalysisLoading = false;

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

    _keyController.dispose();
    _hybridPasswordController.dispose();
    _hybridConfirmPasswordController.dispose();
    _stegoPasswordController.dispose();
    _stegoConfirmPasswordController.dispose();

    super.dispose();
  }

  void _resetFlow() {
    _completionTimer?.cancel();
    setState(() {
      _stage = _WorkflowStage.setup;
      _selectedFilePath = null;
      _selectedFileName = null;
      _stegoCoverImagePath = null;
      _stegoCoverImageName = null;
      _stegoFilePath = null;
      _stegoFileName = null;
      _stegoExtractImagePath = null;
      _stegoExtractImageName = null;
      _generatedKey = null;
      _keyController.clear();
      _processedFileId = null;
      _aiAnalysis = null;
      _isAiAnalysisLoading = false;
      _protectionMethod = ProtectionMethod.biometric;

      _hybridPasswordController.clear();
      _hybridConfirmPasswordController.clear();

      _stegoPasswordController.clear();
      _stegoConfirmPasswordController.clear();

      _stegoDownloadFileName = null;
    });
  }

  void _setMode(EncryptionMode mode) {
    if (_activeMode == mode) return;
    _completionTimer?.cancel();
    setState(() {
      _activeMode = mode;
      _stage = _WorkflowStage.setup;
    });
  }

  Future<void> _pickFile({
    required bool isStegoCover,
    required bool isStegoFile,
    required bool isStegoExtract,
  }) async {
    try {
      final result = await FilePicker.pickFiles(
        type: (isStegoCover || isStegoExtract) ? FileType.image : FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          final path = result.files.single.path;
          final name = result.files.single.name;
          if (isStegoCover) {
            _stegoCoverImagePath = path;
            _stegoCoverImageName = name;
          } else if (isStegoFile) {
            _stegoFilePath = path;
            _stegoFileName = name;
          } else if (isStegoExtract) {
            _stegoExtractImagePath = path;
            _stegoExtractImageName = name;
          } else {
            _selectedFilePath = path;
            _selectedFileName = name;
            _aiAnalysis = null;
          }
        });
        if (!isStegoCover &&
            !isStegoFile &&
            !isStegoExtract &&
            _activeMode == EncryptionMode.encrypt) {
          await _uploadAndAnalyzeSelectedFile();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  bool _isImageFile(String fileName) {
    final lowerName = fileName.toLowerCase();

    return lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp') ||
        lowerName.endsWith('.bmp');
  }

  Future<void> _uploadAndAnalyzeSelectedFile() async {
    final selectedPath = _selectedFilePath;
    final selectedName = _selectedFileName;

    if (selectedPath == null || selectedName == null) {
      return;
    }

    try {
      if (!mounted) return;

      setState(() {
        _isAiAnalysisLoading = true;
        _aiAnalysis = null;
      });

      final uploadResult = await ApiService.uploadFile(selectedPath);

      if (uploadResult['status'] != 200) {
        throw Exception(uploadResult['body']?['detail'] ?? 'Upload failed');
      }

      final fileId = uploadResult['body']?['file_id'] as int;

      late final Map<String, dynamic> aiResult;

      debugPrint('SELECTED FILE NAME: $selectedName');
      debugPrint('IS IMAGE FILE: ${_isImageFile(selectedName)}');

      if (_isImageFile(selectedName)) {
        debugPrint('USING MOBILE OCR FLOW');

        final extractedText = await OcrService.extractTextFromImage(
          selectedPath,
        );

        if (extractedText.trim().isEmpty) {
          throw Exception('No readable text was detected in the image.');
        }

        debugPrint(
          'MOBILE OCR EXTRACTED '
          '${extractedText.length} CHARACTERS',
        );

        debugPrint('MOBILE OCR TEXT: $extractedText');

        aiResult = await OcrApiService.analyzeExtractedText(
          fileId: fileId,
          extractedText: extractedText,
        );
      } else {
        debugPrint('USING BACKEND FILE ANALYSIS FLOW');

        aiResult = await ApiService.analyzeFile(fileId);
      }

      if (aiResult['status'] != 200) {
        throw Exception(aiResult['body']?['detail'] ?? 'AI analysis failed');
      }

      if (!mounted) return;

      setState(() {
        _processedFileId = fileId;
        _aiAnalysis = aiResult['body'] as Map<String, dynamic>;
        _isAiAnalysisLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isAiAnalysisLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(NetworkErrorMessage.forError(
        error,
        fallback: 'AI analysis failed. Please try again.',
      ))));
    }
  }

  void _startWorkflow() async {
    String decryptionKey = '';

    if (_activeMode == EncryptionMode.encrypt) {
      if (_selectedFilePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a file to encrypt.')),
        );
        return;
      }

      // Hybrid password validation
      final methodName = _protectionMethod == ProtectionMethod.hybrid
          ? 'Hybrid'
          : 'Password';
      if (_protectionMethod == ProtectionMethod.hybrid ||
          _protectionMethod == ProtectionMethod.passwordOnly) {
        final password = _hybridPasswordController.text.trim();
        final confirmPassword = _hybridConfirmPasswordController.text.trim();

        if (password.isEmpty || confirmPassword.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enter and confirm the $methodName password.',
              ),
            ),
          );
          return;
        }
        if (password.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Hybrid password must contain at least 6 characters.',
              ),
            ),
          );
          return;
        }

        if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hybrid passwords do not match.')),
          );
          return;
        }
      }

      // Biometric and Hybrid both require biometric authentication
      if (_protectionMethod == ProtectionMethod.biometric ||
          _protectionMethod == ProtectionMethod.hybrid) {
        final biometricOk = await BiometricKeyService.authenticate();

        if (!mounted) return;

        if (!biometricOk) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Biometric authentication failed.')),
          );
          return;
        }
      }
    } else if (_activeMode == EncryptionMode.decrypt) {
      if (_selectedFilePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an encrypted file.')),
        );
        return;
      }

      if (_protectionMethod == ProtectionMethod.biometric ||
          _protectionMethod == ProtectionMethod.hybrid) {
        final biometricOk = await BiometricKeyService.authenticate();

        if (!biometricOk) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Biometric authentication failed.')),
          );
          return;
        }
      }

      if (_protectionMethod == ProtectionMethod.biometric) {
        if (_selectedFileName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select encrypted file first.')),
          );
          return;
        }

        final savedKey = await BiometricKeyService.getKeyByFileName(
          fileName: _selectedFileName!,
        );

        if (!mounted) return;

        if (savedKey == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No biometric key found for this file.')),
          );
          return;
        }

        decryptionKey = savedKey;
      } else {
        decryptionKey = _keyController.text.trim();

        if (decryptionKey.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _protectionMethod == ProtectionMethod.hybrid
                    ? 'Please enter the hybrid password.'
                    : 'Please enter the sharing password.',
              ),
            ),
          );
          return;
        }
      }
    } else if (_activeMode == EncryptionMode.steganography) {
      if (_stegoExtractImagePath == null &&
          (_stegoCoverImagePath == null || _stegoFilePath == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select either stego cover + hidden file or a stego image to extract.',
            ),
          ),
        );
        return;
      }
    }

    _completionTimer?.cancel();

    setState(() {
      _stage = _WorkflowStage.processing;
      _step1State = _StepState.active;
      _step2State = _StepState.pending;
      _step3State = _StepState.pending;
      _progressPercentage = '0%';
      _currentProgressLabel = 'Preparing file...';
      _fileSizeLabel = '0.0 KB';
    });

    try {
      String pathForSize = '';

      if (_activeMode == EncryptionMode.encrypt ||
          _activeMode == EncryptionMode.decrypt) {
        pathForSize = _selectedFilePath!;
      } else {
        pathForSize = _stegoExtractImagePath ?? _stegoFilePath!;
      }

      final file = File(pathForSize);
      final sizeBytes = await file.length();
      final sizeKb = sizeBytes / 1024.0;

      setState(() {
        _fileSizeLabel = '${sizeKb.toStringAsFixed(1)} KB';
        _progressPercentage = '20%';
        _currentProgressLabel = 'Uploading file to server...';
      });

      int? fileId;

      if (_activeMode == EncryptionMode.encrypt ||
          _activeMode == EncryptionMode.decrypt) {
        if (_processedFileId == null) {
          final uploadResult = await ApiService.uploadFile(pathForSize);

          if (uploadResult['status'] != 200) {
            throw Exception(uploadResult['body']?['detail'] ?? 'Upload failed');
          }

          _processedFileId = uploadResult['body']?['file_id'] as int;
        }

        fileId = _processedFileId!;
      }

      setState(() {
        _step1State = _StepState.done;
        _step2State = _StepState.active;
        _progressPercentage = '50%';
        _currentProgressLabel = _activeMode == EncryptionMode.encrypt
            ? 'Encrypting file data...'
            : _activeMode == EncryptionMode.decrypt
            ? 'Decrypting file data...'
            : 'Processing steganography...';
      });

      if (_activeMode == EncryptionMode.encrypt) {
        Map<String, dynamic> encryptResult;

        if (_protectionMethod == ProtectionMethod.hybrid ||
            _protectionMethod == ProtectionMethod.passwordOnly) {
          encryptResult = await ApiService.encryptFileWithPassword(
            fileId: fileId!,
            password: _hybridPasswordController.text.trim(),
            mode: _protectionMethod == ProtectionMethod.hybrid
                ? 'hybrid'
                : 'password_only',
          );
        } else {
          encryptResult = await ApiService.encryptFile(fileId!);
        }

        if (encryptResult['status'] != 200) {
          throw Exception(
            encryptResult['body']?['detail'] ?? 'Encryption failed',
          );
        }

        if (_protectionMethod == ProtectionMethod.biometric) {
          _generatedKey = encryptResult['body']?['key'] as String?;

          if (_generatedKey != null && _selectedFileName != null) {
            await BiometricKeyService.saveKeyByFileName(
              fileName: 'enc_$_selectedFileName',
              key: _generatedKey!,
            );
          }
        } else {
          _generatedKey = null;
        }
      } else if (_activeMode == EncryptionMode.decrypt) {
        Map<String, dynamic> decryptResult;

        if (_protectionMethod == ProtectionMethod.biometric) {
          decryptResult = await ApiService.decryptFile(
            fileId: fileId!,
            key: decryptionKey,
          );
        } else {
          decryptResult = await ApiService.decryptFileWithPassword(
            fileId: fileId!,
            password: decryptionKey,
            mode: _protectionMethod == ProtectionMethod.hybrid
                ? 'hybrid'
                : 'password_only',
          );
        }

        if (decryptResult['status'] != 200) {
          throw Exception(
            decryptResult['body']?['detail'] ?? 'Decryption failed',
          );
        }
      } else {
        // -----------------------------
        // Steganography
        // -----------------------------

        if (_stegoExtractImagePath != null) {
          // Extract hidden file

          final result = await ApiService.extractStego(
            stegoImagePath: _stegoExtractImagePath!,
          );

          if (result["status"] != 200) {
            throw Exception(
              result["body"]?["detail"] ?? "Stego extraction failed",
            );
          }

          _stegoDownloadFileName =
              result["body"]["extracted_filename"] as String?;
        } else {
          // Hide file inside image

          final result = await ApiService.hideStego(
            coverImagePath: _stegoCoverImagePath!,
            hiddenFilePath: _stegoFilePath!,
          );

          if (result["status"] != 200) {
            throw Exception(result["body"]?["detail"] ?? "Stego hiding failed");
          }

          _stegoDownloadFileName = result["body"]["stego_filename"] as String?;
        }
      }

      setState(() {
        _step2State = _StepState.done;
        _step3State = _StepState.active;
        _progressPercentage = '90%';
        _currentProgressLabel = 'Finalizing...';
      });

      await Future<void>.delayed(Duration(milliseconds: 500));

      setState(() {
        _step3State = _StepState.done;
        _progressPercentage = '100%';
        _stage = _WorkflowStage.success;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(NetworkErrorMessage.forError(
          e,
          fallback: 'The workflow could not be completed. Please try again.',
        ))));

        setState(() {
          _stage = _WorkflowStage.setup;
        });
      }
    }
  }

  Future<void> _downloadAndSaveFile({required String type}) async {
    try {
      List<int>? fileBytes;
      String fileName = 'processed_file';

      if (_activeMode == EncryptionMode.steganography) {
        if (_stegoDownloadFileName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No steganography file to download.')),
          );
          return;
        }

        fileBytes = await ApiService.downloadStegoFile(_stegoDownloadFileName!);
        fileName = _stegoDownloadFileName!;
      } else {
        if (_processedFileId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No processed file to download.')),
          );
          return;
        }

        fileBytes = await ApiService.downloadFile(_processedFileId!, type);

        fileName = _selectedFileName ?? 'processed_file';

        if (type == 'encrypted') {
          fileName = 'enc_$fileName';
        } else if (type == 'decrypted') {
          fileName = 'dec_$fileName';
        }
      }

      if (fileBytes == null) {
        throw Exception('Failed to download file.');
      }

      final savedPath = await FilePicker.saveFile(
        dialogTitle: 'Save $fileName',
        fileName: fileName,
        type: FileType.any,
        bytes: Uint8List.fromList(fileBytes),
      );

      if (!mounted) return;

      if (savedPath == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save cancelled')));
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File saved to $savedPath')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving file: $e')));
      }
    }
  }

  void _cancelWorkflow() {
    _completionTimer?.cancel();
    _completionTimer = null;

    if (!mounted) return;

    setState(() {
      _stage = _WorkflowStage.setup;
      _step1State = _StepState.pending;
      _step2State = _StepState.pending;
      _step3State = _StepState.pending;
      _progressPercentage = '0%';
      _currentProgressLabel = '';
      _fileSizeLabel = '0.0 KB';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EncryptoTopBar(
          showBackButton: true,
          onBackPressed: widget.onBackPressed,
          onNotificationsPressed: widget.onOpenNotifications,
          onSettingsPressed: widget.onOpenSettings,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: switch (_stage) {
              _WorkflowStage.setup => _SetupView(
                key: ValueKey('setup'),
                mode: _activeMode,
                onModeChanged: _setMode,
                onStartPressed: _startWorkflow,
                selectedFileName: _selectedFileName,
                stegoCoverImageName: _stegoCoverImageName,
                stegoFileName: _stegoFileName,
                stegoExtractImageName: _stegoExtractImageName,
                keyController: _keyController,
                aiAnalysis: _aiAnalysis,
                isAiAnalysisLoading: _isAiAnalysisLoading,
                protectionMethod: _protectionMethod,
                onProtectionMethodChanged: (method) {
                  setState(() {
                    _protectionMethod = method;
                  });
                },
                hybridPasswordController: _hybridPasswordController,
                hybridConfirmPasswordController:
                    _hybridConfirmPasswordController,
                stegoPasswordController: _stegoPasswordController,
                stegoConfirmPasswordController: _stegoConfirmPasswordController,
                onPickFile: () => _pickFile(
                  isStegoCover: false,
                  isStegoFile: false,
                  isStegoExtract: false,
                ),
                onPickStegoCover: () => _pickFile(
                  isStegoCover: true,
                  isStegoFile: false,
                  isStegoExtract: false,
                ),
                onPickStegoFile: () => _pickFile(
                  isStegoCover: false,
                  isStegoFile: true,
                  isStegoExtract: false,
                ),
                onPickStegoExtract: () => _pickFile(
                  isStegoCover: false,
                  isStegoFile: false,
                  isStegoExtract: true,
                ),
              ),
              _WorkflowStage.processing => _ProcessingView(
                key: ValueKey('processing'),
                mode: _activeMode,
                onCancelPressed: _cancelWorkflow,
                step1State: _step1State,
                step2State: _step2State,
                step3State: _step3State,
                progressPercentage: _progressPercentage,
                currentProgressLabel: _currentProgressLabel,
                fileSizeLabel: _fileSizeLabel,
              ),
              _WorkflowStage.success => _SuccessView(
                key: ValueKey('success'),
                mode: _activeMode,
                onRepeatPressed: _resetFlow,
                generatedKey: _generatedKey,
                onDownload: () => _downloadAndSaveFile(
                  type: _activeMode == EncryptionMode.encrypt
                      ? 'encrypted'
                      : _activeMode == EncryptionMode.decrypt
                      ? 'decrypted'
                      : 'stego',
                ),
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
    required this.selectedFileName,
    required this.stegoCoverImageName,
    required this.stegoFileName,
    required this.stegoExtractImageName,
    required this.keyController,
    required this.onPickFile,
    required this.onPickStegoCover,
    required this.onPickStegoFile,
    required this.onPickStegoExtract,
    required this.aiAnalysis,
    required this.isAiAnalysisLoading,
    required this.protectionMethod,
    required this.onProtectionMethodChanged,
    required this.hybridPasswordController,
    required this.hybridConfirmPasswordController,
    required this.stegoPasswordController,
    required this.stegoConfirmPasswordController,
  });

  final EncryptionMode mode;
  final ValueChanged<EncryptionMode> onModeChanged;
  final VoidCallback onStartPressed;
  final String? selectedFileName;
  final String? stegoCoverImageName;
  final String? stegoFileName;
  final String? stegoExtractImageName;
  final TextEditingController keyController;
  final VoidCallback onPickFile;
  final VoidCallback onPickStegoCover;
  final VoidCallback onPickStegoFile;
  final VoidCallback onPickStegoExtract;
  final Map<String, dynamic>? aiAnalysis;
  final bool isAiAnalysisLoading;
  final ProtectionMethod protectionMethod;
  final ValueChanged<ProtectionMethod> onProtectionMethodChanged;
  final TextEditingController hybridPasswordController;
  final TextEditingController hybridConfirmPasswordController;
  final TextEditingController stegoPasswordController;
  final TextEditingController stegoConfirmPasswordController;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: EncryptionContentContainer(
        padding: EdgeInsets.fromLTRB(24, 12, 24, 24),
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
                color: context.encryptoColors.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            if (mode != EncryptionMode.steganography) ...[
              SizedBox(height: 18),
              _SegmentedModeControl(mode: mode, onChanged: onModeChanged),
            ],
            SizedBox(height: 22),
            switch (mode) {
              EncryptionMode.encrypt => _EncryptSetupContent(
                onStartPressed: onStartPressed,
                selectedFileName: selectedFileName,
                onPickFile: onPickFile,
                aiAnalysis: aiAnalysis,
                isAiAnalysisLoading: isAiAnalysisLoading,
                protectionMethod: protectionMethod,
                onProtectionMethodChanged: onProtectionMethodChanged,
                passwordController: hybridPasswordController,
                confirmPasswordController: hybridConfirmPasswordController,
              ),
              EncryptionMode.decrypt => _DecryptSetupContent(
                onStartPressed: onStartPressed,
                selectedFileName: selectedFileName,
                keyController: keyController,
                onPickFile: onPickFile,
                protectionMethod: protectionMethod,
                onProtectionMethodChanged: onProtectionMethodChanged,
              ),
              EncryptionMode.steganography => _SteganographySetupContent(
                onStartPressed: onStartPressed,
                stegoCoverImageName: stegoCoverImageName,
                stegoFileName: stegoFileName,
                stegoExtractImageName: stegoExtractImageName,
                onPickStegoCover: onPickStegoCover,
                onPickStegoFile: onPickStegoFile,
                onPickStegoExtract: onPickStegoExtract,
                passwordController: stegoPasswordController,
                confirmPasswordController: stegoConfirmPasswordController,
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
  const _EncryptSetupContent({
    required this.onStartPressed,
    required this.selectedFileName,
    required this.onPickFile,
    required this.aiAnalysis,
    required this.isAiAnalysisLoading,
    required this.protectionMethod,
    required this.onProtectionMethodChanged,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final VoidCallback onStartPressed;
  final String? selectedFileName;
  final VoidCallback onPickFile;
  final Map<String, dynamic>? aiAnalysis;
  final bool isAiAnalysisLoading;

  final ProtectionMethod protectionMethod;
  final ValueChanged<ProtectionMethod> onProtectionMethodChanged;

  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(
          label: 'Select Photo or File',
          icon: Icons.image_outlined,
        ),
        SizedBox(height: 10),
        _UploadCard(
          label: selectedFileName ?? 'Click to upload photo or file',
          hint: selectedFileName != null
              ? 'File picked successfully'
              : 'JPG, PNG, PDF up to 20MB',
          icon: selectedFileName != null
              ? Icons.verified_user_rounded
              : Icons.image_rounded,
          onTap: onPickFile,
        ),
        SizedBox(height: 14),
        _SectionLabel(label: 'Scan Document', icon: Icons.file_present_rounded),
        SizedBox(height: 10),
        _UploadCard(
          label: selectedFileName ?? 'Scan or attach a document',
          hint: selectedFileName != null
              ? 'Document picked successfully'
              : 'Scan or attach a document',
          icon: selectedFileName != null
              ? Icons.verified_user_rounded
              : Icons.lock_outlined,
          onTap: onPickFile,
        ),
        SizedBox(height: 22),
        _SectionLabel(label: 'Encryption Option', icon: Icons.settings_rounded),
        SizedBox(height: 12),
        _OptionRow(
          label: 'Biometric',
          icon: Icons.fingerprint_rounded,
          color: Color(0xFF60A5FA),
          selected: protectionMethod == ProtectionMethod.biometric,
          onTap: () {
            onProtectionMethodChanged(ProtectionMethod.biometric);
          },
        ),

        SizedBox(height: 8),

        _OptionRow(
          label: 'Hybrid',
          icon: Icons.security_rounded,
          color: Color(0xFF34D399),
          selected: protectionMethod == ProtectionMethod.hybrid,
          onTap: () {
            onProtectionMethodChanged(ProtectionMethod.hybrid);
          },
        ),

        SizedBox(height: 8),

        _OptionRow(
          label: 'Password Only',
          icon: Icons.lock_outlined,
          color: Color(0xFFA78BFA),
          selected: protectionMethod == ProtectionMethod.passwordOnly,
          onTap: () {
            onProtectionMethodChanged(ProtectionMethod.passwordOnly);
          },
        ),

        if (protectionMethod == ProtectionMethod.hybrid ||
            protectionMethod == ProtectionMethod.passwordOnly) ...[
          SizedBox(height: 16),

          TextField(
            controller: passwordController,
            obscureText: true,
            style: TextStyle(color: context.encryptoColors.textPrimary),
            decoration: _secureInputDecoration(
              context: context,
              hint: protectionMethod == ProtectionMethod.hybrid
                  ? 'Enter hybrid password'
                  : 'Enter sharing password',
              icon: Icons.lock_outline_rounded,
            ),
          ),

          SizedBox(height: 10),

          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            style: TextStyle(color: context.encryptoColors.textPrimary),
            decoration: _secureInputDecoration(
              context: context,
              hint: protectionMethod == ProtectionMethod.hybrid
                  ? 'Confirm hybrid password'
                  : 'Confirm sharing password',
              icon: Icons.lock_reset_rounded,
            ),
          ),

          SizedBox(height: 8),

          Text(
            protectionMethod == ProtectionMethod.hybrid
                ? 'Hybrid protection requires both your password and biometric authentication.'
                : 'Use Password Only for files that will be shared through Steganography.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.60),
            ),
          ),
        ],
        SizedBox(height: 22),
        if (isAiAnalysisLoading) ...[
          _AiAnalysisLoadingCard(),
          SizedBox(height: 14),
        ],
        if (aiAnalysis != null) ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Color(0xFF60A5FA)),
                    SizedBox(width: 8),
                    Text(
                      'AI Security Advisor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.encryptoColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  'Risk Level : ${aiAnalysis!['risk_level']}',
                  style: TextStyle(
                    color: context.encryptoColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Confidence : ${aiAnalysis!['confidence'] ?? '-'}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.encryptoColors.textSecondary,
                  ),
                ),
                Text(
                  'Risk Score : ${aiAnalysis!['risk_score']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.encryptoColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  aiAnalysis!['reason'] ?? '',
                  style: TextStyle(color: context.encryptoColors.textSecondary),
                ),
                SizedBox(height: 12),
                Text(
                  'Detected:',
                  style: TextStyle(
                    color: context.encryptoColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                ...((aiAnalysis!['findings'] as List?) ?? []).map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: TextStyle(
                              color: context.encryptoColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Recommended : ${aiAnalysis!['recommendation']}',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],

        _GradientCTAButton(
          label: isAiAnalysisLoading
              ? 'Preparing security report...'
              : 'Start Encryption',
          onPressed: isAiAnalysisLoading ? null : onStartPressed,
        ),
      ],
    );
  }
}

class _AiAnalysisLoadingCard extends StatefulWidget {
  const _AiAnalysisLoadingCard();

  @override
  State<_AiAnalysisLoadingCard> createState() =>
      _AiAnalysisLoadingCardState();
}

class _AiAnalysisLoadingCardState extends State<_AiAnalysisLoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label:
          'Checking file security. Your AI advisor report will appear automatically.',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: child,
          ),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    FadeTransition(
                      opacity: _pulse,
                      child: ScaleTransition(
                        scale: _pulse,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 21,
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checking file security...',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: context.encryptoColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your AI advisor report will appear automatically.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: context.encryptoColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LinearProgressIndicator(
                minHeight: 2,
                color: Color(0xFF60A5FA),
                backgroundColor: Color(0xFF60A5FA).withValues(alpha: 0.12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Decrypt setup
// ---------------------------------------------------------------------------
class _DecryptSetupContent extends StatefulWidget {
  const _DecryptSetupContent({
    required this.onStartPressed,
    required this.selectedFileName,
    required this.keyController,
    required this.onPickFile,
    required this.protectionMethod,
    required this.onProtectionMethodChanged,
  });

  final VoidCallback onStartPressed;
  final String? selectedFileName;
  final TextEditingController keyController;
  final VoidCallback onPickFile;
  final ProtectionMethod protectionMethod;
  final ValueChanged<ProtectionMethod> onProtectionMethodChanged;

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
        SizedBox(height: 10),
        _UploadCard(
          label: widget.selectedFileName ?? 'Upload Encrypted File',
          hint: widget.selectedFileName != null
              ? 'Encrypted file picked'
              : 'Drop your file here',
          icon: widget.selectedFileName != null
              ? Icons.verified_user_rounded
              : Icons.lock_outlined,
          onTap: widget.onPickFile,
        ),
        SizedBox(height: 22),
        _SectionLabel(label: 'Decryption Option', icon: Icons.settings_rounded),

        SizedBox(height: 12),

        _OptionRow(
          label: 'Biometric',
          icon: Icons.fingerprint_rounded,
          color: Color(0xFF60A5FA),
          selected: widget.protectionMethod == ProtectionMethod.biometric,
          onTap: () {
            widget.onProtectionMethodChanged(ProtectionMethod.biometric);
          },
        ),

        SizedBox(height: 8),

        _OptionRow(
          label: 'Hybrid',
          icon: Icons.security_rounded,
          color: Color(0xFF34D399),
          selected: widget.protectionMethod == ProtectionMethod.hybrid,
          onTap: () {
            widget.onProtectionMethodChanged(ProtectionMethod.hybrid);
          },
        ),

        SizedBox(height: 8),

        _OptionRow(
          label: 'Password Only',
          icon: Icons.lock_outline_rounded,
          color: Color(0xFFA78BFA),
          selected: widget.protectionMethod == ProtectionMethod.passwordOnly,
          onTap: () {
            widget.onProtectionMethodChanged(ProtectionMethod.passwordOnly);
          },
        ),
        SizedBox(height: 18),
        if (widget.protectionMethod != ProtectionMethod.biometric) ...[
          _SectionLabel(label: 'Decryption Password', icon: Icons.key_rounded),

          SizedBox(height: 10),

          TextField(
            controller: widget.keyController,
            obscureText: _obscurePassword,
            style: textTheme.bodyLarge?.copyWith(
              color: context.encryptoColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.protectionMethod == ProtectionMethod.hybrid
                  ? 'Enter hybrid password'
                  : 'Enter sharing password',

              hintStyle: textTheme.bodyMedium?.copyWith(
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.45,
                ),
              ),

              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.6,
                ),
              ),

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
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),

              filled: true,
              fillColor: context.encryptoColors.textPrimary.withValues(
                alpha: 0.08,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.accent, width: 1.8),
              ),
            ),
          ),

          SizedBox(height: 14),
        ],
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
                    return context.encryptoColors.textPrimary.withValues(
                      alpha: 0.1,
                    );
                  }),
                  side: BorderSide(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Retrieve hidden steganography data',
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.85,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
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
  const _SteganographySetupContent({
    required this.onStartPressed,
    required this.stegoCoverImageName,
    required this.stegoFileName,
    required this.stegoExtractImageName,
    required this.onPickStegoCover,
    required this.onPickStegoFile,
    required this.onPickStegoExtract,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final VoidCallback onStartPressed;
  final String? stegoCoverImageName;
  final String? stegoFileName;
  final String? stegoExtractImageName;
  final VoidCallback onPickStegoCover;
  final VoidCallback onPickStegoFile;
  final VoidCallback onPickStegoExtract;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel(
          label: 'Hide data in image',
          icon: Icons.hide_image_rounded,
        ),
        SizedBox(height: 10),
        _UploadCard(
          label: stegoCoverImageName ?? 'Upload Cover Image',
          hint: stegoCoverImageName != null
              ? 'Cover image loaded'
              : 'The carrier image',
          icon: stegoCoverImageName != null
              ? Icons.verified_user_rounded
              : Icons.image_rounded,
          onTap: onPickStegoCover,
        ),
        SizedBox(height: 10),
        _UploadCard(
          label: stegoFileName ?? 'Upload Encrypted File',
          hint: stegoFileName != null ? 'File to hide loaded' : 'Data to hide',
          icon: stegoFileName != null
              ? Icons.verified_user_rounded
              : Icons.lock_outlined,
          onTap: onPickStegoFile,
        ),
        SizedBox(height: 18),
        _GradientCTAButton(label: 'Hide Data', onPressed: onStartPressed),
        SizedBox(height: 22),
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.10,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Retrieve hidden data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.10,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        _SectionLabel(label: 'Stego image', icon: Icons.image_search_rounded),
        SizedBox(height: 10),
        _UploadCard(
          label: stegoExtractImageName ?? 'Upload Stego Image',
          hint: stegoExtractImageName != null
              ? 'Stego image loaded'
              : 'Image with hidden data',
          icon: stegoExtractImageName != null
              ? Icons.verified_user_rounded
              : Icons.image_search_rounded,
          onTap: onPickStegoExtract,
        ),
        SizedBox(height: 18),
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
    required this.step1State,
    required this.step2State,
    required this.step3State,
    required this.progressPercentage,
    required this.currentProgressLabel,
    required this.fileSizeLabel,
  });

  final EncryptionMode mode;
  final VoidCallback onCancelPressed;
  final _StepState step1State;
  final _StepState step2State;
  final _StepState step3State;
  final String progressPercentage;
  final String currentProgressLabel;
  final String fileSizeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: EncryptionContentContainer(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                color: context.encryptoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28),
            _AnimatedProcessingIllustration(mode: mode),
            SizedBox(height: 20),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (b) =>
                  AppGradients.accentHorizontal.createShader(b),
              child: Text(
                progressPercentage,
                style: textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 64,
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              currentProgressLabel,
              style: textTheme.titleMedium?.copyWith(
                color: context.encryptoColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              fileSizeLabel,
              style: textTheme.bodyMedium?.copyWith(
                color: context.encryptoColors.textPrimary.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
            SizedBox(height: 26),
            EncryptionSurfaceCard(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _ProgressStep(
                    label: 'Initializing key & uploading',
                    state: step1State,
                  ),
                  SizedBox(height: 10),
                  _ProgressStep(
                    label: switch (mode) {
                      EncryptionMode.encrypt => 'Applying encryption',
                      EncryptionMode.decrypt => 'Decrypting file',
                      EncryptionMode.steganography => 'Applying steganography',
                    },
                    state: step2State,
                  ),
                  SizedBox(height: 10),
                  _ProgressStep(label: 'Finalizing process', state: step3State),
                ],
              ),
            ),
            SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onCancelPressed,
                icon: Icon(Icons.close_rounded),
                label: Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.encryptoColors.textPrimary
                      .withValues(alpha: 0.8),
                  side: BorderSide(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.25,
                    ),
                  ),
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
    this.generatedKey,
    required this.onDownload,
  });

  final EncryptionMode mode;
  final VoidCallback onRepeatPressed;
  final String? generatedKey;
  final VoidCallback onDownload;

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
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                color: context.encryptoColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 22),
            _AnimatedSuccessIllustration(mode: widget.mode),
            SizedBox(height: 16),
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
            SizedBox(height: 6),
            Text(
              switch (widget.mode) {
                EncryptionMode.encrypt => 'File successfully encrypted.',
                EncryptionMode.decrypt => 'File successfully decrypted.',
                _ => 'Steganography complete.',
              },
              style: textTheme.titleMedium?.copyWith(
                color: context.encryptoColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 22),
            if (widget.mode == EncryptionMode.encrypt) ...[
              EncryptionSurfaceCard(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.fingerprint_rounded,
                      color: Color(0xFF60A5FA),
                      size: 28,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Encryption Key Secured',
                      style: textTheme.titleSmall?.copyWith(
                        color: context.encryptoColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your encryption key is protected with biometric authentication. Use fingerprint or face unlock during decryption.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.encryptoColors.textPrimary.withValues(
                          alpha: 0.78,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
            ],
            if (widget.mode == EncryptionMode.decrypt) ...[
              EncryptionSurfaceCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF60A5FA),
                      size: 20,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This file is private. Only download or share via secure channels.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.encryptoColors.textPrimary.withValues(
                          alpha: 0.82,
                        ),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              _GradientCTAButton(
                label: 'Share File',
                icon: Icons.share_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Share option is not configured. Use Download to save the file.',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: widget.onDownload,
                  icon: Icon(Icons.download_rounded),
                  label: Text('Download'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.encryptoColors.textPrimary
                        .withValues(alpha: 0.88),
                    side: BorderSide(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.35,
                      ),
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
                onPressed: widget.onDownload,
              ),
              SizedBox(height: 10),
              _GradientCTAButton(
                label: 'Upload to Cloud',
                icon: Icons.cloud_upload_rounded,
                gradient: AppGradients.success,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'File is already securely saved on the server.',
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
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
                      return context.encryptoColors.textPrimary.withValues(
                        alpha: 0.1,
                      );
                    }),
                    side: BorderSide(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  Text(
                    'Always upload to cloud',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: widget.onRepeatPressed,
                  icon: Icon(Icons.replay_rounded),
                  label: Text('Start over'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.encryptoColors.textPrimary
                        .withValues(alpha: 0.8),
                    side: BorderSide(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.25,
                      ),
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
    this.onTap,
  });

  final String label;
  final String hint;
  final IconData icon;
  final VoidCallback? onTap;

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
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _hovered ? 0.97 : 1.0,
        duration: Duration(milliseconds: 120),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _hovered
                ? AppColors.accent.withValues(alpha: 0.6)
                : context.encryptoColors.textPrimary.withValues(alpha: 0.2),
            radius: 18,
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            constraints: BoxConstraints(minHeight: 86),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.accent.withValues(alpha: 0.10)
                  : context.encryptoColors.textPrimary.withValues(alpha: 0.04),
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
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          color: context.encryptoColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: context.encryptoColors.textPrimary.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                    ],
                  ),
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
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.12),
        ),
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
          duration: Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: EdgeInsets.all(4),
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
                    : context.encryptoColors.textPrimary.withValues(alpha: 0.5),
              ),
              SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : context.encryptoColors.textPrimary.withValues(
                          alpha: 0.5,
                        ),
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
class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : context.encryptoColors.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.4)
                : context.encryptoColors.textPrimary.withValues(alpha: 0.10),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.2)
                    : context.encryptoColors.textPrimary.withValues(
                        alpha: 0.06,
                      ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14,
                color: selected
                    ? color
                    : context.encryptoColors.textPrimary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? context.encryptoColors.textPrimary
                      : context.encryptoColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? color
                      : context.encryptoColors.textPrimary.withValues(
                          alpha: 0.25,
                        ),
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 11, color: Colors.white)
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
        context.encryptoColors.textPrimary.withValues(alpha: 0.3),
      ),
    };

    return Row(
      children: [
        // Left accent line
        Container(
          width: 3,
          height: 32,
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: state == _StepState.pending
                ? context.encryptoColors.textPrimary.withValues(alpha: 0.10)
                : color.withValues(alpha: 0.7),
          ),
        ),
        Icon(icon, size: 18, color: color),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: state == _StepState.pending
                  ? context.encryptoColors.textPrimary.withValues(alpha: 0.4)
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

InputDecoration _secureInputDecoration({
  required BuildContext context,
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: context.encryptoColors.textPrimary.withValues(alpha: 0.45),
    ),
    prefixIcon: Icon(
      icon,
      color: context.encryptoColors.textPrimary.withValues(alpha: 0.60),
    ),
    filled: true,
    fillColor: context.encryptoColors.textPrimary.withValues(alpha: 0.08),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.15),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.15),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.accent, width: 1.8),
    ),
  );
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
        Icon(
          icon,
          size: 14,
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.5),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.encryptoColors.textSecondary,
            fontWeight: FontWeight.w700,
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
              ? LinearGradient(colors: [Color(0x22FFFFFF), Color(0x16FFFFFF)])
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
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          child: icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    SizedBox(width: 8),
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
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
          SizedBox(width: 8),
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
      duration: Duration(milliseconds: 2400),
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
                duration: Duration(milliseconds: 500),
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
      duration: Duration(milliseconds: 1800),
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
                duration: Duration(milliseconds: 600),
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
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
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
  _ArcPainter({required this.color});

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
  _DashedBorderPainter({required this.color, required this.radius});

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
