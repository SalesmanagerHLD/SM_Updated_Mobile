import 'package:flutter/material.dart';

typedef ChipColors = ({Color fg, Color bg});

/// The color system extracted from the Claude Design mockup
/// (`SalesManager CRM Mobile.dc.html`) — semantic status/interest/leave/
/// notification colors, independent of the org-configurable theme
/// (`core/theme/`). These mirror the web app's `LEAD_STATUS_COLORS` /
/// `ACTIVITY_TYPE_COLORS` / etc. maps: fixed per-category colors that don't
/// change with an org's brand color, mode, or density.
class AppColors {
  AppColors._();

  // Neutral palette (mockup default / Standard uiStyle, light mode).
  static const background = Color(0xFFF6F7F9);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE6E8EC);
  static const divider = Color(0xFFF0F1F4);
  static const textPrimary = Color(0xFF12151B);
  static const textSecondary = Color(0xFF667085);
  static const textTertiary = Color(0xFF98A2B3);

  static const neutralChip = (fg: Color(0xFF667085), bg: Color(0xFFF0F1F4));

  /// `LeadStatus` -> chip colors. Only the statuses the mockup actually
  /// shows have bespoke colors (NEGOTIATION/INTERESTED/CONTACTED/LOST);
  /// everything else (NEW/CLOSED_WON/LAPSED) falls back to [neutralChip]
  /// rather than guessing an unverified color.
  static const Map<String, ChipColors> _leadStatusChips = {
    'NEGOTIATION': (fg: Color(0xFF7C3AED), bg: Color(0xFFF3ECFE)),
    'INTERESTED': (fg: Color(0xFF0F766E), bg: Color(0xFFE6F4F1)),
    'CONTACTED': (fg: Color(0xFF3547E0), bg: Color(0xFFEEF0FD)),
    'LOST': (fg: Color(0xFFB42318), bg: Color(0xFFFBEAE8)),
  };

  static ChipColors leadStatusChip(String status) => _leadStatusChips[status] ?? neutralChip;

  // Interest-level indicator dot colors (Hot/Warm/Cold).
  static const hotInterest = Color(0xFFC2410C);
  static const warmInterest = Color(0xFFB54708);
  static const coldInterest = Color(0xFF98A2B3);

  static Color interestDotColor(String? code) => switch (code) {
    'HOT' => hotInterest,
    'WARM' => warmInterest,
    _ => coldInterest,
  };

  // Leave request status chips.
  static const Map<String, ChipColors> _leaveStatusChips = {
    'PENDING': (fg: Color(0xFFB54708), bg: Color(0xFFFDF1E8)),
    'APPROVED': (fg: Color(0xFF12805C), bg: Color(0xFFE7F6EF)),
    'REJECTED': (fg: Color(0xFFB42318), bg: Color(0xFFFBEAE8)),
  };

  static ChipColors leaveStatusChip(String status) => _leaveStatusChips[status] ?? neutralChip;

  // Notification type accent colors (icon-in-circle background + dot).
  static const Map<String, ChipColors> _notificationChips = {
    'LEAD_REASSIGNED': (fg: Color(0xFFB42318), bg: Color(0xFFFBEAE8)),
    'VISIT_MISSED': (fg: Color(0xFFB54708), bg: Color(0xFFFDF1E8)),
    'LEAD_LAPSED': (fg: Color(0xFF98A2B3), bg: Color(0xFFF0F1F4)),
    'LEAD_LAPSED_DIGEST': (fg: Color(0xFF98A2B3), bg: Color(0xFFF0F1F4)),
    'LEAVE_REQUEST_APPROVED': (fg: Color(0xFF12805C), bg: Color(0xFFE7F6EF)),
    'LEAVE_REQUEST_SUBMITTED': (fg: Color(0xFFB54708), bg: Color(0xFFFDF1E8)),
    'LEAVE_REQUEST_REJECTED': (fg: Color(0xFFB42318), bg: Color(0xFFFBEAE8)),
  };

  static ChipColors notificationChip(String type) => _notificationChips[type] ?? neutralChip;
}
