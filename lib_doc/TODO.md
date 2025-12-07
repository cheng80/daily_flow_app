# TODO - 유틸리티 클래스 구현 계획

## 완료된 항목 ✅

### 높은 우선순위

- ✅ **DateUtil** - 날짜/시간 관련 유틸리티 (CustomCommonUtil에 통합)
- ✅ **StringUtil** - 문자열 관련 유틸리티 (CustomCommonUtil에 통합)
- ✅ **ValidationUtil** - 검증 관련 유틸리티 (CustomCommonUtil에 통합)
- ✅ **FormatUtil** - 포맷팅 관련 유틸리티 (CustomCommonUtil에 통합)
- ✅ **CustomCupertinoDatePicker** - iOS 스타일 날짜 선택기
- ✅ **CustomDatePicker** - Material Design 날짜 선택
- ✅ **CustomPickerView** - 리스트 선택 위젯
- ✅ **CustomGridView** - 그리드 레이아웃
- ✅ **CustomDropdownButton** - 드롭다운 메뉴
- ✅ **CustomExpansionTile** - 접을 수 있는 리스트 아이템 위젯
- ✅ **CustomChip** - 태그, 필터, 선택 표시용 Chip 위젯
- ✅ **CustomBottomSheet** - 하단 시트 다이얼로그 헬퍼
- ✅ **CustomProgressIndicator** - 로딩 및 진행률 표시 위젯
- ✅ **CustomRefreshIndicator** - Pull to refresh 기능
- ✅ **CustomFloatingActionButton** - FloatingActionButton 래핑
- ✅ **CustomDrawer** - 사이드 드로어 메뉴 위젯

### 중간 우선순위

- ✅ **NumberUtil** - 숫자 관련 유틸리티 (CustomCommonUtil에 통합)
- ✅ **DebounceUtil / ThrottleUtil** - 디바운싱/스로틀링 유틸리티 (TimerUtil에 통합)
- ✅ **StorageUtil** - 로컬 데이터 저장 유틸리티 (`lib/custom/external_util/storage/`)
- ✅ **CollectionUtil** - 컬렉션 조작 유틸리티 (`lib/custom/util/collection/`)
- ✅ **TimerUtil** - 타이머 관리 유틸리티 (`lib/custom/util/timer/`)
- ✅ **JsonUtil** - JSON 변환 유틸리티 (`lib/custom/util/json/`)
- ✅ **NetworkUtil** - HTTP 통신 유틸리티 (`lib/custom/external_util/network/`) - http 패키지 사용

---

## 남은 구현 항목

### 중간 우선순위 (필요시 추가)

#### 8. CustomStepper

**우선순위**: 중간 ⭐⭐  
**파일**: `lib/custom/custom_stepper.dart`

**기능 설명**:

- 단계별 진행 표시 위젯
- Stepper를 래핑하여 간편하게 사용
- 기본 스타일 및 단계 관리 제공

**주요 사용 사례**:

- 멀티 스텝 폼
- 단계별 진행 표시
- 온보딩 프로세스
- 주문 프로세스

**예시 사용법**:

```dart
CustomStepper(
  currentStep: 0,
  steps: [
    StepperStep(title: Text("1단계"), content: Step1Content()),
    StepperStep(title: Text("2단계"), content: Step2Content()),
  ],
  onStepTapped: (index) {},
)
```

**상태**: 📋 진행 예정

---

#### 9. LogUtil

**우선순위**: 중간  
**파일**: `lib/custom/util/log/custom_log_util.dart` (별도 파일)

**기능 설명**:

- 레벨별 로깅 (debug, info, warning, error)
- 릴리즈 모드에서 자동 비활성화
- 파일 로깅 지원 (선택적)
- 로그 포맷팅

**주요 사용 사례**:

- 디버깅 정보 출력
- 에러 추적
- 사용자 행동 로깅
- 성능 모니터링

**예시 사용법**:

```dart
LogUtil.d('디버그 메시지');
LogUtil.i('정보 메시지');
LogUtil.w('경고 메시지');
LogUtil.e('에러 메시지', error: exception);

// 태그와 함께 사용
LogUtil.d('디버그 메시지', tag: 'API');
```

**구현 필요 메서드**:

- `d(String message, {String? tag, Object? error})` - 디버그 로그
- `i(String message, {String? tag})` - 정보 로그
- `w(String message, {String? tag, Object? error})` - 경고 로그
- `e(String message, {String? tag, Object? error, StackTrace? stackTrace})` - 에러 로그
- `setEnabled(bool enabled)` - 로깅 활성화/비활성화
- `setLogLevel(LogLevel level)` - 로그 레벨 설정

**상태**: 📋 계획 중

---

### 낮은 우선순위 (특수한 경우에만)

#### 9. ColorUtil

**우선순위**: 낮음  
**파일**: `lib/custom/util/color/custom_color_util.dart` (별도 파일)

**기능 설명**:

- Hex ↔ Color 변환
- 밝기 조절 (밝게/어둡게)
- 대비 색상 계산 (텍스트 가독성)
- 그라데이션 생성
- 색상 혼합

**주요 사용 사례**:

- 디자인 시스템에서 색상 관리
- 다크모드 지원
- 접근성 향상 (가독성 개선)

**상태**: 📋 계획 중

---

#### 10. FileUtil

**우선순위**: 낮음  
**파일**: `lib/custom/util/file/custom_file_util.dart` (별도 파일)

**기능 설명**:

- 파일 확장자 추출
- 파일 크기 확인
- 파일 존재 여부 확인
- 파일 읽기/쓰기 (간편한 래핑)
- 이미지 리사이징

**의존성**: `path_provider`, `image` 패키지 필요 (이미지 리사이징 시)

**상태**: 📋 계획 중

---

#### 11. DeviceUtil

**우선순위**: 낮음  
**파일**: `lib/custom/util/device/custom_device_util.dart` (별도 파일)

**기능 설명**:

- 플랫폼 확인 (iOS, Android, Web)
- 디바이스 정보 (모델명, OS 버전 등)
- 화면 크기/밀도 정보
- 키보드 높이 확인

**의존성**: `device_info_plus` 패키지 필요

**상태**: 📋 계획 중

---

#### 12. CryptoUtil

**우선순위**: 낮음  
**파일**: `lib/custom/util/crypto/custom_crypto_util.dart` (별도 파일)

**기능 설명**:

- 해시 생성 (MD5, SHA256 등)
- 암호화/복호화 (AES 등)
- Base64 인코딩/디코딩
- 랜덤 문자열 생성

**의존성**: `crypto`, `encrypt` 패키지 필요

**상태**: 📋 계획 중

---

#### 13. NetworkUtil (Connectivity)

**우선순위**: 낮음  
**파일**: `lib/custom/util/network/custom_network_util.dart` (별도 파일)

**기능 설명**:

- 인터넷 연결 확인
- 네트워크 타입 확인 (WiFi, 모바일 등)
- URL 파라미터 파싱/생성
- 헤더 관리

**의존성**: `connectivity_plus` 패키지 필요

**참고**: HTTP 통신용 NetworkUtil은 이미 구현 완료 (`lib/custom/external_util/network/`). 이 항목은 네트워크 상태 확인용입니다.

**상태**: 📋 계획 중

---

#### 14. CustomExpansionPanel

**우선순위**: 낮음  
**파일**: `lib/custom/custom_expansion_panel.dart`

**기능 설명**:

- 확장 가능한 패널 리스트 위젯
- ExpansionPanelList를 래핑하여 간편하게 사용
- ExpansionTile과 유사하지만 리스트 형태

**주요 사용 사례**:

- 확장 가능한 패널 리스트
- FAQ 리스트
- 설정 섹션

**상태**: 📋 계획 중

---

#### 15. CustomDataTable

**우선순위**: 낮음  
**파일**: `lib/custom/custom_data_table.dart`

**기능 설명**:

- 테이블 데이터 표시 위젯
- DataTable을 래핑하여 간편하게 사용
- 정렬, 필터링 기능 제공

**주요 사용 사례**:

- 데이터 테이블 표시
- 관리자 페이지
- 통계 데이터 표시

**상태**: 📋 계획 중

---

## 전체 다국어 지원 적용

**우선순위**: 낮음 (AudioUtil보다 위)  
**상태**: 📋 계획 중

**기능 설명**:

- 모든 커스텀 위젯과 유틸리티에 다국어 지원 추가
- intl 패키지를 활용한 자동 생성 방식 또는 직접 리소스 관리 방식 선택
- 모든 하드코딩된 문자열을 다국어 리소스로 변환

**참고**:

- DatePicker, CupertinoDatePicker 등은 이미 MaterialApp의 `localizationsDelegates`와 `supportedLocales` 설정으로 다국어 지원이 완료됨
- 이 항목은 위젯 내부의 모든 텍스트(버튼 라벨, 에러 메시지, 힌트 텍스트 등)에 대한 다국어 지원을 의미함

**주요 작업 내용**:

1. **다국어 리소스 파일 생성**

   - `lib/l10n/` 폴더 구조 생성
   - ARB 파일 또는 직접 리소스 파일 생성
   - 지원 언어: 한국어, 영어, 일본어 (필요시 확장)

2. **위젯별 다국어 적용**

   - CustomText: 다국어 문자열 지원
   - CustomButton: 버튼 텍스트 다국어화
   - CustomDialog: 다이얼로그 메시지 다국어화
   - CustomSnackBar: 알림 메시지 다국어화
   - CustomTextField: 힌트, 에러 메시지 다국어화
   - CustomAppBar: 제목 다국어화
   - 기타 모든 위젯의 하드코딩된 문자열

3. **유틸리티 다국어 적용**

   - CustomCommonUtil: 에러 메시지, 포맷팅 텍스트
   - 기타 유틸리티의 메시지들

4. **문서화**
   - 다국어 지원 가이드 작성
   - 사용 예시 추가

**예상 구현 방법**:

**옵션 1: intl 패키지 사용 (권장)**

```yaml
dependencies:
  intl: ^0.19.0
```

```dart
// l10n/app_en.arb
{
  "@@locale": "en",
  "confirm": "Confirm",
  "cancel": "Cancel",
  "@confirm": {
    "description": "Confirm button text"
  }
}

// l10n/app_ko.arb
{
  "@@locale": "ko",
  "confirm": "확인",
  "cancel": "취소"
}
```

**옵션 2: 직접 리소스 관리**

```dart
// lib/l10n/strings.dart
class Strings {
  static String getString(BuildContext context, String key) {
    // 로케일 기반 문자열 반환
  }
}
```

**구현 필요 사항**:

- 다국어 리소스 파일 구조 설계
- 모든 위젯의 하드코딩된 문자열 식별 및 리소스화
- 다국어 지원 유틸리티 클래스 또는 Extension 생성
- 테스트 및 검증

**의존성**: `intl: ^0.19.0` (옵션 1 선택 시)

**상태**: 📋 계획 중

---

## AudioUtil (Sound 관련)

**우선순위**: 낮음 (다국어보다 아래)  
**파일**: `lib/custom/util/audio/custom_audio_util.dart` (별도 파일)

**기능 설명**:

- 오디오 재생, 일시정지, 정지 제어
- ID 기반 여러 오디오 동시 관리 (TimerUtil과 유사한 구조)
- 볼륨, 재생 속도, 피치 조절
- 재생 상태 모니터링 (스트림 기반)
- 배경 재생 지원
- 재생 완료 콜백

**주요 사용 사례**:

- 효과음 재생 (버튼 클릭, 알림 등)
- 배경음악 재생
- 음성 안내 재생
- 게임 사운드 효과

**예시 사용법**:

```dart
// Asset 파일 재생
await CustomAudioUtil.playById(
  'click',
  AudioSource.asset('sounds/click.mp3'),
);

// 네트워크 URL 재생
await CustomAudioUtil.playById(
  'bgm',
  AudioSource.url('https://example.com/music.mp3'),
);

// 일시정지/재개
CustomAudioUtil.pauseById('bgm');
CustomAudioUtil.resumeById('bgm');

// 볼륨 조절 (0.0 ~ 1.0)
await CustomAudioUtil.setVolumeById('bgm', 0.5);

// 재생 속도 조절
await CustomAudioUtil.setPlaybackRateById('bgm', 1.5);

// 재생 상태 모니터링
CustomAudioUtil.getPlayerStateStreamById('bgm').listen((state) {
  print('재생 중: ${state.playing}');
});

// 재생 완료 콜백
CustomAudioUtil.setOnCompleteById('bgm', () {
  print('재생 완료');
});

// 정지
CustomAudioUtil.stopById('bgm');

// 모든 오디오 정지
CustomAudioUtil.stopAll();
```

**구현 필요 메서드**:

