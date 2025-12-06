import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';

/// 시간 선택 다이얼로그
///
/// CustomCupertinoDatePicker를 사용하여 다이얼로그 형태로 시간을 선택할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// final selectedTime = await CustomTimePicker.showTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
/// );
///
/// if (selectedTime != null) {
///   // 선택된 시간 사용
///   print('선택된 시간: ${selectedTime.hour}:${selectedTime.minute}');
/// }
/// ```
class CustomTimePicker {
  /// 시간 선택 다이얼로그 표시
  ///
  /// [context] BuildContext
  /// [initialTime] 초기 선택 시간 (기본값: 현재 시간)
  /// [use24HourFormat] 24시간 형식 사용 여부 (기본값: false, 12시간 형식)
  ///
  /// 반환값: 선택된 시간 (TimeOfDay) 또는 null (취소 시)
  static Future<TimeOfDay?> showTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    bool use24HourFormat = false,
  }) async {
    final now = DateTime.now();
    final initial = initialTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            initialTime.hour,
            initialTime.minute,
          )
        : now;

    return showDialog<TimeOfDay>(
      context: context,
      builder: (dialogContext) {
        return _TimePickerDialog(
          initialDateTime: initial,
          use24HourFormat: use24HourFormat,
        );
      },
    );
  }
}

/// 시간 선택 다이얼로그 위젯
class _TimePickerDialog extends StatefulWidget {
  final DateTime initialDateTime;
  final bool use24HourFormat;

  const _TimePickerDialog({
    required this.initialDateTime,
    required this.use24HourFormat,
  });

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Dialog(
      backgroundColor: p.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 다이얼로그 헤더
            CustomRow(
              spacing: 0,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 왼쪽 빈 공간 (가운데 정렬을 위한)
                const SizedBox(width: 48),
                // 가운데 제목
                CustomText(
                  "시간 선택",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 우측 X 버튼
                CustomIconButton(
                  icon: Icons.close,
                  iconColor: p.textSecondary,
                  onPressed: () {
                    CustomNavigationUtil.back(context);
                  },
                  tooltip: "취소",
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 시간 선택기
            CustomCupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: _selectedDateTime,
              use24HourFormat: widget.use24HourFormat,
              onDateTimeChanged: (dateTime) {
                setState(() {
                  _selectedDateTime = dateTime;
                });
              },
            ),
            const SizedBox(height: 16),
            // 확인 버튼
            CustomButton(
              btnText: "확인",
              buttonType: ButtonType.elevated,
              backgroundColor: p.primary,
              onCallBack: () {
                CustomNavigationUtil.back(
                  context,
                  result: TimeOfDay(
                    hour: _selectedDateTime.hour,
                    minute: _selectedDateTime.minute,
                  ),
                );
              },
              minimumSize: const Size(double.infinity, 48),
            ),
          ],
        ),
      ),
    );
  }
}
