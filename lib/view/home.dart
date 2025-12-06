import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import 'home_test_calendar.dart';
import 'home_test_summary_bar.dart';
import 'home_test_step_mapper.dart';
import 'home_test_filter_radio.dart';
import 'home_test_calendar_test.dart';

import 'home_test_calendar_picker_dialog.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';
import '../util/step_mapper_util.dart';

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

              // 테스트 화면 이동 버튼들
              CustomText(
                "테스트 화면",
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              CustomButton(
                btnText: "MainView 이동",
                onCallBack: () {
                  CustomNavigationUtil.toNamed(
                    context,
                    "/main_view",
                    arguments: widget.onToggleTheme,
                  );
                },
              ),

              CustomButton(
                btnText: "CreateTodoView 이동",
                onCallBack: () {
                  CustomNavigationUtil.toNamed(
                    context,
                    "/create_todo_view",
                    arguments: widget.onToggleTheme,
                  );
                },
              ),

              CustomButton(
                btnText: "캘린더 테스트",
                onCallBack: () {
                  CustomNavigationUtil.to(
                    context,
                    HomeTestCalendar(onToggleTheme: widget.onToggleTheme),
                  );
                },
              ),

              CustomButton(
                btnText: "서머리바 테스트",
                onCallBack: () {
                  CustomNavigationUtil.to(
                    context,
                    HomeTestSummaryBar(onToggleTheme: widget.onToggleTheme),
                  );
                },
              ),

              CustomButton(
                btnText: "StepMapper 테스트",
                onCallBack: () {
                  CustomNavigationUtil.to(
                    context,
                    HomeTestStepMapper(onToggleTheme: widget.onToggleTheme),
                  );
                },
              ),

              CustomButton(
                btnText: "Filter Radio 테스트",
                onCallBack: () {
                  CustomNavigationUtil.to(
                    context,
                    HomeTestFilterRadio(onToggleTheme: widget.onToggleTheme),
                  );
                },
              ),

              CustomButton(
                btnText: "2025년 12월 더미 데이터 삽입",
                onCallBack: () async {
                  await _insertDummyData(context);
                },
              ),

              CustomButton(
                btnText: "테스트용 날짜 선택 다이얼로그",
                onCallBack: () {
                  CustomNavigationUtil.to(
                    context,
                    HomeTestCalendarPickerDialogTest(
                      onToggleTheme: widget.onToggleTheme,
                    ),
                  );
                },
              ),

              CustomButton(
                btnText: "테스트용 달력 (크기 조절 가능)",
                onCallBack: () {
                  CustomNavigationUtil.to(
                    context,
                    HomeTestCalendarTest(onToggleTheme: widget.onToggleTheme),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 모든 데이터 삭제 함수
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

  /// 2025년 12월 더미 데이터 삽입 함수
  ///
  /// 다양한 날짜, 시간대, 우선순위의 Todo 데이터를 생성하여 데이터베이스에 삽입합니다.
  /// 오늘 날짜 데이터도 포함됩니다.
  /// 중복 추가를 방지하기 위해 기존 데이터를 확인합니다.
  Future<void> _insertDummyData(BuildContext context) async {
    final dbHandler = DatabaseHandler();
    final now = DateTime.now();
    final todayStr =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    // 중복 체크: 2025년 12월 데이터가 이미 있는지 확인
    try {
      final existingData = await dbHandler.queryDataByDate('2025-12-01');
      if (existingData.isNotEmpty) {
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: '2025년 12월 데이터가 이미 존재합니다.\n먼저 모든 데이터를 삭제해주세요.',
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }
    } catch (e) {
      print("Error checking existing data: $e");
    }

    // 2025년 12월 더미 데이터 리스트
    final List<Map<String, dynamic>> dummyData = [
      // 12월 초반 (1일~10일)
      {
        'date': '2025-12-01',
        'title': '12월 첫날 회의',
        'time': '09:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 4,
        'memo': '월간 계획 회의',
      },
      {
        'date': '2025-12-01',
        'title': '점심 약속',
        'time': '12:30',
        'step': StepMapperUtil.stepNoon,
        'priority': 3,
        'memo': '친구와 점심',
      },
      {
        'date': '2025-12-02',
        'title': '오전 운동',
        'time': '07:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 2,
        'memo': '조깅하기',
      },
      {
        'date': '2025-12-02',
        'title': '프로젝트 작업',
        'time': '14:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 5,
        'memo': '중요한 작업',
      },
      {
        'date': '2025-12-03',
        'title': '저녁 식사',
        'time': '19:00',
        'step': StepMapperUtil.stepEvening,
        'priority': 3,
        'memo': '가족 저녁',
      },
      {
        'date': '2025-12-03',
        'title': '영화 보기',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 2,
        'memo': '주말 영화',
      },
      {
        'date': '2025-12-04',
        'title': '오전 미팅',
        'time': '10:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 4,
        'memo': '팀 미팅',
      },
      {
        'date': '2025-12-05',
        'title': '점심 회의',
        'time': '13:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 4,
        'memo': '고객 미팅',
      },
      {
        'date': '2025-12-05',
        'title': '저녁 약속',
        'time': '18:30',
        'step': StepMapperUtil.stepEvening,
        'priority': 3,
        'memo': '친구 만나기',
      },
      {
        'date': '2025-12-06',
        'title':
            '이것은 매우 긴 제목입니다. 이 제목은 한 줄로 표시되고 길어지면 말줄임표로 표시되어야 합니다. 이 텍스트가 충분히 길어서 말줄임표가 나타나는지 확인할 수 있도록 만들었습니다.',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 2,
        'memo':
            '이것은 매우 긴 메모입니다. 이 메모도 한 줄로 표시되고 길어지면 말줄임표로 표시되어야 합니다. 메모 텍스트가 충분히 길어서 말줄임표가 나타나는지 확인할 수 있도록 만들었습니다. 추가로 더 많은 텍스트를 넣어서 확실하게 말줄임표가 나타나도록 하겠습니다.',
      },

      // 12월 중반 (11일~20일)
      {
        'date': '2025-12-11',
        'title': '오전 프레젠테이션',
        'time': '11:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 5,
        'memo': '중요 프레젠테이션',
      },
      {
        'date': '2025-12-11',
        'title': '점심 식사',
        'time': '12:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 2,
        'memo': '동료와 점심',
      },
      {
        'date': '2025-12-12',
        'title': '오후 미팅',
        'time': '15:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 4,
        'memo': '프로젝트 미팅',
      },
      {
        'date': '2025-12-12',
        'title': '저녁 운동',
        'time': '20:00',
        'step': StepMapperUtil.stepEvening,
        'priority': 3,
        'memo': '헬스장',
      },
      {
        'date': '2025-12-13',
        'title': '오전 독서',
        'time': '08:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 2,
        'memo': '아침 독서 시간',
      },
      {
        'date': '2025-12-14',
        'title': '주말 여행',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 3,
        'memo': '가족 여행',
      },
      {
        'date': '2025-12-15',
        'title': '점심 약속',
        'time': '13:30',
        'step': StepMapperUtil.stepNoon,
        'priority': 3,
        'memo': '친구 만나기',
      },
      {
        'date': '2025-12-16',
        'title': '오전 회의',
        'time': '09:30',
        'step': StepMapperUtil.stepMorning,
        'priority': 4,
        'memo': '주간 회의',
      },
      {
        'date': '2025-12-17',
        'title': '저녁 파티',
        'time': '19:30',
        'step': StepMapperUtil.stepEvening,
        'priority': 3,
        'memo': '회사 파티',
      },
      {
        'date': '2025-12-18',
        'title': '쇼핑',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 2,
        'memo': '선물 구매',
      },

      // 12월 후반 (21일~31일)
      {
        'date': '2025-12-21',
        'title': '크리스마스 준비',
        'time': '10:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 4,
        'memo': '장식 준비',
      },
      {
        'date': '2025-12-22',
        'title': '점심 약속',
        'time': '12:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 3,
        'memo': '가족 점심',
      },
      {
        'date': '2025-12-23',
        'title': '저녁 파티',
        'time': '18:00',
        'step': StepMapperUtil.stepEvening,
        'priority': 4,
        'memo': '크리스마스 파티',
      },
      {
        'date': '2025-12-24',
        'title': '크리스마스 이브',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 5,
        'memo': '특별한 날',
      },
      {
        'date': '2025-12-25',
        'title': '크리스마스',
        'time': '09:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 5,
        'memo': '가족 모임',
      },
      {
        'date': '2025-12-25',
        'title': '크리스마스 저녁',
        'time': '19:00',
        'step': StepMapperUtil.stepEvening,
        'priority': 5,
        'memo': '특별 저녁',
      },
      {
        'date': '2025-12-26',
        'title': '휴식',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 2,
        'memo': '편안한 하루',
      },
      {
        'date': '2025-12-28',
        'title': '연말 정리',
        'time': '14:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 4,
        'memo': '올해 정리',
      },
      {
        'date': '2025-12-29',
        'title': '새해 준비',
        'time': '10:00',
        'step': StepMapperUtil.stepMorning,
        'priority': 3,
        'memo': '새해 계획',
      },
      {
        'date': '2025-12-31',
        'title': '연말 파티',
        'time': '21:00',
        'step': StepMapperUtil.stepEvening,
        'priority': 5,
        'memo': '새해 맞이',
      },
      {
        'date': '2025-12-31',
        'title': '새해 카운트다운',
        'time': null,
        'step': StepMapperUtil.stepAnytime,
        'priority': 5,
        'memo': '특별한 순간',
      },
    ];

    // 오늘 날짜 데이터 추가 (2025년 12월이 아니거나 이미 포함되지 않은 경우)
    final todayInList = dummyData.any((data) => data['date'] == todayStr);
    if (!todayInList) {
      // 오늘 날짜의 시간에 따라 적절한 Step 결정
      final currentHour = now.hour;
      int todayStep;
      String? todayTime;

      if (currentHour >= 6 && currentHour < 12) {
        todayStep = StepMapperUtil.stepMorning;
        todayTime = '${currentHour.toString().padLeft(2, '0')}:00';
      } else if (currentHour >= 12 && currentHour < 18) {
        todayStep = StepMapperUtil.stepNoon;
        todayTime = '${currentHour.toString().padLeft(2, '0')}:00';
      } else if (currentHour >= 18 && currentHour < 24) {
        todayStep = StepMapperUtil.stepEvening;
        todayTime = '${currentHour.toString().padLeft(2, '0')}:00';
      } else {
        todayStep = StepMapperUtil.stepAnytime;
        todayTime = null;
      }

      dummyData.insert(0, {
        'date': todayStr,
        'title': '오늘의 일정',
        'time': todayTime,
        'step': todayStep,
        'priority': 4,
        'memo': '오늘 날짜 데이터',
      });
    }

    try {
      int successCount = 0;
      int failCount = 0;

      for (var data in dummyData) {
        try {
          final todo = Todo.createNew(
            title: data['title'] as String,
            memo: data['memo'] as String?,
            date: data['date'] as String,
            time: data['time'] as String?,
            step: data['step'] as int,
            priority: data['priority'] as int,
            isDone: false,
            hasAlarm: false,
          );

          final id = await dbHandler.insertData(todo);
          if (id > 0) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          print('더미 데이터 삽입 실패: ${data['title']} - $e');
        }
      }

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '더미 데이터 삽입 완료!\n성공: $successCount개, 실패: $failCount개',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '더미 데이터 삽입 중 오류 발생: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
