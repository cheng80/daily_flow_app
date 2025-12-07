import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_colors.dart';

// 범위 선택 달력 본체 위젯 (V2 - 단계적 개발)
//
// CustomCalendarBody를 기반으로 범위 선택 기능을 단계적으로 추가합니다.
// Phase 1: 싱글 모드 정상 동작 (CustomCalendarBody와 동일)
// Phase 2: 범위 선택 기능 추가 예정
//
// 사용 예시:
// ```dart
// // 싱글 모드 (Phase 1)
// CustomCalendarRangeBodyV2(
//   selectedDay: DateTime.now(),
//   focusedDay: DateTime.now(),
//   onDaySelected: (selectedDay, focusedDay) {
//     setState(() {
//       _selectedDay = selectedDay;
//       _focusedDay = focusedDay;
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
// )
// ```
class CustomCalendarRangeBodyV2 extends StatelessWidget {
  // 선택된 날짜 (싱글 모드)
  final DateTime selectedDay;

  // 현재 보이는 달의 포커스된 날짜
  final DateTime focusedDay;

  // 날짜 선택 시 호출되는 콜백 함수
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

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

  const CustomCalendarRangeBodyV2({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    this.onPageChanged,
    required this.eventLoader,
    this.calendarHeight,
    this.rowHeight,
    this.cellMargin,
    this.cellPadding,
    this.daysOfWeekHeight,
    this.cellAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context);

    // 높이 계산 로직 (CustomCalendarBody와 동일)
    double calculatedDaysOfWeekHeight;
    double calculatedRowHeight;

    double effectiveWidth;
    double effectiveHeight;

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

    // TableCalendar 위젯 생성 (CustomCalendarBody와 동일)
    final calendarWidget = TableCalendar(
      firstDay: DateTime(1900, 1, 1),
      lastDay: DateTime(2100, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
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
        selectedDecoration: BoxDecoration(
          color: p.primary.withOpacity(0.15),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: p.primary, width: 2.0),
        ),
        selectedTextStyle: TextStyle(
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
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, events) {
          final p = context.palette;
          final weekday = date.weekday;
          final isSunday = weekday == 7;
          final isSaturday = weekday == 6;

          if (!isSunday && !isSaturday) {
            return null;
          }

          final textColor = isSunday ? Colors.red.shade600 : p.primary;

          return Container(
            margin: cellMargin ?? const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        },
        todayBuilder: (context, date, events) {
          final p = context.palette;
          final isSelected = isSameDay(selectedDay, date);
          final weekday = date.weekday;
          final isSunday = weekday == 7;
          final isSaturday = weekday == 6;

          final textColor = isSunday
              ? Colors.red.shade600
              : (isSaturday ? p.primary : p.primary);

          if (isSelected) {
            return Container(
              margin: cellMargin ?? const EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: p.primary.withOpacity(0.15),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: p.primary, width: 2.0),
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: p.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          return Container(
            margin: cellMargin ?? const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: p.primary, width: 1.5),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        selectedBuilder: (context, date, events) {
          final p = context.palette;
          final weekday = date.weekday;
          final isSunday = weekday == 7;
          final isSaturday = weekday == 6;

          final textColor = isSunday
              ? Colors.red.shade700
              : (isSaturday ? p.primary : p.primary);

          return Container(
            margin: cellMargin ?? const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: p.primary.withOpacity(0.15),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: p.primary, width: 2.0),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
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
            return Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: p.accent,
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
                      color: eventCount >= 10 ? Colors.red.shade600 : p.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$eventCount',
                        style: TextStyle(
                          color: p.cardBackground,
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

