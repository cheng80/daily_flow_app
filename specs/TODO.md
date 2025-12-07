# DailyFlow 앱 - TODO 목록

이 문서는 DailyFlow 앱 개발의 할 일 목록을 관리합니다.

---

## 🔴 높은 우선순위 (즉시 필요)

### 1. 색상 시스템 보완

- [x] `lib/theme/app_colors.dart` 수정
  - [x] 라이트 테마 색상 값 설정 (Material Design 가이드라인 준수)
  - [x] 다크 테마 색상 값 설정 (다크 모드 최적화)
  - [x] Progress 색상 라이트/다크 모드별 최적화
  - [x] 칩 색상 가독성 개선 (다크 모드 텍스트 흰색)
  - [x] `AppColorScheme`에 중요도 색상 5개 필드 추가
    - [x] priorityVeryLow (1단계: 매우 낮음) - 회색
    - [x] priorityLow (2단계: 낮음) - 파란색
    - [x] priorityMedium (3단계: 보통) - 초록색
    - [x] priorityHigh (4단계: 높음) - 주황색
    - [x] priorityVeryHigh (5단계: 매우 높음) - 빨간색
    - [x] 라이트/다크 모드별 색상 최적화
  - [x] 린터 에러 확인

**참고:** 설계서 `dailyflow_design_spec.md` 9.3.1 섹션

### 2. 시간 → Step 매핑 유틸리티

- [x] `lib/util/step_mapper_util.dart` 생성
  - [x] `mapTimeToStep(String? time)` 메서드 구현
  - [x] `stepToKorean(int step)` 메서드 구현
  - [x] 시간대 구분 규칙 적용 (06:00-11:59=오전, 12:00-17:59=오후, 18:00-23:59=저녁, 00:00-05:59=야간, 나머지=종일)
  - [x] 야간 시간대 추가 (stepNight = 3, stepAnytime = 4)
  - [x] 단위 테스트 작성 및 통과 (`test/util/step_mapper_util_test.dart`)

**참고:** 설계서 `dailyflow_design_spec.md` 2.2 섹션

### 3. 메인 화면 구현

- [x] `lib/view/main_view.dart` 생성
  - [x] TableCalendar 통합
  - [x] Summary Bar 구현 (actionFourRangeBar 함수 사용)
    - [x] 선택된 날짜 기준 Step별 비율 자동 계산 함수 구현
    - [x] 날짜 선택 시마다 비율 자동 갱신
  - [x] Filter Radio 구현 (전체/오전/오후/저녁/종일)
    - [x] `lib/app_custom/custom_filter_radio.dart` 생성
    - [x] CustomFilterRadio 기반으로 5개 라디오 구현
    - [x] Summary Bar 색상과 동일한 색상 적용
    - [x] 선택된 Step 값 반환 (null = 전체, 0~3 = Step)
    - [x] 테스트 페이지 생성 및 검증 완료
  - [x] Todo List 구현 (CustomListView + Slidable)
    - [x] FutureBuilder로 데이터 조회
    - [x] CustomCard로 Todo 표시
    - [x] Slidable로 수정/삭제 액션 구현
    - [x] Todo 카드 UI 개선
      - [x] Stack 제거하고 Row로 재구성 (체크박스, 내용, 우선순위 띠 3개 영역)
      - [x] 제목과 메모 한 줄 표시 (말줄임표 적용)
      - [x] 제목 글자 크기 증가 (18 → 20)
      - [x] 줄간격 및 카드 높이 최적화
      - [x] 완료 여부 텍스트 추가 (메모 앞에 "완료 : " 또는 "미완료 : ")
      - [x] 체크박스 onChanged 로직을 별도 함수로 분리 (`_toggleTodoDone`)
      - [x] Padding을 CustomPadding으로 교체
  - [x] FloatingActionButton 구현
  - [x] 날짜 선택 시 데이터 갱신 로직
    - [x] 달력 이벤트 캐싱 및 자동 로드
    - [x] Summary Bar 비율 자동 계산

**참고:** 설계서 `dailyflow_design_spec.md` 1장

**작업 방식:**

- `lib/view/home.dart`는 모듈 테스트/프로토타이핑 용도로만 사용
- 각 커스텀 모듈 개발 완료 후 `home.dart`에서 테스트
- 모든 모듈이 완료되면 `main_view.dart`에서 실제 화면 구성
- 필요 시 추가 작업 요청

### 3-1. TableCalendar 커스텀 위젯 구현

