# DailyFlow 앱 – 화면 설계 문서 (Wireframe Design Specification)

---

## 0. 개요

DailyFlow 앱은 **애플 리마인더(Apple Reminders)를 기반으로 한 최소한의 핵심 기능만 제공하는 간단한 Todo 앱**이다.

### 디자인 철학

애플 리마인더의 핵심 기능만 추려서 구현:
- **간단함**: 불필요한 기능 제거, 핵심 기능에 집중
- **직관성**: 사용자가 바로 이해할 수 있는 UI
- **일관성**: 애플 리마인더와 유사한 사용자 경험

### 핵심 기능

1. **할 일 추가**: 제목, 메모, 날짜, 시간, 알람 설정
2. **완료 체크**: 체크박스로 완료/미완료 토글
3. **날짜별 보기**: 달력에서 날짜 선택하여 해당 날짜의 할 일 확인
4. **중요도 표시**: 플래그(중요/일반) 또는 중요도 색상
5. **삭제**: 할 일 삭제 및 삭제 보관함에서 복구 가능

### 화면 구성

총 3개의 주요 화면으로 구성된다:

- 메인 화면(Main View) – 달력 + 할 일 리스트
- 할 일 등록 화면(Create Todo)
- 할 일 수정 화면(Edit Todo)

> **제외된 기능:**
> - Summary Bar (시간대 비율 표시)
> - Filter Radio/Chips (시간대 필터)
> - 통계 기능
> - 범위 선택 기능
> - 하루 Flow 상세 화면 (메인 화면에서 충분)

---

# 1. 메인 화면 – Main View (달력 + 날짜 요약)

## 1.1 전체 레이아웃 구조

```
[AppBar]
[Monthly Calendar]
[Todo List (Checkbox + Slidable)]
[Floating Action Button]
```

## 1.2 AppBar

- 제목: **DailyFlow**
- 가운데 정렬
- 우측 액션:
  - ⭐ Today 버튼 → 오늘 날짜로 이동 (선택 사항)

## 1.3 Monthly Calendar 영역 (TableCalendar 기반)

- 화면 상단 40\~45% 차지
- 구성:
  - 월/연도 헤더
  - 요일 헤더
  - 날짜 Grid (7×6)

### 날짜 셀 요소

- 좌상단: 날짜 숫자
- 우측 하단: 일정 갯수 원형 배지
- 선택 상태: 배경 강조 + 테두리
- 오늘: 파란색 테두리 표시

### 날짜 탭 이벤트

- 선택된 날짜 업데이트
- Todo List 갱신

## 1.4 Todo List (체크박스 + Slidable)

각 Todo 항목은 카드 형태로 나열되며 아래 구성으로 이루어짐:

```
[Checkbox]  제목
            메모(있을 경우)
----------------------------------------
Slidable:  왼쪽 → 삭제 / 오른쪽 → 수정
```

- 체크 시 즉시 완료 처리
- 삭제/수정은 Slidable 제스처로 처리
- 시간 정보가 있을 경우 우측 정렬로 표시

---

## 1.5 Floating Action Button (FAB)

- 우측 하단 고정
- 아이콘: +
- 동작:
  - Todo 등록 화면으로 이동
  - 현재 선택된 날짜 정보 전달

---

# 2. 일정 등록 화면 – Create Todo

> **이 화면은 항상 새 페이지로 이동한다.** 메인 화면에서 날짜·카테고리·기본 선택값 등을 아규먼트로 전달하고, `Navigator.push().then()` 으로 저장 결과를 받아 메인 화면을 갱신한다.

## 2.1 레이아웃

```
[AppBar: 일정 등록]
[날짜 선택 영역 (수정 가능)]
[시간 선택 영역 (Picker)]
[제목 입력]
[메모 입력]
[중요도 선택]
[알람 설정]
[저장 버튼]
```

## 2.2 요소 상세

### 날짜 선택 (수정 가능)

