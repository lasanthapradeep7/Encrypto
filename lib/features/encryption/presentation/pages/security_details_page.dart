import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/core/theme/theme_controller.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_state_message.dart';

class SecurityDetailsPage extends StatelessWidget {
  const SecurityDetailsPage({super.key, required this.incidents});

  final List<Map<String, dynamic>> incidents;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final selectedTheme = ThemeController.instance.isDark
            ? AppTheme.dark
            : AppTheme.light;
        return Theme(
          data: selectedTheme,
          child: Builder(builder: _buildPage),
        );
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: context.encryptoColors.background,
      appBar: AppBar(
        backgroundColor: context.encryptoColors.background,
        foregroundColor: context.encryptoColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Security Details",
          style: TextStyle(
            color: context.encryptoColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: incidents.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EncryptionStateMessage(
                  icon: Icons.verified_user_outlined,
                  title: 'No security incidents',
                  message:
                      'Your vault is secure. Any blocked access attempts will appear here.',
                  accentColor: AppColors.success,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: encryptoCardGradient(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.encryptoColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident['incident_type'].toString(),
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Reason: ${incident['reason']}",
                        style: TextStyle(
                          color: context.encryptoColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "Device: ${incident['device_info']}",
                        style: TextStyle(
                          color: context.encryptoColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "IP: ${incident['ip_address']}",
                        style: TextStyle(
                          color: context.encryptoColors.textSecondary,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        "Date: ${incident['created_at']}",
                        style: TextStyle(
                          color: context.encryptoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
