import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_colors.dart';

/// 테스트용 크기 조절 가능한 달력 위젯
///
/// TableCalendar 패키지를 기반으로 구현된 테스트용 커스텀 달력 위젯입니다.
/// 기존 CustomCalendar의 이벤트 표시 방식을 따르면서 크기 조절이 가능합니다.
///
/// **설계 원칙:**
/// - 이벤트 표시 방식(마커, 배지, 바 등)은 달력 내부에서 결정
/// - 이벤트 데이터 조회는 외부 콜백(`eventLoader`)으로 처리
/// - DB 조회나 일정 조회는 달력을 사용하는 페이지에서 담당
/// - 이렇게 해야 피커나 다른 페이지에서도 재사용 가능
///
/// 주요 기능:
/// - 크기 조절 가능 (rowHeight, cellMargin, cellPadding 등)
/// - 상단 헤더에 오늘로 가기 버튼 (calendar_today 아이콘)
/// - 날짜 선택 및 포커스 관리
/// - 날짜별 일정 갯수 원형 배지 표시 (내부에서 처리)
/// - 날짜별 진행도 미니 바 표시 (내부에서 처리)
/// - 오늘 날짜 강조 표시 (파란색 테두리)
/// - 선택된 날짜 강조 표시 (배경색 + 테두리)
/// - 다른 달 날짜 회색 처리
/// - 라이트/다크 모드 자동 지원
///
/// 사용 예시:
/// ```dart
/// CustomCalendar(
///   selectedDay: DateTime.now(),
///   focusedDay: DateTime.now(),
///   onDaySelected: (selectedDay, focusedDay) {
///     setState(() {
///       _selectedDay = selectedDay;
///       _focusedDay = focusedDay;
///     });
///   },
///   onTodayPressed: () {
///     setState(() {
///       _selectedDay = DateTime.now();
///       _focusedDay = DateTime.now();
///     });
///   },
///   onPageChanged: (focusedDay) {
///     setState(() {
///       _focusedDay = focusedDay;
///     });
///   },
///   eventLoader: (day) {
///     // 외부에서 데이터 조회 (DB, API 등)
///     // 달력은 이 리스트를 받아서 내부에서 표시 방식 결정
///     return databaseHandler.queryDataByDate(formatDate(day));
///   },
///   calendarHeight: 400.0,
///   cellAspectRatio: 1.0,
/// )
/// ```
class CustomCalendar extends StatelessWidget {
  /// 선택된 날짜
  final DateTime selectedDay;

  /// 현재 보이는 달의 포커스된 날짜
  final DateTime focusedDay;

  /// 날짜 선택 시 호출되는 콜백 함수
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  /// 오늘로 가기 버튼 클릭 시 호출되는 콜백 함수
  final VoidCallback? onTodayPressed;

  /// 페이지 변경 시 호출되는 콜백 함수 (월 이동 시)
  final void Function(DateTime focusedDay)? onPageChanged;

  /// 날짜별 이벤트(Todo) 리스트를 반환하는 함수
  ///
  /// **중요:** 이 함수는 외부(달력을 사용하는 페이지)에서 데이터를 조회하여 반환합니다.
  /// 달력 내부에서는 이 리스트를 받아서 표시 방식(마커, 배지, 바 등)만 결정합니다.
  /// DB 조회나 API 호출은 이 콜백을 제공하는 쪽에서 처리해야 합니다.
  ///
  /// 예시:
  /// ```dart
  /// eventLoader: (day) {
  ///   // DB에서 조회
  ///   return databaseHandler.queryDataByDate(formatDate(day));
  ///   // 또는 API에서 조회
  ///   // return await apiService.getEventsForDate(day);
  /// }
  /// ```
  final List<dynamic> Function(DateTime day) eventLoader;

  /// 달력 위젯의 높이 (픽셀)
  ///
  /// 높이만 지정하면 너비는 자동으로 높이와 동일하게 계산되어 정사각형이 됩니다.
  final double? calendarHeight;

  /// 행 높이 (각 날짜 셀의 높이)
  final double? rowHeight;

  /// 셀 마진 (각 날짜 셀 주변의 여백)
  final EdgeInsets? cellMargin;

  /// 셀 패딩 (각 날짜 셀 내부의 여백)
  final EdgeInsets? cellPadding;

  /// 요일 헤더 높이
  final double? daysOfWeekHeight;

  /// 헤더 높이 (월/연도 표시 영역)
  final double? headerHeight;

  /// 셀의 세로 기준 비율 (기본값: 1.0 = 정사각형)
  ///
  /// 예: 1.0 = 정사각형, 1.2 = 세로가 가로보다 1.2배 긴 직사각형
  /// 비율이 1.2면 달력의 세로 길이와 셀의 세로 길이가 1.2배가 됩니다.
  final double cellAspectRatio;

