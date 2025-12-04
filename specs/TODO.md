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
- [ ] `lib/util/step_mapper_util.dart` 생성
  - [ ] `mapTimeToStep(String? time)` 메서드 구현
  - [ ] `stepToKorean(int step)` 메서드 구현
  - [ ] 시간대 구분 규칙 적용 (06:00-11:59=아침, 12:00-17:59=낮, 18:00-23:59=저녁, 나머지=Anytime)

**참고:** 설계서 `dailyflow_design_spec.md` 2.2 섹션

### 3. 메인 화면 구현
- [ ] `lib/view/main/main_view.dart` 생성
  - [ ] TableCalendar 통합
  - [ ] Summary Bar 구현 (actionFourRangeBar 함수 사용)
  - [ ] Filter Chips 구현 (전체/아침/낮/저녁/Anytime)
  - [ ] Todo List 구현 (체크박스 + Slidable)
  - [ ] FloatingActionButton 구현
  - [ ] 날짜 선택 시 데이터 갱신 로직

**참고:** 설계서 `dailyflow_design_spec.md` 1장

**작업 방식:**
- `lib/view/home.dart`는 모듈 테스트/프로토타이핑 용도로만 사용
- 각 커스텀 모듈 개발 완료 후 `home.dart`에서 테스트
- 모든 모듈이 완료되면 `main_view.dart`에서 실제 화면 구성
- 필요 시 추가 작업 요청

### 3-1. TableCalendar 커스텀 위젯 구현
- [ ] `lib/custom/custom_calendar.dart` 생성
  - [ ] 기본 TableCalendar 위젯 래핑
  - [ ] 날짜 셀 커스터마이징 (`calendarBuilders` 구현)
    - [ ] 좌상단: 날짜 숫자 표시
    - [ ] 중앙 하단: 일정 갯수 원형 배지 표시
      - [ ] 해당 날짜의 Todo 개수 계산 및 표시
      - [ ] 배지 색상: Primary 색상 사용
      - [ ] 배지 크기 및 위치 조정
    - [ ] 맨 하단: 진행도 미니 바 표시
      - [ ] 완료된 Todo / 전체 Todo 비율 계산
      - [ ] Progress 색상 사용 (Primary 또는 Progress 색상)
      - [ ] 바 높이 및 위치 조정
    - [ ] 선택 상태 스타일링
      - [ ] 선택된 날짜 배경 강조 (CardBackground 또는 Primary 색상)
      - [ ] 선택된 날짜 테두리 표시 (Primary 색상)
    - [ ] 오늘 날짜 표시
      - [ ] 오늘 날짜 파란색 테두리 표시
      - [ ] 오늘 날짜 텍스트 강조 (Primary 또는 Accent 색상)
    - [ ] 이전/다음 달 날짜 스타일링
      - [ ] 다른 달 날짜는 TextSecondary 색상으로 표시
      - [ ] 다른 달 날짜는 투명도 조정
  - [ ] 월/연도 헤더 커스터마이징 (`headerStyle` 구현)
    - [ ] 헤더 배경색: CardBackground
    - [ ] 헤더 텍스트 색상: TextPrimary
    - [ ] 좌우 화살표 버튼 스타일링
      - [ ] 이전/다음 월 이동 버튼
      - [ ] 버튼 색상: Primary 또는 Accent
      - [ ] 버튼 아이콘 크기 및 패딩 조정
  - [ ] 요일 헤더 커스터마이징 (`daysOfWeekStyle` 구현)
    - [ ] 요일 헤더 배경색: CardBackground 또는 Background
    - [ ] 요일 텍스트 색상: TextPrimary
    - [ ] 요일 텍스트 크기 및 굵기 조정
    - [ ] 주말(토/일) 색상 구분 (선택사항)
  - [ ] 날짜 선택 이벤트 처리 (`onDaySelected` 구현)
    - [ ] 선택된 날짜 상태 관리
    - [ ] 날짜 선택 시 Summary Bar 갱신
    - [ ] 날짜 선택 시 Todo List 갱신
    - [ ] 날짜 선택 시 필터 초기화 (전체로 리셋)
  - [ ] 테마 색상 적용
    - [ ] `context.palette`를 통한 동적 색상 적용
    - [ ] 라이트/다크 모드 자동 전환 지원
    - [ ] 모든 색상은 AppColorScheme의 역할 기반 토큰 사용
  - [ ] 달력 레이아웃 설정
    - [ ] 화면 상단 40~45% 차지하도록 높이 조정
    - [ ] 달력 전체 패딩 및 마진 설정
    - [ ] 날짜 셀 크기 및 간격 조정
  - [ ] 초기 날짜 설정
    - [ ] 앱 시작 시 오늘 날짜로 초기화
    - [ ] 선택된 날짜 상태 관리
  - [ ] 데이터 바인딩
    - [ ] 날짜별 Todo 데이터 조회 (DatabaseHandler 사용)
    - [ ] 날짜별 Todo 개수 계산
    - [ ] 날짜별 완료율 계산
    - [ ] 데이터 변경 시 달력 자동 갱신

**참고:** 설계서 `dailyflow_design_spec.md` 1.3 섹션, `table_calendar` 패키지 문서

---

## 🟡 중간 우선순위 (다음 단계)

