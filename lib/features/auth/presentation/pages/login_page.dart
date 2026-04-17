import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/auth/presentation/pages/signup_page.dart';
import 'package:encrypto/shared/widgets/auth/auth_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
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
                  AuthPanel(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick access', style: textTheme.headlineMedium),
                          const SizedBox(height: 14),
                          Row(
                            children: const [
                              Expanded(
                                child: _BiometricOption(
                                  icon: Icons.face_unlock_outlined,
                                  label: 'Face ID',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _BiometricOption(
                                  icon: Icons.fingerprint,
                                  label: 'Fingerprint',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.border.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  'or sign in with credentials',
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.border.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AuthInputField(
                            hint: 'Email or username',
                            prefix: Icons.person_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          AuthInputField(
                            hint: 'Password',
                            prefix: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
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
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _rememberMe = value;
                                    });
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
                                child: const Text('Forgot password?'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {}
                            },
                            child: const Text('Log in securely'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BiometricOption extends StatelessWidget {
  const _BiometricOption({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: AppColors.accentDark),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
