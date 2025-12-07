# DailyFlow 앱 - 진행 상황 문서

이 문서는 DailyFlow 앱 개발의 진행 상황을 추적합니다.

---

## 📋 완료된 작업

### 1. 데이터베이스 설계 및 구현 ✅

#### 1.1 Model 클래스 생성

- ✅ `lib/model/todo_model.dart` - 활성 일정 모델 클래스
  - 스펙 문서 `daily_flow_db_spec.md`의 todo 테이블 구조 기반
  - `fromMap()`, `toMap()`, `copyWith()`, `createNew()` 메서드 구현
  - 상세한 한국어 주석 포함
- ✅ `lib/model/deleted_todo_model.dart` - 삭제된 일정 모델 클래스
  - 스펙 문서 `daily_flow_db_spec.md`의 deleted_todo 테이블 구조 기반
  - `fromMap()`, `toMap()`, `fromTodo()`, `copyWith()` 메서드 구현
  - 상세한 한국어 주석 포함

#### 1.2 DatabaseHandler 구현

- ✅ `lib/vm/database_handler.dart` - 데이터베이스 관리 클래스
  - GetX 제거 완료 (순수 Flutter로 전환)
  - CustomSnackBar/Dialog 통합
  - 스펙 문서 기준 테이블 구조 구현
  - 인덱스 4개 생성 (idx_todo_date, idx_todo_date_step, idx_deleted_todo_date, idx_deleted_todo_deleted_at)
  
**주요 기능:**

- Todo CRUD: 조회, 생성, 수정, 완료 토글
- 소프트 삭제: `todo` → `deleted_todo` 이동
- 복구: `deleted_todo` → `todo` 이동
- 완전 삭제: `deleted_todo`에서 영구 삭제
- 날짜/Step별 조회 기능

### 2. UI 컴포넌트 커스터마이징 ✅

#### 2.1 TableCalendar 커스터마이징

- ✅ `lib/app_custom/custom_calendar.dart` - 메인 화면용 캘린더 위젯
  - 로케일 설정 (한국어)
  - 오늘 날짜와 선택된 날짜 구분 표시
  - 날짜 셀 모양: 원형 → 둥근 사각형으로 변경
  - 반응형 높이 조정 기능
  - 이벤트 표시: 하단 언더바 + 우측 하단 숫자 배지
  - 토요일/일요일 색상 구분 (토요일: Primary 색상, 일요일: 빨간색)
  - 10개 이상 이벤트 시 빨간색 배지로 강조

#### 2.2 테스트 화면 구조 개선

- ✅ 기능별 테스트 화면 분리
  - `lib/view/home_test_calendar.dart` - 캘린더 테스트 화면
  - `lib/view/home_test_summary_bar.dart` - 서머리바 테스트 화면
  - `lib/view/home.dart` - 테스트 화면 라우팅용 인덱스로 변경
  - 각 테스트 화면에 테마 토글 기능 포함

#### 2.3 시간 → Step 매핑 유틸리티 구현

- ✅ `lib/util/step_mapper_util.dart` 생성
  - 시간 문자열('HH:MM')을 Step 값으로 변환하는 기능 제공
  - 시간대 구분 규칙 적용 (06:00-11:59=오전, 12:00-17:59=오후, 18:00-23:59=저녁, 나머지=종일)
  - Step 값을 한국어 문자열로 변환하는 기능 제공
  - 단위 테스트 작성 및 통과 (10개 테스트 모두 통과)

#### 2.4 일정 등록/수정 화면용 날짜 선택 위젯 구현

- ✅ `lib/app_custom/custom_calendar_picker.dart` 생성
  - 다이얼로그 형식: `CustomCalendarPicker.showDatePicker()` 메서드
  - 화면 배치 형식: `CustomCalendarPickerWidget` 위젯
  - 기존 `CustomCalendar`를 `showEvents: false` 옵션으로 재사용
  - 두 가지 사용 방식 모두 테스트 페이지에서 검증 완료
