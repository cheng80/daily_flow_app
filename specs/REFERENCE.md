# DailyFlow 앱 - 참고사항 문서

이 문서는 DailyFlow 앱 개발 시 참고할 중요한 사항들을 정리합니다.

---

## 🎯 핵심 설계 원칙

### 1. 스펙 문서 준수
- 모든 구현은 `daily_flow_db_spec.md`와 `dailyflow_design_spec.md`를 기반으로 합니다
- 스펙 문서와 불일치하는 경우 반드시 문서를 먼저 확인하세요

### 2. 커스텀 위젯 우선 사용
- 기본 Flutter 위젯 대신 `lib/custom/` 폴더의 커스텀 위젯을 우선 사용합니다
- `lib_doc/` 폴더의 문서를 참고하여 사용법을 확인하세요
- SnackBar는 `CustomSnackBar`, Dialog는 `CustomDialog` 사용

### 3. 상태 관리
- GetX는 사용하지 않습니다
- 순수 Flutter (StatefulWidget)를 사용합니다
- 네비게이션은 `Navigator.push()` 사용

---

## 📁 프로젝트 구조

```
lib/
├── model/                    # 데이터 모델
│   ├── todo_model.dart
│   └── deleted_todo_model.dart
├── vm/                       # 데이터베이스 관리
│   └── database_handler.dart
├── view/                     # 화면 (구현 예정)
│   ├── main/
│   ├── create_todo/
│   ├── edit_todo/
│   ├── day_detail/
│   └── deleted_todos/
├── service/                  # 서비스 (구현 예정)
│   └── notification_service.dart
├── util/                     # 유틸리티 (구현 예정)
│   └── step_mapper_util.dart
├── theme/                    # 테마
│   └── app_colors.dart
└── custom/                   # 커스텀 위젯 (기존)
    ├── custom_snack_bar.dart
    ├── custom_dialog.dart
    └── ...
```

---

## 🗄️ 데이터베이스 구조

### 테이블

#### todo 테이블
- 활성 일정 저장용 메인 테이블
- 컬럼: id, title, memo, date, time, step, priority, is_done, has_alarm, notification_id, created_at, updated_at
- 인덱스: idx_todo_date, idx_todo_date_step

#### deleted_todo 테이블
- 삭제된 일정 보관용 테이블 (휴지통)
- 컬럼: id, original_id, title, memo, date, time, step, priority, is_done, deleted_at
- 인덱스: idx_deleted_todo_date, idx_deleted_todo_deleted_at

### 데이터 타입 매핑
- INTEGER → int (Dart)
- TEXT → String (Dart)
- BOOLEAN → INTEGER (0/1) → bool (Dart)

### 날짜/시간 형식
- 날짜: `YYYY-MM-DD` (예: '2024-01-15')
- 시간: `HH:MM` (예: '14:30')
- 날짜시간: `YYYY-MM-DD HH:MM:SS` (예: '2024-01-15 14:30:00')

---

## 🎨 색상 시스템

### 역할 기반 컬러 토큰
모든 색상은 역할 이름(Role Name)으로 관리됩니다.

**기본 색상:**
- Background, CardBackground, Primary, Accent
- TextPrimary, TextSecondary, Divider

**필터 칩 색상:**
- ChipSelectedBg, ChipSelectedText
- ChipUnselectedBg, ChipUnselectedText

**Summary Bar 색상:**
- ProgressMorning (아침)
- ProgressNoon (낮)
- ProgressEvening (저녁)
- ProgressAnytime (Anytime)

**중요도 색상 (추가 필요):**
- PriorityVeryLow (1단계: 매우 낮음)
- PriorityLow (2단계: 낮음)
- PriorityMedium (3단계: 보통)
- PriorityHigh (4단계: 높음)
- PriorityVeryHigh (5단계: 매우 높음)

### 사용 방법
```dart
final p = context.palette; // AppColorScheme 객체 접근
Container(
  color: p.background,
  child: Text('Hello', style: TextStyle(color: p.textPrimary)),
)
```

---

## 🔢 Step (시간대 분류)

### Step 값
- `0`: 아침
- `1`: 낮
- `2`: 저녁
- `3`: Anytime (기본값)

### 시간 → Step 자동 매핑 규칙 (제안)
- **아침 (0)**: 06:00 ~ 11:59
- **낮 (1)**: 12:00 ~ 17:59
- **저녁 (2)**: 18:00 ~ 23:59
- **Anytime (3)**: 00:00 ~ 05:59 (새벽) 또는 시간 없음

**참고:** 이 규칙은 차후 조정 가능합니다.

---

## ⭐ Priority (중요도)

### Priority 값
- `1`: 매우 낮음 (회색)
- `2`: 낮음 (파랑)
- `3`: 보통 (초록) - 기본값
- `4`: 높음 (주황)
- `5`: 매우 높음 (빨강)

### UI 표시
- 카드 좌측 상단에 색상 라벨(●)로 표시
- 색상은 `AppColorScheme`의 Priority 색상 사용

---

## 🔔 알람 정책

