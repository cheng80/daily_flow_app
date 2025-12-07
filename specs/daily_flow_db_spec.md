# DailyFlow 앱 – SQLite 데이터베이스 설계서

DailyFlow MVP에서 사용하는 SQLite 테이블은 다음 2개를 기본으로 한다.

1. `todo` – 활성 일정 저장용 메인 테이블
2. `deleted_todo` – 삭제된 일정(휴지통) 보관 테이블

각 테이블의 컬럼 명세와 SQLite DDL 코드를 아래에 정리한다.

---

## 1. `todo` 테이블 – 활성 일정

### 1.1 테이블 목적

- 현재 사용 중인 모든 "할 일(Todo)"을 저장하는 메인 테이블
- 하루 단위 조회, Step(오전/오후/저녁/야간/종일) 필터, 중요도(1\~5단계), 알람 여부, 완료 여부 등을 관리

### 1.2 컬럼 명세

| 컬럼명               | 타입      | NOT NULL | 기본값           | 설명                                             |
| ----------------- | ------- | -------- | ------------- | ---------------------------------------------- |
| `id`              | INTEGER | ✔        | AUTOINCREMENT | PK, 일정 고유 ID                                   |
| `title`           | TEXT    | ✔        |               | 일정 제목 (최대 50자)                                  |
| `memo`            | TEXT    | ✖        | NULL          | 메모(상세 내용, 최대 200자)                               |
| `date`            | TEXT    | ✔        |               | 일정 날짜, 형식: `YYYY-MM-DD`                        |
| `time`            | TEXT    | ✖        | NULL          | 일정 시간(있을 경우), 형식: `HH:MM`                      |
| `step`            | INTEGER | ✔        | 4             | 시간대 분류: `0=오전, 1=오후, 2=저녁, 3=야간, 4=종일` (기본값: 4=종일) |
| `priority`        | INTEGER | ✔        | 3             | 중요도 1\~5단계 (1:매우낮음 \~ 5:매우높음)                  |
| `is_done`         | INTEGER | ✔        | 0             | 완료 여부: `0=미완료`, `1=완료`                         |
| `has_alarm`       | INTEGER | ✔        | 0             | 알람 활성 여부: `0=알람 없음`, `1=알람 있음`                 |
| `notification_id` | INTEGER | ✖        | NULL          | `flutter_local_notifications`용 알림 ID (1일정 1알람) |
| `created_at`      | TEXT    | ✔        |               | 생성 시각, 형식: `YYYY-MM-DD HH:MM:SS`               |
| `updated_at`      | TEXT    | ✔        |               | 마지막 수정 시각, 형식: `YYYY-MM-DD HH:MM:SS`           |

> 비고
>
> - `title`은 최대 50자로 제한 (UI에서 입력 제한 적용).
> - `memo`는 최대 200자로 제한 (UI에서 입력 제한 적용).
> - `time`은 알람을 사용하지 않는 일정의 경우 NULL 가능.
> - `step`은 드롭다운 선택 또는 시간 자동 매핑 결과를 저장.
> - `priority`는 1\~5 정수 값으로, UI에서 색상 라벨과 매핑.
> - `has_alarm`이 1이고 `time`이 존재할 때만 알람 스케줄링 대상.

### 1.3 인덱스 설계

주요 조회 패턴:

- 특정 날짜의 일정: `WHERE date = ?`
- 날짜 + Step 필터: `WHERE date = ? AND step = ?`
- 날짜 범위의 일정: `WHERE date BETWEEN ? AND ?` (고도화 개발 예정) ✅

이에 따른 인덱스:

- `idx_todo_date` : `date` 단일 인덱스
  - 특정 날짜 조회 최적화
  - 날짜 범위 조회 최적화 (BETWEEN 쿼리에서 활용 가능) ✅
- `idx_todo_date_step` : `date, step` 복합 인덱스
  - 특정 날짜 + Step 조회 최적화

