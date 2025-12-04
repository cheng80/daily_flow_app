import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. 한 테마(라이트/다크 등)에 해당하는 컬러 세트 정의
// -----------------------------------------------------------------------------

class AppColorScheme {
  final Color background;      // 전체 배경 색
  final Color cardBackground;  // 카드/패널 배경 색
  final Color primary;         // 주요 포인트 색
  final Color accent;          // 보조 포인트 색
  final Color textPrimary;     // 기본 텍스트 색
  final Color textSecondary;   // 보조 텍스트 색
  final Color divider;         // 구분선 색

  // 필터 칩용 색상
  final Color chipSelectedBg;
  final Color chipSelectedText;
  final Color chipUnselectedBg;
  final Color chipUnselectedText;

  // 요약 Progress Bar (아침/낮/저녁/Anytime)
  final Color progressMorning;
  final Color progressNoon;
  final Color progressEvening;
  final Color progressAnytime;

  const AppColorScheme({
    required this.background,
    required this.cardBackground,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.chipSelectedBg,
    required this.chipSelectedText,
    required this.chipUnselectedBg,
    required this.chipUnselectedText,
    required this.progressMorning,
    required this.progressNoon,
    required this.progressEvening,
    required this.progressAnytime,
  });
}

// -----------------------------------------------------------------------------
// 2. 라이트 / 다크 팔레트 정의
// -----------------------------------------------------------------------------

class AppColors {
  const AppColors._();

  // 라이트 테마 팔레트
  static const AppColorScheme light = AppColorScheme(
    background: Color(0xFFF7F7F7),
    cardBackground: Colors.white,
    primary: Color(0xFF4A90E2),
    accent: Color(0xFFFFC107),
    textPrimary: Color(0xFF222222),
    textSecondary: Color(0xFF777777),
    divider: Color(0xFFE0E0E0),
    chipSelectedBg: Color(0xFF4A90E2),
    chipSelectedText: Colors.white,
    chipUnselectedBg: Color(0xFFE3F2FD),
    chipUnselectedText: Color(0xFF1565C0),
    progressMorning: Color(0xFFFFA726), // 아침
    progressNoon: Color(0xFFFFEE58),    // 낮
    progressEvening: Color(0xFF26C6DA), // 저녁
    progressAnytime: Color(0xFFAB47BC), // Anytime
  );

  // 다크 테마 팔레트
  static const AppColorScheme dark = AppColorScheme(
    background: Color(0xFF121212),
    cardBackground: Color(0xFF1E1E1E),
    primary: Color(0xFF90CAF9),
    accent: Color(0xFFFFD54F),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    divider: Color(0xFF424242),
    chipSelectedBg: Color(0xFF90CAF9),
    chipSelectedText: Color(0xFF0D47A1),
    chipUnselectedBg: Color(0xFF263238),
    chipUnselectedText: Color(0xFFB0BEC5),
    progressMorning: Color(0xFFFFB74D),
    progressNoon: Color(0xFFFFF176),
    progressEvening: Color(0xFF4DD0E1),
    progressAnytime: Color(0xFFBA68C8),
  );
}

// -----------------------------------------------------------------------------
// 3. 앱 내부에서 사용할 테마 모드 enum
// -----------------------------------------------------------------------------

enum AppThemeMode {
  light,
  dark,
}

// -----------------------------------------------------------------------------
// 4. BuildContext 확장 – context.palette 로 현재 팔레트 접근
// -----------------------------------------------------------------------------

// 실제 앱에서는 InheritedWidget / Provider / GetX 등으로 AppThemeMode를 보관하고,
// 아래 확장 내부에서 현재 모드에 맞는 AppColorScheme를 반환하는 식으로 사용할 수 있다.
// 여기서는 가장 단순한 예제로, Theme.of(context).brightness를 기준으로 분기한다.

extension PaletteContext on BuildContext {
  AppColorScheme get palette {
    final brightness = Theme.of(this).brightness;
    if (brightness == Brightness.dark) {
      return AppColors.dark;
    } else {
      return AppColors.light;
    }
  }
}