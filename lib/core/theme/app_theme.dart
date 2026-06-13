import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF4CAF50);
  static const primaryDark = Color(0xFF2E7D32);
  static const primaryLight = Color(0xFF81C784);
  static const accent = Color(0xFF8BC34A);

  static const darkBg = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkCard = Color(0xFF222222);
  static const darkBorder = Color(0xFF2E2E2E);

  static const lightBg = Color(0xFFF5F5F5);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE0E0E0);

  static const textLight = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF9E9E9E);
  static const textGreyLight = Color(0xFF757575);

  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);

  static const gold = Color(0xFFFFD700);
  static const silver = Color(0xFFC0C0C0);
  static const bronze = Color(0xFFCD7F32);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final textTheme = TextTheme(
      displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textColor),
      displayMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textColor),
      displaySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor),
      headlineLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor),
      headlineMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor),
      headlineSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor),
      titleLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor),
      titleMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor),
      titleSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor),
      bodyLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textColor),
      bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textColor),
      bodySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textGrey),
      labelLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor),
      labelMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor),
      labelSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textGrey),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        onPrimaryContainer: isDark ? Colors.white : AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accent.withOpacity(0.15),
        onSecondaryContainer: AppColors.accent,
        error: AppColors.error,
        onError: Colors.white,
        background: bg,
        onBackground: textColor,
        surface: surface,
        onSurface: textColor,
        surfaceVariant: card,
        onSurfaceVariant: textColor.withOpacity(0.7),
        outline: borderColor,
        outlineVariant: borderColor.withOpacity(0.5),
        shadow: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
        inverseSurface: isDark ? Colors.white : Colors.black,
        onInverseSurface: isDark ? Colors.black : Colors.white,
        inversePrimary: AppColors.primaryLight,
        surfaceTint: primaryColor.withOpacity(0.05),
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: borderColor, width: 0.5)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: primaryColor, width: 1.5),
          textStyle: const TextStyle(
              fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
              fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w400),
        labelStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: textColor.withOpacity(0.7),
            fontWeight: FontWeight.w500),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 0.5,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBg,
        selectedColor: primaryColor.withOpacity(0.15),
        labelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 12, color: textColor),
        side: BorderSide(color: borderColor, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor),
        contentTextStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 14, color: textColor.withOpacity(0.8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkCard : Colors.grey[800],
        contentTextStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 14, color: Colors.white),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: primaryColor.withOpacity(0.15),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected) ? primaryColor : null),
        trackColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected)
                ? primaryColor.withOpacity(0.4)
                : null),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) =>
            states.contains(MaterialState.selected) ? primaryColor : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: AppColors.textGrey,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w400),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        textColor: textColor,
        subtitleTextStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: textColor.withOpacity(0.6)),
      ),
    );
  }
}

// Gradient helpers
class AppGradients {
  static const primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient prGradient = LinearGradient(
    colors: [AppColors.gold.withOpacity(0.8), AppColors.gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
