import 'dart:async';
import 'package:path/path.dart';
import '../model/todo_model.dart';
import '../model/deleted_todo_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '../custom/custom_snack_bar.dart';
import '../custom/custom_dialog.dart';
import '../custom/custom_common_util.dart';

/// SQLite 데이터베이스 관리 클래스 (todo, deleted_todo 테이블)
class DatabaseHandler {
  /// DB 초기화 및 테이블 생성
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    print("Database Path : $path");

    return openDatabase(
      join(path, 'daily_flow.db'),
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE IF NOT EXISTS todo (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            title           TEXT    NOT NULL,
            memo            TEXT,
            date            TEXT    NOT NULL,
            time            TEXT,
            step            INTEGER NOT NULL DEFAULT 3,
            priority        INTEGER NOT NULL DEFAULT 3,
            is_done         INTEGER NOT NULL DEFAULT 0,
            has_alarm       INTEGER NOT NULL DEFAULT 0,
            notification_id INTEGER,
            created_at      TEXT    NOT NULL,
            updated_at      TEXT    NOT NULL
          );
          """);

        await db.execute("""
          CREATE TABLE IF NOT EXISTS deleted_todo (
            id           INTEGER PRIMARY KEY AUTOINCREMENT,
            original_id  INTEGER,
            title        TEXT    NOT NULL,
            memo         TEXT,
            date         TEXT    NOT NULL,
            time         TEXT,
            step         INTEGER NOT NULL DEFAULT 3,
            priority     INTEGER NOT NULL DEFAULT 3,
            is_done      INTEGER NOT NULL DEFAULT 0,
            deleted_at   TEXT    NOT NULL
          );
          """);

        await db.execute("""
          CREATE INDEX IF NOT EXISTS idx_todo_date 
          ON todo(date);
          """);

        await db.execute("""
          CREATE INDEX IF NOT EXISTS idx_todo_date_step 
          ON todo(date, step);
          """);

        await db.execute("""
          CREATE INDEX IF NOT EXISTS idx_deleted_todo_date 
          ON deleted_todo(date);
          """);
        await db.execute("""
          CREATE INDEX IF NOT EXISTS idx_deleted_todo_deleted_at 
          ON deleted_todo(deleted_at);
          """);
      },
      version: 1,
    );
  }

  // ============================================
  // Todo 테이블 관련 메서드
  // ============================================

  /// 모든 활성 일정 조회 (날짜↑, 시간↑, 중요도↓)
  Future<List<Todo>> queryData() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery("""
      SELECT * 
      FROM todo 
      ORDER BY date ASC, time ASC, priority DESC
      """);
    return queryResult.map((e) => Todo.fromMap(e)).toList();
  }

  /// 특정 날짜의 todo 조회
  Future<List<Todo>> queryDataByDate(String date) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      """
      SELECT * 
      FROM todo 
      WHERE date = ? 
      ORDER BY time ASC, priority DESC
      """,
      [date],
    );
    return queryResult.map((e) => Todo.fromMap(e)).toList();
  }

  /// 특정 날짜와 Step의 todo 조회
  Future<List<Todo>> queryDataByDateAndStep(String date, int step) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      """
      SELECT * 
      FROM todo 
      WHERE date = ? 
        AND step = ? 
      ORDER BY time ASC, priority DESC
      """,
      [date, step],
    );
    return queryResult.map((e) => Todo.fromMap(e)).toList();
  }

  /// ID로 단일 todo 조회
  Future<Todo?> queryDataById(int id) async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      """
      SELECT * 
      FROM todo 
      WHERE id = ?
      """,
      [id],
    );
    if (queryResult.isEmpty) return null;
    return Todo.fromMap(queryResult.first);
  }

  /// Todo 입력
  Future<int> insertData(Todo todo) async {
    int result = 0;
    final Database db = await initializeDB();

    final map = todo.toMap();
    map.remove('id'); // id는 AUTOINCREMENT이므로 제거

    result = await db.insert('todo', map);
    print("Insert return value : $result");
    return result;
  }

  /// Todo 수정 (updated_at 자동 갱신)
  Future<int> updateData(Todo todo) async {
    if (todo.id == null) {
      throw Exception('Todo id is null. Cannot update.');
    }

    int result = 0;
    final Database db = await initializeDB();

    // updated_at을 현재 시간으로 갱신
    final now = DateTime.now();
    final updatedAtStr = _formatDateTime(now);

    final updatedTodo = todo.copyWith(updatedAt: updatedAtStr);
    final map = updatedTodo.toMap();
    map.remove('id'); // id는 WHERE 절에서만 사용

    result = await db.update(
      'todo',
      map,
      where: 'id = ?',
      whereArgs: [todo.id],
    );
    return result;
  }

  /// Todo 완료 상태 토글 (updated_at 자동 갱신)
  Future<int> toggleDone(int id, bool isDone) async {
    final Database db = await initializeDB();
    final now = DateTime.now();
    final updatedAtStr = _formatDateTime(now);

    return await db.update(
      'todo',
      {'is_done': isDone ? 1 : 0, 'updated_at': updatedAtStr},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================
  // DeletedTodo 테이블 관련 메서드
  // ============================================

  /// 모든 삭제된 일정 조회 (삭제 일시↓)
  Future<List<DeletedTodo>> queryDeletedData() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.rawQuery("""
      SELECT * 
      FROM deleted_todo 
      ORDER BY deleted_at DESC
      """);
    return queryResult.map((e) => DeletedTodo.fromMap(e)).toList();
  }

  /// 특정 날짜 범위의 삭제된 todo 조회
  Future<List<DeletedTodo>> queryDeletedDataByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Database db = await initializeDB();
    final startStr =
        '${_formatDateTime(startDate, includeTime: false)} 00:00:00';
    final endStr = '${_formatDateTime(endDate, includeTime: false)} 23:59:59';

    final List<Map<String, Object?>> queryResult = await db.rawQuery(
      """
      SELECT * 
      FROM deleted_todo 
      WHERE deleted_at BETWEEN ? AND ? 
      ORDER BY deleted_at DESC
      """,
      [startStr, endStr],
    );
    return queryResult.map((e) => DeletedTodo.fromMap(e)).toList();
  }

  // ============================================
  // 소프트 삭제 / 복구 / 완전 삭제
  // ============================================

  /// 소프트 삭제 (todo → deleted_todo로 이동)
  Future<void> deleteData(Todo todo, {BuildContext? context}) async {
    print("Deleting todo id: ${todo.id}");
    final Database db = await initializeDB();

    try {
      final now = DateTime.now();
      final deletedAtStr = _formatDateTime(now);

      final deletedTodo = DeletedTodo(
        originalId: todo.id,
        title: todo.title,
        memo: todo.memo,
        date: todo.date,
        time: todo.time,
        step: todo.step,
        priority: todo.priority,
        isDone: todo.isDone,
        deletedAt: deletedAtStr,
      );

      final map = deletedTodo.toMap();
      map.remove('id'); // id는 AUTOINCREMENT

      int result = await db.insert('deleted_todo', map);
      print("Moved to deleted_todo, Insert return value : $result");

      if (result == 0) {
        // 이동 실패 시 삭제 취소
        final errorMsg = "일정을 삭제 보관함으로 이동하는데 실패했습니다.";
        print("Error: $errorMsg");
        if (context != null && context.mounted) {
          CustomSnackBar.showError(context, message: errorMsg);
        }
        throw Exception(errorMsg);
      } else {
        await db.delete('todo', where: 'id = ?', whereArgs: [todo.id]);
        print("Deleted from todo table.");

        if (context != null && context.mounted) {
          CustomSnackBar.showSuccess(context, message: "일정이 삭제되었습니다.");
        }
      }
    } catch (e) {
      print("Error deleting todo: $e");
      if (context != null && context.mounted) {
        CustomSnackBar.showError(
          context,
          message: "일정 삭제 중 오류가 발생했습니다: ${e.toString()}",
        );
      }
      rethrow;
    }
  }

  /// 복구 (deleted_todo → todo로 이동, 알람 비활성화)
  Future<void> restoreData(
    DeletedTodo deletedTodo, {
    BuildContext? context,
  }) async {
    print("Restoring deleted_todo id: ${deletedTodo.id}");
    final Database db = await initializeDB();

    try {
      // 1. deleted_todo에서 복구 대상 SELECT (이미 deletedTodo 객체로 받음)
      // 2. todo에 INSERT (새 id 부여)
      final now = DateTime.now();
      final createdAtStr = _formatDateTime(now);

      final todo = Todo(
        title: deletedTodo.title,
        memo: deletedTodo.memo,
        date: deletedTodo.date,
        time: deletedTodo.time,
        step: deletedTodo.step,
        priority: deletedTodo.priority,
        isDone: deletedTodo.isDone,
        hasAlarm: false, // 복구 시 알람은 비활성화
        notificationId: null,
        createdAt: createdAtStr,
        updatedAt: createdAtStr,
      );

      final map = todo.toMap();
      map.remove('id');

      int result = await db.insert('todo', map);
      print("Restored to todo, Insert return value : $result");

      if (result == 0) {
        final errorMsg = "일정을 복구하는데 실패했습니다.";
        print("Error: $errorMsg");
        if (context != null && context.mounted) {
          CustomSnackBar.showError(context, message: errorMsg);
        }
        throw Exception(errorMsg);
      } else {
        // 3. deleted_todo에서 해당 레코드 DELETE
        await db.delete(
          'deleted_todo',
          where: 'id = ?',
          whereArgs: [deletedTodo.id],
        );
        print("Deleted from deleted_todo table.");

        if (context != null && context.mounted) {
          CustomSnackBar.showSuccess(context, message: "일정이 복구되었습니다.");
        }
      }
    } catch (e) {
      print("Error restoring todo: $e");
      if (context != null && context.mounted) {
        CustomSnackBar.showError(
          context,
          message: "일정 복구 중 오류가 발생했습니다: ${e.toString()}",
        );
      }
      rethrow;
    }
  }

  // 완전 삭제 (deleted_todo 테이블에서 영구 삭제)
  //
  // 삭제 보관함의 일정을 완전히 삭제합니다.
  // 이 작업은 되돌릴 수 없으며, deleted_todo 테이블에서 해당 레코드를 영구적으로 삭제합니다.
  //
  // 삭제 플로우:
  // - deleted_todo에서 해당 레코드 DELETE
  //
  // 확인 다이얼로그가 표시되며, 사용자가 확인해야 삭제가 진행됩니다.
  //
  // [deletedTodo] 완전 삭제할 DeletedTodo 객체
  // [context] 확인 다이얼로그 및 메시지 표시를 위한 BuildContext (선택사항)
  // [showConfirmDialog] 확인 다이얼로그 표시 여부 (기본값: true)
  // 예외: 삭제 실패 시 Exception 발생
  Future<void> realDeleteData(
    DeletedTodo deletedTodo, {
    BuildContext? context,
    bool showConfirmDialog = true,
  }) async {
    print("Permanently deleting deleted_todo id: ${deletedTodo.id}");

    // 확인 다이얼로그 표시 (선택사항)
    if (showConfirmDialog && context != null && context.mounted) {
      final completer = Completer<bool>();

      await CustomDialog.show(
        context,
        title: "완전 삭제",
        message: "이 일정을 완전히 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
        type: DialogType.dual,
        confirmText: "삭제",
        cancelText: "취소",
        onConfirm: () {
          completer.complete(true);
        },
        onCancel: () {
          completer.complete(false);
        },
      );

      // 사용자의 선택을 기다림
      final shouldDelete = await completer.future;

      // 사용자가 취소한 경우
      if (!shouldDelete) {
        return;
      }
    }

    try {
      final Database db = await initializeDB();

      // deleted_todo에서 해당 레코드 DELETE
      await db.delete(
        'deleted_todo',
        where: 'id = ?',
        whereArgs: [deletedTodo.id],
      );
      print("Permanently deleted from deleted_todo table.");

      if (context != null && context.mounted) {
        CustomSnackBar.showSuccess(context, message: "일정이 완전히 삭제되었습니다.");
      }
    } catch (e) {
      print("Error permanently deleting todo: $e");
      if (context != null && context.mounted) {
        CustomSnackBar.showError(
          context,
          message: "일정 완전 삭제 중 오류가 발생했습니다: ${e.toString()}",
        );
      }
      rethrow;
    }
  }

  // ============================================
  // 유틸리티 메서드
  // ============================================

  /// todo 테이블 전체 삭제 (개발/테스트용)
  Future<void> allClearData() async {
    final Database db = await initializeDB();
    await db.delete('todo');
    print("All todo data cleared.");
  }

  /// deleted_todo 테이블 전체 삭제 (개발/테스트용)
  Future<void> allClearDeletedData() async {
    final Database db = await initializeDB();
    await db.delete('deleted_todo');
    print("All deleted_todo data cleared.");
  }

  // ============================================
  // Private 헬퍼 메서드
  // ============================================

  /// 날짜/시간을 'YYYY-MM-DD HH:MM:SS' 형식으로 포맷팅
  String _formatDateTime(DateTime dateTime, {bool includeTime = true}) {
    if (includeTime) {
      return CustomCommonUtil.formatDate(dateTime, 'yyyy-MM-dd HH:mm:ss');
    }
    return CustomCommonUtil.formatDate(dateTime, 'yyyy-MM-dd');
  }
}
