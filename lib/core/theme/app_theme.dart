import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color backgroundStart = Color(0xFF060B18);
  static const Color backgroundEnd = Color(0xFF0D1830);

  // Auth panel
  static const Color panel = Color(0xFFFAFBFF);

  // Text
  static const Color textPrimary = Color(0xFF151B2C);
  static const Color textSecondary = Color(0xFF5A637A);

  // Input
  static const Color inputFill = Color(0xFFF0F4FD);
  static const Color border = Color(0xFFD4DCF0);

  // Accent family
  static const Color accent = Color(0xFF3B7BFF);
  static const Color accentMid = Color(0xFF5B5BFF);
  static const Color accentDark = Color(0xFF1947C8);
  static const Color accentSoft = Color(0xFFDCE6FF);
  static const Color accentGlow = Color(0x552F6BFF);
  static const Color onAccent = Colors.white;

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFD97706);
  static const Color error = Color(0xFFEF4444);

  // Dark surface tokens
  static const Color surfaceCard = Color(0x12FFFFFF);
  static const Color surfaceCardBorder = Color(0x1FFFFFFF);
  static const Color surfaceHighlight = Color(0x0AFFFFFF);

  // Overlay
  static const Color overlay = Color(0x99000000);
}

@immutable
class EncryptoColors extends ThemeExtension<EncryptoColors> {
  const EncryptoColors({
    required this.background,
    required this.backgroundEnd,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.icon,
    required this.shadow,
  });

  final Color background;
  final Color backgroundEnd;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color icon;
  final Color shadow;

  static const dark = EncryptoColors(
    background: Color(0xFF050608),
    backgroundEnd: Color(0xFF0B0B0D),
    surface: Color(0x0FFFFFFF),
    surfaceRaised: Color(0x16FFFFFF),
    border: Color(0x24FFFFFF),
    textPrimary: Colors.white,
    textSecondary: Color(0xB8FFFFFF),
    icon: Color(0xE6FFFFFF),
    shadow: Color(0x33000000),
  );

  static const light = EncryptoColors(
    background: Color(0xFFF5F7FB),
    backgroundEnd: Color(0xFFEDF2FA),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF8FAFD),
    border: Color(0xFFDCE3EF),
    textPrimary: Color(0xFF172033),
    textSecondary: Color(0xFF657086),
    icon: Color(0xFF4B5870),
    shadow: Color(0x1A172033),
  );

  @override
  EncryptoColors copyWith({
    Color? background,
    Color? backgroundEnd,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? icon,
    Color? shadow,
  }) {
    return EncryptoColors(
      background: background ?? this.background,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      icon: icon ?? this.icon,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  EncryptoColors lerp(covariant EncryptoColors? other, double t) {
    if (other == null) return this;
    return EncryptoColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension EncryptoThemeContext on BuildContext {
  EncryptoColors get encryptoColors =>
      Theme.of(this).extension<EncryptoColors>() ?? EncryptoColors.dark;
}

LinearGradient encryptoCardGradient(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return AppGradients.card;
  }
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFD)],
  );
}

class AppGradients {
  AppGradients._();

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF72BAFF), Color(0xFF3B7BFF), Color(0xFF1947C8)],
  );

  static const LinearGradient accentHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF3B7BFF), Color(0xFF7C3AFF)],
  );

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x18FFFFFF), Color(0x08FFFFFF)],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), Color(0xFF059669)],
  );

  static const LinearGradient processing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF2563EB)],
  );

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF93C5FD), Color(0xFF3B7BFF), Color(0xFF1E3A8A)],
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> accent = [
    BoxShadow(
      color: Color(0x663B7BFF),
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> accentGlow = [
    BoxShadow(
      color: Color(0x883B7BFF),
      blurRadius: 40,
      spreadRadius: -8,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> panel = [
    BoxShadow(color: Color(0x26000000), blurRadius: 32, offset: Offset(0, -10)),
  ];

  static const List<BoxShadow> navCenter = [
    BoxShadow(
      color: Color(0x993B7BFF),
      blurRadius: 28,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final textTheme = GoogleFonts.spaceGroteskTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.accent,
            onPrimary: AppColors.onAccent,
            surface: AppColors.panel,
            error: AppColors.error,
          ),
      scaffoldBackgroundColor: EncryptoColors.light.background,
      extensions: const [EncryptoColors.light],
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1.2,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error, width: 2.0),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textSecondary,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: AppColors.onAccent,
          side: const BorderSide(color: Colors.white, width: 1.4),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: AppColors.border, width: 1.4),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return Colors.white;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EncryptoColors.light.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF172033),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData get dark {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.backgroundStart,
            error: AppColors.error,
          ),
      scaffoldBackgroundColor: AppColors.backgroundStart,
      extensions: const [EncryptoColors.dark],
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundStart,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF202534),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFFCBD3E0),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.accent
              : const Color(0xFF343A46),
        ),
      ),
    );
  }
}
