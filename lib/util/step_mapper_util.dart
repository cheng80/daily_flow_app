/// 시간 → Step 매핑 유틸리티
///
/// 시간 문자열('HH:MM' 형식)을 Step 값(0=아침, 1=낮, 2=저녁, 3=Anytime)으로 변환하는 기능을 제공합니다.
///
/// 시간대 구분 규칙:
/// - 아침 (0): 06:00 ~ 11:59
/// - 낮 (1): 12:00 ~ 17:59
/// - 저녁 (2): 18:00 ~ 23:59
/// - Anytime (3): 00:00 ~ 05:59 (새벽) 또는 시간 없음
///
/// 사용 예시:
/// ```dart
/// final step = StepMapperUtil.mapTimeToStep("14:30"); // 1 (낮)
/// final korean = StepMapperUtil.stepToKorean(0); // "아침"
/// ```

class StepMapperUtil {
  /// Step 값 상수
  static const int stepMorning = 0; // 아침
  static const int stepNoon = 1; // 낮
  static const int stepEvening = 2; // 저녁
  static const int stepAnytime = 3; // Anytime (기본값)

  /// 시간 문자열을 Step 값으로 변환
  ///
  /// [time] 시간 문자열 ('HH:MM' 형식, 예: '14:30')
  /// null이거나 빈 문자열인 경우 Anytime(3)을 반환합니다.
  ///
  /// 반환값: Step 값 (0=아침, 1=낮, 2=저녁, 3=Anytime)
  ///
  /// 시간대 구분:
  /// - 06:00 ~ 11:59 → 아침 (0)
  /// - 12:00 ~ 17:59 → 낮 (1)
  /// - 18:00 ~ 23:59 → 저녁 (2)
  /// - 00:00 ~ 05:59 → Anytime (3)
  /// - null 또는 빈 문자열 → Anytime (3)
  static int mapTimeToStep(String? time) {
    // null이거나 빈 문자열인 경우 Anytime 반환
    if (time == null || time.trim().isEmpty) {
      return stepAnytime;
    }

    try {
      // 'HH:MM' 형식 파싱
      final parts = time.split(':');
      if (parts.length != 2) {
        // 형식이 올바르지 않으면 Anytime 반환
        return stepAnytime;
      }

      final hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());

      // 시간 범위 검증
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        // 유효하지 않은 시간이면 Anytime 반환
        return stepAnytime;
      }

      // 시간대 구분
      if (hour >= 6 && hour < 12) {
        // 06:00 ~ 11:59 → 아침
        return stepMorning;
      } else if (hour >= 12 && hour < 18) {
        // 12:00 ~ 17:59 → 낮
        return stepNoon;
      } else if (hour >= 18 && hour < 24) {
        // 18:00 ~ 23:59 → 저녁
        return stepEvening;
      } else {
        // 00:00 ~ 05:59 → Anytime (새벽)
        return stepAnytime;
      }
    } catch (e) {
      // 파싱 오류 시 Anytime 반환
      return stepAnytime;
    }
  }

  /// Step 값을 한국어 문자열로 변환
  ///
  /// [step] Step 값 (0=아침, 1=낮, 2=저녁, 3=Anytime)
  ///
  /// 반환값: 한국어 문자열 ("아침", "낮", "저녁", "Anytime")
  ///
  /// 유효하지 않은 Step 값인 경우 "Anytime"을 반환합니다.
  static String stepToKorean(int step) {
    switch (step) {
      case stepMorning:
        return "아침";
      case stepNoon:
        return "낮";
      case stepEvening:
        return "저녁";
      case stepAnytime:
      default:
        return "Anytime";
    }
  }
}