- ✅ `CustomCalendar`에 `showEvents` 옵션 추가
  - 메인 화면용(이벤트 표시)과 일정 등록/수정 화면용(이벤트 숨김) 구분 가능
  - 코드 재사용성 향상
- ✅ 날짜 선택 위젯 테스트 페이지 분리
  - `lib/view/home_test_calendar_picker.dart` 생성
  - 다이얼로그 형식과 화면 배치 형식 모두 테스트 가능
  - `home.dart`에서 불필요한 레이아웃 제거 및 코드 정리

#### 2.5 Filter Radio 모듈 구현

- ✅ `lib/app_custom/custom_filter_radio.dart` 생성
  - CustomFilterRadio 기반으로 5개 라디오 구현 (전체/오전/오후/저녁/종일)
  - Summary Bar 색상과 동일한 색상 적용 (progressMorning, progressNoon, progressEvening, progressAnytime)
  - 선택된 Step 값 반환 (null = 전체, 0=오전, 1=오후, 2=저녁, 3=종일)
  - 단일 선택 모드 (하나만 선택 가능)
  - 테마 색상 자동 적용
  - 텍스트 색상 자동 조정 (배경색 밝기에 따라)
  - 테스트 페이지 생성 (`home_test_filter_radio.dart`) 및 검증 완료

#### 2.6 메인 화면 구현

- ✅ `lib/view/main_view.dart` 구현
  - TableCalendar 통합 및 이벤트 표시 (캐싱 방식)
  - Summary Bar 구현 및 선택된 날짜 기준 Step별 비율 자동 계산
  - Filter Radio 구현 (전체/오전/오후/저녁/종일)
  - Todo List 구현 (CustomListView + Slidable)
  - 날짜 선택 시 데이터 자동 갱신 로직
  - DatabaseHandler API 문서 생성 (`lib/vm/DATABASE_HANDLER_API.md`)
  - Todo 카드 UI 개선
    - Stack 제거하고 Row로 재구성 (체크박스, 내용, 우선순위 띠 3개 영역)
    - 제목과 메모 한 줄 표시 (말줄임표 적용)
    - 제목 글자 크기 증가 (18 → 20)
    - 줄간격 및 카드 높이 최적화
    - 완료 여부 텍스트 추가 (메모 앞에 "완료 : " 또는 "미완료 : ")
    - 체크박스 onChanged 로직을 별도 함수로 분리 (`_toggleTodoDone`)
    - Padding을 CustomPadding으로 교체
  - 정렬 기능 구현
    - 시간순/중요도순 정렬 스위치 추가
    - 시간순: 시간 오름차순, 같으면 중요도 내림차순
    - 중요도순: 중요도 내림차순, 같으면 시간 오름차순
  - ExpansionTile을 사용한 UI 개선
    - 달력과 필터/요약 섹션을 접을 수 있도록 개선
    - 달력 헤더와 본체 분리 (`CustomCalendarHeader`, `CustomCalendarBody`)
    - Summary Bar를 ExpansionTile 제목에 통합
  - 데이터 갱신 로직 개선
    - `_reloadData()`에 `_loadCalendarEvents()`와 `_calculateSummaryRatios()` 포함
    - 일정 등록/수정/삭제 후 자동 갱신
  - Todo 카드에 알람 아이콘 표시
    - 시간이 있고 알람이 활성화된 경우 알람 아이콘 표시

#### 2.7 네비게이션 유틸리티 통합

- ✅ `CustomNavigationUtil`로 모든 네비게이션 호출 통일
  - `Navigator.push` → `CustomNavigationUtil.to`
  - `Navigator.pop` → `CustomNavigationUtil.back`
  - 모든 커스텀 위젯 및 화면에 적용 완료

#### 2.8 더미 데이터 관리 기능

- ✅ 더미 데이터 삽입 기능 개선
  - 2025년 12월 데이터 생성
  - 오늘 날짜 데이터 자동 포함
  - 중복 삽입 방지 로직 추가
