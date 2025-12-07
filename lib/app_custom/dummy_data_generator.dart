import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../custom/custom.dart';
import '../custom/util/log/custom_log_util.dart';
import '../model/todo_model.dart';
import '../vm/database_handler.dart';
import 'step_mapper_util.dart';

/// 더미 데이터 생성 유틸리티
///
/// 테스트 및 개발을 위한 더미 데이터를 생성하는 함수들을 제공합니다.
class DummyDataGenerator {
  static final Random _random = Random();

  /// 2025년 12월 더미 데이터 삽입
  ///
  /// 다양한 날짜, 시간대, 우선순위의 Todo 데이터를 생성하여 데이터베이스에 삽입합니다.
  /// 오늘 날짜 데이터도 포함됩니다.
  /// 중복 추가를 방지하기 위해 기존 데이터를 확인합니다.
  static Future<void> insertDummyData(BuildContext context) async {
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
      AppLogger.e("Error checking existing data", tag: 'DummyData', error: e);
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
        'title': '새벽 운동',
        'time': '05:00',
        'step': StepMapperUtil.stepNight,
        'priority': 3,
        'memo': '새벽 조깅',
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
      {
        'date': '2025-12-07',
        'title': '오후 미팅',
        'time': '14:00',
        'step': StepMapperUtil.stepNoon,
        'priority': 3,
        'memo': '오후 프로젝트 미팅',
      },
      {
        'date': '2025-12-07',
        'title': '저녁 식사',
        'time': '19:00',
        'step': StepMapperUtil.stepEvening,
        'priority': 2,
        'memo': '가족 저녁 식사',
      },
      {
        'date': '2025-12-07',
        'title': '야간 공부',
        'time': '02:00',
        'step': StepMapperUtil.stepNight,
        'priority': 4,
        'memo': '새벽 집중 공부',
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
        'title': '새벽 공부',
        'time': '03:30',
        'step': StepMapperUtil.stepNight,
        'priority': 4,
        'memo': '새벽 집중 공부',
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
        'date': '2025-12-19',
        'title': '새벽 명상',
        'time': '04:00',
        'step': StepMapperUtil.stepNight,
        'priority': 2,
        'memo': '새벽 명상 시간',
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
        'date': '2025-12-27',
        'title': '새벽 기도',
        'time': '05:30',
        'step': StepMapperUtil.stepNight,
        'priority': 3,
        'memo': '새벽 기도 시간',
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
      } else if (currentHour >= 0 && currentHour < 6) {
        todayStep = StepMapperUtil.stepNight;
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
          AppLogger.e(
            '더미 데이터 삽입 실패: ${data['title']}',
            tag: 'DummyData',
            error: e,
          );
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

  /// 삭제된 Todo 더미 데이터 삽입
  ///
  /// deleted_todo 테이블에 3개월치 더미 데이터를 삽입합니다.
  /// 현재로부터 3개월 전 ~ 현재까지의 범위에서 다양한 패턴의 삭제된 Todo 데이터를 생성합니다.
  static Future<void> insertDeletedDummyData(BuildContext context) async {
    final dbHandler = DatabaseHandler();
    final random = _random;
    final now = DateTime.now();
    final db = await dbHandler.initializeDB();

    // 날짜 범위: 현재로부터 3개월 전 ~ 현재
    final startDate = DateTime(now.year, now.month - 3, 1);
    final endDate = now;

    try {
      int successCount = 0;
      int failCount = 0;
      final totalDays = endDate.difference(startDate).inDays;

      AppLogger.i('삭제된 Todo 더미 데이터 생성 시작: 3개월치', tag: 'DummyData');

      // Step, 중요도, 시간 목록
      final steps = [
        StepMapperUtil.stepMorning,
        StepMapperUtil.stepNoon,
        StepMapperUtil.stepEvening,
        StepMapperUtil.stepNight,
        StepMapperUtil.stepAnytime,
      ];

      final priorities = [1, 2, 3, 4, 5];

      // 시간별 시간대 (Step에 맞춤)
      final timeRanges = {
        StepMapperUtil.stepMorning: [
          '07:00',
          '08:00',
          '09:00',
          '10:00',
          '11:00',
        ],
        StepMapperUtil.stepNoon: [
          '12:00',
          '13:00',
          '14:00',
          '15:00',
          '16:00',
          '17:00',
        ],
        StepMapperUtil.stepEvening: [
          '18:00',
          '19:00',
          '20:00',
          '21:00',
          '22:00',
          '23:00',
        ],
        StepMapperUtil.stepNight: [
          '00:00',
          '01:00',
          '02:00',
          '03:00',
          '04:00',
          '05:00',
        ],
        StepMapperUtil.stepAnytime: [], // 종일은 시간 없음
      };

      final memoTemplates = [
        '삭제된 일정 메모 1',
        '삭제된 일정 메모 2',
        '삭제된 일정 메모 3',
        '삭제된 일정 메모 4',
        null, // 메모 없음 (50% 확률)
        null,
      ];

      final titleTemplates = [
        '삭제된 프로젝트 회의',
        '삭제된 팀 미팅',
        '삭제된 점심 약속',
        '삭제된 운동하기',
        '삭제된 책 읽기',
        '삭제된 과제 제출',
        '삭제된 장보기',
        '삭제된 청소하기',
        '삭제된 프로젝트 진행',
        '삭제된 코드 리뷰',
      ];

      // 주 단위 패턴 정의 (삭제된 데이터는 일반적으로 적은 양)
      // 0: 골고루 퍼진 주 (매일 0-1개)
      // 1: 몰린 주 (특정 날에 2-3개, 다른 날은 0개)
      // 2: 적은 주 (매일 0개)
      // 3: 많은 주 (매일 1-2개)
      final weekPatterns = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]; // 패턴 반복

      // 날짜별로 삭제된 일정 생성
      for (int dayOffset = 0; dayOffset <= totalDays; dayOffset++) {
        final currentDate = startDate.add(Duration(days: dayOffset));
        final dateStr = CustomCommonUtil.formatDate(currentDate, 'yyyy-MM-dd');

        // 주 번호 계산 (0부터 시작)
        final weekNumber = dayOffset ~/ 7;
        final dayInWeek = dayOffset % 7;

        // 주 패턴 선택 (패턴 배열 순환)
        final weekPattern = weekPatterns[weekNumber % weekPatterns.length];

        int deletedTodosCount;

        // 주 패턴에 따라 삭제된 일정 개수 결정
        switch (weekPattern) {
          case 0: // 골고루 퍼진 주 (매일 0-1개)
            deletedTodosCount = random.nextInt(2); // 0-1개
            break;

          case 1: // 몰린 주 (특정 날에 2-3개, 다른 날은 0개)
            // 주 중 특정 날(목요일, 금요일)에 몰림
            if (dayInWeek == 3 || dayInWeek == 4) {
              deletedTodosCount = random.nextInt(2) + 2; // 2-3개
            } else {
              deletedTodosCount = 0;
            }
            break;

          case 2: // 적은 주 (매일 0개)
            deletedTodosCount = 0;
            break;

          case 3: // 많은 주 (매일 1-2개)
            deletedTodosCount = random.nextInt(2) + 1; // 1-2개
            break;

          default:
            deletedTodosCount = random.nextInt(2);
        }

        // 삭제된 일정이 없는 날은 스킵
        if (deletedTodosCount == 0) {
          continue;
        }

        // 삭제 시간은 해당 날짜의 오후 시간으로 설정 (실제 삭제 시점을 시뮬레이션)
        final deletedDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          14 + random.nextInt(6), // 14시~19시 사이
          random.nextInt(60), // 0~59분
        );
        final deletedAt = CustomCommonUtil.formatDate(
          deletedDateTime,
          'yyyy-MM-dd HH:mm:ss',
        );

        for (int i = 0; i < deletedTodosCount; i++) {
          try {
            // Step 선택 (균등 분포)
            final step = steps[random.nextInt(steps.length)];

            // 시간 선택
            String? time;
            if (step == StepMapperUtil.stepAnytime) {
              time = null; // 종일은 시간 없음
            } else {
              final timeList = timeRanges[step]!;
              time = timeList[random.nextInt(timeList.length)];
            }

            // 중요도 선택 (균등 분포)
            final priority = priorities[random.nextInt(priorities.length)];

            // 완료 여부 (삭제된 데이터는 30% 완료)
            final isDone = random.nextDouble() < 0.3;

            // 메모 작성 (50% 확률)
            final memoIndex = random.nextInt(memoTemplates.length);
            final memo = memoTemplates[memoIndex];

            // 제목 선택
            final titleIndex = random.nextInt(titleTemplates.length);
            final baseTitle = titleTemplates[titleIndex];
            final title = '$baseTitle ${random.nextInt(100)}'; // 중복 방지

            final deletedTodo = {
              'title': title,
              'memo': memo,
              'date': dateStr,
              'time': time,
              'step': step,
              'priority': priority,
              'is_done': isDone ? 1 : 0,
              'deleted_at': deletedAt,
            };

            await db.insert('deleted_todo', deletedTodo);
            successCount++;
          } catch (e) {
            failCount++;
            AppLogger.e(
              '삭제된 더미 데이터 삽입 실패: $dateStr',
              tag: 'DummyData',
              error: e,
            );
          }
        }
      }

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message:
              '삭제된 Todo 더미 데이터 삽입 완료!\n성공: $successCount개, 실패: $failCount개\n날짜 범위: ${CustomCommonUtil.formatDate(startDate, 'yyyy-MM-dd')} ~ ${CustomCommonUtil.formatDate(endDate, 'yyyy-MM-dd')}',
          duration: const Duration(seconds: 4),
        );
      }