- `playById(String id, AudioSource source)` - ID로 오디오 재생
- `pauseById(String id)` - ID로 일시정지
- `resumeById(String id)` - ID로 재개
- `stopById(String id)` - ID로 정지
- `setVolumeById(String id, double volume)` - 볼륨 조절 (0.0 ~ 1.0)
- `setPlaybackRateById(String id, double rate)` - 재생 속도 조절
- `seekById(String id, Duration position)` - 재생 위치 이동
- `getPlayerStateStreamById(String id)` - 재생 상태 스트림
- `getPositionStreamById(String id)` - 재생 위치 스트림
- `setOnCompleteById(String id, VoidCallback callback)` - 재생 완료 콜백
- `stopAll()` - 모든 오디오 정지
- `getActivePlayerIds()` - 활성 플레이어 ID 목록
- `isPlaying(String id)` - 재생 중인지 확인
- `isPaused(String id)` - 일시정지 중인지 확인

**의존성**: `audioplayers` 또는 `just_audio` 패키지 필요

**상태**: 📋 계획 중

---

## 구현 우선순위 요약

### ✅ 완료된 높은 우선순위 항목

1. ✅ **CustomExpansionTile** - FAQ, 아코디언 메뉴에 필수
2. ✅ **CustomChip** - 태그, 필터에 매우 유용
3. ✅ **CustomBottomSheet** - 하단 시트 UI에 필수
4. ✅ **CustomProgressIndicator** - 로딩 표시에 필수
5. ✅ **CustomRefreshIndicator** - Pull to refresh에 필수
6. ✅ **CustomFloatingActionButton** - 주요 액션 버튼에 필수
7. ✅ **CustomDrawer** - 사이드 메뉴에 유용

### 필요시 구현 (중간 우선순위)

1. **CustomStepper** - 멀티 스텝 폼에 유용
2. **LogUtil** - 디버깅에 유용

### 필요시 구현 (낮은 우선순위)

1. **ColorUtil** - 디자인 시스템이 복잡한 경우
2. **FileUtil** - 파일 처리가 많은 경우
3. **DeviceUtil** - 플랫폼별 분기가 많은 경우
4. **CryptoUtil** - 보안이 중요한 경우
5. **NetworkUtil (Connectivity)** - 네트워크 상태 확인이 필요한 경우
6. **CustomExpansionPanel** - ExpansionTile과 유사하지만 리스트 형태가 필요한 경우
7. **CustomDataTable** - 테이블 데이터 표시가 필요한 경우

### 차후 구현 (낮은 우선순위)

1. **전체 다국어 지원 적용** - 모든 위젯의 하드코딩된 문자열 다국어화
2. **AudioUtil** - 사운드 재생이 필요한 경우

---

## 구현 시 고려사항

1. **의존성 최소화**: 가능한 한 외부 패키지 없이 구현
2. **타입 안전성**: null-safety를 고려한 안전한 구현
3. **에러 처리**: 예외 상황에 대한 적절한 처리
4. **성능**: 자주 호출되는 함수는 성능 최적화
5. **문서화**: 각 함수의 사용법과 예시를 문서화
6. **테스트**: 각 유틸리티 함수에 대한 단위 테스트 작성

---

## 고도화 개발 예정 항목

### 날짜 범위 선택 및 범위 통계 기능

**우선순위**: 중간 ⭐⭐  
**상태**: 📋 검토 완료, 구현 대기

**기능 설명**:

달력에서 시작일과 종료일을 선택하여 해당 기간의 일정 통계를 확인하는 기능입니다.
현재는 하루 단위 통계만 제공되지만, 이를 주간/월간 단위로 확장합니다.

**주요 기능**:

1. **날짜 범위 선택**
   - `CustomCalendar`에 `rangeSelectionMode` 활성화
   - 사용자가 달력에서 시작일과 종료일을 드래그 또는 클릭으로 선택
   - 반대로 선택한 경우 자동으로 시작일/종료일 정렬 (이전 날짜가 시작일)

2. **범위 통계 데이터 모델**
   - 선택된 날짜 범위의 일수 계산
   - 범위 내 전체 일정 개수 집계
   - Step별 통계 (오전/오후/저녁/야간/종일)
   - 중요도별 통계 (1~5단계)
   - 완료율 통계 (완료된 일정 / 전체 일정)

3. **데이터베이스 쿼리 확장**
   - `DatabaseHandler`에 `queryDataByDateRange(String startDate, String endDate)` 메서드 추가
   - 날짜 범위 내의 모든 Todo 조회 (인덱스 활용하여 성능 최적화)