- [x] `lib/app_custom/custom_calendar.dart` 생성
  - [x] 기본 TableCalendar 위젯 래핑
  - [x] 날짜 셀 커스터마이징 (`calendarBuilders` 구현)
    - [x] 좌상단: 날짜 숫자 표시
    - [x] 우측 하단: 일정 갯수 원형 배지 표시
      - [x] 해당 날짜의 Todo 개수 계산 및 표시
      - [x] 배지 색상: Primary 색상 사용 (10개 이상은 붉은 계열)
      - [x] 배지 크기 및 위치 조정 (우측 하단)
      - [x] 10개 이상일 때 붉은 배지로 강조
    - [x] 맨 하단: 이벤트 언더바 표시
      - [x] 이벤트가 있는 날짜에 주황색 언더바 표시
      - [x] 바 높이 및 위치 조정 (셀 경계와 일치하도록)
    - [x] 선택 상태 스타일링
      - [x] 선택된 날짜 배경 강조 (Primary 색상 투명도 적용)
      - [x] 선택된 날짜 테두리 표시 (Primary 색상, 2.0px)
    - [x] 오늘 날짜 표시
      - [x] 오늘 날짜 파란색 테두리 표시 (Primary 색상, 1.5px)
      - [x] 오늘 날짜 텍스트 강조 (Primary 색상)
    - [x] 이전/다음 달 날짜 스타일링
      - [x] 다른 달 날짜는 TextSecondary 색상으로 표시
      - [x] 다른 달 날짜는 투명도 조정
    - [x] 주말 색상 구분
      - [x] 일요일: 붉은 계열 색상 (Colors.red.shade600)
      - [x] 토요일: Primary 색상
  - [x] 월/연도 헤더 커스터마이징 (`headerStyle` 구현)
    - [x] 헤더 배경색: CardBackground
    - [x] 헤더 텍스트 색상: TextPrimary
    - [x] 좌우 화살표 버튼 스타일링
      - [x] 이전/다음 월 이동 버튼
      - [x] 버튼 색상: Primary 색상
      - [x] 버튼 아이콘 크기 및 패딩 조정
  - [x] 요일 헤더 커스터마이징 (`daysOfWeekStyle` 구현)
    - [x] 요일 헤더 배경색: CardBackground 또는 Background
    - [x] 요일 텍스트 색상: TextPrimary
    - [x] 요일 텍스트 크기 및 굵기 조정
    - [x] 주말(토/일) 색상 구분 (일요일 붉은색, 토요일 Primary)
  - [x] 날짜 선택 이벤트 처리 (`onDaySelected` 구현)
    - [x] 선택된 날짜 상태 관리
    - [x] 날짜 선택 시 Summary Bar 갱신
    - [x] 날짜 선택 시 Todo List 갱신
  - [x] 테마 색상 적용
    - [x] `context.palette`를 통한 동적 색상 적용
    - [x] 라이트/다크 모드 자동 전환 지원
    - [x] 모든 색상은 AppColorScheme의 역할 기반 토큰 사용
  - [x] 달력 레이아웃 설정
    - [x] 화면 상단 40~45% 차지하도록 높이 조정 (반응형 지원)
    - [x] 달력 전체 패딩 및 마진 설정
    - [x] 날짜 셀 크기 및 간격 조정 (둥근 사각형, 8px radius)
  - [x] 초기 날짜 설정
    - [x] 앱 시작 시 오늘 날짜로 초기화
    - [x] 선택된 날짜 상태 관리
  - [x] 데이터 바인딩
    - [x] 날짜별 Todo 데이터 조회 (eventLoader 콜백 사용)
    - [x] 날짜별 Todo 개수 계산
    - [x] 이벤트 바 및 배지 표시
    - [ ] 날짜별 완료율 계산 (차후 구현)
    - [ ] 데이터 변경 시 달력 자동 갱신 (차후 구현)
  - [ ] 공휴일 표시 기능 (차후 작업 - 유보)
    - [ ] `world_holidays` 패키지 사용 검토
      - 패키지: https://pub.dev/packages/world_holidays
      - 한국 공휴일 정보 제공 (2024-2026, 41개 공휴일)
      - 오프라인 지원 및 자동 온라인 업데이트 기능
      - 다국어 지원 (영어, 한국어)
    - [ ] 공휴일 날짜 스타일링 (빨간색 텍스트 또는 특별한 배경색)
    - [ ] 공휴일 정보 표시 방법 결정 (툴팁, 배지 등)
    - [ ] 공휴일 데이터 로딩 및 캐싱 전략

**참고:** 설계서 `dailyflow_design_spec.md` 1.3 섹션, `table_calendar` 패키지 문서

---

## 🔴 높은 우선순위 (즉시 필요)

### 7. 기능 모듈 구현 (화면 구성 전)

#### 7-0. Filter Chips 모듈 ✅

- [x] `lib/app_custom/custom_filter_chips.dart` 생성
  - [x] CustomChip 기반으로 5개 칩 구현 (전체/오전/오후/저녁/종일)
  - [x] Summary Bar 색상과 동일한 색상 적용
  - [x] 선택된 Step 값 반환 (null = 전체, 0~3 = Step)
  - [x] 단일 선택 모드 (하나만 선택 가능)
  - [x] 테스트 페이지 생성 (`home_test_filter_chips.dart`)
  - [x] `home.dart`에 등록

**참고:** 설계서 `dailyflow_design_spec.md` 1.5 섹션

#### 7-1. 일정 등록/수정 화면용 달력 위젯 모듈

- [x] `lib/app_custom/custom_calendar_picker.dart` 생성
  - [x] 기존 `CustomCalendar` 기반으로 날짜 선택 전용 위젯 구현
  - [x] 메인 화면 달력과 유사하나 단순화된 버전
    - [x] 이벤트 바 및 배지 제거 (날짜 선택에 집중) - `showEvents: false` 옵션 사용
    - [x] 날짜 선택 시 즉시 반영
    - [x] 선택된 날짜 강조 표시
  - [x] 다이얼로그 또는 풀스크린 모드 지원
    - [x] `showDialog`로 날짜 선택 다이얼로그 구현
    - [x] 선택된 날짜를 콜백으로 반환
  - [x] 테마 색상 적용 (context.palette 사용)
  - [x] 초기 날짜 설정 가능
  - [x] 날짜 변경 시 콜백 호출
  - [x] `home.dart`에서 모듈 테스트
  - [x] `CustomCalendar`에 `showEvents` 옵션 추가 (기존 클래스 재사용 방식 채택)
  - [x] 날짜 선택 위젯 테스트 페이지 분리 (`home_test_calendar_picker.dart`)
    - [x] 다이얼로그 형식과 화면 배치 형식 모두 테스트 가능
    - [x] 별도 테스트 페이지로 분리하여 관리

**참고:** 설계서 `dailyflow_design_spec.md` 2.2, 3장 섹션

