# DailyFlow 앱 - 통계 기능 설계 문서

이 문서는 달력 범위 선택 및 통계 기능의 추가 가능한 통계 항목들을 정리합니다.

---

## 📐 통계 데이터의 기준 축 (Axis) 개념

### 날짜의 역할

**날짜는 필터링 조건이지, 모든 통계의 기준 축이 아닙니다.**

- 날짜 범위 선택: 사용자가 선택한 기간 내의 데이터만 조회
- 각 통계 항목은 고유한 기준 축(X축)을 가짐
- 날짜는 데이터를 필터링하는 조건일 뿐

### 기준 축별 분류

| 기준 축 (X축) | 통계 항목 | 차트 타입 |
|--------------|----------|----------|
| **Step** (오전/오후/저녁/야간/종일) | Step별 개수, Step별 비율, Step별 완료율, Step별 알람 설정률 | Column Chart, Pie Chart |
| **중요도** (1~5단계) | 중요도별 개수, 중요도별 비율, 중요도별 완료율, 중요도별 알람 설정률 | Column Chart, Pie Chart |
| **완료 여부** (완료/미완료) | 완료율, 완료된 일정 평균 중요도 | Doughnut Chart, Bar Chart |
| **알람 설정 여부** (설정/미설정) | 알람 설정률, 알람 + 완료 상관관계 | Doughnut Chart, Grouped Column Chart |
| **메모 작성 여부** (작성/미작성) | 메모 작성률, 메모 + 완료 상관관계 | Doughnut Chart, Grouped Column Chart |
| **시간 설정 여부** (설정/미설정) | 시간 설정률 | Doughnut Chart |
| **날짜** (시간 추이) | 일정 생성 추이, 일별/주별 생성 개수 | Line Chart, Area Chart, Column Chart |
| **시간대** (HH:MM) | 시간대별 분포, 평균 시간대 | Column Chart, Histogram |
| **조합** (Step + 중요도) | Step별 중요도 분포, 중요도별 Step 분포 | Stacked Column Chart |

### 예시

**Step별 완료율 통계:**
- 필터링 조건: 날짜 범위 (예: 2024-12-01 ~ 2024-12-07)
- 기준 축 (X축): Step (오전, 오후, 저녁, 야간, 종일)
- 측정 값 (Y축): 완료율 (0~100%)
- 차트: Column Chart (Step별 완료율 막대 비교)

**일정 생성 추이 통계:**
- 필터링 조건: 날짜 범위 (예: 2024-12-01 ~ 2024-12-07)
- 기준 축 (X축): 날짜 (일별 또는 주별)
- 측정 값 (Y축): 생성된 일정 개수
- 차트: Line Chart (시간 추이)

---

## 📊 현재 todo 테이블 데이터 구조

| 컬럼명 | 타입 | 설명 |
|--------|------|------|
| `id` | INTEGER | 일정 고유 ID |
| `title` | TEXT | 일정 제목 |
| `memo` | TEXT | 메모 (nullable) |
| `date` | TEXT | 일정 날짜 ('YYYY-MM-DD') |
| `time` | TEXT | 일정 시간 ('HH:MM', nullable) |
| `step` | INTEGER | 시간대 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일) |
| `priority` | INTEGER | 중요도 (1~5) |
| `is_done` | INTEGER | 완료 여부 (0/1) |
| `has_alarm` | INTEGER | 알람 설정 여부 (0/1) |
| `notification_id` | INTEGER | 알람 알림 ID (nullable) |
| `created_at` | TEXT | 생성 시각 ('YYYY-MM-DD HH:MM:SS') |
| `updated_at` | TEXT | 마지막 수정 시각 ('YYYY-MM-DD HH:MM:SS') |

---

## 📈 추가 가능한 통계 항목

### 기본 통계 (이미 계획됨) ✅

1. **기간 정보**
   - 날짜 일수 (선택된 기간의 일수)
   - 총 일정 개수

2. **완료 관련 통계**
   - 완료율 (완료된 일정 / 전체 일정)
     - **차트:** `SfCircularChart` - **Doughnut Chart** (완료/미완료 비율)
   - 완료된 일정 개수
   - 미완료 일정 개수

3. **Step별 통계**
   - Step별 개수 (오전/오후/저녁/야간/종일)
     - **차트:** `SfCartesianChart` - **Column Chart** (막대 차트, 카테고리별 개수 비교)
   - Step별 비율
     - **차트:** `SfCircularChart` - **Pie Chart** (5개 Step 비율 시각화)

