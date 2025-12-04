# DailyFlow 앱 – SQLite 데이터베이스 설계서

DailyFlow MVP에서 사용하는 SQLite 테이블은 다음 2개를 기본으로 한다.

1. `todo` – 활성 일정 저장용 메인 테이블
2. `deleted_todo` – 삭제된 일정(휴지통) 보관 테이블

각 테이블의 컬럼 명세와 SQLite DDL 코드를 아래에 정리한다.

---

## 1. `todo` 테이블 – 활성 일정

### 1.1 테이블 목적

- 현재 사용 중인 모든 "할 일(Todo)"을 저장하는 메인 테이블
- 하루 단위 조회, Step(아침/낮/저녁/Anytime) 필터, 중요도(1\~5단계), 알람 여부, 완료 여부 등을 관리

### 1.2 컬럼 명세

| 컬럼명               | 타입      | NOT NULL | 기본값           | 설명                                             |
| ----------------- | ------- | -------- | ------------- | ---------------------------------------------- |
| `id`              | INTEGER | ✔        | AUTOINCREMENT | PK, 일정 고유 ID                                   |
| `title`           | TEXT    | ✔        |               | 일정 제목                                          |
| `memo`            | TEXT    | ✖        | NULL          | 메모(상세 내용)                                      |
| `date`            | TEXT    | ✔        |               | 일정 날짜, 형식: `YYYY-MM-DD`                        |
| `time`            | TEXT    | ✖        | NULL          | 일정 시간(있을 경우), 형식: `HH:MM`                      |
| `step`            | INTEGER | ✔        | 3             | 시간대 분류: `0=아침, 1=낮, 2=저녁, 3=Anytime`           |
| `priority`        | INTEGER | ✔        | 3             | 중요도 1\~5단계 (1:매우낮음 \~ 5:매우높음)                  |
| `is_done`         | INTEGER | ✔        | 0             | 완료 여부: `0=미완료`, `1=완료`                         |
| `has_alarm`       | INTEGER | ✔        | 0             | 알람 활성 여부: `0=알람 없음`, `1=알람 있음`                 |
| `notification_id` | INTEGER | ✖        | NULL          | `flutter_local_notifications`용 알림 ID (1일정 1알람) |
| `created_at`      | TEXT    | ✔        |               | 생성 시각, 형식: `YYYY-MM-DD HH:MM:SS`               |
| `updated_at`      | TEXT    | ✔        |               | 마지막 수정 시각, 형식: `YYYY-MM-DD HH:MM:SS`           |

> 비고
>
> - `time`은 알람을 사용하지 않는 일정의 경우 NULL 가능.
> - `step`은 드롭다운 선택 또는 시간 자동 매핑 결과를 저장.
> - `priority`는 1\~5 정수 값으로, UI에서 색상 라벨과 매핑.
> - `has_alarm`이 1이고 `time`이 존재할 때만 알람 스케줄링 대상.

### 1.3 인덱스 설계

주요 조회 패턴:

- 특정 날짜의 일정: `WHERE date = ?`
- 날짜 + Step 필터: `WHERE date = ? AND step = ?`

이에 따른 인덱스:

- `idx_todo_date` : `date` 단일 인덱스
- `idx_todo_date_step` : `date, step` 복합 인덱스

### 1.4 SQLite CREATE TABLE / INDEX 코드

