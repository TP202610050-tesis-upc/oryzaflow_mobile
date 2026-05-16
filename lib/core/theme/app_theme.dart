import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const darkPrimary = Color(0xFF66BB6A);
    const darkOnPrimary = Colors.black;
    const darkError = Color(0xFFCF6679);
    const darkScaffoldBg = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);
    const darkSurfaceElevated = Color(0xFF252525);
    const darkOutline = Color(0xFF3A3A3A);
    const darkOnSurface = Color(0xFFEEEEEE);
    const darkOnSurfaceSecondary = Color(0xFF9E9E9E);
    const darkOnSurfaceDisabled = Color(0xFF5E5E5E);
    const darkNavBg = Color(0xFF1A1A1A);
    const darkDrawerBg = Color(0xFF1A1A1A);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      secondary: darkPrimary,
      onSecondary: darkOnPrimary,
      error: darkError,
      onError: Colors.black,
      surface: darkSurface,
      onSurface: darkOnSurface,
      outline: darkOutline,
      surfaceContainerHighest: darkSurfaceElevated,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkScaffoldBg,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme.apply(
          bodyColor: darkOnSurface,
          displayColor: darkOnSurface,
        ),
      ).copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: darkOnSurface),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: darkOnSurface),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: darkOnSurface),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: darkOnSurface),
        bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: darkOnSurface),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: darkOnSurfaceSecondary),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: darkOnSurface),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: darkOnSurfaceSecondary),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: darkOnSurfaceDisabled),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: const BorderSide(color: darkOutline, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXs, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkNavBg,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        foregroundColor: darkOnSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: darkOutline,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: darkOnSurface),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: darkNavBg,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkNavBg,
        indicatorColor: darkPrimary.withAlpha(40),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: darkPrimary);
          }
          return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: darkOnSurfaceSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: darkPrimary, size: 22);
          }
          return const IconThemeData(color: darkOnSurfaceSecondary, size: 22);
        }),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkDrawerBg,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: darkError, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: darkOnSurfaceSecondary),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: darkOnSurfaceDisabled),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceElevated,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: darkPrimary),
        side: const BorderSide(color: darkPrimary, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingS, vertical: AppDimensions.paddingXs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusS)),
      ),
      dividerTheme: const DividerThemeData(
        color: darkOutline,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingM, vertical: AppDimensions.paddingXs),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return darkOnSurfaceDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return darkPrimary;
          return darkOutline;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: darkOnSurface),
      ),
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.verde,
      brightness: Brightness.light,
      surface: AppColors.superficie,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fondo,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textoPrimario),
        headlineMedium: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textoPrimario),
        titleLarge: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textoPrimario),
        titleMedium: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textoPrimario),
        bodyLarge: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textoPrimario),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textoSecundario),
        labelLarge: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textoPrimario),
        labelMedium: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textoSecundario),
        labelSmall: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textoDeshabilitado),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        color: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          side: const BorderSide(color: AppColors.borde, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingXs,
            horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.superficie,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        foregroundColor: AppColors.textoPrimario,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.borde,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textoPrimario,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.superficie,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        indicatorColor: AppColors.verdeChip,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.verde);
          }
          return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textoSecundario);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.verde, size: 22);
          }
          return const IconThemeData(color: AppColors.textoSecundario, size: 22);
        }),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.superficie,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verde,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.verde,
          side: const BorderSide(color: AppColors.verde, width: 1.5),
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          textStyle: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.verde,
          textStyle: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.verde, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.critico),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          borderSide: const BorderSide(color: AppColors.critico, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textoSecundario),
        hintStyle: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textoDeshabilitado),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.verdeFondo,
        labelStyle: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.verde),
        side: const BorderSide(color: AppColors.verdeClaro, width: 0.5),
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingS,
            vertical: AppDimensions.paddingXs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borde,
        thickness: 1,
        space: 0,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingXs),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textoDeshabilitado;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.verde;
          return AppColors.borde;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        contentTextStyle: GoogleFonts.inter(fontSize: 14),
      ),
    );
  }
}
