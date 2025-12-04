import 'todo_model.dart';

/// DeletedTodo 모델 클래스
/// 
/// 삭제된 일정을 나타내는 데이터 모델입니다.
/// 스펙 문서 daily_flow_db_spec.md의 deleted_todo 테이블 구조를 기반으로 합니다.
/// 휴지통 기능에서 사용되며, 복구 또는 완전 삭제가 가능합니다.
class DeletedTodo {
  /// 휴지통 레코드 ID (PK, AUTOINCREMENT)
  /// null일 경우 새로 삭제 보관함에 추가되는 레코드를 의미합니다.
  final int? id;
  
  /// 원래 todo.id 값 (선택사항)
  /// 삭제되기 전 todo 테이블의 id를 추적하기 위한 필드입니다.
  /// NULL 허용입니다.
  final int? originalId;
  
  /// 일정 제목 (필수)
  /// 삭제 시점의 일정 제목을 보관합니다.
  final String title;
  
  /// 메모 내용 (선택사항)
  /// 삭제 시점의 메모 내용을 보관합니다.
  /// NULL 허용입니다.
  final String? memo;
  
  /// 일정 날짜 (필수)
  /// 형식: 'YYYY-MM-DD' (예: '2024-01-15')
  final String date;
  
  /// 일정 시간 (선택사항)
  /// 형식: 'HH:MM' (예: '14:30')
  /// NULL 허용입니다.
  final String? time;
  
  /// 시간대 분류 (필수, 기본값: 3)
  /// 0: 아침, 1: 낮, 2: 저녁, 3: Anytime
  /// 삭제 시점의 시간대 분류를 보관합니다.
  final int step;
  
  /// 중요도 1~5단계 (필수, 기본값: 3)
  /// 1: 매우 낮음, 2: 낮음, 3: 보통, 4: 높음, 5: 매우 높음
  /// 삭제 시점의 중요도를 보관합니다.
  final int priority;
  
  /// 삭제 시점의 완료 여부 (필수, 기본값: false)
  /// false(0): 미완료, true(1): 완료
  /// 삭제 당시의 완료 상태를 보관합니다.
  final bool isDone;
  
  /// 삭제 일시 (필수)
  /// 형식: 'YYYY-MM-DD HH:MM:SS' (예: '2024-01-15 14:30:00')
  /// 일정이 삭제된 정확한 시각을 기록합니다.
  final String deletedAt;
  
  /// DeletedTodo 생성자
  /// 
  /// [id] 휴지통 레코드 ID (새 삭제 레코드 생성 시 null)
  /// [originalId] 원래 todo.id 값 (선택사항)
  /// [title] 일정 제목 (필수)
  /// [memo] 메모 내용 (선택사항)
  /// [date] 일정 날짜 'YYYY-MM-DD' 형식 (필수)
  /// [time] 일정 시간 'HH:MM' 형식 (선택사항)
  /// [step] 시간대 분류 (기본값: 3)
  /// [priority] 중요도 (기본값: 3)
  /// [isDone] 삭제 시점의 완료 여부 (기본값: false)
  /// [deletedAt] 삭제 일시 'YYYY-MM-DD HH:MM:SS' 형식 (필수)
  DeletedTodo({
    this.id,
    this.originalId,
    required this.title,
    this.memo,
    required this.date,
    this.time,
    this.step = 3,
    this.priority = 3,
    this.isDone = false,
    required this.deletedAt,
  });
  
  /// SQLite Map → DeletedTodo 객체 변환 팩토리 생성자
  /// 
  /// 데이터베이스에서 조회한 Map 데이터를 DeletedTodo 객체로 변환합니다.
  /// 
  /// [map] SQLite에서 조회한 Map 데이터
  /// 반환값: DeletedTodo 객체
  factory DeletedTodo.fromMap(Map<String, dynamic> map) {
    return DeletedTodo(
      id: map['id'] as int?,
      originalId: map['original_id'] as int?,
      title: map['title'] as String,
      memo: map['memo'] as String?,
      date: map['date'] as String,
      time: map['time'] as String?,
      step: map['step'] as int? ?? 3,
      priority: map['priority'] as int? ?? 3,
      isDone: (map['is_done'] as int? ?? 0) == 1,
      deletedAt: map['deleted_at'] as String,
    );
  }
  
  /// DeletedTodo 객체 → SQLite Map 변환 메서드
  /// 
  /// DeletedTodo 객체를 데이터베이스에 저장하기 위한 Map 형태로 변환합니다.
  /// 
  /// 반환값: SQLite에 저장 가능한 Map 데이터
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'original_id': originalId,
      'title': title,
      'memo': memo,
      'date': date,
      'time': time,
      'step': step,
      'priority': priority,
      'is_done': isDone ? 1 : 0,
      'deleted_at': deletedAt,
    };
  }
  
  /// Todo → DeletedTodo 변환 팩토리 생성자
  /// 
  /// 활성 Todo 객체를 DeletedTodo로 변환합니다.
  /// 소프트 삭제 시 사용됩니다.
  /// 스펙 문서 2.3의 삭제 플로우에 따라 사용됩니다.
  /// 
  /// [todo] 삭제할 Todo 객체
  /// [originalId] 원래 todo.id 값 (기본값: todo.id)
  /// 반환값: 현재 시간이 deleted_at으로 설정된 DeletedTodo 객체
  factory DeletedTodo.fromTodo(Todo todo, {int? originalId}) {
    final now = DateTime.now();
    final deletedAtStr = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    
    return DeletedTodo(
      originalId: originalId ?? todo.id,
      title: todo.title,
      memo: todo.memo,
      date: todo.date,
      time: todo.time,
      step: todo.step,
      priority: todo.priority,
      isDone: todo.isDone,
      deletedAt: deletedAtStr,
    );
  }
  
  /// DeletedTodo 객체 복사 생성자
  /// 
  /// 기존 DeletedTodo 객체를 기반으로 일부 필드만 변경한 새로운 DeletedTodo 객체를 생성합니다.
  /// 
  /// [id] 휴지통 레코드 ID
  /// [originalId] 원래 todo.id 값
  /// [title] 일정 제목
  /// [memo] 메모 내용
  /// [date] 일정 날짜
  /// [time] 일정 시간
  /// [step] 시간대 분류
  /// [priority] 중요도
  /// [isDone] 삭제 시점의 완료 여부
  /// [deletedAt] 삭제 일시
  /// 반환값: 복사된 DeletedTodo 객체
  DeletedTodo copyWith({
    int? id,
    int? originalId,
    String? title,
    String? memo,
    String? date,
    String? time,
    int? step,
    int? priority,
    bool? isDone,
    String? deletedAt,
  }) {
    return DeletedTodo(
      id: id ?? this.id,
      originalId: originalId ?? this.originalId,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      date: date ?? this.date,
      time: time ?? this.time,
      step: step ?? this.step,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
  
  /// 디버깅용 toString 메서드
  @override
  String toString() {
    return 'DeletedTodo(id: $id, originalId: $originalId, title: $title, date: $date, deletedAt: $deletedAt)';
  }
}