**인덱스 활용 범위 쿼리:**
- `idx_todo_date` 인덱스는 `WHERE date BETWEEN ? AND ?` 쿼리에서도 효율적으로 사용됩니다.
- SQLite는 범위 쿼리에서도 단일 컬럼 인덱스를 활용할 수 있어 추가 인덱스가 필요하지 않습니다.

### 1.4 SQLite CREATE TABLE / INDEX 코드

```sql
CREATE TABLE IF NOT EXISTS todo (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  title           TEXT    NOT NULL,
  memo            TEXT,
  date            TEXT    NOT NULL,           -- 'YYYY-MM-DD'
  time            TEXT,                       -- 'HH:MM' (NULL 허용)
  step            INTEGER NOT NULL DEFAULT 4, -- 0:오전,1:오후,2:저녁,3:야간,4:종일
  priority        INTEGER NOT NULL DEFAULT 3, -- 1~5
  is_done         INTEGER NOT NULL DEFAULT 0, -- 0:false, 1:true
  has_alarm       INTEGER NOT NULL DEFAULT 0, -- 0:false, 1:true
  notification_id INTEGER,
  created_at      TEXT    NOT NULL,           -- 'YYYY-MM-DD HH:MM:SS'
  updated_at      TEXT    NOT NULL            -- 'YYYY-MM-DD HH:MM:SS'
);

CREATE INDEX IF NOT EXISTS idx_todo_date
  ON todo(date);

CREATE INDEX IF NOT EXISTS idx_todo_date_step
  ON todo(date, step);
```

---

## 2. `deleted_todo` 테이블 – 삭제된 일정(휴지통)

### 2.1 테이블 목적

- 사용자가 삭제한 일정을 **즉시 완전 삭제하지 않고**, 별도 테이블에 보관
- 삭제 보관함 화면에서 복구 또는 완전 삭제를 지원

### 2.2 컬럼 명세

| 컬럼명           | 타입      | NOT NULL | 기본값           | 설명                          |
| ------------- | ------- | -------- | ------------- | --------------------------- |
| `id`          | INTEGER | ✔        | AUTOINCREMENT | PK (휴지통 레코드 ID)             |
| `original_id` | INTEGER | ✖        | NULL          | 삭제되기 전 `todo.id` 값 (추적용)    |
| `title`       | TEXT    | ✔        |               | 일정 제목 (최대 50자)              |
| `memo`        | TEXT    | ✖        | NULL          | 메모 내용 (최대 200자)              |
| `date`        | TEXT    | ✔        |               | 일정 날짜 `YYYY-MM-DD`          |
| `time`        | TEXT    | ✖        | NULL          | 일정 시간(있을 경우) `HH:MM`        |
| `step`        | INTEGER | ✔        | 4             | 0=오전,1=오후,2=저녁,3=야간,4=종일 (기본값: 4=종일) |
| `priority`    | INTEGER | ✔        | 3             | 중요도 1\~5단계                  |
| `is_done`     | INTEGER | ✔        | 0             | 삭제 시점의 완료 여부 (0/1)          |
| `deleted_at`  | TEXT    | ✔        |               | 삭제 일시 `YYYY-MM-DD HH:MM:SS` |

> 비고
>
> - `notification_id` 등 알람 관련 필드는 삭제 시점 기준으로 의미가 사라지므로 저장하지 않는다.
> - 복구 시에는 알람이 비활성화 상태로 복구되며, 필요 시 사용자가 새 알람을 등록하도록 유도한다. ✅

### 2.3 삭제/복구 플로우 개요

- **삭제 시**:

  1. `todo`에서 대상 레코드 SELECT
  2. 같은 내용 + `original_id = todo.id`, `deleted_at = 현재 시각`으로 `deleted_todo`에 INSERT
  3. 알람 `cancel(notification_id)` 자동 수행 ✅
  4. `todo`에서 해당 레코드 DELETE

- **복구 시**:

  1. `deleted_todo`에서 복구 대상 SELECT
  2. `todo`에 INSERT (새 id 부여) ✅
  3. 알람은 비활성화 상태로 복구 (`has_alarm = 0`, `notification_id = NULL`) ✅
  4. `deleted_todo`에서 해당 레코드 DELETE

