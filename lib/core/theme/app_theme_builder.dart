import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../design/colors.dart';
import 'theme_models.dart';

/// Builds a `ThemeData` from fully-resolved settings, porting
/// `frontend/src/theme/createAppTheme.ts`'s treatment of the same 4
/// dimensions:
/// - `density` -> `VisualDensity` (comfortable/compact)
/// - `uiStyle` -> a flatter, less-decorated look when minimalist (0
///   elevation, 4px radius vs. 12px) — never touches palette colors
/// - `mode`/`primaryColor` -> a seeded `ColorScheme`
///
/// Typography is Manrope throughout, matching the mockup's deliberate
/// brand-consistency choice (both iOS and Android screens use it for
/// content; only the OS-level chrome the mockup's device frames render
/// uses native SF Pro/Roboto, which is out of this app's control anyway).
ThemeData buildAppTheme(EffectiveThemeSettings settings) {
  final isDark = settings.mode == Brightness.dark;
  final isMinimalist = settings.uiStyle == AppUiStyle.minimalist;
  final isCompact = settings.density == AppDensity.compact;

  final backgroundColor = isDark ? const Color(0xFF0B0D14) : AppColors.background;
  final surfaceColor = isDark ? const Color(0xFF12141F) : AppColors.surface;
  final borderColor = isDark ? const Color(0xFF262A3A) : AppColors.border;
  final foregroundColor = isDark ? Colors.white : AppColors.textPrimary;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: settings.primaryColor,
    brightness: settings.mode,
  ).copyWith(surface: surfaceColor);

  final radius = isMinimalist ? 4.0 : 12.0;
  final cardElevation = isMinimalist ? 0.0 : 1.0;

  final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: settings.mode,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    visualDensity: isCompact ? VisualDensity.compact : VisualDensity.standard,
    textTheme: GoogleFonts.manropeTextTheme(baseTextTheme).apply(bodyColor: foregroundColor),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: cardElevation,
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: isMinimalist ? 0 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        side: BorderSide(color: borderColor),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: borderColor),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: isDark ? const Color(0xFF1A1D2B) : const Color(0xFFEEF0F4),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? const Color(0xFF262A3A) : AppColors.divider,
      space: 1,
    ),
    // Bottom nav (Home/Leads/Leave/Profile, per the mockup) rather than the
    // web sidebar's rounded "pill" indicator - minimalist here trades the
    // filled pill indicator for a plain flat one, the closest bottom-nav
    // analog to the web's "pill -> left border" minimalist treatment.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      indicatorShape: isMinimalist
          ? const RoundedRectangleBorder()
          : const StadiumBorder(),
      indicatorColor: colorScheme.primary.withValues(alpha: isMinimalist ? 0.08 : 0.12),
    ),
  );
}
