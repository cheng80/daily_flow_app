//main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_colors.dart';
import 'view/create_todo_view.dart';
import 'view/home.dart';
import 'view/main_view.dart';

/// 앱 진입점
///
/// Flutter 앱을 시작하고 MyApp 위젯을 실행합니다.
void main() {
  runApp(const MyApp());
}

/// DailyFlow 앱의 루트 위젯
///
/// 테마 모드 관리 및 MaterialApp 설정을 담당합니다.
/// 라이트/다크 모드 전환 기능을 제공합니다.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 현재 테마 모드 (기본값: 라이트 모드)
  AppThemeMode _mode = AppThemeMode.light;

  /// 테마 모드를 토글합니다.
  ///
  /// 라이트 모드와 다크 모드를 전환합니다.
  void _toggleTheme() {
    setState(() {
      _mode = _mode == AppThemeMode.light
          ? AppThemeMode.dark
          : AppThemeMode.light;
    });
  }

  /// MaterialApp 위젯을 빌드합니다.
  ///
  /// 테마 설정, 다국어 지원, 라우팅을 구성합니다.
  @override
  Widget build(BuildContext context) {
    final isDark = _mode == AppThemeMode.dark;

    return MaterialApp(
      title: 'Main',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      debugShowCheckedModeBanner: false, // 우측 상단 디버그 배너 제거
      // 다국어 지원
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 영어
        const Locale('ko', 'KR'), // 한국어
        const Locale('ja', 'JP'), // 일본어
      ],

      initialRoute: '/', // 처음 화면 지정
      routes: {
        '/': (context) => Home(onToggleTheme: _toggleTheme),
        '/main_view': (context) => MainView(onToggleTheme: _toggleTheme),
        '/create_todo_view': (context) =>
            CreateTodoView(onToggleTheme: _toggleTheme),
      },
    );
  }
}