```sql
CREATE TABLE IF NOT EXISTS todo (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  title           TEXT    NOT NULL,
  memo            TEXT,
  date            TEXT    NOT NULL,           -- 'YYYY-MM-DD'
  time            TEXT,                       -- 'HH:MM' (NULL 허용)
  step            INTEGER NOT NULL DEFAULT 3, -- 0:아침,1:낮,2:저녁,3:Anytime
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
| `title`       | TEXT    | ✔        |               | 일정 제목                       |
| `memo`        | TEXT    | ✖        | NULL          | 메모 내용                       |
| `date`        | TEXT    | ✔        |               | 일정 날짜 `YYYY-MM-DD`          |
| `time`        | TEXT    | ✖        | NULL          | 일정 시간(있을 경우) `HH:MM`        |
| `step`        | INTEGER | ✔        | 3             | 0=아침,1=낮,2=저녁,3=Anytime     |
| `priority`    | INTEGER | ✔        | 3             | 중요도 1\~5단계                  |
| `is_done`     | INTEGER | ✔        | 0             | 삭제 시점의 완료 여부 (0/1)          |
| `deleted_at`  | TEXT    | ✔        |               | 삭제 일시 `YYYY-MM-DD HH:MM:SS` |

> 비고
>
> - `notification_id` 등 알람 관련 필드는 삭제 시점 기준으로 의미가 사라지므로 저장하지 않는다.
> - 복구 시에는 필요에 따라 새 알람을 등록하도록 유도한다.

### 2.3 삭제/복구 플로우 개요

- **삭제 시**:

  1. `todo`에서 대상 레코드 SELECT
  2. 같은 내용 + `original_id = todo.id`, `deleted_at = 현재 시각`으로 `deleted_todo`에 INSERT
  3. 필요 시 알람 `cancel(notification_id)` 수행
  4. `todo`에서 해당 레코드 DELETE

- **복구 시**:

  1. `deleted_todo`에서 복구 대상 SELECT
  2. `todo`에 INSERT (새 id 부여, 또는 original\_id 재사용 여부는 구현 시 결정)
  3. `deleted_todo`에서 해당 레코드 DELETE

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
  step         INTEGER NOT NULL DEFAULT 3, -- 0:아침,1:낮,2:저녁,3:Anytime
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

## 3. 환경 설정 저장 전략 – shared\_preferences (MVP 기준)

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

## 4. 요약

- `todo` : 활성 일정 관리용 메인 테이블 (알람/중요도/Step/완료 여부 포함)
- `deleted_todo` : 삭제된 일정 보관 및 복구/완전 삭제용 테이블
- 환경 설정(테마 모드 등): SQLite가 아닌 `shared_preferences`로 관리

이 설계서를 기준으로 Flutter의 sqflite 초기화 코드에 위 CREATE TABLE/INDEX 구문을 포함시키면 된다.

---

## 5. DBML 정의 (dbdiagram.io용)

아래 DBML 스키마를 [https://dbdiagram.io](https://dbdiagram.io) 에 입력하면 ERD를 시각적으로 확인할 수 있다.

```dbml
// DailyFlow – SQLite schema (todo / deleted_todo)
// step: 0=아침,1=낮,2=저녁,3=Anytime
// priority: 1=매우낮음 ~ 5=매우높음
// is_done, has_alarm: 0=false, 1=true

Table todo {
  id              integer [pk, increment] // PK, AUTOINCREMENT
  title           text   [not null]       // 일정 제목
  memo            text                    // 메모 (nullable)
  date            text   [not null]       // 'YYYY-MM-DD'
  time            text                    // 'HH:MM' (nullable)
  step            integer [not null, default: 3] // 0=아침,1=낮,2=저녁,3=Anytime
  priority        integer [not null, default: 3] // 1~5 중요도
  is_done         integer [not null, default: 0] // 0=미완료,1=완료
  has_alarm       integer [not null, default: 0] // 0=알람 없음,1=알람 있음
  notification_id integer                 // flutter_local_notifications ID
  created_at      text   [not null]       // 'YYYY-MM-DD HH:MM:SS'
  updated_at      text   [not null]       // 'YYYY-MM-DD HH:MM:SS'

  Note: 'step: 0=아침,1=낮,2=저녁,3=Anytime; priority:1~5; is_done/has_alarm:0/1'

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
  step         integer [not null, default: 3] // 0=아침,1=낮,2=저녁,3=Anytime
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

