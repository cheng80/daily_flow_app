/// Todo 모델 클래스
/// 
/// 활성 일정을 나타내는 데이터 모델입니다.
/// 스펙 문서 daily_flow_db_spec.md의 todo 테이블 구조를 기반으로 합니다.
class Todo {
  /// 일정 고유 ID (PK, AUTOINCREMENT)
  /// null일 경우 새로 생성되는 일정을 의미합니다.
  final int? id;
  
  /// 일정 제목 (필수)
  /// NOT NULL 제약조건이 있습니다.
  final String title;
  
  /// 메모(상세 내용) (선택사항)
  /// NULL 허용입니다.
  final String? memo;
  
  /// 일정 날짜 (필수)
  /// 형식: 'YYYY-MM-DD' (예: '2024-01-15')
  /// NOT NULL 제약조건이 있습니다.
  final String date;
  
  /// 일정 시간 (선택사항)
  /// 형식: 'HH:MM' (예: '14:30')
  /// 알람을 사용하지 않는 일정의 경우 NULL 가능합니다.
  final String? time;
  
  /// 시간대 분류 (필수, 기본값: 3)
  /// 0: 아침, 1: 낮, 2: 저녁, 3: Anytime
  /// 드롭다운 선택 또는 시간 자동 매핑 결과를 저장합니다.
  final int step;
  
  /// 중요도 1~5단계 (필수, 기본값: 3)
  /// 1: 매우 낮음, 2: 낮음, 3: 보통, 4: 높음, 5: 매우 높음
  /// UI에서 색상 라벨과 매핑됩니다.
  final int priority;
  
  /// 완료 여부 (필수, 기본값: false)
  /// false(0): 미완료, true(1): 완료
  final bool isDone;
  
  /// 알람 활성 여부 (필수, 기본값: false)
  /// false(0): 알람 없음, true(1): 알람 있음
  /// has_alarm이 true이고 time이 존재할 때만 알람 스케줄링 대상입니다.
  final bool hasAlarm;
  
  /// flutter_local_notifications용 알림 ID (선택사항)
  /// 1일정당 최대 1개의 알람만 지원합니다.
  /// NULL 허용입니다.
  final int? notificationId;
  
  /// 생성 시각 (필수)
  /// 형식: 'YYYY-MM-DD HH:MM:SS' (예: '2024-01-15 14:30:00')
  final String createdAt;
  
  /// 마지막 수정 시각 (필수)
  /// 형식: 'YYYY-MM-DD HH:MM:SS' (예: '2024-01-15 14:30:00')
  final String updatedAt;
  
  /// Todo 생성자
  /// 
  /// [id] 일정 고유 ID (새 일정 생성 시 null)
  /// [title] 일정 제목 (필수)
  /// [memo] 메모 내용 (선택사항)
  /// [date] 일정 날짜 'YYYY-MM-DD' 형식 (필수)
  /// [time] 일정 시간 'HH:MM' 형식 (선택사항)
  /// [step] 시간대 분류 (0=아침, 1=낮, 2=저녁, 3=Anytime, 기본값: 3)
  /// [priority] 중요도 1~5단계 (기본값: 3)
  /// [isDone] 완료 여부 (기본값: false)
  /// [hasAlarm] 알람 활성 여부 (기본값: false)
  /// [notificationId] 알림 ID (선택사항)
  /// [createdAt] 생성 시각 'YYYY-MM-DD HH:MM:SS' 형식 (필수)
  /// [updatedAt] 수정 시각 'YYYY-MM-DD HH:MM:SS' 형식 (필수)
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
  
  /// SQLite Map → Todo 객체 변환 팩토리 생성자
  /// 
  /// 데이터베이스에서 조회한 Map 데이터를 Todo 객체로 변환합니다.
  /// 
  /// [map] SQLite에서 조회한 Map 데이터
  /// 반환값: Todo 객체
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
  
  /// Todo 객체 → SQLite Map 변환 메서드
  /// 
  /// Todo 객체를 데이터베이스에 저장하기 위한 Map 형태로 변환합니다.
  /// 
  /// 반환값: SQLite에 저장 가능한 Map 데이터
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
  
  /// Todo 객체 복사 생성자
  /// 
  /// 기존 Todo 객체를 기반으로 일부 필드만 변경한 새로운 Todo 객체를 생성합니다.
  /// 수정 작업 시 유용합니다.
  /// 
  /// [id] 일정 고유 ID
  /// [title] 일정 제목
  /// [memo] 메모 내용
  /// [date] 일정 날짜
  /// [time] 일정 시간
  /// [step] 시간대 분류
  /// [priority] 중요도
  /// [isDone] 완료 여부
  /// [hasAlarm] 알람 활성 여부
  /// [notificationId] 알림 ID
  /// [createdAt] 생성 시각
  /// [updatedAt] 수정 시각
  /// 반환값: 복사된 Todo 객체
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
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      time: time ?? this.time,
      step: step ?? this.step,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// 현재 시간을 기반으로 새 Todo 객체 생성 헬퍼 메서드
  /// 
  /// 새 일정 생성 시 created_at과 updated_at을 현재 시간으로 자동 설정합니다.
  /// 
  /// [title] 일정 제목 (필수)
  /// [memo] 메모 내용 (선택사항)
  /// [date] 일정 날짜 'YYYY-MM-DD' 형식 (필수)
  /// [time] 일정 시간 'HH:MM' 형식 (선택사항)
  /// [step] 시간대 분류 (기본값: 3)
  /// [priority] 중요도 (기본값: 3)
  /// [isDone] 완료 여부 (기본값: false)
  /// [hasAlarm] 알람 활성 여부 (기본값: false)
  /// 반환값: 현재 시간이 설정된 새 Todo 객체
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
    final dateTimeStr = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    
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
  
  /// 디버깅용 toString 메서드
  @override
  String toString() {
    return 'Todo(id: $id, title: $title, date: $date, time: $time, step: $step, priority: $priority, isDone: $isDone)';
  }
}

