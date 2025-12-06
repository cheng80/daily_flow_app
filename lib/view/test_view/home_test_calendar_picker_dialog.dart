import 'package:flutter/material.dart';
import '../../custom/custom.dart';
import '../../app_custom/custom_calendar_picker.dart';
import '../../theme/app_colors.dart';

/// 테스트용 날짜 선택 다이얼로그 테스트 화면
///
/// **목적:** `CustomCalendarPicker.showDatePicker()` 다이얼로그를 테스트합니다.
///
/// 테스트 항목:
/// - 다이얼로그 형식 날짜 선택 (CustomCalendar 사용)
/// - 날짜 선택 결과 표시
/// - 다이얼로그 크기 및 레이아웃 확인
class HomeTestCalendarPickerDialogTest extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestCalendarPickerDialogTest({
    super.key,
    required this.onToggleTheme,
  });

  @override
  State<HomeTestCalendarPickerDialogTest> createState() =>
      _HomeTestCalendarPickerDialogTestState();
}

class _HomeTestCalendarPickerDialogTestState
    extends State<HomeTestCalendarPickerDialogTest> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  /// 선택된 날짜 (다이얼로그 형식)
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _themeBool = false;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText(
          "테스트용 날짜 선택 다이얼로그",
          style: TextStyle(color: p.textPrimary),
        ),
        actions: [
          Switch(
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
        child: CustomPadding.all(
          16,
          child: CustomColumn(
            spacing: 24,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 설명 섹션
              _buildDescriptionSection(p),

              const Divider(),

              // 테스트 버튼 및 결과 섹션
              _buildTestSection(p),
            ],
          ),
        ),
      ),
    );
  }

  /// 설명 섹션
  Widget _buildDescriptionSection(AppColorScheme p) {
    return CustomColumn(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          "다이얼로그 형식 날짜 선택 테스트",
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomText(
          "CustomCalendarPicker.showDatePicker()를 사용하여 다이얼로그로 날짜를 선택할 수 있습니다.",
          style: TextStyle(color: p.textSecondary, fontSize: 14),
        ),
        CustomText(
          "다이얼로그 내부에서 고정된 높이로 달력이 생성됩니다.",
          style: TextStyle(color: p.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  /// 테스트 버튼 및 결과 섹션
  Widget _buildTestSection(AppColorScheme p) {
    return CustomColumn(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          "테스트",
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomButton(
          btnText: "날짜 선택 다이얼로그 열기",
          onCallBack: () async {
            final selectedDate = await CustomCalendarPicker.showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
            );

            if (selectedDate != null) {
              setState(() {
                _selectedDate = selectedDate;
              });
            }
          },
        ),
        if (_selectedDate != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: p.primary.withOpacity(0.3)),
            ),
            child: CustomColumn(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: p.primary, size: 20),
                    const SizedBox(width: 8),
                    CustomText(
                      "선택 완료",
                      style: TextStyle(
                        color: p.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                CustomText(
                  "선택된 날짜:",
                  style: TextStyle(
                    color: p.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                CustomText(
                  "${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomText(
                  "요일: ${_getDayOfWeek(_selectedDate!)}",
                  style: TextStyle(color: p.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 요일 반환 (한국어)
  String _getDayOfWeek(DateTime date) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }
}
