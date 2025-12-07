import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'service/notification_service.dart';
import 'theme/app_colors.dart';
import 'view/create_todo_view.dart';
import 'view/home.dart';
import 'view/main_view.dart';
import 'view/splash_page.dart';
import 'custom/util/log/custom_log_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermission();
  await notificationService.cleanupExpiredNotifications();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppThemeMode _mode = AppThemeMode.light;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    AppLogger.d('앱 생명주기 변경: $state', tag: 'AppLifecycle');

    if (state == AppLifecycleState.resumed) {
      AppLogger.d('앱이 포그라운드로 돌아옴 - 과거 알람 정리 시작', tag: 'AppLifecycle');
      _notificationService.cleanupExpiredNotifications().catchError((error) {
        AppLogger.e('과거 알람 정리 중 오류 발생', tag: 'AppLifecycle', error: error);
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _mode = _mode == AppThemeMode.light
          ? AppThemeMode.dark
          : AppThemeMode.light;
    });
  }

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

      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('ko', 'KR'),
        const Locale('ja', 'JP'),
      ],
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        // 페이드 트랜지션을 위한 PageRouteBuilder 생성 함수
        PageRoute<T> _fadeRoute<T extends Object?>(
          Widget page, {
          RouteSettings? routeSettings,
        }) {
          return PageRouteBuilder<T>(
            settings: routeSettings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        }

        switch (settings.name) {
          case '/splash':
            return _fadeRoute(
              SplashPage(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
          case '/':
            return _fadeRoute(
              Home(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
          case '/main_view':
            return _fadeRoute(
              MainView(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
          case '/create_todo_view':
            final args = settings.arguments;
            DateTime? initialDate;
            if (args is Map<String, dynamic> && args['initialDate'] != null) {
              initialDate = args['initialDate'] as DateTime;
            } else if (args is DateTime) {
              initialDate = args;
            }
            return _fadeRoute(
              CreateTodoView(
                onToggleTheme: _toggleTheme,
                initialDate: initialDate,
              ),
              routeSettings: settings,
            );
          default:
            return _fadeRoute(
              Home(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
        }
      },
    );
  }
}
