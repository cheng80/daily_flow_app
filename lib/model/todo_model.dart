import '../custom/custom_common_util.dart';

/// 활성 일정 데이터 모델
///
/// step: 0=아침, 1=낮, 2=저녁, 3=야간, 4=종일
/// priority: 1~5단계 (1=매우낮음, 5=매우높음)
class Todo {
  final int? id; // 일정 고유 ID
  final String title; // 일정 제목
  final String? memo; // 메모
  final String date; // 'YYYY-MM-DD'
  final String? time; // 'HH:MM'
  final int step; // 0=아침, 1=낮, 2=저녁, 3=야간, 4=종일
  final int priority; // 1~5
  final bool isDone; // 완료 여부
  final bool hasAlarm; // 알람 설정 여부
  final int? notificationId; // 알람 알림 ID
  final String createdAt; // 'YYYY-MM-DD HH:MM:SS'
  final String updatedAt; // 'YYYY-MM-DD HH:MM:SS'

  Todo({
    this.id,
    required this.title,
    this.memo,
    required this.date,
    this.time,
    this.step = 3,
    this.priority = 3,
    this.isDone = false,
    this.hasAlarm = false,
    this.notificationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      memo: map['memo'] as String?,
      date: map['date'] as String,
      time: map['time'] as String?,
      step: map['step'] as int? ?? 3,
      priority: map['priority'] as int? ?? 3,
      isDone: (map['is_done'] as int? ?? 0) == 1,
      hasAlarm: (map['has_alarm'] as int? ?? 0) == 1,
      notificationId: map['notification_id'] as int?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Todo 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'memo': memo,
      'date': date,
      'time': time,
      'step': step,
      'priority': priority,
      'is_done': isDone ? 1 : 0,
      'has_alarm': hasAlarm ? 1 : 0,
      'notification_id': notificationId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 일부 필드만 변경한 새 Todo 객체 생성
  ///
  /// clearMemo, clearTime, clearNotificationId: true 시 해당 필드를 null로 설정
  Todo copyWith({
    int? id,
    String? title,
    String? memo,
    String? date,
    String? time,
    int? step,
    int? priority,
    bool? isDone,
    bool? hasAlarm,
    int? notificationId,
    String? createdAt,
    String? updatedAt,
    bool clearMemo = false,
    bool clearTime = false,
    bool clearNotificationId = false,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: clearMemo ? null : (memo ?? this.memo),
      date: date ?? this.date,
      time: clearTime ? null : (time ?? this.time),
      step: step ?? this.step,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      notificationId: clearNotificationId
          ? null
          : (notificationId ?? this.notificationId),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// created_at과 updated_at을 현재 시간으로 자동 설정하여 새 Todo 생성
  factory Todo.createNew({
    required String title,
    String? memo,
    required String date,
    String? time,
    int step = 3,
    int priority = 3,
    bool isDone = false,
    bool hasAlarm = false,
  }) {
    final now = DateTime.now();
    final dateTimeStr = CustomCommonUtil.formatDate(now, 'yyyy-MM-dd HH:mm:ss');

    return Todo(
      title: title,
      memo: memo,
      date: date,
      time: time,
      step: step,
      priority: priority,
      isDone: isDone,
      hasAlarm: hasAlarm,
      createdAt: dateTimeStr,
      updatedAt: dateTimeStr,
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, date: $date, time: $time, step: $step, priority: $priority, isDone: $isDone)';
  }
}
