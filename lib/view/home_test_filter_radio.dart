import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../app_custom/custom_filter_radio.dart';
import '../app_custom/step_mapper_util.dart';

/// Filter Radio 위젯 테스트 화면
///
/// **목적:** `CustomFilterRadio` 위젯의 동작을 테스트하고 검증합니다.
///
/// 테스트 항목:
/// - 전체/오전/오후/저녁/종일 라디오 선택 기능
/// - 각 상태별 색상을 배경색으로 가지는 둥근 라운드 컨테이너
/// - 라디오 버튼과 라벨 표시
/// - 선택된 Step 값 반환
/// - 테마 색상 적용
class HomeTestFilterRadio extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestFilterRadio({super.key, required this.onToggleTheme});

  @override
  State<HomeTestFilterRadio> createState() => _HomeTestFilterRadioState();
}

class _HomeTestFilterRadioState extends State<HomeTestFilterRadio> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  /// 선택된 Step 값 (null = 전체, 0=오전, 1=오후, 2=저녁, 3=종일)
  int? _selectedStep;

  @override
  void initState() {
    super.initState();
    _themeBool = false;
    _selectedStep = null; // 기본값: 전체
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText(
          "Filter Radio 테스트",
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
        child: CustomColumn(
          children: [
            const SizedBox(height: 20),

            // 제목
            CustomText(
              "Filter Radio 테스트",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            CustomText(
              "Step별 필터링을 위한 라디오 선택 테스트",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // Filter Radio 위젯
            CustomText(
              "Filter Radio",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            RadioGroup<int?>(
              groupValue: _selectedStep,
              onChanged: (value) {
                setState(() {
                  _selectedStep = value;
                });
              },
              child: Transform.scale(
                scale: 0.95,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (var option in FilterRadioUtil.getDefaultOptions())
                      _filterRadioCreate(70, 40, 12, option),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 선택된 Step 정보 표시
            CustomText(
              "선택된 Step 정보",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            CustomContainer(
              padding: const EdgeInsets.all(16),
              backgroundColor: p.cardBackground,
              borderRadius: 8,
              borderColor: p.divider,
              borderWidth: 1.0,
              child: CustomColumn(
                children: [
                  CustomText(
                    "Step 값",
                    style: TextStyle(color: p.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    _selectedStep == null
                        ? "null (전체)"
                        : _selectedStep.toString(),
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    "한국어",
                    style: TextStyle(color: p.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    _selectedStep == null
                        ? "전체"
                        : StepMapperUtil.stepToKorean(_selectedStep!),
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 빠른 선택 버튼들
            CustomText(
              "빠른 선택",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "전체",
                  onCallBack: () {
                    setState(() {
                      _selectedStep = null;
                    });
                  },
                ),
                CustomButton(
                  btnText: "오전",
                  onCallBack: () {
                    setState(() {
                      _selectedStep = StepMapperUtil.stepMorning;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "오후",
                  onCallBack: () {
                    setState(() {
                      _selectedStep = StepMapperUtil.stepNoon;
                    });
                  },
                ),
                CustomButton(
                  btnText: "저녁",
                  onCallBack: () {
                    setState(() {
                      _selectedStep = StepMapperUtil.stepEvening;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            CustomButton(
              btnText: "종일",
              onCallBack: () {
                setState(() {
                  _selectedStep = StepMapperUtil.stepAnytime;
                });
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  //-----------------
  //--Function
  //-----------------

  // CustomFilterRadio 위젯 생성
  Widget _filterRadioCreate(
    double width,
    double height,
    double fontSize,
    FilterRadioOption option,
  ) {
    return CustomFilterRadio(
      width: width,
      height: height,
      option: option,
      padding: EdgeInsets.zero, // 패딩 제거
      mainAxisAlignment: MainAxisAlignment.start,
      labelStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      selectedStep: _selectedStep,
      onStepSelected: (step) {
        setState(() {
          _selectedStep = step;
        });
      },
    );
  }
}
