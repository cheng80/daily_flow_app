import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'step_mapper_util.dart';
import '../custom/custom_container.dart';
import '../custom/custom_text.dart';

/// 필터 라디오 옵션 정보 클래스
///
/// 각 필터 라디오 옵션의 정보를 담는 클래스입니다.
class FilterRadioOption {
  /// 옵션에 표시할 라벨
  final String label;

  /// Step 값 (null = 전체, 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
  final int? step;

  /// 배경색 가져오기 함수
  final Color Function(AppColorScheme) getBackgroundColor;

  /// 텍스트 색상 가져오기 함수
  final Color Function(AppColorScheme) getTextColor;

  const FilterRadioOption({
    required this.label,
    required this.step,
    required this.getBackgroundColor,
    required this.getTextColor,
  });
}

/// 필터 라디오 유틸리티 클래스
///
/// 필터 라디오 옵션 정보를 제공하는 유틸리티 클래스입니다.
class FilterRadioUtil {
  /// 기본 필터 라디오 옵션 리스트 반환
  ///
  /// 전체/오전/오후/저녁/종일 5개의 옵션 정보를 반환합니다.
  static List<FilterRadioOption> getDefaultOptions() {
    return [
      FilterRadioOption(
        label: "전체",
        step: null,
        getBackgroundColor: (p) => p.chipSelectedBg,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "오전",
        step: StepMapperUtil.stepMorning,
        getBackgroundColor: (p) => p.progressMorning,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "오후",
        step: StepMapperUtil.stepNoon,
        getBackgroundColor: (p) => p.progressNoon,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "저녁",
        step: StepMapperUtil.stepEvening,
        getBackgroundColor: (p) => p.progressEvening,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "야간",
        step: StepMapperUtil.stepNight,
        getBackgroundColor: (p) => p.progressNight,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "종일",
        step: StepMapperUtil.stepAnytime,
        getBackgroundColor: (p) => p.progressAnytime,
        getTextColor: (p) => p.chipSelectedText,
      ),
    ];
  }
}

/// 필터 라디오 위젯
///
/// 각 상태별 색상을 배경색으로 가지는 둥근 라운드 컨테이너에
/// 라디오 버튼과 라벨을 표시하는 필터 위젯입니다.
///
/// **사용 위치**: 세로 화면의 달력과 다른 위젯들 사이에 Column의 자식으로 배치됩니다.
///
/// 사용 예시:
/// ```dart
/// CustomColumn(
///   children: [
///     // 달력 위젯
///     CustomCalendar(...),
///
///     // Summary Bar
///     actionFourRangeBar(...),
///
///     // Filter Radio (Column의 자식으로 배치)
///     Padding(
///       padding: const EdgeInsets.symmetric(horizontal: 16.0),
///       child: Wrap(
///         spacing: 8.0,
///         runSpacing: 8.0,
///         children: FilterRadioUtil.getDefaultOptions().map((option) {
///           return CustomFilterRadio(
///             option: option,
///             selectedStep: _selectedStep,
///             onStepSelected: (step) {
///               setState(() {
///                 _selectedStep = step;
///               });
///             },
///           );
///         }).toList(),
///       ),
///     ),
///
///     // Todo List
///     TodoList(...),
///   ],
/// )
/// ```
class CustomFilterRadio extends StatelessWidget {
  /// 필터 라디오 옵션 정보
  final FilterRadioOption option;

  /// 현재 선택된 Step 값 (null = 전체, 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
  final int? selectedStep;

  /// Step 선택 시 호출되는 콜백 함수
  final void Function(int? step) onStepSelected;

  /// 컨테이너 패딩 (기본값: EdgeInsets.symmetric(horizontal: 16, vertical: 10))
  final EdgeInsets? padding;

  /// 컨테이너 모서리 둥글기 (기본값: 16.0)
  final double? borderRadius;

  /// 컨테이너 너비 (기본값: null, 내용에 맞게 자동 조정)
  final double? width;

  /// 컨테이너 높이 (기본값: null, 내용에 맞게 자동 조정)
  final double? height;

  /// 라디오 버튼과 라벨 사이의 간격 (기본값: 8.0)
  final double? spacing;

  /// Row의 주축 정렬 방식 (기본값: MainAxisAlignment.start)
  final MainAxisAlignment? mainAxisAlignment;

  /// Row의 교차축 정렬 방식 (기본값: CrossAxisAlignment.center)
  final CrossAxisAlignment? crossAxisAlignment;

  /// 라벨 텍스트 스타일 (기본값: null, 선택 상태에 따라 자동 설정)
  final TextStyle? labelStyle;

  /// 라벨 폰트 크기 (기본값: 16.0)
  final double? fontSize;

  const CustomFilterRadio({
    super.key,
    required this.option,
    required this.selectedStep,
    required this.onStepSelected,
    this.padding,
    this.borderRadius,
    this.width,
    this.height,
    this.spacing,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.labelStyle,
    this.fontSize,
  });

  /// 배경색의 밝기에 따라 적절한 텍스트 색상을 반환
  ///
  /// 밝은 배경에는 어두운 텍스트, 어두운 배경에는 밝은 텍스트를 반환합니다.
  Color _getContrastTextColor(Color backgroundColor) {
    // 색상의 밝기 계산 (0.0 ~ 1.0)
    // 공식: 0.299 * R + 0.587 * G + 0.114 * B
    // r, g, b는 이미 0.0~1.0 범위이므로 255를 곱할 필요 없음
    final brightness =
        0.299 * backgroundColor.r +
        0.587 * backgroundColor.g +
        0.114 * backgroundColor.b;

    // 밝기가 0.5보다 크면 어두운 텍스트, 작으면 밝은 텍스트
    return brightness > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final isSelected = selectedStep == option.step;

    // 선택된 경우: 상태별 색상, 선택되지 않은 경우: 기본 배경색
    final backgroundColor = isSelected
        ? option.getBackgroundColor(p)
        : p.chipUnselectedBg;

    // 선택된 경우: 배경색에 맞는 대비 색상 자동 계산, 선택되지 않은 경우: 기본 텍스트 색상
    final textColor = isSelected
        ? _getContrastTextColor(backgroundColor)
        : p.chipUnselectedText;

    return GestureDetector(
      onTap: _onTap,
      child: CustomContainer(
        width: width,
        height: height,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: backgroundColor,
        borderRadius: borderRadius ?? 16.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
          crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
          children: [
            IgnorePointer(
              child: Radio<int?>(
                value: option.step,
                activeColor: textColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            SizedBox(width: spacing ?? 8.0),
            CustomText(
              option.label,
              style:
                  labelStyle ??
                  TextStyle(
                    color: textColor,
                    fontSize: fontSize ?? 16.0,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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

  /// 탭 콜백
  void _onTap() {
    onStepSelected(option.step);
  }
}
