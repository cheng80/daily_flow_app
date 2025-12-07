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
- 네비게이션은 `CustomNavigationUtil.to` 사용 (기본 `Navigator.push()` 대신) ✅

### 4. 개발 작업 스타일 및 우선순위 ✅

**핵심 원칙: 기능 모듈 우선 개발, 화면 구성은 후순위** (1차 개발 완료)

이 프로젝트는 **화면 구성보다 기능 구현을 위한 모듈들을 먼저 개발**하는 방식을 따릅니다.

**현재 상태:** 모든 주요 기능 모듈 및 화면 구현 완료 ✅

#### 작업 순서

1. **기능 모듈 개발 (우선순위 높음)**

   - 화면 구성 전에 필요한 기능 모듈들을 먼저 구현
   - 예: `CustomCalendar`, `CustomCalendarPicker`, `StepMapperUtil`, `NotificationService` 등
   - 각 모듈은 독립적으로 동작할 수 있도록 설계

2. **테스트 페이지를 통한 검증**

   - 개발된 모듈은 `home_test_[기능명].dart` 형식의 테스트 페이지에서 검증
   - 테스트 페이지에서 모듈의 동작, 스타일, 테마 적용 등을 확인
   - 모든 기능이 정상 동작하는지 확인 후 다음 단계로 진행

3. **실제 디자인 페이지 구성 (후순위)** ✅ 완료
   - 모든 필요한 모듈이 완성되고 테스트 완료 후 진행
   - 실제 화면은 `lib/view/main_view.dart`, `lib/view/create_todo_view.dart` 등에 구현 ✅
   - 모든 주요 화면 구현 완료: 메인 화면, 일정 등록/수정, 삭제 보관함, Todo 상세보기

#### 작업 흐름 예시

```
1. TODO.md에서 우선순위 높은 기능 모듈 확인
   ↓
2. 기능 모듈 구현 (예: CustomCalendarPicker)
   ↓
3. 테스트 페이지 생성 (예: home_test_calendar_picker.dart)
   ↓
4. 테스트 페이지에서 모듈 동작 검증
   ↓
5. 필요시 수정 및 개선
   ↓
6. 모든 모듈 완성 후 → 실제 화면 구성 ✅ (완료됨)
```

#### 이 방식의 장점

- **모듈 단위 개발**: 각 기능을 독립적으로 개발하고 테스트 가능
- **재사용성**: 완성된 모듈은 여러 화면에서 재사용 가능
- **유연성**: 화면 구성 전에 모듈의 동작을 충분히 검증 가능
- **협업 효율**: 모듈 개발과 화면 구성을 분리하여 작업 효율 향상

#### 참고사항 ✅

- `lib/view/home.dart`는 모듈 테스트/프로토타이핑 용도로만 사용 ✅
- 실제 메인 화면은 `lib/view/main_view.dart`에서 별도 구현 ✅ (완료됨)
- 각 모듈 개발 완료 후 `home.dart`에서 테스트 ✅
- 테스트 페이지는 `lib/view/test_view/` 폴더에 위치 ✅
- **모든 주요 화면 구현 완료**: 메인 화면, 일정 등록/수정, 삭제 보관함, Todo 상세보기 ✅
- 향후 추가 기능 개발 시에도 동일한 방식 (모듈 → 테스트 → 화면 구성) 적용

### 5. 문서 기반 개발 워크플로우

모든 작업은 다음 프로세스를 따라야 합니다:

**작업 시작 전:**

1. 관련 설계 문서 확인 (`specs/dailyflow_design_spec.md`)
2. TODO 문서 확인 (`specs/TODO.md`) - 작업 항목 확인 (우선순위 확인)
3. REFERENCE 문서 확인 (`specs/REFERENCE.md`) - 개발 가이드라인 확인
4. 데이터베이스 스펙 확인 (`specs/daily_flow_db_spec.md`) - 필요 시

**작업 진행 중:**

- 문서의 요구사항과 일치하는지 확인하며 작업 진행
- 스펙과 불일치하는 부분 발견 시 문서 먼저 확인 및 수정
- 기능 모듈 개발 시 테스트 페이지에서 충분히 검증

**작업 완료 후:**