- ✅ 모든 데이터 삭제 기능 추가 (드로어에 배치)

#### 2.9 유틸리티 파일 구조 개선

- ✅ 앱 전용 공용 함수/클래스 분리
  - `lib/util/common_util.dart` → `lib/app_custom/app_common_util.dart`로 이동
  - `SummaryRatios` 클래스를 `AppSummaryRatios`로 변경
  - 모든 사용처 import 경로 업데이트 (`main_view.dart`, `home_test_summary_bar.dart`)
  - `lib/util/common_util.dart`는 범용 함수/클래스를 담는 공간으로 문서화
  - `lib/app_custom/app_common_util.dart`는 앱 전용 공용 함수/클래스를 담는 공간으로 문서화

#### 2.10 일정 등록/수정 화면 구현

- ✅ `lib/view/create_todo_view.dart` 생성
  - 날짜 선택 (CustomCalendarPicker 다이얼로그 사용)
  - 시간 선택 (CustomTimePicker 다이얼로그 사용, 12시간 형식)
  - 제목 입력 (CustomTextField, 최대 50자)
  - 메모 입력 (CustomTextField, 최대 200자, 멀티라인)
  - 시간대 선택 (CustomDropdownButton, 시간 범위 표시)
  - 중요도 선택 (CustomDropdownButton, 1~5단계)
  - 알람 설정 (Switch, 시간 설정 시에만 활성화)
  - 저장 버튼 (CustomButton)
  - 시간 → Step 자동 매핑 로직
  - 제목 필수 입력 검증 (CustomTextField.textCheck)
  - 저장 성공/실패 다이얼로그 (CustomDialog)
  - DatabaseHandler와 연동 (Todo 저장)
  - 뒤로가기 버튼 색상 설정 (foregroundColor)

- ✅ `lib/view/edit_todo_view.dart` 생성
  - 기존 데이터 로드 및 표시
  - 수정 기능 (등록 화면과 유사한 구조)
  - 날짜 표시 (수정 불가, 텍스트만 표시)
  - 시간 선택 (CustomTimePicker 다이얼로그 사용)
  - 수정 완료 버튼 (CustomButton)
  - 제목 필수 입력 검증
  - 수정 성공/실패 다이얼로그 (CustomDialog)
  - DatabaseHandler와 연동 (Todo 수정)
  - 뒤로가기 버튼 색상 설정 (foregroundColor)

- ✅ `lib/app_custom/custom_time_picker.dart` 생성
  - CustomCupertinoDatePicker를 사용한 시간 선택 다이얼로그
  - 12시간 형식 지원
  - 확인 버튼과 취소(X) 버튼 UI

#### 2.11 코드 리팩토링 및 개선

- ✅ 중복 함수 제거
  - `_formatTime` 함수를 `CustomCommonUtil.formatTime`으로 통합
  - `_formatDateDisplay` 함수 제거, `CustomCommonUtil.formatDate` 직접 사용
  - 일정 등록/수정 화면에서 중복 코드 제거
  - 우선순위 관련 함수 통합 (`getPriorityColor`, `getPriorityText`를 `app_common_util.dart`로 이동)
  - 모든 파일에서 중복 함수 제거 (todo_detail_dialog, create_todo_view, edit_todo_view, main_view, deleted_todos_view)

- ✅ 데이터 갱신 로직 개선
  - `_reloadData()`에 `_loadCalendarEvents()`와 `_calculateSummaryRatios()` 포함
  - 일정 등록/수정/삭제/완료 토글 후 자동으로 모든 데이터 갱신

- ✅ UI 개선
  - 일정 삭제 다이얼로그에서 제목 제거 ("일정을 삭제 하시겠습니까?"만 표시)
  - 일정 카드에 알람 아이콘 추가 (시간이 있고 알람이 활성화된 경우)
  - 정렬 로직과 UI 일치 (true: 중요도순, false: 시간순)

