import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/todo_model.dart';
import '../model/deleted_todo_model.dart';
import 'database_handler.dart';

/// Todo 타입 enum
/// normal: 활성 일정
/// deleted: 삭제된 일정 (휴지통)
enum TodoType { normal, deleted }

/// Todo 리스트를 관리하는 AsyncNotifier
///
/// 참고 파일 패턴을 따라 작성되었으며, Todo와 DeletedTodo를 관리합니다.
/// CRUD 작업 후에는 관련된 Provider들을 갱신하여 정확한 싱크를 유지합니다.
class TodoNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final TodoType arg;

  TodoNotifier(this.arg);

  @override
  Future<List<Todo>> build() async {
    // Arg에 따라 초기 데이터 로드
    if (arg == TodoType.deleted) {
      // 삭제된 일정은 DeletedTodo 리스트를 반환하지 않음
      // (별도의 DeletedTodoNotifier 사용)
      return [];
    } else {
      // 활성 일정 조회
      return await _dbHandler.queryData();
    }
  }

  /// Todo 추가
  /// 반환값: 저장된 Todo의 ID
  Future<int> insertTodo(Todo todo) async {
    final id = await _dbHandler.insertData(todo);
    // 추가는 normal 리스트에 영향 -> normal 이라면 갱신
    if (arg == TodoType.normal) {
      ref.invalidateSelf();
    }
    // 날짜별 조회 Provider도 갱신 필요 (특정 날짜만)
    ref.invalidate(todoByDateProvider(todo.date));
    // 달력 이벤트 캐시도 갱신 필요 (특정 날짜의 달만)
    final yearMonth = todo.date.substring(0, 7); // 'YYYY-MM-DD' -> 'YYYY-MM'
    ref.invalidate(calendarEventsProvider(yearMonth));
    // 날짜 제약 조건도 갱신 필요
    ref.invalidate(dateConstraintsProvider);
    return id;
  }

  /// Todo 수정
  Future<void> updateTodo(Todo todo) async {
    await _dbHandler.updateData(todo);
    ref.invalidateSelf();
    // 날짜별 조회 Provider도 갱신 필요 (특정 날짜만)
    ref.invalidate(todoByDateProvider(todo.date));
    // 달력 이벤트 캐시도 갱신 필요 (특정 날짜의 달만)
    final yearMonth = todo.date.substring(0, 7); // 'YYYY-MM-DD' -> 'YYYY-MM'
    ref.invalidate(calendarEventsProvider(yearMonth));
  }

  /// Todo 완료 상태 토글
  Future<void> toggleDone(int id, bool isDone) async {
    // 먼저 Todo를 조회해서 날짜 정보를 얻어야 함
    final todos = await _dbHandler.queryData();
    final todo = todos.firstWhere((t) => t.id == id);
    
    await _dbHandler.toggleDone(id, isDone);
    ref.invalidateSelf();
    // 날짜별 조회 Provider도 갱신 필요 (특정 날짜만)
    ref.invalidate(todoByDateProvider(todo.date));
    // 달력 이벤트 캐시도 갱신 필요 (특정 날짜의 달만)
    final yearMonth = todo.date.substring(0, 7); // 'YYYY-MM-DD' -> 'YYYY-MM'
    ref.invalidate(calendarEventsProvider(yearMonth));
  }

  /// Todo 삭제 (소프트 삭제)
  Future<void> deleteTodo(Todo todo) async {
    await _dbHandler.deleteData(todo);
    // 삭제는 normal -> deleted 로 이동.
    // Provider간 의존성 때문에, 여기서는 전역적으로 invalidate 하는게 가장 깔끔함.
    ref.invalidate(todoNotifierProvider);
    // 날짜별 조회 Provider도 갱신 필요 (특정 날짜만)
    ref.invalidate(todoByDateProvider(todo.date));
    // 달력 이벤트 캐시도 갱신 필요 (특정 날짜의 달만)
    final yearMonth = todo.date.substring(0, 7); // 'YYYY-MM-DD' -> 'YYYY-MM'
    ref.invalidate(calendarEventsProvider(yearMonth));
    // 날짜 제약 조건도 갱신 필요
    ref.invalidate(dateConstraintsProvider);
  }

  /// ID로 Todo 조회
  Future<Todo?> queryTodoById(int id) async {
    return await _dbHandler.queryDataById(id);
  }

  /// Todo 테이블 전체 삭제 (개발/테스트용)
  Future<void> allClearData() async {
    await _dbHandler.allClearData();
    // 모든 관련 Provider 갱신
    ref.invalidateSelf();
    ref.invalidate(todoNotifierProvider);
    ref.invalidate(dateConstraintsProvider);
    // 모든 Family Provider도 갱신 (전역 invalidate)
    ref.invalidate(todoByDateProvider);
    ref.invalidate(todoByDateAndStepProvider);
    ref.invalidate(todoByDateRangeProvider);
    ref.invalidate(todoByDateRangeAndStepProvider);
    ref.invalidate(calendarEventsProvider);
  }

  /// 데이터 다시 로드
  void reloadData() {
    ref.invalidateSelf();
  }
}

