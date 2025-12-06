//main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'service/notification_service.dart';
import 'theme/app_colors.dart';
import 'view/create_todo_view.dart';
import 'view/home.dart';
import 'view/main_view.dart';
import 'custom/util/log/custom_log_util.dart';

/// 앱 진입점
///
/// Flutter 앱을 시작하고 MyApp 위젯을 실행합니다.
/// 알람 서비스를 초기화합니다.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알람 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();
  // main에서는 context가 없으므로 권한만 요청 (영구 거부 시 다이얼로그는 표시하지 않음)
  await notificationService.requestPermission();

  // 과거 알람 정리 (앱 시작 시 자동으로 지나간 알람들 정리)
  await notificationService.cleanupExpiredNotifications();

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// 현재 테마 모드 (기본값: 라이트 모드)
  AppThemeMode _mode = AppThemeMode.light;

  /// 알람 서비스 인스턴스
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // 앱 생명주기 관찰자 해제
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    AppLogger.d('앱 생명주기 변경: $state', tag: 'AppLifecycle');
    
    // 앱이 포그라운드로 돌아올 때 과거 알람 정리
    if (state == AppLifecycleState.resumed) {
      AppLogger.d('앱이 포그라운드로 돌아옴 - 과거 알람 정리 시작', tag: 'AppLifecycle');
      // 비동기 함수이므로 await 없이 호출 (생명주기 콜백은 동기 함수)
      _notificationService.cleanupExpiredNotifications().catchError((error) {
        AppLogger.e(
          '과거 알람 정리 중 오류 발생',
          tag: 'AppLifecycle',
          error: error,
        );
      });
    }
  }

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => Home(onToggleTheme: _toggleTheme),
            );
          case '/main_view':
            return MaterialPageRoute(
              builder: (context) => MainView(onToggleTheme: _toggleTheme),
            );
          case '/create_todo_view':
            // arguments에서 initialDate를 받을 수 있음
            final args = settings.arguments;
            DateTime? initialDate;
            if (args is Map<String, dynamic> && args['initialDate'] != null) {
              initialDate = args['initialDate'] as DateTime;
            } else if (args is DateTime) {
              initialDate = args;
            }
            return MaterialPageRoute(
              builder: (context) => CreateTodoView(
                onToggleTheme: _toggleTheme,
                initialDate: initialDate,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Home(onToggleTheme: _toggleTheme),
            );
        }
      },
    );
  }
}