- ✅ 버그 수정
  - 일정 등록/수정 후 데이터 반영 안되는 문제 수정
    - 다이얼로그 닫힌 후 화면 닫기 로직 개선
    - `await CustomDialog.show()` 완료 후 `Navigator.pop(true)` 호출
  - "종일" 선택 시 시간 초기화 문제 수정
    - `Todo.copyWith`에 `clearTime` 플래그 추가
    - DB 저장 시 "종일"이면 time을 null로 강제 설정

#### 2.12 Todo 상세보기 다이얼로그 구현

- ✅ `lib/view/todo_detail_dialog.dart` 생성
  - Todo 상세 정보 표시 (제목, 날짜, 시간, 메모, 중요도, 완료 상태)
  - 시간대 표시 (종일일 때도 표시)
  - 알람 정보 표시
  - Edit 버튼 (수정 화면으로 이동)
  - 높이 고정 및 스크롤 지원
  - 공용 함수 사용 (날짜 포맷팅, 우선순위 관련 함수)

#### 2.13 시간대 시스템 개선

- ✅ 야간 시간대 추가
  - `StepMapperUtil`에 야간(00:00-05:59) 추가 (stepNight = 3)
  - 종일을 stepAnytime = 4로 변경
  - 관련 색상 및 함수 업데이트 (progressNight 색상 추가)
  - Summary Bar에 야간 비율 추가
  - 모든 관련 파일 업데이트 (create_todo_view, edit_todo_view, main_view, home 등)

#### 2.14 네비게이션 통일 및 코드 개선

- ✅ 네비게이션 유틸리티 통일
  - 모든 화면에서 `CustomNavigationUtil.to` 사용 (기본 Navigator.push 제거)
  - 모든 화면에서 `CustomNavigationUtil.back` 사용 (기본 Navigator.pop 제거)
  - `main.dart`의 라우트 정의를 `onGenerateRoute`로 변경하여 arguments 처리 가능하도록 개선
  - 타입 안전성 향상 및 코드 일관성 확보

- ✅ 우선순위 관련 함수 통합
  - `getPriorityColor`, `getPriorityText`를 `app_common_util.dart`로 이동
  - 모든 파일에서 중복 함수 제거 (todo_detail_dialog, create_todo_view, edit_todo_view, main_view, deleted_todos_view)

- ✅ "종일" 선택 시 시간 초기화 로직 개선
  - `Todo.copyWith`에 `clearTime` 플래그 추가
  - DB 저장 시 "종일"이면 time을 null로 강제 설정
  - 시간 선택 버튼은 활성화 상태 유지 (사용자가 다시 시간 선택 가능)

- ✅ Todo 상세보기 다이얼로그 개선
  - 높이 고정 및 스크롤 지원
  - 시간대 표시 개선 (종일일 때도 시간대 표시)
  - 공용 함수 사용 (날짜 포맷팅, 우선순위 관련 함수)

#### 2.15 전역 로깅 시스템 구현

- ✅ `lib/custom/util/log/custom_log_util.dart` 생성
  - `AppLogger` 클래스 구현
  - 5가지 로그 레벨 제공 (디버그/정보/경고/에러/성공)
  - 디버그 모드와 릴리즈 모드 자동 구분
  - 릴리즈 모드에서도 에러 로그 출력 옵션 제공 (`_enableReleaseErrorLogs`)
  - 태그 기반 로그 분류 지원
  - 에러 객체 및 스택 트레이스 출력 지원

- ✅ 모든 `print` 문을 `AppLogger`로 교체
  - `lib/service/notification_service.dart` (모든 print 문 교체)
  - `lib/view/create_todo_view.dart` (모든 print 문 교체)
  - `lib/view/edit_todo_view.dart` (모든 print 문 교체)
  - `lib/view/main_view.dart` (모든 print 문 교체)
  - `lib/view/home.dart` (모든 print 문 교체)
  - `lib/view/deleted_todos_view.dart` (모든 print 문 교체)
  - `lib/main.dart` (print 문 교체)

