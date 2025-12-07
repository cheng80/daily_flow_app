# DailyFlow 앱 - 스펙 문서 폴더

이 폴더에는 DailyFlow 앱의 설계 및 개발 관련 문서들이 포함되어 있습니다.

---

## 📚 문서 목록

### 설계 문서

1. **daily_flow_db_spec.md**
   - 데이터베이스 스펙 문서
   - 테이블 구조, 컬럼 명세, 인덱스 설계
   - SQLite DDL 코드 및 DBML 정의 포함
   - Step 값: 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일 (기본값: 4)

2. **dailyflow_design_spec.md**
   - 화면 설계 문서 (Wireframe Design Specification)
   - 화면별 레이아웃 구조 및 UI/UX 설계
   - 색상 시스템, 네비게이션 구조 포함

3. **daily_flow_class_diagram.dbml** ✅
   - 엔티티 관계 다이어그램 (ERD)
   - 데이터베이스, 뷰 화면, 서비스, 사용자 행위, 앱 데이터/응답의 관계 정의
   - [dbdiagram.io](https://dbdiagram.io)에서 시각화 가능
   - 모든 핵심 기능 구현 완료 상태 반영

4. **STATISTICS_DESIGN.md** ✅
   - 달력 범위 선택 및 통계 기능 설계 문서
   - 추가 가능한 통계 항목 정리
   - 각 통계 항목에 적합한 Syncfusion 차트 타입 제안
   - 우선순위 및 구현 순서 제안

### 진행 상황 문서

4. **PROGRESS.md**
   - 개발 진행 상황 추적
   - 완료된 작업, 진행 중인 작업, 다음 작업 예정
   - 작업 일지 포함

5. **TODO.md**
   - 할 일 목록 관리
   - 우선순위별 작업 분류
   - 테스트 및 검증 항목 포함

### 참고 문서

6. **REFERENCE.md**
   - 개발 시 참고할 중요한 사항들
   - 프로젝트 구조, 데이터베이스 구조
   - 색상 시스템, Step/Priority 설명
   - 알람 정책 (과거 알람 자동 정리 포함), 삭제/복구 플로우 ✅
   - 네비게이션 (CustomNavigationUtil), 코딩 컨벤션 등 ✅
   - 로깅 시스템 (AppLogger) ✅
   - 설정 기능 (Drawer 통합) ✅

7. **TEST_RESULTS.md**
   - 단위 테스트 결과 문서
   - 테스트 항목별 통과 여부 표
   - 테스트 실행 방법 및 환경 정보
   - 테스트 커버리지 통계

---

## 🚀 빠른 시작

### 새로 시작하는 경우
1. `daily_flow_db_spec.md` - 데이터베이스 구조 이해
2. `dailyflow_design_spec.md` - 화면 설계 이해
3. `daily_flow_class_diagram.dbml` - 엔티티 관계 다이어그램 확인 (선택사항)
4. `PROGRESS.md` - 현재 진행 상황 확인 (모든 핵심 기능 구현 완료 ✅)
5. `TODO.md` - 다음 작업 확인 (고도화 개발 예정 항목 포함)
6. `REFERENCE.md` - 개발 시 참고사항 확인
7. `STATISTICS_DESIGN.md` - 통계 기능 설계 확인 (고도화 기능)

### 작업 이어가기
1. `PROGRESS.md` - 최근 완료된 작업 확인
2. `TODO.md` - 다음 우선순위 작업 확인
3. `REFERENCE.md` - 개발 가이드라인 확인
4. `TEST_RESULTS.md` - 단위 테스트 결과 확인 (필요 시)

---

## 📋 문서 업데이트 규칙

### 필수 워크플로우
**모든 작업은 문서 기반 개발 워크플로우를 따라야 합니다:**
1. 작업 시작 전: 관련 설계 문서, TODO, REFERENCE 확인
2. 작업 진행 중: 문서 요구사항과 일치하는지 확인하며 작업
3. 작업 완료 후: 문서 갱신 필요 여부 확인 및 업데이트

자세한 내용은 `REFERENCE.md`의 "4. 문서 기반 개발 워크플로우" 섹션을 참고하세요.

### 문서별 업데이트 규칙

#### PROGRESS.md
- 작업 완료 시 즉시 업데이트
- 중요한 결정 사항 기록
- 작업 일지에 날짜와 내용 기록

#### TODO.md
- 작업 시작 시 해당 항목을 "진행 중"으로 표시
- 작업 완료 시 체크박스 체크
- 새로운 작업 추가 시 우선순위에 맞게 분류

#### REFERENCE.md
- 새로운 규칙이나 정책 추가 시 업데이트
- 알려진 이슈 발생 시 추가
- 개발 팁 추가 시 업데이트

#### dailyflow_design_spec.md
- UI/UX 변경사항 반영
- 새로운 기능 추가 시 관련 섹션 업데이트
- 색상 시스템, 레이아웃 변경 시 업데이트

#### daily_flow_db_spec.md
- 데이터베이스 구조 변경 시 업데이트
- 테이블 스키마 변경 시 DDL 코드 업데이트
- Step 값이나 기본값 변경 시 업데이트

#### daily_flow_class_diagram.dbml
- 새로운 기능 추가 시 엔티티 및 관계 추가
- 뷰 화면, 서비스, 사용자 행위 변경 시 업데이트
- 데이터 흐름 변경 시 업데이트

---

## 🔗 관련 폴더

- `lib/` - 소스 코드
- `lib_doc/` - 커스텀 위젯 문서
- `test/` - 테스트 코드

---

---

## ✅ 현재 상태

**모든 핵심 기능 구현 완료** ✅

- 메인 화면 (MainView) ✅
- 일정 등록/수정 화면 (CreateTodoView, EditTodoView) ✅
- 삭제 보관함 화면 (DeletedTodosView) ✅
- Todo 상세보기 다이얼로그 (TodoDetailDialog) ✅
- 알람 기능 (NotificationService) ✅
- 로깅 시스템 (AppLogger) ✅
- 설정 기능 (Drawer 통합) ✅

**향후 개발 예정:**
- 달력 범위 선택 및 통계 기능
- 기타 고도화 항목 (TODO.md 참고)

---

**마지막 업데이트:** 2024년 12월