- **완전 삭제 시**:

  - `deleted_todo`에서 해당 레코드 DELETE

### 2.4 SQLite CREATE TABLE / INDEX 코드

```sql
CREATE TABLE IF NOT EXISTS deleted_todo (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  original_id  INTEGER,
  title        TEXT    NOT NULL,
  memo         TEXT,
  date         TEXT    NOT NULL,           -- 'YYYY-MM-DD'
  time         TEXT,                       -- 'HH:MM'
  step         INTEGER NOT NULL DEFAULT 4, -- 0:오전,1:오후,2:저녁,3:야간,4:종일
  priority     INTEGER NOT NULL DEFAULT 3, -- 1~5
  is_done      INTEGER NOT NULL DEFAULT 0, -- 0:false,1:true
  deleted_at   TEXT    NOT NULL            -- 'YYYY-MM-DD HH:MM:SS'
);

CREATE INDEX IF NOT EXISTS idx_deleted_todo_date
  ON deleted_todo(date);

CREATE INDEX IF NOT EXISTS idx_deleted_todo_deleted_at
  ON deleted_todo(deleted_at);
```

---

## 3. 날짜 범위 조회 및 통계 기능 (고도화 개발 예정) ✅

### 3.1 목적

- 사용자가 달력에서 시작날짜와 끝날짜를 선택하여 기간 내 일정 통계를 확인할 수 있는 기능
- 단일 날짜 모드와 범위 모드 간 전환 지원

### 3.2 데이터베이스 스키마 변경 필요 여부

**✅ DB 스키마 변경 불필요**

현재 `todo` 테이블의 모든 컬럼이 범위 선택 및 통계 기능에 충분합니다:

| 통계 항목 | 필요한 컬럼 | 현재 상태 |
|----------|------------|----------|
| 날짜 범위 조회 | `date` | ✅ 존재 |
| Step별 통계 | `step` | ✅ 존재 |
| 중요도별 통계 | `priority` | ✅ 존재 |
| 완료율 통계 | `is_done` | ✅ 존재 |
| 알람 설정률 | `has_alarm` | ✅ 존재 |
| 메모 작성률 | `memo` (IS NOT NULL 체크) | ✅ 존재 (nullable) |
| 시간 설정률 | `time` (IS NOT NULL 체크) | ✅ 존재 (nullable) |
| 생성 추이 | `created_at` | ✅ 존재 |
| 수정 빈도 | `updated_at` | ✅ 존재 |

**결론:**
- **DB 스키마 변경 불필요** ✅
- **인덱스도 이미 존재** (`idx_todo_date`, `idx_todo_date_step`) ✅
- **DatabaseHandler에 쿼리 메서드만 추가하면 됨** ✅

### 3.3 데이터베이스 쿼리 설계

#### 날짜 범위 조회 쿼리

```sql
-- 날짜 범위 내 모든 Todo 조회
SELECT * 
FROM todo 
WHERE date BETWEEN ? AND ? 
ORDER BY date ASC, time ASC, priority DESC
```

**성능 고려사항:**
- `idx_todo_date` 인덱스가 범위 쿼리에서도 효율적으로 작동합니다.
- `BETWEEN ? AND ?` 조건은 인덱스 스캔을 활용하여 빠른 조회가 가능합니다.
- 넓은 범위(예: 1년) 선택 시에도 인덱스 덕분에 성능 저하가 최소화됩니다.

#### 집계 쿼리 (통계 계산용)