1. 문서 갱신 필요 여부 확인
2. 필요 시 관련 문서 업데이트:
   - **설계 문서** (`specs/dailyflow_design_spec.md`) - UI/UX 변경, 새로운 기능 추가 시
   - **TODO 문서** (`specs/TODO.md`) - 작업 완료 체크, 새 작업 추가 시
   - **REFERENCE 문서** (`specs/REFERENCE.md`) - 새로운 규칙, 정책, 가이드라인 추가 시
   - **PROGRESS 문서** (`specs/PROGRESS.md`) - 작업 완료 기록 시
   - **데이터베이스 스펙** (`specs/daily_flow_db_spec.md`) - DB 구조 변경 시

**⚠️ Git 커밋 전 필수 문서 갱신:**
Git에 커밋하기 전에는 반드시 다음 문서들을 확인하고 필요 시 갱신해야 합니다:

- **`specs/TODO.md`** - 완료된 작업 항목 체크, 새 작업 추가 여부 확인
- **`specs/PROGRESS.md`** - 완료된 작업 내용을 "완료된 작업" 섹션에 추가, 작업 일지 업데이트

이 규칙은 코드 변경사항과 문서의 동기화를 유지하고, 프로젝트 진행 상황을 정확히 추적하기 위한 필수 절차입니다.

**문서 갱신 체크리스트:**

- [ ] 작업 내용이 설계 문서의 요구사항과 일치하는가?
- [ ] 새로운 기능이나 변경사항이 문서에 반영되어야 하는가?
- [ ] TODO 항목이 완료되었는가?
- [ ] 새로운 규칙이나 정책이 추가되었는가?
- [ ] 다른 개발자가 이해할 수 있도록 문서가 충분히 업데이트되었는가?
- [ ] **Git 커밋 전: TODO.md 갱신 완료 (완료된 작업 체크, 새 작업 추가)**
- [ ] **Git 커밋 전: PROGRESS.md 갱신 완료 (완료된 작업 기록, 작업 일지 업데이트)**

---

## 📁 프로젝트 구조

```
lib/
├── model/                    # 데이터 모델
│   ├── todo_model.dart
│   └── deleted_todo_model.dart
├── vm/                       # 데이터베이스 관리
│   └── database_handler.dart
├── view/                     # 화면
│   ├── home.dart             # 테스트 페이지 라우팅용 인덱스
│   ├── main_view.dart        # 실제 메인 화면 ✅
│   ├── create_todo_view.dart # 일정 등록 화면 ✅
│   ├── edit_todo_view.dart   # 일정 수정 화면 ✅
│   ├── todo_detail_dialog.dart # Todo 상세보기 다이얼로그 ✅
│   ├── deleted_todos_view.dart # 삭제 보관함 화면 ✅
│   └── test_view/            # 테스트 페이지 폴더 ✅
│       ├── home_test_calendar.dart
│       ├── home_test_summary_bar.dart
│       ├── home_test_step_mapper.dart
│       ├── home_test_filter_radio.dart
│       ├── home_test_calendar_picker_dialog.dart
│       └── home_test_calendar_test.dart
├── app_custom/               # 앱 전용 커스텀 위젯
│   ├── custom_calendar.dart
│   ├── custom_calendar_picker.dart
│   ├── custom_filter_radio.dart
│   ├── custom_time_picker.dart
│   └── app_common_util.dart  # 앱 전용 공용 함수/클래스
├── service/                  # 서비스 ✅
│   └── notification_service.dart # 알람 서비스 ✅
├── util/                     # 유틸리티
│   ├── common_util.dart
│   └── step_mapper_util.dart
├── theme/                    # 테마
│   └── app_colors.dart
└── custom/                   # 커스텀 위젯 (기존)
    ├── custom_snack_bar.dart
    ├── custom_dialog.dart
    └── ...
```

---

## 🧪 테스트 페이지 구조

### 테스트 페이지 목적

- 새로 개발된 커스텀 위젯/함수를 빠르게 테스트
- 디자인 화면 작업 전 모듈 동작 확인
- 테마 색상 및 스타일 검증
- 각 모듈 개발 완료 후, 완성된 커스텀 모듈과 함수를 사용하여 실제 화면 구성

