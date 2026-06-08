import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/auth/presentation/pages/login_page.dart';
import 'package:encrypto/shared/widgets/auth/auth_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  double _passwordStrength = 0.0;

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

    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic),
    );

    _panelFade = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _panelController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = _calculateStrength(value);
    });
  }

  double _calculateStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.15;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.20;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.20;
    if (password.contains(RegExp(r'[!@#\$&*~%^()_\-+=\[\]{}|;:,.<>?]'))) {
      strength += 0.20;
    }
    return strength.clamp(0.0, 1.0);
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
                    kicker: 'Create your vault',
                    title: 'Sign up',
                    subtitle:
                        'Build your account once and protect sensitive files everywhere.',
                  ),
                  FadeTransition(
                    opacity: _panelFade,
                    child: SlideTransition(
                      position: _panelSlide,
                      child: AuthPanel(
                        child: Form(
                          key: _formKey,
                          autovalidateMode:
                              AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (b) =>
                                        AppGradients.accentHorizontal
                                            .createShader(b),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Account details',
                                    style: textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              AuthInputField(
                                hint: 'Username',
                                prefix: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Choose a username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AuthInputField(
                                hint: 'Email',
                                prefix: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: (value) {
                                  final input = value?.trim() ?? '';
                                  if (input.isEmpty) {
                                    return 'Enter your email';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                  if (!emailRegex.hasMatch(input)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              AuthInputField(
                                hint: 'Password',
                                prefix: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                controller: _passwordController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onChanged: _onPasswordChanged,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Create a password';
                                  }
                                  if (value.length < 8) {
                                    return 'Use at least 8 characters';
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
                              // Password strength meter
                              if (_passwordController.text.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _PasswordStrengthMeter(
                                  strength: _passwordStrength,
                                ),
                              ],
                              const SizedBox(height: 12),
                              AuthInputField(
                                hint: 'Confirm password',
                                prefix: Icons.verified_user_outlined,
                                obscureText: _obscureConfirm,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm your password';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              AuthInputField(
                                hint: 'Phone number',
                                prefix: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                validator: (value) {
                                  final input = value?.trim() ?? '';
                                  if (input.isEmpty) {
                                    return 'Enter your phone number';
                                  }
                                  if (input.length < 8) {
                                    return 'Phone number is too short';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              // Terms row
                              GestureDetector(
                                onTap: () {
                                  setState(() => _agreeTerms = !_agreeTerms);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Transform.scale(
                                      scale: 0.92,
                                      child: Checkbox(
                                        value: _agreeTerms,
                                        onChanged: (value) {
                                          if (value == null) return;
                                          setState(() => _agreeTerms = value);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 9),
                                        child: RichText(
                                          text: TextSpan(
                                            style:
                                                textTheme.bodyMedium,
                                            children: [
                                              const TextSpan(
                                                text: 'I agree to the ',
                                              ),
                                              TextSpan(
                                                text: 'Terms',
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: AppColors.accent,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                  color: AppColors.accent,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                              const TextSpan(text: '.'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              GradientButton(
                                label: 'Create secure account',
                                icon: Icons.shield_rounded,
                                onPressed: _agreeTerms
                                    ? () {
                                        if (_formKey.currentState
                                                ?.validate() ??
                                            false) {
                                          FocusScope.of(context).unfocus();
                                        }
                                      }
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: textTheme.bodyLarge,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context)
                                            .pushReplacement(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    ),
                                    child: const Text('Log in'),
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
// Password strength meter
// ---------------------------------------------------------------------------
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.strength});

  final double strength;

  String get _label {
    if (strength < 0.25) return 'Very weak';
    if (strength < 0.5) return 'Weak';
    if (strength < 0.75) return 'Good';
    if (strength < 0.9) return 'Strong';
    return 'Very strong';
  }

  Color get _color {
    if (strength < 0.25) return AppColors.error;
    if (strength < 0.5) return AppColors.warning;
    if (strength < 0.75) return const Color(0xFF60A5FA);
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segmented bar
        Row(
          children: List.generate(4, (i) {
            final threshold = (i + 1) / 4;
            final filled = strength >= threshold - 0.01;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: filled ? _color : AppColors.border,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password strength',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w700,
                  ),
              child: Text(_label),
            ),
          ],
        ),
      ],
    );
  }
}
