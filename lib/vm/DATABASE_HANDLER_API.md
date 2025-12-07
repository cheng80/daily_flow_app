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
| `queryDataByDateAndStep(String date, int step)` | `Future<List<Todo>>` | `date`: 'YYYY-MM-DD'<br>`step`: 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일 | 특정 날짜와 Step의 일정 조회 | 시간↑, 우선순위↓ | 필터링된 일정 목록 (Step 필터 적용 시) |
| `queryDataByDateRange(String startDate, String endDate)` | `Future<List<Todo>>` | `startDate`: 'YYYY-MM-DD'<br>`endDate`: 'YYYY-MM-DD' (포함) | 날짜 범위 내 모든 일정 조회 | 날짜↑, 시간↑, 우선순위↓ | **통계 화면 범위 조회, 차트 데이터 생성** |
| `queryDataByDateRangeAndStep(String startDate, String endDate, int step)` | `Future<List<Todo>>` | `startDate`: 'YYYY-MM-DD'<br>`endDate`: 'YYYY-MM-DD'<br>`step`: 0~4 | 날짜 범위와 Step으로 일정 조회 | 날짜↑, 시간↑, 우선순위↓ | **필터링된 통계 데이터, 필터 적용된 차트 데이터** |
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

## 📊 통계 및 차트 데이터용 쿼리 상세 설명

### 1. `queryDataByDateRange(String startDate, String endDate)`

**용도**: 날짜 범위 내의 모든 일정을 조회하여 통계 및 차트 데이터를 생성하는 핵심 쿼리입니다.

**특징**:
- 날짜 범위 내의 모든 Todo를 한 번에 조회
- `idx_todo_date` 인덱스를 활용하여 성능 최적화
- 날짜 오름차순, 시간 오름차순, 우선순위 내림차순으로 정렬

**사용 예시**:
```dart
// 2025-12-01부터 2025-12-07까지의 모든 일정 조회
final todos = await handler.queryDataByDateRange('2025-12-01', '2025-12-07');
```

**통계 계산 과정**:
1. 조회된 `todos` 리스트를 순회하며 다음 통계를 계산:
   - **기본 통계**: 총 개수, 완료 개수, 완료율
   - **Step별 집계**: 오전/오후/저녁/야간/종일별 개수 및 완료율
   - **중요도별 집계**: P1~P5별 개수, 비율, 완료율

2. 계산된 데이터는 `AppRangeStatistics` 객체로 반환되어 다음 차트에 사용:
   - **완료율 Doughnut Chart**: `doneCount`, `totalCount` 사용
   - **Step별 비율 Pie Chart**: `stepRatios` 사용
   - **중요도별 분포 Column Chart**: `priorityDistribution` 사용 (Y축: 전체 개수)
   - **Step별 완료율 Column Chart**: `stepCompletionRates` 사용 (Y축: 0~100%)
   - **중요도별 완료율 Column Chart**: `priorityCompletionRates` 사용 (Y축: 0~100%)

**차트 데이터 매핑**:
- `priorityDistribution[1~5]`: 중요도별 개수 → Column Chart의 Y값
- `stepCompletionRates[0~4]`: Step별 완료율 (0.0~1.0) → Column Chart의 Y값 (×100하여 0~100%로 변환)
- `priorityCompletionRates[1~5]`: 중요도별 완료율 (0.0~1.0) → Column Chart의 Y값 (×100하여 0~100%로 변환)

### 2. `queryDataByDateRangeAndStep(String startDate, String endDate, int step)`

**용도**: 날짜 범위 내에서 특정 Step(시간대)으로 필터링된 일정을 조회합니다. 필터가 적용된 통계 및 차트 데이터를 생성할 때 사용됩니다.

**특징**:
- `idx_todo_date_step` 인덱스를 활용하여 성능 최적화
- Step 필터가 적용된 상태에서도 동일한 통계 계산 로직 사용
- 필터링된 데이터로 계산된 통계는 필터가 적용된 차트에 표시

**사용 예시**:
```dart
// 2025-12-01부터 2025-12-07까지의 오전(step=0) 일정만 조회
final morningTodos = await handler.queryDataByDateRangeAndStep(
  '2025-12-01', 
  '2025-12-07', 
  StepMapperUtil.stepMorning
);
```

**필터링된 통계 계산**:
- 메인 화면에서 Step 필터를 선택한 상태로 통계 화면에 진입하면, 필터링된 데이터만으로 통계 계산
- 예: "오전" 필터 선택 시 → 오전 일정만으로 완료율, 중요도별 분포 등 계산
- 필터가 없으면 전체 데이터로 계산 (`queryDataByDateRange` 사용)

**차트 데이터 영향**:
- 필터 적용 시 모든 차트가 필터링된 데이터 기준으로 표시
- 중요도별 분포 차트의 Y축 최대값도 필터링된 데이터의 총 개수로 설정

### 3. `queryMinDate()` / `queryMaxDate()`

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

