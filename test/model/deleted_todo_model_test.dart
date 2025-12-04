import 'package:flutter_test/flutter_test.dart';
import 'package:daily_flow_app/model/deleted_todo_model.dart';
import 'package:daily_flow_app/model/todo_model.dart';
import '../util/test_helpers.dart';

void main() {
  group('DeletedTodo Model Tests', () {
    test('DeletedTodo.fromMap - 모든 필드 포함', () {
      // Given: 모든 필드가 포함된 Map 데이터
      final map = TestHelpers.createDummyDeletedTodoMap(
        id: 1,
        originalId: 100,
        title: "삭제된 일정",
        memo: "메모",
        date: "2024-01-15",
        time: "14:30",
        step: 1,
        priority: 4,
        isDone: 1,
      );

      // When: fromMap으로 변환
      final deletedTodo = DeletedTodo.fromMap(map);

      // Then: 모든 필드가 올바르게 변환되었는지 확인
      expect(deletedTodo.id, equals(1));
      expect(deletedTodo.originalId, equals(100));
      expect(deletedTodo.title, equals("삭제된 일정"));
      expect(deletedTodo.memo, equals("메모"));
      expect(deletedTodo.date, equals("2024-01-15"));
      expect(deletedTodo.time, equals("14:30"));
      expect(deletedTodo.step, equals(1));
      expect(deletedTodo.priority, equals(4));
      expect(deletedTodo.isDone, equals(true));
    });

    test('DeletedTodo.fromMap - 선택 필드 null 처리', () {
      // Given: 선택 필드가 null인 Map 데이터
      final map = TestHelpers.createDummyDeletedTodoMap(
        id: 2,
        originalId: null,
        title: "삭제된 일정",
        memo: null,
        time: null,
      );

      // When: fromMap으로 변환
      final deletedTodo = DeletedTodo.fromMap(map);

      // Then: null 필드가 올바르게 처리되었는지 확인
      expect(deletedTodo.originalId, isNull);
      expect(deletedTodo.memo, isNull);
      expect(deletedTodo.time, isNull);
    });

    test('DeletedTodo.fromMap - 기본값 처리', () {
      // Given: 기본값 필드가 없는 Map 데이터
      final map = {
        'id': 3,
        'title': '기본값 테스트',
        'date': '2024-01-17',
        'deleted_at': TestHelpers.getCurrentDateTime(),
      };

      // When: fromMap으로 변환
      final deletedTodo = DeletedTodo.fromMap(map);

      // Then: 기본값이 올바르게 적용되었는지 확인
      expect(deletedTodo.step, equals(3)); // 기본값
      expect(deletedTodo.priority, equals(3)); // 기본값
      expect(deletedTodo.isDone, equals(false)); // 기본값 (0 → false)
    });

    test('DeletedTodo.toMap - 모든 필드 포함', () {
      // Given: 모든 필드가 포함된 DeletedTodo 객체
      final deletedTodo = TestHelpers.createDummyDeletedTodo(
        id: 1,
        originalId: 100,
        title: "삭제된 일정",
        memo: "메모",
        date: "2024-01-15",
        time: "14:30",
        step: 1,
        priority: 4,
        isDone: true,
      );

      // When: toMap으로 변환
      final map = deletedTodo.toMap();

      // Then: 모든 필드가 올바르게 변환되었는지 확인
      expect(map['id'], equals(1));
      expect(map['original_id'], equals(100));
      expect(map['title'], equals("삭제된 일정"));
      expect(map['memo'], equals("메모"));
      expect(map['date'], equals("2024-01-15"));
      expect(map['time'], equals("14:30"));
      expect(map['step'], equals(1));
      expect(map['priority'], equals(4));
      expect(map['is_done'], equals(1)); // bool → int 변환 확인
    });

    test('DeletedTodo.toMap - null 필드 처리', () {
      // Given: null 필드가 있는 DeletedTodo 객체
      final deletedTodo = TestHelpers.createDummyDeletedTodo(
        id: 2,
        originalId: null,
        memo: null,
        time: null,
      );

      // When: toMap으로 변환
      final map = deletedTodo.toMap();

      // Then: null 필드가 올바르게 처리되었는지 확인
      expect(map['original_id'], isNull);
      expect(map['memo'], isNull);
      expect(map['time'], isNull);
    });

    test('DeletedTodo.toMap - 새 DeletedTodo (id 없음)', () {
      // Given: id가 없는 새 DeletedTodo 객체
      final deletedTodo = TestHelpers.createDummyDeletedTodo(
        id: null,
        title: "새 삭제 일정",
      );

      // When: toMap으로 변환
      final map = deletedTodo.toMap();

      // Then: id가 Map에 포함되지 않았는지 확인
      expect(map.containsKey('id'), isFalse);
    });

    test('DeletedTodo.fromMap/toMap - 순환 변환 테스트', () {
      // Given: 원본 DeletedTodo 객체
      final original = TestHelpers.createDummyDeletedTodo(
        id: 1,
        originalId: 100,
        title: "순환 테스트",
        memo: "메모",
        date: "2024-01-15",
        time: "14:30",
        step: 2,
        priority: 5,
        isDone: true,
      );

      // When: toMap → fromMap 순환 변환
      final map = original.toMap();
      final converted = DeletedTodo.fromMap(map);

      // Then: 원본과 변환된 객체가 동일한지 확인
      expect(converted.id, equals(original.id));
      expect(converted.originalId, equals(original.originalId));
      expect(converted.title, equals(original.title));
      expect(converted.memo, equals(original.memo));
      expect(converted.date, equals(original.date));
      expect(converted.time, equals(original.time));
      expect(converted.step, equals(original.step));
      expect(converted.priority, equals(original.priority));
      expect(converted.isDone, equals(original.isDone));
    });

    test('DeletedTodo.copyWith - 일부 필드만 변경', () {
      // Given: 원본 DeletedTodo 객체
      final original = TestHelpers.createDummyDeletedTodo(
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

    test('DeletedTodo.copyWith - 모든 필드 변경', () {
      // Given: 원본 DeletedTodo 객체
      final original = TestHelpers.createDummyDeletedTodo(
        id: 1,
        title: "원본",
        date: "2024-01-15",
      );

      // When: copyWith로 모든 필드 변경
      final newDateTime = TestHelpers.getCurrentDateTime();
      final copied = original.copyWith(
        id: 2,
        originalId: 200,
        title: "새 제목",
        memo: "새 메모",
        date: "2024-01-20",
        time: "10:00",
        step: 1,
        priority: 4,
        isDone: true,
        deletedAt: newDateTime,
      );

      // Then: 모든 필드가 변경되었는지 확인
      expect(copied.id, equals(2));
      expect(copied.originalId, equals(200));
      expect(copied.title, equals("새 제목"));
      expect(copied.memo, equals("새 메모"));
      expect(copied.date, equals("2024-01-20"));
      expect(copied.time, equals("10:00"));
      expect(copied.step, equals(1));
      expect(copied.priority, equals(4));
      expect(copied.isDone, equals(true));
    });

    test('DeletedTodo.fromTodo - Todo에서 DeletedTodo 변환', () {
      // Given: Todo 객체
      final todo = TestHelpers.createDummyTodo(
        id: 100,
        title: "변환할 일정",
        memo: "메모",
        date: "2024-01-15",
        time: "14:30",
        step: 1,
        priority: 4,
        isDone: true,
      );

      // When: fromTodo로 변환
      final deletedTodo = DeletedTodo.fromTodo(todo);

      // Then: Todo의 모든 필드가 올바르게 변환되었는지 확인
      expect(deletedTodo.originalId, equals(100));
      expect(deletedTodo.title, equals(todo.title));
      expect(deletedTodo.memo, equals(todo.memo));
      expect(deletedTodo.date, equals(todo.date));
      expect(deletedTodo.time, equals(todo.time));
      expect(deletedTodo.step, equals(todo.step));
      expect(deletedTodo.priority, equals(todo.priority));
      expect(deletedTodo.isDone, equals(todo.isDone));
      expect(deletedTodo.deletedAt, isNotEmpty);
      expect(deletedTodo.id, isNull); // 새로 생성되므로 id는 null
    });

    test('DeletedTodo.fromTodo - originalId 지정', () {
      // Given: Todo 객체
      final todo = TestHelpers.createDummyTodo(id: 100, title: "변환할 일정");

      // When: originalId를 지정하여 변환
      final deletedTodo = DeletedTodo.fromTodo(todo, originalId: 999);

      // Then: 지정한 originalId가 사용되었는지 확인
      expect(deletedTodo.originalId, equals(999));
    });
  });
}
