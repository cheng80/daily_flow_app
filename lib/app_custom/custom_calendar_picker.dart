import 'package:flutter/material.dart';
import 'custom_calendar.dart';
import '../theme/app_colors.dart';

/// 일정 등록/수정 화면용 날짜 선택 달력 위젯
///
/// CustomCalendar를 기반으로 구현된 날짜 선택 전용 위젯입니다.
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
///
/// 사용 예시 (다이얼로그 형식):
/// ```dart
/// final selectedDate = await CustomCalendarPicker.showDatePicker(
///   context: context,
///   initialDate: DateTime.now(),
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
/// )
/// ```
class CustomCalendarPicker {
  /// 날짜 선택 다이얼로그 표시
  ///
  /// [context] BuildContext
  /// [initialDate] 초기 선택 날짜 (기본값: 오늘)
  ///
  /// 반환값: 선택된 날짜 (DateTime) 또는 null (취소 시)
  ///
  /// 사용 예시:
  /// ```dart
  /// final date = await CustomCalendarPicker.showDatePicker(
  ///   context: context,
  ///   initialDate: DateTime(2024, 1, 15),
  /// );
  /// ```
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    final selectedDate = initialDate ?? DateTime.now();

    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return _DatePickerDialog(
          initialDate: selectedDate,
          onDateSelected: (date) {
            Navigator.of(dialogContext).pop(date);
          },
        );
      },
    );
  }
}

/// 날짜 선택 다이얼로그 내부 위젯
///
/// CustomCalendar를 사용하여 날짜를 선택할 수 있는 다이얼로그입니다.
class _DatePickerDialog extends StatefulWidget {
  /// 초기 선택 날짜
  final DateTime initialDate;

  /// 날짜 선택 시 호출되는 콜백 함수
  final void Function(DateTime date) onDateSelected;

  const _DatePickerDialog({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
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
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 다이얼로그 헤더
            Row(
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
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 달력 위젯
            // showEvents: false로 설정하여 이벤트 배지 및 바 표시 안 함
            Flexible(
              child: CustomCalendar(
                selectedDay: _selectedDate,
                focusedDay: _focusedDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                },
                eventLoader: (day) => [], // 빈 리스트 반환 (이벤트 없음)
                showEvents: false, // 이벤트 표시 안 함
                calendarHeight: 400,
              ),
            ),

            const SizedBox(height: 16),

            // 선택된 날짜 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

            const SizedBox(height: 16),

            // 확인 버튼
            SizedBox(
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

/// 화면에 배치된 날짜 선택 달력 위젯
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
///   calendarHeight: 400, // 선택사항
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
  /// null인 경우 CustomCalendar가 자동으로 높이를 계산합니다.
  /// 설계서에 따르면 화면 상단 40~45%를 차지하도록 설정하는 것을 권장합니다.
  /// 예: MediaQuery.of(context).size.height * 0.4
  final double? calendarHeight;

  const CustomCalendarPickerWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.calendarHeight,
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
      eventLoader: (day) => [], // 빈 리스트 반환 (이벤트 없음)
      showEvents: false, // 이벤트 표시 안 함
      calendarHeight: widget.calendarHeight,
    );
  }
}