### 4. `queryDataByDate(String date)` (통계 관련 사용)

**용도**: 단일 날짜의 일정을 조회하여 Summary Bar 비율을 계산합니다.

**통계 계산 과정**:
1. 특정 날짜의 모든 일정 조회
2. Step별 개수 집계 (오전/오후/저녁/야간/종일)
3. 전체 대비 비율 계산 → `AppSummaryRatios` 객체 반환
4. Summary Bar에 시각적으로 표시

**차트 데이터 매핑**:
- `AppSummaryRatios`의 각 비율 → Summary Bar의 각 구간 너비
- Step별 비율 Pie Chart에도 동일한 데이터 사용

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

### 날짜 범위 일정 조회 (통계/차트용)
```dart
final handler = DatabaseHandler();
// 2025-12-01부터 2025-12-07까지의 모든 일정 조회
final todos = await handler.queryDataByDateRange('2025-12-01', '2025-12-07');

// 통계 계산
final stats = await calculateRangeStatistics(handler, '2025-12-01', '2025-12-07');
// stats.totalCount: 총 일정 개수
// stats.doneCount: 완료된 일정 개수
// stats.completionRate: 완료율 (0.0~1.0)
// stats.priorityDistribution: 중요도별 분포 {1: 5, 2: 10, 3: 8, 4: 3, 5: 2}
// stats.stepCompletionRates: Step별 완료율 {0: 0.8, 1: 0.6, 2: 0.9, 3: 0.5, 4: 0.7}
// stats.priorityCompletionRates: 중요도별 완료율 {1: 0.9, 2: 0.7, 3: 0.8, 4: 0.6, 5: 0.5}
```

### 필터링된 통계 데이터 조회
```dart
final handler = DatabaseHandler();
// 오전(step=0) 일정만 조회하여 통계 계산
final morningTodos = await handler.queryDataByDateRangeAndStep(
  '2025-12-01', 
  '2025-12-07', 
  StepMapperUtil.stepMorning
);

// 필터링된 데이터로 통계 계산
final stats = _calculateStatisticsFromTodos(morningTodos, startDate, endDate);
// 필터링된 데이터 기준으로 모든 통계 계산
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

## 📌 Step 값 상수

| 값 | 의미 | 한국어 | 시간 범위 |
|---|------|--------|----------|
| `0` | 오전 | 오전 | 06:00-11:59 |
| `1` | 오후 | 오후 | 12:00-17:59 |
| `2` | 저녁 | 저녁 | 18:00-23:59 |
| `3` | 야간 | 야간 | 00:00-05:59 |
| `4` | 종일 | 종일 | 시간 없음 또는 기타 |

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

## 📈 통계 데이터 흐름도

### 범위 통계 계산 흐름

```
1. 사용자가 날짜 범위 선택 (예: 2025-12-01 ~ 2025-12-07)
   ↓
2. queryDataByDateRange() 또는 queryDataByDateRangeAndStep() 호출
   ↓
3. 조회된 Todo 리스트 반환
   ↓
4. calculateRangeStatistics() 또는 _calculateStatisticsFromTodos() 호출
   ↓
5. 통계 계산:
   - 기본 통계: totalCount, doneCount, completionRate
   - Step별 집계: stepCounts, stepDoneCounts → stepRatios, stepCompletionRates
   - 중요도별 집계: priorityCounts, priorityDoneCounts → priorityRatios, priorityCompletionRates
   ↓
6. AppRangeStatistics 객체 생성
   ↓
7. 차트 데이터로 변환:
   - 완료율 Doughnut Chart: doneCount, totalCount
   - Step별 비율 Pie Chart: stepRatios
   - 중요도별 분포 Column Chart: priorityDistribution (Y축: totalCount)
   - Step별 완료율 Column Chart: stepCompletionRates × 100 (Y축: 0~100%)
   - 중요도별 완료율 Column Chart: priorityCompletionRates × 100 (Y축: 0~100%)
```

### 필터링된 통계 계산 흐름

```
1. 사용자가 Step 필터 선택 (예: "오전")
   ↓
2. queryDataByDateRangeAndStep() 호출 (step=0)
   ↓
3. 필터링된 Todo 리스트 반환 (오전 일정만)
   ↓
4. _calculateStatisticsFromTodos() 호출 (필터링된 데이터)
   ↓
5. 필터링된 데이터 기준으로 통계 계산
   ↓
6. 모든 차트가 필터링된 데이터 기준으로 표시
```

---

## 🔍 인덱스 활용

다음 인덱스들이 쿼리 성능을 최적화합니다:

- **`idx_todo_date`**: `date` 컬럼 인덱스
  - `queryDataByDate()`, `queryDataByDateRange()` 성능 향상
  
- **`idx_todo_date_step`**: `date`, `step` 복합 인덱스
  - `queryDataByDateAndStep()`, `queryDataByDateRangeAndStep()` 성능 향상

---

*마지막 업데이트: 2024-12-07*

