import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/pages/encryption_shell.dart';
import 'package:encrypto/features/auth/presentation/pages/signup_page.dart';
import 'package:encrypto/shared/widgets/auth/auth_layout.dart';
import 'package:encrypto/services/api_service.dart';

final emailController = TextEditingController();
final passwordController = TextEditingController();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _localAuth = LocalAuthentication();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _biometricsAvailable = false;
  bool _authenticating = false;

  late final AnimationController _panelController;
  late final Animation<Offset> _panelSlide;
  late final Animation<double> _panelFade;

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _panelSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic),
        );

    _panelFade = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOut,
    );

    _loadBiometricStatus();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricStatus() async {
    try {
      final biometricsAvailable = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      final deviceSupported = await _localAuth.isDeviceSupported();

      if (!mounted) return;
      setState(() {
        _biometricsAvailable =
            biometricsAvailable &&
            deviceSupported &&
            availableBiometrics.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _biometricsAvailable = false);
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_biometricsAvailable || _authenticating) {
      _showAuthMessage('Biometric unlock is not available on this device.');
      return;
    }

    setState(() => _authenticating = true);

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to unlock your encrypted vault.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (!mounted) return;
      if (authenticated) {
        _openVault();
      } else {
        _showAuthMessage('Biometric authentication was cancelled.');
      }
    } catch (_) {
      if (mounted) {
        _showAuthMessage('Biometric authentication failed. Use your password.');
      }
    } finally {
      if (mounted) {
        setState(() => _authenticating = false);
      }
    }
  }

  void _openVault() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const EncryptionShell(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showAuthMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Column(
                children: [
                  const AuthTitleBlock(
                    kicker: 'Welcome back',
                    title: 'Sign in',
                    subtitle:
                        'Access your encrypted vault with biometric shortcuts or your password.',
                  ),
                  FadeTransition(
                    opacity: _panelFade,
                    child: SlideTransition(
                      position: _panelSlide,
                      child: AuthPanel(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quick access label
                              Row(
                                children: [
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (b) => AppGradients
                                        .accentHorizontal
                                        .createShader(b),
                                    child: const Icon(
                                      Icons.bolt_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Quick access',
                                    style: textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _BiometricOption(
                                      icon: Icons.face_unlock_outlined,
                                      label: 'Face ID',
                                      enabled:
                                          _biometricsAvailable &&
                                          !_authenticating,
                                      onTap: _authenticateWithBiometrics,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _BiometricOption(
                                      icon: Icons.fingerprint,
                                      label: 'Fingerprint',
                                      enabled:
                                          _biometricsAvailable &&
                                          !_authenticating,
                                      onTap: _authenticateWithBiometrics,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              // Gradient divider
                              _GradientDivider(
                                label: 'or sign in with credentials',
                              ),
                              const SizedBox(height: 18),
                              AuthInputField(
                                controller: emailController,
                                hint: 'Email or username',
                                prefix: Icons.person_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your email or username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AuthInputField(
                                controller: passwordController,
                                hint: 'Password',
                                prefix: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 0.92,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _rememberMe = value);
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Keep me signed in on this device',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('Forgot?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              GradientButton(
                                label: 'Log in securely',
                                icon: Icons.lock_open_rounded,
                                onPressed: () async {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }

                                  final result = await ApiService.login(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                  );

                                  if (!mounted) return;

                                  if (result["status"] == 200) {
                                    final token =
                                        result["body"]["access_token"];

                                    print("JWT TOKEN: $token");

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Login Success"),
                                      ),
                                    );

                                    _openVault();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result["body"]["detail"].toString(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('New here?', style: textTheme.bodyLarge),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const SignUpPage(),
                                      ),
                                    ),
                                    child: const Text('Create account'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

// ---------------------------------------------------------------------------
// Gradient-border biometric tile
// ---------------------------------------------------------------------------
class _BiometricOption extends StatefulWidget {
  const _BiometricOption({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  State<_BiometricOption> createState() => _BiometricOptionState();
}

class _BiometricOptionState extends State<_BiometricOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final enabled = widget.enabled;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          decoration: BoxDecoration(
            color: !enabled
                ? AppColors.inputFill.withValues(alpha: 0.56)
                : _pressed
                ? AppColors.accentSoft.withValues(alpha: 0.5)
                : AppColors.inputFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _pressed ? AppColors.accent : AppColors.border,
              width: _pressed ? 1.8 : 1.2,
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (b) =>
                    AppGradients.accentHorizontal.createShader(b),
                child: Icon(widget.icon, size: 32),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                style: textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
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
// Gradient-fade divider
// ---------------------------------------------------------------------------
class _GradientDivider extends StatelessWidget {
  const _GradientDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.border.withValues(alpha: 0.8),
              ],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.border.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: Container(height: 1, color: AppColors.border),
          ),
        ),
      ],
    );
  }
}
