import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// 범위 선택 달력 헤더 위젯 (V2 - 단계적 개발)
//
// CustomCalendarHeader를 기반으로 범위 선택 기능을 단계적으로 추가합니다.
// Phase 1: 싱글 모드 정상 동작 (CustomCalendarHeader와 동일)
// Phase 2: 범위 선택 기능 추가 예정
//
// 사용 예시:
// ```dart
// CustomCalendarRangeHeaderV2(
//   focusedDay: DateTime.now(),
//   onPreviousMonth: () {
//     setState(() {
//       _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
//     });
//   },
//   onNextMonth: () {
//     setState(() {
//       _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
//     });
//   },
//   onTodayPressed: () {
//     setState(() {
//       _focusedDay = DateTime.now();
//     });
//   },
// )
// ```
class CustomCalendarRangeHeaderV2 extends StatelessWidget {
  // 현재 포커스된 날짜 (월 이동 시 변경됨)
  final DateTime focusedDay;

  // 이전 월 이동 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onPreviousMonth;

  // 다음 월 이동 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onNextMonth;

  // 오늘로 가기 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onTodayPressed;

  // 헤더 높이 (기본값: 50.0)
  final double? height;

  const CustomCalendarRangeHeaderV2({
    super.key,
    required this.focusedDay,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onTodayPressed,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final headerHeight = height ?? 50.0;

    return Container(
      height: headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 이전 월 이동 버튼
          IconButton(
            icon: Icon(Icons.chevron_left, color: p.primary, size: 28),
            onPressed: onPreviousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
          // 월/연도 표시 및 오늘로 가기 버튼
          Flexible(
            fit: FlexFit.loose,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 월/연도 텍스트
                Flexible(
                  fit: FlexFit.loose,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${focusedDay.year}년 ${focusedDay.month}월',
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 오늘로 가기 버튼
                if (onTodayPressed != null)
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: p.primary,
                      size: 20,
                    ),
                    onPressed: onTodayPressed,
                    tooltip: '오늘로 이동',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
              ],
            ),
          ),
          // 다음 월 이동 버튼
          IconButton(
            icon: Icon(Icons.chevron_right, color: p.primary, size: 28),
            onPressed: onNextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }
}