### 테스트 페이지 구조

#### 1. `home.dart` - 테스트 페이지 라우팅용 인덱스

- **역할**: 각 모듈별 테스트 페이지로 이동하는 라우팅 페이지
- **위치**: `lib/view/home.dart`
- **기능**:
  - 테스트 화면 선택 메뉴 제공
  - 각 모듈별 테스트 페이지로 이동하는 버튼 제공
  - 테마 토글 스위치 포함 (앱바)

#### 2. 모듈별 테스트 페이지

- **명명 규칙**: `home_test_[기능명].dart`
- **위치**: `lib/view/test_view/` 폴더
- **예시**:
  - `home_test_calendar.dart` - 캘린더 위젯 테스트 ✅
  - `home_test_summary_bar.dart` - 서머리바 테스트 ✅
  - `home_test_step_mapper.dart` - Step 매핑 유틸리티 테스트 ✅
  - `home_test_filter_radio.dart` - 필터 라디오 테스트 ✅
  - `home_test_calendar_picker_dialog.dart` - 날짜 선택 다이얼로그 테스트 ✅
  - `home_test_calendar_test.dart` - 캘린더 테스트 ✅

### 테스트 페이지 공통 구조

모든 테스트 페이지는 다음 구조를 따라야 합니다:

```dart
class HomeTest[기능명] extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTest[기능명]({super.key, required this.onToggleTheme});

  @override
  State<HomeTest[기능명]> createState() => _HomeTest[기능명]State();
}

class _HomeTest[기능명]State extends State<HomeTest[기능명]> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  @override
  void initState() {
    super.initState();
    _themeBool = false; // 기본값: 라이트 모드
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText(
          "[기능명] 테스트",
          style: TextStyle(color: p.textPrimary),
        ),
        actions: [
          Switch(
            value: _themeBool,
            onChanged: (value) {
              setState(() {
                _themeBool = value;
              });
              widget.onToggleTheme();
            },
          ),
        ],
      ),
      body: // 테스트 내용
    );
  }
}
```

### 테스트 페이지 작성 규칙

작업 순서에 따라 다음 단계를 진행합니다:

1. **명명 규칙 확인**:

   - 파일명: `home_test_[기능명].dart` (snake_case)
   - 클래스명: `HomeTest[기능명]` (PascalCase)
   - 예: `home_test_calendar.dart` → `HomeTestCalendar`

2. **필수 요소 구현**:

   - `onToggleTheme` 콜백 함수를 생성자 파라미터로 받음
   - `_themeBool` 상태 변수로 테마 모드 관리
   - 기본 위젯 구조 작성 (위의 "테스트 페이지 공통 구조" 참고)

3. **테마 토글 구현**:

   - 앱바의 `actions`에 `Switch` 위젯 추가
   - `Switch`의 `value`는 `_themeBool` 상태 사용
   - `onChanged`에서 `_themeBool` 업데이트 및 `widget.onToggleTheme()` 호출

4. **⚠️ home.dart에 자동 등록 (필수)**:
   - **새로운 테스트 페이지를 생성하면 반드시 `home.dart`에 버튼을 추가해야 합니다.**
   - 테스트 페이지 생성과 동시에 `home.dart`에 등록하는 것이 필수입니다.
   - 버튼은 `SizedBox(width: double.infinity)`와 `Padding(padding: EdgeInsets.symmetric(horizontal: 16.0))`로 감싸서 동일한 너비로 정렬
   - 버튼 클릭 시 `CustomNavigationUtil.to()`로 테스트 페이지로 이동 ✅
   - 등록하지 않으면 테스트 페이지에 접근할 수 없으므로 반드시 등록해야 합니다.

### 실제 메인 화면과의 관계 ✅

- **테스트 페이지**: 모듈 개발 및 검증용 (임시) - `lib/view/test_view/` 폴더에 위치
- **실제 메인 화면**: `lib/view/main_view.dart`에서 별도 구현 ✅ (완료됨)
- 각 모듈 개발 완료 후, 완성된 커스텀 모듈과 함수를 사용하여 실제 화면 구성 ✅
- 모든 주요 화면 구현 완료: 메인 화면, 일정 등록/수정, 삭제 보관함, Todo 상세보기

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

