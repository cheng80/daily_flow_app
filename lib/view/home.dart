import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import 'home_test_calendar.dart';
import 'home_test_summary_bar.dart';

/// 모듈 테스트용 홈 화면 위젯 (인덱스)
///
/// **주의:** 이 파일은 실제 메인 화면이 아닌, 커스텀 모듈 및 함수의 테스트/프로토타이핑 용도로 사용됩니다.
///
/// 사용 목적:
/// - 새로 개발된 커스텀 위젯/함수를 빠르게 테스트
/// - 디자인 화면 작업 전 모듈 동작 확인
/// - 테마 색상 및 스타일 검증
///
/// 실제 메인 화면은 `lib/view/main/main_view.dart`에서 별도로 구현됩니다.
/// 각 모듈 개발 완료 후, 완성된 커스텀 모듈과 함수를 사용하여 실제 화면을 구성합니다.
class Home extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const Home({super.key, required this.onToggleTheme});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

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
  /// 테스트 화면 선택 메뉴를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText("테스트 화면", style: TextStyle(color: p.textPrimary)),
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
              "모듈 테스트 화면",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            CustomText(
              "각 기능별 테스트 화면을 선택하세요",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 40),

            // 테스트 화면 이동 버튼들
            CustomText(
              "테스트 화면",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // 캘린더 테스트 버튼
            CustomButton(
              btnText: "캘린더 테스트",
              onCallBack: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomeTestCalendar(onToggleTheme: widget.onToggleTheme),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // 서머리바 테스트 버튼
            CustomButton(
              btnText: "서머리바 테스트",
              onCallBack: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomeTestSummaryBar(onToggleTheme: widget.onToggleTheme),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