- 기본값: 메인 화면에서 전달된 날짜
- 사용자가 탭하면 달력(DatePicker) 또는 풀스크린 달력 UI가 팝업됨
- 선택된 날짜는 즉시 갱신됨

### 시간 선택

- TimePicker(시·분 선택)
- 선택 사항 (알람 설정 시 필요)

### 제목 입력

- TextField
- placeholder: "제목 입력 (최대 50자)"
- 필수 입력
- 최대 50자 제한

### 메모 입력

- 멀티라인 TextField (높이 약 120px)
- 최대 200자 제한

### 중요도 선택 (선택 사항)

- 옵션 1: 플래그 (중요/일반) - 애플 리마인더 스타일
  - Switch 또는 별표 아이콘 버튼
  - 중요: 별표 아이콘 표시
  - 일반: 별표 없음
- 옵션 2: 중요도 드롭다운 (1~5단계)
  - 기본값: 일반 (중요도 없음 또는 3단계)

### 알람 설정

- Switch 위젯
- 시간이 선택된 경우에만 활성화 가능
- 알람 활성 시 해당 시간에 알림 표시

### 저장 버튼

- 너비 100%
- 높이 48px
- 저장 후 pop 및 데이터 갱신

---

# 3. 일정 수정 화면 – Edit Todo

> **항상 새 페이지로 이동한다.** 선택된 Todo 객체 전체를 아규먼트로 전달하고, 수정 또는 삭제 후 `Navigator.pop(result)` 를 호출하여 메인 화면 또는 상세 화면이 해당 결과를 반영하도록 설계한다.

등록 화면과 동일하나 요소 추가됨:

### 추가 요소

- 삭제 버튼 (테두리 빨간색)
- 삭제 시 확인 Dialog 표시

---

# 4. Todo 상세보기 (팝업)

> **메인 화면의 Todo 카드를 탭하면 팝업으로 표시된다.** 애플 리마인더와 유사하게 다이얼로그 형태로 구현한다.

## 4.1 개요

- 이 화면은 기존 메인 화면과 동일한 데이터를 단순 반복하는 것이 아니라, **개별 일정의 세부 확인·메모 확인·중요도 정보·빠른 수정 기능**을 제공하는 목적의 화면으로 정의한다.
- 메인 화면 = “할 일 처리 중심”
- 상세 화면 = “할 일 정보 확인·편집 중심”

---

## 4.2 상세보기 다이얼로그 구성

```
[제목]
[날짜]
[시간 (있을 경우)]
[중요도 표시 (별표 또는 색상)]
[메모 전체 내용]
[알람 정보 (있을 경우)]
----------------------------------
[수정 버튼]
[삭제 버튼]
```

### 기능

- 수정 버튼 → 할 일 수정 화면으로 이동
- 삭제 버튼 → 삭제 확인 다이얼로그 → 삭제
- 팝업 외부 탭 → 팝업 닫기

**파일 위치:** `lib/view/todo_detail_dialog.dart`

---

# 5. 데이터 흐름 요약

- 메인 화면:
  - 날짜 선택 시 SQLite에서 Todo 불러오기 → 리스트 갱신
- 등록 화면:
  - 새로운 Todo INSERT 후 `Navigator.pop(result)` 로 메인/상세 화면 갱신
- 수정 화면:
  - UPDATE 또는 삭제 플래그 설정 후 `Navigator.pop(result)`
- 상세보기 팝업:
  - Todo 카드 탭 → 상세 정보 팝업 표시
  - 수정/삭제 → 메인 화면 갱신
- 삭제 처리:
  - 활성 Todo 테이블에서 제거하기 전, 별도의 삭제 보관 테이블에 INSERT (소프트 삭제)

---

# 6. 삭제 보관함 화면 – Deleted Todos / Trash

> 애플 리마인더와 동일하게 삭제된 할 일을 보관하고 복구할 수 있는 기능을 제공한다.

## 6.1 데이터베이스 구조 (추가 테이블)

