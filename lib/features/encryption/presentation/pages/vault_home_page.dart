import 'package:flutter/material.dart';

import 'package:encrypto/core/theme/app_theme.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_chrome.dart';
import 'package:encrypto/features/encryption/presentation/widgets/encryption_state_message.dart';
import 'package:encrypto/services/api_service.dart';
import 'dart:async';

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
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isRefreshing = false;
  DateTime? _lastUpdated;
  Timer? _dashboardRefreshTimer;

  @override
  void initState() {
    super.initState();

    unawaited(_loadDashboard());

    _dashboardRefreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      unawaited(_loadDashboard(silent: true));
    });
  }

  @override
  void dispose() {
    _dashboardRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard({bool silent = false}) async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      if (!silent && _lastUpdated == null) _isLoading = true;
    });

    try {
      final dashboardResult = await ApiService.getVaultDashboard();

      final securityResult = await ApiService.getSecurityIncidents();

      if (!mounted) return;

      int encryptedFiles = 0;
      int cloudSynced = 0;
      int protectedFiles = 0;
      int securityIncidents = 0;

      List<Map<String, dynamic>> recentFiles = [];

      if (dashboardResult['status'] == 200 && dashboardResult['body'] is Map) {
        final dashboardBody = Map<String, dynamic>.from(
          dashboardResult['body'] as Map,
        );

        encryptedFiles =
            int.tryParse('${dashboardBody['encrypted_files']}') ?? 0;

        cloudSynced = int.tryParse('${dashboardBody['cloud_synced']}') ?? 0;

        protectedFiles =
            int.tryParse('${dashboardBody['protected_sessions']}') ?? 0;

        final rawRecentFiles = dashboardBody['recent_files'];

        if (rawRecentFiles is List) {
          recentFiles = rawRecentFiles
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      if (securityResult['status'] == 200 && securityResult['body'] is Map) {
        final securityBody = Map<String, dynamic>.from(
          securityResult['body'] as Map,
        );

        securityIncidents = int.tryParse('${securityBody['count']}') ?? 0;
      }

      setState(() {
        _encryptedFiles = encryptedFiles;
        _cloudSynced = cloudSynced;
        _protectedSessions = protectedFiles;
        _securityIncidents = securityIncidents;
        _recentFiles = recentFiles;
        _lastUpdated = DateTime.now();
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (error) {
      debugPrint('Dashboard loading failed: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        EncryptoTopBar(
          onNotificationsPressed: widget.onOpenNotifications,
          onSettingsPressed: widget.onOpenSettings,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: EncryptionContentContainer(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your secure vault',
                    style: textTheme.headlineSmall?.copyWith(
                      color: context.encryptoColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  _SecurityHeroCard(
                    protectedFiles: _protectedSessions,
                    totalFiles: _encryptedFiles,
                    onProtectFile: widget.onOpenWorkflow,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Overview',
                        style: textTheme.titleMedium?.copyWith(
                          color: context.encryptoColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Spacer(),
                      if (_lastUpdated != null)
                        Text(
                          'Updated just now',
                          style: textTheme.bodySmall?.copyWith(
                            color: context.encryptoColors.textPrimary
                                .withValues(alpha: 0.48),
                          ),
                        ),
                      SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Refresh dashboard',
                        onPressed: _isRefreshing ? null : _loadDashboard,
                        icon: _isRefreshing
                            ? SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                color: context.encryptoColors.textSecondary,
                                size: 20,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (_isLoading)
                    _DashboardLoadingState()
                  else
                    _MetricGrid(
                      encryptedFiles: _encryptedFiles,
                      cloudSynced: _cloudSynced,
                      protectedFiles: _protectedSessions,
                      securityIncidents: _securityIncidents,
                    ),
                  SizedBox(height: 18),
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
                              child: Icon(Icons.folder_open_rounded, size: 16),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Recent files',
                              style: textTheme.titleMedium?.copyWith(
                                color: context.encryptoColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Spacer(),

                            TextButton.icon(
                              onPressed: widget.onOpenWorkflow,
                              icon: Icon(Icons.add_rounded, size: 18),
                              label: Text('Add file'),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _VaultSearchField(
                          onChanged: (value) => setState(
                            () => _searchQuery = value.trim().toLowerCase(),
                          ),
                        ),
                        SizedBox(height: 14),
                        _RecentFileList(
                          files: _recentFiles.where((file) {
                            if (_searchQuery.isEmpty) return true;
                            return (file['name']?.toString().toLowerCase() ??
                                    '')
                                .contains(_searchQuery);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityHeroCard extends StatelessWidget {
  const _SecurityHeroCard({
    required this.protectedFiles,
    required this.totalFiles,
    required this.onProtectFile,
  });

  final int protectedFiles;
  final int totalFiles;
  final VoidCallback onProtectFile;

  @override
  Widget build(BuildContext context) {
    final progress = totalFiles == 0
        ? 0.0
        : (protectedFiles / totalFiles).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF244EC9), Color(0xFF6337C9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.18),
        ),
        boxShadow: AppShadows.accent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.encryptoColors.textPrimary.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.lock_rounded, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vault protection',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      totalFiles == 0
                          ? 'Protect your first file to get started'
                          : '$protectedFiles of $totalFiles files fully protected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: context.encryptoColors.textPrimary.withValues(
                alpha: 0.16,
              ),
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onProtectFile,
              icon: Icon(Icons.add_rounded, size: 20),
              label: Text('Protect a new file'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.accentDark,
                minimumSize: Size.fromHeight(46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.encryptedFiles,
    required this.cloudSynced,
    required this.protectedFiles,
    required this.securityIncidents,
  });

  final int encryptedFiles;
  final int cloudSynced;
  final int protectedFiles;
  final int securityIncidents;

  @override
  Widget build(BuildContext context) {
    final maxValue = [
      encryptedFiles,
      cloudSynced,
      protectedFiles,
      securityIncidents,
      1,
    ].reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: width,
              icon: Icons.lock_rounded,
              label: 'Encrypted',
              value: encryptedFiles,
              progress: encryptedFiles / maxValue,
              color: Color(0xFF60A5FA),
            ),
            _MetricCard(
              width: width,
              icon: Icons.cloud_done_rounded,
              label: 'Cloud synced',
              value: cloudSynced,
              progress: cloudSynced / maxValue,
              color: Color(0xFF34D399),
            ),
            _MetricCard(
              width: width,
              icon: Icons.verified_user_rounded,
              label: 'Protected',
              value: protectedFiles,
              progress: protectedFiles / maxValue,
              color: Color(0xFFA78BFA),
            ),
            _MetricCard(
              width: width,
              icon: Icons.warning_amber_rounded,
              label: 'Incidents',
              value: securityIncidents,
              progress: securityIncidents / maxValue,
              color: Color(0xFFF87171),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  final double width;
  final IconData icon;
  final String label;
  final int value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.encryptoColors.textPrimary.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 14),
          Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: context.encryptoColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: context.encryptoColors.textPrimary.withValues(
                alpha: 0.08,
              ),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.encryptoColors.textPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(strokeWidth: 2),
          SizedBox(height: 12),
          Text(
            'Loading your vault...',
            style: TextStyle(color: context.encryptoColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _VaultSearchField extends StatelessWidget {
  const _VaultSearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: context.encryptoColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search files',
        prefixIcon: Icon(Icons.search_rounded),
        suffixIcon: Icon(Icons.tune_rounded),
        filled: true,
        fillColor: context.encryptoColors.textPrimary.withValues(alpha: 0.08),
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}

class _RecentFileList extends StatefulWidget {
  const _RecentFileList({required this.files});

  final List<Map<String, dynamic>> files;

  @override
  State<_RecentFileList> createState() => _RecentFileListState();
}

class _RecentFileListState extends State<_RecentFileList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
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

    return Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) {
      return EncryptionStateMessage(
        icon: Icons.folder_open_outlined,
        title: 'No recent files',
        message: 'Files you encrypt or decrypt will appear here.',
        compact: true,
        showSurface: false,
      );
    }

    final vaultFiles = widget.files.map((item) {
      final fileName = item['name']?.toString() ?? 'Unknown file';

      final status = _formatStatus(item['status']);

      return _VaultFile(
        name: fileName,
        status: status,
        size: _formatSize(item['size_bytes']),
        icon: _getFileIcon(fileName),
        color: _getStatusColor(status),
      );
    }).toList();

    final hasOverflow = vaultFiles.length > 4;
    final listHeight = hasOverflow ? 310.0 : vaultFiles.length * 70.0;

    return SizedBox(
      height: listHeight,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: hasOverflow,
        interactive: true,
        radius: Radius.circular(8),
        child: ListView.separated(
          controller: _scrollController,
          primary: false,
          physics: ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(right: hasOverflow ? 10 : 0, bottom: 2),
          itemCount: vaultFiles.length,
          separatorBuilder: (_, _) => SizedBox(height: 10),
          itemBuilder: (context, index) =>
              _RecentFileTile(file: vaultFiles[index]),
        ),
      ),
    );
  }
}

class _VaultFile {
  _VaultFile({
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
          padding: EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: context.encryptoColors.textPrimary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.encryptoColors.textPrimary.withValues(alpha: 0.10),
            ),
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
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.encryptoColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      file.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: context.encryptoColors.textPrimary.withValues(
                          alpha: 0.54,
                        ),
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.more_vert_rounded,
                    color: context.encryptoColors.textPrimary.withValues(
                      alpha: 0.64,
                    ),
                    size: 20,
                  ),
                  SizedBox(height: 4),
                  Text(
                    file.size,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.encryptoColors.textPrimary.withValues(
                        alpha: 0.72,
                      ),
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
