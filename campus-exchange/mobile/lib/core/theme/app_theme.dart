import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // BRAND COLORS (Cyber Modern Palette)
  // ============================================================

  static const Color primaryColor = Color(0xFF0B1128);
  static const Color primaryVariant = Color(0xFF111936);

  // Main brand & vibrant accents
  static const Color secondaryColor = Color(0xFF6366F1);
  static const Color royalBlue = Color(0xFF4F46E5);
  static const Color electricBlue = Color(0xFF6366F1);
  static const Color cyanAccent = Color(0xFF38BDF8);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color softIndigo = Color(0xFF818CF8);
  static const Color violetAccent = Color(0xFF7C3AED);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color deepPurple = Color(0xFF4338CA);

  // Semantic accents
  static const Color tealAccent = Color(0xFF0D9488);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color orangeAccent = Color(0xFFF97316);
  static const Color roseAccent = Color(0xFFF43F5E);
  static const Color pinkAccent = Color(0xFFEC4899);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFFBBF24);
  static const Color errorColor = Color(0xFFE11D48);
  static const Color infoColor = Color(0xFF38BDF8);

  // ============================================================
  // BACKGROUNDS & SURFACES
  // ============================================================

  static const Color backgroundColor = Color(0xFF0B1128);
  static const Color surfaceColor = Color(0xFF111936);
  static const Color cardColor = Color(0xFF111936);

  static const Color cardAltBackground = Color(0xFF0B1228);
  static const Color cardTonedBackground = Color(0xFF17224D);

  // ============================================================
  // TEXT & BORDERS
  // ============================================================

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color dividerColor = Color(0x1AFFFFFF);

  // ============================================================
  // GRADIENTS
  // ============================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF080D1C),
      Color(0xFF111936),
      Color(0xFF1E1B4B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF2563EB),
      Color(0xFF6366F1),
      Color(0xFF7C3AED),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF7C3AED),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [
      Color(0xFF111936),
      Color(0xFF1E1B4B),
      Color(0xFF312E81),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoVioletGradient = LinearGradient(
    colors: [
      Color(0xFF4F46E5),
      Color(0xFF7C3AED),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanTealGradient = LinearGradient(
    colors: [
      Color(0xFF06B6D4),
      Color(0xFF10B981),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [
      Color(0xFFF97316),
      Color(0xFFF59E0B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [
      Color(0xFF7C3AED),
      Color(0xFFEC4899),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient trustGradient = LinearGradient(
    colors: [
      Color(0xFF064E3B),
      Color(0xFF065F46),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient placeholderGradient = LinearGradient(
    colors: [
      Color(0xFF111936),
      Color(0xFF1E293B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================
  // SHADOWS
  // ============================================================

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get elevatedCardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get glowButtonShadow => [
        BoxShadow(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get tealGlowShadow => [
        BoxShadow(
          color: tealAccent.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get amberGlowShadow => [
        BoxShadow(
          color: amberAccent.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ============================================================
  // BORDER RADIUS
  // ============================================================

  static final BorderRadius radiusSmall = BorderRadius.circular(10);
  static final BorderRadius radiusMedium = BorderRadius.circular(14);
  static final BorderRadius radiusLarge = BorderRadius.circular(18);
  static final BorderRadius radiusExtraLarge = BorderRadius.circular(24);

  // ============================================================
  // THEME
  // ============================================================

  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: secondaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1E1B4B),
      onPrimaryContainer: Color(0xFFC7D2FE),
      secondary: Color(0xFF38BDF8),
      onSecondary: Color(0xFF0B1128),
      secondaryContainer: Color(0xFF17224D),
      onSecondaryContainer: Color(0xFFBAE6FD),
      tertiary: violetAccent,
      onTertiary: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimary,
      surfaceContainerLowest: Color(0xFF080D1C),
      surfaceContainerLow: Color(0xFF0B1128),
      surfaceContainer: Color(0xFF111936),
      surfaceContainerHigh: Color(0xFF17224D),
      error: errorColor,
      onError: Colors.white,
      outline: Color(0x26FFFFFF),
      outlineVariant: Color(0x14FFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 22,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
          size: 22,
        ),
      ),

      // ----------------------------------------------------------
      // CARD
      // ----------------------------------------------------------
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ELEVATED BUTTON
      // ----------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
          animationDuration: const Duration(milliseconds: 180),
        ),
      ),

      // ----------------------------------------------------------
      // OUTLINED BUTTON
      // ----------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF60A5FA),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // TEXT BUTTON
      // ----------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF60A5FA),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // INPUT FIELDS
      // ----------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardAltBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textMuted,
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textSecondary,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF60A5FA),
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: const Color(0xFF60A5FA),
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6366F1),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1.5,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // CHIPS
      // ----------------------------------------------------------
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF111936),
        selectedColor: secondaryColor,
        disabledColor: const Color(0xFF0B1228),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),

      // ----------------------------------------------------------
      // NAVIGATION BAR
      // ----------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0B1128),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        height: 72,
        indicatorColor: const Color(0xFF1E1B4B),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF60A5FA),
              );
            }
            return const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Color(0xFF60A5FA),
                size: 24,
              );
            }
            return const IconThemeData(
              color: textMuted,
              size: 23,
            );
          },
        ),
      ),

      // ----------------------------------------------------------
      // FLOATING ACTION BUTTON
      // ----------------------------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ----------------------------------------------------------
      // DIVIDERS
      // ----------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),

      // ----------------------------------------------------------
      // DIALOG
      // ----------------------------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF111936),
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Color(0xFFCBD5E1),
          fontSize: 13.5,
          height: 1.5,
        ),
      ),

      // ----------------------------------------------------------
      // BOTTOM SHEET
      // ----------------------------------------------------------
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF111936),
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        showDragHandle: true,
        dragHandleColor: Colors.white.withValues(alpha: 0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
          side: BorderSide(
            color: Color(0x1FFFFFFF),
          ),
        ),
      ),

      // ----------------------------------------------------------
      // SNACKBAR
      // ----------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF17224D),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),

      // ----------------------------------------------------------
      // PROGRESS INDICATORS
      // ----------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF60A5FA),
        linearTrackColor: Color(0xFF1E1B4B),
        circularTrackColor: Color(0xFF1E1B4B),
      ),

      // ----------------------------------------------------------
      // LIST TILE
      // ----------------------------------------------------------
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        minVerticalPadding: 8,
        iconColor: textSecondary,
        textColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
      ),
    );
  }
}
