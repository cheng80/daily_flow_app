import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service/notification_service.dart';
import 'theme/app_colors.dart';
import 'view/create_todo_view.dart';
import 'view/home.dart';
import 'view/splash_page.dart';
import 'vm/vm_notifier.dart';
import 'custom/util/log/custom_log_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermission();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  AppThemeMode _mode = AppThemeMode.light;
  final NotificationService _notificationService = NotificationService();
  bool _isInitialCleanupDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 초기 알람 정리 (한 번만 실행)
    if (!_isInitialCleanupDone) {
      _isInitialCleanupDone = true;
      _performInitialCleanup();
    }
  }

  Future<void> _performInitialCleanup() async {
    try {
      // Provider를 통해 Todo 리스트 가져오기
      final todoAsync = await ref.read(todoNotifierProvider(TodoType.normal).future);
      final notifier = ref.read(todoNotifierProvider(TodoType.normal).notifier);
      
      // cleanupExpiredNotifications 호출
      await _notificationService.cleanupExpiredNotifications(
        todos: todoAsync,
        updateTodo: (todo) => notifier.updateTodo(todo),
      );
    } catch (e) {
      AppLogger.e('초기 알람 정리 중 오류 발생', tag: 'AppLifecycle', error: e);
    }
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
      _performCleanupOnResume().catchError((error) {
        AppLogger.e('과거 알람 정리 중 오류 발생', tag: 'AppLifecycle', error: error);
      });
    }
  }

  Future<void> _performCleanupOnResume() async {
    try {
      // Provider를 통해 Todo 리스트 가져오기
      final todoAsync = await ref.read(todoNotifierProvider(TodoType.normal).future);
      final notifier = ref.read(todoNotifierProvider(TodoType.normal).notifier);
      
      // cleanupExpiredNotifications 호출
      await _notificationService.cleanupExpiredNotifications(
        todos: todoAsync,
        updateTodo: (todo) => notifier.updateTodo(todo),
      );
    } catch (e) {
      AppLogger.e('포그라운드 복귀 시 알람 정리 중 오류 발생', tag: 'AppLifecycle', error: e);
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
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        // 페이드 트랜지션을 위한 PageRouteBuilder 생성 함수
        PageRoute<T> fadeRoute<T extends Object?>(
          Widget page, {
          RouteSettings? routeSettings,
        }) {
          return PageRouteBuilder<T>(
            settings: routeSettings,
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 300),
          );
        }

        switch (settings.name) {
          case '/home':
            return fadeRoute(
              Home(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
          case '/splash':
            return fadeRoute(
              SplashPage(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
          case '/':
            return fadeRoute(
              Home(onToggleTheme: _toggleTheme),
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
            return fadeRoute(
              CreateTodoView(
                onToggleTheme: _toggleTheme,
                initialDate: initialDate,
              ),
              routeSettings: settings,
            );
          default:
            return fadeRoute(
              Home(onToggleTheme: _toggleTheme),
              routeSettings: settings,
            );
        }
      },
    );
  }
}
