import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/app_colors.dart';

/// DailyFlow 앱 전용 달력 위젯
///
/// TableCalendar 패키지를 기반으로 구현된 커스텀 달력 위젯입니다.
/// 메인 화면에서 월간 달력을 표시하며, 날짜별 일정 정보를 시각적으로 표현합니다.
///
/// 주요 기능:
/// - 날짜 선택 및 포커스 관리
/// - 날짜별 일정 갯수 원형 배지 표시
/// - 날짜별 진행도 미니 바 표시 (완료된 Todo / 전체 Todo 비율)
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
///     // Summary Bar 및 Todo List 갱신
///   },
///   eventLoader: (day) {
///     // DatabaseHandler에서 해당 날짜의 Todo 리스트 조회
///     return databaseHandler.queryDataByDate(formatDate(day));
///   },
///   calendarHeight: 400,
/// )
/// ```
///
/// 화면 상단 40~45%를 차지하도록 높이를 설정하는 것을 권장합니다.
class CustomCalendar extends StatelessWidget {
  /// 선택된 날짜
  ///
  /// 사용자가 탭하여 선택한 날짜입니다.
  /// 이 날짜는 배경색과 테두리로 강조 표시됩니다.
  final DateTime selectedDay;

  /// 현재 보이는 달의 포커스된 날짜
  ///
  /// 달력에서 현재 표시 중인 달의 기준 날짜입니다.
  /// 월 이동 시 이 값이 변경되며, 선택된 날짜와는 별개로 관리됩니다.
  final DateTime focusedDay;

  /// 날짜 선택 시 호출되는 콜백 함수
  ///
  /// 사용자가 달력의 날짜를 탭하면 호출됩니다.
  /// [selectedDay] 사용자가 선택한 날짜
  /// [focusedDay] 포커스된 날짜 (월 이동 시 변경됨)
  ///
  /// 이 함수에서 다음 작업을 수행해야 합니다:
  /// 1. selectedDay와 focusedDay 상태 업데이트
  /// 2. Summary Bar 갱신 (해당 날짜의 Todo 데이터 조회)
  /// 3. Todo List 갱신 (해당 날짜의 Todo 리스트 조회)
  /// 4. 필터 초기화 (전체로 리셋)
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  /// 날짜별 이벤트(Todo) 리스트를 반환하는 함수
  ///
  /// **위치 및 호출 시점:**
  /// - TableCalendar가 각 날짜 셀을 렌더링할 때 자동으로 호출됩니다.
  /// - 달력 화면이 표시되거나 월이 변경될 때마다 모든 날짜 셀에 대해 호출됩니다.
  /// - CustomCalendar 위젯의 필수 파라미터로 전달되며, TableCalendar의 `eventLoader` 속성에 연결됩니다.
  ///
  /// **파라미터:**
  /// - [day] 조회할 날짜 (DateTime 객체)
  ///
  /// **반환값:**
  /// - 해당 날짜의 Todo 리스트 (List<dynamic> 또는 List<Todo>)
  /// - 빈 리스트([])를 반환하면 일정 갯수 배지와 이벤트 바가 표시되지 않습니다.
  /// - 리스트의 길이가 이벤트 개수로 계산되어 배지에 표시됩니다.
  ///
  /// **날짜별 Todo 계산 방식:**
  /// 1. eventLoader가 호출되면 전달받은 [day] 파라미터를 사용하여 해당 날짜의 Todo를 조회합니다.
  /// 2. 날짜 형식 변환: DateTime 객체를 'YYYY-MM-DD' 형식의 문자열로 변환합니다.
  /// 3. 데이터베이스 조회: DatabaseHandler.queryDataByDate()를 사용하여 해당 날짜의 모든 Todo를 조회합니다.
  /// 4. 반환된 리스트는 markerBuilder에서 사용되어 이벤트 개수를 계산하고 배지/바를 표시합니다.
  ///
  /// **실제 구현 예시:**
  /// ```dart
  /// eventLoader: (day) async {
  ///   // 날짜 형식 변환: DateTime -> 'YYYY-MM-DD'
  ///   final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  ///
  ///   // DatabaseHandler를 사용하여 해당 날짜의 Todo 조회
  ///   final databaseHandler = DatabaseHandler();
  ///   final todos = await databaseHandler.queryDataByDate(dateStr);
  ///
  ///   // Todo 리스트 반환 (빈 리스트면 배지/바 표시 안 됨)
  ///   return todos;
  /// }
  /// ```
  ///
  /// **주의사항:**
  /// - 동기 함수로 구현해야 합니다 (비동기 함수는 지원하지 않음).
  /// - 실제 데이터베이스 조회가 필요한 경우, 미리 조회한 데이터를 Map에 캐싱하여 사용하는 것을 권장합니다.
  /// - 테스트용으로는 더미 데이터를 반환할 수 있습니다 (home.dart 참고).
  final List<dynamic> Function(DateTime day) eventLoader;

  /// 달력 위젯의 높이 (픽셀)
  ///
  /// null인 경우 TableCalendar가 자동으로 높이를 계산합니다.
  /// 설계서에 따르면 화면 상단 40~45%를 차지하도록 설정하는 것을 권장합니다.
  /// 예: MediaQuery.of(context).size.height * 0.4
  final double? calendarHeight;

  const CustomCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.eventLoader,
    this.calendarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = Localizations.localeOf(context);

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

      // 날짜별 이벤트 로더
      eventLoader: eventLoader,

      // 달력 형식: 월간 달력만 지원
      calendarFormat: CalendarFormat.month,

      // 주 시작일: 월요일
      startingDayOfWeek: StartingDayOfWeek.monday,