#### 7-2. 알람 기능 모듈 ✅

- [x] `lib/service/notification_service.dart` 생성
  - [x] flutter_local_notifications 초기화
    - [x] Android 초기화 (채널 설정)
    - [x] iOS 초기화 (권한 요청)
    - [x] 시뮬레이터/에뮬레이터에서 테스트 가능 (실기기 필수 아님)
  - [x] 알람 등록 메서드
    - [x] Todo의 date와 time을 기반으로 알람 스케줄링
    - [x] notification_id를 Todo에 저장
    - [x] 알람 제목과 내용 설정
  - [x] 알람 취소 메서드
    - [x] notification_id로 알람 취소
    - [x] Todo 삭제 시 자동 취소
  - [x] 알람 업데이트 메서드
    - [x] 기존 알람 취소 후 새 알람 등록
    - [x] 시간 변경 시 자동 업데이트
  - [x] 알람 권한 요청
    - [x] iOS: UNUserNotificationCenter 권한 요청
    - [x] Android: 알람 권한 (Android 13+)
  - [x] 알람 정책 구현
    - [x] 1 Todo당 최대 1개의 알람만 지원
    - [x] has_alarm = true AND time IS NOT NULL일 때만 알람 등록
    - [x] 복구 시 알람은 비활성화 상태로 복구
  - [x] 과거 알람 정리 기능
    - [x] 앱 시작 시 과거 알람 자동 정리
    - [x] 앱 포그라운드 복귀 시 과거 알람 자동 정리
    - [x] 과거 알람 취소 및 DB 상태 업데이트 (hasAlarm=false, notificationId=null)
    - [x] notificationId가 없는 경우도 정리 대상에 포함
  - [x] `home.dart`에서 모듈 테스트
    - [x] 알람 등록 테스트 버튼
    - [x] 알람 취소 테스트 버튼
    - [x] 알람 업데이트 테스트 버튼

**테스트 환경:**

- iOS 시뮬레이터: 알람 표시 가능 (실제 알람 소리는 제한적)
- Android 에뮬레이터: 알람 표시 가능
- 실기기: 모든 기능 완전 지원

**참고:** 설계서 `dailyflow_design_spec.md` 7장

---

## 🟡 중간 우선순위 (기능 모듈 완료 후 화면 구성)

### 8. 화면 구현 (기능 모듈 통합)

#### 8-1. 일정 등록 화면

- [x] `lib/view/create_todo_view.dart` 생성
    - [x] 날짜 선택 (CustomCalendarPicker 위젯 사용)
    - [x] 시간 선택 (CustomTimePicker 다이얼로그 사용, 12시간 형식)
    - [x] 제목 입력 (CustomTextField, 최대 50자)
    - [x] 메모 입력 (CustomTextField, 멀티라인, 최대 200자)
    - [x] Step 선택 (CustomDropdownButton, 시간 범위 표시)
    - [x] 중요도 선택 (1~5단계)
    - [x] 알람 설정 (Switch, 시간 설정 시에만 활성화)
    - [x] 저장 버튼 (CustomButton)
    - [x] 시간 → Step 자동 매핑 로직
    - [x] 제목 필수 입력 검증
    - [x] 저장 성공/실패 다이얼로그
    - [x] DatabaseHandler와 연동 (Todo 저장)
    - [x] "종일" 선택 시 시간 초기화 로직
    - [x] copyWith에 clearTime 플래그 추가
    - [x] NotificationService와 연동 (알람 등록) ✅

**참고:** 설계서 `dailyflow_design_spec.md` 2장

#### 8-2. 일정 수정 화면

- [x] `lib/view/edit_todo_view.dart` 생성
    - [x] 기존 데이터 로드
    - [x] 수정 기능 (등록 화면과 유사)
    - [x] 날짜 표시 (수정 불가, 텍스트만 표시)
    - [x] 시간 선택 (CustomTimePicker 다이얼로그 사용)
    - [x] 제목 필수 입력 검증
    - [x] 수정 성공/실패 다이얼로그
    - [x] DatabaseHandler와 연동 (Todo 수정)
    - [x] "종일" 선택 시 시간 초기화 로직
    - [ ] 삭제 버튼 (CustomButton, 빨간색 테두리) - 메인 화면에서 Slidable로 처리 중
    - [ ] 삭제 확인 Dialog (CustomDialog) - 메인 화면에서 처리 중
    - [x] NotificationService와 연동 (알람 업데이트/취소) ✅

**참고:** 설계서 `dailyflow_design_spec.md` 3장

### 9. 삭제 보관함 화면

- [x] `lib/view/deleted_todos_view.dart` 생성
  - [x] 삭제된 Todo 리스트 표시
  - [x] 필터 라디오 (전체/오늘/7일/30일)
  - [x] 정렬 기능 (시간순/중요도순)
  - [x] 복구 기능
  - [x] 완전 삭제 기능
  - [x] Slidable (좌: 복구 / 우: 완전 삭제)

**참고:** 설계서 `dailyflow_design_spec.md` 6장

### 10. Todo 상세보기 다이얼로그

- [x] `lib/view/todo_detail_dialog.dart` 생성
  - [x] Todo 상세 정보 표시
  - [x] 제목, 날짜, 시간, 메모, 중요도, 완료 상태 표시
  - [x] 시간대 표시 (종일일 때도 표시)
  - [x] 알람 정보 표시
  - [x] Edit 버튼 (수정 화면으로 이동)
  - [x] 높이 고정 및 스크롤 지원
  - [x] 공용 함수 사용 (날짜 포맷팅, 우선순위 관련 함수)

**참고:** 설계서 `dailyflow_design_spec.md` 4.5 섹션

### 11. 설정 화면

