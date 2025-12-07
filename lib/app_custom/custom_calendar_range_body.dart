import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_colors.dart';

// 범위 선택 달력 본체 위젯
//
// TableCalendar를 기반으로 한 범위 선택 달력 본체입니다.
// 시작일과 종료일을 선택할 수 있는 기능을 제공합니다.
//
// 사용 예시:
// ```dart
// CustomCalendarRangeBody(
//   focusedDay: DateTime.now(),
//   selectedRange: DateTimeRange(
//     start: DateTime(2025, 12, 1),
//     end: DateTime(2025, 12, 7),
//   ),
//   onRangeSelected: (start, end) {
//     setState(() {
//       _selectedRange = DateTimeRange(start: start, end: end);
//     });
//   },
//   onPageChanged: (focusedDay) {
//     setState(() {
//       _focusedDay = focusedDay;
//     });
//   },
//   eventLoader: (day) {
//     return databaseHandler.queryDataByDate(formatDate(day));
//   },
//   calendarHeight: 400.0,
//   cellAspectRatio: 1.0,
//   minDate: DateTime(2025, 9, 1),
//   maxDate: DateTime(2025, 12, 31),
// )
// ```
class CustomCalendarRangeBody extends StatelessWidget {
  // 현재 보이는 달의 포커스된 날짜
  final DateTime focusedDay;

  // 선택된 날짜 범위 (시작일과 종료일)
  final DateTimeRange? selectedRange;

  // 날짜 범위 선택 시 호출되는 콜백 함수
  // start: 시작일, end: 종료일 (null일 수 있음)
  final void Function(DateTime start, DateTime? end) onRangeSelected;

  // 페이지 변경 시 호출되는 콜백 함수 (월 이동 시)
  final void Function(DateTime focusedDay)? onPageChanged;

  // 날짜별 이벤트(Todo) 리스트를 반환하는 함수
  final List<dynamic> Function(DateTime day) eventLoader;

  // 달력 위젯의 높이 (픽셀)
  final double? calendarHeight;

  // 행 높이 (각 날짜 셀의 높이)
  final double? rowHeight;

  // 셀 마진 (각 날짜 셀 주변의 여백)
  final EdgeInsets? cellMargin;

  // 셀 패딩 (각 날짜 셀 내부의 여백)
  final EdgeInsets? cellPadding;

  // 요일 헤더 높이
  final double? daysOfWeekHeight;

  // 셀의 세로 기준 비율 (기본값: 1.0 = 정사각형)
  final double cellAspectRatio;

  // 선택 가능한 최소 날짜 (null이면 제한 없음)
  final DateTime? minDate;

  // 선택 가능한 최대 날짜 (null이면 제한 없음)
  final DateTime? maxDate;

