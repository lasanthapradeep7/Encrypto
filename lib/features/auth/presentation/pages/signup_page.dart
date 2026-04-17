import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/auth/presentation/pages/login_page.dart';
import 'package:encrypto/shared/widgets/auth/auth_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;

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
                    kicker: 'Create your vault',
                    title: 'Sign up',
                    subtitle:
                        'Build your account once and protect sensitive files everywhere.',
                  ),
                  AuthPanel(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account details',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          const AuthInputField(
                            hint: 'Username',
                            prefix: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          const AuthInputField(
                            hint: 'Email',
                            prefix: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 12),
                          AuthInputField(
                            hint: 'Password',
                            prefix: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
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
                          const SizedBox(height: 12),
                          AuthInputField(
                            hint: 'Confirm password',
                            prefix: Icons.verified_user_outlined,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.next,
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
                          const AuthInputField(
                            hint: 'Phone number',
                            prefix: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.scale(
                                scale: 0.92,
                                child: Checkbox(
                                  value: _agreeTerms,
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() {
                                      _agreeTerms = value;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 9),
                                  child: Text(
                                    'I agree to the Terms and Privacy Policy.',
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _agreeTerms
                                ? () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {}
                                  }
                                : null,
                            child: const Text('Create secure account'),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: textTheme.bodyLarge,
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pushReplacement(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