/// Todo 리스트 Provider (Family)
final todoNotifierProvider =
    AsyncNotifierProvider.family<TodoNotifier, List<Todo>, TodoType>(
      TodoNotifier.new,
    );

/// 삭제된 Todo 리스트를 관리하는 AsyncNotifier
class DeletedTodoNotifier extends AsyncNotifier<List<DeletedTodo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  Future<List<DeletedTodo>> build() async {
    return await _dbHandler.queryDeletedData();
  }

  /// 삭제된 Todo 복구
  Future<void> restoreTodo(DeletedTodo deletedTodo) async {
    await _dbHandler.restoreData(deletedTodo);
    // 복구는 deleted -> normal 로 이동.
    ref.invalidate(todoNotifierProvider);
    ref.invalidateSelf();
    // 날짜별 조회 Provider도 갱신 필요 (특정 날짜만)
    ref.invalidate(todoByDateProvider(deletedTodo.date));
    // 달력 이벤트 캐시도 갱신 필요 (특정 날짜의 달만)
    final yearMonth = deletedTodo.date.substring(0, 7); // 'YYYY-MM-DD' -> 'YYYY-MM'
    ref.invalidate(calendarEventsProvider(yearMonth));
    // 날짜 제약 조건도 갱신 필요
    ref.invalidate(dateConstraintsProvider);
  }

  /// 삭제된 Todo 완전 삭제
  Future<void> permanentlyDeleteTodo(DeletedTodo deletedTodo) async {
    await _dbHandler.realDeleteData(deletedTodo, showConfirmDialog: false);
    ref.invalidateSelf();
  }

  /// DeletedTodo 테이블 전체 삭제 (개발/테스트용)
  Future<void> allClearDeletedData() async {
    await _dbHandler.allClearDeletedData();
    // 모든 관련 Provider 갱신
    ref.invalidateSelf();
    ref.invalidate(deletedTodoByDateRangeProvider);
  }

  /// 데이터 다시 로드
  void reloadData() {
    ref.invalidateSelf();
  }
}

/// 삭제된 Todo 리스트 Provider
final deletedTodoNotifierProvider =
    AsyncNotifierProvider<DeletedTodoNotifier, List<DeletedTodo>>(
      DeletedTodoNotifier.new,
    );

/// 날짜 범위로 삭제된 Todo 조회를 위한 Notifier (Family)
class DeletedTodoByDateRangeNotifier extends AsyncNotifier<List<DeletedTodo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final DateTime startDate;
  final DateTime endDate;

  DeletedTodoByDateRangeNotifier(this.startDate, this.endDate);

  @override
  Future<List<DeletedTodo>> build() async {
    return await _dbHandler.queryDeletedDataByDateRange(startDate, endDate);
  }
}

/// 날짜 범위로 삭제된 Todo 조회 Provider (Family)
/// 파라미터: ({DateTime startDate, DateTime endDate})
final deletedTodoByDateRangeProvider =
    AsyncNotifierProvider.family<DeletedTodoByDateRangeNotifier, List<DeletedTodo>, ({DateTime startDate, DateTime endDate})>(
      (params) => DeletedTodoByDateRangeNotifier(params.startDate, params.endDate),
    );

/// 특정 날짜의 Todo 조회를 위한 Notifier (Family)
class TodoByDateNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final String date; // 'YYYY-MM-DD' 형식

  TodoByDateNotifier(this.date);

  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryDataByDate(date);
  }
}

/// 특정 날짜의 Todo 조회 Provider (Family)
final todoByDateProvider =
    AsyncNotifierProvider.family<TodoByDateNotifier, List<Todo>, String>(
      TodoByDateNotifier.new,
    );

/// 특정 날짜와 Step의 Todo 조회를 위한 Notifier (Family)
class TodoByDateAndStepNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final String date; // 'YYYY-MM-DD' 형식
  final int step; // 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일

  TodoByDateAndStepNotifier(this.date, this.step);

  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryDataByDateAndStep(date, step);
  }
}

/// 특정 날짜와 Step의 Todo 조회 Provider (Family)
/// 파라미터: ({String date, int step})
final todoByDateAndStepProvider =
    AsyncNotifierProvider.family<TodoByDateAndStepNotifier, List<Todo>, ({String date, int step})>(
      (params) => TodoByDateAndStepNotifier(params.date, params.step),
    );

/// 날짜 범위의 Todo 조회를 위한 Notifier (Family)
class TodoByDateRangeNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final String startDate; // 'YYYY-MM-DD' 형식
  final String endDate; // 'YYYY-MM-DD' 형식

  TodoByDateRangeNotifier(this.startDate, this.endDate);

  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryDataByDateRange(startDate, endDate);
  }
}

/// 날짜 범위의 Todo 조회 Provider (Family)
/// 파라미터: ({String startDate, String endDate})
final todoByDateRangeProvider =
    AsyncNotifierProvider.family<TodoByDateRangeNotifier, List<Todo>, ({String startDate, String endDate})>(
      (params) => TodoByDateRangeNotifier(params.startDate, params.endDate),
    );

