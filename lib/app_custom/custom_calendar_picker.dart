import 'package:flutter/material.dart';
import 'custom_calendar.dart';
import '../theme/app_colors.dart';
import '../custom/custom.dart';

/// 날짜 선택 다이얼로그
///
/// CustomCalendar를 사용하여 다이얼로그 형태로 날짜를 선택할 수 있습니다.
/// 화면에 배치된 달력이 필요한 경우에는 CustomCalendar를 직접 사용하세요.
///
/// 사용 예시:
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
class CustomCalendarPicker {
  /// 날짜 선택 다이얼로그 표시
  ///
  /// [context] BuildContext
  /// [initialDate] 초기 선택 날짜 (기본값: 오늘)
  ///
  /// 반환값: 선택된 날짜 (DateTime) 또는 null (취소 시)
  static Future<DateTime?> showDatePicker({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    final selectedDate = initialDate ?? DateTime.now();

    return showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return _DatePickerDialog(initialDate: selectedDate);
      },
    );
  }
}

/// 날짜 선택 다이얼로그 위젯
class _DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _DatePickerDialog({required this.initialDate});

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime _selectedDate;
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
    final screenSize = MediaQuery.of(context).size;

    // 미디어 쿼리로 달력 크기 계산 (화면 너비의 90%, 최대 400px)
    final calendarSize = (screenSize.width * 0.9).clamp(300.0, 400.0);

    return Dialog(
      backgroundColor: p.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 다이얼로그 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
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
            const SizedBox(height: 16),

            // 달력 위젯
            SizedBox(
              width: calendarSize,
              height: calendarSize,
              child: CustomCalendar(
                selectedDay: _selectedDate,
                focusedDay: _focusedDate,
                onDaySelected: _onDaySelected,
                onTodayPressed: _onTodayPressed,
                onPageChanged: _onPageChanged,
                eventLoader: _eventLoader,
                calendarHeight: calendarSize,
                cellAspectRatio: 1.0,
              ),
            ),

            const SizedBox(height: 16),

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                btnText: "확인",
                buttonType: ButtonType.elevated,
                backgroundColor: p.primary,
                onCallBack: _onConfirmPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------
  //-- Function
  //----------------------------------

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _focusedDate = focusedDay;
    });
  }

  void _onTodayPressed() {
    setState(() {
      final now = DateTime.now();
      _selectedDate = now;
      _focusedDate = now;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDate = focusedDay;
    });
  }

  List<dynamic> _eventLoader(DateTime day) {
    return [];
  }

  void _onConfirmPressed() {
    Navigator.of(context).pop(_selectedDate);
  }
}
