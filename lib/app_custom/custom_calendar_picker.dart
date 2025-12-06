import 'package:flutter/material.dart';
import 'custom_calendar.dart';
import '../theme/app_colors.dart';

/// 테스트용 날짜 선택 달력 위젯
///
/// CustomCalendar를 기반으로 구현된 날짜 선택 전용 위젯입니다.
/// 크기 조절이 가능한 테스트용 달력을 사용합니다.
///
/// 두 가지 사용 방식을 제공합니다:
/// 1. 다이얼로그 형태로 날짜 선택 (`showDatePicker` 메서드)
/// 2. 화면에 배치된 형태로 날짜 선택 (`CustomCalendarPickerWidget` 위젯)
///
/// 주요 기능:
/// - 다이얼로그 형태로 날짜 선택
/// - 화면에 배치된 형태로 날짜 선택
/// - 이벤트 배지 및 바 표시 안 함 (날짜 선택에 집중)
/// - 선택된 날짜 강조 표시
/// - 오늘 날짜 강조 표시
/// - 테마 색상 자동 적용
/// - 크기 조절 가능 (세로 길이, 셀 비율)
///
/// 사용 예시 (다이얼로그 형식):
/// ```dart
/// final selectedDate = await CustomCalendarPicker.showDatePicker(
///   context: context,
///   initialDate: DateTime.now(),
///   calendarHeight: 500,
///   cellAspectRatio: 1.0,
/// );
///
/// if (selectedDate != null) {
///   // 선택된 날짜 사용
///   print('선택된 날짜: $selectedDate');
/// }
/// ```
///
/// 사용 예시 (화면 배치 형식):
/// ```dart
/// CustomCalendarPickerWidget(
///   initialDate: DateTime.now(),
///   onDateSelected: (date) {
///     setState(() {
///       _selectedDate = date;
///     });
///   },
///   calendarHeight: 500,
///   cellAspectRatio: 1.0,
/// )
/// ```
class CustomCalendarPicker {
  /// 날짜 선택 다이얼로그 표시
  ///
  /// [context] BuildContext
  /// [initialDate] 초기 선택 날짜 (기본값: 오늘)
  /// [calendarHeight] 달력 높이 (기본값: 400)
  ///
  /// 반환값: 선택된 날짜 (DateTime) 또는 null (취소 시)
  ///
  /// 사용 예시:
  /// ```dart
  /// final date = await CustomCalendarPicker.showDatePicker(
  ///   context: context,
  ///   initialDate: DateTime(2024, 1, 15),
  ///   calendarHeight: 500,
  ///   cellAspectRatio: 1.2,
  /// );
  /// ```
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    double? calendarHeight,
  }) async {
    final selectedDate = initialDate ?? DateTime.now();

    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return _DatePickerTestDialog(
          initialDate: selectedDate,
          onDateSelected: (date) {
            Navigator.of(dialogContext).pop(date);
          },
        );
      },
    );
  }
}

/// 날짜 선택 다이얼로그 내부 위젯 (테스트용)
///
/// CustomCalendar를 사용하여 날짜를 선택할 수 있는 다이얼로그입니다.
class _DatePickerTestDialog extends StatefulWidget {
  /// 초기 선택 날짜
  final DateTime initialDate;

  /// 날짜 선택 시 호출되는 콜백 함수
  final void Function(DateTime date) onDateSelected;

  /// 캘린더 고정 크기 (정사각형)
  static const double _calendarSize = 320.0;

  /// 다이얼로그 패딩
  static const double _dialogPadding = 16.0;

  /// 다이얼로그 최대 너비 (캘린더 크기 + 좌우 패딩)
  static const double _dialogMaxWidth =
      _calendarSize + (_dialogPadding * 2); // 352.0

  /// 다이얼로그 최대 높이 계산
  /// 헤더(56px) + 간격(16px) + 캘린더(320px) + 간격(16px) + 선택된 날짜 표시(60px) + 간격(16px) + 확인 버튼(56px) + 패딩(32px)
  static const double _dialogMaxHeight =
      56 + 16 + _calendarSize + 16 + 60 + 16 + 56 + 32; // 572.0

