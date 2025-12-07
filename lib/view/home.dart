import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';

import 'test_view/home_test_calendar.dart';
import 'test_view/home_test_summary_bar.dart';
import 'test_view/home_test_step_mapper.dart';
import 'test_view/home_test_filter_radio.dart';
import 'test_view/home_test_calendar_test.dart';
import 'test_view/home_test_calendar_picker_dialog.dart';

import '../app_custom/step_mapper_util.dart';
import '../app_custom/dummy_data_generator.dart';
import '../service/notification_service.dart';

import 'main_range_view_v2.dart';
import 'statistics_range_view.dart';
import 'create_todo_view.dart';

// 모듈 테스트용 홈 화면 위젯 (인덱스)
//
// **주의:** 이 파일은 실제 메인 화면이 아닌, 커스텀 모듈 및 함수의 테스트/프로토타이핑 용도로 사용됩니다.
//
// 사용 목적:
// - 새로 개발된 커스텀 위젯/함수를 빠르게 테스트
// - 디자인 화면 작업 전 모듈 동작 확인
// - 테마 색상 및 스타일 검증
//
// 실제 메인 화면은 `lib/view/main/main_view.dart`에서 별도로 구현됩니다.
// 각 모듈 개발 완료 후, 완성된 커스텀 모듈과 함수를 사용하여 실제 화면을 구성합니다.
class Home extends StatefulWidget {
  // 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const Home({super.key, required this.onToggleTheme});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  // 위젯 초기화
  //
  // 페이지가 새로 생성될 때 한 번 호출됩니다.
  // 테마 상태를 라이트 모드(false)로 초기화합니다.
  @override
  void initState() {
    super.initState();
    _themeBool = false;
  }

  // 위젯 빌드
  //
  // 테스트 화면 선택 메뉴를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        drawerIconColor: p.textOnPrimary,
        drawerIcon: Icons.menu_rounded,
        toolbarHeight: 50,
        title: CustomText(
          "Home",
          style: TextStyle(color: p.textOnPrimary, fontSize: 24),
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
      drawer: CustomDrawer(
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
                    await _clearAllData(context);
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: CustomColumn(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 화면 테스트
              CustomExpansionTile(
                title: CustomText(
                  '화면 테스트',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  CustomColumn(
                    spacing: 10,
                    children: [
                      CustomButton(
                        btnText: "범위 선택 메인 화면 V2",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            MainRangeViewV2(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "범위 통계 조회",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            StatisticsRangeView(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "일정 생성 화면",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            CreateTodoView(onToggleTheme: widget.onToggleTheme),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "캘린더 테스트",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            HomeTestCalendar(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "서머리바 테스트",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            HomeTestSummaryBar(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "StepMapper 테스트",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            HomeTestStepMapper(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "Filter Radio 테스트",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            HomeTestFilterRadio(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "테스트용 날짜 선택 다이얼로그",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            HomeTestCalendarPickerDialogTest(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "테스트용 달력 (크기 조절 가능)",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () {
                          CustomNavigationUtil.to(
                            context,
                            HomeTestCalendarTest(
                              onToggleTheme: widget.onToggleTheme,
                            ),
                            transitionType: PageTransitionType.fade,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // 더미 데이터 관리
              CustomExpansionTile(
                title: CustomText(
                  '더미 데이터 관리',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  CustomColumn(
                    spacing: 10,
                    children: [
                      CustomButton(
                        btnText: "12월 더미 데이터 삽입",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await DummyDataGenerator.insertDummyData(context);
                        },
                      ),
                      CustomButton(
                        btnText: "통계 테스트용 데이터 삽입 (3개월)",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await DummyDataGenerator.insertStatisticsDummyData(
                            context,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "삭제된 Todo 데이터 삽입 (3개월)",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await DummyDataGenerator.insertDeletedDummyData(
                            context,
                          );
                        },
                      ),
                      CustomButton(
                        btnText: "Todo 데이터 전체 삭제",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await _clearTodoData(context);
                        },
                      ),
                      CustomButton(
                        btnText: "삭제된 Todo 데이터 전체 삭제",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await DummyDataGenerator.clearDeletedData(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // 알람 테스트
              CustomExpansionTile(
                title: CustomText(
                  '알람 테스트',
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  CustomColumn(
                    spacing: 10,
                    children: [
                      CustomButton(
                        btnText: "등록된 알람 목록 조회",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await _testCheckPendingNotifications(context);
                        },
                      ),
                      CustomButton(
                        btnText: "알람 등록 (1분 후)",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await _testScheduleNotification(context);
                        },
                      ),
                      CustomButton(
                        btnText: "알람 취소 (최근 알람)",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await _testCancelNotification(context);
                        },
                      ),
                      CustomButton(
                        btnText: "모든 알람 취소",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await _testCancelAllNotifications(context);
                        },
                      ),
                      CustomButton(
                        btnText: "즉시 알람 표시",
                        minimumSize: const Size(double.infinity, 50),
                        onCallBack: () async {
                          await _testShowNotification(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 모든 데이터 삭제 함수
  Future<void> _clearAllData(BuildContext context) async {
    final dbHandler = DatabaseHandler();

    try {
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();

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

  // Todo 데이터만 삭제 함수
  Future<void> _clearTodoData(BuildContext context) async {
    final dbHandler = DatabaseHandler();

    try {
      await dbHandler.allClearData();

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

  // 알람 등록 테스트 (1분 후 알람)
  Future<void> _testScheduleNotification(BuildContext context) async {
    final notificationService = NotificationService();

    // 1분 후 시간 계산
    final now = DateTime.now();
    final oneMinuteLater = now.add(const Duration(minutes: 1));
    final dateStr = CustomCommonUtil.formatDate(oneMinuteLater, 'yyyy-MM-dd');
    final timeStr = CustomCommonUtil.formatDate(oneMinuteLater, 'HH:mm');

    // 테스트용 Todo 생성
    final testTodo = Todo.createNew(
      title: '알람 테스트',
      memo: '1분 후 알람이 울립니다.',
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
      if (notificationId != null) {
        CustomSnackBar.show(
          context,
          message: '알람 등록 완료: notificationId=$notificationId\n시간: $timeStr',
          duration: const Duration(seconds: 3),
        );
      } else {
        CustomSnackBar.show(
          context,
          message: '알람 등록 실패',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  // 알람 취소 테스트
  Future<void> _testCancelNotification(BuildContext context) async {
    final notificationService = NotificationService();

    // 가장 최근에 등록된 알람의 ID를 찾기 위해 DB 조회
    final dbHandler = DatabaseHandler();
    final todos = await dbHandler.queryData();

    // notificationId가 있는 Todo 찾기
    Todo? todoWithNotification;
    for (final todo in todos) {
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

  // 모든 알람 취소 테스트
  Future<void> _testCancelAllNotifications(BuildContext context) async {
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

  // 즉시 알람 테스트
  Future<void> _testShowNotification(BuildContext context) async {
    final notificationService = NotificationService();

    // 권한 확인
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

    // 즉시 알람 표시
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
  Future<void> _testCheckPendingNotifications(BuildContext context) async {
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
