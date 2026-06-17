# DatabaseHandler API 참조 문서

## 개요
`DatabaseHandler` 클래스는 DailyFlow 앱의 SQLite 데이터베이스 관리 클래스입니다.
todo와 deleted_todo 테이블을 관리하며, 소프트 삭제/복구 기능을 제공합니다.

---

## 📋 Todo 테이블 관련 메서드

| 메서드명 | 반환 타입 | 파라미터 | 설명 | 정렬/필터 | 사용처 |
|---------|----------|---------|------|----------|--------|
| `queryData()` | `Future<List<Todo>>` | 없음 | 모든 활성 일정 조회 | 날짜↑, 시간↑, 우선순위↓ | 전체 일정 목록, 알람 정리 |
| `queryDataByDate(String date)` | `Future<List<Todo>>` | `date`: 'YYYY-MM-DD' 형식 | 특정 날짜의 일정 조회 | 시간↑, 우선순위↓ | 메인 화면 일정 목록, Summary Bar 계산, 달력 이벤트 표시 |
| `queryDataByDateRange(String startDate, String endDate)` | `Future<List<Todo>>` | `startDate`: 'YYYY-MM-DD'<br>`endDate`: 'YYYY-MM-DD' (포함) | 날짜 범위 내 모든 일정 조회 | 날짜↑, 시간↑, 우선순위↓ | 달력 이벤트 캐시, 날짜 범위 조회 |
| `queryMinDate()` | `Future<String?>` | 없음 | 데이터가 존재하는 최소 날짜 조회 | - | 달력 날짜 제약 조건 설정 |
| `queryMaxDate()` | `Future<String?>` | 없음 | 데이터가 존재하는 최대 날짜 조회 | - | 달력 날짜 제약 조건 설정 |
| `queryDataById(int id)` | `Future<Todo?>` | `id`: Todo ID | ID로 단일 일정 조회 | - | 일정 수정/확인 |
| `insertData(Todo todo)` | `Future<int>` | `todo`: Todo 객체 | 새 일정 저장 | - |
| `updateData(Todo todo)` | `Future<int>` | `todo`: Todo 객체 (id 필수) | 일정 수정 (updated_at 자동 갱신) | - |
| `toggleDone(int id, bool isDone)` | `Future<int>` | `id`: Todo ID<br>`isDone`: 완료 여부 | 완료 상태 토글 (updated_at 자동 갱신) | - |

---

## 🗑️ DeletedTodo 테이블 관련 메서드

| 메서드명 | 반환 타입 | 파라미터 | 설명 | 정렬/필터 |
|---------|----------|---------|------|----------|
| `queryDeletedData()` | `Future<List<DeletedTodo>>` | 없음 | 모든 삭제된 일정 조회 | 삭제일시↓ |
| `queryDeletedDataByDateRange(DateTime startDate, DateTime endDate)` | `Future<List<DeletedTodo>>` | `startDate`: 시작 날짜<br>`endDate`: 종료 날짜 | 특정 기간의 삭제된 일정 조회 | 삭제일시↓ |

---

## 🔄 소프트 삭제 / 복구 / 완전 삭제

| 메서드명 | 반환 타입 | 파라미터 | 설명 | 비고 |
|---------|----------|---------|------|------|
| `deleteData(Todo todo, {BuildContext? context})` | `Future<void>` | `todo`: 삭제할 Todo<br>`context`: 선택사항 | 소프트 삭제 (todo → deleted_todo 이동) | 알람 취소는 호출 측에서 처리 |
| `restoreData(DeletedTodo deletedTodo, {BuildContext? context})` | `Future<void>` | `deletedTodo`: 복구할 DeletedTodo<br>`context`: 선택사항 | 복구 (deleted_todo → todo 이동) | 알람은 비활성화됨 |
| `realDeleteData(DeletedTodo deletedTodo, {BuildContext? context, bool showConfirmDialog = true})` | `Future<void>` | `deletedTodo`: 완전 삭제할 DeletedTodo<br>`context`: 선택사항<br>`showConfirmDialog`: 확인 다이얼로그 표시 여부 | 완전 삭제 (deleted_todo에서 영구 삭제) | 되돌릴 수 없음 |

---

## 🛠️ 유틸리티 메서드