- ✅ 릴리즈 빌드에서 로그 확인 방법
  - Android: `adb logcat | grep ERROR` 명령어로 에러 로그 확인 가능
  - iOS: Xcode Console에서 디바이스 연결 후 로그 확인 가능

### 3. 문서 업데이트 ✅

#### 3.1 REFERENCE.md 업데이트

- ✅ 테스트 페이지 구조 및 명명 규칙 명시
- ✅ 개발 작업 스타일 및 우선순위 섹션 추가
  - 기능 모듈 우선 개발, 화면 구성은 후순위 원칙 명시
  - 작업 순서 및 흐름 예시 추가
- ✅ Step 값 및 시간대 용어 업데이트 (오전/오후/저녁/야간/종일)
- ✅ 네비게이션 유틸리티 사용 규칙 명시

#### 3.2 DatabaseHandler API 문서 생성

- ✅ `lib/vm/DATABASE_HANDLER_API.md` 생성
  - 모든 메서드 목록 및 사용법 정리
  - 파라미터, 반환 타입, 설명 표로 정리
  - 사용 예시 코드 포함

#### 3.3 DBML 클래스 다이어그램 업데이트

- ✅ `specs/daily_flow_class_diagram.dbml` 완성된 앱 상태 반영
  - 모든 뷰 화면, 서비스, 사용자 행위, 앱 데이터/응답 관계 정리
  - 논리적 엔티티 PK 정의 정제 (viewType, serviceType, actionId, dataId)
  - 관계(Ref) 정리 및 논리적 관계 Note 섹션에 상세 설명 추가
  - "[구현 완료]" 표시 및 각 엔티티의 기능, 트리거, 결과 상세 설명
  - 데이터 흐름 섹션 추가 (뷰 → 행위 → 데이터 생성)

### 4. 설계 결정 사항 ✅

#### 4.1 상태 관리

- ✅ GetX 제거 결정
- ✅ 순수 Flutter (StatefulWidget) 사용
- ✅ 네비게이션: Navigator.push() 사용

#### 4.2 UI 컴포넌트

- ✅ CustomSnackBar 사용 (에러/성공 메시지)
- ✅ CustomDialog 사용 (확인 다이얼로그)
- ✅ lib_doc의 커스텀 위젯 우선 사용

#### 4.3 데이터베이스

- ✅ SQLite (sqflite 패키지)
- ✅ 스펙 문서의 컬럼명 및 타입 준수
- ✅ 소프트 삭제 구조 (휴지통 기능)

#### 4.4 코드 품질 개선

- ✅ SQL 쿼리 가독성 개선 (multi-line 문자열 사용)
- ✅ 스펙 문서 참조 주석 제거 및 자체 설명 주석으로 통합

---

## 🚧 진행 중인 작업

### 없음

---

## 📝 다음 작업 예정

### 1. 기능 모듈 구현 (화면 구성 전) 🔴 높은 우선순위

#### 1.1 Filter Chips 모듈 ✅
- ✅ `lib/app_custom/custom_filter_chips.dart` 생성
  - CustomChip 기반으로 5개 칩 구현 (전체/오전/오후/저녁/종일)
  - Summary Bar 색상과 동일한 색상 적용
  - 선택된 Step 값 반환 (null = 전체, 0~3 = Step)
  - 단일 선택 모드 (하나만 선택 가능)
  - 테스트 페이지 생성 및 검증 완료

#### 1.2 알람 기능 모듈 ✅

