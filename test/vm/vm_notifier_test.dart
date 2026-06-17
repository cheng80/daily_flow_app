import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:daily_flow_app/vm/vm_notifier.dart';
import 'package:daily_flow_app/vm/database_handler.dart';
import '../util/test_helpers.dart';

void main() {
  // 테스트용 SQLite 초기화 (메모리 데이터베이스 사용)
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TodoNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - normal 타입일 때 활성 Todo 리스트 조회', () async {
      // Given: 테스트 데이터 삽입
      final todo1 = TestHelpers.createDummyTodo(
        title: "테스트 일정 1",
        date: "2024-01-15",
      );
      final todo2 = TestHelpers.createDummyTodo(
        title: "테스트 일정 2",
        date: "2024-01-16",
      );
      await dbHandler.insertData(todo1);
      await dbHandler.insertData(todo2);

      // When: normal 타입 Provider 조회
      final provider = todoNotifierProvider(TodoType.normal);
      final result = await container.read(provider.future);

      // Then: 활성 Todo 리스트가 조회되었는지 확인
      expect(result.length, equals(2));
      expect(result.any((t) => t.title == "테스트 일정 1"), isTrue);
      expect(result.any((t) => t.title == "테스트 일정 2"), isTrue);
    });

    test('build - deleted 타입일 때 빈 리스트 반환', () async {
      // When: deleted 타입 Provider 조회
      final provider = todoNotifierProvider(TodoType.deleted);
      final result = await container.read(provider.future);

      // Then: 빈 리스트가 반환되었는지 확인
      expect(result, isEmpty);
    });

    test('insertTodo - Todo 추가 후 자동 갱신', () async {
      // Given: Provider 초기화
      final provider = todoNotifierProvider(TodoType.normal);
      final notifier = container.read(provider.notifier);

      // When: Todo 추가
      final newTodo = TestHelpers.createDummyTodo(
        title: "새 일정",
        date: "2024-01-20",
      );
      await notifier.insertTodo(newTodo);

      // Then: Provider가 자동으로 갱신되었는지 확인
      final result = await container.read(provider.future);
      expect(result.length, greaterThan(0));
      expect(result.any((t) => t.title == "새 일정"), isTrue);
    });

    test('updateTodo - Todo 수정 후 자동 갱신', () async {
      // Given: 테스트 데이터 삽입
      final todo = TestHelpers.createDummyTodo(
        title: "원본 제목",
        date: "2024-01-15",
      );
      final id = await dbHandler.insertData(todo);
      final insertedTodo = await dbHandler.queryDataById(id);

      // Provider 초기화
      final provider = todoNotifierProvider(TodoType.normal);
      final notifier = container.read(provider.notifier);

      // When: Todo 수정
      final updatedTodo = insertedTodo!.copyWith(title: "수정된 제목");
      await notifier.updateTodo(updatedTodo);

      // Then: Provider가 자동으로 갱신되었는지 확인
      final result = await container.read(provider.future);
      expect(result.any((t) => t.title == "수정된 제목"), isTrue);
      expect(result.any((t) => t.title == "원본 제목"), isFalse);
    });

    test('toggleDone - 완료 상태 토글', () async {
      // Given: 테스트 데이터 삽입
      final todo = TestHelpers.createDummyTodo(
        title: "미완료 일정",
        date: "2024-01-15",
        isDone: false,
      );
      final id = await dbHandler.insertData(todo);

      // Provider 초기화
      final provider = todoNotifierProvider(TodoType.normal);
      final notifier = container.read(provider.notifier);

      // When: 완료 상태 토글
      await notifier.toggleDone(id, true);

      // Then: 완료 상태가 변경되었는지 확인
      final result = await container.read(provider.future);
      final updatedTodo = result.firstWhere((t) => t.id == id);
      expect(updatedTodo.isDone, isTrue);
    });

    test('deleteTodo - 소프트 삭제 후 Provider 갱신', () async {
      // Given: 테스트 데이터 삽입
      final todo = TestHelpers.createDummyTodo(
        title: "삭제될 일정",
        date: "2024-01-15",
      );
      final id = await dbHandler.insertData(todo);
      final insertedTodo = await dbHandler.queryDataById(id);

      // Provider 초기화
      final provider = todoNotifierProvider(TodoType.normal);
      final notifier = container.read(provider.notifier);

      // When: 소프트 삭제
      await notifier.deleteTodo(insertedTodo!);

      // Then: Provider가 갱신되어 삭제된 Todo가 없어졌는지 확인
      final result = await container.read(provider.future);
      expect(result.any((t) => t.id == id), isFalse);
    });
  });

  group('DeletedTodoNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - 삭제된 Todo 리스트 조회', () async {
      // Given: 테스트 데이터 삽입 및 삭제
      final todo = TestHelpers.createDummyTodo(
        title: "삭제될 일정",
        date: "2024-01-15",
      );
      final id = await dbHandler.insertData(todo);
      final insertedTodo = await dbHandler.queryDataById(id);
      await dbHandler.deleteData(insertedTodo!);

      // When: 삭제된 Todo Provider 조회
      final provider = deletedTodoNotifierProvider;
      final result = await container.read(provider.future);

      // Then: 삭제된 Todo 리스트가 조회되었는지 확인
      expect(result.length, greaterThan(0));
      expect(result.any((t) => t.title == "삭제될 일정"), isTrue);
    });

    test('restoreTodo - 삭제된 Todo 복구', () async {
      // Given: 테스트 데이터 삽입 및 삭제
      final todo = TestHelpers.createDummyTodo(
        title: "복구될 일정",
        date: "2024-01-15",
      );
      final id = await dbHandler.insertData(todo);
      final insertedTodo = await dbHandler.queryDataById(id);
      await dbHandler.deleteData(insertedTodo!);

      // 삭제된 Todo 조회
      final deletedTodos = await dbHandler.queryDeletedData();
      final deletedTodo = deletedTodos.first;

      // Provider 초기화
      final provider = deletedTodoNotifierProvider;
      final notifier = container.read(provider.notifier);

      // When: 복구
      await notifier.restoreTodo(deletedTodo);

      // Then: 삭제된 Todo 리스트에서 제거되었는지 확인
      final result = await container.read(provider.future);
      expect(result.any((t) => t.id == deletedTodo.id), isFalse);
    });

    test('permanentlyDeleteTodo - 완전 삭제', () async {
      // Given: 테스트 데이터 삽입 및 삭제
      final todo = TestHelpers.createDummyTodo(
        title: "완전 삭제될 일정",
        date: "2024-01-15",
      );
      final id = await dbHandler.insertData(todo);
      final insertedTodo = await dbHandler.queryDataById(id);
      await dbHandler.deleteData(insertedTodo!);

      // 삭제된 Todo 조회
      final deletedTodos = await dbHandler.queryDeletedData();
      final deletedTodo = deletedTodos.first;

      // Provider 초기화
      final provider = deletedTodoNotifierProvider;
      final notifier = container.read(provider.notifier);

      // When: 완전 삭제
      await notifier.permanentlyDeleteTodo(deletedTodo);

      // Then: 삭제된 Todo 리스트에서 제거되었는지 확인
      final result = await container.read(provider.future);
      expect(result.any((t) => t.id == deletedTodo.id), isFalse);
    });
  });

  group('TodoByDateNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - 특정 날짜의 Todo 조회', () async {
      // Given: 테스트 데이터 삽입
      final todo1 = TestHelpers.createDummyTodo(
        title: "2024-01-15 일정",
        date: "2024-01-15",
      );
      final todo2 = TestHelpers.createDummyTodo(
        title: "2024-01-16 일정",
        date: "2024-01-16",
      );
      await dbHandler.insertData(todo1);
      await dbHandler.insertData(todo2);

      // When: 특정 날짜 Provider 조회
      final provider = todoByDateProvider("2024-01-15");
      final result = await container.read(provider.future);

      // Then: 해당 날짜의 Todo만 조회되었는지 확인
      expect(result.length, equals(1));
      expect(result.first.title, equals("2024-01-15 일정"));
      expect(result.every((t) => t.date == "2024-01-15"), isTrue);
    });
  });

  group('TodoByDateAndStepNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - 특정 날짜와 Step의 Todo 조회', () async {
      // Given: 테스트 데이터 삽입
      final todo1 = TestHelpers.createDummyTodo(
        title: "2024-01-15 오전",
        date: "2024-01-15",
        step: 0, // 오전
      );
      final todo2 = TestHelpers.createDummyTodo(
        title: "2024-01-15 오후",
        date: "2024-01-15",
        step: 1, // 오후
      );
      await dbHandler.insertData(todo1);
      await dbHandler.insertData(todo2);

      // When: 특정 날짜와 Step Provider 조회
      final provider = todoByDateAndStepProvider((date: "2024-01-15", step: 0));
      final result = await container.read(provider.future);

      // Then: 해당 날짜와 Step의 Todo만 조회되었는지 확인
      expect(result.length, equals(1));
      expect(result.first.title, equals("2024-01-15 오전"));
      expect(result.first.step, equals(0));
    });
  });

  group('TodoByDateRangeNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - 날짜 범위의 Todo 조회', () async {
      // Given: 테스트 데이터 삽입
      final todo1 = TestHelpers.createDummyTodo(
        title: "2024-01-15 일정",
        date: "2024-01-15",
      );
      final todo2 = TestHelpers.createDummyTodo(
        title: "2024-01-16 일정",
        date: "2024-01-16",
      );
      final todo3 = TestHelpers.createDummyTodo(
        title: "2024-01-17 일정",
        date: "2024-01-17",
      );
      final todo4 = TestHelpers.createDummyTodo(
        title: "2024-01-20 일정",
        date: "2024-01-20",
      );
      await dbHandler.insertData(todo1);
      await dbHandler.insertData(todo2);
      await dbHandler.insertData(todo3);
      await dbHandler.insertData(todo4);

      // When: 날짜 범위 Provider 조회
      final provider = todoByDateRangeProvider(
        (startDate: "2024-01-15", endDate: "2024-01-17"),
      );
      final result = await container.read(provider.future);

      // Then: 범위 내의 Todo만 조회되었는지 확인
      expect(result.length, equals(3));
      expect(result.any((t) => t.date == "2024-01-15"), isTrue);
      expect(result.any((t) => t.date == "2024-01-16"), isTrue);
      expect(result.any((t) => t.date == "2024-01-17"), isTrue);
      expect(result.any((t) => t.date == "2024-01-20"), isFalse);
    });
  });

  group('CalendarEventsNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - 달력 이벤트 캐시 생성', () async {
      // Given: 2024년 1월 데이터 삽입
      final todo1 = TestHelpers.createDummyTodo(
        title: "1월 15일 일정",
        date: "2024-01-15",
      );
      final todo2 = TestHelpers.createDummyTodo(
        title: "1월 20일 일정",
        date: "2024-01-20",
      );
      final todo3 = TestHelpers.createDummyTodo(
        title: "2월 1일 일정",
        date: "2024-02-01",
      );
      await dbHandler.insertData(todo1);
      await dbHandler.insertData(todo2);
      await dbHandler.insertData(todo3);

      // When: 2024년 1월 달력 이벤트 Provider 조회
      final yearMonth = '2024-01'; // 'YYYY-MM' 형식
      final provider = calendarEventsProvider(yearMonth);
      final result = await container.read(provider.future);

      // Then: 1월의 모든 날짜에 대한 캐시가 생성되었는지 확인
      expect(result.containsKey("2024-01-15"), isTrue);
      expect(result.containsKey("2024-01-20"), isTrue);
      expect(result.containsKey("2024-02-01"), isFalse); // 2월 데이터는 포함되지 않음
      expect(result["2024-01-15"]!.length, equals(1));
      expect(result["2024-01-20"]!.length, equals(1));
    });
  });

  group('DateConstraintsNotifier Tests', () {
    late ProviderContainer container;
    late DatabaseHandler dbHandler;

    setUp(() async {
      container = ProviderContainer();
      dbHandler = DatabaseHandler();
      // 테스트 전 데이터베이스 초기화
      final db = await dbHandler.initializeDB();
      await dbHandler.allClearData();
      await dbHandler.allClearDeletedData();
      await db.close();
    });

    tearDown(() {
      container.dispose();
    });

    test('build - 날짜 제약 조건 조회 (최소/최대 날짜)', () async {
      // Given: 테스트 데이터 삽입
      final todo1 = TestHelpers.createDummyTodo(
        title: "2024-01-15 일정",
        date: "2024-01-15",
      );
      final todo2 = TestHelpers.createDummyTodo(
        title: "2024-01-20 일정",
        date: "2024-01-20",
      );
      final todo3 = TestHelpers.createDummyTodo(
        title: "2024-02-01 일정",
        date: "2024-02-01",
      );
      await dbHandler.insertData(todo1);
      await dbHandler.insertData(todo2);
      await dbHandler.insertData(todo3);

      // When: 날짜 제약 조건 Provider 조회
      final provider = dateConstraintsProvider;
      final result = await container.read(provider.future);

      // Then: 최소/최대 날짜가 올바르게 조회되었는지 확인
      expect(result.minDate, isNotNull);
      expect(result.maxDate, isNotNull);
      expect(result.minDate!.year, equals(2024));
      expect(result.minDate!.month, equals(1));
      expect(result.minDate!.day, equals(15));
      expect(result.maxDate!.year, equals(2024));
      expect(result.maxDate!.month, equals(2));
      expect(result.maxDate!.day, equals(1));
    });

    test('build - 데이터가 없을 때 null 반환', () async {
      // When: 데이터가 없는 상태에서 날짜 제약 조건 Provider 조회
      final provider = dateConstraintsProvider;
      final result = await container.read(provider.future);

      // Then: 최소/최대 날짜가 null인지 확인
      expect(result.minDate, isNull);
      expect(result.maxDate, isNull);
    });
  });
}