- [x] 설정 기능 Drawer로 통합 ✅
  - [x] `MainView`의 Drawer에 라이트/다크 모드 토글 추가
  - [x] `MainView`의 Drawer에 삭제 보관함 진입 버튼 추가
  - [x] 별도 설정 화면 없이 Drawer에서 모든 설정 접근 가능
  - [ ] 향후 확장 항목 (알람 기본 설정 등)

**참고:** 설계서 `dailyflow_design_spec.md` 9장 (Drawer로 통합)

---

## 🧪 테스트 및 검증

### 단위 테스트

- [x] Model 클래스 테스트
  - [x] Todo.fromMap/toMap 테스트
  - [x] DeletedTodo.fromMap/toMap 테스트
  - [x] copyWith 메서드 테스트
  - [x] 더미 데이터 생성 함수 작성 (`test/util/test_helpers.dart`)
- [x] DatabaseHandler 테스트
  - [x] CRUD 동작 테스트
  - [x] 소프트 삭제/복구 테스트
  - [x] 날짜/Step별 조회 테스트
  - [x] 테스트 파일 생성 (`test/vm/database_handler_test.dart`)

**참고:** 테스트용 패키지 `sqflite_common_ffi`는 나중에 제거 요청 시 제거 예정입니다.

### 통합 테스트

- [x] 화면 간 네비게이션 테스트 ✅
  - [x] CustomNavigationUtil.to/back 사용 확인
  - [x] MainView ↔ CreateTodoView 네비게이션 동작 확인
  - [x] MainView ↔ EditTodoView 네비게이션 동작 확인
  - [x] MainView ↔ DeletedTodosView 네비게이션 동작 확인
  - [x] TodoDetailDialog → EditTodoView 네비게이션 동작 확인
- [ ] 데이터 흐름 테스트
- [x] 알람 동작 테스트 ✅
  - [x] 알람 등록/취소/업데이트 동작 확인
  - [x] 과거 알람 자동 정리 기능 확인
  - [x] 알람 시간 검증(최소 2분) 동작 확인
  - [x] 알람 테스트 버튼으로 수동 테스트 완료 (home.dart)

---

## 📝 리팩토링 및 개선

### 문서화

- [x] DBML 클래스 다이어그램 업데이트 ✅
  - [x] `specs/daily_flow_class_diagram.dbml` 완성된 앱 상태 반영
  - [x] 모든 뷰, 서비스, 사용자 행위, 앱 데이터/응답 관계 정리
  - [x] 논리적 엔티티 PK 정의 정제 (viewType, serviceType, actionId, dataId)
  - [x] 관계(Ref) 정리 및 논리적 관계 Note 섹션에 상세 설명 추가

- [x] 문서 동기화 및 최신 상태 반영 작업 ✅ (2024-12-07)
  - [x] `specs/REFERENCE.md` 업데이트
    - [x] 네비게이션 방식 최신화 (CustomNavigationUtil 사용 명시)
    - [x] 로깅 시스템 섹션 추가 (AppLogger)
    - [x] 설정 기능 섹션 추가 (Drawer 통합)
    - [x] 삭제 보관함 화면 설명 추가
    - [x] 프로젝트 구조 최신화 (test_view 폴더 반영)
    - [x] 개발 작업 스타일 섹션 완료 상태 표시
  - [x] `specs/daily_flow_db_spec.md` 업데이트
    - [x] Step 기본값 변경 반영 (3 → 4, 종일)
    - [x] Step 값에 야간(3) 추가 반영 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일)
    - [x] 삭제/복구 플로우 상세 설명 추가
  - [x] `specs/daily_flow_class_diagram.dbml` 재편성
    - [x] Step 기본값 업데이트 (4)
    - [x] 뷰 화면 설명 보강 (MainView, DeletedTodosView)
    - [x] 서비스 설명 보강 (NotificationService, DatabaseHandler)
    - [x] 데이터 흐름 섹션 네비게이션 방식 명시
    - [x] 시스템 자동 실행 플로우 추가
  - [x] `specs/README.md` 업데이트
    - [x] daily_flow_class_diagram.dbml 문서 추가
    - [x] 최신 기능 상태 반영
    - [x] 현재 상태 섹션 추가 (구현 완료 항목 목록)
  - [x] `specs/TODO.md` 업데이트
    - [x] 통합 테스트 항목 완료 표시 (화면 간 네비게이션, 알람 동작 테스트)

### 코드 품질

- [x] Repository 레이어 추가 검토 (결정: 현재 구조 유지)
  - [x] DatabaseHandler를 직접 사용하는 현재 구조 유지
  - [x] Repository 레이어는 추가하지 않음 (단순한 CRUD 작업, SQLite만 사용)
  - [x] 향후 네트워크 동기화나 복잡한 비즈니스 로직 추가 시 재검토

- [x] 전역 로깅 시스템 구현 ✅
  - [x] `lib/custom/util/log/custom_log_util.dart` 생성
  - [x] `AppLogger` 클래스 구현 (디버그/정보/경고/에러/성공 레벨)
  - [x] 디버그 모드와 릴리즈 모드 자동 구분
  - [x] 릴리즈 모드에서도 에러 로그 출력 옵션 제공
  - [x] 모든 `print` 문을 `AppLogger`로 교체
    - [x] `lib/service/notification_service.dart`
    - [x] `lib/view/create_todo_view.dart`
    - [x] `lib/view/edit_todo_view.dart`
    - [x] `lib/view/main_view.dart`
    - [x] `lib/view/home.dart`
    - [x] `lib/view/deleted_todos_view.dart`
    - [x] `lib/main.dart`

### 코드 주석 개선

