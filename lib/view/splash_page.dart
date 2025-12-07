import 'dart:async';
import 'package:flutter/material.dart';
import '../custom/util/timer/custom_timer_util.dart';
import '../custom/util/navigation/custom_navigation_util.dart';
import 'main_range_view_v2.dart';

// 스플래시 화면
//
// 앱 시작 시 표시되는 스플래시 화면입니다.
// - 하얀 배경에 "Daily Flow" 큰 글자 표시
// - 하단에 "Ver 0.1.0" 작은 글자 표시
// - 3초 후 자동으로 MainRangeViewV2로 이동
// - 전체 화면 터치 시 타이머 취소하고 바로 이동
class SplashPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SplashPage({super.key, required this.onToggleTheme});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  final GlobalKey _titleKey = GlobalKey();
  double? _titleLeft;
  double? _titleTop;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 2초 후 자동 이동 타이머 시작
  void _startTimer() {
    _timer = CustomTimerUtil.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToMain();
      }
    });
  }

  // MainRangeViewV2로 이동
  void _navigateToMain() {
    _timer?.cancel();
    CustomNavigationUtil.to(
      context,
      MainRangeViewV2(onToggleTheme: widget.onToggleTheme),
      transitionType: PageTransitionType.fade,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: _navigateToMain,
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 텍스트 스타일 정의
            const textStyle = TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            );

            // 화면 크기
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            // 위젯이 빌드된 후 크기 측정
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final RenderBox? renderBox =
                  _titleKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null && mounted) {
                final size = renderBox.size;
                setState(() {
                  // 중앙 정렬 계산: left = (화면 너비 - 텍스트 너비) / 2
                  _titleLeft = (screenWidth - size.width) / 2;
                  // top은 중앙(50%)보다 위쪽 (화면 높이의 40% 지점에서 텍스트 중심 정렬)
                  _titleTop = screenHeight * 0.40 - size.height / 2;
                });
              }
            });

            // 초기 위치 (위젯 크기를 모를 때는 대략적인 값 사용)
            final initialLeft = _titleLeft ?? (screenWidth / 2 - 100);
            final initialTop = _titleTop ?? (screenHeight * 0.40 - 30);

            return Stack(
              children: [
                // 중앙에 Daily Flow 큰 글자
                Positioned(
                  left: initialLeft,
                  top: initialTop,
                  child: Text('Daily Flow', key: _titleKey, style: textStyle),
                ),
                // 우측 하단에 Ver 0.1.0 작은 글자
                Positioned(
                  right: 32,
                  bottom: 32,
                  child: const Text(
                    'Ver 0.1.0',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
