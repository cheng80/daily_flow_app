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

### 2. 설계 결정 사항 ✅

#### 2.1 상태 관리
- ✅ GetX 제거 결정
- ✅ 순수 Flutter (StatefulWidget) 사용
- ✅ 네비게이션: Navigator.push() 사용

#### 2.2 UI 컴포넌트
- ✅ CustomSnackBar 사용 (에러/성공 메시지)
- ✅ CustomDialog 사용 (확인 다이얼로그)
- ✅ lib_doc의 커스텀 위젯 우선 사용

#### 2.3 데이터베이스
- ✅ SQLite (sqflite 패키지)
- ✅ 스펙 문서의 컬럼명 및 타입 준수
- ✅ 소프트 삭제 구조 (휴지통 기능)

---

## 🚧 진행 중인 작업

현재 진행 중인 작업 없음

---

## 📝 다음 작업 예정

### 1. 색상 시스템 보완
- [ ] `AppColorScheme`에 중요도 색상 5개 추가
  - PriorityVeryLow (1단계: 매우 낮음 - 회색 #9E9E9E)
  - PriorityLow (2단계: 낮음 - 파랑 #1E88E5)
  - PriorityMedium (3단계: 보통 - 초록 #43A047)
  - PriorityHigh (4단계: 높음 - 주황 #FB8C00)
  - PriorityVeryHigh (5단계: 매우 높음 - 빨강 #E53935)
- [ ] 라이트/다크 테마 모두 적용

### 2. 유틸리티 클래스 생성
- [ ] `lib/util/step_mapper_util.dart` - 시간 → Step 매핑
  - 시간대 구분: 아침(06:00-11:59), 낮(12:00-17:59), 저녁(18:00-23:59), Anytime(나머지)
  - `mapTimeToStep(String? time)` 메서드
  - `stepToKorean(int step)` 메서드

### 3. 화면 구현
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