### 4. 일정 등록 화면
- [ ] `lib/view/create_todo/create_todo_view.dart` 생성
  - [ ] 날짜 선택 (CustomDatePicker 또는 TableCalendar 위젯 사용)
  - [ ] 시간 선택 (TimePicker 또는 드롭다운)
  - [ ] 제목 입력 (CustomTextField)
  - [ ] 메모 입력 (CustomTextField, 멀티라인)
  - [ ] Step 선택 (CustomDropdownButton)
  - [ ] 중요도 선택 (1~5단계)
  - [ ] 알람 설정 (Switch)
  - [ ] 저장 버튼 (CustomButton)
  - [ ] 시간 → Step 자동 매핑 로직

**참고:** 설계서 `dailyflow_design_spec.md` 2장

### 4-1. 일정 등록 화면용 달력 위젯 (선택사항)
- [ ] `lib/custom/custom_calendar_picker.dart` 생성 (또는 기존 CustomCalendar 재사용)
  - [ ] 날짜 선택 전용 달력 위젯
  - [ ] 메인 화면 달력과 유사하나 단순화된 버전
  - [ ] 날짜 선택 시 즉시 반영
  - [ ] 선택된 날짜 강조 표시
  - [ ] 다이얼로그 또는 풀스크린 모드 지원
  - [ ] 테마 색상 적용 (context.palette 사용)

**참고:** 설계서 `dailyflow_design_spec.md` 2.2 섹션

### 5. 일정 수정 화면
- [ ] `lib/view/edit_todo/edit_todo_view.dart` 생성
  - [ ] 기존 데이터 로드
  - [ ] 수정 기능 (등록 화면과 유사)
  - [ ] 날짜 선택 (CustomDatePicker 또는 TableCalendar 위젯 사용)
  - [ ] 삭제 버튼 (CustomButton, 빨간색 테두리)
  - [ ] 삭제 확인 Dialog (CustomDialog)
  - [ ] 알람 업데이트 로직

**참고:** 설계서 `dailyflow_design_spec.md` 3장

### 5-1. 일정 수정 화면용 달력 위젯 (선택사항)
- [ ] 일정 등록 화면과 동일한 달력 위젯 재사용
  - [ ] 기존 날짜로 초기화
  - [ ] 날짜 변경 시 즉시 반영
  - [ ] 테마 색상 적용

### 6. 하루 상세 화면
- [ ] `lib/view/day_detail/day_detail_view.dart` 생성
  - [ ] 상단 요약 카드 (강조 버전)
  - [ ] 필터 칩 (전체/아침/낮/저녁/Anytime)
  - [ ] Todo 상세 리스트
  - [ ] 중요도 라벨 색상 표시
  - [ ] 카드 탭 → 상세 보기
  - [ ] Slidable (좌: 삭제 / 우: 수정)

**참고:** 설계서 `dailyflow_design_spec.md` 4장

---

## 🟢 낮은 우선순위 (향후 구현)

### 7. 알람 기능
- [ ] `lib/service/notification_service.dart` 생성
  - [ ] flutter_local_notifications 초기화
  - [ ] 알람 등록 메서드
  - [ ] 알람 취소 메서드
  - [ ] 알람 업데이트 메서드
  - [ ] 알람 권한 요청

**참고:** 설계서 `dailyflow_design_spec.md` 7장

### 8. 삭제 보관함 화면 (선택 기능)
- [ ] `lib/view/deleted_todos/deleted_todos_view.dart` 생성
  - [ ] 삭제된 Todo 리스트 표시
  - [ ] 필터 칩 (전체/오늘/7일/30일)
  - [ ] 복구 기능
  - [ ] 완전 삭제 기능
  - [ ] Slidable (좌: 복구 / 우: 완전 삭제)

**참고:** 설계서 `dailyflow_design_spec.md` 6장

### 9. 설정 화면
- [ ] `lib/view/settings/settings_view.dart` 생성
  - [ ] 라이트/다크 모드 토글 (현재는 홈 화면 앱바에 임시 구현됨)
  - [ ] 삭제 보관함 진입 버튼
  - [ ] 향후 확장 항목 (알람 기본 설정 등)

**참고:** 설계서 `dailyflow_design_spec.md` 9장

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
- [ ] 화면 간 네비게이션 테스트
- [ ] 데이터 흐름 테스트
- [ ] 알람 동작 테스트

---

## 📝 리팩토링 및 개선

### 코드 품질
- [ ] Repository 레이어 추가 (선택사항)
  - [ ] `lib/repository/todo_repository.dart`
  - [ ] `lib/repository/deleted_todo_repository.dart`
  - [ ] DatabaseHandler와 View 사이의 중간 계층

### 성능 최적화
- [ ] 데이터베이스 쿼리 최적화
- [ ] 위젯 리빌드 최적화
- [ ] 이미지/리소스 최적화

---

## 🔍 확인 필요 사항

### 설계 검토
- [ ] 시간 → Step 자동 매핑 규칙 최종 확인
  - 현재 제안: 06:00-11:59=아침, 12:00-17:59=낮, 18:00-23:59=저녁, 나머지=Anytime
  - 새벽 시간대(00:00-05:59) 처리 방식 확인 필요

### 알람 정책 세부화
- [ ] 알람 취소 시점 명확화
  - Todo 삭제 시
  - 시간 변경 시
  - has_alarm을 false로 변경 시
- [ ] 알람 수정 시 처리 방식 확인

---

## 📚 참고 자료

- `daily_flow_db_spec.md` - 데이터베이스 스펙
- `dailyflow_design_spec.md` - 화면 설계 스펙
- `PROGRESS.md` - 진행 상황 문서
- `REFERENCE.md` - 참고사항 문서
- `lib_doc/` - 커스텀 위젯 문서