- [x] 주석 정리 작업 ✅
  - [x] `lib` 폴더 전반의 과도한 주석 제거
  - [x] 모델 클래스 변수에 한국어 주석 추가
    - [x] `lib/model/todo_model.dart` - 모든 필드에 한국어 주석 추가
    - [x] `lib/model/deleted_todo_model.dart` - 모든 필드에 한국어 주석 추가
  - [x] 코드 가독성 개선을 위한 주석 정리

### 유틸리티 파일 구조 개선

- [x] 앱 전용 공용 함수/클래스 분리
  - [x] `lib/util/common_util.dart` → `lib/app_custom/app_common_util.dart`로 이동
  - [x] `SummaryRatios` 클래스를 `AppSummaryRatios`로 변경
  - [x] 모든 사용처 import 경로 업데이트
  - [x] `lib/util/common_util.dart`는 범용 함수/클래스를 담는 공간으로 문서화
  - [x] `lib/app_custom/app_common_util.dart`는 앱 전용 공용 함수/클래스를 담는 공간으로 문서화
  - [x] 우선순위 관련 함수 통합
    - [x] `getPriorityColor`, `getPriorityText`를 `app_common_util.dart`로 이동
    - [x] 모든 파일에서 중복 함수 제거 (todo_detail_dialog, create_todo_view, edit_todo_view, main_view, deleted_todos_view)

### 네비게이션 통일

- [x] 네비게이션 유틸리티 통일
  - [x] 모든 화면에서 `CustomNavigationUtil.to` 사용 (기본 Navigator.push 제거)
  - [x] 모든 화면에서 `CustomNavigationUtil.back` 사용 (기본 Navigator.pop 제거)
  - [x] `main.dart`의 라우트 정의를 `onGenerateRoute`로 변경하여 arguments 처리 가능하도록 개선
  - [x] 타입 안전성 향상 및 코드 일관성 확보

### 성능 최적화

- [ ] 데이터베이스 쿼리 최적화
- [ ] 위젯 리빌드 최적화
- [ ] 이미지/리소스 최적화

---

## 🔍 확인 필요 사항

### 설계 검토

- [x] 시간 → Step 자동 매핑 규칙 구현 완료 ✅
  - 구현됨: 06:00-11:59=오전, 12:00-17:59=오후, 18:00-23:59=저녁, 00:00-05:59=야간, 나머지=종일
  - `StepMapperUtil`에 야간 시간대 추가 완료

### 알람 정책 세부화

- [x] 알람 정책 구현 완료 ✅
  - [x] 알람 취소 시점 명확화
    - [x] Todo 삭제 시: 자동 취소
    - [x] 시간 변경 시: 기존 알람 취소 후 새 알람 등록
    - [x] has_alarm을 false로 변경 시: 알람 취소
  - [x] 알람 수정 시 처리: 기존 알람 취소 후 새 알람 등록
  - [x] 과거 알람 정리: 앱 시작/포그라운드 복귀 시 자동 정리

---

## 🚀 고도화 개발 예정 항목

### 달력 범위 선택 및 통계 기능

**목표:** 사용자가 달력에서 시작날짜와 끝날짜를 선택하여 기간 내 일정 통계를 확인할 수 있는 기능

**개발 순서:** 
1. **달력 범위 선택 기능 먼저 개발** (통계 기능 전)
2. 통계 기능 개발 (Phase 1 → Phase 2)

---

## Phase 0: 달력 범위 선택 기능 개발 (최우선) ⭐

**전략:** 기존 달력을 복제하여 범위 선택 달력을 별도로 개발 → 호환성 확보 → 교체

**현재 진행 상황:**
- ✅ Phase 0.5-1 완료: V2 버전 파일 생성 및 싱글 모드 정상 동작 확인
- ✅ Phase 0.5-2 완료: 범위 선택 기능 추가 완료
- ✅ Phase 0.5-3 완료: 범위 선택 UI 구현 완료 (모드 전환, 서머리바 초기화, 필터링된 통계)

#### 0-1. 범위 선택 달력 위젯 개발

- [x] 기존 `CustomCalendar` 복제하여 V2 버전 생성 (단계적 개발 방식)
  - [x] 파일: `lib/app_custom/custom_calendar_range_body_v2.dart` (Phase 1: 싱글 모드)
  - [x] 파일: `lib/app_custom/custom_calendar_range_header_v2.dart` (Phase 1: 싱글 모드)
  - [x] 파일: `lib/view/main_range_view_v2.dart` (Phase 1: 싱글 모드)
  - [x] 기존 `CustomCalendar` 코드 기반으로 복제 (싱글 모드 정상 동작 확인 완료)
  - [x] Phase 2: 범위 선택 기능 추가 완료 ✅

#### 0-1-1. Phase 1: 싱글 모드 정상 동작 (완료 ✅)

- [x] V2 버전 파일 생성 및 기본 구조 설정
  - [x] `CustomCalendarRangeBodyV2`: `CustomCalendarBody` 완전 복제
  - [x] `CustomCalendarRangeHeaderV2`: `CustomCalendarHeader` 완전 복제
  - [x] `MainRangeViewV2`: `MainView` 완전 복제
  - [x] V2 컴포넌트 사용하도록 수정
  - [x] 싱글 모드 정상 동작 확인 완료

#### 0-1-2. Phase 2: 범위 선택 기능 추가 (완료 ✅)

**작업 순서:**
1. `CustomCalendarRangeBodyV2`에 범위 선택 파라미터 추가
2. `MainRangeViewV2`에 범위 선택 상태 관리 추가
3. 날짜 제약 조건 적용 (`queryMinDate`, `queryMaxDate`)
4. 예외 처리 및 테스트