### 구조 개요

색상 시스템은 **공용 컬러**와 **앱 전용 컬러**로 분리되어 있습니다:

- **`CommonColorScheme`**: 다른 앱에서도 재사용 가능한 기본 컬러
- **`DailyFlowColorScheme`**: DailyFlow 앱 전용 컬러
- **`AppColorScheme`**: 두 스키마를 조합한 통합 컬러 스키마

이 구조를 통해 공용 컬러는 다른 앱에서도 재사용할 수 있으며, 앱 전용 컬러는 DailyFlow에만 존재합니다.

### 역할 기반 컬러 토큰

모든 색상은 역할 이름(Role Name)으로 관리되며, 라이트/다크 모드에 따라 자동으로 적절한 색상이 적용됩니다.

**공용 색상 (CommonColorScheme):**

- Background, CardBackground, Primary, Accent
- TextPrimary, TextSecondary, Divider
- ChipSelectedBg, ChipSelectedText
- ChipUnselectedBg, ChipUnselectedText

**앱 전용 색상 (DailyFlowColorScheme):**

- **Summary Bar 색상:**

  - ProgressMorning (오전) - 라이트: 주황색, 다크: 밝은 주황색
  - ProgressNoon (오후) - 라이트: 밝은 노란색, 다크: 밝은 노란색
  - ProgressEvening (저녁) - 라이트: 청록색, 다크: 밝은 청록색
  - ProgressNight (야간) - 라이트: 파란색 계열, 다크: 밝은 파란색 계열
  - ProgressAnytime (종일) - 라이트: 보라색, 다크: 밝은 보라색

- **중요도 색상:**
  - PriorityVeryLow (1단계: 매우 낮음) - 라이트: 회색, 다크: 밝은 회색
  - PriorityLow (2단계: 낮음) - 라이트: 파란색, 다크: 밝은 파란색
  - PriorityMedium (3단계: 보통) - 라이트: 초록색, 다크: 밝은 초록색
  - PriorityHigh (4단계: 높음) - 라이트: 주황색, 다크: 밝은 주황색
  - PriorityVeryHigh (5단계: 매우 높음) - 라이트: 빨간색, 다크: 밝은 빨간색

### 라이트/다크 모드 지원

`AppColorScheme`은 라이트 모드와 다크 모드를 모두 지원하며, `context.palette`를 통해 현재 테마에 맞는 색상이 자동으로 제공됩니다.

- **라이트 모드**: 밝은 배경에 어두운 텍스트, 선명한 색상 사용
- **다크 모드**: 어두운 배경에 밝은 텍스트, 다크 모드에 최적화된 밝은 색상 사용

### 사용 방법

```dart
final p = context.palette; // AppColorScheme 객체 접근
Container(
  color: p.background, // 공용 색상
  child: Text('Hello', style: TextStyle(color: p.textPrimary)),
)

// 앱 전용 색상 사용
Container(color: p.progressMorning) // Summary Bar
Container(color: p.priorityHigh) // 중요도 표시
```

### 파일 구조

색상 관련 파일은 `lib/theme/` 폴더에 다음과 같이 분리되어 있습니다:

- `common_color_scheme.dart` - 공용 컬러 스키마
- `daily_flow_color_scheme.dart` - 앱 전용 컬러 스키마
- `app_color_scheme.dart` - 통합 컬러 스키마 (조합 클래스)
- `app_colors.dart` - 팔레트 정의 및 모든 컬러 관련 요소 export
- `app_theme_mode.dart` - 테마 모드 enum
- `palette_context.dart` - BuildContext 확장 (context.palette)

기존 코드 호환성을 위해 `app_colors.dart`에서 모든 요소를 export하므로, 기존 import 경로는 그대로 사용할 수 있습니다.

---

## 🔢 Step (시간대 분류)

### Step 값

- `0`: 오전
- `1`: 오후
- `2`: 저녁
- `3`: 야간
- `4`: 종일 (기본값)

### 시간 → Step 자동 매핑 규칙 ✅ 구현 완료

