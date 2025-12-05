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

### 3. 설계 결정 사항 ✅

#### 3.1 상태 관리
- ✅ GetX 제거 결정
- ✅ 순수 Flutter (StatefulWidget) 사용
- ✅ 네비게이션: Navigator.push() 사용

#### 3.2 UI 컴포넌트
- ✅ CustomSnackBar 사용 (에러/성공 메시지)
- ✅ CustomDialog 사용 (확인 다이얼로그)
- ✅ lib_doc의 커스텀 위젯 우선 사용

#### 3.3 데이터베이스
- ✅ SQLite (sqflite 패키지)
- ✅ 스펙 문서의 컬럼명 및 타입 준수
- ✅ 소프트 삭제 구조 (휴지통 기능)

#### 3.4 코드 품질 개선
- ✅ SQL 쿼리 가독성 개선 (multi-line 문자열 사용)
- ✅ 스펙 문서 참조 주석 제거 및 자체 설명 주석으로 통합

---

## 🚧 진행 중인 작업

현재 진행 중인 작업 없음

---

## 📝 다음 작업 예정

### 1. 기능 모듈 구현 (화면 구성 전) 🔴 높은 우선순위

#### 1.1 일정 등록/수정 화면용 달력 위젯 모듈
- [ ] `lib/app_custom/custom_calendar_picker.dart` 생성
  - 기존 `CustomCalendar` 기반으로 날짜 선택 전용 위젯 구현
  - 메인 화면 달력과 유사하나 단순화된 버전 (이벤트 바 및 배지 제거)
  - 날짜 선택 시 즉시 반영
  - 다이얼로그 또는 풀스크린 모드 지원
  - 테마 색상 적용

#### 1.2 알람 기능 모듈
- [ ] `lib/service/notification_service.dart` 생성
  - `flutter_local_notifications` 초기화
  - 알람 등록/취소/업데이트 메서드
  - 알람 권한 요청 (iOS/Android)
  - 알람 정책 구현 (1 Todo당 최대 1개 알람, has_alarm=true AND time IS NOT NULL일 때만 등록)

### 2. 유틸리티 클래스 생성
- [ ] `lib/util/step_mapper_util.dart` - 시간 → Step 매핑
  - 시간대 구분: 아침(06:00-11:59), 낮(12:00-17:59), 저녁(18:00-23:59), Anytime(나머지)
  - `mapTimeToStep(String? time)` 메서드
  - `stepToKorean(int step)` 메서드

### 3. 화면 구현 🟡 중간 우선순위 (기능 모듈 완료 후)
- [ ] 메인 화면 (Main View)
  - TableCalendar 통합
  - Summary Bar 구현
  - Filter Chips 구현
  - Todo List (체크박스 + Slidable)
  
- [ ] 일정 등록 화면 (Create Todo)
  - 날짜/시간 선택
  - 제목/메모 입력
  - Step 선택
  - 저장 기능

- [ ] 일정 수정 화면 (Edit Todo)
  - 기존 데이터 로드
  - 수정 기능
  - 삭제 기능

- [ ] 하루 상세 화면 (Day Detail View)
  - 상세 요약 카드
  - Todo 상세 리스트
  - 중요도 표시

---

## 📅 작업 일지

### 2024년 (최근 작업)

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