```sql
-- 날짜 범위 내 전체 Todo 개수 및 완료 개수
SELECT 
  COUNT(*) as total_count,
  SUM(CASE WHEN is_done = 1 THEN 1 ELSE 0 END) as done_count
FROM todo 
WHERE date BETWEEN ? AND ?

-- 날짜 범위 내 Step별 Todo 개수
SELECT 
  step,
  COUNT(*) as count
FROM todo 
WHERE date BETWEEN ? AND ?
GROUP BY step
ORDER BY step ASC

-- 날짜 범위 내 중요도별 Todo 개수
SELECT 
  priority,
  COUNT(*) as count
FROM todo 
WHERE date BETWEEN ? AND ?
GROUP BY priority
ORDER BY priority ASC

-- 날짜 범위 내 Step별 + 중요도별 집계 (필요시)
SELECT 
  step,
  priority,
  COUNT(*) as count,
  SUM(CASE WHEN is_done = 1 THEN 1 ELSE 0 END) as done_count
FROM todo 
WHERE date BETWEEN ? AND ?
GROUP BY step, priority
ORDER BY step ASC, priority ASC
```

### 3.3 DatabaseHandler 메서드 설계

#### 날짜 범위 조회 메서드

```dart
/// 날짜 범위 내 모든 todo 조회
/// 
/// [startDate] 시작 날짜 ('YYYY-MM-DD' 형식)
/// [endDate] 종료 날짜 ('YYYY-MM-DD' 형식, 포함)
/// 반환: 날짜↑, 시간↑, 중요도↓ 순으로 정렬된 Todo 리스트
Future<List<Todo>> queryDataByDateRange(String startDate, String endDate) async {
  final Database db = await initializeDB();
  final List<Map<String, Object?>> queryResult = await db.rawQuery(
    """
    SELECT * 
    FROM todo 
    WHERE date BETWEEN ? AND ? 
    ORDER BY date ASC, time ASC, priority DESC
    """,
    [startDate, endDate],
  );
  return queryResult.map((e) => Todo.fromMap(e)).toList();
}
```

#### 날짜 범위 + Step 조회 메서드 (선택사항)

```dart
/// 날짜 범위 내 특정 Step의 todo 조회
/// 
/// [startDate] 시작 날짜 ('YYYY-MM-DD' 형식)
/// [endDate] 종료 날짜 ('YYYY-MM-DD' 형식, 포함)
/// [step] Step 값 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
/// 반환: 날짜↑, 시간↑, 중요도↓ 순으로 정렬된 Todo 리스트
Future<List<Todo>> queryDataByDateRangeAndStep(
  String startDate, 
  String endDate, 
  int step
) async {
  final Database db = await initializeDB();
  final List<Map<String, Object?>> queryResult = await db.rawQuery(
    """
    SELECT * 
    FROM todo 
    WHERE date BETWEEN ? AND ? 
      AND step = ?
    ORDER BY date ASC, time ASC, priority DESC
    """,
    [startDate, endDate, step],
  );
  return queryResult.map((e) => Todo.fromMap(e)).toList();
}
```

**인덱스 활용:**
- `queryDataByDateRange`: `idx_todo_date` 인덱스 사용
- `queryDataByDateRangeAndStep`: `idx_todo_date_step` 인덱스 사용 (더 효율적)

#### 날짜 범위 제약을 위한 조회 메서드

```dart
/// 데이터가 존재하는 최소 날짜 조회
/// 
/// 반환: 가장 이른 날짜 ('YYYY-MM-DD' 형식), 데이터가 없으면 null
Future<String?> queryMinDate() async {
  final Database db = await initializeDB();
  final List<Map<String, Object?>> queryResult = await db.rawQuery(
    """
    SELECT MIN(date) as min_date
    FROM todo
    """,
  );
  
  if (queryResult.isEmpty || queryResult[0]['min_date'] == null) {
    return null;
  }
  
  return queryResult[0]['min_date'] as String;
}

/// 데이터가 존재하는 최대 날짜 조회
/// 
/// 반환: 가장 늦은 날짜 ('YYYY-MM-DD' 형식), 데이터가 없으면 null
Future<String?> queryMaxDate() async {
  final Database db = await initializeDB();
  final List<Map<String, Object?>> queryResult = await db.rawQuery(
    """
    SELECT MAX(date) as max_date
    FROM todo
    """,
  );
  
  if (queryResult.isEmpty || queryResult[0]['max_date'] == null) {
    return null;
  }
  
  return queryResult[0]['max_date'] as String;
}
```