  const CustomCalendarRangeBody({
    super.key,
    required this.focusedDay,
    this.selectedRange,
    required this.onRangeSelected,
    this.onPageChanged,
    required this.eventLoader,
    this.calendarHeight,
    this.rowHeight,
    this.cellMargin,
    this.cellPadding,
    this.daysOfWeekHeight,
    this.cellAspectRatio = 1.0,
    this.minDate,
    this.maxDate,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context);

    // focusedDay가 날짜 범위 내에 있는지 확인하고 조정
    DateTime adjustedFocusedDay = focusedDay;
    final firstDay = minDate ?? DateTime(1900, 1, 1);
    final lastDay = maxDate ?? DateTime(2100, 12, 31);
    
    if (adjustedFocusedDay.isBefore(firstDay)) {
      adjustedFocusedDay = firstDay;
    } else if (adjustedFocusedDay.isAfter(lastDay)) {
      adjustedFocusedDay = lastDay;
    }

    // 높이 계산 로직
    double calculatedDaysOfWeekHeight;
    double calculatedRowHeight;

    double effectiveWidth = 0;
    double effectiveHeight = 0;

    if (calendarHeight != null && calendarHeight! > 0) {
      if (cellAspectRatio == 1.0) {
        effectiveHeight = calendarHeight!;
        effectiveWidth = calendarHeight!;
      } else {
        effectiveHeight = calendarHeight! * cellAspectRatio;
        effectiveWidth = calendarHeight!;
      }

      final availableHeight = effectiveHeight - 16.0;
      final availableWidth = effectiveWidth - 16.0;

      if (cellAspectRatio == 1.0) {
        final cellAreaWidth = availableWidth / 7.0;
        final cellAreaHeight = availableHeight / 8.0;

        final cellSize = cellAreaWidth < cellAreaHeight
            ? cellAreaWidth
            : cellAreaHeight;

        final totalCellHeight = cellSize * 6.0;
        final headerAndDaysHeight = availableHeight - totalCellHeight;
        final daysH = (headerAndDaysHeight * 0.455).clamp(30.0, 50.0);

        calculatedDaysOfWeekHeight = daysH;
        calculatedRowHeight = cellSize.clamp(30.0, 80.0);
      } else {
        final headerH = (availableHeight * 0.12).clamp(40.0, 60.0);
        final daysH = (availableHeight * 0.10).clamp(30.0, 50.0);

        final cellAreaWidth = availableWidth / 7.0;
        final cellAreaHeight = (availableHeight - headerH - daysH) / 6.0;

        final calculatedCellHeight = cellAreaWidth * cellAspectRatio;
        final maxCellHeight = cellAreaHeight;
        final finalCellHeight = calculatedCellHeight < maxCellHeight
            ? calculatedCellHeight
            : maxCellHeight;

        calculatedRowHeight = finalCellHeight.clamp(30.0, 80.0);
        calculatedDaysOfWeekHeight = daysH;
      }
    } else {
      final screenWidth = MediaQuery.of(context).size.width;
      effectiveWidth = screenWidth;
      final cellWidth = (screenWidth - 16.0) / 7.0;
      final rowH = (cellWidth * cellAspectRatio).clamp(30.0, 80.0);
      final daysH = 40.0;

      calculatedDaysOfWeekHeight = daysH;
      calculatedRowHeight = rowH;
    }

    // daysOfWeekHeight가 명시적으로 지정된 경우 사용
    if (daysOfWeekHeight != null) {
      calculatedDaysOfWeekHeight = daysOfWeekHeight!;
    }

    // rowHeight가 명시적으로 지정된 경우 사용
    if (rowHeight != null) {
      calculatedRowHeight = rowHeight!;
    }

    // 날짜 범위 판별 함수
    bool isStartDate(DateTime day) {
      if (selectedRange == null) return false;
      return isSameDay(day, selectedRange!.start);
    }

    bool isEndDate(DateTime day) {
      if (selectedRange == null) return false;
      return isSameDay(day, selectedRange!.end);
    }

    // TableCalendar 위젯 생성
    final calendarWidget = TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: adjustedFocusedDay,
      rangeSelectionMode: RangeSelectionMode.enforced,
      rangeStartDay: selectedRange?.start,
      rangeEndDay: selectedRange?.end,
      onRangeSelected: (start, end, focusedDay) {
        // table_calendar의 onRangeSelected는 날짜를 클릭할 때마다 호출됩니다.
        // 첫 번째 클릭: start는 클릭한 날짜, end는 null
        // 두 번째 클릭: start는 첫 번째 날짜, end는 두 번째 날짜
        // 같은 날짜를 다시 클릭하면: start와 end가 모두 null (선택 해제)
        
        if (start == null && end == null) {
          // 선택이 해제된 경우
          onRangeSelected(focusedDay, null);
        } else if (start != null) {
          // 시작일과 종료일 자동 정렬
          if (end != null && end.isBefore(start)) {
            // 역순으로 선택한 경우 자동 정렬
            onRangeSelected(end, start);
          } else {
            onRangeSelected(start, end);
          }
        }
      },
      onPageChanged: onPageChanged,
      eventLoader: eventLoader,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: locale.toString(),
      headerVisible: false,
      daysOfWeekHeight: calculatedDaysOfWeekHeight,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      rowHeight: calculatedRowHeight,
      calendarStyle: CalendarStyle(
        defaultDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),
        defaultTextStyle: TextStyle(color: p.textPrimary, fontSize: 14),
        weekendTextStyle: TextStyle(color: p.textPrimary, fontSize: 14),
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: p.primary, width: 1.5),
        ),
        todayTextStyle: TextStyle(
          color: p.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        outsideDaysVisible: true,
        outsideTextStyle: TextStyle(
          color: p.textSecondary.withOpacity(0.5),
          fontSize: 14,
        ),
        outsideDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),
        weekendDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),
        cellPadding: cellPadding ?? EdgeInsets.zero,
        cellMargin: cellMargin ?? const EdgeInsets.all(2.0),
        markersMaxCount: 0,
        // 시작일: Primary 색상 (파란색 계열)
        rangeStartDecoration: BoxDecoration(
          color: p.primary,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
          ),
        ),
        rangeStartTextStyle: TextStyle(
          color: p.cardBackground,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        // 종료일: Accent 색상 (주황색 계열) - 시작일과 구분
        rangeEndDecoration: BoxDecoration(
          color: p.accent,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
        ),
        rangeEndTextStyle: TextStyle(
          color: p.cardBackground,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        // 범위 내 날짜 스타일 (시작일과 종료일 제외)
        // 시작일과 종료일 색상의 중간 톤으로 표시
        withinRangeDecoration: BoxDecoration(
          color: Color.lerp(p.primary, p.accent, 0.5)?.withOpacity(0.2) ?? p.primary.withOpacity(0.2),
          shape: BoxShape.rectangle,
        ),
        withinRangeTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 14,
        ),
      ),
      // calendarBuilders를 완전히 제거하여 기본 빌더 사용
      // 터치 이벤트가 정상 작동하도록 함
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          int eventCount = 0;
          try {
            final eventsList = events as List;
            eventCount = eventsList.length;
          } catch (e) {
            eventCount = 0;
          }

          if (eventCount > 0) {
            final p = context.palette;
            final isStart = isStartDate(date);
            final isEnd = isEndDate(date);

            return Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isStart || isEnd) ? p.cardBackground : p.accent,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: (isStart || isEnd)
                          ? p.cardBackground
                          : (eventCount >= 10 ? Colors.red.shade600 : p.primary),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$eventCount',
                        style: TextStyle(
                          color: (isStart || isEnd) ? p.primary : p.cardBackground,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );

    // calendarHeight가 지정된 경우 크기를 제한하여 cellAspectRatio를 정확히 유지
    if (calendarHeight != null && calendarHeight! > 0) {
      return SizedBox(
        width: effectiveWidth, // 정확한 너비
        height: effectiveHeight, // 정확한 높이
        child: Container(
          width: effectiveWidth, // 명시적으로 너비 설정
          height: effectiveHeight, // 명시적으로 높이 설정
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: p.cardBackground,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: calendarWidget,
        ),
      );
    } else {
      // calendarHeight가 지정되지 않은 경우 기존 방식 유지
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: p.cardBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: calendarWidget,
      );
    }
  }
}

// DateTime 확장: 하루의 시작 시간
extension DateTimeExtension on DateTime {
  DateTime startOfDay() {
    return DateTime(year, month, day);
  }

  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