      // 로케일 설정 (main.dart의 supportedLocales에 따라 자동 적용)
      locale: locale.toString(),

      // 날짜 셀 스타일 설정
      calendarStyle: CalendarStyle(
        // 기본 셀 decoration (모든 셀에 공통으로 적용)
        // shape를 명시적으로 rectangle로 설정하여 borderRadius와 충돌 방지
        defaultDecoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
        ),

        // 기본 날짜 텍스트 스타일
        defaultTextStyle: TextStyle(color: p.textPrimary, fontSize: 14),

        // 주말 날짜 텍스트 스타일
        // 일요일과 토요일을 구분하기 위해 calendarBuilders에서 개별 처리
        // 여기서는 기본값 설정 (실제 색상은 defaultBuilder에서 적용)
        weekendTextStyle: TextStyle(color: p.textPrimary, fontSize: 14),

        // 오늘 날짜 스타일 (테두리만, 배경 없음 - 선택된 날짜와 구분)
        // shape를 명시적으로 rectangle로 설정하여 borderRadius와 충돌 방지
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

        // 선택된 날짜 스타일 (배경색 + 테두리 - 오늘과 구분)
        // shape를 명시적으로 rectangle로 설정하여 borderRadius와 충돌 방지
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

        // 셀 내부 패딩 제거 (커스텀 레이아웃 사용)
        cellPadding: EdgeInsets.zero,

        // 기본 이벤트 마커 표시 비활성화 (원형 배지 제거)
        markersMaxCount: 0,
      ),

      // 헤더 스타일 (월/연도 표시 영역)
      headerStyle: HeaderStyle(
        // 형식 변경 버튼 숨김 (월간만 지원)
        formatButtonVisible: false,

        // 제목 가운데 정렬
        titleCentered: true,

        // 제목 텍스트 스타일
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),

        // 이전 월 이동 버튼
        leftChevronIcon: Icon(Icons.chevron_left, color: p.primary, size: 28),

        // 다음 월 이동 버튼
        rightChevronIcon: Icon(Icons.chevron_right, color: p.primary, size: 28),

        // 헤더 패딩
        headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
      ),

      // 요일 헤더 스타일 (월, 화, 수, 목, 금, 토, 일)
      daysOfWeekStyle: DaysOfWeekStyle(
        // 평일 스타일
        weekdayStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        // 주말 스타일
        weekendStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 날짜 셀 커스터마이징 빌더
      // 기본 셀 구조는 TableCalendar의 기본 구조를 사용하고,
      // markerBuilder를 통해 이벤트 바만 오버레이하는 방식으로 구현
      calendarBuilders: CalendarBuilders(
        // 기본 날짜 셀 빌더: 주말 색상 구분 적용
        // 일요일: 붉은 계열 색상, 토요일: 파란 계열 색상
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
          // 일요일: 붉은 계열 색상 (빨간색)
          // 토요일: 파란 계열 색상 (Primary 색상 사용)
          final textColor = isSunday
              ? Colors
                    .red
                    .shade600 // 일요일: 붉은 계열
              : p.primary; // 토요일: Primary 색상

          // 주말 날짜 셀 커스터마이징
          return Container(
            margin: const EdgeInsets.all(2.0),
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

          // 요일 확인 (1=월요일, 7=일요일)
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
              margin: const EdgeInsets.all(2.0),
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
            margin: const EdgeInsets.all(2.0),
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

          // 요일 확인 (1=월요일, 7=일요일)
          final weekday = date.weekday;
          final isSunday = weekday == 7; // 일요일
          final isSaturday = weekday == 6; // 토요일

          // 주말 색상 결정 (선택된 날짜는 Primary 색상 사용하되, 주말인 경우 약간 조정)
          final textColor = isSunday
              ? Colors
                    .red
                    .shade700 // 일요일: 더 진한 붉은 계열
              : (isSaturday
                    ? p.primary
                    : p.primary); // 토요일: Primary, 평일: Primary

          // 선택된 날짜 스타일 (배경색 + 테두리)
          return Container(
            margin: const EdgeInsets.all(2.0),
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

        // 이벤트 마커 빌더: 이벤트가 있는 날짜에 하단 언더바 및 이벤트 개수 배지 표시
        // TableCalendar의 기본 셀 구조를 유지하고, markerBuilder를 통해 이벤트 표시 오버레이
        markerBuilder: (context, date, events) {
          // 날짜별 Todo 개수 계산
          // events 파라미터는 eventLoader에서 반환된 리스트입니다.
          // eventLoader가 호출되어 해당 날짜의 Todo 리스트를 조회하고,
          // 그 리스트가 events로 전달됩니다.
          //
          // 계산 과정:
          // 1. eventLoader(day) 호출 → 해당 날짜의 Todo 리스트 반환
          // 2. TableCalendar가 events로 전달
          // 3. markerBuilder에서 events.length로 개수 계산
          // 4. 개수가 0보다 크면 배지와 바 표시
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
                // 셀의 margin(2.0)을 고려하여 양 옆에 여백 추가 (더 줄여서 정확히 맞춤)
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
                        // 10개 이상이면 붉은 배지로 강조
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

    // calendarHeight가 null이면 반응형으로 자동 조절
    // null이 아니면 지정된 높이 사용 (최소 350px 권장)
    if (calendarHeight == null) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: p.cardBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: calendarWidget,
      );
    } else {
      // 최소 높이 350px 보장 (300px는 너무 낮아서 문제 발생)
      final minHeight = calendarHeight! < 350 ? 350.0 : calendarHeight!;
      return Container(
        height: minHeight,
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
