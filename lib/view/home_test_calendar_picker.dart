import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../app_custom/custom_calendar_picker.dart';
import '../theme/app_colors.dart';

/// 날짜 선택 위젯 테스트 화면
///
/// **목적:** `CustomCalendarPicker` 위젯의 다이얼로그 형식과 화면 배치 형식을 테스트합니다.
///
/// 테스트 항목:
/// - 다이얼로그 형식 날짜 선택
/// - 화면 배치 형식 날짜 선택
/// - 날짜 선택 결과 표시
class HomeTestCalendarPicker extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestCalendarPicker({super.key, required this.onToggleTheme});

  @override
  State<HomeTestCalendarPicker> createState() => _HomeTestCalendarPickerState();
}

class _HomeTestCalendarPickerState extends State<HomeTestCalendarPicker> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  /// 선택된 날짜 (다이얼로그 형식)
  DateTime? _selectedDateDialog;

  /// 선택된 날짜 (화면 배치 형식)
  late DateTime _selectedDateWidget;

  @override
  void initState() {
    super.initState();
    _themeBool = false;
    _selectedDateWidget = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText(
          "날짜 선택 위젯 테스트",
          style: TextStyle(color: p.textPrimary),
        ),
        actions: [
          CustomSwitch(
            value: _themeBool,
            onChanged: (value) {
              setState(() {
                _themeBool = value;
              });
              widget.onToggleTheme();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: CustomColumn(
          children: [
            const SizedBox(height: 20),

            // 다이얼로그 형식 테스트 섹션
            CustomText(
              "다이얼로그 형식",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomText(
              "날짜 선택 다이얼로그를 띄워 날짜를 선택합니다.",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            CustomPadding(
              horizontal: 16.0,
              child: CustomButton(
                btnText: "날짜 선택 다이얼로그 열기",
                onCallBack: () async {
                  final selectedDate =
                      await CustomCalendarPicker.showDatePicker(
                    context: context,
                    initialDate: _selectedDateDialog ?? DateTime.now(),
                  );

                  if (selectedDate != null && mounted) {
                    setState(() {
                      _selectedDateDialog = selectedDate;
                    });
                    CustomSnackBar.show(
                      context,
                      message:
                          '선택된 날짜: ${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedDateDialog != null)
              CustomContainer(
                padding: const EdgeInsets.all(16),
                backgroundColor: p.cardBackground,
                borderRadius: 8,
                borderColor: p.divider,
                borderWidth: 1.0,
                child: CustomColumn(
                  children: [
                    CustomText(
                      "선택된 날짜 (다이얼로그)",
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      "${_selectedDateDialog!.year}년 ${_selectedDateDialog!.month}월 ${_selectedDateDialog!.day}일",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // 화면 배치 형식 테스트 섹션
            CustomText(
              "화면 배치 형식",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            CustomText(
              "달력을 화면에 직접 배치하여 날짜를 선택합니다.",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // 날짜 선택 위젯 (화면 배치 형식)
            CustomCalendarPickerWidget(
              initialDate: _selectedDateWidget,
              onDateSelected: (date) {
                setState(() {
                  _selectedDateWidget = date;
                });
                CustomSnackBar.show(
                  context,
                  message: '선택된 날짜: ${date.year}년 ${date.month}월 ${date.day}일',
                  duration: const Duration(seconds: 1),
                );
              },
            ),

            const SizedBox(height: 20),

            // 선택된 날짜 표시
            CustomContainer(
              padding: const EdgeInsets.all(16),
              backgroundColor: p.cardBackground,
              borderRadius: 8,
              borderColor: p.divider,
              borderWidth: 1.0,
              child: CustomColumn(
                children: [
                  CustomText(
                    "선택된 날짜 (화면 배치)",
                    style: TextStyle(color: p.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    "${_selectedDateWidget.year}년 ${_selectedDateWidget.month}월 ${_selectedDateWidget.day}일",
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 오늘 날짜로 이동 버튼
            CustomPadding(
              horizontal: 16.0,
              child: CustomButton(
                btnText: "오늘 날짜로 이동",
                onCallBack: () {
                  setState(() {
                    _selectedDateWidget = DateTime.now();
                  });
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