| 메서드명 | 반환 타입 | 파라미터 | 설명 | 주의사항 |
|---------|----------|---------|------|---------|
| `initializeDB()` | `Future<Database>` | 없음 | DB 초기화 및 테이블 생성 | 앱 시작 시 한 번 호출 |
| `allClearData()` | `Future<void>` | 없음 | todo 테이블 전체 삭제 | 개발/테스트용 |
| `allClearDeletedData()` | `Future<void>` | 없음 | deleted_todo 테이블 전체 삭제 | 개발/테스트용 |

---

## 📊 주요 쿼리 상세 설명

### 1. `queryDataByDateRange(String startDate, String endDate)`

**용도**: 날짜 범위 내의 모든 일정을 조회합니다. 달력 이벤트 캐시 생성에 사용됩니다.

**특징**:
- 날짜 범위 내의 모든 Todo를 한 번에 조회
- `idx_todo_date` 인덱스를 활용하여 성능 최적화
- 날짜 오름차순, 시간 오름차순, 우선순위 내림차순으로 정렬

**사용 예시**:
```dart
// 2025-12-01부터 2025-12-07까지의 모든 일정 조회
final todos = await handler.queryDataByDateRange('2025-12-01', '2025-12-07');
```

### 2. `queryMinDate()` / `queryMaxDate()`

**용도**: 데이터베이스에 저장된 일정의 최소/최대 날짜를 조회하여 달력의 선택 가능한 날짜 범위를 제한합니다.

**특징**:
- 데이터가 없는 경우 `null` 반환
- 범위 선택 달력에서 날짜 제약 조건으로 사용
- 사용자가 데이터가 없는 날짜를 선택하는 것을 방지

**사용 예시**:
```dart
final minDate = await handler.queryMinDate(); // '2025-01-01'
final maxDate = await handler.queryMaxDate(); // '2025-12-31'
```

**통계 화면에서의 활용**:
- 날짜 범위 선택 다이얼로그의 `firstDate`, `lastDate`로 사용
- 범위 선택 달력의 `minDate`, `maxDate`로 사용

### 3. `queryDataByDate(String date)`

**용도**: 단일 날짜의 일정을 조회합니다. 메인 화면 일정 목록 표시에 사용됩니다.

**사용 예시**:
```dart
final handler = DatabaseHandler();
final todos = await handler.queryDataByDate('2024-12-01');
```

---

## 📝 사용 예시

### 날짜별 일정 조회
```dart
final handler = DatabaseHandler();
final todos = await handler.queryDataByDate('2024-12-01');
```

### 날짜 범위 일정 조회
```dart
final handler = DatabaseHandler();
final todos = await handler.queryDataByDateRange('2025-12-01', '2025-12-07');
```

### 날짜 제약 조건 조회
```dart
final handler = DatabaseHandler();
final minDate = await handler.queryMinDate(); // '2025-01-01'
final maxDate = await handler.queryMaxDate(); // '2025-12-31'

// 달력의 선택 가능한 날짜 범위 설정
CustomCalendarRangeBody(
  minDate: minDate != null ? DateTime.parse(minDate) : null,
  maxDate: maxDate != null ? DateTime.parse(maxDate) : null,
  // ...
)
```

### 일정 삽입
```dart
final handler = DatabaseHandler();
final todo = Todo.createNew(
  title: '회의',
  date: '2024-12-01',
  time: '14:00',
  step: StepMapperUtil.stepNoon,
);
final id = await handler.insertData(todo);
```

### 일정 수정
```dart
final handler = DatabaseHandler();
final updatedTodo = todo.copyWith(title: '수정된 제목');
await handler.updateData(updatedTodo);
```

### 완료 상태 토글
```dart
final handler = DatabaseHandler();
await handler.toggleDone(todoId, true); // 완료로 변경
```

### 소프트 삭제
```dart
final handler = DatabaseHandler();
await handler.deleteData(todo, context: context);
```

### 복구
```dart
final handler = DatabaseHandler();
await handler.restoreData(deletedTodo, context: context);
```

### 완전 삭제
```dart
final handler = DatabaseHandler();
await handler.realDeleteData(deletedTodo, context: context);
```

---

## 📌 날짜 형식

