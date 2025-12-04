import 'package:flutter_test/flutter_test.dart';
import 'package:daily_flow_app/model/todo_model.dart';
import '../util/test_helpers.dart';

void main() {
  group('Todo Model Tests', () {
    test('Todo.fromMap - 모든 필드 포함', () {
      // Given: 모든 필드가 포함된 Map 데이터
      final map = TestHelpers.createDummyTodoMap(
        id: 1,
        title: "회의 일정",
        memo: "중요한 회의",
        date: "2024-01-15",
        time: "14:30",
        step: 1,
        priority: 4,
        isDone: 0,
        hasAlarm: 1,
        notificationId: 100,
      );

      // When: fromMap으로 변환
      final todo = Todo.fromMap(map);

      // Then: 모든 필드가 올바르게 변환되었는지 확인
      expect(todo.id, equals(1));
      expect(todo.title, equals("회의 일정"));
      expect(todo.memo, equals("중요한 회의"));
      expect(todo.date, equals("2024-01-15"));
      expect(todo.time, equals("14:30"));
      expect(todo.step, equals(1));
      expect(todo.priority, equals(4));
      expect(todo.isDone, equals(false));
      expect(todo.hasAlarm, equals(true));
      expect(todo.notificationId, equals(100));
    });

    test('Todo.fromMap - 선택 필드 null 처리', () {
      // Given: 선택 필드가 null인 Map 데이터
      final map = TestHelpers.createDummyTodoMap(
        id: 2,
        title: "간단한 일정",
        memo: null,
        date: "2024-01-16",
        time: null,
        step: 3,
        priority: 3,
        notificationId: null,
      );

      // When: fromMap으로 변환
      final todo = Todo.fromMap(map);

      // Then: null 필드가 올바르게 처리되었는지 확인
      expect(todo.id, equals(2));
      expect(todo.title, equals("간단한 일정"));
      expect(todo.memo, isNull);
      expect(todo.time, isNull);
      expect(todo.notificationId, isNull);
    });

    test('Todo.fromMap - 기본값 처리', () {
      // Given: 기본값 필드가 없는 Map 데이터
      final map = {
        'id': 3,
        'title': '기본값 테스트',
        'date': '2024-01-17',
        'created_at': TestHelpers.getCurrentDateTime(),
        'updated_at': TestHelpers.getCurrentDateTime(),
      };

      // When: fromMap으로 변환
      final todo = Todo.fromMap(map);

      // Then: 기본값이 올바르게 적용되었는지 확인
      expect(todo.step, equals(3)); // 기본값
      expect(todo.priority, equals(3)); // 기본값
      expect(todo.isDone, equals(false)); // 기본값 (0 → false)
      expect(todo.hasAlarm, equals(false)); // 기본값 (0 → false)
    });

    test('Todo.toMap - 모든 필드 포함', () {
      // Given: 모든 필드가 포함된 Todo 객체
      final todo = TestHelpers.createDummyTodo(
        id: 1,
        title: "회의 일정",
        memo: "중요한 회의",
        date: "2024-01-15",
        time: "14:30",
        step: 1,
        priority: 4,
        isDone: true,
        hasAlarm: true,
        notificationId: 100,
      );

      // When: toMap으로 변환
      final map = todo.toMap();

      // Then: 모든 필드가 올바르게 변환되었는지 확인
      expect(map['id'], equals(1));
      expect(map['title'], equals("회의 일정"));
      expect(map['memo'], equals("중요한 회의"));
      expect(map['date'], equals("2024-01-15"));
      expect(map['time'], equals("14:30"));
      expect(map['step'], equals(1));
      expect(map['priority'], equals(4));
      expect(map['is_done'], equals(1)); // bool → int 변환 확인
      expect(map['has_alarm'], equals(1)); // bool → int 변환 확인
      expect(map['notification_id'], equals(100));
    });

    test('Todo.toMap - null 필드 처리', () {
      // Given: null 필드가 있는 Todo 객체
      final todo = TestHelpers.createDummyTodo(
        id: 2,
        title: "간단한 일정",
        memo: null,
        time: null,
        notificationId: null,
      );

      // When: toMap으로 변환
      final map = todo.toMap();

      // Then: null 필드가 올바르게 처리되었는지 확인
      expect(map['memo'], isNull);
      expect(map['time'], isNull);
      expect(map['notification_id'], isNull);
    });

    test('Todo.toMap - 새 Todo (id 없음)', () {
      // Given: id가 없는 새 Todo 객체
      final todo = TestHelpers.createDummyTodo(
        id: null,
        title: "새 일정",
      );

      // When: toMap으로 변환
      final map = todo.toMap();

      // Then: id가 Map에 포함되지 않았는지 확인
      expect(map.containsKey('id'), isFalse);
    });

    test('Todo.fromMap/toMap - 순환 변환 테스트', () {
      // Given: 원본 Todo 객체
      final original = TestHelpers.createDummyTodo(
        id: 1,
        title: "순환 테스트",
        memo: "메모",
        date: "2024-01-15",
        time: "14:30",
        step: 2,
        priority: 5,
        isDone: true,
        hasAlarm: true,
        notificationId: 200,
      );

      // When: toMap → fromMap 순환 변환
      final map = original.toMap();
      final converted = Todo.fromMap(map);

      // Then: 원본과 변환된 객체가 동일한지 확인
      expect(converted.id, equals(original.id));
      expect(converted.title, equals(original.title));
      expect(converted.memo, equals(original.memo));
      expect(converted.date, equals(original.date));
      expect(converted.time, equals(original.time));
      expect(converted.step, equals(original.step));
      expect(converted.priority, equals(original.priority));
      expect(converted.isDone, equals(original.isDone));
      expect(converted.hasAlarm, equals(original.hasAlarm));
      expect(converted.notificationId, equals(original.notificationId));
    });

    test('Todo.copyWith - 일부 필드만 변경', () {
      // Given: 원본 Todo 객체
      final original = TestHelpers.createDummyTodo(
        id: 1,
        title: "원본 제목",
        date: "2024-01-15",
        step: 0,
        priority: 3,
        isDone: false,
      );

      // When: copyWith로 일부 필드만 변경
      final copied = original.copyWith(
        title: "변경된 제목",
        priority: 5,
        isDone: true,
      );

      // Then: 변경된 필드와 변경되지 않은 필드 확인
      expect(copied.id, equals(original.id));
      expect(copied.title, equals("변경된 제목")); // 변경됨
      expect(copied.date, equals(original.date)); // 변경 안됨
      expect(copied.step, equals(original.step)); // 변경 안됨
      expect(copied.priority, equals(5)); // 변경됨
      expect(copied.isDone, equals(true)); // 변경됨
    });

    test('Todo.copyWith - 모든 필드 변경', () {
      // Given: 원본 Todo 객체
      final original = TestHelpers.createDummyTodo(
        id: 1,
        title: "원본",
        date: "2024-01-15",
      );

      // When: copyWith로 모든 필드 변경
      final newDateTime = TestHelpers.getCurrentDateTime();
      final copied = original.copyWith(
        id: 2,
        title: "새 제목",
        memo: "새 메모",
        date: "2024-01-20",
        time: "10:00",
        step: 1,
        priority: 4,
        isDone: true,
        hasAlarm: true,
        notificationId: 300,
        createdAt: newDateTime,
        updatedAt: newDateTime,
      );

      // Then: 모든 필드가 변경되었는지 확인
      expect(copied.id, equals(2));
      expect(copied.title, equals("새 제목"));
      expect(copied.memo, equals("새 메모"));
      expect(copied.date, equals("2024-01-20"));
      expect(copied.time, equals("10:00"));
      expect(copied.step, equals(1));
      expect(copied.priority, equals(4));
      expect(copied.isDone, equals(true));
      expect(copied.hasAlarm, equals(true));
      expect(copied.notificationId, equals(300));
    });

    test('Todo.copyWith - null 필드 처리', () {
      // Given: memo와 time이 null인 Todo 객체
      final original = TestHelpers.createDummyTodo(
        id: 1,
        memo: null,
        time: null,
      );

      // When: copyWith로 null로 변경 시도
      final copied = original.copyWith(
        memo: null,
        time: null,
      );

      // Then: null이 유지되는지 확인
      expect(copied.memo, isNull);
      expect(copied.time, isNull);
    });

    test('Todo.createNew - 새 Todo 생성', () {
      // When: createNew로 새 Todo 생성
      final todo = Todo.createNew(
        title: "새 일정",
        memo: "메모",
        date: "2024-01-15",
        time: "14:30",
        step: 1,
        priority: 4,
      );

      // Then: id가 null이고 createdAt과 updatedAt이 설정되었는지 확인
      expect(todo.id, isNull);
      expect(todo.title, equals("새 일정"));
      expect(todo.createdAt, isNotEmpty);
      expect(todo.updatedAt, isNotEmpty);
      expect(todo.createdAt, equals(todo.updatedAt));
    });
  });
}

