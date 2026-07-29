import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/services/api_service.dart';
import 'package:encrypto/services/session_service.dart';

String _errorMessage(Map<String, dynamic> result) {
  final body = result['body'];
  if (body is Map) {
    final detail = body['detail'] ?? body['message'] ?? body['error'];
    if (detail is String && detail.trim().isNotEmpty) return detail;
  }
  return 'Something went wrong. Please try again.';
}

Future<bool> showEditProfileDialog({
  required BuildContext context,
  required String initialName,
  required String initialEmail,
}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _EditProfileDialog(
          initialName: initialName,
          initialEmail: initialEmail,
        ),
      ) ??
      false;
}

Future<bool> showChangePasswordDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ChangePasswordDialog(),
      ) ??
      false;
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialName,
    required this.initialEmail,
  });

  final String initialName;
  final String initialEmail;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ApiService.updateProfile(
        fullName: _name.text,
        email: _email.text,
      );
      final status = result['status'] as int;
      if (status < 200 || status >= 300) {
        if (mounted) setState(() => _error = _errorMessage(result));
        return;
      }
      await SessionService.saveUserProfile(
        name: _name.text,
        email: _email.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to update your profile right now.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      icon: Icons.manage_accounts_outlined,
      title: 'Edit profile',
      description: 'Update the details shown on your Encrypto account.',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogField(
              controller: _name,
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.name],
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return 'Enter your full name';
                if (name.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 14),
            _DialogField(
              controller: _email,
              label: 'Email address',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: [AutofillHints.email],
              onSubmitted: (_) => _save(),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email address';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            if (_error != null) _InlineError(_error!),
          ],
        ),
      ),
      saving: _saving,
      actionLabel: 'Save changes',
      onAction: _save,
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ApiService.changePassword(
        currentPassword: _current.text,
        newPassword: _password.text,
      );
      final status = result['status'] as int;
      if (status < 200 || status >= 300) {
        if (mounted) setState(() => _error = _errorMessage(result));
        return;
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to change your password right now.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      icon: Icons.password_rounded,
      title: 'Change password',
      description:
          'Use at least 8 characters with uppercase, lowercase, and a number.',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PasswordField(
              controller: _current,
              label: 'Current password',
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.password],
              validator: (value) => (value?.isEmpty ?? true)
                  ? 'Enter your current password'
                  : null,
            ),
            SizedBox(height: 14),
            _PasswordField(
              controller: _password,
              label: 'New password',
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.newPassword],
              validator: (value) {
                final password = value ?? '';
                if (password.length < 8) return 'Use at least 8 characters';
                if (!RegExp(r'[A-Z]').hasMatch(password) ||
                    !RegExp(r'[a-z]').hasMatch(password) ||
                    !RegExp(r'[0-9]').hasMatch(password)) {
                  return 'Include uppercase, lowercase, and a number';
                }
                if (password == _current.text) {
                  return 'Choose a different password';
                }
                return null;
              },
            ),
            SizedBox(height: 14),
            _PasswordField(
              controller: _confirm,
              label: 'Confirm new password',
              textInputAction: TextInputAction.done,
              autofillHints: [AutofillHints.newPassword],
              onSubmitted: (_) => _save(),
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match' : null,
            ),
            if (_error != null) _InlineError(_error!),
          ],
        ),
      ),
      saving: _saving,
      actionLabel: 'Update password',
      onAction: _save,
    );
  }
}

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.icon,
    required this.title,
    required this.description,
    required this.content,
    required this.saving,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget content;
  final bool saving;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !saving,
      child: AlertDialog(
        backgroundColor: context.encryptoColors.background,
        insetPadding: EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.18),
          ),
        ),
        icon: Icon(icon, color: AppColors.accent, size: 38),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.encryptoColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.64,
                    ),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20),
                content,
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: saving ? null : onAction,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              minimumSize: Size(132, 46),
            ),
            child: saving
                ? SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: context.encryptoColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      cursorColor: AppColors.accent,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.encryptoColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.accent),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : context.encryptoColors.surfaceRaised,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.encryptoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent, width: 1.8),
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    required this.textInputAction,
    required this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return _DialogField(
      controller: widget.controller,
      label: widget.label,
      icon: Icons.lock_outline_rounded,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onSubmitted: widget.onSubmitted,
      obscureText: _obscured,
      suffixIcon: IconButton(
        tooltip: _obscured ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.62),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 19),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