별도의 삭제 전용 테이블을 사용한다. 예시: `deleted_todo` 테이블

컬럼 예:

- id (PRIMARY KEY)
- original\_id (원래 Todo id, 선택 사항)
- title
- memo
- date
- time (nullable)
- priority (중요도, 1\~5단계)
- is\_done (삭제 시점 완료 여부)
- deleted\_at (삭제 일시)

삭제 처리 시 플로우:

1. 활성 `todo` 테이블에서 삭제 대상 레코드를 SELECT
2. 해당 레코드를 `deleted_todo` 테이블에 INSERT (deleted\_at 포함)
3. 활성 `todo` 테이블에서 실제 DELETE 수행

복구 처리 시 플로우:

1. `deleted_todo` 테이블에서 선택된 레코드를 가져온다.
2. 활성 `todo` 테이블에 INSERT (필요 시 새로운 id 부여)
3. `deleted_todo` 테이블에서 해당 레코드를 DELETE

완전 삭제:

- `deleted_todo` 테이블에서 DELETE

---

## 6.2 삭제 보관함 화면 레이아웃

```
[AppBar: 삭제된 일정]
[필터: 전체 / 오늘 / 7일 / 30일]
[삭제된 Todo 리스트]
```

각 카드 구성:

- 제목
- 날짜 + 시간
- 중요도 표시 (별표 또는 색상)
- 삭제 일시 (deleted\_at)
- Slidable 액션:
  - 좌측: 복구 (Restore)
  - 우측: 완전 삭제 (Delete Permanently)

---

## 6.3 네비게이션

- 메인 화면 또는 설정/메뉴에서 "삭제된 일정" 버튼을 통해 진입
- 별도 페이지로 Push
- 복구/완전 삭제 수행 후 `Navigator.pop(result)` 로 상위 화면에 결과 전달 (선택 사항)

---

# 7. 알람 정책 및 확장 계획

## 7.1 1차 버전 알람 정책

- **1 Todo당 최대 1개의 알람만 지원**한다.
- 알람 활성 조건:
  - 사용자가 "시간 선택" 영역에서 실제 시간을 선택한 경우에만 알람을 활성화한다.
  - 시간이 비어 있으면 알람은 비활성 상태로 취급한다.
- 알람 관련 필드는 `todo` 테이블에 함께 포함하는 것을 기본 구조로 한다. (예: has\_alarm, notification\_id)
- 알람 스케줄링은 `flutter_local_notifications` 를 사용하여 구현한다.

## 7.2 향후 고도화 시 알람 확장 계획

- 알람 테이블을 별도로 분리하여 **1 Todo당 다수의 알람**을 지원하는 구조로 확장할 수 있다.
  - 예: 사전 알람(하루 전), 직전 알람(1시간 전), 정확한 시간 알람 등 다중 알림
- 반복 규칙(매일/주중/매주 등)을 위한 `repeat_rule` 필드를 추가하는 확장도 고려 대상이다.
- 현재 문서에서는 1차 버전 범위로 **단일 알람 + 시간 선택 시 자동 활성**까지만 구현 대상으로 한다.

이 설계까지 포함하여, DailyFlow 앱은 활성 일정과 삭제된 일정, 그리고 단일 알람 기반의 시간 관리 기능을 가진다.

---

# 8. 로컬라이징(Localization) 정책

> **현재 MVP 개발 범위에서는 다국어 지원을 완전히 제외한다.** 언어 변경 · 번역 리소스 분리 · 국제화(i18n) 구조는 **추후 고도화 단계에서 고려**한다.

## 8.1 제외 사유

- 개발 범위 최소화
- 핵심 기능(일정 관리 · 알람 · 삭제 보관함)에 집중
- 텍스트 수가 많지 않아 구조화 필요성 낮음

## 8.2 향후 고도화 시 도입 방향 (참고)

- GetX Translations 또는 easy\_localization 기반 확장 가능
- 문자열 KEY-Value 구조로 분리하여 JSON/ARB 파일 관리
- 기본 언어: 한국어 → 향후 영어 등 확대 가능