- ✅ `lib/service/notification_service.dart` 생성 완료
  - `flutter_local_notifications` 초기화 완료 (Android/iOS)
  - 알람 등록/취소/업데이트 메서드 구현 완료
  - 알람 권한 요청 (iOS/Android) 구현 완료
  - 알람 정책 구현 완료 (1 Todo당 최대 1개 알람, has_alarm=true AND time IS NOT NULL일 때만 등록)
  - 과거 알람 정리 기능 구현
    - 앱 시작 시 자동 정리
    - 앱 포그라운드 복귀 시 자동 정리
    - 과거 알람 취소 및 DB 상태 업데이트 (hasAlarm=false, notificationId=null)
    - notificationId가 없는 경우도 정리 대상에 포함
  - 일정 등록/수정 화면과 연동 완료

### 2. 유틸리티 클래스 생성 ✅

- ✅ `lib/util/step_mapper_util.dart` - 시간 → Step 매핑 구현 완료
  - 시간대 구분: 오전(06:00-11:59), 오후(12:00-17:59), 저녁(18:00-23:59), 야간(00:00-05:59), 종일(나머지)
  - `mapTimeToStep(String? time)` 메서드 구현
  - `stepToKorean(int step)` 메서드 구현
  - 단위 테스트 작성 및 통과 완료

### 3. 화면 구현 ✅ 완료

- ✅ 메인 화면 (Main View) 구현 완료
  - TableCalendar 통합 완료
  - Summary Bar 구현 완료
  - Filter Radio 구현 완료 (전체/오전/오후/저녁/야간/종일)
  - Todo List 구현 완료 (체크박스 + Slidable)
  - 설정 Drawer 통합 완료

- ✅ 일정 등록 화면 (Create Todo) 구현 완료
  - 날짜/시간 선택 완료
  - 제목/메모 입력 완료
  - Step 선택 완료
  - 저장 기능 완료
  - 알람 기능 연동 완료

- ✅ 일정 수정 화면 (Edit Todo) 구현 완료
  - 기존 데이터 로드 완료
  - 수정 기능 완료
  - 알람 기능 연동 완료

- ✅ 삭제 보관함 화면 구현 완료
  - 삭제된 Todo 리스트 표시
  - 필터 및 정렬 기능
  - 복구 및 완전 삭제 기능

- ✅ Todo 상세보기 다이얼로그 구현 완료
  - Todo 상세 정보 표시
  - Edit 버튼으로 수정 화면 이동

---

## 📅 작업 일지

### 2024년 (최근 작업)

#### 일정 등록/수정 화면 구현 및 개선 (2024년 12월)

- 일정 등록 화면 구현 완료
  - CustomTimePicker를 사용한 시간 선택 (12시간 형식)
  - 제목/메모 글자 수 제한 (50자/200자)
  - 시간대 선택 드롭다운에 시간 범위 표시
  - 알람 설정 (시간 설정 시에만 활성화)
  - 저장 성공/실패 다이얼로그
  - 제목 필수 입력 검증

- 일정 수정 화면 구현 완료
  - 기존 데이터 로드 및 표시
  - 수정 기능 (등록 화면과 유사한 구조)
  - 수정 성공/실패 다이얼로그
  - 제목 필수 입력 검증

- 코드 리팩토링
  - 중복 함수 제거 (formatTime, formatDateDisplay)
  - CustomCommonUtil에 formatTime 함수 추가
  - 데이터 갱신 로직 개선 (_reloadData 통합)

- UI 개선
  - 일정 삭제 다이얼로그 간소화 (제목 제거)
  - 일정 카드에 알람 아이콘 추가
  - 정렬 로직과 UI 일치 (true: 중요도순, false: 시간순)
  - 뒤로가기 버튼 색상 설정 (foregroundColor)

- 버그 수정
  - 일정 등록/수정 후 데이터 반영 안되는 문제 수정
  - 다이얼로그 닫힌 후 화면 닫기 로직 개선

#### 메인 화면 기능 개선

#### 메인 화면 Todo 카드 UI 개선

