import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:daily_flow_app/vm/database_handler.dart';
import 'package:daily_flow_app/model/todo_model.dart';
import 'package:daily_flow_app/model/deleted_todo_model.dart';
import '../util/test_helpers.dart';

void main() {
  // 테스트용 SQLite 초기화 (메모리 데이터베이스 사용)
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHandler Tests', () {
    late DatabaseHandler dbHandler;

    setUp(() async {
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    group('CRUD 동작 테스트', () {
      test('insertData - Todo 삽입', () async {
        // Given: 새 Todo 객체
        final todo = TestHelpers.createDummyTodo(
          title: "테스트 일정",
          date: "2024-01-15",
        );

        // When: 데이터베이스에 삽입
        final id = await dbHandler.insertData(todo);

        // Then: 삽입된 ID가 0보다 큰지 확인
        expect(id, greaterThan(0));
      });

      test('queryDataById - ID로 조회', () async {
        // Given: Todo 삽입
        final todo = TestHelpers.createDummyTodo(
          title: "조회 테스트",
          date: "2024-01-15",
        );
        final insertedId = await dbHandler.insertData(todo);

        // When: ID로 조회
        final retrieved = await dbHandler.queryDataById(insertedId);

        // Then: 조회된 데이터가 올바른지 확인
        expect(retrieved, isNotNull);
        expect(retrieved!.title, equals("조회 테스트"));
        expect(retrieved.date, equals("2024-01-15"));
      });

      test('queryDataById - 존재하지 않는 ID 조회', () async {
        // When: 존재하지 않는 ID로 조회
        final retrieved = await dbHandler.queryDataById(99999);

        // Then: null이 반환되는지 확인
        expect(retrieved, isNull);
      });

      test('updateData - Todo 수정', () async {
        // Given: Todo 삽입
        final todo = TestHelpers.createDummyTodo(
          title: "원본 제목",
          date: "2024-01-15",
          priority: 3,
        );
        final insertedId = await dbHandler.insertData(todo);

        // When: Todo 수정
        final updatedTodo = todo.copyWith(
          id: insertedId,
          title: "수정된 제목",
          priority: 5,
        );
        final result = await dbHandler.updateData(updatedTodo);

        // Then: 수정이 성공했는지 확인
        expect(result, equals(1));

        // 수정된 데이터 확인
        final retrieved = await dbHandler.queryDataById(insertedId);
        expect(retrieved!.title, equals("수정된 제목"));
        expect(retrieved.priority, equals(5));
      });

      test('updateData - updated_at 자동 갱신', () async {
        // Given: Todo 삽입
        final todo = TestHelpers.createDummyTodo(
          title: "시간 테스트",
          date: "2024-01-15",
        );
        final insertedId = await dbHandler.insertData(todo);
        final original = await dbHandler.queryDataById(insertedId);
        final originalUpdatedAt = original!.updatedAt;

        // 잠시 대기 (1초 대기로 충분한 시간 확보)
        await Future.delayed(Duration(seconds: 1));

        // When: Todo 수정
        final updatedTodo = todo.copyWith(
          id: insertedId,
          title: "수정됨",
        );
        await dbHandler.updateData(updatedTodo);

        // Then: updated_at이 갱신되었는지 확인
        final retrieved = await dbHandler.queryDataById(insertedId);
        expect(retrieved!.updatedAt, isNot(equals(originalUpdatedAt)));
        // 또는 시간이 더 최신인지 확인
        final originalTime = DateTime.parse(originalUpdatedAt.replaceAll(' ', 'T'));
        final updatedTime = DateTime.parse(retrieved.updatedAt.replaceAll(' ', 'T'));
        expect(updatedTime.isAfter(originalTime), isTrue);
      });

      test('toggleDone - 완료 상태 토글', () async {
        // Given: Todo 삽입 (미완료)
        final todo = TestHelpers.createDummyTodo(
          title: "완료 테스트",
          date: "2024-01-15",
          isDone: false,
        );
        final insertedId = await dbHandler.insertData(todo);

        // When: 완료 상태로 변경
        final result = await dbHandler.toggleDone(insertedId, true);

        // Then: 상태가 변경되었는지 확인
        expect(result, equals(1));
        final retrieved = await dbHandler.queryDataById(insertedId);
        expect(retrieved!.isDone, equals(true));

        // 다시 미완료로 변경
        await dbHandler.toggleDone(insertedId, false);
        final retrieved2 = await dbHandler.queryDataById(insertedId);
        expect(retrieved2!.isDone, equals(false));
      });
    });

    group('날짜/Step별 조회 테스트', () {
      setUp(() async {
        // 테스트 데이터 준비
        final todos = [
          TestHelpers.createDummyTodo(
            title: "2024-01-15 아침",
            date: "2024-01-15",
            time: "08:00",
            step: 0, // 아침
            priority: 3,
          ),
          TestHelpers.createDummyTodo(
            title: "2024-01-15 낮",
            date: "2024-01-15",
            time: "14:00",
            step: 1, // 낮
            priority: 4,
          ),
          TestHelpers.createDummyTodo(
            title: "2024-01-15 저녁",
            date: "2024-01-15",
            time: "20:00",
            step: 2, // 저녁
            priority: 5,
          ),
          TestHelpers.createDummyTodo(
            title: "2024-01-16 아침",
            date: "2024-01-16",
            time: "09:00",
            step: 0, // 아침
            priority: 2,
          ),
        ];

        for (final todo in todos) {
          await dbHandler.insertData(todo);
        }
      });

      test('queryDataByDate - 특정 날짜 조회', () async {
        // When: 특정 날짜로 조회
        final results = await dbHandler.queryDataByDate("2024-01-15");

        // Then: 해당 날짜의 Todo만 조회되었는지 확인
        expect(results.length, equals(3));
        expect(results.every((todo) => todo.date == "2024-01-15"), isTrue);
      });

      test('queryDataByDateAndStep - 특정 날짜와 Step 조회', () async {
        // When: 특정 날짜와 Step으로 조회
        final results = await dbHandler.queryDataByDateAndStep("2024-01-15", 0);

        // Then: 해당 날짜와 Step의 Todo만 조회되었는지 확인
        expect(results.length, equals(1));
        expect(results.first.date, equals("2024-01-15"));
        expect(results.first.step, equals(0));
        expect(results.first.title, equals("2024-01-15 아침"));
      });

      test('queryData - 전체 조회 및 정렬', () async {
        // When: 전체 조회
        final results = await dbHandler.queryData();

        // Then: 모든 데이터가 조회되고 날짜순으로 정렬되었는지 확인
        expect(results.length, equals(4));
        expect(results[0].date, lessThanOrEqualTo(results[1].date));
      });
    });

    group('소프트 삭제/복구 테스트', () {
      test('deleteData - 소프트 삭제 (todo → deleted_todo)', () async {
        // Given: Todo 삽입
        final todo = TestHelpers.createDummyTodo(
          title: "삭제할 일정",
          date: "2024-01-15",
        );
        final insertedId = await dbHandler.insertData(todo);
        final insertedTodo = await dbHandler.queryDataById(insertedId);

        // When: 소프트 삭제
        await dbHandler.deleteData(insertedTodo!);

        // Then: todo 테이블에서 삭제되었는지 확인
        final deletedFromTodo = await dbHandler.queryDataById(insertedId);
        expect(deletedFromTodo, isNull);

        // deleted_todo 테이블에 추가되었는지 확인
        final deletedTodos = await dbHandler.queryDeletedData();
        expect(deletedTodos.length, equals(1));
        expect(deletedTodos.first.title, equals("삭제할 일정"));
        expect(deletedTodos.first.originalId, equals(insertedId));
      });

      test('restoreData - 복구 (deleted_todo → todo)', () async {
        // Given: Todo 삽입 후 삭제
        final todo = TestHelpers.createDummyTodo(
          title: "복구할 일정",
          date: "2024-01-15",
        );
        final insertedId = await dbHandler.insertData(todo);
        final insertedTodo = await dbHandler.queryDataById(insertedId);
        await dbHandler.deleteData(insertedTodo!);

        // deleted_todo 조회
        final deletedTodos = await dbHandler.queryDeletedData();
        final deletedTodo = deletedTodos.first;

        // When: 복구
        await dbHandler.restoreData(deletedTodo);

        // Then: deleted_todo에서 삭제되었는지 확인
        final deletedTodosAfter = await dbHandler.queryDeletedData();
        expect(deletedTodosAfter.length, equals(0));

        // todo 테이블에 복구되었는지 확인
        final allTodos = await dbHandler.queryData();
        expect(allTodos.length, equals(1));
        expect(allTodos.first.title, equals("복구할 일정"));
        expect(allTodos.first.hasAlarm, equals(false)); // 복구 시 알람 비활성화
      });

      test('realDeleteData - 완전 삭제', () async {
        // Given: Todo 삽입 후 삭제
        final todo = TestHelpers.createDummyTodo(
          title: "완전 삭제할 일정",
          date: "2024-01-15",
        );
        final insertedId = await dbHandler.insertData(todo);
        final insertedTodo = await dbHandler.queryDataById(insertedId);
        await dbHandler.deleteData(insertedTodo!);

        // deleted_todo 조회
        final deletedTodos = await dbHandler.queryDeletedData();
        final deletedTodo = deletedTodos.first;

        // When: 완전 삭제 (다이얼로그 없이)
        await dbHandler.realDeleteData(
          deletedTodo,
          showConfirmDialog: false,
        );

        // Then: deleted_todo에서 완전히 삭제되었는지 확인
        final deletedTodosAfter = await dbHandler.queryDeletedData();
        expect(deletedTodosAfter.length, equals(0));
      });
    });

    group('DeletedTodo 조회 테스트', () {
      setUp(() async {
        // 테스트 데이터 준비 (삭제된 Todo들)
        final todos = [
          TestHelpers.createDummyTodo(
            title: "삭제된 일정 1",
            date: "2024-01-15",
          ),
          TestHelpers.createDummyTodo(
            title: "삭제된 일정 2",
            date: "2024-01-16",
          ),
        ];

        for (final todo in todos) {
          final id = await dbHandler.insertData(todo);
          final insertedTodo = await dbHandler.queryDataById(id);
          await dbHandler.deleteData(insertedTodo!);
        }
      });

      test('queryDeletedData - 전체 삭제된 Todo 조회', () async {
        // When: 전체 삭제된 Todo 조회
        final results = await dbHandler.queryDeletedData();

        // Then: 모든 삭제된 Todo가 조회되었는지 확인
        expect(results.length, equals(2));
        // 삭제 일시 내림차순 정렬 확인
        expect(
          results[0].deletedAt,
          greaterThanOrEqualTo(results[1].deletedAt),
        );
      });

      test('queryDeletedDataByDateRange - 날짜 범위 조회', () async {
        // Given: 테스트 데이터 준비 (삭제된 Todo들)
        final todos = [
          TestHelpers.createDummyTodo(
            title: "삭제된 일정 범위 테스트 1",
            date: "2024-01-15",
          ),
          TestHelpers.createDummyTodo(
            title: "삭제된 일정 범위 테스트 2",
            date: "2024-01-16",
          ),
        ];

        for (final todo in todos) {
          final id = await dbHandler.insertData(todo);
          final insertedTodo = await dbHandler.queryDataById(id);
          await dbHandler.deleteData(insertedTodo!);
        }

        // When: 날짜 범위로 조회 (현재 날짜 기준으로 넓은 범위)
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, now.day - 1);
        final endDate = DateTime(now.year, now.month, now.day + 1);
        final results = await dbHandler.queryDeletedDataByDateRange(
          startDate,
          endDate,
        );

        // Then: 해당 기간의 삭제된 Todo가 조회되었는지 확인
        expect(results.length, greaterThanOrEqualTo(2));
        // 삭제 일시 내림차순 정렬 확인
        if (results.length > 1) {
          expect(
            results[0].deletedAt,
            greaterThanOrEqualTo(results[1].deletedAt),
          );
        }
      });
    });
  });
}

