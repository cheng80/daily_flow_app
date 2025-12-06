import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 달력 헤더 위젯
///
/// 월/연도 표시, 이전/다음 월 이동 버튼, 오늘로 가기 버튼을 포함합니다.
///
/// 사용 예시:
/// ```dart
/// CustomCalendarHeader(
///   focusedDay: DateTime.now(),
///   onPreviousMonth: () {
///     setState(() {
///       _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
///     });
///   },
///   onNextMonth: () {
///     setState(() {
///       _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
///     });
///   },
///   onTodayPressed: () {
///     setState(() {
///       _focusedDay = DateTime.now();
///     });
///   },
/// )
/// ```
class CustomCalendarHeader extends StatelessWidget {
  /// 현재 포커스된 날짜 (월 이동 시 변경됨)
  final DateTime focusedDay;

  /// 이전 월 이동 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onPreviousMonth;

  /// 다음 월 이동 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onNextMonth;

  /// 오늘로 가기 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onTodayPressed;

  /// 헤더 높이 (기본값: 50.0)
  final double? height;

  const CustomCalendarHeader({
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 월/연도 텍스트
                Flexible(
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