### 현재 정책 (1차 버전)
- 1 Todo당 최대 1개의 알람만 지원
- 알람 활성 조건: `has_alarm = 1` AND `time IS NOT NULL`
- 알람 스케줄링: `flutter_local_notifications` 사용

### 알람 취소 시점
- Todo 삭제 시
- 시간 변경 시 (기존 알람 취소 후 재등록)
- `has_alarm`을 false로 변경 시

### 알람 수정 시
- 기존 알람 취소 → 새 알람 등록

### 향후 확장 계획
- 알람 테이블 분리 (1 Todo당 다수 알람 지원)
- 반복 규칙 추가 (매일/주중/매주 등)

---

## 🗑️ 삭제/복구 플로우

### 소프트 삭제 (todo → deleted_todo)
1. `todo`에서 대상 레코드 SELECT
2. 같은 내용 + `original_id = todo.id`, `deleted_at = 현재 시각`으로 `deleted_todo`에 INSERT
3. 필요 시 알람 `cancel(notification_id)` 수행
4. `todo`에서 해당 레코드 DELETE

### 복구 (deleted_todo → todo)
1. `deleted_todo`에서 복구 대상 SELECT
2. `todo`에 INSERT (새 id 부여)
3. 알람은 비활성화 상태로 복구 (필요 시 사용자가 재설정)
4. `deleted_todo`에서 해당 레코드 DELETE

### 완전 삭제
- `deleted_todo`에서 해당 레코드 DELETE
- 확인 다이얼로그 표시 권장

---

## 🧭 네비게이션

### 네비게이션 방식
- `Navigator.push()` 사용 (GetX 미사용)
- 결과 반환: `Navigator.push().then((result) => {})`
- 데이터 전달: 생성자 파라미터로 전달

### 화면 간 데이터 전달 예시
```dart
// 등록 화면으로 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreateTodoView(
      date: selectedDate,
      step: selectedStep,
    ),
  ),
).then((result) {
  if (result == true) {
    // 데이터 갱신
    _refreshTodoList();
  }
});

// 수정 화면으로 이동
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditTodoView(todo: selectedTodo),
  ),
).then((result) {
  if (result == true) {
    // 데이터 갱신
    _refreshTodoList();
  }
});
```

---

## 📦 주요 패키지

### 필수 패키지
- `sqflite: ^2.4.2` - SQLite 데이터베이스
- `path: ^1.9.1` - 파일 경로 처리
- `shared_preferences: ^2.2.2` - 환경 설정 저장
- `flutter_local_notifications: ^19.5.0` - 로컬 알람
- `table_calendar: ^3.2.0` - 달력 위젯
- `flutter_slidable: ^4.0.3` - 슬라이드 액션
- `geekyants_flutter_gauges: ^1.0.4` - Summary Bar

### 사용하지 않는 패키지
- `get: ^4.7.3` - GetX (제거됨)

---

## 🐛 알려진 이슈 및 주의사항

### 현재 없음
- 알려진 버그 없음

### 주의사항
1. **날짜 형식**: 반드시 `YYYY-MM-DD` 형식을 사용하세요
2. **시간 형식**: 반드시 `HH:MM` 형식을 사용하세요
3. **Step 값**: 0~3 범위를 벗어나지 않도록 주의하세요
4. **Priority 값**: 1~5 범위를 벗어나지 않도록 주의하세요
5. **Context 사용**: CustomSnackBar/Dialog 사용 시 context.mounted 확인 필요

---

## 📝 코딩 컨벤션

### 네이밍
- 파일명: snake_case (예: `todo_model.dart`)
- 클래스명: PascalCase (예: `Todo`, `DatabaseHandler`)
- 변수/메서드명: camelCase (예: `queryData`, `isDone`)
- 상수: lowerCamelCase 또는 UPPER_SNAKE_CASE

### 주석
- 모든 클래스, 메서드, 주요 변수에 한국어 주석 작성
- 목적과 역할을 명확히 설명
- 파라미터와 반환값 설명 포함

### 코드 스타일
- Dart 공식 스타일 가이드 준수
- `dart format` 실행 권장
- 린터 에러 해결 필수

---

## 🔗 관련 문서

- `daily_flow_db_spec.md` - 데이터베이스 스펙
- `dailyflow_design_spec.md` - 화면 설계 스펙
- `PROGRESS.md` - 진행 상황 문서
- `TODO.md` - 할 일 목록
- `lib_doc/README.md` - 커스텀 위젯 문서

---

## 💡 개발 팁

### 데이터베이스 작업
- `DatabaseHandler`는 싱글톤 패턴으로 사용 가능
- 모든 메서드는 비동기(`Future`)로 구현됨
- 에러 처리는 try-catch로 처리

### UI 작업
- `context.palette`로 색상 접근
- 커스텀 위젯 사용 시 `lib_doc/` 문서 참고
- 다국어는 MVP에서 제외 (DatePicker 한글 표시용으로만 사용)

### 디버깅
- `print()` 문으로 로그 출력
- 데이터베이스 경로는 초기화 시 출력됨
- Model 클래스의 `toString()` 메서드 활용

---

**마지막 업데이트:** 2024년 (최근 작업 기준)