4. **통계 계산 함수 확장**
   - `calculateRangeSummaryRatios` 함수 추가 (범위별 Step 비율)
   - `calculateRangeStatistics` 함수 추가 (범위별 종합 통계)
   - 기존 단일 날짜 통계와 공존 (모드에 따라 선택적 사용)

5. **UI 표시**
   - Summary Bar를 범위 모드에서도 표시 (범위 내 전체 Step 비율)
   - 범위 통계 카드 추가:
     - "선택 기간: X일"
     - "총 일정: XX개"
     - "완료율: XX%"
     - Step별 분포 (바 차트)
     - 중요도별 분포 (바 차트)

**구현 필요 사항**:

1. **`lib/vm/database_handler.dart`**
   ```dart
   /// 날짜 범위 내의 todo 조회
   Future<List<Todo>> queryDataByDateRange(String startDate, String endDate) async {
     // WHERE date >= ? AND date <= ? 쿼리
   }
   ```

2. **`lib/app_custom/app_common_util.dart`**
   ```dart
   /// 범위 통계 데이터 모델
   class AppRangeStatistics {
     final int dayCount;           // 선택된 날짜 일수
     final int totalTodoCount;     // 전체 일정 개수
     final int completedCount;     // 완료된 일정 개수
     final double completedRatio;  // 완료율 (0.0 ~ 1.0)
     final AppSummaryRatios stepRatios;  // Step별 비율
     final Map<int, int> priorityDistribution;  // 중요도별 분포 (1~5)
   }
   
   /// 날짜 범위의 일정 통계 계산
   Future<AppRangeStatistics> calculateRangeStatistics(
     DatabaseHandler dbHandler,
     String startDate,
     String endDate,
   ) async { ... }
   ```

3. **`lib/app_custom/custom_calendar.dart`**
   - `rangeSelectionMode` 파라미터 추가
   - `selectedRangeStart`, `selectedRangeEnd` 상태 관리
   - `onRangeSelected` 콜백 추가
   - 선택된 범위 시각적 표시 (시작일/종료일 강조, 범위 배경색)

4. **`lib/view/main_view.dart`**
   - 범위 선택 모드 토글 버튼 추가
   - 범위 선택 시 범위 통계 자동 계산 및 표시
   - 범위 통계 카드 위젯 추가

**기술적 고려사항**:

- `table_calendar` 패키지가 `rangeSelectionMode`를 지원하는지 확인 필요
- 날짜 범위가 클 경우 (예: 1년) 성능 이슈 고려 (페이지네이션 또는 샘플링)
- 단일 날짜 모드와 범위 모드 전환 시 기존 상태 보존
- 범위 선택 취소 기능 (전체 선택 해제)

**의존성**: 
- 기존 `table_calendar` 패키지 (rangeSelectionMode 지원 여부 확인 필요)

**예상 구현 시기**: 필요 시 (통계 분석 기능이 필요한 경우)

---

### NetworkUtil 고도화 (dio 패키지 마이그레이션)

**현재 상태**: http 패키지 사용 중

**고도화 목표**: dio 패키지로 마이그레이션하여 고급 기능 추가

**추가 예정 기능**:

- **인터셉터**: 요청/응답 전처리, 로깅, 에러 처리
- **자동 재시도**: 네트워크 에러 시 자동 재시도 (지수 백오프)
- **요청 취소**: 진행 중인 요청 취소 기능
- **파일 업로드/다운로드**: 멀티파트 업로드, 진행률 추적
- **응답 변환기**: 자동 JSON 변환, 커스텀 변환기
- **캐싱**: 요청 결과 캐싱 (선택적)
- **동시 요청 제한**: 동시 요청 수 제한
- **요청 큐**: 요청 순서 관리

**의존성**: `dio: ^5.4.0` 패키지 필요

**예상 구현 시기**: 필요 시 (고급 기능이 필요한 경우)

---

## 참고사항

- 각 유틸리티는 필요에 따라 점진적으로 추가하는 것을 권장
- 프로젝트 특성에 맞는 유틸리티만 선택적으로 구현
- 외부 패키지가 필요한 경우, 의존성을 명확히 문서화

---

## 구조 개선 계획

### 단일 Import 구조 구현 (방법 2) ✅ 완료