4. **중요도별 통계**
   - 중요도별 개수 (1~5단계)
     - **차트:** `SfCartesianChart` - **Column Chart** (중요도별 개수 비교)
   - 중요도별 비율
     - **차트:** `SfCircularChart` - **Pie Chart** 또는 **Doughnut Chart**

---

### 추가 통계 항목 (제안)

#### 1. 알람 관련 통계

**알람 설정률**
- 알람이 설정된 일정 개수
- 알람 설정 비율 (has_alarm=1인 일정 / 전체 일정)
  - **차트:** `SfCircularChart` - **Doughnut Chart** (설정/미설정 비율)
- 알람 미설정 비율

**Step별 알람 설정률**
- 각 Step(오전/오후/저녁/야간/종일)별로 알람 설정된 일정 비율
- 예: "오전 일정의 60%가 알람 설정됨"
  - **차트:** `SfCartesianChart` - **Column Chart** (Step별 알람 설정 비율 막대 비교)

**중요도별 알람 설정률**
- 각 중요도(1~5)별로 알람 설정된 일정 비율
- 예: "중요도 5단계 일정의 90%가 알람 설정됨"
  - **차트:** `SfCartesianChart` - **Column Chart** (중요도별 알람 설정 비율 막대 비교)

**알람 완료 상관관계**
- 알람 설정된 일정의 완료율 vs 알람 미설정 일정의 완료율 비교
  - **차트:** `SfCartesianChart` - **Grouped Column Chart** (두 그룹 비교: 알람 설정 vs 미설정)

---

#### 2. 메모 작성 관련 통계

**메모 작성률**
- 메모가 작성된 일정 개수 (memo IS NOT NULL)
- 메모 작성 비율
  - **차트:** `SfCircularChart` - **Doughnut Chart** (작성/미작성 비율)
- 메모 미작성 일정 개수

**Step별 메모 작성률**
- 각 Step별 메모 작성 비율
  - **차트:** `SfCartesianChart` - **Column Chart** (Step별 메모 작성 비율)

**중요도별 메모 작성률**
- 각 중요도별 메모 작성 비율
  - **차트:** `SfCartesianChart` - **Column Chart** (중요도별 메모 작성 비율)

**완료율과 메모 작성 상관관계**
- 메모 작성된 일정의 완료율 vs 미작성 일정의 완료율
  - **차트:** `SfCartesianChart` - **Grouped Column Chart** (두 그룹 비교: 작성 vs 미작성)

---

#### 3. 시간 설정 관련 통계

**시간 설정률**
- 시간이 설정된 일정 개수 (time IS NOT NULL)
- 시간 설정 비율
  - **차트:** `SfCircularChart` - **Doughnut Chart** (설정/미설정 비율)
- 시간 미설정 일정 개수 (종일 일정)

**Step별 시간 설정 분포**
- 시간 설정된 일정 중 Step별 분포
- 시간 미설정 일정 중 Step별 분포 (대부분 종일)
  - **차트:** `SfCartesianChart` - **Stacked Column Chart** (설정/미설정을 스택으로 표현)

**평균 시간대**
- 시간이 설정된 일정들의 평균 시간 계산 (HH:MM → 분 단위 변환 후 평균)
- 가장 많이 사용하는 시간대 (시간별 히스토그램)
  - **차트:** `SfCartesianChart` - **Column Chart** 또는 **Histogram** (시간대별 분포)

---

#### 4. 완료율 세부 분석

**Step별 완료율**
- 각 Step(오전/오후/저녁/야간/종일)별 완료율
- 예: "오전 일정 완료율: 75%, 저녁 일정 완료율: 45%"
  - **차트:** `SfCartesianChart` - **Column Chart** (Step별 완료율 막대 비교)

**중요도별 완료율**
- 각 중요도(1~5)별 완료율
- 예: "중요도 5단계 완료율: 90%, 중요도 1단계 완료율: 30%"
  - **차트:** `SfCartesianChart` - **Column Chart** (중요도별 완료율 막대 비교)

**Step + 중요도 조합별 완료율**
- 각 조합(오전+중요도5, 오후+중요도3 등)의 완료율
- 복잡도가 높아 선택적 구현 권장
  - **차트:** `SfCartesianChart` - **Grouped Column Chart** (Step별로 그룹화, 중요도별 비교)