- [x] `table_calendar` 패키지의 `rangeSelectionMode` 활용
  - [x] `rangeSelectionMode` 파라미터 확인 (이미 확인됨)
  - [x] 범위 선택 이벤트 처리 방법 확인 (이미 확인됨)
  - [x] V2 버전에 `rangeSelectionMode: RangeSelectionMode.enforced` 적용 (CustomCalendarRangeBody 사용)

- [x] `CustomCalendarRangeBody`에 범위 선택 기능 구현 (기존 CustomCalendarRangeBody 사용)
  - [x] `selectedRange`, `onRangeSelected`, `enableRangeSelection` 파라미터 추가
  - [x] `minDate`, `maxDate` 파라미터 추가 (날짜 제약)
  - [x] 시작일/종료일 선택 로직
  - [x] 범위 내 날짜 시각적 표시 (배경색 등)
    - [x] `rangeStartDecoration`: 시작일 배경색 (p.primary)
    - [x] `rangeEndDecoration`: 종료일 배경색 (p.accent)
    - [x] `withinRangeDecoration`: 범위 내 날짜 배경색 (반투명)
  - [x] 시작일/종료일 자동 정렬 로직
    - [x] 사용자가 역순으로 선택한 경우 (끝날짜 → 시작날짜) 자동으로 시작일/종료일 정렬
  - [x] 선택된 날짜 범위 유효성 검증
  - [x] 날짜 제약 조건 체크 (`minDate`, `maxDate` 범위 내)
  - [x] 싱글 모드와 범위 모드 전환 로직
  - [x] 예외 처리 (날짜 범위 초과, null 체크 등)

- [x] `MainRangeViewV2`에 범위 선택 상태 관리 추가
  - [x] `_selectedRange` 상태 변수 추가 (`DateTimeRange?`)
  - [x] `_minDate`, `_maxDate` 상태 변수 추가
  - [x] `_loadDateConstraints()` 메서드 추가 (`queryMinDate`, `queryMaxDate` 호출)
  - [x] `_onRangeSelected` 콜백 구현
  - [x] 날짜 제약 조건 적용 (`CustomCalendarRangeBody`에 `minDate`, `maxDate` 전달)
  - [x] 범위 선택 모드 토글 기능 (싱글 ↔ 범위, enableRangeSelection으로 제어)

- [x] 날짜 범위 제약 구현 (완료 ✅)
  - [x] `DatabaseHandler.queryMinDate()` 메서드 추가 ✅
  - [x] `DatabaseHandler.queryMaxDate()` 메서드 추가 ✅
  - [x] 선택 가능한 날짜 범위 제한 (데이터가 있는 최소/최대 날짜)
  - [x] `minDate`, `maxDate` 파라미터로 제한 적용

#### 0-2. 범위 선택 달력 테스트 및 검증

**Phase 1 테스트 (완료 ✅)**
- [x] 싱글 모드 정상 동작 확인 (`MainRangeViewV2` 테스트)
  - [x] 날짜 선택 동작 확인
  - [x] 이벤트 표시 동작 확인
  - [x] 스타일링 일관성 확인 (기존 `MainView`와 동일)

**Phase 2 테스트 (완료 ✅)**
- [x] 범위 선택 동작 테스트
  - [x] 시작일/종료일 선택 동작
  - [x] 역순 선택 시 자동 정렬 테스트
  - [x] 범위 내 날짜 시각적 표시 확인
- [x] 날짜 제약 동작 테스트
  - [x] `minDate` 이전 날짜 선택 방지
  - [x] `maxDate` 이후 날짜 선택 방지
  - [x] 월 이동 시 날짜 제약 범위 유지
- [x] 기존 `CustomCalendar`와 기능 비교
  - [x] 이벤트 표시 기능 동일하게 작동하는지 확인
  - [x] 스타일링 일관성 확인
  - [x] 성능 비교

#### 0-3. 호환성 확보 및 교체 준비

- [ ] API 호환성 검토
  - [ ] 기존 `CustomCalendar` 사용처 확인
  - [ ] 범위 선택 달력의 API가 기존과 호환되는지 검토
  - [ ] 필요 시 adapter 패턴 적용

- [ ] 기존 달력 사용처 점검
  - [ ] `MainView`에서 `CustomCalendar` 사용 확인
  - [ ] 다른 화면에서 사용 여부 확인
  - [ ] 교체 계획 수립

- [ ] 마이그레이션 계획
  - [ ] 단계별 교체 계획 (테스트 페이지 → 실제 화면)
  - [ ] 롤백 계획 (문제 발생 시 기존 달력으로 복귀)

#### 0-4. 기존 달력과의 통합 (선택)

- [ ] 단일 날짜 모드와 범위 모드 전환 기능
  - [ ] 모드 전환 버튼 추가 (단일 날짜 ↔ 범위 선택)
  - [ ] 모드 상태 관리
  - [ ] 각 모드별 콜백 처리

- [ ] 기존 `CustomCalendar`를 `CustomCalendarRange`로 통합 고려
  - [ ] 단일 날짜 모드일 때는 기존 동작 유지
  - [ ] 범위 모드일 때는 범위 선택 동작
  - [ ] API 통합 가능 여부 검토

#### 1. 데이터베이스 쿼리 확장 (완료 ✅)

- [x] `DatabaseHandler`에 `queryDataByDateRange(String startDate, String endDate)` 메서드 추가
  - [x] 날짜 인덱스(`idx_todo_date`) 활용으로 성능 유지
  - [x] 범위 내 모든 Todo 조회
  - [x] 날짜별 정렬 보장

---

## Phase 0.5: 범위 선택 일정 분류 보기 기능 (Phase 0 완료 후, 통계 기능 전) ⭐⭐

