import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 4개 구간(아침, 낮, 저녁, Anytime)으로 나뉜 범위 바 위젯을 생성하는 함수
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