**완료 일정 평균 중요도**
- 완료된 일정들의 평균 중요도
- 미완료 일정들의 평균 중요도
  - **차트:** `SfCartesianChart` - **Bar Chart** (완료/미완료 두 그룹 비교)

---

#### 5. 생성/수정 추이 통계

**일정 생성 추이**
- 기간 내 일별/주별 일정 생성 개수 (created_at 기준)
- 가장 많이 일정을 추가한 날짜/요일
- 일정 생성 패턴 분석 (평일 vs 주말)
  - **차트:** `SfCartesianChart` - **Line Chart** (시간 추이) 또는 **Area Chart** (누적 효과)
  - 일별: Line Chart
  - 주별: Column Chart (주별 비교)

**일정 수정 빈도**
- 수정된 일정 개수 (updated_at != created_at인 경우)
- 수정 비율
  - **차트:** `SfCircularChart` - **Doughnut Chart** (수정/미수정 비율)
- 평균 수정 횟수 (복잡도 높음, created_at과 updated_at 비교만으로는 정확한 수정 횟수 계산 불가)

**최근 활동**
- 최근 7일/30일 내 생성된 일정 개수
- 최근 수정된 일정 개수
  - **차트:** `SfCartesianChart` - **Combination Chart** (생성/수정 두 라인 비교) 또는 **Grouped Column Chart**

---

#### 6. 조합 통계 (고급)

**Step별 중요도 분포**
- 각 Step에서 어떤 중요도가 많이 사용되는지
- 예: "오전 일정 중 중요도 3~4단계가 70%"
  - **차트:** `SfCartesianChart` - **Stacked Column Chart** (Step별로 스택, 중요도별 비율)

**중요도별 Step 분포**
- 각 중요도에서 어떤 Step이 많이 사용되는지
- 예: "중요도 5단계 일정 중 오전/오후가 60%"
  - **차트:** `SfCartesianChart` - **Stacked Column Chart** (중요도별로 스택, Step별 비율)

**완료 패턴 분석**
- 완료율이 높은 Step + 중요도 조합
- 완료율이 낮은 Step + 중요도 조합
  - **차트:** `SfCartesianChart` - **Heat Map** (SfCartesianChart의 색상 강도로 표현) 또는 **Grouped Column Chart**

**알람 + 완료 상관관계**
- 알람 설정 + Step별 완료율
- 알람 설정 + 중요도별 완료율
  - **차트:** `SfCartesianChart` - **Grouped Column Chart** (알람 설정/미설정 그룹으로 비교)

---

#### 7. 시간 분석 통계 (time 필드 활용)

**시간대별 분포**
- 시간이 설정된 일정들을 시간대별로 그룹화
- 예: "09:00-10:00 시간대 일정 15개"
- "14:00-15:00 시간대 일정 8개"
  - **차트:** `SfCartesianChart` - **Column Chart** 또는 **Histogram** (시간대별 개수 분포)

**평균 일정 시간**
- 시간이 설정된 일정들의 평균 시간 계산
- 가장 많이 사용하는 시간대 (모드)
  - **차트:** 숫자 표시 또는 `SfCartesianChart` - **Column Chart` (시간대별 빈도)

**오전/오후/저녁 시간대 분석**
- 오전(06:00-11:59) 내에서 가장 많이 사용하는 시간
- 오후(12:00-17:59) 내에서 가장 많이 사용하는 시간
- 저녁(18:00-23:59) 내에서 가장 많이 사용하는 시간
  - **차트:** `SfCartesianChart` - **Multiple Series Line Chart` 또는 각각 별도 **Column Chart**

---

## 📊 Syncfusion 차트 타입 요약

### 사용되는 주요 차트 타입