- Todo 카드 레이아웃 개선
  - Stack 제거하고 Row로 재구성 (체크박스, 내용, 우선순위 띠 3개 영역)
  - 제목과 메모 한 줄 표시 (말줄임표 적용)
  - 제목 글자 크기 증가 (18 → 20)
  - 줄간격 및 카드 높이 최적화
  - 완료 여부 텍스트 추가 (메모 앞에 "완료 : " 또는 "미완료 : ")
  - 체크박스 onChanged 로직을 별도 함수로 분리 (`_toggleTodoDone`)
  - Padding을 CustomPadding으로 교체

#### 유틸리티 파일 구조 개선

- 앱 전용 공용 함수/클래스 분리
  - `lib/util/common_util.dart` → `lib/app_custom/app_common_util.dart`로 이동
  - `SummaryRatios` 클래스를 `AppSummaryRatios`로 변경
  - 모든 사용처 import 경로 업데이트
  - 파일 목적 및 용도 문서화

#### 테스트 페이지 구조 개선 및 코드 정리

- 날짜 선택 위젯 테스트 페이지 분리
  - `home_test_calendar_picker.dart` 생성
  - 다이얼로그 형식과 화면 배치 형식 모두 테스트 가능한 별도 페이지로 분리
  - `home.dart`에서 불필요한 레이아웃 및 중복 코드 제거
- `create_todo_view.dart` 코드 정리
  - Summary Bar 관련 불필요한 코드 제거
  - 사용하지 않는 import 및 필드 정리

#### 기능 모듈 구현 및 문서 업데이트

- 시간 → Step 매핑 유틸리티 구현 완료
  - `StepMapperUtil` 클래스 생성 및 단위 테스트 작성
  - 시간대 구분 규칙 적용 (오전/오후/저녁/종일)
- 일정 등록/수정 화면용 날짜 선택 위젯 구현 완료
  - 다이얼로그 형식과 화면 배치 형식 두 가지 방식 제공
  - `CustomCalendar`에 `showEvents` 옵션 추가하여 코드 재사용성 향상
- REFERENCE.md 업데이트
  - 테스트 페이지 구조 및 명명 규칙 명시
  - 개발 작업 스타일 및 우선순위 섹션 추가

#### 전역 로깅 시스템 구현 (2024년 12월)

- `AppLogger` 클래스 구현 완료
  - 디버그/정보/경고/에러/성공 5가지 로그 레벨 제공
  - 디버그 모드와 릴리즈 모드 자동 구분
  - 릴리즈 모드에서도 에러 로그 출력 옵션 제공 (`_enableReleaseErrorLogs`)
  - 태그 기반 로그 분류 및 에러 객체/스택 트레이스 지원

- 모든 `print` 문을 `AppLogger`로 교체 완료
  - 서비스 레이어: `notification_service.dart` (모든 print 문 교체)
  - 뷰 레이어: `create_todo_view.dart`, `edit_todo_view.dart`, `main_view.dart`, `home.dart`, `deleted_todos_view.dart` (모든 print 문 교체)
  - 앱 진입점: `main.dart` (print 문 교체)

- 릴리즈 빌드에서 로그 확인 방법 문서화
  - Android: `adb logcat | grep ERROR` 명령어로 에러 로그 확인 가능
  - iOS: Xcode Console에서 디바이스 연결 후 로그 확인 가능

#### 알람 기능 모듈 구현 (2024년 12월)

- `NotificationService` 클래스 구현 완료
  - `flutter_local_notifications` 초기화 (Android/iOS)
  - 알람 등록/취소/업데이트 메서드 구현
  - 알람 권한 요청 (iOS/Android)
  - 알람 정책 구현 (1 Todo당 최대 1개 알람, has_alarm=true AND time IS NOT NULL일 때만 등록)
  - 과거 알람 정리 기능 구현
    - 앱 시작 시 자동 정리 (`main.dart`에서 호출)
    - 앱 포그라운드 복귀 시 자동 정리 (`WidgetsBindingObserver` 사용)
    - 과거 알람 취소 및 DB 상태 업데이트 (hasAlarm=false, notificationId=null)
    - notificationId가 없는 경우도 정리 대상에 포함 (알람 등록 실패한 경우 처리)
  - 일정 등록/수정 화면과 연동 완료
    - `create_todo_view.dart`: 알람 등록 연동
    - `edit_todo_view.dart`: 알람 업데이트/취소 연동