**목표:** 범위 선택 달력으로 선택한 날짜 범위의 일정을 기존 Summary Bar와 Filter로 분류해서 볼 수 있게 하기

#### 0.5-1. 범위 선택 후 일정 조회 및 표시 (완료 ✅)

- [x] 범위 선택 달력에서 날짜 범위 선택 시 이벤트 처리
  - [x] `onRangeSelected` 콜백에서 선택된 범위 받기
  - [x] 선택된 범위를 상태로 관리 (`_selectedRange`)

- [x] 범위 내 일정 조회 및 표시
  - [x] `DatabaseHandler.queryDataByDateRange()` 호출
  - [x] 조회된 일정을 Todo List에 표시
  - [x] 기존 단일 날짜 모드와 범위 모드 구분

#### 0.5-2. Summary Bar 범위 모드 지원 (완료 ✅)

- [x] 범위 모드에서 Summary Bar 계산 로직 구현
  - [x] 선택된 날짜 범위 내 모든 일정의 Step별 비율 계산
  - [x] 기존 `calculateRangeSummaryRatios` 함수 사용
  - [x] 범위 내 일정들의 Step별 집계

- [x] Summary Bar 표시
  - [x] 범위 모드일 때 Summary Bar 업데이트
  - [x] 기존 Summary Bar 위젯 재사용
  - [x] 범위 모드 표시 (예: "2024-12-01 ~ 2024-12-07")

#### 0.5-3. Filter Radio 범위 모드 지원 (완료 ✅)

- [x] 범위 모드에서 Filter Radio 동작 구현
  - [x] Step 필터 선택 시 범위 내 해당 Step 일정만 필터링 (클라이언트 측 필터링)
  - [x] 기존 Filter Radio 위젯 재사용
  - [x] 필터 변경 시 Todo List 자동 업데이트

- [x] 필터링 로직
  - [x] 범위 내 일정 중 선택된 Step에 해당하는 일정만 표시
  - [x] "전체" 선택 시 범위 내 모든 일정 표시

#### 0.5-4. UI 통합 및 모드 전환

- [ ] 단일 날짜 모드 ↔ 범위 모드 전환
  - [ ] 모드 전환 버튼 또는 토글 추가
  - [ ] 단일 날짜 모드: 기존 동작 유지
  - [ ] 범위 모드: 범위 선택 → Summary Bar + Filter로 분류 보기

- [ ] 상태 관리
  - [ ] 현재 모드 상태 관리 (단일 날짜 vs 범위)
  - [ ] 선택된 날짜/범위 상태 관리
  - [ ] 모드 전환 시 UI 업데이트

- [ ] 기존 기능과의 호환성
  - [ ] 단일 날짜 모드에서 기존 기능 정상 동작 확인
  - [ ] 범위 모드에서 Summary Bar와 Filter 정상 동작 확인

#### 0.5-5. 테스트 및 검증 (완료 ✅)

- [x] 범위 선택 후 일정 조회 테스트
- [x] Summary Bar 범위 모드 계산 정확성 테스트
- [x] Filter Radio 범위 모드 필터링 테스트
- [x] 모드 전환 동작 테스트 (싱글 ↔ 범위)
- [x] 성능 테스트 (넓은 범위 선택 시)

#### 0.5-6. UI 개선 및 통계 연동 (완료 ✅)

- [x] 모드 전환 시 서머리바 초기화 기능
  - [x] 범위 모드로 전환 시 서머리바 초기화
  - [x] 단일 모드로 전환 시 마지막 날짜의 데이터 로드 및 서머리바 계산
- [x] 범위 선택 시 정렬 기능 적용 (시간순/중요도순)
- [x] 통계 페이지에 필터 전달 기능
  - [x] 필터가 없으면 전체 데이터로 통계 계산
  - [x] 필터가 있으면 필터링된 데이터로 통계 계산
  - [x] 단일 모드일 때도 날짜 범위 전달

---

## Phase 1: 핵심 통계 (Phase 0.5 완료 후) ⭐⭐⭐

##### 3-1. 기본 통계 (완료 ✅)
- [x] 범위 통계 모델 클래스 추가 (`AppRangeStatistics`)
  - [x] 날짜 일수 (선택된 기간의 일수)
  - [x] 총 일정 개수
  - [x] 완료율 (완료된 일정 / 전체 일정)
  - [x] Step별 비율 (기존 `AppSummaryRatios` 로직 재사용)
    - [x] 오전/오후/저녁/야간/종일 비율 계산
  - [x] 중요도별 분포 (1~5단계별 개수 및 비율)

- [x] 범위 통계 계산 함수 추가
  - [x] `AppCommonUtil`에 `calculateRangeStatistics` 메서드 추가
  - [x] 날짜 범위와 Todo 리스트를 입력받아 통계 계산
  - [x] Step별, 중요도별 집계 로직 구현

##### 3-2. Step별 완료율 통계 ⭐⭐⭐⭐⭐ (완료 ✅)
- [x] Step별 완료율 계산 함수 구현
- [x] 각 Step(오전/오후/저녁/야간/종일)별 완료율 계산
- [x] Syncfusion Column Chart 구현
- [x] 데이터 가치: 매우 높음 (생산성 향상 기회 발견)

##### 3-3. 중요도별 완료율 통계 ⭐⭐⭐⭐⭐ (완료 ✅)
- [x] 중요도별 완료율 계산 함수 구현
- [x] 각 중요도(1~5)별 완료율 계산
- [x] Syncfusion Column Chart 구현
- [x] 데이터 가치: 매우 높음 (우선순위 관리 개선)

#### 4. Phase 2: 기능 활용도 통계 ⭐⭐ (Phase 1 완료 후 개발)

