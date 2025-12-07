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
  // 선택된 날짜 (싱글 모드, 기존 CustomCalendarBody와 호환성)
  final DateTime? selectedDay;

  // 현재 보이는 달의 포커스된 날짜
  final DateTime focusedDay;

  // 날짜 선택 시 호출되는 콜백 함수 (싱글 모드)
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;

  // 선택된 날짜 범위 (시작일과 종료일)
  final DateTimeRange? selectedRange;
  
  // 범위 선택 시작일 (종료일이 없을 때도 표시용)
  final DateTime? rangeStart;

  // 범위 선택 기능 활성화 여부 (기본값: false)
  // true: 범위 선택 모드, false: 단일 날짜 선택 모드
  final bool enableRangeSelection;

  // 날짜 범위 선택 시 호출되는 콜백 함수 (optional)
  // start: 시작일, end: 종료일 (null일 수 있음)
  // enableRangeSelection이 true일 때만 사용됨
  final void Function(DateTime start, DateTime? end)? onRangeSelected;

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

  const CustomCalendarRangeBodyV2({
    super.key,
    this.selectedDay,
    required this.focusedDay,
    this.onDaySelected,
    this.selectedRange,
    this.rangeStart,
    this.enableRangeSelection = false,
    this.onRangeSelected,
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

    // Step 4: focusedDay가 날짜 범위 내에 있는지 확인하고 조정
    DateTime adjustedFocusedDay = focusedDay;
    // 단일 모드일 때는 focusedDay 기준으로 적절한 범위 설정 (1900년대 방지)
    // 단일 모드: 현재 날짜 기준 ±10년, 범위 모드: minDate/maxDate 사용
    final now = DateTime.now();
    final firstDay = enableRangeSelection && minDate != null 
        ? minDate! 
        : DateTime(now.year - 10, 1, 1); // 현재 날짜 기준 10년 전
    final lastDay = enableRangeSelection && maxDate != null 
        ? maxDate! 
        : DateTime(now.year + 10, 12, 31); // 현재 날짜 기준 10년 후
    
    if (enableRangeSelection) {
      if (adjustedFocusedDay.isBefore(firstDay)) {
        adjustedFocusedDay = firstDay;
      } else if (adjustedFocusedDay.isAfter(lastDay)) {
        adjustedFocusedDay = lastDay;
      }
    } else {
      // 단일 모드일 때도 focusedDay가 firstDay/lastDay 범위 내에 있는지 확인
      if (adjustedFocusedDay.isBefore(firstDay)) {
        adjustedFocusedDay = firstDay;
      } else if (adjustedFocusedDay.isAfter(lastDay)) {
        adjustedFocusedDay = lastDay;
      }
    }

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

    // TableCalendar 위젯 생성
    // 싱글 모드일 때는 CustomCalendarBody와 동일하게 동작
    // 범위 선택 모드일 때만 날짜 제약 조건 적용
    final calendarWidget = TableCalendar(
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: adjustedFocusedDay,
      // 싱글 모드일 때는 CustomCalendarBody와 동일하게 설정
      selectedDayPredicate: enableRangeSelection
          ? null
          : (selectedDay != null ? (day) => isSameDay(day, selectedDay!) : null),
      onDaySelected: enableRangeSelection
          ? null
          : (onDaySelected != null
              ? (selectedDay, focusedDay) {
                  // 싱글 모드일 때는 날짜 제약 조건 체크 없이 직접 전달 (CustomCalendarBody와 동일)
                  onDaySelected!(selectedDay, focusedDay);
                }
              : null),
      rangeSelectionMode: enableRangeSelection
          ? RangeSelectionMode.enforced
          : RangeSelectionMode.disabled,
      rangeStartDay: selectedRange?.start ?? rangeStart,
      rangeEndDay: selectedRange?.end,
      onRangeSelected: enableRangeSelection && onRangeSelected != null
          ? (start, end, focusedDay) {
              // table_calendar의 onRangeSelected는 날짜를 클릭할 때마다 호출됩니다.
              // 첫 번째 클릭: start는 클릭한 날짜, end는 null
              // 두 번째 클릭: start는 첫 번째 날짜, end는 두 번째 날짜
              // 같은 날짜를 다시 클릭하면: start와 end가 모두 null (선택 해제)
              
              // 날짜 제약 조건 체크 함수 (에러 없이 무시)
              bool isDateInRange(DateTime? date) {
                if (date == null) return true;
                // 날짜를 하루의 시작으로 정규화하여 비교
                final normalizedDate = DateTime(date.year, date.month, date.day);
                if (minDate != null) {
                  final normalizedMin = DateTime(minDate!.year, minDate!.month, minDate!.day);
                  if (normalizedDate.isBefore(normalizedMin)) return false;
                }
                if (maxDate != null) {
                  final normalizedMax = DateTime(maxDate!.year, maxDate!.month, maxDate!.day);
                  if (normalizedDate.isAfter(normalizedMax)) return false;
                }
                return true;
              }
              
              if (start == null && end == null) {
                // 선택이 해제된 경우 - focusedDay가 범위 내인지 확인
                if (isDateInRange(focusedDay)) {
                  onRangeSelected!(focusedDay, null);
                }
                // 범위를 벗어나면 무시 (에러 발생하지 않음)
              } else if (start != null) {
                // 날짜 제약 조건 체크
                if (!isDateInRange(start)) {
                  // 시작일이 범위를 벗어나면 무시 (에러 발생하지 않음)
                  return;
                }
                
                if (end != null && !isDateInRange(end)) {
                  // 종료일이 범위를 벗어나면 시작일만 전달 (에러 발생하지 않음)
                  onRangeSelected!(start, null);
                  return;
                }
                
                // 시작일과 종료일 자동 정렬
                if (end != null && end.isBefore(start)) {
                  // 역순으로 선택한 경우 자동 정렬
                  onRangeSelected!(end, start);
                } else {
                  onRangeSelected!(start, end);
                }
              }
            }
          : null,
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
        // 범위 선택 모드일 때는 모든 decoration에서 borderRadius 제거 (애니메이션 충돌 방지)
        defaultDecoration: enableRangeSelection
            ? BoxDecoration(
                shape: BoxShape.rectangle,
              )
            : BoxDecoration(
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
        // 싱글 모드에서 선택된 날짜 스타일
        // 범위 선택 모드일 때는 투명하게 설정 (rangeStartDecoration/rangeEndDecoration 사용)
        selectedDecoration: enableRangeSelection
            ? BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
              )
            : BoxDecoration(
                color: p.primary.withOpacity(0.15),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: p.primary, width: 2.0),
              ),
        selectedTextStyle: enableRangeSelection
            ? TextStyle(
                color: p.textPrimary,
                fontSize: 14,
              )
            : TextStyle(
                color: p.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
        outsideDaysVisible: true,
        outsideTextStyle: TextStyle(
          color: p.textSecondary.withOpacity(0.5),
          fontSize: 14,
        ),
        outsideDecoration: enableRangeSelection
            ? BoxDecoration(
                shape: BoxShape.rectangle,
              )
            : BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
        weekendDecoration: enableRangeSelection
            ? BoxDecoration(
                shape: BoxShape.rectangle,
              )
            : BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
              ),
        cellPadding: cellPadding ?? EdgeInsets.zero,
        // cellMargin: 범위 선택 모드에서도 약간의 마진을 주어 선택 네모가 잘 보이도록 함
        // 싱글 모드일 때는 cellMargin이 null이면 기본값 EdgeInsets.all(2.0) 사용
        cellMargin: cellMargin ?? const EdgeInsets.all(2.0),
        // markerBuilder를 사용하려면 markersMaxCount를 1 이상으로 설정해야 함
        markersMaxCount: 1,
        // 시작일: Primary 색상 (파란색 계열)
        // 범위 선택 모드에서도 borderRadius 적용
        rangeStartDecoration: BoxDecoration(
          color: p.primary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),
        rangeStartTextStyle: TextStyle(
          color: p.cardBackground,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        // 종료일: Accent 색상 (주황색 계열) - 시작일과 구분
        // 범위 선택 모드에서도 borderRadius 적용
        rangeEndDecoration: BoxDecoration(
          color: p.accent,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
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
          borderRadius: BorderRadius.circular(8.0),
        ),
        withinRangeTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 14,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // 기본 날짜 빌더 (주말 색상 처리만, 평일은 null 반환하여 CalendarStyle의 defaultTextStyle 사용)
        // 범위 선택 모드에서도 주말 색상은 표시해야 함
        defaultBuilder: (context, date, events) {
          final p = context.palette;
          final weekday = date.weekday;
          final isSunday = weekday == 7;
          final isSaturday = weekday == 6;

          // 평일은 null 반환하여 CalendarStyle의 defaultTextStyle 사용 (p.textPrimary)
          if (!isSunday && !isSaturday) {
            return null;
          }

          // 주말만 커스텀 색상 적용
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
        // 오늘 날짜 빌더 (범위 선택 모드에서도 주말 색상 처리)
        todayBuilder: (context, date, events) {
          final p = context.palette;
          final isSelected = selectedDay != null && isSameDay(selectedDay!, date);
          final weekday = date.weekday;
          final isSunday = weekday == 7;
          final isSaturday = weekday == 6;

          final textColor = isSunday
              ? Colors.red.shade600
              : (isSaturday ? p.primary : p.primary);

          // 범위 선택 모드가 아닐 때만 선택된 오늘 날짜 처리
          if (!enableRangeSelection && isSelected) {
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

          // 범위 선택 모드이거나 선택되지 않은 오늘 날짜
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
        // 선택된 날짜 빌더
        selectedBuilder: enableRangeSelection
            ? null // 범위 선택 모드일 때는 기본 스타일 사용
            : (context, date, events) {
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
        // markerBuilder는 항상 활성화 (범위 선택 모드에서도 이벤트 표시)
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
            final isStart = enableRangeSelection &&
                selectedRange != null &&
                isSameDay(date, selectedRange!.start);
            final isEnd = enableRangeSelection &&
                selectedRange != null &&
                isSameDay(date, selectedRange!.end);

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
                  child: ClipOval(
                    child: Container(
                      width: 16,
                      height: 16,
                      color: (isStart || isEnd)
                          ? p.cardBackground
                          : (eventCount >= 10 ? Colors.red.shade600 : p.primary),
                      child: Center(
                        child: Text(
                          '$eventCount',
                          style: TextStyle(
                            color: (isStart || isEnd)
                                ? p.primary
                                : p.cardBackground,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
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