모든 날짜 파라미터는 **'YYYY-MM-DD'** 형식의 문자열을 사용합니다.

예: `'2024-12-01'`, `'2024-12-31'`

---

## ⚠️ 주의사항

1. **비동기 처리**: 모든 메서드는 `Future`를 반환하므로 `await`를 사용해야 합니다.
2. **날짜 형식**: 날짜는 반드시 'YYYY-MM-DD' 형식을 사용해야 합니다.
3. **ID 필수**: `updateData`, `toggleDone`, `deleteData` 등은 Todo의 `id`가 필수입니다.
4. **트랜잭션**: 소프트 삭제와 복구는 트랜잭션으로 처리되어 실패 시 롤백됩니다.
5. **완전 삭제**: `realDeleteData`는 되돌릴 수 없으므로 신중하게 사용해야 합니다.

---

## 🔍 정렬 규칙

- **날짜별 조회**: 시간 오름차순, 우선순위 내림차순
- **전체 조회**: 날짜 오름차순, 시간 오름차순, 우선순위 내림차순
- **삭제된 일정**: 삭제 일시 내림차순 (최신 삭제 순)

---

## 🔍 인덱스 활용

다음 인덱스들이 쿼리 성능을 최적화합니다. SQLite는 WHERE 절에서 인덱스가 있는 컬럼을 사용하면 **자동으로 인덱스를 활용**합니다.

### 인덱스 정의

```sql
CREATE INDEX IF NOT EXISTS idx_todo_date ON todo(date);
CREATE INDEX IF NOT EXISTS idx_deleted_todo_date ON deleted_todo(date);
CREATE INDEX IF NOT EXISTS idx_deleted_todo_deleted_at ON deleted_todo(deleted_at);
```

### 인덱스 사용 현황

#### `idx_todo_date` (todo 테이블의 date 컬럼)
다음 쿼리에서 **자동으로 사용**됩니다:
- ✅ `queryDataByDate(String date)`: `WHERE date = ?` → 인덱스 스캔
- ✅ `queryDataByDateRange(String startDate, String endDate)`: `WHERE date BETWEEN ? AND ?` → 인덱스 범위 스캔
- ✅ `queryMinDate()`: `SELECT MIN(date)` → 인덱스 사용 가능 (최소값 빠른 조회)
- ✅ `queryMaxDate()`: `SELECT MAX(date)` → 인덱스 사용 가능 (최대값 빠른 조회)

#### `idx_deleted_todo_date` (deleted_todo 테이블의 date 컬럼)
- ✅ `queryDeletedDataByDateRange()`: `WHERE deleted_at BETWEEN ? AND ?` → 인덱스 범위 스캔

#### `idx_deleted_todo_deleted_at` (deleted_todo 테이블의 deleted_at 컬럼)
- ✅ `queryDeletedData()`: `ORDER BY deleted_at DESC` → 인덱스 사용 가능 (정렬 최적화)

### 인덱스 사용 확인 방법

SQLite에서 인덱스 사용 여부를 확인하려면 `EXPLAIN QUERY PLAN`을 사용할 수 있습니다:

```sql
-- 예시: queryDataByDate 쿼리의 실행 계획 확인
EXPLAIN QUERY PLAN
SELECT * FROM todo WHERE date = '2025-12-07' ORDER BY time ASC, priority DESC;
```

결과에서 `SEARCH TABLE todo USING INDEX idx_todo_date`가 표시되면 인덱스가 사용되고 있음을 의미합니다.

### 성능 향상 효과

- **인덱스 없음**: 전체 테이블 스캔 (O(n))
- **인덱스 사용**: 인덱스 스캔 (O(log n))
- **데이터가 많을수록** 인덱스의 성능 향상 효과가 큼

---

## 🧪 테스트

테스트 시 `DatabaseHandler`의 `dbName` 파라미터를 활용하여 테스트 파일 간 DB 격리가 가능합니다.

```dart
// 기본 사용 (프로덕션)
final handler = DatabaseHandler(); // 'daily_flow.db' 사용

// 테스트용 (파일 간 DB 잠금 충돌 방지)
final handler = DatabaseHandler(dbName: 'test_my_feature.db');
```

---

*마지막 업데이트: 2026-02-08*

