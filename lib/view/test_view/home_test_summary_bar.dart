import 'package:flutter/material.dart';
import '../../custom/custom.dart';
import '../../theme/app_colors.dart';
import '../../app_custom/app_common_util.dart';

/// 서머리바 위젯 테스트 화면
///
/// **목적:** `actionFourRangeBar` 함수의 동작을 테스트하고 검증합니다.
///
/// 테스트 항목:
/// - 4개 구간(아침, 낮, 저녁, Anytime) 비율 표시
/// - 다양한 비율 조합 테스트
/// - 테마 색상 적용
/// - 바 크기 조정
class HomeTestSummaryBar extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestSummaryBar({super.key, required this.onToggleTheme});

  @override
  State<HomeTestSummaryBar> createState() => _HomeTestSummaryBarState();
}

class _HomeTestSummaryBarState extends State<HomeTestSummaryBar> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  /// 아침 비율 (0.0 ~ 1.0)
  double _morningRatio = 0.2;

  /// 낮 비율 (0.0 ~ 1.0)
  double _noonRatio = 0.3;

  /// 저녁 비율 (0.0 ~ 1.0)
  double _eveningRatio = 0.2;

  /// 야간 비율 (0.0 ~ 1.0)
  final double _nightRatio = 0.1;

  /// Anytime 비율 (0.0 ~ 1.0)
  double _anytimeRatio = 0.2;

  /// 바 너비 (픽셀)
  double _barWidth = 300.0;

  /// 바 높이 (픽셀)
  double _barHeight = 40.0;

  /// 위젯 초기화
  ///
  /// 페이지가 새로 생성될 때 한 번 호출됩니다.
  /// 테마 상태를 라이트 모드(false)로 초기화합니다.
  @override
  void initState() {
    super.initState();
    _themeBool = false;
  }

  /// 위젯 빌드
  ///
  /// 서머리바 위젯 테스트용 UI를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText("서머리바 테스트", style: TextStyle(color: p.textPrimary)),
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

            // 서머리바 표시
            CustomText(
              "Summary Bar",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            CustomContainer(
              width: _barWidth,
              height: _barHeight,
              child: actionFourRangeBar(
                context,
                barWidth: _barWidth,
                barHeight: _barHeight,
                morningRatio: _morningRatio,
                noonRatio: _noonRatio,
                eveningRatio: _eveningRatio,
                nightRatio: _nightRatio,
                anytimeRatio: _anytimeRatio,
              ),
            ),

            const SizedBox(height: 20),

            // 비율 정보 표시
            CustomText(
              "비율 정보",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            CustomText(
              "아침: ${(_morningRatio * 100).toStringAsFixed(1)}%",
              style: TextStyle(color: p.textPrimary, fontSize: 14),
            ),
            CustomText(
              "낮: ${(_noonRatio * 100).toStringAsFixed(1)}%",
              style: TextStyle(color: p.textPrimary, fontSize: 14),
            ),
            CustomText(
              "저녁: ${(_eveningRatio * 100).toStringAsFixed(1)}%",
              style: TextStyle(color: p.textPrimary, fontSize: 14),
            ),
            CustomText(
              "Anytime: ${(_anytimeRatio * 100).toStringAsFixed(1)}%",
              style: TextStyle(color: p.textPrimary, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // ============================================
            // 테스트용 버튼 섹션
            // ============================================
            CustomText(
              "테스트 버튼",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 프리셋 비율 버튼들
            CustomText(
              "프리셋 비율",
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 균등 분배
                CustomButton(
                  btnText: "균등",
                  onCallBack: () {
                    setState(() {
                      _morningRatio = 0.25;
                      _noonRatio = 0.25;
                      _eveningRatio = 0.25;
                      _anytimeRatio = 0.25;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 아침 집중
                CustomButton(
                  btnText: "아침 집중",
                  onCallBack: () {
                    setState(() {
                      _morningRatio = 0.6;
                      _noonRatio = 0.2;
                      _eveningRatio = 0.1;
                      _anytimeRatio = 0.1;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 저녁 집중
                CustomButton(
                  btnText: "저녁 집중",
                  onCallBack: () {
                    setState(() {
                      _morningRatio = 0.1;
                      _noonRatio = 0.2;
                      _eveningRatio = 0.6;
                      _anytimeRatio = 0.1;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 빈 바 (모든 비율 0)
                CustomButton(
                  btnText: "빈 바",
                  onCallBack: () {
                    setState(() {
                      _morningRatio = 0.0;
                      _noonRatio = 0.0;
                      _eveningRatio = 0.0;
                      _anytimeRatio = 0.0;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 기본 비율
                CustomButton(
                  btnText: "기본",
                  onCallBack: () {
                    setState(() {
                      _morningRatio = 0.2;
                      _noonRatio = 0.3;
                      _eveningRatio = 0.4;
                      _anytimeRatio = 0.1;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 바 크기 조정
            CustomText(
              "바 크기",
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 너비 조정
                CustomButton(
                  btnText: "너비 ${_barWidth.toInt()}px",
                  onCallBack: () {
                    setState(() {
                      if (_barWidth == 300) {
                        _barWidth = 400;
                      } else if (_barWidth == 400) {
                        _barWidth = 500;
                      } else {
                        _barWidth = 300;
                      }
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 높이 조정
                CustomButton(
                  btnText: "높이 ${_barHeight.toInt()}px",
                  onCallBack: () {
                    setState(() {
                      if (_barHeight == 40) {
                        _barHeight = 50;
                      } else if (_barHeight == 50) {
                        _barHeight = 60;
                      } else {
                        _barHeight = 40;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
