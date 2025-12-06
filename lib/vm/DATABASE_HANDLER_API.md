# DatabaseHandler API 참조 문서

## 개요
`DatabaseHandler` 클래스는 DailyFlow 앱의 SQLite 데이터베이스 관리 클래스입니다.
todo와 deleted_todo 테이블을 관리하며, 소프트 삭제/복구 기능을 제공합니다.

---

## 📋 Todo 테이블 관련 메서드

| 메서드명 | 반환 타입 | 파라미터 | 설명 | 정렬/필터 |
|---------|----------|---------|------|----------|
| `queryData()` | `Future<List<Todo>>` | 없음 | 모든 활성 일정 조회 | 날짜↑, 시간↑, 우선순위↓ |
| `queryDataByDate(String date)` | `Future<List<Todo>>` | `date`: 'YYYY-MM-DD' 형식 | 특정 날짜의 일정 조회 | 시간↑, 우선순위↓ |
| `queryDataByDateAndStep(String date, int step)` | `Future<List<Todo>>` | `date`: 'YYYY-MM-DD'<br>`step`: 0=오전, 1=오후, 2=저녁, 3=종일 | 특정 날짜와 Step의 일정 조회 | 시간↑, 우선순위↓ |
| `queryDataById(int id)` | `Future<Todo?>` | `id`: Todo ID | ID로 단일 일정 조회 | - |
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

## 📝 사용 예시

### 날짜별 일정 조회
```dart
final handler = DatabaseHandler();
final todos = await handler.queryDataByDate('2024-12-01');
```

### Step별 일정 조회
```dart
final handler = DatabaseHandler();
final morningTodos = await handler.queryDataByDateAndStep('2024-12-01', StepMapperUtil.stepMorning);
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

## 📌 Step 값 상수

| 값 | 의미 | 한국어 |
|---|------|--------|
| `0` | 오전 | 오전 (06:00-11:59) |
| `1` | 오후 | 오후 (12:00-17:59) |
| `2` | 저녁 | 저녁 (18:00-23:59) |
| `3` | 종일 | 종일 (00:00-05:59 또는 시간 없음) |

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

*마지막 업데이트: 2024-12*

