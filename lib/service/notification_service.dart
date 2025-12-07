import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../model/todo_model.dart';
import '../vm/database_handler.dart';
import '../custom/util/log/custom_log_util.dart';

// 로컬 알람 서비스 클래스
//
// flutter_local_notifications를 사용하여 Todo 알람을 관리합니다.
// 1 Todo당 최대 1개의 알람만 지원합니다.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  static const String _channelId = 'daily_flow_alarm_channel';
  static const String _channelName = 'DailyFlow 알람';
  static const String _channelDescription = '일정 알람 알림';

  /// 알람 서비스 초기화 (앱 시작 시 한 번만 호출)
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // Timezone 초기화
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

      // Android 초기화 설정
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS 초기화 설정
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // 통합 초기화 설정
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 알람 초기화
      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        // Android 알람 채널 생성
        await _createNotificationChannel();
        _isInitialized = true;
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.e('알람 초기화 오류', tag: 'Notification', error: e);
      return false;
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// 알람 권한 상태 확인
  Future<bool> checkPermission() async {
    final status = await Permission.notification.status;
    AppLogger.d('알람 권한 상태: $status', tag: 'Permission');
    return status.isGranted;
  }

  /// 알람 권한 요청 (영구 거부 시 다이얼로그 표시)
  Future<bool> requestPermission({BuildContext? context}) async {
    if (!_isInitialized) {
      await initialize();
    }

    // iOS 권한 요청
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      // iOS 권한 상태 확인
      final status = await Permission.notification.status;

      if (status.isGranted) {
        AppLogger.i('iOS 알람 권한: 이미 허용됨', tag: 'Permission');
        return true;
      }

      if (status.isPermanentlyDenied) {
        AppLogger.w('iOS 알람 권한이 영구 거부되었습니다.', tag: 'Permission');
        AppLogger.w('설정에서 수동으로 권한을 허용해야 합니다.', tag: 'Permission');

        // 다이얼로그 표시 후 설정으로 이동
        if (context != null) {
          final shouldOpenSettings = await _showPermissionDeniedDialog(
            context,
            isIOS: true,
          );
          if (shouldOpenSettings) {
            await openAppSettings();
          }
        } else {
          // context가 없으면 바로 설정으로 이동
          await openAppSettings();
        }
        return false;
      }

      // 권한 요청
      final bool? result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      AppLogger.d('iOS 알람 권한 요청 결과: $result', tag: 'Permission');
      return result ?? false;
    }

    // Android 권한 확인 및 요청
    final status = await Permission.notification.status;
    AppLogger.d('Android 알람 권한 상태: $status', tag: 'Permission');

    // Android 12 이하는 권한이 필요 없음
    if (status.isLimited || status.isRestricted) {
      AppLogger.i('Android 12 이하: 알람 권한 불필요', tag: 'Permission');
      return true;
    }

    // 이미 허용된 경우
    if (status.isGranted) {
      AppLogger.i('Android 알람 권한: 이미 허용됨', tag: 'Permission');
      return true;
    }

    // 영구 거부된 경우
    if (status.isPermanentlyDenied) {
      AppLogger.w('Android 알람 권한이 영구 거부되었습니다.', tag: 'Permission');
      AppLogger.w('설정에서 수동으로 권한을 허용해야 합니다.', tag: 'Permission');

      // 다이얼로그 표시 후 설정으로 이동
      if (context != null) {
        final shouldOpenSettings = await _showPermissionDeniedDialog(
          context,
          isIOS: false,
        );
        if (shouldOpenSettings) {
          await openAppSettings();
        }
      } else {
        // context가 없으면 바로 설정으로 이동
        await openAppSettings();
      }
      return false;
    }

    // 거부되었지만 다시 요청 가능한 경우 (Android 13+)
    if (status.isDenied) {
      AppLogger.d('Android 알람 권한 요청 중...', tag: 'Permission');
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        AppLogger.d('Android 알람 권한 요청 결과: $granted', tag: 'Permission');
        return granted ?? false;
      }
    }

    return false;
  }

  /// 즉시 알람 테스트 (디버깅용)
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999999, // 테스트용 고유 ID
        '알람 테스트',
        '알람이 정상적으로 작동합니다!',
        notificationDetails,
      );
      AppLogger.s('즉시 알람 테스트 완료', tag: 'Notification');
    } catch (e) {
      AppLogger.e('즉시 알람 테스트 오류', tag: 'Notification', error: e);
    }
  }

  /// 알람 등록
  ///
  /// has_alarm=true AND time IS NOT NULL일 때만 등록
  /// 1 Todo당 최대 1개 알람만 지원, 기존 알람 자동 취소
  Future<int?> scheduleNotification(Todo todo) async {
    AppLogger.d('=== 알람 등록 시작 ===', tag: 'Notification');
    AppLogger.d(
      'Todo 정보: id=${todo.id}, title=${todo.title}, date=${todo.date}, time=${todo.time}, hasAlarm=${todo.hasAlarm}',
      tag: 'Notification',
    );

    // 알람 정책 확인
    if (!todo.hasAlarm || todo.time == null) {
      AppLogger.w(
        '알람 등록 조건 불만족: hasAlarm=${todo.hasAlarm}, time=${todo.time}',
        tag: 'Notification',
      );
      return null;
    }
    AppLogger.d('알람 등록 조건 만족', tag: 'Notification');

    if (!_isInitialized) {
      AppLogger.d('알람 서비스 초기화 중...', tag: 'Notification');
      await initialize();
    }
    AppLogger.d('알람 서비스 초기화 완료', tag: 'Notification');

    try {
      // 기존 알람이 있으면 취소
      if (todo.notificationId != null) {
        AppLogger.d(
          '기존 알람 취소: notificationId=${todo.notificationId}',
          tag: 'Notification',
        );
        await cancelNotification(todo.notificationId!);
      }

      // 새로운 notification_id 생성 (Todo의 id를 사용하거나, 없으면 timestamp 사용)
      final int notificationId =
          todo.id ?? DateTime.now().millisecondsSinceEpoch % 100000;
      AppLogger.d('생성된 notificationId: $notificationId', tag: 'Notification');

      // 날짜와 시간 파싱
      AppLogger.d(
        '날짜/시간 파싱 시도: date=${todo.date}, time=${todo.time}',
        tag: 'Notification',
      );
      final dateTime = _parseDateTime(todo.date, todo.time!);
      if (dateTime == null) {
        AppLogger.e(
          '날짜/시간 파싱 실패: date=${todo.date}, time=${todo.time}',
          tag: 'Notification',
        );
        return null;
      }
      AppLogger.d('날짜/시간 파싱 성공: $dateTime', tag: 'Notification');

      // 과거 시간이면 알람 등록하지 않음
      final now = DateTime.now();
      AppLogger.d('현재 시간: $now', tag: 'Notification');
      if (dateTime.isBefore(now)) {
        AppLogger.w(
          '과거 시간은 알람 등록 불가: $dateTime (현재: $now)',
          tag: 'Notification',
        );
        return null;
      }

      // 최소 2분 이후만 알람 등록 가능
      final duration = dateTime.difference(now);
      if (duration.inMinutes < 2) {
        AppLogger.w(
          '알람 등록 불가: 최소 2분 이후만 가능 (남은 시간: ${duration.inSeconds}초)',
          tag: 'Notification',
        );
        return null;
      }
      AppLogger.d(
        '미래 시간 확인: $dateTime (${duration.inMinutes}분 ${duration.inSeconds % 60}초 후)',
        tag: 'Notification',
      );

      // TZDateTime 생성 (로컬 시간대 사용)
      AppLogger.d('TZDateTime 생성 시작...', tag: 'Notification');
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        dateTime.year,
        dateTime.month,
        dateTime.day,
        dateTime.hour,
        dateTime.minute,
      );
      AppLogger.d('TZDateTime 생성 완료: $scheduledDate', tag: 'Notification');
      AppLogger.d(
        '알람 스케줄링: DateTime=$dateTime, TZDateTime=$scheduledDate, 현재시간=${DateTime.now()}',
        tag: 'Notification',
      );

      // 알람 제목과 내용 설정
      AppLogger.d('알람 제목/내용 설정 중...', tag: 'Notification');
      final String title = todo.title;
      final String body = todo.memo != null && todo.memo!.isNotEmpty
          ? todo.memo!
          : '일정 시간입니다.';
      AppLogger.d('제목: $title, 내용: $body', tag: 'Notification');

      // Android 알람 상세 설정
      AppLogger.d('Android 알람 상세 설정 생성 중...', tag: 'Notification');
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          );

      // iOS 알람 상세 설정
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // 통합 알람 상세 설정
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      AppLogger.d('알람 상세 설정 완료', tag: 'Notification');

      // 알람 스케줄링
      AppLogger.d('알람 스케줄링 시작...', tag: 'Notification');

      // 시간 확인
      final scheduledLocal = scheduledDate.toLocal();
      final currentLocal = DateTime.now();

      AppLogger.d('현재 시간 (로컬): $currentLocal', tag: 'Notification');
      AppLogger.d('예정 시간 (로컬): $scheduledLocal', tag: 'Notification');
      AppLogger.d('TZDateTime: $scheduledDate', tag: 'Notification');
      AppLogger.d(
        '남은 시간: ${duration.inSeconds}초 (${duration.inMinutes}분 ${duration.inSeconds % 60}초)',
        tag: 'Notification',
      );

      if (duration.isNegative) {
        AppLogger.w('과거 시간입니다. 알람을 등록할 수 없습니다.', tag: 'Notification');
        return null;
      }

      // zonedSchedule 사용 (여러 모드 시도)
      try {
        AppLogger.d(
          'zonedSchedule (exactAllowWhileIdle) 시도...',
          tag: 'Notification',
        );
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: null, // 일회성 알람
        );
        AppLogger.s(
          '알람 등록 완료 (exactAllowWhileIdle): notificationId=$notificationId',
          tag: 'Notification',
        );
        AppLogger.i(
          '알람 예정 시간: ${scheduledLocal.year}-${scheduledLocal.month.toString().padLeft(2, '0')}-${scheduledLocal.day.toString().padLeft(2, '0')} ${scheduledLocal.hour.toString().padLeft(2, '0')}:${scheduledLocal.minute.toString().padLeft(2, '0')}',
          tag: 'Notification',
        );
        AppLogger.i(
          '남은 시간: ${duration.inMinutes}분 ${duration.inSeconds % 60}초 (${duration.inSeconds}초)',
          tag: 'Notification',
        );
        AppLogger.s('=== 알람 등록 성공 ===', tag: 'Notification');

        // 등록 확인
        await Future.delayed(const Duration(milliseconds: 500));
        await checkPendingNotifications();

        return notificationId;
      } catch (e) {
        AppLogger.w('exactAllowWhileIdle 실패', tag: 'Notification', error: e);
        AppLogger.d('exact 모드로 재시도...', tag: 'Notification');
        try {
          await _notifications.zonedSchedule(
            notificationId,
            title,
            body,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exact,
            matchDateTimeComponents: null, // 일회성 알람
          );
          AppLogger.s(
            '알람 등록 완료 (exact): notificationId=$notificationId',
            tag: 'Notification',
          );
          AppLogger.i(
            '알람 예정 시간: ${scheduledLocal.year}-${scheduledLocal.month.toString().padLeft(2, '0')}-${scheduledLocal.day.toString().padLeft(2, '0')} ${scheduledLocal.hour.toString().padLeft(2, '0')}:${scheduledLocal.minute.toString().padLeft(2, '0')}',
            tag: 'Notification',
          );
          AppLogger.i(
            '남은 시간: ${duration.inMinutes}분 ${duration.inSeconds % 60}초 (${duration.inSeconds}초)',
            tag: 'Notification',
          );
          AppLogger.s('=== 알람 등록 성공 (exact 모드) ===', tag: 'Notification');
          return notificationId;
        } catch (e2) {
          AppLogger.w('exact 실패', tag: 'Notification', error: e2);
          AppLogger.d('inexactAllowWhileIdle 모드로 재시도...', tag: 'Notification');
          try {
            await _notifications.zonedSchedule(
              notificationId,
              title,
              body,
              scheduledDate,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              matchDateTimeComponents: null, // 일회성 알람
            );
            AppLogger.s(
              '알람 등록 완료 (inexactAllowWhileIdle): notificationId=$notificationId',
              tag: 'Notification',
            );
            AppLogger.i(
              '알람 예정 시간: ${scheduledLocal.year}-${scheduledLocal.month.toString().padLeft(2, '0')}-${scheduledLocal.day.toString().padLeft(2, '0')} ${scheduledLocal.hour.toString().padLeft(2, '0')}:${scheduledLocal.minute.toString().padLeft(2, '0')}',
              tag: 'Notification',
            );
            AppLogger.i(
              '남은 시간: ${duration.inMinutes}분 ${duration.inSeconds % 60}초 (${duration.inSeconds}초)',
              tag: 'Notification',
            );
            AppLogger.s(
              '=== 알람 등록 성공 (inexactAllowWhileIdle 모드) ===',
              tag: 'Notification',
            );

            // 등록 확인
            await Future.delayed(const Duration(milliseconds: 500));
            await checkPendingNotifications();

            return notificationId;
          } catch (e3) {
            AppLogger.e(
              '모든 방법 실패',
              tag: 'Notification',
              error: e3,
              stackTrace: StackTrace.current,
            );
            rethrow;
          }
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        '알람 등록 오류',
        tag: 'Notification',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.e('=== 알람 등록 실패 ===', tag: 'Notification');
      return null;
    }
  }

  /// 알람 취소
  Future<void> cancelNotification(int notificationId) async {
    AppLogger.d('=== 알람 취소 시작 ===', tag: 'Notification');
    AppLogger.d('취소할 notificationId: $notificationId', tag: 'Notification');
    try {
      await _notifications.cancel(notificationId);
      AppLogger.s(
        '알람 취소 완료: notificationId=$notificationId',
        tag: 'Notification',
      );
      AppLogger.s('=== 알람 취소 성공 ===', tag: 'Notification');
    } catch (e) {
      AppLogger.e(
        '알람 취소 오류: notificationId=$notificationId',
        tag: 'Notification',
        error: e,
      );
      AppLogger.e('=== 알람 취소 실패 ===', tag: 'Notification');
    }
  }

  /// 알람 업데이트 (기존 알람 취소 후 새 알람 등록)
  Future<int?> updateNotification(Todo todo) async {
    // 기존 알람 취소
    if (todo.notificationId != null) {
      await cancelNotification(todo.notificationId!);
    }

    // 새 알람 등록
    return await scheduleNotification(todo);
  }

  /// 모든 알람 취소
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      AppLogger.s('모든 알람 취소 완료', tag: 'Notification');
    } catch (e) {
      AppLogger.e('모든 알람 취소 오류', tag: 'Notification', error: e);
    }
  }

  /// 등록된 알람 목록 확인 (디버깅용)
  Future<void> checkPendingNotifications() async {
    try {
      final pendingNotifications = await _notifications
          .pendingNotificationRequests();
      AppLogger.d('=== 등록된 알람 목록 ===', tag: 'Notification');
      AppLogger.i(
        '총 ${pendingNotifications.length}개의 알람이 등록되어 있습니다.',
        tag: 'Notification',
      );
      for (final notification in pendingNotifications) {
        AppLogger.d(
          '  - ID: ${notification.id}, 제목: ${notification.title}, 본문: ${notification.body}',
          tag: 'Notification',
        );
        if (notification.payload != null) {
          AppLogger.d(
            '    Payload: ${notification.payload}',
            tag: 'Notification',
          );
        }
      }
      if (pendingNotifications.isEmpty) {
        AppLogger.w('등록된 알람이 없습니다.', tag: 'Notification');
        AppLogger.w('알람이 등록되지 않았거나 이미 실행되었을 수 있습니다.', tag: 'Notification');
      }
    } catch (e) {
      AppLogger.e('알람 목록 확인 오류', tag: 'Notification', error: e);
    }
  }

  /// 날짜/시간 문자열을 DateTime으로 파싱 ('YYYY-MM-DD', 'HH:MM')
  DateTime? _parseDateTime(String date, String time) {
    try {
      final dateParts = date.split('-');
      final timeParts = time.split(':');

      if (dateParts.length != 3 || timeParts.length != 2) {
        return null;
      }

      return DateTime(
        int.parse(dateParts[0]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[2]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );
    } catch (e) {
      AppLogger.e('날짜/시간 파싱 오류', tag: 'Notification', error: e);
      return null;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.d(
      '알람 탭됨: id=${response.id}, payload=${response.payload}',
      tag: 'Notification',
    );
    // TODO: 알람 탭 시 상세 화면으로 이동하는 로직 추가 가능
  }

  /// 과거 알람 정리 (앱 시작/포그라운드 복귀 시 자동 호출)
  Future<void> cleanupExpiredNotifications({
    DatabaseHandler? databaseHandler,
  }) async {
    AppLogger.d('=== 과거 알람 정리 시작 ===', tag: 'Notification');
    try {
      final handler = databaseHandler ?? DatabaseHandler();
      final todos = await handler.queryData();

      AppLogger.d('전체 Todo 개수: ${todos.length}', tag: 'Notification');

      final now = DateTime.now();
      AppLogger.d(
        '현재 시간: ${now.toString().substring(0, 19)}',
        tag: 'Notification',
      );

      int cleanedCount = 0;
      int alarmCount = 0; // 알람이 있는 Todo 개수 (notificationId 유무 관계없이)
      int expiredCount = 0; // 과거 알람 개수

      for (final todo in todos) {
        // 알람이 있고 시간이 있는 경우 확인
        if (!todo.hasAlarm || todo.time == null) {
          continue;
        }

        alarmCount++; // 알람이 있는 Todo 카운트 (notificationId 유무 관계없이)

        // notificationId가 없는 경우도 정리 대상에 포함 (과거 알람이지만 등록 실패한 경우)
        if (todo.notificationId == null) {
          AppLogger.w(
            '알람이 있지만 notificationId가 없음: id=${todo.id}, 제목=${todo.title}, date=${todo.date}, time=${todo.time}',
            tag: 'Notification',
          );

          // 알람 시간 파싱
          final alarmDateTime = _parseDateTime(todo.date, todo.time!);
          if (alarmDateTime == null) {
            AppLogger.w(
              '알람 시간 파싱 실패: id=${todo.id}, date=${todo.date}, time=${todo.time}',
              tag: 'Notification',
            );
            continue;
          }

          // 과거 알람이면 notificationId만 제거 (이미 시스템 알람은 없음)
          if (alarmDateTime.isBefore(now)) {
            expiredCount++;
            AppLogger.w(
              '과거 알람 발견 (notificationId 없음): id=${todo.id}, 제목=${todo.title}, 알람 시간=${alarmDateTime.toString().substring(0, 19)}',
              tag: 'Notification',
            );

            // notificationId 제거 및 hasAlarm도 false로 변경 (과거 알람은 비활성화)
            final updatedTodo = todo.copyWith(
              clearNotificationId: true,
              hasAlarm: false,
            );
            await handler.updateData(updatedTodo);
            cleanedCount++;

            AppLogger.s(
              '과거 알람 정리 완료 (notificationId 없음): id=${todo.id}, 제목=${todo.title}, hasAlarm=false로 변경',
              tag: 'Notification',
            );
          }
          continue;
        }

        // 알람 시간 파싱
        final alarmDateTime = _parseDateTime(todo.date, todo.time!);
        if (alarmDateTime == null) {
          AppLogger.w(
            '알람 시간 파싱 실패: id=${todo.id}, date=${todo.date}, time=${todo.time}',
            tag: 'Notification',
          );
          continue;
        }

        // 날짜와 시간을 모두 비교 (오늘 날짜라도 시간이 지났으면 정리)
        final isExpired = alarmDateTime.isBefore(now);
        final difference = now.difference(alarmDateTime);

        AppLogger.d(
          '알람 확인: id=${todo.id}, 제목=${todo.title}',
          tag: 'Notification',
        );
        AppLogger.d(
          '  - 날짜/시간: ${todo.date} ${todo.time}',
          tag: 'Notification',
        );
        AppLogger.d(
          '  - 파싱된 알람 시간: ${alarmDateTime.toString().substring(0, 19)}',
          tag: 'Notification',
        );
        AppLogger.d(
          '  - 현재 시간: ${now.toString().substring(0, 19)}',
          tag: 'Notification',
        );
        AppLogger.d(
          '  - 시간 차이: ${difference.inDays}일 ${difference.inHours % 24}시간 ${difference.inMinutes % 60}분 (${difference.inMinutes}분)',
          tag: 'Notification',
        );
        AppLogger.d('  - 만료 여부: $isExpired', tag: 'Notification');

        // 알람 시간이 현재 시간보다 이전인 경우 정리 (같은 날짜라도 시간이 지났으면 정리)
        if (isExpired) {
          expiredCount++;
          AppLogger.w(
            '과거 알람 발견: id=${todo.id}, 제목=${todo.title}, 알람 시간=${alarmDateTime.toString().substring(0, 19)}, 현재 시간=${now.toString().substring(0, 19)}',
            tag: 'Notification',
          );

          // 시스템 알람 취소
          await cancelNotification(todo.notificationId!);

          // notificationId 제거 및 hasAlarm도 false로 변경 (과거 알람은 비활성화)
          final updatedTodo = todo.copyWith(
            clearNotificationId: true,
            hasAlarm: false,
          );
          await handler.updateData(updatedTodo);
          cleanedCount++;

          AppLogger.s(
            '과거 알람 정리 완료: id=${todo.id}, 제목=${todo.title}, hasAlarm=false로 변경',
            tag: 'Notification',
          );
        }
      }

      AppLogger.d('알람이 있는 Todo 개수: $alarmCount', tag: 'Notification');
      AppLogger.d('과거 알람 개수: $expiredCount', tag: 'Notification');

      if (cleanedCount > 0) {
        AppLogger.s(
          '과거 알람 정리 완료: 총 $cleanedCount개 알람 정리됨',
          tag: 'Notification',
        );
      } else {
        AppLogger.i('정리할 과거 알람이 없습니다.', tag: 'Notification');
      }
      AppLogger.d('=== 과거 알람 정리 종료 ===', tag: 'Notification');
    } catch (e, stackTrace) {
      AppLogger.e(
        '과거 알람 정리 오류',
        tag: 'Notification',
        error: e,
        stackTrace: stackTrace,
      );
      AppLogger.e('=== 과거 알람 정리 실패 ===', tag: 'Notification');
    }
  }

  // 권한 영구 거부 시 다이얼로그 표시
  //
  // 사용자에게 설정으로 이동해야 한다는 안내를 표시합니다.
  // 뒤로가기 버튼과 바깥 영역 탭으로는 닫히지 않습니다.
  // 반환값: 설정으로 이동할지 여부
  Future<bool> _showPermissionDeniedDialog(
    BuildContext context, {
    required bool isIOS,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 바깥 영역 탭으로 닫기 방지
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false, // 뒤로가기 버튼으로 닫기 방지
          child: AlertDialog(
            title: const Text('알림 권한 필요'),
            content: const Text(
              '알람 기능을 사용하려면 알림 권한이 필요합니다.\n'
              '설정에서 알림 권한을 허용해주세요.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('설정으로 이동'),
              ),
            ],
          ),
        );
      },
    );

    return result ?? false;
  }
}