※ 본 버전에서는 로컬라이징 관련 코드/구조를 전혀 포함하지 않음.

---

# 9. 설정 화면 – 라이트/다크 모드 토글(고려 사항)

> 본 MVP에서는 상태관리 라이브러리를 사용하지 않고, 최상위 Stateful 위젯에서 `ThemeMode`를 관리하는 단순 구조를 사용한다. UI 관점에서만, **설정 화면에서 라이트/다크 모드를 전환할 수 있음**을 명시한다.

## 9.1 설정 화면 역할

- 라이트 모드 / 다크 모드 전환 스위치 제공
- 추후 확장 시 아래 항목도 함께 배치 가능:
  - 삭제 보관함 진입 버튼
  - 알람 기본 설정
  - 기타 앱 환경 설정

## 9.2 테마 토글 UX

- 설정 화면에 `다크 모드` 토글 스위치 1개 제공
- ON: 다크 모드 / OFF: 라이트 모드
- 시스템 테마 연동(ThemeMode.system)은 고도화 시점에 고려 가능

※ 본 문서에서는 **테마 토글이 설정 화면에서 제공된다**는 UX 수준만 정의하며, 구체적인 상태관리 구현 방식(GetX/Provider/Riverpod 등)은 범위에서 제외한다.

## 9.3 디자인 토큰(Color Tokens) – 컬러 팔레트 기반 UI 규칙

DailyFlow 앱의 모든 UI 색상은 "역할 기반(Role-based) 컬러 시스템"으로 정의하며, 앱 전역에서 일관성 있게 사용한다. 컬러 정의는 Dart 코드의 `AppColorScheme` (라이트/다크 팔레트)에서 관리하며, 화면 설계서는 색상을 **역할 이름(Role Name)** 기준으로만 기록한다.

### 9.3.1 주요 색상 역할 정의

아래 표는 기존 역할 기반 토큰에 **중요도(1~5단계) 색상 역할(Priority Tokens)** 을 추가 반영한 버전이다.

| 역할(Role)                 | 설명                          | AppColorScheme 필드         |
|---------------------------|-------------------------------|-----------------------------|
| Background                | 전체 화면 배경                | `background`                |
| CardBackground            | 카드/패널/앱바 배경           | `cardBackground`            |
| Primary                   | 주요 액션·선택 강조           | `primary`                   |
| Accent                    | 보조/보틀 액션 강조           | `accent`                    |
| TextPrimary               | 기본 텍스트                  | `textPrimary`               |
| TextSecondary             | 보조 텍스트                  | `textSecondary`             |
| Divider                   | 구분선                       | `divider`                   |
| ChipSelectedBg            | 선택된 필터 칩 배경           | `chipSelectedBg`            |
| ChipSelectedText          | 선택된 필터 칩 텍스트         | `chipSelectedText`          |
| ChipUnselectedBg          | 비선택 필터 칩 배경           | `chipUnselectedBg`          |
| ChipUnselectedText        | 비선택 필터 칩 텍스트         | `chipUnselectedText`        |
| **PriorityVeryLow**       | 중요도 1단계(매우 낮음)       | `priorityVeryLow`           |
| **PriorityLow**           | 중요도 2단계(낮음)           | `priorityLow`               |
| **PriorityMedium**        | 중요도 3단계(보통)           | `priorityMedium`            |
| **PriorityHigh**          | 중요도 4단계(높음)           | `priorityHigh`              |
| **PriorityVeryHigh**      | 중요도 5단계(매우 높음)       | `priorityVeryHigh`          |

> ※ 이 토큰들은 문서 4.4 (상세 리스트) / 6.2 (삭제 보관함 화면)에서 사용되는 **중요도 색상 정보**와 1:1 대응되도록 설계되었다.