**목표**: GetX처럼 `import 'package:custom_test_app/custom.dart';` 하나로 모든 위젯과 유틸리티 사용 가능

**구조**:

```
lib/
├── custom.dart                    # 편의용: widgets + utils 모두 export
└── custom/
    ├── widgets.dart               # 위젯만 export
    ├── utils_core.dart            # 핵심 유틸리티만 export (의존성 없음)
    └── util/                      # 유틸리티 폴더
        ├── storage/               # 스토리지 유틸리티
        └── network/               # 네트워크 유틸리티
    ├── custom_full.dart           # 전체 기능 export (의존성 필요)
    └── ... (기존 파일들 그대로)
```

**사용 방법**:

```dart
// 위젯만 필요한 경우
import 'package:custom_test_app/custom/widgets.dart';

// 유틸리티만 필요한 경우
import 'package:custom_test_app/custom/utils_core.dart';

// 둘 다 필요한 경우
import 'package:custom_test_app/custom/custom.dart';
```

**상태**: ✅ 완료

---

## 최근 완료 사항 (2024)

### 높은 우선순위 위젯 7개 구현 완료 ✅

다음 위젯들이 구현되어 예제 페이지와 함께 제공됩니다:

1. ✅ **CustomExpansionTile** - FAQ, 아코디언 메뉴에 필수
2. ✅ **CustomChip** - 태그, 필터에 매우 유용
3. ✅ **CustomBottomSheet** - 하단 시트 UI에 필수
4. ✅ **CustomProgressIndicator** - 로딩 표시에 필수
5. ✅ **CustomRefreshIndicator** - Pull to refresh에 필수
6. ✅ **CustomFloatingActionButton** - 주요 액션 버튼에 필수
7. ✅ **CustomDrawer** - 사이드 메뉴에 유용

**예제 페이지**:
- `layout_widgets_page.dart`: ExpansionTile, Chip, ProgressIndicator, RefreshIndicator 예시
- `bottom_sheet_page.dart`: BottomSheet 다양한 사용 예시
- `navigation_widgets_page.dart`: FAB 타입별 예시 및 Drawer 예시

**문서 업데이트**:
- Reference 폴더 구조로 문서 재구성 완료
- 각 위젯별 상세 문서 추가 완료
- README.md에 새로운 위젯 반영 완료

**버그 수정**:
- DrawerHeader overflow 문제 해결
- FAB 타입별 예시를 실제로 동작하도록 개선
- Drawer에서 홈으로 돌아가기 기능 추가

---

### 향후 리팩토링 계획 (방법 3) 🔮

**목표**: 위젯을 카테고리별 폴더로 재구성하여 더 체계적인 구조 만들기

**구조**:

```
lib/
├── custom.dart                    # widgets + utils 모두 export
└── custom/
    ├── widgets.dart               # 위젯들 export (경로만 변경)
    ├── utils_core.dart            # 핵심 유틸리티 export
    └── util/                      # 유틸리티 폴더
        ├── storage/               # 스토리지 유틸리티
        └── network/               # 네트워크 유틸리티
    ├── custom_full.dart           # 전체 기능 export
    ├── widgets/
    │   ├── basic/                 # 기본 위젯 (Text, Button, Column, Row, Padding)
    │   ├── layout/                # 레이아웃 위젯 (Card, Container, Image, IconButton, ListView)
    │   ├── input/                 # 입력 위젯 (TextField)
    │   ├── navigation/            # 네비게이션 위젯 (AppBar, BottomNavBar, TabBar)
    │   └── dialog/                # 다이얼로그/알림 (Dialog, SnackBar, ActionSheet)
    └── utils/
        ├── custom_common_util.dart
        └── util/ (기존 구조 유지)
```

**장점**:

- 더 체계적인 파일 구조
- 카테고리별 관리 용이
- 확장성 향상

**전환 시 작업**:

- 파일 이동: 위젯 파일들을 카테고리별 폴더로 이동
- Export 파일 수정: `widgets.dart`, `utils_core.dart`의 export 경로 변경
- `custom_full.dart`에서 `external_util/storage/custom_storage_util.dart`, `external_util/network/custom_network_util.dart` 직접 export
- 사용자 코드 변경: 없음 (export 파일을 통해 접근하므로)

**상태**: 🔮 향후 리팩토링 예정 (방법 2 완료 후 진행)