| 차트 타입 | 위젯 | 사용 케이스 | 통계 항목 예시 |
|-----------|------|-------------|----------------|
| **Column Chart** | `SfCartesianChart`<br>`ChartType.column` | 카테고리별 값 비교 | Step별 개수, 중요도별 개수, 완료율 비교 |
| **Bar Chart** | `SfCartesianChart`<br>`ChartType.bar` | 수평 막대 비교 | 완료/미완료 평균 중요도 비교 |
| **Line Chart** | `SfCartesianChart`<br>`ChartType.line` | 시간 추이 분석 | 일정 생성 추이, 주별 생성 패턴 |
| **Area Chart** | `SfCartesianChart`<br>`ChartType.area` | 누적 데이터 강조 | 일정 생성 누적 추이 |
| **Stacked Column** | `SfCartesianChart`<br>`ChartType.stackedColumn` | 카테고리 내 세부 분포 | Step별 중요도 분포, Step별 시간 설정 분포 |
| **Grouped Column** | `SfCartesianChart`<br>`ChartType.column` (multiple series) | 여러 그룹 비교 | 알람 설정 vs 미설정 완료율 비교 |
| **Pie Chart** | `SfCircularChart`<br>`ChartType.pie` | 전체 대비 비율 | Step별 비율, 중요도별 비율 |
| **Doughnut Chart** | `SfCircularChart`<br>`ChartType.doughnut` | 비율 표시 (중앙 공간 활용) | 완료율, 알람 설정률, 메모 작성률 |
| **Combination Chart** | `SfCartesianChart`<br>(multiple series) | 여러 데이터 타입 결합 | 생성/수정 추이 동시 표시 |

### 차트 선택 가이드

1. **비율 표시**: `Doughnut Chart` (2개 카테고리: 완료/미완료, 설정/미설정 등)
2. **다중 비율**: `Pie Chart` (5개 Step 비율 등)
3. **값 비교**: `Column Chart` (카테고리별 개수, 완료율 비교)
4. **시간 추이**: `Line Chart` (일별 생성 추이)
5. **그룹 비교**: `Grouped Column Chart` (알람 설정 vs 미설정 비교)
6. **세부 분포**: `Stacked Column Chart` (Step별 중요도 분포)

---

## 🎯 데이터 가치 기준 우선순위 및 개발 순서

### 데이터 가치 평가 기준

1. **행동 패턴 분석** (사용자 생산성 향상)
2. **완료 성과 측정** (목표 달성도 확인)
3. **기능 활용도** (앱 기능 사용 패턴)
4. **시간 추이 분석** (트렌드 파악)
5. **고급 상관관계** (심층 분석)

---

## 📊 Phase 1: 핵심 통계 (최우선 개발) ⭐⭐⭐

**데이터 가치: 매우 높음** - 사용자의 일정 관리 성과를 즉시 파악 가능

### 1-1. 기본 통계 ✅ (이미 계획됨)
- **데이터 가치**: ⭐⭐⭐⭐⭐
- 날짜 일수 (선택된 기간)
- 총 일정 개수
- 완료율 (완료된 일정 / 전체 일정)
- Step별 비율 (기존 Summary Bar 로직 재사용)
- 중요도별 분포

### 1-2. Step별 완료율 ⭐
- **데이터 가치**: ⭐⭐⭐⭐⭐
- **분석 가치**: "어느 시간대에 일정을 잘 완료하는지" 파악 → 생산성 향상 기회 발견
- 각 Step(오전/오후/저녁/야간/종일)별 완료율
- **차트**: `SfCartesianChart` - **Column Chart**
- **개발 난이도**: 낮음 (완료율 계산 + Step별 그룹화)

### 1-3. 중요도별 완료율 ⭐
- **데이터 가치**: ⭐⭐⭐⭐⭐
- **분석 가치**: "중요한 일을 우선적으로 처리하는지" 확인 → 우선순위 관리 개선
- 각 중요도(1~5)별 완료율
- **차트**: `SfCartesianChart` - **Column Chart**
- **개발 난이도**: 낮음 (완료율 계산 + 중요도별 그룹화)

---

## 📊 Phase 2: 기능 활용도 통계 ⭐⭐

**데이터 가치: 높음** - 알람 기능 활용도와 효과 분석

### 2-1. 알람 설정률
- **데이터 가치**: ⭐⭐⭐⭐
- **분석 가치**: 알람 기능 활용도 확인
- 전체 알람 설정 비율 (설정/미설정)
- **차트**: `SfCircularChart` - **Doughnut Chart**
- **개발 난이도**: 매우 낮음 (단순 비율 계산)