- **오전 (0)**: 06:00 ~ 11:59
- **오후 (1)**: 12:00 ~ 17:59
- **저녁 (2)**: 18:00 ~ 23:59
- **야간 (3)**: 00:00 ~ 05:59
- **종일 (4)**: 시간 없음 (null) 또는 유효하지 않은 시간

**구현:** `lib/util/step_mapper_util.dart`의 `StepMapperUtil` 클래스 사용
- `mapTimeToStep(String? time)`: 시간 문자열을 Step 값으로 변환
- `stepToKorean(int step)`: Step 값을 한국어 문자열로 변환
- `stepToTimeRange(int step)`: Step 값에 해당하는 시간 범위 문자열 반환

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

## 🔔 알람 정책 ✅ 구현 완료

### 현재 정책 (1차 버전)

- 1 Todo당 최대 1개의 알람만 지원
- 알람 활성 조건: `has_alarm = 1` AND `time IS NOT NULL`
- 알람 스케줄링: `flutter_local_notifications` 사용
- 알람 서비스: `lib/service/notification_service.dart`의 `NotificationService` 클래스

### 알람 취소 시점

- Todo 삭제 시: 자동 취소
- 시간 변경 시: 기존 알람 취소 후 새 알람 등록
- `has_alarm`을 false로 변경 시: 알람 취소

### 알람 수정 시

- 기존 알람 취소 → 새 알람 등록

### 과거 알람 정리 기능 ✅

- **앱 시작 시**: 자동으로 과거 알람 정리 (`main.dart`에서 호출)
- **앱 포그라운드 복귀 시**: 자동으로 과거 알람 정리 (`WidgetsBindingObserver` 사용)
- **정리 대상**:
  - `hasAlarm=true`이고 `time`이 현재 시간보다 이전인 Todo
  - `notificationId`가 없는 경우도 포함 (알람 등록 실패한 경우)
- **정리 동작**:
  - 시스템 알람 취소 (notificationId가 있는 경우)
  - DB 상태 업데이트: `hasAlarm=false`, `notificationId=null`

### 향후 확장 계획

- 알람 테이블 분리 (1 Todo당 다수 알람 지원)
- 반복 규칙 추가 (매일/주중/매주 등)

---

## 🗑️ 삭제/복구 플로우 ✅ 구현 완료

### 소프트 삭제 (todo → deleted_todo)

1. `todo`에서 대상 레코드 SELECT
2. 같은 내용 + `original_id = todo.id`, `deleted_at = 현재 시각`으로 `deleted_todo`에 INSERT
3. 알람 `cancel(notification_id)` 자동 수행
4. `todo`에서 해당 레코드 DELETE

### 복구 (deleted_todo → todo) ✅

1. `deleted_todo`에서 복구 대상 SELECT
2. `todo`에 INSERT (새 id 부여)
3. 알람은 비활성화 상태로 복구 (`has_alarm = 0`, `notification_id = NULL`)
4. `deleted_todo`에서 해당 레코드 DELETE

### 완전 삭제 ✅

- `deleted_todo`에서 해당 레코드 DELETE
- 확인 다이얼로그 표시 (`CustomDialog` 사용)

### 삭제 보관함 화면 ✅

- **위치**: `lib/view/deleted_todos_view.dart`
- **기능**:
  - 삭제된 Todo 리스트 표시
  - 필터 라디오 (전체/오늘/7일/30일)
  - 정렬 기능 (시간순/중요도순)
  - 복구 기능 (Slidable 좌측)
  - 완전 삭제 기능 (Slidable 우측)
- **접근**: `MainView` Drawer에서 "삭제 보관함" 버튼으로 진입

---

## 🧭 네비게이션 ✅ 통일 완료

### 네비게이션 방식

- **⚠️ 필수**: `CustomNavigationUtil` 사용 (기본 `Navigator.push()` 제거)
- 모든 화면에서 `CustomNavigationUtil.to` 사용
- 모든 화면에서 `CustomNavigationUtil.back` 사용
- `main.dart`의 라우트 정의: `onGenerateRoute`로 변경하여 arguments 처리 가능

### CustomNavigationUtil 사용법

