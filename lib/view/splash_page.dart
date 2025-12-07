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
        child: Stack(
          children: [
            // 중앙에 Daily Flow 큰 글자
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 120,
              top: MediaQuery.of(context).size.height * 0.5 - 150,
              child: Text(
                'Daily Flow',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // 우측 하단에 Ver 0.1.0 작은 글자
            Positioned(
              right: 32,
              bottom: 32,
              child: Text(
                'Ver 0.1.0',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