### 2-2. 알람 + 완료 상관관계 ⭐
- **데이터 가치**: ⭐⭐⭐⭐⭐
- **분석 가치**: "알람이 완료율 향상에 도움이 되는지" 검증 → 알람 기능 가치 확인
- 알람 설정된 일정의 완료율 vs 알람 미설정 일정의 완료율 비교
- **차트**: `SfCartesianChart` - **Grouped Column Chart`
- **개발 난이도**: 중간 (두 그룹 비교 로직)

### 2-3. Step별 알람 설정률
- **데이터 가치**: ⭐⭐⭐
- **분석 가치**: 어떤 시간대 일정에 알람을 많이 설정하는지 파악
- 각 Step별 알람 설정 비율
- **차트**: `SfCartesianChart` - **Column Chart**
- **개발 난이도**: 낮음

### 2-4. 중요도별 알람 설정률
- **데이터 가치**: ⭐⭐⭐⭐
- **분석 가치**: 중요한 일정에 알람을 설정하는 패턴 확인
- 각 중요도별 알람 설정 비율
- **차트**: `SfCartesianChart` - **Column Chart**
- **개발 난이도**: 낮음

---

## 📊 Phase 3: 메모 활용도 통계 ⭐

**데이터 가치: 중간** - 기능 활용도 확인

### 3-1. 메모 작성률
- **데이터 가치**: ⭐⭐⭐
- **분석 가치**: 메모 기능 활용도 확인
- 메모 작성 비율 (작성/미작성)
- **차트**: `SfCircularChart` - **Doughnut Chart**
- **개발 난이도**: 매우 낮음

### 3-2. 메모 + 완료 상관관계
- **데이터 가치**: ⭐⭐⭐⭐
- **분석 가치**: "메모 작성이 완료율에 영향을 주는지" 검증
- 메모 작성된 일정의 완료율 vs 미작성 일정의 완료율
- **차트**: `SfCartesianChart` - **Grouped Column Chart**
- **개발 난이도**: 중간

---

## 📊 Phase 4: 시간 추이 분석 ⭐

**데이터 가치: 중간** - 패턴 파악

### 4-1. 일정 생성 추이
- **데이터 가치**: ⭐⭐⭐
- **분석 가치**: 일정 추가 패턴 확인 (평일 vs 주말, 주별 트렌드)
- 기간 내 일별/주별 일정 생성 개수
- **차트**: `SfCartesianChart` - **Line Chart** (일별) 또는 **Column Chart** (주별)
- **개발 난이도**: 중간 (날짜별 집계 필요)

### 4-2. 시간 설정률
- **데이터 가치**: ⭐⭐
- **분석 가치**: 시간을 구체적으로 설정하는 비율 확인
- 시간 설정 비율 (설정/미설정)
- **차트**: `SfCircularChart` - **Doughnut Chart**
- **개발 난이도**: 매우 낮음

---

## 📊 Phase 5: 고급 분석 (선택) 

**데이터 가치: 낮음** - 심층 분석용, 초기에는 제외 권장

### 5-1. Step별 중요도 분포
- **데이터 가치**: ⭐⭐
- **개발 난이도**: 높음 (복잡한 집계)
- **차트**: `SfCartesianChart` - **Stacked Column Chart**

### 5-2. 시간대별 세부 분석
- **데이터 가치**: ⭐⭐
- **개발 난이도**: 높음 (시간대별 그룹화)
- **차트**: `SfCartesianChart` - **Column Chart** 또는 **Histogram**

### 5-3. 일정 수정 빈도
- **데이터 가치**: ⭐
- **개발 난이도**: 높음 (정확한 수정 횟수 계산 어려움)

---

## 🚀 개발 우선순위 요약

### 1차 목표: Phase 1 - 핵심 통계 (최우선 개발) ⭐

1. ✅ **기본 통계** (이미 계획됨)
   - 날짜 일수, 총 개수, 완료율
   - Step별 비율, 중요도별 분포

2. **Step별 완료율** ⭐⭐⭐⭐⭐
   - 데이터 가치: 매우 높음
   - 개발 난이도: 낮음

3. **중요도별 완료율** ⭐⭐⭐⭐⭐
   - 데이터 가치: 매우 높음
   - 개발 난이도: 낮음

**Phase 1 목표 달성 기준:**
- 날짜 범위 선택 기능 완료
- 기본 통계 표시 완료
- Step별/중요도별 완료율 차트 완료

---

### 2차 목표: Phase 2 - 기능 활용도 통계 (Phase 1 완료 후)

4. **알람 설정률**
   - 데이터 가치: 높음
   - 개발 난이도: 매우 낮음
   - **의존성**: 없음 (독립적 개발 가능)

5. **알람 + 완료 상관관계** ⭐⭐⭐⭐⭐
   - 데이터 가치: 매우 높음
   - 개발 난이도: 중간
   - **의존성**: ⚠️ Phase 1 완료 필요 (완료율 계산 로직 활용)

6. Step별/중요도별 알람 설정률
   - **의존성**: 알람 설정률(4번) 완료 후 개발 가능

---

### 3차 개발 (Phase 3)
7. 메모 작성률 및 상관관계

### 4차 개발 (Phase 4)
8. 일정 생성 추이
9. 시간 설정률

### 선택적 개발 (Phase 5)
10. 고급 분석 통계들

---

## 💡 UI 표시 제안

### 기본 통계 카드 레이아웃

```
┌─────────────────────────────────────┐
│ 📊 기간 통계                         │
│ 2024-12-01 ~ 2024-12-07 (7일)      │
├─────────────────────────────────────┤
│ 📝 총 일정: 42개                     │
│ ✅ 완료: 28개 (66.7%)               │
│ ⏰ 알람 설정: 15개 (35.7%)          │
│ 📄 메모 작성: 18개 (42.9%)          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 🕐 Step별 완료율                     │
│ 오전   ████████░░ 80%               │
│ 오후   ███████░░░ 70%               │
│ 저녁   █████░░░░░ 50%               │
│ 야간   ████░░░░░░ 40%               │
│ 종일   ██████░░░░ 60%               │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ ⭐ 중요도별 완료율                   │
│ ⭐⭐⭐⭐⭐ ██████████ 90%           │
│ ⭐⭐⭐⭐   ████████░░ 80%           │
│ ⭐⭐⭐     ██████░░░░ 60%           │
│ ⭐⭐       ████░░░░░░ 40%           │
│ ⭐         ██░░░░░░░░ 20%           │
└─────────────────────────────────────┘
```

---

## 🔄 통계 차트 생성 방식

### 날짜 범위 선택 제약 사항

**데이터가 있는 날짜 범위로 제한:**
- 범위 선택창은 DB에서 실제 데이터가 있는 최소 날짜와 최대 날짜 사이에서만 선택 가능
- `DatabaseHandler.queryMinDate()`로 최소 날짜 조회
- `DatabaseHandler.queryMaxDate()`로 최대 날짜 조회
- 데이터가 없는 날짜 범위는 선택 불가 (의미 없는 빈 통계 방지)

**제약 사항:**
- 최소 날짜 이전: 선택 불가 (disabled)
- 최대 날짜 이후: 선택 불가 (disabled)
- 데이터가 전혀 없는 경우: 날짜 범위 선택 비활성화 또는 안내 메시지 표시

### 필터링 및 자동 생성 프로세스

1. **날짜 범위 선택**
   - 사용자가 달력에서 시작일과 종료일 선택
   - 선택 가능한 날짜 범위: DB에 데이터가 있는 최소 날짜 ~ 최대 날짜
   - 선택된 날짜 범위가 모든 통계의 필터링 조건이 됨

2. **데이터 조회**
   - `DatabaseHandler.queryDataByDateRange(startDate, endDate)` 호출
   - 선택된 날짜 범위 내의 모든 Todo 데이터 조회

3. **통계 자동 계산 및 차트 생성**
   - 조회된 데이터를 기반으로 각 통계 항목 계산
   - 계산된 결과를 Syncfusion 차트로 자동 시각화
   - 날짜 범위가 변경되면 자동으로 재계산 및 차트 업데이트

### 여러 통계 항목 표시 방식

**겹쳐서 표시 가능한 경우:**
- 같은 기준 축을 가진 여러 통계는 하나의 차트에 여러 시리즈로 표시 가능
- 예: **Grouped Column Chart** - 알람 설정 vs 미설정 완료율 비교

**별도 차트로 표시:**
- 서로 다른 기준 축을 가진 통계는 각각 별도 차트로 표시
- 예: Step별 완료율 (Step 기준 축) + 중요도별 완료율 (중요도 기준 축)

### UI 레이아웃 예시

```
┌─────────────────────────────────────┐
│ 📅 날짜 범위 선택                    │
│ 2024-12-01 ~ 2024-12-07            │
│ (선택 가능: 2024-11-15 ~ 2024-12-31)│
│ [범위 선택 버튼]                    │
└─────────────────────────────────────┘
```

┌─────────────────────────────────────┐
│ 📊 기본 통계                        │
│ 총 일정: 42개 | 완료율: 66.7%      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 📈 Step별 완료율                    │
│ [Column Chart: Step 기준 축]        │
│ 오전 ████████░░ 80%                │
│ 오후 ███████░░░ 70%                │
│ 저녁 █████░░░░░ 50%                │
│ ...                                 │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 📈 중요도별 완료율                  │
│ [Column Chart: 중요도 기준 축]      │
│ ⭐⭐⭐⭐⭐ ██████████ 90%           │
│ ⭐⭐⭐⭐   ████████░░ 80%           │
│ ...                                 │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 📈 알람 설정 vs 미설정 완료율 비교  │
│ [Grouped Column Chart: 알람 여부 기준 축]│
│ 알람 설정   ████████░░ 80%          │
│ 알람 미설정 ██████░░░░ 60%          │
└─────────────────────────────────────┘
```