**성능 고려사항:**
- `MIN(date)`와 `MAX(date)`는 `idx_todo_date` 인덱스를 효율적으로 활용합니다.
- SQLite는 인덱스에서 최소/최대 값을 빠르게 찾을 수 있습니다.
- 데이터가 없을 경우를 대비해 null 체크 필요합니다.

### 3.4 통계 계산 설계

#### 통계 데이터 모델 (애플리케이션 레이어)

통계 계산은 애플리케이션 레이어에서 수행하며, DB는 조회만 담당합니다.

**이유:**
- SQLite 집계 함수로도 가능하지만, Dart 코드에서 계산하는 것이 더 유연합니다.
- Step별 비율, 중요도별 분포 등 복잡한 계산을 쉽게 구현할 수 있습니다.
- 기존 `AppCommonUtil.calculateSummaryRatios()` 로직 재사용 가능합니다.

**통계 계산 예시:**
```dart
// 1. 날짜 범위 내 모든 Todo 조회
final todos = await databaseHandler.queryDataByDateRange(startDate, endDate);

// 2. 애플리케이션 레이어에서 통계 계산
final statistics = AppCommonUtil.calculateRangeStatistics(
  todos: todos,
  startDate: startDate,
  endDate: endDate,
);
```

### 3.5 성능 최적화 고려사항

1. **인덱스 활용**
   - 기존 `idx_todo_date` 인덱스로 범위 쿼리 최적화
   - 넓은 범위(예: 1년) 조회 시에도 효율적

2. **쿼리 최적화**
   - `BETWEEN` 연산자는 인덱스 범위 스캔을 활용
   - 필요한 컬럼만 조회하는 것보다 전체 조회가 더 효율적 (통계 계산에 모든 필드 필요)

3. **메모리 관리**
   - 넓은 범위 조회 시 메모리 사용량 고려
   - 필요 시 페이지네이션 또는 샘플링 검토

4. **캐싱 전략** (선택사항)
   - 자주 조회되는 범위의 통계 결과 캐싱
   - Todo 변경 시 캐시 무효화

### 3.6 구현 순서

1. ✅ DB 스펙 문서 업데이트 (현재 작업)
2. ✅ **DB 스키마 변경 불필요 확인** (모든 필요한 컬럼 이미 존재)
3. `DatabaseHandler`에 쿼리 메서드 추가:
   - `queryDataByDateRange()` - 날짜 범위 조회
   - `queryMinDate()` - 최소 날짜 조회
   - `queryMaxDate()` - 최대 날짜 조회
4. 통계 계산 모델 클래스 추가 (`AppRangeStatistics`)
5. 통계 계산 함수 추가 (`AppCommonUtil.calculateRangeStatistics`)
6. UI 구현 (달력 범위 선택, 통계 카드)

**중요:** 
- ✅ **DB 마이그레이션이나 스키마 변경 불필요**
- ✅ **기존 테이블 구조 그대로 사용 가능**
- ✅ **인덱스도 이미 존재** (`idx_todo_date`, `idx_todo_date_step`)
- ✅ **DatabaseHandler에 쿼리 메서드만 추가하면 됨**

---

## 4. 환경 설정 저장 전략 – shared\_preferences (MVP 기준)

### 3.1 결정 사항

