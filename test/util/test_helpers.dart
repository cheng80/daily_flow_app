import 'package:daily_flow_app/model/todo_model.dart';
import 'package:daily_flow_app/model/deleted_todo_model.dart';

/// 테스트용 더미 데이터 생성 헬퍼 함수들
class TestHelpers {
  /// 현재 시간을 'YYYY-MM-DD HH:MM:SS' 형식으로 반환
  static String getCurrentDateTime() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  /// 더미 Todo 객체 생성
  /// 
  /// [id] Todo ID (기본값: null)
  /// [title] 제목 (기본값: "테스트 일정")
  /// [date] 날짜 (기본값: "2024-01-15")
  /// [step] 시간대 분류 (기본값: 3)
  /// [priority] 중요도 (기본값: 3)
  static Todo createDummyTodo({
    int? id,
    String title = "테스트 일정",
    String? memo,
    String date = "2024-01-15",
    String? time,
    int step = 3,
    int priority = 3,
    bool isDone = false,
    bool hasAlarm = false,
    int? notificationId,
  }) {
    final now = getCurrentDateTime();
    return Todo(
      id: id,
      title: title,
      memo: memo,
      date: date,
      time: time,
      step: step,
      priority: priority,
      isDone: isDone,
      hasAlarm: hasAlarm,
      notificationId: notificationId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 더미 Todo Map 데이터 생성 (fromMap 테스트용)
  static Map<String, dynamic> createDummyTodoMap({
    int? id,
    String title = "테스트 일정",
    String? memo,
    String date = "2024-01-15",
    String? time,
    int step = 3,
    int priority = 3,
    int isDone = 0,
    int hasAlarm = 0,
    int? notificationId,
  }) {
    final now = getCurrentDateTime();
    return {
      if (id != null) 'id': id,
      'title': title,
      'memo': memo,
      'date': date,
      'time': time,
      'step': step,
      'priority': priority,
      'is_done': isDone,
      'has_alarm': hasAlarm,
      'notification_id': notificationId,
      'created_at': now,
      'updated_at': now,
    };
  }

  /// 더미 DeletedTodo 객체 생성
  /// 
  /// [id] DeletedTodo ID (기본값: null)
  /// [originalId] 원래 Todo ID (기본값: null)
  /// [title] 제목 (기본값: "삭제된 일정")
  /// [date] 날짜 (기본값: "2024-01-15")
  /// [step] 시간대 분류 (기본값: 3)
  /// [priority] 중요도 (기본값: 3)
  static DeletedTodo createDummyDeletedTodo({
    int? id,
    int? originalId,
    String title = "삭제된 일정",
    String? memo,
    String date = "2024-01-15",
    String? time,
    int step = 3,
    int priority = 3,
    bool isDone = false,
  }) {
    final now = getCurrentDateTime();
    return DeletedTodo(
      id: id,
      originalId: originalId,
      title: title,
      memo: memo,
      date: date,
      time: time,
      step: step,
      priority: priority,
      isDone: isDone,
      deletedAt: now,
    );
  }

  /// 더미 DeletedTodo Map 데이터 생성 (fromMap 테스트용)
  static Map<String, dynamic> createDummyDeletedTodoMap({
    int? id,
    int? originalId,
    String title = "삭제된 일정",
    String? memo,
    String date = "2024-01-15",
    String? time,
    int step = 3,
    int priority = 3,
    int isDone = 0,
  }) {
    final now = getCurrentDateTime();
    return {
      if (id != null) 'id': id,
      'original_id': originalId,
      'title': title,
      'memo': memo,
      'date': date,
      'time': time,
      'step': step,
      'priority': priority,
      'is_done': isDone,
      'deleted_at': now,
    };
  }

  /// 여러 개의 더미 Todo 리스트 생성
  /// 
  /// [count] 생성할 Todo 개수 (기본값: 5)
  /// [startDate] 시작 날짜 (기본값: "2024-01-15")
  static List<Todo> createDummyTodoList({
    int count = 5,
    String startDate = "2024-01-15",
  }) {
    final List<Todo> todos = [];
    final start = DateTime.parse(startDate);
    
    for (int i = 0; i < count; i++) {
      final date = start.add(Duration(days: i));
      final dateStr = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      
      todos.add(createDummyTodo(
        id: i + 1,
        title: "테스트 일정 ${i + 1}",
        date: dateStr,
        step: i % 4, // 0, 1, 2, 3 순환
        priority: (i % 5) + 1, // 1~5 순환
      ));
    }
    
    return todos;
  }

  /// 여러 개의 더미 DeletedTodo 리스트 생성
  /// 
  /// [count] 생성할 DeletedTodo 개수 (기본값: 3)
  static List<DeletedTodo> createDummyDeletedTodoList({int count = 3}) {
    final List<DeletedTodo> deletedTodos = [];
    
    for (int i = 0; i < count; i++) {
      deletedTodos.add(createDummyDeletedTodo(
        id: i + 1,
        originalId: i + 1,
        title: "삭제된 일정 ${i + 1}",
        step: i % 4,
        priority: (i % 5) + 1,
      ));
    }
    
    return deletedTodos;
  }
}