#### 코드 주석 개선 (2024년 12월)

- 주석 정리 작업 완료
  - `lib` 폴더 전반의 과도한 주석 제거
  - 모델 클래스 변수에 한국어 주석 추가
    - `todo_model.dart`: 모든 필드에 한국어 주석 추가
    - `deleted_todo_model.dart`: 모든 필드에 한국어 주석 추가
  - 코드 가독성 개선

#### 문서 업데이트 (2024년 12월)

- DBML 클래스 다이어그램 업데이트 완료
  - `specs/daily_flow_class_diagram.dbml` 완성된 앱 상태 반영
  - 모든 뷰 화면, 서비스, 사용자 행위, 앱 데이터/응답 관계 정리
  - 논리적 엔티티 PK 정의 정제 (viewType, serviceType, actionId, dataId)
  - 관계(Ref) 정리 및 논리적 관계 Note 섹션에 상세 설명 추가
  - "[구현 완료]" 표시 및 각 엔티티의 기능, 트리거, 결과 상세 설명
  - 데이터 흐름 섹션 추가 (뷰 → 행위 → 데이터 생성)

#### 삭제 보관함 화면 구현 (2024년 12월)

- `lib/view/deleted_todos_view.dart` 생성 완료
  - 삭제된 Todo 리스트 표시
  - 필터 라디오 (전체/오늘/7일/30일)
  - 정렬 기능 (시간순/중요도순)
  - 복구 기능 (소프트 삭제 복구)
  - 완전 삭제 기능 (영구 삭제)
  - Slidable (좌: 복구 / 우: 완전 삭제)
  - `MainView` Drawer에 진입 버튼 추가

#### 설정 기능 Drawer 통합 (2024년 12월)

- `MainView` Drawer에 설정 기능 통합
  - 라이트/다크 모드 토글 추가
  - 삭제 보관함 진입 버튼 추가
  - 별도 설정 화면 없이 Drawer에서 모든 설정 접근 가능

### 2024년 (이전 작업)

#### UI 컴포넌트 커스터마이징 및 테스트 구조 개선

- TableCalendar 커스터마이징 완료
  - 날짜 셀 스타일링 (둥근 사각형, 오늘/선택 날짜 구분)
  - 이벤트 표시 (하단 언더바 + 숫자 배지)
  - 주말 색상 구분 (토요일/일요일)
  - 반응형 높이 조정 기능
- 기능별 테스트 화면 분리
  - `home_test_calendar.dart`, `home_test_summary_bar.dart` 생성
  - `home.dart`를 테스트 화면 라우팅용 인덱스로 변경
- 코드 품질 개선
  - SQL 쿼리 가독성 개선
  - 스펙 문서 참조 주석 제거 및 자체 설명 주석으로 통합

#### 데이터베이스 및 모델 구현

- Model 클래스 생성 완료
- DatabaseHandler 수정 완료
- GetX 제거 및 CustomSnackBar/Dialog 통합 완료
- 스펙 문서 준수 확인 완료

---

## 🔍 검증 필요 사항

### 데이터베이스

- [ ] DB 초기화 테스트
- [ ] CRUD 동작 테스트
- [ ] 소프트 삭제/복구 플로우 테스트
- [ ] 인덱스 성능 확인

### 모델 클래스

- [ ] fromMap/toMap 변환 정확성 확인
- [ ] copyWith 메서드 동작 확인
- [ ] createNew 메서드 날짜 형식 확인

---

## 📚 참고 문서

- `daily_flow_db_spec.md` - 데이터베이스 스펙
- `dailyflow_design_spec.md` - 화면 설계 스펙
- `lib_doc/` - 커스텀 위젯 문서
