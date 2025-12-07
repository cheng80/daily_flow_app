import 'todo_model.dart';

/// 삭제된 일정 데이터 모델 (휴지통)
class DeletedTodo {
  final int? id; // 휴지통 레코드 ID
  final int? originalId; // 원래 todo ID
  final String title; // 일정 제목
  final String? memo; // 메모
  final String date; // 'YYYY-MM-DD'
  final String? time; // 'HH:MM'
  final int step; // 시간대 (0=아침, 1=낮, 2=저녁, 3=야간, 4=종일)
  final int priority; // 중요도 (1~5)
  final bool isDone; // 완료 여부
  final String deletedAt; // 'YYYY-MM-DD HH:MM:SS'

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

  /// Todo를 DeletedTodo로 변환 (소프트 삭제용)
  ///
  /// original_id에 todo.id 저장, deleted_at에 현재 시간 설정
  factory DeletedTodo.fromTodo(Todo todo, {int? originalId}) {
    final now = DateTime.now();
    final deletedAtStr =
        '${now.year.toString().padLeft(4, '0')}-'
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

  @override
  String toString() {
    return 'DeletedTodo(id: $id, originalId: $originalId, title: $title, date: $date, deletedAt: $deletedAt)';
  }
}