/// 날짜 범위와 Step의 Todo 조회를 위한 Notifier (Family)
class TodoByDateRangeAndStepNotifier extends AsyncNotifier<List<Todo>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final String startDate; // 'YYYY-MM-DD' 형식
  final String endDate; // 'YYYY-MM-DD' 형식
  final int step; // 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일

  TodoByDateRangeAndStepNotifier(this.startDate, this.endDate, this.step);

  @override
  Future<List<Todo>> build() async {
    return await _dbHandler.queryDataByDateRangeAndStep(startDate, endDate, step);
  }
}

/// 날짜 범위와 Step의 Todo 조회 Provider (Family)
/// 파라미터: ({String startDate, String endDate, int step})
final todoByDateRangeAndStepProvider =
    AsyncNotifierProvider.family<TodoByDateRangeAndStepNotifier, List<Todo>, ({String startDate, String endDate, int step})>(
      (params) => TodoByDateRangeAndStepNotifier(params.startDate, params.endDate, params.step),
    );

/// 달력 이벤트 캐시를 관리하는 Notifier (Family)
/// 월별 Todo 캐시를 관리합니다.
class CalendarEventsNotifier extends AsyncNotifier<Map<String, List<Todo>>> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final String yearMonth; // 'YYYY-MM' 형식

  CalendarEventsNotifier(this.yearMonth);

  @override
  Future<Map<String, List<Todo>>> build() async {
    try {
      // 'YYYY-MM' 형식에서 년/월 파싱
      final parts = yearMonth.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      
      // 현재 포커스된 달의 시작일과 종료일 계산
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      // 시작일과 종료일을 'YYYY-MM-DD' 형식으로 변환
      final startDateStr = _formatDate(firstDay);
      final endDateStr = _formatDate(lastDay);

      print('CalendarEventsNotifier: Loading events for $startDateStr to $endDateStr');

      // 한 번의 쿼리로 전체 달의 데이터를 조회 (최적화)
      final todos = await _dbHandler.queryDataByDateRange(startDateStr, endDateStr);
      
      print('CalendarEventsNotifier: Loaded ${todos.length} todos');

      // 날짜별로 그룹화하여 캐시 생성
      final cache = <String, List<Todo>>{};
      
      // 먼저 해당 달의 모든 날짜를 초기화 (데이터가 없는 날짜도 빈 리스트로 포함)
      for (
        var day = firstDay;
        day.isBefore(lastDay.add(const Duration(days: 1)));
        day = day.add(const Duration(days: 1))
      ) {
        final dateStr = _formatDate(day);
        cache[dateStr] = [];
      }

      // 조회된 Todo를 날짜별로 그룹화
      for (final todo in todos) {
        final dateStr = todo.date;
        if (cache.containsKey(dateStr)) {
          cache[dateStr]!.add(todo);
        }
      }

      // 각 날짜의 Todo를 시간순, 중요도순으로 정렬
      for (final dateStr in cache.keys) {
        cache[dateStr]!.sort((a, b) {
          // 시간순 정렬 (null은 맨 뒤로)
          if (a.time != null && b.time != null) {
            final timeCompare = a.time!.compareTo(b.time!);
            if (timeCompare != 0) return timeCompare;
          } else if (a.time != null) {
            return -1;
          } else if (b.time != null) {
            return 1;
          }
          // 시간이 같거나 둘 다 null이면 중요도 내림차순
          return b.priority.compareTo(a.priority);
        });
      }

      print('CalendarEventsNotifier: Cache created with ${cache.length} dates');
      return cache;
    } catch (e, stackTrace) {
      print('CalendarEventsNotifier: Error occurred - $e');
      print('CalendarEventsNotifier: Stack trace - $stackTrace');
      rethrow;
    }
  }

  /// 날짜를 'YYYY-MM-DD' 형식으로 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

/// 달력 이벤트 캐시 Provider (Family)
/// 파라미터: 'YYYY-MM' 형식의 문자열 (예: '2026-02')
final calendarEventsProvider =
    AsyncNotifierProvider.family<CalendarEventsNotifier, Map<String, List<Todo>>, String>(
      CalendarEventsNotifier.new,
    );

/// 날짜 제약 조건 (최소/최대 날짜)을 관리하는 Notifier
class DateConstraintsNotifier extends AsyncNotifier<({DateTime? minDate, DateTime? maxDate})> {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  Future<({DateTime? minDate, DateTime? maxDate})> build() async {
    final minDateStr = await _dbHandler.queryMinDate();
    final maxDateStr = await _dbHandler.queryMaxDate();

    DateTime? minDate;
    DateTime? maxDate;

    if (minDateStr != null) {
      final parts = minDateStr.split('-');
      minDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    if (maxDateStr != null) {
      final parts = maxDateStr.split('-');
      maxDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    return (minDate: minDate, maxDate: maxDate);
  }
}

/// 날짜 제약 조건 Provider
final dateConstraintsProvider =
    AsyncNotifierProvider<DateConstraintsNotifier, ({DateTime? minDate, DateTime? maxDate})>(
      DateConstraintsNotifier.new,
    );
