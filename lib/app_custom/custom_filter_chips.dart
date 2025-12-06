import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../util/step_mapper_util.dart';

/// 필터 칩 정보 클래스
///
/// 각 필터 칩의 정보를 담는 클래스입니다.
class FilterChipInfo {
  /// 칩에 표시할 라벨
  final String label;

  /// Step 값 (null = 전체, 0=아침, 1=낮, 2=저녁, 3=Anytime)
  final int? step;

  /// 칩 색상 가져오기 함수
  final Color Function(AppColorScheme) getColor;

  const FilterChipInfo({
    required this.label,
    required this.step,
    required this.getColor,
  });
}

/// 필터 칩 유틸리티 클래스
///
/// 필터 칩 정보를 제공하는 유틸리티 클래스입니다.
/// 사용하는 쪽에서 `Wrap` 위젯과 함께 사용하여 레이아웃을 자유롭게 구성할 수 있습니다.
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
///     // Filter Chips (Column의 자식으로 배치)
///     Padding(
///       padding: const EdgeInsets.symmetric(horizontal: 16.0),
///       child: Wrap(
///         spacing: 8.0,
///         runSpacing: 8.0,
///         children: FilterChipUtil.getDefaultChipInfos().map((chipInfo) {
///           final isSelected = _selectedStep == chipInfo.step;
///           final p = context.palette;
///           final chipColor = chipInfo.getColor(p);
///
///           return CustomChip(
///             label: chipInfo.label,
///             selectable: true,
///             selected: isSelected,
///             onSelected: (selected) {
///               if (selected) {
///                 setState(() {
///                   _selectedStep = chipInfo.step;
///                 });
///               }
///             },
///             backgroundColor: isSelected ? chipColor : p.chipUnselectedBg,
///             selectedColor: chipColor,
///             labelColor: isSelected ? p.chipSelectedText : p.chipUnselectedText,
///             selectedLabelColor: p.chipSelectedText,
///             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
///             borderRadius: 16.0,
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
class FilterChipUtil {
  /// 기본 필터 칩 정보 리스트 반환
  ///
  /// 전체/아침/낮/저녁/Anytime 5개의 칩 정보를 반환합니다.
  static List<FilterChipInfo> getDefaultChipInfos() {
    return [
      FilterChipInfo(
        label: "전체",
        step: null,
        getColor: (p) => p.chipSelectedBg,
      ),
      FilterChipInfo(
        label: "아침",
        step: StepMapperUtil.stepMorning,
        getColor: (p) => p.progressMorning,
      ),
      FilterChipInfo(
        label: "낮",
        step: StepMapperUtil.stepNoon,
        getColor: (p) => p.progressNoon,
      ),
      FilterChipInfo(
        label: "저녁",
        step: StepMapperUtil.stepEvening,
        getColor: (p) => p.progressEvening,
      ),
      FilterChipInfo(
        label: "Anytime",
        step: StepMapperUtil.stepAnytime,
        getColor: (p) => p.progressAnytime,
      ),
    ];
  }
}