- **MVP 단계에서는 별도의 ****\`\`**** SQLite 테이블을 사용하지 않는다.**
- 테마 모드(라이트/다크)와 같은 간단한 환경 설정 값은 \`\`\*\* 로컬 저장소\*\*를 사용하여 관리한다.

### 3.2 이유

- 환경 설정은 모두 Key-Value 형태이며, 관계형 구조가 필요 없다.
- 읽기/쓰기 빈도가 높고 데이터 양이 매우 적다.
- Flutter에서 `shared_preferences`는 이 용도에 최적화된 경량 솔루션이다.
- DB 스키마를 단순하게 유지하여 유지보수 부담을 줄인다.

### 3.3 사용 예시 (개념)

- 테마 모드 저장:
  - key: `"theme_mode"`
  - value: `"light"` / `"dark"`
- 앱 시작 시:
  - `sharedPreferences.getString('theme_mode')` 로 값 읽기
  - 없으면 기본값 `light` 또는 `ThemeMode.system` 적용

> 향후 환경 설정 항목이 매우 많아지거나, 설정 변경 이력을 관리해야 하는 수준이 되면, 그때 별도의 `app_settings` 테이블 도입을 재고려할 수 있다. 현재 MVP에서는 **SQLite에는 **``** / **``** 두 테이블만 사용**한다.

---

## 5. 요약

- `todo` : 활성 일정 관리용 메인 테이블 (알람/중요도/Step/완료 여부 포함)
- `deleted_todo` : 삭제된 일정 보관 및 복구/완전 삭제용 테이블
- 환경 설정(테마 모드 등): SQLite가 아닌 `shared_preferences`로 관리
- 날짜 범위 조회: 기존 `idx_todo_date` 인덱스 활용하여 효율적인 범위 쿼리 지원 ✅

이 설계서를 기준으로 Flutter의 sqflite 초기화 코드에 위 CREATE TABLE/INDEX 구문을 포함시키면 된다.

---

## 6. DBML 정의 (dbdiagram.io용)

아래 DBML 스키마를 [https://dbdiagram.io](https://dbdiagram.io) 에 입력하면 ERD를 시각적으로 확인할 수 있다.

```dbml
// DailyFlow – SQLite schema (todo / deleted_todo)
// step: 0=오전,1=오후,2=저녁,3=야간,4=종일 (기본값: 4=종일)
// priority: 1=매우낮음 ~ 5=매우높음
// is_done, has_alarm: 0=false, 1=true

Table todo {
  id              integer [pk, increment] // PK, AUTOINCREMENT
  title           text   [not null]       // 일정 제목
  memo            text                    // 메모 (nullable)
  date            text   [not null]       // 'YYYY-MM-DD'
  time            text                    // 'HH:MM' (nullable)
  step            integer [not null, default: 4] // 0=오전,1=오후,2=저녁,3=야간,4=종일
  priority        integer [not null, default: 3] // 1~5 중요도
  is_done         integer [not null, default: 0] // 0=미완료,1=완료
  has_alarm       integer [not null, default: 0] // 0=알람 없음,1=알람 있음
  notification_id integer                 // flutter_local_notifications ID
  created_at      text   [not null]       // 'YYYY-MM-DD HH:MM:SS'
  updated_at      text   [not null]       // 'YYYY-MM-DD HH:MM:SS'

  Note: 'step: 0=오전,1=오후,2=저녁,3=야간,4=종일; priority:1~5; is_done/has_alarm:0/1'

  Indexes {
    (date) [name: 'idx_todo_date']
    (date, step) [name: 'idx_todo_date_step']
  }
}

Table deleted_todo {
  id           integer [pk, increment]      // 휴지통 PK
  original_id  integer                      // 원래 todo.id (nullable)
  title        text    [not null]           // 일정 제목
  memo         text                          // 메모
  date         text    [not null]           // 'YYYY-MM-DD'
  time         text                          // 'HH:MM'
  step         integer [not null, default: 4] // 0=오전,1=오후,2=저녁,3=야간,4=종일
  priority     integer [not null, default: 3] // 1~5 중요도
  is_done      integer [not null, default: 0] // 삭제 시점 완료 여부
  deleted_at   text    [not null]           // 'YYYY-MM-DD HH:MM:SS'

  Note: '휴지통용 백업 테이블. 알람 정보는 저장하지 않음.'

  Indexes {
    (date)       [name: 'idx_deleted_todo_date']
    (deleted_at) [name: 'idx_deleted_todo_deleted_at']
  }
}

// 느슨한 참조 관계 (논리적 FK)
Ref: deleted_todo.original_id > todo.id
```

