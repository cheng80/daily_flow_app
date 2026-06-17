# DailyFlow 앱 - 스펙 문서 폴더

이 폴더에는 DailyFlow 앱의 설계 및 개발 관련 문서들이 포함되어 있습니다.

---

## 📚 문서 목록

### 설계 문서

1. **daily_flow_db_spec.md**
   - 데이터베이스 스펙 문서
   - 테이블 구조, 컬럼 명세, 인덱스 설계
   - SQLite DDL 코드 및 DBML 정의 포함

2. **dailyflow_design_spec.md**
   - 화면 설계 문서 (Wireframe Design Specification)
   - 애플 리마인더 기반 최소한의 핵심 기능 설계
   - 화면별 레이아웃 구조 및 UI/UX 설계
   - 색상 시스템, 네비게이션 구조 포함

3. **atomic_design_spec.md**
   - 아토믹 디자인 시스템 문서
   - Atoms, Molecules, Organisms, Templates, Pages 분류
   - 컴포넌트 사용 가이드

4. **apple_reminders_inspiration.md**
   - 애플 리마인더 기반 디자인 가이드
   - 디자인 철학 및 구현 방향
   - 핵심 기능 상세 설명

5. **daily_flow_class_diagram.dbml** ✅
   - 엔티티 관계 다이어그램 (ERD)
   - 데이터베이스, 뷰 화면, 서비스, 사용자 행위, 앱 데이터/응답의 관계 정의
   - [dbdiagram.io](https://dbdiagram.io)에서 시각화 가능
   - 모든 핵심 기능 구현 완료 상태 반영

### 참고 문서

6. **REFERENCE.md**
   - 개발 시 참고할 중요한 사항들
   - 프로젝트 구조, 데이터베이스 구조
   - 색상 시스템, Priority 설명
   - 알람 정책 (과거 알람 자동 정리 포함), 삭제/복구 플로우 ✅
   - 네비게이션 (CustomNavigationUtil), 코딩 컨벤션 등 ✅
   - 로깅 시스템 (AppLogger) ✅
   - 설정 기능 (Drawer 통합) ✅

---

## 🚀 빠른 시작

### 새로 시작하는 경우
1. `apple_reminders_inspiration.md` - 애플 리마인더 기반 디자인 철학 이해
2. `dailyflow_design_spec.md` - 화면 설계 이해
3. `atomic_design_spec.md` - 아토믹 디자인 시스템 이해
4. `daily_flow_db_spec.md` - 데이터베이스 구조 이해
5. `daily_flow_class_diagram.dbml` - 엔티티 관계 다이어그램 확인 (선택사항)
6. `REFERENCE.md` - 개발 시 참고사항 확인

### 작업 이어가기
1. `REFERENCE.md` - 개발 가이드라인 확인
2. `daily_flow_db_spec.md` - 데이터베이스 스펙 확인 (필요 시)
3. `dailyflow_design_spec.md` - 화면 설계 확인 (필요 시)

---

## 📋 문서 업데이트 규칙

### 필수 워크플로우
**모든 작업은 문서 기반 개발 워크플로우를 따라야 합니다:**
1. 작업 시작 전: 관련 설계 문서, REFERENCE 확인
2. 작업 진행 중: 문서 요구사항과 일치하는지 확인하며 작업
3. 작업 완료 후: 문서 갱신 필요 여부 확인 및 업데이트

자세한 내용은 `REFERENCE.md`의 "4. 문서 기반 개발 워크플로우" 섹션을 참고하세요.

### 문서별 업데이트 규칙

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

**현재 방향:**
- 애플 리마인더 스타일로 단순화 진행 중
- Summary Bar, Filter, 통계 기능 제거
- 핵심 기능에 집중 (할 일 추가/수정/삭제, 완료 체크, 날짜별 보기, 알람)

---

**마지막 업데이트:** 2024년 12월

