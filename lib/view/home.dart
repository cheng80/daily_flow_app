import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../vm/vm_notifier.dart';
import '../vm/theme_notifier.dart';
import '../model/todo_model.dart';

import '../app_custom/step_mapper_util.dart';
import '../app_custom/dummy_data_generator.dart';
import '../service/notification_service.dart';

import 'main_range_view_v2.dart';
import 'create_todo_view.dart';

//----------------------------------
//-- Home
//----------------------------------

// 모듈 테스트용 홈 화면 위젯 (인덱스)
//
// **주의:** 이 파일은 실제 메인 화면이 아닌, 커스텀 모듈 및 함수의 테스트/프로토타이핑 용도로 사용됩니다.
//
// 사용 목적:
// - 새로 개발된 커스텀 위젯/함수를 빠르게 테스트
// - 디자인 화면 작업 전 모듈 동작 확인
// - 테마 색상 및 스타일 검증
// - Riverpod Provider 테스트
class Home extends ConsumerWidget {
  const Home({super.key});

  //----------------------------------
  //-- Build
  //----------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: _buildAppBar(context, ref, p),
      drawer: _buildDrawer(context, ref, p),
      body: SafeArea(
        top: false,
        child: Container(
          color: p.background,
          child: SingleChildScrollView(
            child: CustomPadding.all(
              20,
              child: CustomColumn(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _buildScreenTestSection(context, p),
                  _buildDummyDataSection(context, ref, p),
                  _buildAlarmTestSection(context, ref, p),
                  _buildProviderTestSection(context, ref, p),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------
  //-- AppBar & Drawer
  //----------------------------------

  CustomAppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme p,
  ) {
    return CustomAppBar(
      drawerIconColor: p.textOnPrimary,
      drawerIcon: Icons.menu_rounded,
      toolbarHeight: 50,
      title: CustomText(
        "Home",
        style: TextStyle(color: p.textOnPrimary, fontSize: 24),
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeNotifierProvider);
            final isDark = themeMode == ThemeMode.dark;
            return Switch(
              value: isDark,
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, AppColorScheme p) {
    return CustomDrawer(
      header: DrawerHeader(
        decoration: BoxDecoration(color: p.cardBackground),
        child: CustomColumn(
          width: double.infinity,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 4,
          children: [
            CustomText(
              "데이터 관리",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      items: [],
      middleChildren: [
        CustomPadding.all(
          16,
          child: CustomColumn(
            children: [
              CustomButton(
                btnText: "모든 데이터 삭제",
                minimumSize: const Size(double.infinity, 50),
                onCallBack: () async {
                  await _handleClearAllData(ref, context);
                  CustomNavigationUtil.back(context);
                },
              ),
            ],
          ),
        ),
      ],
      footer: CustomPadding.all(
        16,
        child: CustomColumn(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              "DailyFlow v1.0.0",
              style: TextStyle(color: p.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  //----------------------------------
  //-- 화면 테스트 섹션
  //----------------------------------

  Widget _buildScreenTestSection(BuildContext context, AppColorScheme p) {
    return _buildExpansionCard(
      p: p,
      icon: Icons.phone_android_rounded,
      color: p.primary,
      title: '화면 테스트',
      children: [
        _buildModernButton(
          context,
          p,
          "범위 선택 메인 화면 V2",
          Icons.calendar_month_rounded,
          p.primary,
          () => CustomNavigationUtil.offAll(
            context,
            const MainRangeViewV2(),
            transitionType: PageTransitionType.fade,
          ),
        ),
        _buildModernButton(
          context,
          p,
          "일정 생성 화면",
          Icons.add_circle_outline_rounded,
          p.accent,
          () => CustomNavigationUtil.to(
            context,
            const CreateTodoView(),
            transitionType: PageTransitionType.fade,
          ),
        ),
      ],
    );
  }

  //----------------------------------
  //-- 더미 데이터 관리 섹션
  //----------------------------------

  Widget _buildDummyDataSection(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme p,
  ) {
    return _buildExpansionCard(
      p: p,
      icon: Icons.data_object_rounded,
      color: p.accent,
      title: '더미 데이터 관리',
      children: [
        _buildModernButton(
          context,
          p,
          "통계 테스트용 데이터 삽입 (3개월)",
          Icons.insert_chart_rounded,
          Colors.blue,
          () async {
            await DummyDataGenerator.insertStatisticsDummyData(context);
            _invalidateAllCalendarCache(ref);
          },
        ),
        _buildModernButton(
          context,
          p,
          "삭제된 Todo 데이터 삽입 (3개월)",
          Icons.delete_outline_rounded,
          Colors.orange,
          () async {
            await DummyDataGenerator.insertDeletedDummyData(context);
            _invalidateDeletedTodoCache(ref);
          },
        ),
        _buildModernButton(
          context,
          p,
          "Todo 데이터 전체 삭제",
          Icons.delete_forever_rounded,
          Colors.red,
          () async {
            await _handleClearTodoData(ref, context);
            _invalidateAllCalendarCache(ref);
          },
        ),
        _buildModernButton(
          context,
          p,
          "삭제된 Todo 데이터 전체 삭제",
          Icons.cleaning_services_rounded,
          Colors.red,
          () async {
            await DummyDataGenerator.clearDeletedData(context);
            _invalidateDeletedTodoCache(ref);
          },
        ),
      ],
    );
  }

  //----------------------------------
  //-- 알람 테스트 섹션
  //----------------------------------

  Widget _buildAlarmTestSection(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme p,
  ) {
    return _buildExpansionCard(
      p: p,
      icon: Icons.notifications_active_rounded,
      color: Colors.orange,
      title: '알람 테스트',
      children: [
        _buildModernButton(
          context,
          p,
          "등록된 알람 목록 조회",
          Icons.list_rounded,
          Colors.blue,
          () async => await _handleCheckPendingNotifications(context),
        ),
        _buildModernButton(
          context,
          p,
          "알람 등록 (3분 후)",
          Icons.alarm_add_rounded,
          Colors.green,
          () async => await _handleScheduleNotification(ref, context),
        ),
        _buildModernButton(
          context,
          p,
          "알람 취소 (최근 알람)",
          Icons.cancel_outlined,
          Colors.orange,
          () async => await _handleCancelNotification(ref, context),
        ),
        _buildModernButton(
          context,
          p,
          "모든 알람 취소",
          Icons.notifications_off_rounded,
          Colors.red,
          () async => await _handleCancelAllNotifications(context),
        ),
        _buildModernButton(
          context,
          p,
          "즉시 알람 표시",
          Icons.notification_important_rounded,
          Colors.purple,
          () async => await _handleShowNotification(context),
        ),
      ],
    );
  }

  //----------------------------------
  //-- Provider 테스트 섹션
  //----------------------------------

  Widget _buildProviderTestSection(
    BuildContext context,
    WidgetRef ref,
    AppColorScheme p,
  ) {
    return _buildExpansionCard(
      p: p,
      icon: Icons.settings_applications_rounded,
      color: Colors.purple,
      title: 'Riverpod Provider 테스트',
      children: [
        // 활성 Todo 리스트 조회
        _buildProviderDisplay(
          p,
          Consumer(
            builder: (context, ref, child) {
              final todoAsync = ref.watch(
                todoNotifierProvider(TodoType.normal),
              );
              return todoAsync.when(
                data: (todos) => CustomText(
                  "활성 Todo 개수: ${todos.length}",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => CustomText(
                  "로딩 중...",
                  style: TextStyle(color: p.textSecondary),
                ),
                error: (error, stack) => CustomText(
                  "에러: $error",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
        _buildModernButton(
          context,
          p,
          "활성 Todo 리스트 새로고침",
          Icons.refresh_rounded,
          Colors.blue,
          () => ref.invalidate(todoNotifierProvider(TodoType.normal)),
        ),
        // 삭제된 Todo 리스트 조회
        _buildProviderDisplay(
          p,
          Consumer(
            builder: (context, ref, child) {
              final deletedAsync = ref.watch(deletedTodoNotifierProvider);
              return deletedAsync.when(
                data: (todos) => CustomText(
                  "삭제된 Todo 개수: ${todos.length}",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => CustomText(
                  "로딩 중...",
                  style: TextStyle(color: p.textSecondary),
                ),
                error: (error, stack) => CustomText(
                  "에러: $error",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
        _buildModernButton(
          context,
          p,
          "삭제된 Todo 리스트 새로고침",
          Icons.refresh_rounded,
          Colors.blue,
          () => ref.invalidate(deletedTodoNotifierProvider),
        ),
        // 날짜 제약 조건 조회
        _buildProviderDisplay(
          p,
          Consumer(
            builder: (context, ref, child) {
              final constraintsAsync = ref.watch(dateConstraintsProvider);
              return constraintsAsync.when(
                data: (constraints) => CustomText(
                  "최소 날짜: ${constraints.minDate?.toString().split(' ')[0] ?? '없음'}\n"
                  "최대 날짜: ${constraints.maxDate?.toString().split(' ')[0] ?? '없음'}",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => CustomText(
                  "로딩 중...",
                  style: TextStyle(color: p.textSecondary),
                ),
                error: (error, stack) => CustomText(
                  "에러: $error",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
        _buildModernButton(
          context,
          p,
          "날짜 제약 조건 새로고침",
          Icons.refresh_rounded,
          Colors.blue,
          () => ref.invalidate(dateConstraintsProvider),
        ),
        // 특정 날짜 조회
        _buildProviderDisplay(
          p,
          Consumer(
            builder: (context, ref, child) {
              final now = DateTime.now();
              final todayStr =
                  '${now.year.toString().padLeft(4, '0')}-'
                  '${now.month.toString().padLeft(2, '0')}-'
                  '${now.day.toString().padLeft(2, '0')}';
              final todoByDateAsync = ref.watch(todoByDateProvider(todayStr));
              return todoByDateAsync.when(
                data: (todos) => CustomText(
                  "오늘($todayStr) Todo 개수: ${todos.length}",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => CustomText(
                  "로딩 중...",
                  style: TextStyle(color: p.textSecondary),
                ),
                error: (error, stack) => CustomText(
                  "에러: $error",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
        _buildModernButton(
          context,
          p,
          "오늘 날짜 Todo 새로고침",
          Icons.refresh_rounded,
          Colors.blue,
          () {
            final now = DateTime.now();
            final todayStr =
                '${now.year.toString().padLeft(4, '0')}-'
                '${now.month.toString().padLeft(2, '0')}-'
                '${now.day.toString().padLeft(2, '0')}';
            ref.invalidate(todoByDateProvider(todayStr));
          },
        ),
        // 달력 이벤트 캐시
        _buildProviderDisplay(
          p,
          Consumer(
            builder: (context, ref, child) {
              final now = DateTime.now();
              final yearMonth =
                  '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
              final calendarAsync = ref.watch(
                calendarEventsProvider(yearMonth),
              );
              return calendarAsync.when(
                data: (cache) => CustomText(
                  "현재 달(${now.year}-${now.month}) 캐시된 날짜 수: ${cache.length}",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => CustomText(
                  "로딩 중...",
                  style: TextStyle(color: p.textSecondary),
                ),
                error: (error, stack) => CustomText(
                  "에러: $error",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
        _buildModernButton(
          context,
          p,
          "달력 이벤트 캐시 새로고침",
          Icons.refresh_rounded,
          Colors.blue,
          () {
            final now = DateTime.now();
            final yearMonth =
                '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
            ref.invalidate(calendarEventsProvider(yearMonth));
          },
        ),
        // CRUD 작업 테스트
        _buildModernButton(
          context,
          p,
          "테스트 Todo 추가",
          Icons.add_circle_rounded,
          Colors.green,
          () async {
            final now = DateTime.now();
            final dateStr =
                '${now.year.toString().padLeft(4, '0')}-'
                '${now.month.toString().padLeft(2, '0')}-'
                '${now.day.toString().padLeft(2, '0')}';
            final testTodo = Todo.createNew(
              title: "Provider 테스트 일정",
              date: dateStr,
              step: 3,
              priority: 3,
            );
            final notifier = ref.read(
              todoNotifierProvider(TodoType.normal).notifier,
            );
            await notifier.insertTodo(testTodo);
            if (context.mounted) {
              CustomSnackBar.showSuccess(
                context,
                message: "테스트 Todo가 추가되었습니다.",
              );
            }
          },
        ),
      ],
    );
  }

  //----------------------------------
  //-- 공통 UI 헬퍼
  //----------------------------------

  // 확장 카드 (ExpansionTile) 래퍼
  Widget _buildExpansionCard({
    required AppColorScheme p,
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomExpansionTile(
        iconColor: color,
        collapsedIconColor: color,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: CustomRow(
          spacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            CustomText(
              title,
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        children: [
          CustomPadding.all(
            20,
            child: CustomColumn(spacing: 12, children: children),
          ),
        ],
      ),
    );
  }

  // 모던 버튼 헬퍼
  Widget _buildModernButton(
    BuildContext context,
    AppColorScheme p,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return CustomButton(
      btnText: CustomRow(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          Flexible(
            child: CustomText(
              text,
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      buttonType: ButtonType.outlined,
      backgroundColor: color,
      minimumSize: const Size(double.infinity, 56),
      onCallBack: onPressed,
    );
  }

  // Provider 표시 컨테이너
  Widget _buildProviderDisplay(AppColorScheme p, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  //----------------------------------
  //-- Handler: 데이터 관리
  //----------------------------------

  // 모든 데이터 삭제
  Future<void> _handleClearAllData(WidgetRef ref, BuildContext context) async {
    try {
      final todoNotifier = ref.read(
        todoNotifierProvider(TodoType.normal).notifier,
      );
      final deletedTodoNotifier = ref.read(
        deletedTodoNotifierProvider.notifier,
      );
      await todoNotifier.allClearData();
      await deletedTodoNotifier.allClearDeletedData();

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '모든 데이터가 삭제되었습니다.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '데이터 삭제 중 오류 발생: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Todo 데이터만 삭제
  Future<void> _handleClearTodoData(WidgetRef ref, BuildContext context) async {
    try {
      final todoNotifier = ref.read(
        todoNotifierProvider(TodoType.normal).notifier,
      );
      await todoNotifier.allClearData();

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Todo 데이터가 모두 삭제되었습니다.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Todo 데이터 삭제 중 오류 발생: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  //----------------------------------
  //-- Provider 캐시 갱신
  //----------------------------------

  /// Todo 관련 Provider 캐시 전체 갱신
  ///
  /// DB에 직접 데이터를 삽입/삭제한 후, Riverpod Provider 캐시를 무효화하여
  /// 다음 화면(달력 등)에서 최신 데이터를 표시하도록 합니다.
  void _invalidateAllCalendarCache(WidgetRef ref) {
    // 현재 달 ± 3개월 범위의 캐시를 모두 invalidate
    final now = DateTime.now();
    for (int offset = -3; offset <= 3; offset++) {
      final target = DateTime(now.year, now.month + offset);
      final yearMonth =
          '${target.year.toString().padLeft(4, '0')}-${target.month.toString().padLeft(2, '0')}';
      ref.invalidate(calendarEventsProvider(yearMonth));
    }
    // todoNotifier 갱신
    ref.invalidate(todoNotifierProvider(TodoType.normal));
    // todoByDate 전체 캐시 갱신 (Family Provider 전체 invalidate)
    ref.invalidate(todoByDateProvider);
    // todoByDateRange 전체 캐시 갱신
    ref.invalidate(todoByDateRangeProvider);
    // dateConstraints (min/max date) 갱신
    ref.invalidate(dateConstraintsProvider);
  }

  /// 삭제된 Todo 관련 Provider 캐시 갱신
  void _invalidateDeletedTodoCache(WidgetRef ref) {
    ref.invalidate(todoNotifierProvider(TodoType.deleted));
  }

  //----------------------------------
  //-- Handler: 알람 테스트
  //----------------------------------

  // 알람 등록 테스트 (3분 후)
  Future<void> _handleScheduleNotification(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final notificationService = NotificationService();
    final now = DateTime.now();
    final threeMinutesLater = now.add(const Duration(minutes: 3));
    final dateStr = CustomCommonUtil.formatDate(
      threeMinutesLater,
      'yyyy-MM-dd',
    );
    final timeStr = CustomCommonUtil.formatDate(threeMinutesLater, 'HH:mm');

    final testTodo = Todo.createNew(
      title: '알람 테스트',
      memo: '3분 후 알람이 울립니다. (알람 시간: $timeStr)',
      date: dateStr,
      time: timeStr,
      step: StepMapperUtil.mapTimeToStep(timeStr),
      priority: 3,
      hasAlarm: true,
    );

    final notificationId = await notificationService.scheduleNotification(
      testTodo,
    );

    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: notificationId != null
            ? '알람 등록 완료: notificationId=$notificationId\n시간: $timeStr'
            : '알람 등록 실패',
        duration: Duration(seconds: notificationId != null ? 3 : 2),
      );
    }
  }

  // 알람 취소 테스트
  Future<void> _handleCancelNotification(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final notificationService = NotificationService();
    final todosAsync = await ref.read(
      todoNotifierProvider(TodoType.normal).future,
    );

    // notificationId가 있는 Todo 찾기
    Todo? todoWithNotification;
    for (final todo in todosAsync) {
      if (todo.notificationId != null) {
        todoWithNotification = todo;
        break;
      }
    }

    if (todoWithNotification == null ||
        todoWithNotification.notificationId == null) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '취소할 알람이 없습니다.',
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    await notificationService.cancelNotification(
      todoWithNotification.notificationId!,
    );

    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message:
            '알람 취소 완료: notificationId=${todoWithNotification.notificationId}',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // 모든 알람 취소
  Future<void> _handleCancelAllNotifications(BuildContext context) async {
    final notificationService = NotificationService();
    await notificationService.cancelAllNotifications();

    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: '모든 알람이 취소되었습니다.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // 즉시 알람 표시
  Future<void> _handleShowNotification(BuildContext context) async {
    final notificationService = NotificationService();
    final hasPermission = await notificationService.requestPermission();
    if (!hasPermission) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '알람 권한이 거부되었습니다.\n설정에서 권한을 허용해주세요.',
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    await notificationService.showTestNotification();

    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: '즉시 알람을 표시했습니다.',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // 등록된 알람 목록 확인
  Future<void> _handleCheckPendingNotifications(BuildContext context) async {
    final notificationService = NotificationService();
    await notificationService.checkPendingNotifications();

    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: '콘솔에서 등록된 알람 목록을 확인하세요.',
        duration: const Duration(seconds: 2),
      );
    }
  }
}
