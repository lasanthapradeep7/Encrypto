import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/services/api_service.dart';

class VaultHomePage extends StatefulWidget {
  const VaultHomePage({
    super.key,
    required this.onOpenWorkflow,
    required this.onOpenSteganographyWorkflow,
    required this.onOpenProfile,
    required this.onOpenNotifications,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenSteganographyWorkflow;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSettings;

  @override
  State<VaultHomePage> createState() => _VaultHomePageState();
}

class _VaultHomePageState extends State<VaultHomePage> {
  int _encryptedFiles = 0;
  int _cloudSynced = 0;
  int _protectedSessions = 0;
  int _securityIncidents = 0;

  List<Map<String, dynamic>> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
  try {
    final dashboardResult =
        await ApiService.getVaultDashboard();

    final securityResult =
        await ApiService.getSecurityIncidents();

    if (!mounted) return;

    int encryptedFiles = 0;
    int cloudSynced = 0;
    int protectedFiles = 0;
    int securityIncidents = 0;

    List<Map<String, dynamic>> recentFiles = [];

    if (dashboardResult['status'] == 200 &&
        dashboardResult['body'] is Map) {
      final dashboardBody =
          Map<String, dynamic>.from(
        dashboardResult['body'] as Map,
      );

      encryptedFiles = int.tryParse(
            '${dashboardBody['encrypted_files']}',
          ) ??
          0;

      cloudSynced = int.tryParse(
            '${dashboardBody['cloud_synced']}',
          ) ??
          0;

      protectedFiles = int.tryParse(
            '${dashboardBody['protected_sessions']}',
          ) ??
          0;

          final rawRecentFiles = dashboardBody['recent_files'];

if (rawRecentFiles is List) {
  recentFiles = rawRecentFiles
      .whereType<Map>()
      .map(
        (item) => Map<String, dynamic>.from(item),
      )
      .toList();
}
    }

    if (securityResult['status'] == 200 &&
        securityResult['body'] is Map) {
      final securityBody =
          Map<String, dynamic>.from(
        securityResult['body'] as Map,
      );

      securityIncidents = int.tryParse(
            '${securityBody['count']}',
          ) ??
          0;
    }

    setState(() {
      _encryptedFiles = encryptedFiles;
      _cloudSynced = cloudSynced;
      _protectedSessions = protectedFiles;
      _securityIncidents = securityIncidents;
      _recentFiles = recentFiles;
    });
  } catch (error) {
    debugPrint('Dashboard loading failed: $error');
  }
}
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          onProfilePressed: widget.onOpenProfile,
          onNotificationsPressed: widget.onOpenNotifications,
          onSettingsPressed: widget.onOpenSettings,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Page header
                  Row(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) =>
                            AppGradients.accentHorizontal.createShader(b),
                        child: const Icon(Icons.layers_rounded, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure Vault',
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Manage protected files & sessions',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Summary card
                  EncryptionSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (b) =>
                                  AppGradients.accentHorizontal.createShader(b),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Vault summary',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _SummaryRow(
                          icon: Icons.lock_rounded,
                          label: 'Encrypted files',
                          value: _encryptedFiles.toString(),
                          color: const Color(0xFF60A5FA),
                        ),
                        _SummaryDivider(),
                        _SummaryRow(
                          icon: Icons.cloud_done_rounded,
                          label: 'Cloud synced',
                          value: _cloudSynced.toString(),
                          color: Color(0xFF34D399),
                        ),
                        _SummaryDivider(),
                        _SummaryRow(
                          icon: Icons.verified_user_rounded,
                          label: 'Protected files',
                          value: _protectedSessions.toString(),
                          color: Color(0xFFA78BFA),
                        ),
                        _SummaryDivider(),
                        _SummaryRow(
                          icon: Icons.warning_amber_rounded,
                          label: 'Security incidents',
                          value: _securityIncidents.toString(),
                          color: const Color(0xFFF87171),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Recent files card
                  EncryptionSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (b) =>
                                  AppGradients.accentHorizontal.createShader(b),
                              child: const Icon(
                                Icons.folder_open_rounded,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Recent files',
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: widget.onOpenWorkflow,
                              child: const Text('Add file'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _VaultSearchField(),
                        const SizedBox(height: 14),
                        _RecentFileList(
                          files: _recentFiles,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (b) => LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
          ).createShader(b),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _VaultSearchField extends StatelessWidget {
  const _VaultSearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.58),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search for files...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.54),
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
          Icon(
            Icons.tune_rounded,
            color: Colors.white.withValues(alpha: 0.68),
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _RecentFileList extends StatelessWidget {
  const _RecentFileList({
    required this.files,
  });

  final List<Map<String, dynamic>> files;

  String _formatSize(dynamic sizeBytes) {
    final bytes = int.tryParse('$sizeBytes');

    if (bytes == null || bytes <= 0) {
      return 'Size unavailable';
    }

    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatStatus(dynamic status) {
    final value = status?.toString() ?? 'uploaded';

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  IconData _getFileIcon(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png')) {
      return Icons.image_rounded;
    }

    if (name.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    }

    if (name.endsWith('.txt')) {
      return Icons.text_snippet_rounded;
    }

    return Icons.insert_drive_file_rounded;
  }

  Color _getStatusColor(String status) {
    final value = status.toLowerCase();

    if (value.contains('decrypted')) {
      return AppColors.success;
    }

    if (value.contains('encrypted')) {
      return AppColors.accent;
    }

    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.folder_off_outlined,
              color: Colors.white.withValues(alpha: 0.45),
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              'No recent files available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      );
    }

    final vaultFiles = files.map((item) {
      final fileName =
          item['name']?.toString() ?? 'Unknown file';

      final status =
          _formatStatus(item['status']);

      return _VaultFile(
        name: fileName,
        status: status,
        size: _formatSize(item['size_bytes']),
        icon: _getFileIcon(fileName),
        color: _getStatusColor(status),
      );
    }).toList();

    return Column(
      children: [
        for (var index = 0;
            index < vaultFiles.length;
            index++) ...[
          _RecentFileTile(
            file: vaultFiles[index],
          ),
          if (index != vaultFiles.length - 1)
            const SizedBox(height: 10),
        ],
      ],
    );
  }
}


class _VaultFile {
  const _VaultFile({
    required this.name,
    required this.status,
    required this.size,
    required this.icon,
    required this.color,
  });

  final String name;
  final String status;
  final String size;
  final IconData icon;
  final Color color;
}

class _RecentFileTile extends StatelessWidget {
  const _RecentFileTile({required this.file});

  final _VaultFile file;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: file.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: file.color.withValues(alpha: 0.28)),
                ),
                child: Icon(file.icon, color: file.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      file.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.54),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white.withValues(alpha: 0.64),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file.size,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
