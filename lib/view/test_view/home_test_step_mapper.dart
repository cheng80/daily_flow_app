import 'package:flutter/material.dart';
import '../../custom/custom.dart';
import '../../theme/app_colors.dart';
import '../../app_custom/step_mapper_util.dart';

/// StepMapperUtil 유틸리티 테스트 화면
///
/// **목적:** `StepMapperUtil` 클래스의 동작을 테스트하고 검증합니다.
///
/// 테스트 항목:
/// - 시간 → Step 변환 (`mapTimeToStep`)
/// - Step → 한국어 변환 (`stepToKorean`)
/// - 다양한 시간대 테스트 (아침/낮/저녁/Anytime)
/// - 경계값 테스트
/// - 에러 처리 테스트
class HomeTestStepMapper extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestStepMapper({super.key, required this.onToggleTheme});

  @override
  State<HomeTestStepMapper> createState() => _HomeTestStepMapperState();
}

class _HomeTestStepMapperState extends State<HomeTestStepMapper> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  /// 시간 입력 컨트롤러
  final TextEditingController _timeController = TextEditingController();

  /// Step 입력 컨트롤러
  final TextEditingController _stepController = TextEditingController();

  /// 시간 → Step 변환 결과
  String _timeToStepResult = '';

  /// Step → 한국어 변환 결과
  String _stepToKoreanResult = '';

  @override
  void initState() {
    super.initState();
    _themeBool = false;
    _timeController.text = '14:30';
    _stepController.text = '1';
  }

  @override
  void dispose() {
    _timeController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  /// 시간 → Step 변환 테스트
  void _testTimeToStep() {
    final time = _timeController.text.trim();
    final step = StepMapperUtil.mapTimeToStep(time.isEmpty ? null : time);
    final korean = StepMapperUtil.stepToKorean(step);

    setState(() {
      _timeToStepResult = '시간: $time\nStep: $step ($korean)';
    });
  }

  /// Step → 한국어 변환 테스트
  void _testStepToKorean() {
    final stepText = _stepController.text.trim();
    try {
      final step = int.parse(stepText);
      final korean = StepMapperUtil.stepToKorean(step);

      setState(() {
        _stepToKoreanResult = 'Step: $step\n한국어: $korean';
      });
    } catch (e) {
      setState(() {
        _stepToKoreanResult = '오류: 유효하지 않은 Step 값입니다.';
      });
    }
  }

  /// 빠른 테스트 케이스 실행
  void _runQuickTest(String time, String description) {
    _timeController.text = time;
    _testTimeToStep();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText(
          "StepMapper 테스트",
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
              "StepMapperUtil 테스트",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            CustomText(
              "시간 → Step 변환 및 Step → 한국어 변환 테스트",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 30),

            // ============================================
            // 시간 → Step 변환 테스트 섹션
            // ============================================
            CustomText(
              "1. 시간 → Step 변환",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // 시간 입력 필드
            CustomTextField(
              controller: _timeController,
              hintText: "시간 입력 (예: 14:30)",
              keyboardType: TextInputType.datetime,
            ),

            const SizedBox(height: 12),

            // 변환 버튼
            CustomButton(btnText: "시간 → Step 변환", onCallBack: _testTimeToStep),

            const SizedBox(height: 12),

            // 결과 표시
            if (_timeToStepResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.divider),
                ),
                child: CustomText(
                  _timeToStepResult,
                  style: TextStyle(color: p.textPrimary, fontSize: 16),
                ),
              ),

            const SizedBox(height: 20),

            // 빠른 테스트 버튼들
            CustomText(
              "빠른 테스트",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // 아침 시간대 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "08:00 (아침)",
                  onCallBack: () => _runQuickTest("08:00", "아침"),
                ),
                CustomButton(
                  btnText: "11:59 (아침)",
                  onCallBack: () => _runQuickTest("11:59", "아침"),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 낮 시간대 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "12:00 (낮)",
                  onCallBack: () => _runQuickTest("12:00", "낮"),
                ),
                CustomButton(
                  btnText: "14:30 (낮)",
                  onCallBack: () => _runQuickTest("14:30", "낮"),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 저녁 시간대 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "18:00 (저녁)",
                  onCallBack: () => _runQuickTest("18:00", "저녁"),
                ),
                CustomButton(
                  btnText: "20:30 (저녁)",
                  onCallBack: () => _runQuickTest("20:30", "저녁"),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 새벽/Anytime 시간대 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "03:00 (Anytime)",
                  onCallBack: () => _runQuickTest("03:00", "Anytime"),
                ),
                CustomButton(
                  btnText: "null (Anytime)",
                  onCallBack: () {
                    _timeController.clear();
                    _testTimeToStep();
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ============================================
            // Step → 한국어 변환 테스트 섹션
            // ============================================
            CustomText(
              "2. Step → 한국어 변환",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Step 입력 필드
            CustomTextField(
              controller: _stepController,
              hintText: "Step 입력 (0=아침, 1=낮, 2=저녁, 3=Anytime)",
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            // 변환 버튼
            CustomButton(
              btnText: "Step → 한국어 변환",
              onCallBack: _testStepToKorean,
            ),

            const SizedBox(height: 12),

            // 결과 표시
            if (_stepToKoreanResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.divider),
                ),
                child: CustomText(
                  _stepToKoreanResult,
                  style: TextStyle(color: p.textPrimary, fontSize: 16),
                ),
              ),

            const SizedBox(height: 20),

            // 빠른 테스트 버튼들
            CustomText(
              "빠른 테스트",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Step 값 테스트 버튼들
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "0 (아침)",
                  onCallBack: () {
                    _stepController.text = '0';
                    _testStepToKorean();
                  },
                ),
                CustomButton(
                  btnText: "1 (낮)",
                  onCallBack: () {
                    _stepController.text = '1';
                    _testStepToKorean();
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  btnText: "2 (저녁)",
                  onCallBack: () {
                    _stepController.text = '2';
                    _testStepToKorean();
                  },
                ),
                CustomButton(
                  btnText: "3 (Anytime)",
                  onCallBack: () {
                    _stepController.text = '3';
                    _testStepToKorean();
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 유효하지 않은 Step 값 테스트
            CustomButton(
              btnText: "유효하지 않은 값 (예: 99)",
              onCallBack: () {
                _stepController.text = '99';
                _testStepToKorean();
              },
            ),

            const SizedBox(height: 30),

            // ============================================
            // 통합 테스트 섹션
            // ============================================
            CustomText(
              "3. 통합 테스트",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            CustomText(
              "시간 입력부터 한국어 출력까지 전체 플로우 테스트",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 12),

            // 통합 테스트 버튼들
            CustomButton(
              btnText: "08:00 → Step → 한국어",
              onCallBack: () {
                final step = StepMapperUtil.mapTimeToStep("08:00");
                final korean = StepMapperUtil.stepToKorean(step);
                setState(() {
                  _timeToStepResult = '시간: 08:00\nStep: $step ($korean)';
                });
              },
            ),

            const SizedBox(height: 8),

            CustomButton(
              btnText: "14:30 → Step → 한국어",
              onCallBack: () {
                final step = StepMapperUtil.mapTimeToStep("14:30");
                final korean = StepMapperUtil.stepToKorean(step);
                setState(() {
                  _timeToStepResult = '시간: 14:30\nStep: $step ($korean)';
                });
              },
            ),

            const SizedBox(height: 8),

            CustomButton(
              btnText: "20:00 → Step → 한국어",
              onCallBack: () {
                final step = StepMapperUtil.mapTimeToStep("20:00");
                final korean = StepMapperUtil.stepToKorean(step);
                setState(() {
                  _timeToStepResult = '시간: 20:00\nStep: $step ($korean)';
                });
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