| 역할(Role)           | 설명                     | AppColorScheme 필드    |
| ------------------ | ---------------------- | -------------------- |
| Background         | 전체 화면 배경               | `background`         |
| CardBackground     | 카드/패널/앱바 배경            | `cardBackground`     |
| Primary            | 주요 액션·선택 강조            | `primary`            |
| Accent             | 보조/보틀 액션 강조            | `accent`             |
| TextPrimary        | 기본 텍스트                 | `textPrimary`        |
| TextSecondary      | 보조 텍스트                 | `textSecondary`      |
| Divider            | 구분선                    | `divider`            |
| ChipSelectedBg     | 선택된 필터 칩 배경            | `chipSelectedBg`     |
| ChipSelectedText   | 선택된 필터 칩 텍스트           | `chipSelectedText`   |
| ChipUnselectedBg   | 선택되지 않은 필터 칩 배경        | `chipUnselectedBg`   |
| ChipUnselectedText | 선택되지 않은 필터 칩 텍스트       | `chipUnselectedText` |

이 표에 나온 역할 이름만을 UI 문서에 사용하며, 실제 색상 값(hex, ARGB 등)은 코드 레벨에서 관리한다.

### 9.3.2 문서 내 색상 표기 규칙

화면 설계 문서에서 색상은 **역할 이름**으로만 기재한다. 예를 들면:

- "배경색: Background"
- "카드 배경: CardBackground"
- "제목 텍스트: TextPrimary"
- "서브 텍스트: TextSecondary"
- "필터 칩(선택): ChipSelectedBg / ChipSelectedText"
- "필터 칩(비선택): ChipUnselectedBg / ChipUnselectedText"

이렇게 기록해 두면, 나중에 팔레트 색상(hex 값)을 변경하더라도 문서는 그대로 두고 코드만 수정해도 전체 UI 테마가 바뀌는 구조를 유지할 수 있다.

## 9.4 컬러 팔레트 사용 방법 (Dart 코드 연동 개요)

실제 Flutter 코드에서는 **BuildContext 확장**을 통해 현재 팔레트에 접근한다. 예시:

```dart
final p = context.palette; // AppColorScheme

// 배경색 적용
Scaffold(
  backgroundColor: p.background,
  appBar: AppBar(
    backgroundColor: p.cardBackground,
    title: Text(
      'DailyFlow',
      style: TextStyle(color: p.textPrimary),
    ),
  ),
  body: ...,
);
```

필터 칩 예시:

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: selected ? p.chipSelectedBg : p.chipUnselectedBg,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: selected ? p.chipSelectedText : p.chipUnselectedText,
    ),
  ),
);
```

이 문서에서 정의하는 모든 색상 요구사항은 **역할 이름(Role) 기준**으로만 유지되며, 실제 색상 값과 다크/라이트 전환 로직은 `AppColorScheme` / `AppColors` / `context.palette` 구현에서 처리한다.

### 9.4.1 라이트/다크 모드 색상 전략

`AppColorScheme`은 라이트 모드와 다크 모드를 모두 지원하며, 각 모드에 최적화된 색상을 제공합니다:

**라이트 모드 특징:**
- 밝은 배경 (`Color(0xFFF5F5F5)`)과 순수 흰색 카드 배경
- 어두운 텍스트 (`Color(0xFF212121)`)로 가독성 확보
- Material Design 가이드라인에 맞는 진한 Primary 색상 (`Color(0xFF1976D2)`)

**다크 모드 특징:**
- Material Dark 배경 (`Color(0xFF121212)`)과 어두운 카드 배경
- 밝은 텍스트 (`Color(0xFFFFFFFF)`)로 가독성 확보
- 다크 모드에 최적화된 밝은 Primary 색상 (`Color(0xFF90CAF9)`)
- 칩 선택 텍스트는 흰색으로 설정하여 가독성 향상

모든 색상은 `context.palette`를 통해 현재 테마 모드에 맞게 자동으로 제공되므로, 코드에서 별도의 분기 처리가 필요하지 않습니다.

