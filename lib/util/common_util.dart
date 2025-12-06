import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../vm/database_handler.dart';
import '../util/step_mapper_util.dart';

/// 4개 구간(오전, 오후, 저녁, 종일)으로 나뉜 범위 바 위젯을 생성하는 함수
///
/// 사용 예시:
/// ```dart
/// actionFourRangeBar(
///   context,
///   barWidth: 300,
///   barHeight: 40,
///   morningRatio: 0.2,
///   noonRatio: 0.3,
///   eveningRatio: 0.4,
///   anytimeRatio: 0.1,
/// )
/// ```
ClipRRect actionFourRangeBar(
  BuildContext context, {
  required double barWidth,
  required double barHeight,
  required double morningRatio,
  required double noonRatio,
  required double eveningRatio,
  required double anytimeRatio,
}) {
  final p = context.palette;
  double total = morningRatio + noonRatio + eveningRatio + anytimeRatio;

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
            flex: flex(anytimeRatio),
            child: Container(color: p.progressAnytime),
          ),
        ],
      ),
    ),
  );
}

/// Summary Bar 비율 정보 클래스
///
/// 선택된 날짜의 Todo를 Step별로 계산한 비율 정보를 담는 클래스입니다.
class SummaryRatios {
  /// 오전 비율 (0.0 ~ 1.0)
  final double morningRatio;

  /// 오후 비율 (0.0 ~ 1.0)
  final double noonRatio;

  /// 저녁 비율 (0.0 ~ 1.0)
  final double eveningRatio;

  /// 종일 비율 (0.0 ~ 1.0)
  final double anytimeRatio;

  const SummaryRatios({
    required this.morningRatio,
    required this.noonRatio,
    required this.eveningRatio,
    required this.anytimeRatio,
  });

  /// 모든 비율이 0인 경우 (데이터 없음)
  static const SummaryRatios empty = SummaryRatios(
    morningRatio: 0.0,
    noonRatio: 0.0,
    eveningRatio: 0.0,
    anytimeRatio: 0.0,
  );
}

/// 선택된 날짜의 일정을 Step별로 비율 계산
///
/// 선택된 날짜의 모든 Todo를 조회하여 Step별 개수를 세고,
/// 전체 대비 비율을 계산하여 반환합니다.
///
/// [dbHandler] DatabaseHandler 인스턴스
/// [date] 조회할 날짜 ('YYYY-MM-DD' 형식)
///
/// 반환값: SummaryRatios 객체 (오전/오후/저녁/종일 비율)
///
/// 사용 예시:
/// ```dart
/// final ratios = await calculateSummaryRatios(dbHandler, '2025-12-01');
/// actionFourRangeBar(
///   context,
///   barWidth: 300,
///   barHeight: 20,
///   morningRatio: ratios.morningRatio,
///   noonRatio: ratios.noonRatio,
///   eveningRatio: ratios.eveningRatio,
///   anytimeRatio: ratios.anytimeRatio,
/// );
/// ```
Future<SummaryRatios> calculateSummaryRatios(
  DatabaseHandler dbHandler,
  String date,
) async {
  try {
    final todos = await dbHandler.queryDataByDate(date);

    // Step별 개수 세기
    int morningCount = 0;
    int noonCount = 0;
    int eveningCount = 0;
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
      return SummaryRatios.empty;
    }

    return SummaryRatios(
      morningRatio: morningCount / totalCount,
      noonRatio: noonCount / totalCount,
      eveningRatio: eveningCount / totalCount,
      anytimeRatio: anytimeCount / totalCount,
    );
  } catch (e) {
    print("Error calculating summary ratios: $e");
    // 에러 발생 시 빈 비율 반환
    return SummaryRatios.empty;
  }
}

/// 선택된 날짜의 일정을 Step별로 비율 계산하고 콜백으로 결과 전달
///
/// 선택된 날짜의 모든 Todo를 조회하여 Step별 비율을 계산하고,
/// 계산된 결과를 콜백 함수로 전달합니다.
/// 이 함수는 상태 업데이트 로직을 콜백으로 분리하여 여러 화면에서 재사용 가능합니다.
///
/// [dbHandler] DatabaseHandler 인스턴스
/// [date] 조회할 날짜 ('YYYY-MM-DD' 형식 또는 DateTime)
/// [onRatiosCalculated] 비율 계산 완료 시 호출되는 콜백 함수
///   - SummaryRatios: 계산된 비율 데이터
///
/// 사용 예시:
/// ```dart
/// await calculateAndUpdateSummaryRatios(
///   dbHandler,
///   '2025-12-01',
///   onRatiosCalculated: (ratios) {
///     setState(() {
///       _morningRatio = ratios.morningRatio;
///       _noonRatio = ratios.noonRatio;
///       _eveningRatio = ratios.eveningRatio;
///       _anytimeRatio = ratios.anytimeRatio;
///     });
///   },
/// );
/// ```
Future<void> calculateAndUpdateSummaryRatios(
  DatabaseHandler dbHandler,
  dynamic date, {
  required void Function(SummaryRatios) onRatiosCalculated,
}) async {
  // DateTime인 경우 문자열로 변환
  String dateStr;
  if (date is DateTime) {
    dateStr = '${date.year.toString().padLeft(4, '0')}-'
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