```dart
// 화면 이동
final result = await CustomNavigationUtil.to(
  context,
  CreateTodoView(
    initialDate: selectedDate,
    initialStep: selectedStep,
  ),
);

// 결과 확인
if (result == true) {
  // 데이터 갱신
  _refreshTodoList();
}

// 뒤로가기
CustomNavigationUtil.back(context, result: true);
```

### 화면 간 데이터 전달 예시

```dart
// 등록 화면으로 이동
final result = await CustomNavigationUtil.to(
  context,
  CreateTodoView(
    initialDate: selectedDate,
    initialStep: selectedStep,
  ),
);
if (result == true) {
  // 데이터 갱신
  _refreshTodoList();
}

// 수정 화면으로 이동
final result = await CustomNavigationUtil.to(
  context,
  EditTodoView(todo: selectedTodo),
);
if (result == true) {
  // 데이터 갱신
  _refreshTodoList();
}
```

### 이점

- 타입 안전성 향상
- 코드 일관성 확보
- 유지보수성 향상

---

## 📦 주요 패키지

### 필수 패키지

- `sqflite: ^2.4.2` - SQLite 데이터베이스
- `path: ^1.9.1` - 파일 경로 처리
- `shared_preferences: ^2.2.2` - 환경 설정 저장
- `flutter_local_notifications: ^19.5.0` - 로컬 알람 ✅
- `timezone: ^0.9.4` - 타임존 처리 (알람용) ✅
- `permission_handler: ^11.3.1` - 권한 처리 (알람 권한용) ✅
- `table_calendar: ^3.2.0` - 달력 위젯
- `flutter_slidable: ^4.0.3` - 슬라이드 액션

### 테스트용 패키지 (제거 예정)

- `sqflite_common_ffi: ^2.3.0` - 단위 테스트용 SQLite (데스크톱 환경)
  - **주의:** 나중에 제거 요청 시 `dev_dependencies`에서 제거 필요

### 사용하지 않는 패키지

- `get: ^4.7.3` - GetX (제거됨)

---

## 🐛 알려진 이슈 및 주의사항

### 현재 없음

- 알려진 버그 없음

### 주의사항

1. **날짜 형식**: 반드시 `YYYY-MM-DD` 형식을 사용하세요
2. **시간 형식**: 반드시 `HH:MM` 형식을 사용하세요
3. **Step 값**: 0~4 범위를 벗어나지 않도록 주의하세요 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
4. **Priority 값**: 1~5 범위를 벗어나지 않도록 주의하세요
5. **Context 사용**: CustomSnackBar/Dialog 사용 시 context.mounted 확인 필요
6. **로깅**: `print()` 대신 `AppLogger` 사용 필수
7. **네비게이션**: `Navigator.push()` 대신 `CustomNavigationUtil.to` 사용 필수

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

### 인라인 함수 지양 원칙

**⚠️ 핵심 규칙: 인라인 함수를 지양하고, 기능이 포함된 콜백은 모두 하단 함수 섹션으로 분리**

- 단순히 `setState()`만 호출하는 경우가 아니라면, 기능이 포함된 모든 콜백 함수는 인라인으로 작성하지 않고 하단의 함수 섹션에 로컬 함수로 분리합니다.
- 이는 코드 가독성, 유지보수성, 재사용성을 향상시키기 위한 필수 규칙입니다.

**예시:**

```dart
// ❌ 나쁜 예: 인라인 함수 사용
CustomButton(
  onCallBack: () {
    CustomNavigationUtil.to(
      context,
      CreateTodoView(
        onToggleTheme: widget.onToggleTheme,
        initialDate: _selectedDay,
      ),
    ).then((result) {
      if (result == true) {
        _loadCalendarEvents();
        _calculateSummaryRatios();
      }
    });
  },
)

// ✅ 좋은 예: 함수로 분리
CustomButton(
  onCallBack: _navigateToCreateTodo,
)

// 하단 함수 섹션에 정의
Future<void> _navigateToCreateTodo() async {
  final result = await CustomNavigationUtil.to(
    context,
    CreateTodoView(
      onToggleTheme: widget.onToggleTheme,
      initialDate: _selectedDay,
    ),
  );

  if (result == true) {
    _loadCalendarEvents();
    _calculateSummaryRatios();
  }
}
```