**1차 목표: Phase 1 완료 후 진행**

##### 4-1. 알람 설정률
- [ ] 전체 알람 설정 비율 계산
- [ ] Syncfusion Doughnut Chart 구현
- [ ] 데이터 가치: 높음 (기능 활용도 확인)
- [ ] 의존성: 없음 (독립적 개발 가능)

##### 4-2. 알람 + 완료 상관관계 ⭐⭐⭐⭐⭐ (Phase 1 완료 후)
- [ ] **의존성**: Phase 1 완료 필요 (완료율 계산 로직 활용)
- [ ] 알람 설정된 일정의 완료율 계산
- [ ] 알람 미설정 일정의 완료율 계산
- [ ] Syncfusion Grouped Column Chart 구현
- [ ] 데이터 가치: 매우 높음 (알람 기능 가치 검증)

##### 4-3. Step별/중요도별 알람 설정률 (4-1 완료 후)
- [ ] **의존성**: 알람 설정률(4-1) 완료 후 개발 가능
- [ ] Step별 알람 설정 비율 계산 및 차트
- [ ] 중요도별 알람 설정 비율 계산 및 차트

#### 5. UI 개선

##### 5-1. 기본 통계 카드 (완료 ✅)
- [x] 선택된 기간 정보 표시 (시작일 ~ 종료일)
- [x] 총 일정 개수 표시
- [x] 완료율 표시 (진행률 바 및 Doughnut Chart)
- [x] Step별 비율 표시 (Summary Bar 및 Pie Chart)
- [x] 중요도별 분포 표시 (Column Chart)

##### 5-2. 핵심 통계 차트 (Phase 1) (완료 ✅)
- [x] Step별 완료율 Column Chart
- [x] 중요도별 완료율 Column Chart
- [x] 차트 레이아웃 및 스타일링
- [x] 모든 차트에 범례 추가
- [x] 각 차트 섹션 사이에 디바이더 추가

##### 5-3. 기능 활용도 통계 차트 (Phase 2)
- [ ] 알람 설정률 Doughnut Chart
- [ ] 알람 + 완료 상관관계 Grouped Column Chart

#### 6. 상태 관리 및 모드 전환

- [ ] 단일 날짜 모드와 범위 모드 간 전환 로직 구현
  - [ ] 모드 상태 관리 (selectedDate vs selectedDateRange)
  - [ ] 모드 전환 시 UI 업데이트
  - [ ] 기존 기능과의 호환성 유지

#### 7. 성능 고려사항

- [ ] 넓은 범위(예: 1년) 선택 시 성능 최적화
  - [ ] 쿼리 최적화 확인 (인덱스 활용)
  - [ ] 통계 계산 최적화 (메모리 계산)
  - [ ] 필요 시 페이지네이션 또는 샘플링 고려

#### 8. 사용자 경험 개선

- [ ] 범위 선택 안내 (첫 날짜 선택 → 두 번째 날짜 선택)
- [ ] 선택된 범위 시각적 표시
- [ ] 선택 가능한 날짜 범위 안내 표시 (최소/최대 날짜)
- [ ] 범위 초기화 기능 (단일 날짜 모드로 복귀)
- [ ] 통계 카드 애니메이션 (선택 사항)

#### 9. Phase 3 이후 통계 (선택적 개발)

- [ ] 메모 작성률 통계 (Phase 3)
- [ ] 메모 + 완료 상관관계 (Phase 3)
- [ ] 일정 생성 추이 (Phase 4)
- [ ] 시간 설정률 (Phase 4)
- [ ] 고급 분석 통계 (Phase 5)

**개발 순서 요약:**
1. **Phase 0**: 달력 범위 선택 기능 개발 (최우선)
2. **Phase 0.5**: 범위 선택 후 Summary Bar와 Filter로 일정 분류 보기 (통계 기능 전)
3. **Phase 1**: 핵심 통계 (차트 등)
4. **Phase 2**: 기능 활용도 통계

**참고:**
- Phase 0.5에서 범위 선택 후 기존 Summary Bar와 Filter로 일정을 분류해서 볼 수 있게 함
- 통계 기능(Phase 1)은 Phase 0.5 완료 후 진행
- 기존 단일 날짜 모드는 유지 (하위 호환성)
- Summary Bar는 기존 방식 유지 + 범위 모드에서 확장
- 통계 계산 로직은 기존 `calculateSummaryRatios` 함수 재사용 가능

---

## 📚 참고 자료

- `daily_flow_db_spec.md` - 데이터베이스 스펙
- `dailyflow_design_spec.md` - 화면 설계 스펙
- `PROGRESS.md` - 진행 상황 문서
- `REFERENCE.md` - 참고사항 문서
- `lib_doc/` - 커스텀 위젯 문서

---

## 🔖 커밋 이력

### 1차 개발 완료 (2024-12-07)

**커밋 ID:** `3916701af62412f71b7da7bc795d23cadd50df71`

**작업 내용:**
- 모든 주요 화면 구현 완료 (MainView, CreateTodoView, EditTodoView, DeletedTodosView, TodoDetailDialog)
- 알람 기능 완전 구현 (NotificationService)
- 로깅 시스템 통일 (AppLogger)
- 설정 기능 Drawer 통합
- 모든 문서 최신 상태 반영

**주요 변경 사항:**
- REFERENCE.md: 네비게이션, 로깅, 설정 기능 업데이트
- daily_flow_db_spec.md: Step 기본값 및 야간 추가 반영
- daily_flow_class_diagram.dbml: 완성된 앱 기준으로 재편성
- README.md: 문서 목록 및 현재 상태 업데이트
- TODO.md: 고도화 개발 예정 항목 추가
