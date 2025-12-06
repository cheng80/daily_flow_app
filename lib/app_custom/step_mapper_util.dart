/// 시간 → Step 매핑 유틸리티
///
/// 시간 문자열('HH:MM' 형식)을 Step 값(0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)으로 변환하는 기능을 제공합니다.
///
/// 시간대 구분 규칙:
/// - 오전 (0): 06:00 ~ 11:59
/// - 오후 (1): 12:00 ~ 17:59
/// - 저녁 (2): 18:00 ~ 23:59
/// - 야간 (3): 00:00 ~ 05:59
/// - 종일 (4): 00:00 ~ 23:59 또는 시간 없음
///
/// 사용 예시:
/// ```dart
/// final step = StepMapperUtil.mapTimeToStep("14:30"); // 1 (오후)
/// final korean = StepMapperUtil.stepToKorean(0); // "오전"
/// ```
library;

class StepMapperUtil {
  /// Step 값 상수
  static const int stepMorning = 0; // 오전
  static const int stepNoon = 1; // 오후
  static const int stepEvening = 2; // 저녁
  static const int stepNight = 3; // 야간
  static const int stepAnytime = 4; // 종일 (기본값)

  /// 시간 문자열을 Step 값으로 변환
  ///
  /// [time] 시간 문자열 ('HH:MM' 형식, 예: '14:30')
  /// null이거나 빈 문자열인 경우 Anytime(4)을 반환합니다.
  ///
  /// 반환값: Step 값 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
  ///
  /// 시간대 구분:
  /// - 06:00 ~ 11:59 → 오전 (0)
  /// - 12:00 ~ 17:59 → 오후 (1)
  /// - 18:00 ~ 23:59 → 저녁 (2)
  /// - 00:00 ~ 05:59 → 야간 (3)
  /// - null 또는 빈 문자열 → 종일 (4)
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
        // 06:00 ~ 11:59 → 오전
        return stepMorning;
      } else if (hour >= 12 && hour < 18) {
        // 12:00 ~ 17:59 → 오후
        return stepNoon;
      } else if (hour >= 18) {
        // 18:00 ~ 23:59 → 저녁
        return stepEvening;
      } else {
        // 00:00 ~ 05:59 → 야간
        return stepNight;
      }
    } catch (e) {
      // 파싱 오류 시 Anytime 반환
      return stepAnytime;
    }
  }

  /// Step 값을 한국어 문자열로 변환
  ///
  /// [step] Step 값 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
  ///
  /// 반환값: 한국어 문자열 ("오전", "오후", "저녁", "야간", "종일")
  ///
  /// 유효하지 않은 Step 값인 경우 "종일"을 반환합니다.
  static String stepToKorean(int step) {
    switch (step) {
      case stepMorning:
        return "오전";
      case stepNoon:
        return "오후";
      case stepEvening:
        return "저녁";
      case stepNight:
        return "야간";
      case stepAnytime:
      default:
        return "종일";
    }
  }

  /// Step 값에 해당하는 시간 범위를 반환
  ///
  /// [step] Step 값 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
  ///
  /// 반환값: 시간 범위 문자열 ("06:00-11:59", "12:00-17:59", "18:00-23:59", "00:00-05:59", "00:00-23:59")
  ///
  /// 유효하지 않은 Step 값인 경우 "00:00-23:59"을 반환합니다.
  static String stepToTimeRange(int step) {
    switch (step) {
      case stepMorning:
        return "06:00-11:59";
      case stepNoon:
        return "12:00-17:59";
      case stepEvening:
        return "18:00-23:59";
      case stepNight:
        return "00:00-05:59";
      case stepAnytime:
      default:
        return "00:00-23:59";
    }
  }
}

