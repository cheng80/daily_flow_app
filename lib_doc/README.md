# 커스텀 위젯 및 유틸리티 개발 문서

이 폴더에는 커스텀 위젯 클래스들과 유틸리티 클래스들의 개발 문서와 예제 문서가 포함되어 있습니다.

## 문서 구조

### 위젯 레퍼런스

- [기본 위젯](./Reference/Widgets/01_Basic_Widgets.md) - Text, Button, Column, Row, Padding 등
- [레이아웃 위젯](./Reference/Widgets/02_Layout_Widgets.md) - Card, Container, Image, GridView, ExpansionTile, Chip, ProgressIndicator, RefreshIndicator 등
- [입력 위젯](./Reference/Widgets/03_Input_Widgets.md) - TextField, Switch, Checkbox, Radio, Slider, Rating, DropdownButton 등
- [네비게이션 위젯](./Reference/Widgets/04_Navigation_Widgets.md) - AppBar, BottomNavBar, TabBar, FloatingActionButton, Drawer 등
- [다이얼로그 및 알림](./Reference/Widgets/05_Dialog_Notifications.md) - Dialog, SnackBar, ActionSheet, BottomSheet

### 유틸리티 레퍼런스

- [유틸리티](./Reference/Utilities/06_Utilities.md) - CommonUtil, StorageUtil, CollectionUtil, TimerUtil, JsonUtil, NetworkUtil

### 기타 문서

- [TODO](./TODO.md) - 구현 계획 및 진행 상황

## 주요 특징

모든 커스텀 위젯은 다음 원칙을 따릅니다:

- **기본값 제공**: 필수 요소만 입력하면 기본형으로 생성
- **유연한 커스터마이징**: 모든 속성을 선택적으로 오버라이드 가능
- **String/Widget 지원**: 텍스트 관련 속성은 String 또는 Widget 모두 지원
- **일관된 네이밍**: Custom 접두사 사용
- **테마 색상 자동 지원**: `AppColorScheme`이 있는 경우 자동으로 테마 색상 사용, 없으면 Material 기본값 사용

## 빠른 시작

### 다국어 지원 설정

DatePicker 및 CupertinoDatePicker의 언어는 MaterialApp의 `localizationsDelegates`와 `supportedLocales` 설정에 따라 결정됩니다.

**pubspec.yaml 설정:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
```

**main.dart 설정 예시:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 다국어 지원
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 영어
        const Locale('ko', 'KR'), // 한국어
        const Locale('ja', 'JP'), // 일본어
      ],
      // ... 기타 설정
    );
  }
}
```

**주의사항:**

- DatePicker의 언어는 디바이스의 언어 설정에 따라 자동으로 변경됩니다.
- 특정 언어를 강제하려면 `CustomDatePicker.show()`의 `locale` 파라미터를 사용하세요.
- `flutter_localizations`는 Flutter SDK에 포함되어 있어 `pubspec.yaml`에 추가만 하면 됩니다.

### Import 방법

```dart
// 단일 import (권장) - 모든 위젯과 유틸리티 사용
import 'package:custom_test_app/custom/custom.dart';

// 선택적 import - 위젯만 필요한 경우
import 'package:custom_test_app/custom/widgets.dart';

// 선택적 import - 핵심 유틸리티만 필요한 경우
import 'package:custom_test_app/custom/utils_core.dart';

// 선택적 import - 전체 유틸리티 (외부 패키지 의존성 필요)
import 'package:custom_test_app/custom/custom_full.dart';
```

### 테마 색상 지원

커스텀 위젯들은 `AppColorScheme`을 자동으로 감지하여 테마 색상을 사용합니다:

- **테마가 있는 경우**: `context.palette`를 통해 테마 색상 자동 적용
- **테마가 없는 경우**: Material Theme 기본값 사용 (다른 앱에서도 사용 가능)

**사용 예시:**
```dart
// 테마 색상 자동 적용 (backgroundColor를 지정하지 않으면 테마 primary 색상 사용)
CustomButton(btnText: "확인", onCallBack: () {})

// 명시적으로 색상 지정 (테마 색상보다 우선)
CustomButton(
  btnText: "확인",
  backgroundColor: Colors.red, // 명시적 색상이 우선
  onCallBack: () {},
)

// 테마 색상 직접 사용
final p = context.palette;
CustomButton(
  btnText: "확인",
  backgroundColor: p.primary, // 테마 primary 색상
  onCallBack: () {},
)
```

