// 앱 전용 공용 유틸리티 함수 및 클래스 모음
//
// 이 파일은 이 앱(daily_flow_app)에서만 사용되는 공용 함수나 클래스들을 담는 공간입니다.
//
// **사용 목적:**
// - 앱 전역에서 공통으로 사용되는 함수들
// - 앱 특화된 비즈니스 로직 함수들
// - 앱 내 여러 화면에서 재사용되는 유틸리티 함수들
// - 앱 전용 데이터 모델 클래스들
//
// **범용 함수와의 구분:**
// - 범용 함수들은 `lib/util/common_util.dart`에 위치합니다.
// - 여러 프로젝트에서 재사용 가능한 일반적인 유틸리티는 `common_util.dart`에 있습니다.
//
// **포함된 기능:**
// - `actionFourRangeBar`: Summary Bar 위젯 생성 함수
// - `AppSummaryRatios`: Summary Bar 비율 정보 클래스
// - `calculateSummaryRatios`: 날짜별 Todo Step 비율 계산 함수
// - `calculateAndUpdateSummaryRatios`: 비율 계산 및 콜백 처리 함수
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../vm/database_handler.dart';
import 'step_mapper_util.dart';

/// 5개 구간(오전, 오후, 저녁, 야간, 종일)으로 나뉜 범위 바 위젯 생성
ClipRRect actionFourRangeBar(
  BuildContext context, {
  required double barWidth,
  required double barHeight,
  required double morningRatio,
  required double noonRatio,
  required double eveningRatio,
  required double nightRatio,
  required double anytimeRatio,
}) {
  final p = context.palette;
  double total =
      morningRatio + noonRatio + eveningRatio + nightRatio + anytimeRatio;

  if (total == 0) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: barHeight,
        width: barWidth,
        color: p.divider, // 비어 있을 때 연한 회색
      ),
    );
  }

  int flex(double part) {
    final v = (part / total * 100).round();
    return v == 0 ? 1 : v; // 0 구간도 최소 1은 차지하게
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(999), // 양끝 둥글게
    child: SizedBox(
      height: barHeight,
      width: barWidth,
      child: Row(
        children: [
          Expanded(
            flex: flex(morningRatio),
            child: Container(color: p.progressMorning),
          ),
          Expanded(
            flex: flex(noonRatio),
            child: Container(color: p.progressNoon),
          ),
          Expanded(
            flex: flex(eveningRatio),
            child: Container(color: p.progressEvening),
          ),
          Expanded(
            flex: flex(nightRatio),
            child: Container(color: p.progressNight),
          ),
          Expanded(
            flex: flex(anytimeRatio),
            child: Container(color: p.progressAnytime),
          ),
        ],
      ),
    ),
  );
}

// Summary Bar 비율 정보 클래스
//
// 선택된 날짜의 Todo를 Step별로 계산한 비율 정보를 담는 클래스입니다.
class AppSummaryRatios {
  // 오전 비율 (0.0 ~ 1.0)
  final double morningRatio;

  // 오후 비율 (0.0 ~ 1.0)
  final double noonRatio;

  // 저녁 비율 (0.0 ~ 1.0)
  final double eveningRatio;

  // 야간 비율 (0.0 ~ 1.0)
  final double nightRatio;

  // 종일 비율 (0.0 ~ 1.0)
  final double anytimeRatio;

  const AppSummaryRatios({
    required this.morningRatio,
    required this.noonRatio,
    required this.eveningRatio,
    required this.nightRatio,
    required this.anytimeRatio,
  });

  // 모든 비율이 0인 경우 (데이터 없음)
  static const AppSummaryRatios empty = AppSummaryRatios(
    morningRatio: 0.0,
    noonRatio: 0.0,
    eveningRatio: 0.0,
    nightRatio: 0.0,
    anytimeRatio: 0.0,
  );
}

// 선택된 날짜의 일정을 Step별로 비율 계산
//
// 선택된 날짜의 모든 Todo를 조회하여 Step별 개수를 세고,
// 전체 대비 비율을 계산하여 반환합니다.
//
// [dbHandler] DatabaseHandler 인스턴스
// [date] 조회할 날짜 ('YYYY-MM-DD' 형식)
//
// 반환값: AppSummaryRatios 객체 (오전/오후/저녁/종일 비율)
//
// 사용 예시:
// ```dart
// final ratios = await calculateSummaryRatios(dbHandler, '2025-12-01');
// actionFourRangeBar(
//   context,
//   barWidth: 300,
//   barHeight: 20,
//   morningRatio: ratios.morningRatio,
//   noonRatio: ratios.noonRatio,
//   eveningRatio: ratios.eveningRatio,
//   anytimeRatio: ratios.anytimeRatio,
// );
// ```
Future<AppSummaryRatios> calculateSummaryRatios(
  DatabaseHandler dbHandler,
  String date,
) async {
  try {
    final todos = await dbHandler.queryDataByDate(date);

    // Step별 개수 세기
    int morningCount = 0;
    int noonCount = 0;
    int eveningCount = 0;
    int nightCount = 0;
    int anytimeCount = 0;

    for (var todo in todos) {
      switch (todo.step) {
        case StepMapperUtil.stepMorning:
          morningCount++;
          break;
        case StepMapperUtil.stepNoon:
          noonCount++;
          break;
        case StepMapperUtil.stepEvening:
          eveningCount++;
          break;
        case StepMapperUtil.stepNight:
          nightCount++;
          break;
        case StepMapperUtil.stepAnytime:
        default:
          anytimeCount++;
          break;
      }
    }

    // 전체 개수 계산
    final totalCount = todos.length;

    // 비율 계산 (전체가 0이면 모두 0.0)
    if (totalCount == 0) {
      return AppSummaryRatios.empty;
    }

    return AppSummaryRatios(
      morningRatio: morningCount / totalCount,
      noonRatio: noonCount / totalCount,
      eveningRatio: eveningCount / totalCount,
      nightRatio: nightCount / totalCount,
      anytimeRatio: anytimeCount / totalCount,
    );
  } catch (e) {
    print("Error calculating summary ratios: $e");
    // 에러 발생 시 빈 비율 반환
    return AppSummaryRatios.empty;
  }
}