      AppLogger.i(
        '삭제된 Todo 더미 데이터 생성 완료: 성공=$successCount, 실패=$failCount',
        tag: 'DummyData',
      );
    } catch (e) {
      AppLogger.e('삭제된 Todo 더미 데이터 삽입 중 오류 발생', tag: 'DummyData', error: e);
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '삭제된 Todo 더미 데이터 삽입 중 오류 발생: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 통계 테스트용 더미 데이터 삽입
  ///
  /// 현재로부터 3개월 전 ~ 현재까지의 날짜 범위에 다양한 패턴의 Todo 데이터를 생성합니다.
  /// - 골고루 퍼진 주, 몰린 주, 적은 주, 많은 주 등 다양한 분포 패턴
  /// - 다양한 Step, 중요도, 완료율, 알람 설정률, 메모 작성률
  static Future<void> insertStatisticsDummyData(BuildContext context) async {
    final dbHandler = DatabaseHandler();
    final random = _random;
    final now = DateTime.now();

    // 날짜 범위: 현재로부터 3개월 전 ~ 현재
    final startDate = DateTime(now.year, now.month - 3, 1);
    final endDate = now;

    // 중복 체크: 해당 범위에 데이터가 있는지 확인
    try {
      final minDate = await dbHandler.queryMinDate();
      final maxDate = await dbHandler.queryMaxDate();

      if (minDate != null && maxDate != null) {
        final existingMinDate = DateTime.parse(minDate);
        final existingMaxDate = DateTime.parse(maxDate);

        // 기존 데이터와 겹치는지 확인
        if (!startDate.isAfter(existingMaxDate) &&
            !endDate.isBefore(existingMinDate)) {
          if (context.mounted) {
            final completer = Completer<bool>();

            await CustomDialog.show(
              context,
              title: '데이터 확인',
              message: '해당 날짜 범위에 이미 데이터가 존재합니다.\n덮어쓰시겠습니까?',
              type: DialogType.dual,
              confirmText: '계속',
              cancelText: '취소',
              onConfirm: () {
                completer.complete(true);
              },
              onCancel: () {
                completer.complete(false);
              },
            );

            final shouldContinue = await completer.future;
            if (!shouldContinue) {
              return;
            }
          }
        }
      }
    } catch (e) {
      AppLogger.e('기존 데이터 확인 중 오류', tag: 'DummyData', error: e);
    }

    try {
      int successCount = 0;
      int failCount = 0;
      final totalDays = endDate.difference(startDate).inDays;
      final todosPerDay = 2.5; // 평균 하루당 일정 개수
      final totalTodos = (totalDays * todosPerDay).round();

      AppLogger.i('통계 테스트용 더미 데이터 생성 시작: $totalTodos개 예상', tag: 'DummyData');

      // Step, 중요도, 시간 목록
      final steps = [
        StepMapperUtil.stepMorning,
        StepMapperUtil.stepNoon,
        StepMapperUtil.stepEvening,
        StepMapperUtil.stepNight,
        StepMapperUtil.stepAnytime,
      ];

      final priorities = [1, 2, 3, 4, 5];

      // 시간별 시간대 (Step에 맞춤)
      final timeRanges = {
        StepMapperUtil.stepMorning: [
          '07:00',
          '08:00',
          '09:00',
          '10:00',
          '11:00',
        ],
        StepMapperUtil.stepNoon: [
          '12:00',
          '13:00',
          '14:00',
          '15:00',
          '16:00',
          '17:00',
        ],
        StepMapperUtil.stepEvening: [
          '18:00',
          '19:00',
          '20:00',
          '21:00',
          '22:00',
          '23:00',
        ],
        StepMapperUtil.stepNight: [
          '00:00',
          '01:00',
          '02:00',
          '03:00',
          '04:00',
          '05:00',
        ],
        StepMapperUtil.stepAnytime: [], // 종일은 시간 없음
      };

      final memoTemplates = [
        '중요한 회의 내용을 정리해야 합니다.',
        '준비물을 미리 챙겨두세요.',
        '장소 확인 필요',
        '지각하지 않도록 주의',
        '관련 자료 미리 읽어보기',
        '후속 작업 계획 수립',
        '피드백 요청',
        '추가 논의 사항 정리',
        null, // 메모 없음 (50% 확률)
        null,
      ];

      final titleTemplates = [
        '프로젝트 회의',
        '팀 미팅',
        '점심 약속',
        '운동하기',
        '책 읽기',
        '과제 제출',
        '장보기',
        '청소하기',
        '프로젝트 진행',
        '코드 리뷰',
        '문서 작성',
        '발표 준비',
        '설문 조사',
        '병원 예약',
        '은행 업무',
        '세미나 참석',
        '네트워킹',
        '기술 공유',
        '학습 시간',
        '취미 활동',
      ];

      // 주 단위 패턴 정의 (골고루 퍼진 주, 몰린 주 등)
      // 0: 골고루 퍼진 주 (매일 1-3개)
      // 1: 몰린 주 (특정 날에 5-8개, 다른 날은 0-2개)
      // 2: 적은 주 (매일 0-2개)
      // 3: 많은 주 (매일 3-6개)
      final weekPatterns = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3]; // 패턴 반복

      // 날짜별로 일정 생성
      for (int dayOffset = 0; dayOffset <= totalDays; dayOffset++) {
        final currentDate = startDate.add(Duration(days: dayOffset));
        final dateStr = CustomCommonUtil.formatDate(currentDate, 'yyyy-MM-dd');

        // 12월인지 확인 (12월은 더 많은 데이터 생성)
        final isDecember = currentDate.month == 12;

        // 주 번호 계산 (0부터 시작)
        final weekNumber = dayOffset ~/ 7;
        final dayInWeek = dayOffset % 7;

        // 주 패턴 선택 (패턴 배열 순환)
        final weekPattern = weekPatterns[weekNumber % weekPatterns.length];

        int todosCount;

        // 12월인 경우 더 많은 일정 생성
        if (isDecember) {
          // 주 패턴에 따라 일정 개수 결정 (12월은 기본값 + 2~4개 추가)
          switch (weekPattern) {
            case 0: // 골고루 퍼진 주 (매일 3-6개)
              todosCount = random.nextInt(4) + 3;
              break;

            case 1: // 몰린 주 (특정 날에 7-10개, 다른 날은 2-5개)
              // 주 중 특정 날(목요일, 금요일)에 몰림
              if (dayInWeek == 3 || dayInWeek == 4) {
                todosCount = random.nextInt(4) + 7; // 7-10개
              } else {
                todosCount = random.nextInt(4) + 2; // 2-5개
              }
              break;

            case 2: // 적은 주 (매일 2-4개)
              todosCount = random.nextInt(3) + 2; // 2-4개
              break;

            case 3: // 많은 주 (매일 5-8개)
              todosCount = random.nextInt(4) + 5; // 5-8개
              break;

            default:
              todosCount = random.nextInt(4) + 3;
          }
        } else {
          // 12월이 아닌 경우 기존 로직
          switch (weekPattern) {
            case 0: // 골고루 퍼진 주 (매일 1-3개)
              todosCount = random.nextInt(3) + 1;
              break;

            case 1: // 몰린 주 (특정 날에 5-8개, 다른 날은 0-2개)
              // 주 중 특정 날(목요일, 금요일)에 몰림
              if (dayInWeek == 3 || dayInWeek == 4) {
                todosCount = random.nextInt(4) + 5; // 5-8개
              } else {
                todosCount = random.nextInt(3); // 0-2개
              }
              break;

            case 2: // 적은 주 (매일 0-2개)
              todosCount = random.nextInt(3); // 0-2개
              break;

            case 3: // 많은 주 (매일 3-6개)
              todosCount = random.nextInt(4) + 3; // 3-6개
              break;

            default:
              todosCount = random.nextInt(3) + 1;
          }
        }

        // 일정이 없는 날은 스킵 (12월은 최소 1개는 보장)
        if (todosCount == 0 && !isDecember) {
          continue;
        }
        if (todosCount == 0 && isDecember) {
          todosCount = 1; // 12월은 최소 1개 보장
        }

        // 12월 5일인 경우 오후, 저녁, 야간 각 1개씩 추가
        final isDecember5 = currentDate.month == 12 && currentDate.day == 5;
        if (isDecember5) {
          todosCount += 3; // 오후 1개, 저녁 1개, 야간 1개 추가
        }

        for (int i = 0; i < todosCount; i++) {
          try {
            // Step 선택
            int step;
            // 12월 5일이고 마지막 3개인 경우 특정 Step 강제 지정
            if (isDecember5 && i >= todosCount - 3) {
              final additionalStepIndex = i - (todosCount - 3);
              switch (additionalStepIndex) {
                case 0: // 오후
                  step = StepMapperUtil.stepNoon;
                  break;
                case 1: // 저녁
                  step = StepMapperUtil.stepEvening;
                  break;
                case 2: // 야간
                  step = StepMapperUtil.stepNight;
                  break;
                default:
                  step = steps[random.nextInt(steps.length)];
              }
            } else {
              // 일반적인 경우: Step 선택 (균등 분포)
              step = steps[random.nextInt(steps.length)];
            }

            // 시간 선택
            String? time;
            if (step == StepMapperUtil.stepAnytime) {
              time = null; // 종일은 시간 없음
            } else {
              final timeList = timeRanges[step]!;
              time = timeList[random.nextInt(timeList.length)];
            }

            // 중요도 선택 (균등 분포)
            final priority = priorities[random.nextInt(priorities.length)];

            // 완료 여부 (65% 완료)
            final isDone = random.nextDouble() < 0.65;

            // 알람 설정 (40% 확률, 시간이 있을 때만)
            final hasAlarm = time != null && random.nextDouble() < 0.4;

            // 메모 작성 (50% 확률)
            final memoIndex = random.nextInt(memoTemplates.length);
            final memo = memoTemplates[memoIndex];

            // 제목 선택
            final titleIndex = random.nextInt(titleTemplates.length);
            final baseTitle = titleTemplates[titleIndex];
            final title = '$baseTitle ${random.nextInt(100)}'; // 중복 방지

            final todo = Todo.createNew(
              title: title,
              memo: memo,
              date: dateStr,
              time: time,
              step: step,
              priority: priority,
              isDone: isDone,
              hasAlarm: hasAlarm,
            );

            final id = await dbHandler.insertData(todo);

            // 완료 상태 업데이트 (isDone이 true인 경우)
            if (isDone && id > 0) {
              await dbHandler.toggleDone(id, true);
            }

            if (id > 0) {
              successCount++;
            } else {
              failCount++;
            }
          } catch (e) {
            failCount++;
            AppLogger.e('더미 데이터 삽입 실패: $dateStr', tag: 'DummyData', error: e);
          }
        }
      }

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message:
              '통계 테스트용 더미 데이터 삽입 완료!\n성공: $successCount개, 실패: $failCount개\n날짜 범위: ${CustomCommonUtil.formatDate(startDate, 'yyyy-MM-dd')} ~ ${CustomCommonUtil.formatDate(endDate, 'yyyy-MM-dd')}',
          duration: const Duration(seconds: 4),
        );
      }

      AppLogger.i(
        '통계 테스트용 더미 데이터 생성 완료: 성공=$successCount, 실패=$failCount',
        tag: 'DummyData',
      );
    } catch (e) {
      AppLogger.e('통계 테스트용 더미 데이터 삽입 중 오류 발생', tag: 'DummyData', error: e);
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '더미 데이터 삽입 중 오류 발생: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// 삭제된 Todo 데이터 삭제
  ///
  /// deleted_todo 테이블의 모든 데이터를 삭제합니다.
  static Future<void> clearDeletedData(BuildContext context) async {
    final dbHandler = DatabaseHandler();

    try {
      await dbHandler.allClearDeletedData();

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '삭제된 Todo 데이터가 모두 삭제되었습니다.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '삭제된 Todo 데이터 삭제 중 오류 발생: $e',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