  const CustomCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    this.onTodayPressed,
    this.onPageChanged,
    required this.eventLoader,
    this.calendarHeight,
    this.rowHeight,
    this.cellMargin,
    this.cellPadding,
    this.daysOfWeekHeight,
    this.headerHeight,
    this.cellAspectRatio = 1.0, // 기본값: 정사각형
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context);

    // calendarHeight가 설정되어 있으면 내부 요소들을 비율에 맞춰 자동 계산
    double calculatedHeaderHeight;
    double calculatedDaysOfWeekHeight;
    double calculatedRowHeight;

    // 셀의 가로세로 비율을 유지하기 위한 계산
    // 셀 너비 = (달력 너비 - 패딩 좌우) / 7일
    // 셀 높이 = rowHeight
    // 비율 유지: rowHeight = 셀 너비 * 비율 (1.0 = 정사각형)

    // calendarHeight만 받아서 항상 자동 계산
    // 달력 전체 너비는 셀 비율에 따라 계산되고, 셀도 지정된 비율로 유지
    double effectiveWidth;
    double effectiveHeight;

    if (calendarHeight != null && calendarHeight! > 0) {
      // 높이가 지정된 경우: 비율에 따라 세로 길이와 셀 세로 길이를 조정
      // cellAspectRatio가 1.0이면 정사각형 (가로 = 세로)
      // cellAspectRatio가 1.2면 세로가 가로보다 1.2배 긴 직사각형
      if (cellAspectRatio == 1.0) {
        // 정사각형: 가로와 세로가 동일
        effectiveHeight = calendarHeight!;
        effectiveWidth = calendarHeight!;
      } else {
        // 직사각형: 세로가 비율만큼 늘어남
        effectiveHeight = calendarHeight! * cellAspectRatio;
        effectiveWidth = calendarHeight!; // 가로는 원래 높이와 동일
      }

      // 사용 가능한 크기 계산
      final availableHeight = effectiveHeight - 16.0;
      final availableWidth = effectiveWidth - 16.0;

      if (cellAspectRatio == 1.0) {
        // 정사각형인 경우: 셀도 정사각형이 되도록 정확히 계산
        // 셀 너비와 높이가 같아야 함
        final cellAreaWidth = availableWidth / 7.0; // 가로: 7일로 나눔
        final cellAreaHeight =
            availableHeight /
            8.0; // 세로: 헤더(12%) + 요일헤더(10%) + 셀(78%) = 100%, 셀은 6주

        // 정사각형 셀: 너비와 높이 중 작은 값을 사용
        final cellSize = cellAreaWidth < cellAreaHeight
            ? cellAreaWidth
            : cellAreaHeight;

        // 헤더와 요일 헤더 높이를 셀 크기에 맞춰 역산
        final totalCellHeight = cellSize * 6.0;
        final headerAndDaysHeight = availableHeight - totalCellHeight;
        final headerH = (headerAndDaysHeight * 0.545).clamp(
          40.0,
          60.0,
        ); // 12% / (12% + 10%) ≈ 0.545
        final daysH = (headerAndDaysHeight * 0.455).clamp(
          30.0,
          50.0,
        ); // 10% / (12% + 10%) ≈ 0.455

        calculatedHeaderHeight = headerH;
        calculatedDaysOfWeekHeight = daysH;
        calculatedRowHeight = cellSize.clamp(30.0, 80.0);
      } else {
        // 직사각형인 경우: 기존 로직 사용
        // 헤더와 요일 헤더 높이 계산 (전체 높이의 비율)
        final headerH = (availableHeight * 0.12).clamp(40.0, 60.0);
        final daysH = (availableHeight * 0.10).clamp(30.0, 50.0);

        // 셀 영역 계산
        final cellAreaWidth = availableWidth / 7.0; // 가로: 7일로 나눔
        final cellAreaHeight =
            (availableHeight - headerH - daysH) / 6.0; // 세로: 6주로 나눔

        // 셀 비율에 맞춰 행 높이 계산: 셀 세로 = 셀 가로 * 비율
        // 비율이 1.2면 셀 세로가 셀 가로보다 1.2배가 되어야 함
        // 즉, 셀 세로 = 셀 가로 * 비율
        final calculatedCellHeight = cellAreaWidth * cellAspectRatio;

        // 셀 높이가 사용 가능한 높이를 초과하지 않도록 조정
        final maxCellHeight = cellAreaHeight;
        final finalCellHeight = calculatedCellHeight < maxCellHeight
            ? calculatedCellHeight
            : maxCellHeight;

        // 실제 행 높이는 계산된 셀 높이로 설정 (비율이 적용됨)
        calculatedRowHeight = finalCellHeight.clamp(30.0, 80.0);

        // 헤더와 요일 헤더 높이 설정
        calculatedHeaderHeight = headerH;
        calculatedDaysOfWeekHeight = daysH;
      }
    } else {
      // calendarHeight가 지정되지 않은 경우: 화면 크기 기준으로 셀 비율 계산
      final screenWidth = MediaQuery.of(context).size.width;
      effectiveWidth = screenWidth;
      // 셀 너비 계산
      final cellWidth = (screenWidth - 16.0) / 7.0;
      // 셀 비율에 맞춰 행 높이 계산
      final rowH = (cellWidth * cellAspectRatio).clamp(30.0, 80.0);
      // 필요한 전체 높이 계산
      final headerH = 50.0;
      final daysH = 40.0;
      effectiveHeight = headerH + daysH + (rowH * 6) + 16.0;

      // 헤더와 요일 헤더 높이 설정
      calculatedHeaderHeight = headerH;
      calculatedDaysOfWeekHeight = daysH;
      calculatedRowHeight = rowH;
    }

    // 커스텀 헤더 위젯 (오늘로 가기 버튼 포함)
    Widget buildCustomHeader() {
      return Container(
        height: calculatedHeaderHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 이전 월 이동 버튼
            IconButton(
              icon: Icon(Icons.chevron_left, color: p.primary, size: 28),
              onPressed: () => _onPreviousMonthPressed(focusedDay),
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
              onPressed: () => _onNextMonthPressed(focusedDay),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
      );
    }

    // TableCalendar 위젯 생성
    final calendarWidget = TableCalendar(
      // 날짜 범위 설정
      firstDay: DateTime(1900, 1, 1),
      lastDay: DateTime(2100, 12, 31),

      // 현재 포커스된 날짜 (월 이동 시 변경됨)
      focusedDay: focusedDay,

      // 선택된 날짜 판별 함수
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),

      // 날짜 선택 이벤트 처리
      onDaySelected: onDaySelected,

      // 페이지 변경 이벤트 처리 (월 이동 시)
      onPageChanged: onPageChanged,

      // 날짜별 이벤트 로더
      eventLoader: eventLoader,

      // 달력 형식: 월간 달력만 지원
      calendarFormat: CalendarFormat.month,

      // 주 시작일: 월요일
      startingDayOfWeek: StartingDayOfWeek.monday,

      // 로케일 설정
      locale: locale.toString(),

      // 헤더 숨김 (커스텀 헤더 사용)
      headerVisible: false,

      // 요일 헤더 스타일
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

      // 날짜 셀 스타일 설정
      rowHeight: calculatedRowHeight,
      calendarStyle: CalendarStyle(
        // 기본 셀 decoration
        defaultDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),

        // 기본 날짜 텍스트 스타일
        defaultTextStyle: TextStyle(color: p.textPrimary, fontSize: 14),

        // 주말 날짜 텍스트 스타일
        weekendTextStyle: TextStyle(color: p.textPrimary, fontSize: 14),

        // 오늘 날짜 스타일 (테두리만, 배경 없음)
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

        // 선택된 날짜 스타일 (배경색 + 테두리)
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

        // 다른 달 날짜 표시 여부 및 스타일
        outsideDaysVisible: true,
        outsideTextStyle: TextStyle(
          color: p.textSecondary.withOpacity(0.5),
          fontSize: 14,
        ),
        outsideDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),

        // 주말 배경 스타일
        weekendDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),

        // 셀 내부 패딩
        cellPadding: cellPadding ?? EdgeInsets.zero,

        // 셀 마진
        cellMargin: cellMargin ?? const EdgeInsets.all(2.0),

        // 기본 이벤트 마커 표시 비활성화 (커스텀 마커 사용)
        markersMaxCount: 0,
      ),

      // 날짜 셀 커스터마이징 빌더
      calendarBuilders: CalendarBuilders(
        // 기본 날짜 셀 빌더: 주말 색상 구분 적용
        defaultBuilder: (context, date, events) {
          final p = context.palette;

          // 요일 확인 (1=월요일, 7=일요일)
          final weekday = date.weekday;
          final isSunday = weekday == 7; // 일요일
          final isSaturday = weekday == 6; // 토요일

          // 주말이 아닌 경우 기본 스타일 사용 (null 반환)
          if (!isSunday && !isSaturday) {
            return null; // null을 반환하면 CalendarStyle의 기본 스타일 사용
          }

          // 주말 색상 결정
          final textColor = isSunday
              ? Colors
                    .red
                    .shade600 // 일요일: 붉은 계열
              : p.primary; // 토요일: Primary 색상

          // 주말 날짜 셀 커스터마이징
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

        // 오늘 날짜 셀 빌더: 주말인 경우 색상 구분 적용
        todayBuilder: (context, date, events) {
          final p = context.palette;
          final isSelected = isSameDay(selectedDay, date);

          // 요일 확인
          final weekday = date.weekday;
          final isSunday = weekday == 7; // 일요일
          final isSaturday = weekday == 6; // 토요일

          // 주말 색상 결정
          final textColor = isSunday
              ? Colors
                    .red
                    .shade600 // 일요일: 붉은 계열
              : (isSaturday
                    ? p.primary
                    : p.primary); // 토요일: Primary, 평일: Primary

          // 선택된 날짜인 경우 선택 스타일 우선 적용
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

          // 오늘 날짜 스타일 (테두리 + 주말 색상)
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

        // 선택된 날짜 셀 빌더: 주말인 경우 색상 구분 적용
        selectedBuilder: (context, date, events) {
          final p = context.palette;

          // 요일 확인
          final weekday = date.weekday;
          final isSunday = weekday == 7; // 일요일
          final isSaturday = weekday == 6; // 토요일

          // 주말 색상 결정
          final textColor = isSunday
              ? Colors
                    .red
                    .shade700 // 일요일: 더 진한 붉은 계열
              : (isSaturday
                    ? p.primary
                    : p.primary); // 토요일: Primary, 평일: Primary

          // 선택된 날짜 스타일 (배경색 + 테두리)
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

        // 이벤트 마커 빌더: 이벤트 표시 방식은 달력 내부에서 결정
        // 외부에서 전달받은 events 리스트를 기반으로 마커를 표시
        // 하단 언더바 및 우측 하단 이벤트 개수 배지 표시
        markerBuilder: (context, date, events) {
          // 날짜별 Todo 개수 계산
          int eventCount = 0;
          try {
            final eventsList = events as List;
            eventCount = eventsList.length; // 리스트 길이 = Todo 개수
          } catch (e) {
            // events가 List가 아닌 경우 처리 (안전장치)
            eventCount = 0;
          }

          // 이벤트가 있는 경우에만 하단 바 및 이벤트 개수 배지 표시
          if (eventCount > 0) {
            final p = context.palette;
            return Stack(
              children: [
                // 이벤트 바 (하단 언더바)
                Positioned(
                  bottom: 0,
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      // 눈에 잘 띄는 색상 (Accent 색상 사용 - 주황색)
                      color: p.accent,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                // 이벤트 개수 배지 (우측 하단, 원형)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      // 배지 배경색: 10개 이상이면 붉은 계열, 9개 이하는 Primary 색상
                      color: eventCount >= 10
                          ? Colors
                                .red
                                .shade600 // 10개 이상: 붉은 계열
                          : p.primary, // 9개 이하: Primary 색상
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        // 이벤트 개수 표시 (숫자로 표시, 최대 99개까지)
                        '$eventCount',
                        style: TextStyle(
                          // 배지 텍스트 색상: 배경과 대비되는 색상 (일반적으로 흰색)
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

          // 이벤트가 없으면 아무것도 표시하지 않음
          return const SizedBox.shrink();
        },
      ),
    );

    // 커스텀 헤더와 달력을 Column으로 배치
    // 정확한 크기를 유지하기 위해 mainAxisSize를 max로 설정
    final calendarWithCustomHeader = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        buildCustomHeader(),
        Flexible(
          child: calendarWidget, // Flexible로 감싸서 남은 공간만 사용
        ),
      ],
    );

    // Container 생성 (높이와 너비 제약 설정)
    //
    // 제약 동작 방식:
    // - calendarHeight만 지정: 너비는 항상 높이와 동일하게 자동 계산 (정사각형)
    // - calendarHeight가 null: 화면 크기 기준으로 셀 비율 계산

    // 정확한 크기를 유지하기 위해 SizedBox로 감싸기
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
        child: calendarWithCustomHeader,
      ),
    );
  }

  //----------------------------------
  //-- Function
  //----------------------------------

  /// 이전 월 이동 버튼 클릭 콜백
  ///
  /// [focusedDay] 현재 포커스된 날짜
  void _onPreviousMonthPressed(DateTime focusedDay) {
    final previousMonth = DateTime(
      focusedDay.year,
      focusedDay.month - 1,
      focusedDay.day,
    );
    onPageChanged?.call(previousMonth);
  }

  /// 다음 월 이동 버튼 클릭 콜백
  ///
  /// [focusedDay] 현재 포커스된 날짜
  void _onNextMonthPressed(DateTime focusedDay) {
    final nextMonth = DateTime(
      focusedDay.year,
      focusedDay.month + 1,
      focusedDay.day,
    );
    onPageChanged?.call(nextMonth);
  }
}