**적용 범위:**

- 위젯의 `onPressed`, `onCallBack`, `onChanged`, `onTap` 등의 콜백
- 네비게이션 로직이 포함된 경우
- 데이터 처리 로직이 포함된 경우
- 여러 단계의 작업이 포함된 경우
- 단순 `setState()` 호출만 있는 경우는 예외 (간단한 상태 변경만 있는 경우)

---

## 📝 로깅 시스템 ✅

### AppLogger 클래스

- **위치**: `lib/custom/util/log/custom_log_util.dart`
- **용도**: 전역 로깅 시스템으로 모든 `print()` 문을 대체

### 로그 레벨

- `AppLogger.d(String message, {String? tag})`: 디버그 로그
- `AppLogger.i(String message, {String? tag})`: 정보 로그
- `AppLogger.w(String message, {String? tag, Object? error})`: 경고 로그
- `AppLogger.e(String message, {String? tag, Object? error, StackTrace? stackTrace})`: 에러 로그
- `AppLogger.s(String message, {String? tag})`: 성공 로그

### 출력 정책

- **디버그 모드**: 모든 로그 레벨 출력
- **릴리즈 모드**: 
  - 기본적으로 로그 비활성화
  - 에러 로그만 선택적 출력 (`_enableReleaseErrorLogs` 플래그로 제어)

### 사용 예시

```dart
// 기본 사용
AppLogger.d('디버그 메시지');
AppLogger.i('정보 메시지');
AppLogger.w('경고 메시지');
AppLogger.e('에러 발생', error: exception, stackTrace: stackTrace);
AppLogger.s('작업 완료');

// 태그와 함께 사용 (권장)
AppLogger.d('알람 등록 시작', tag: 'Notification');
AppLogger.e('알람 등록 실패', tag: 'Notification', error: e);

// 릴리즈 빌드에서 로그 확인
// Android: adb logcat | grep ERROR
// iOS: Xcode Console에서 디바이스 연결 후 확인
```

### 주의사항

- ⚠️ **필수**: 모든 `print()` 문을 `AppLogger`로 교체
- 태그 사용을 통해 로그 분류 및 필터링 용이
- 릴리즈 빌드에서도 에러 추적을 위해 에러 로그는 출력 가능

---

## ⚙️ 설정 기능 ✅

### 설정 방식

- 별도 설정 화면 없음
- `MainView` Drawer에 설정 기능 통합

### Drawer 메뉴 항목

1. **라이트/다크 모드 토글**
   - Switch 위젯으로 테마 전환
   - 설정은 `SharedPreferences`에 자동 저장

2. **삭제 보관함**
   - 삭제된 Todo 리스트 화면으로 이동
   - `deleted_todos_view.dart` 화면 표시

### 향후 확장 가능 항목

- 알람 기본 설정
- 알림 소리 설정
- 데이터 백업/복원

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

- **⚠️ 중요**: `print()` 문 대신 `AppLogger` 사용
- 로깅 시스템: `lib/custom/util/log/custom_log_util.dart`의 `AppLogger` 클래스
- 로그 레벨:
  - `AppLogger.d()`: 디버그 로그 (디버그 모드에서만 출력)
  - `AppLogger.i()`: 정보 로그 (디버그 모드에서만 출력)
  - `AppLogger.w()`: 경고 로그 (디버그 모드에서만 출력)
  - `AppLogger.e()`: 에러 로그 (디버그 모드 + 릴리즈 모드에서 출력 가능)
  - `AppLogger.s()`: 성공 로그 (디버그 모드에서만 출력)
- 태그 기반 로그 분류 지원: `AppLogger.d('메시지', tag: 'TagName')`
- 릴리즈 빌드에서 에러 로그 확인:
  - Android: `adb logcat | grep ERROR`
  - iOS: Xcode Console에서 디바이스 연결 후 확인
- 데이터베이스 경로는 초기화 시 출력됨
- Model 클래스의 `toString()` 메서드 활용

---

**마지막 업데이트:** 2024년 12월 (알람 기능, 로깅 시스템, 주석 개선, 삭제 보관함 화면 구현 완료)