// 선택된 날짜의 일정을 Step별로 비율 계산하고 콜백으로 결과 전달
//
// 선택된 날짜의 모든 Todo를 조회하여 Step별 비율을 계산하고,
// 계산된 결과를 콜백 함수로 전달합니다.
// 이 함수는 상태 업데이트 로직을 콜백으로 분리하여 여러 화면에서 재사용 가능합니다.
//
// [dbHandler] DatabaseHandler 인스턴스
// [date] 조회할 날짜 ('YYYY-MM-DD' 형식 또는 DateTime)
// [onRatiosCalculated] 비율 계산 완료 시 호출되는 콜백 함수
//   - AppSummaryRatios: 계산된 비율 데이터
//
// 사용 예시:
// ```dart
// await calculateAndUpdateSummaryRatios(
//   dbHandler,
//   '2025-12-01',
//   onRatiosCalculated: (ratios) {
//     setState(() {
//       _morningRatio = ratios.morningRatio;
//       _noonRatio = ratios.noonRatio;
//       _eveningRatio = ratios.eveningRatio;
//       _anytimeRatio = ratios.anytimeRatio;
//     });
//   },
// );
// ```
Future<void> calculateAndUpdateSummaryRatios(
  DatabaseHandler dbHandler,
  dynamic date, {
  required void Function(AppSummaryRatios) onRatiosCalculated,
}) async {
  // DateTime인 경우 문자열로 변환
  String dateStr;
  if (date is DateTime) {
    dateStr =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  } else {
    dateStr = date.toString();
  }

  final ratios = await calculateSummaryRatios(dbHandler, dateStr);
  onRatiosCalculated(ratios);

  // 디버그 로그 출력
  print(
    'Summary Bar 비율 계산 완료 - 오전: ${(ratios.morningRatio * 100).toStringAsFixed(1)}%, '
    '오후: ${(ratios.noonRatio * 100).toStringAsFixed(1)}%, '
    '저녁: ${(ratios.eveningRatio * 100).toStringAsFixed(1)}%, '
    '종일: ${(ratios.anytimeRatio * 100).toStringAsFixed(1)}%',
  );
}

// 우선순위에 따른 색상 반환
//
// [priority] 우선순위 값 (1~5)
// [p] AppColorScheme 객체
//
// 반환값: 우선순위에 맞는 색상
//
// 사용 예시:
// ```dart
// final color = getPriorityColor(5, context.palette);
// ```
Color getPriorityColor(int priority, AppColorScheme p) {
  switch (priority) {
    case 1:
      return p.dailyFlow.priorityVeryLow;
    case 2:
      return p.dailyFlow.priorityLow;
    case 3:
      return p.dailyFlow.priorityMedium;
    case 4:
      return p.dailyFlow.priorityHigh;
    case 5:
      return p.dailyFlow.priorityVeryHigh;
    default:
      return p.dailyFlow.priorityMedium;
  }
}

// 우선순위에 따른 텍스트 반환
//
// [priority] 우선순위 값 (1~5)
//
// 반환값: 우선순위에 맞는 한국어 텍스트
//
// 사용 예시:
// ```dart
// final text = getPriorityText(5); // "매우 높음"
// ```
String getPriorityText(int priority) {
  switch (priority) {
    case 1:
      return "매우 낮음";
    case 2:
      return "낮음";
    case 3:
      return "보통";
    case 4:
      return "높음";
    case 5:
      return "매우 높음";
    default:
      return "보통";
  }
}

// 날짜와 시간 문자열을 DateTime으로 파싱
//
// [date] 'YYYY-MM-DD' 형식의 날짜 문자열
// [time] 'HH:MM' 형식의 시간 문자열
// 반환값: 파싱된 DateTime 객체 (실패 시 null)
//
// 사용 예시:
// ```dart
// final dateTime = parseDateTime('2024-12-07', '14:30');
// if (dateTime != null) {
//   print('파싱된 시간: $dateTime');
// }
// ```
DateTime? parseDateTime(String date, String time) {
  try {
    final dateParts = date.split('-');
    final timeParts = time.split(':');

    if (dateParts.length != 3 || timeParts.length != 2) {
      return null;
    }

    return DateTime(
      int.parse(dateParts[0]), // year
      int.parse(dateParts[1]), // month
      int.parse(dateParts[2]), // day
      int.parse(timeParts[0]), // hour
      int.parse(timeParts[1]), // minute
    );
  } catch (e) {
    print('날짜/시간 파싱 오류: $e');
    return null;
  }
}