### 사용 예시

```dart
// 기본 사용 (테마 색상 자동 적용)
CustomText("안녕하세요") // 테마 textPrimary 색상 사용
CustomButton(btnText: "확인", onCallBack: () {}) // 테마 primary 색상 사용
CustomAppBar(title: "홈") // 테마 primary 배경색 사용

// Widget 사용
CustomButton(
  btnText: Row(children: [Icon(Icons.check), Text("확인")]),
  onCallBack: () {},
)

// 유틸리티 사용
CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd');
CustomCollectionUtil.unique([1, 2, 2, 3]);

// 날짜 선택
final selectedDate = await CustomDatePicker.show(context: context);

// 드롭다운 메뉴
CustomDropdownButton<String>(
  value: selectedValue,
  items: ['옵션1', '옵션2'],
  onChanged: (value) {},
)

// 그리드 뷰
CustomGridView(
  itemCount: 20,
  crossAxisCount: 2,
  itemBuilder: (context, index) => Card(...),
)

// ExpansionTile
CustomExpansionTile(
  title: Text("FAQ"),
  children: [Text("답변 내용")],
)

// Chip
CustomChip(label: "태그", onDeleted: () {})

// BottomSheet
CustomBottomSheet.show(
  context: context,
  title: "옵션 선택",
  items: [BottomSheetItem(label: "옵션 1", onTap: () {})],
)

// ProgressIndicator
CustomProgressIndicator.circular()
CustomProgressIndicator.linear(value: 0.5, label: "50%")

// RefreshIndicator
CustomRefreshIndicator(
  onRefresh: () async {},
  child: ListView(...),
)

// FloatingActionButton
CustomFloatingActionButton(
  onPressed: () {},
  icon: Icons.add,
)

// Drawer
CustomDrawer(
  items: [DrawerItem(label: "홈", icon: Icons.home, onTap: () {})],
)

// Rating
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) => setState(() => _rating = rating),
)
```

## 테마 색상 자동 적용

### 지원되는 위젯

다음 위젯들은 테마 색상을 자동으로 감지하여 적용합니다:

- **CustomButton**: `backgroundColor`를 지정하지 않으면 테마 `primary` 색상 사용
- **CustomText**: `color`를 지정하지 않으면 테마 `textPrimary` 색상 사용
- **CustomAppBar**: `backgroundColor`를 지정하지 않으면 테마 `primary` 색상 사용
- **CustomIconButton**: `iconColor`를 지정하지 않으면 테마 `textPrimary` 색상 사용

### 테마 색상 우선순위

1. **명시적 색상 지정** (최우선)
   ```dart
   CustomButton(btnText: "확인", backgroundColor: Colors.red, onCallBack: () {})
   ```

2. **테마 색상** (AppColorScheme이 있는 경우)
   ```dart
   CustomButton(btnText: "확인", onCallBack: () {}) // 테마 primary 색상 자동 적용
   ```

3. **Material Theme 기본값** (테마가 없는 경우)
   ```dart
   // 다른 앱에서도 사용 가능 - Material Theme 기본값 사용
   CustomButton(btnText: "확인", onCallBack: () {}) // Colors.blue 사용
   ```

### 다른 앱에서 사용 시

커스텀 위젯들은 다른 앱에서도 사용할 수 있도록 설계되었습니다:

- `AppColorScheme`이 없는 경우 Material Theme 기본값 사용
- 테마 색상은 선택적으로 적용되며, 없어도 정상 동작
- 모든 색상 파라미터는 선택적(optional)이므로 명시적으로 지정 가능

### 구현 방식

위젯들은 내부적으로 다음 로직을 사용합니다:

```dart
// 테마 색상 감지 헬퍼 함수 (각 위젯 파일 내부)
Color? _getThemePrimaryColor(BuildContext context) {
  try {
    final palette = (context as dynamic).palette;
    if (palette != null) {
      return palette.primary;
    }
  } catch (e) {
    // PaletteContext가 없는 경우 무시
  }
  // Material Theme 기본값 사용
  return Theme.of(context).colorScheme.primary;
}
```

이 방식으로 다른 앱에서도 사용할 수 있으면서, 테마가 있는 경우 자동으로 적용됩니다.