  const _DatePickerTestDialog({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_DatePickerTestDialog> createState() => _DatePickerTestDialogState();
}

class _DatePickerTestDialogState extends State<_DatePickerTestDialog> {
  /// 선택된 날짜
  late DateTime _selectedDate;

  /// 포커스된 날짜 (현재 보이는 달의 날짜)
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Dialog(
      backgroundColor: p.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        width: _DatePickerTestDialog._dialogMaxWidth,
        height: _DatePickerTestDialog._dialogMaxHeight,
        padding: const EdgeInsets.all(_DatePickerTestDialog._dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 다이얼로그 헤더
            SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '날짜 선택',
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: p.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 달력 위젯 (정확한 크기로 고정)
            SizedBox(
              width: _DatePickerTestDialog._calendarSize,
              height: _DatePickerTestDialog._calendarSize,
              child: CustomCalendar(
                selectedDay: _selectedDate,
                focusedDay: _focusedDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                },
                onTodayPressed: () {
                  setState(() {
                    final now = DateTime.now();
                    _selectedDate = now;
                    _focusedDate = now;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDate = focusedDay;
                  });
                },
                eventLoader: (day) => [], // 빈 리스트 반환 (이벤트 없음)
                calendarHeight: _DatePickerTestDialog._calendarSize,
                cellAspectRatio: 1.0, // 정사각형 유지
              ),
            ),

            const SizedBox(height: 16),

            // 선택된 날짜 표시
            SizedBox(
              height: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: p.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, color: p.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                      style: TextStyle(
                        color: p.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 확인 버튼
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_selectedDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: p.primary,
                  foregroundColor: p.cardBackground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 화면에 배치된 날짜 선택 달력 위젯 (테스트용)
///
/// CustomCalendar를 기반으로 구현된 날짜 선택 전용 위젯입니다.
/// 다이얼로그가 아닌 화면에 직접 배치하여 사용할 수 있습니다.
///
/// 주요 기능:
/// - 화면에 배치된 형태로 날짜 선택
/// - 이벤트 배지 및 바 표시 안 함 (날짜 선택에 집중)
/// - 선택된 날짜 강조 표시
/// - 오늘 날짜 강조 표시
/// - 테마 색상 자동 적용
/// - 날짜 선택 시 즉시 콜백 호출
/// - 크기 조절 가능 (세로 길이, 셀 비율)
///
/// 사용 예시:
/// ```dart
/// CustomCalendarPickerWidget(
///   initialDate: DateTime.now(),
///   onDateSelected: (date) {
///     setState(() {
///       _selectedDate = date;
///     });
///     print('선택된 날짜: $date');
///   },
///   calendarHeight: 500,
///   cellAspectRatio: 1.0,
/// )
/// ```
class CustomCalendarPickerWidget extends StatefulWidget {
  /// 초기 선택 날짜
  ///
  /// 위젯이 처음 표시될 때 선택된 날짜입니다.
  /// null인 경우 오늘 날짜를 사용합니다.
  final DateTime? initialDate;

  /// 날짜 선택 시 호출되는 콜백 함수
  ///
  /// 사용자가 달력의 날짜를 탭하면 호출됩니다.
  /// [date] 사용자가 선택한 날짜
  final void Function(DateTime date) onDateSelected;

  /// 달력 위젯의 높이 (픽셀)
  ///
  /// null인 경우 기본값 400을 사용합니다.
  final double? calendarHeight;

  /// 날짜별 이벤트(Todo) 리스트를 반환하는 함수
  ///
  /// **중요:** 이 함수는 외부(달력을 사용하는 페이지)에서 데이터를 조회하여 반환합니다.
  /// 달력 내부에서는 이 리스트를 받아서 표시 방식(마커, 배지, 바 등)만 결정합니다.
  /// DB 조회나 API 호출은 이 콜백을 제공하는 쪽에서 처리해야 합니다.
  ///
  /// null인 경우 이벤트를 표시하지 않습니다.
  final List<dynamic> Function(DateTime day)? eventLoader;

  /// 페이지 변경 시 호출되는 콜백 함수 (월 이동 시)
  ///
  /// 월이 변경될 때 호출되며, 이벤트를 다시 로드하는 등의 작업을 수행할 수 있습니다.
  final void Function(DateTime focusedDay)? onPageChanged;

  const CustomCalendarPickerWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.calendarHeight,
    this.eventLoader,
    this.onPageChanged,
  });

  @override
  State<CustomCalendarPickerWidget> createState() =>
      _CustomCalendarPickerWidgetState();
}

class _CustomCalendarPickerWidgetState
    extends State<CustomCalendarPickerWidget> {
  /// 선택된 날짜
  late DateTime _selectedDate;

  /// 포커스된 날짜 (현재 보이는 달의 날짜)
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _focusedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCalendar(
      selectedDay: _selectedDate,
      focusedDay: _focusedDate,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
          _focusedDate = focusedDay;
        });
        // 날짜 선택 시 즉시 콜백 호출
        widget.onDateSelected(selectedDay);
      },
      onTodayPressed: () {
        setState(() {
          final now = DateTime.now();
          _selectedDate = now;
          _focusedDate = now;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDate = focusedDay;
        });
        // 월 변경 시 외부 콜백 호출 (이벤트 다시 로드 등)
        widget.onPageChanged?.call(focusedDay);
      },
      eventLoader: widget.eventLoader ?? ((day) => []), // 외부에서 전달받은 이벤트 로더 사용
      calendarHeight:
          widget.calendarHeight ?? 400, // 높이만 지정하면 너비는 자동으로 동일하게 계산됨
    );
  }
}