### 구현 예시 코드 구조

```dart
// 1. 데이터가 있는 날짜 범위 조회 (제약 조건 설정용)
final minDate = await databaseHandler.queryMinDate();
final maxDate = await databaseHandler.queryMaxDate();

if (minDate == null || maxDate == null) {
  // 데이터가 없는 경우 안내 메시지 표시
  showMessage('통계를 생성할 데이터가 없습니다.');
  return;
}

// 2. 날짜 범위 선택 (제약 조건 적용)
final selectedDateRange = await selectDateRange(
  minDate: DateTime.parse(minDate),
  maxDate: DateTime.parse(maxDate),
);
final startDate = selectedDateRange.start;
final endDate = selectedDateRange.end;

// 2. 데이터 조회
final todos = await databaseHandler.queryDataByDateRange(startDate, endDate);

// 3. 각 통계 계산 및 차트 생성
final stepCompletionRates = calculateStepCompletionRates(todos);
final priorityCompletionRates = calculatePriorityCompletionRates(todos);
final alarmComparison = calculateAlarmCompletionComparison(todos);

// 4. 차트 위젯 생성
Column(
  children: [
    // Step별 완료율 차트
    SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Step'),
      ),
      series: <ChartSeries>[
        ColumnSeries<StepData, String>(
          dataSource: stepCompletionRates,
          xValueMapper: (StepData data, _) => data.stepName,
          yValueMapper: (StepData data, _) => data.completionRate,
        ),
      ],
    ),
    
    // 중요도별 완료율 차트
    SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: '중요도'),
      ),
      series: <ChartSeries>[
        ColumnSeries<PriorityData, int>(
          dataSource: priorityCompletionRates,
          xValueMapper: (PriorityData data, _) => data.priority,
          yValueMapper: (PriorityData data, _) => data.completionRate,
        ),
      ],
    ),
    
    // 알람 설정 vs 미설정 비교 차트 (겹쳐서 표시)
    SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: '완료율'),
      ),
      series: <ChartSeries>[
        ColumnSeries<AlarmData, String>(
          dataSource: alarmComparison,
          xValueMapper: (AlarmData data, _) => data.category,
          yValueMapper: (AlarmData data, _) => data.completionRate,
          name: '완료율',
        ),
      ],
    ),
  ],
)
```

### 동적 업데이트

- 날짜 범위 변경 시 자동으로:
  1. 새로운 날짜 범위로 데이터 재조회
  2. 모든 통계 재계산
  3. 모든 차트 자동 업데이트 (setState 호출)

### 성능 고려

- 넓은 날짜 범위 선택 시에도 인덱스 활용으로 빠른 조회
- 통계 계산은 메모리에서 수행 (애플리케이션 레이어)
- 차트 렌더링은 Syncfusion의 최적화된 렌더링 활용

---

## 📝 구현 순서 제안

### Phase 1: 기본 통계 (현재 계획)
- ✅ 날짜 일수, 총 개수
- ✅ 완료율
- ✅ Step별 비율
- ✅ 중요도별 분포

### Phase 2: 알람 관련 통계
- 알람 설정률
- Step별 알람 설정률
- 알람 + 완료 상관관계

### Phase 3: 완료율 세부 분석
- Step별 완료율
- 중요도별 완료율

### Phase 4: 기타 통계 (선택)
- 메모 작성률
- 시간 설정률
- 생성/수정 추이

---

**마지막 업데이트:** 2024-12-07

