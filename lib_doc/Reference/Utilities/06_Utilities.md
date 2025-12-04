# 유틸리티 클래스

## CustomCommonUtil

위젯 및 공통 기능 관련 유틸리티 함수들을 제공하는 헬퍼 클래스입니다.

### 주요 메서드

#### 위젯 관련 유틸리티

##### `isString`

값이 String인지 확인하는 메서드입니다.

```dart
static bool isString(dynamic value)
```

**사용 예시:**

```dart
if (CustomCommonUtil.isString(label)) {
  // String 처리
  Text(label as String)
}
```

##### `isWidget`

값이 Widget인지 확인하는 메서드입니다.

```dart
static bool isWidget(dynamic value)
```

**사용 예시:**

```dart
if (CustomCommonUtil.isWidget(label)) {
  // Widget 처리
  return label as Widget;
}
```

##### `toWidget`

label을 Widget으로 변환하는 메서드입니다. String이면 Text 위젯으로, Widget이면 그대로 반환합니다.

```dart
static Widget toWidget(
  dynamic label, {
  TextStyle? style,
  TextAlign? textAlign,
  int? maxLines,
  TextOverflow? overflow,
})
```

**파라미터:**

| 파라미터    | 타입            | 기본값 | 설명                                   |
| ----------- | --------------- | ------ | -------------------------------------- |
| `label`     | `dynamic`       | 필수   | 변환할 label (String 또는 Widget)      |
| `style`     | `TextStyle?`    | `null` | Text 위젯 스타일 (String인 경우)       |
| `textAlign` | `TextAlign?`    | `null` | 텍스트 정렬 방식 (String인 경우)       |
| `maxLines`  | `int?`          | `null` | 최대 줄 수 (String인 경우)             |
| `overflow`  | `TextOverflow?` | `null` | 텍스트 오버플로우 처리 (String인 경우) |

**사용 예시:**

```dart
final widget = CustomCommonUtil.toWidget(
  label,
  style: TextStyle(fontSize: 16, color: Colors.blue),
  textAlign: TextAlign.center,
);
```

##### `toLabelString`

label을 String으로 변환하는 메서드입니다. Widget인 경우 null을 반환합니다.

```dart
static String? toLabelString(dynamic label)
```

**사용 예시:**

```dart
final text = CustomCommonUtil.toLabelString(label);
if (text != null) {
  // String으로 처리
  print("라벨: $text");
}
```

---

#### 날짜/시간 관련 유틸리티

##### `formatDate`

날짜를 지정된 형식으로 포맷팅합니다.

```dart
static String formatDate(DateTime date, String format)
```

**사용 예시:**

```dart
CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd'); // '2024-01-15'
CustomCommonUtil.formatDate(DateTime.now(), 'yyyy년 MM월 dd일'); // '2024년 01월 15일'
CustomCommonUtil.formatDate(DateTime.now(), 'yyyy-MM-dd HH:mm:ss'); // '2024-01-15 14:30:00'
```

##### `isToday`

날짜가 오늘인지 확인합니다.

```dart
static bool isToday(DateTime date)
```

**사용 예시:**

```dart
CustomCommonUtil.isToday(DateTime.now()); // true
```

##### `daysBetween`

두 날짜 사이의 일수 차이를 계산합니다.

```dart
static int daysBetween(DateTime start, DateTime end)
```

**사용 예시:**

```dart
CustomCommonUtil.daysBetween(DateTime(2024, 1, 1), DateTime(2024, 1, 5)); // 4
```

##### `addDays`

날짜에 일수를 추가합니다.

```dart
static DateTime addDays(DateTime date, int days)
```

**사용 예시:**

```dart
CustomCommonUtil.addDays(DateTime.now(), 7); // 7일 후
```

##### `subtractDays`

날짜에서 일수를 뺍니다.

```dart
static DateTime subtractDays(DateTime date, int days)
```

**사용 예시:**

```dart
CustomCommonUtil.subtractDays(DateTime.now(), 7); // 7일 전
```

##### `toRelativeTime`

상대 시간을 표시합니다 ("방금 전", "5분 전", "3일 전" 등).

```dart
static String toRelativeTime(DateTime date)
```

**사용 예시:**

```dart
CustomCommonUtil.toRelativeTime(DateTime.now().subtract(Duration(minutes: 5))); // '5분 전'
CustomCommonUtil.toRelativeTime(DateTime.now().subtract(Duration(hours: 2))); // '2시간 전'
CustomCommonUtil.toRelativeTime(DateTime.now().subtract(Duration(days: 3))); // '3일 전'
```

---

#### 문자열 관련 유틸리티

##### `isEmpty`

문자열이 비어있거나 null인지 확인합니다.

```dart
static bool isEmpty(String? value, {bool trim = true})
```

**사용 예시:**

```dart
CustomCommonUtil.isEmpty(null); // true
CustomCommonUtil.isEmpty(''); // true
CustomCommonUtil.isEmpty('   '); // true (trim 후)
```

##### `isNotEmpty`

문자열이 비어있지 않은지 확인합니다.

```dart
static bool isNotEmpty(String? value, {bool trim = true})
```

**사용 예시:**

```dart
CustomCommonUtil.isNotEmpty('hello'); // true
```

##### `toCamelCase`

문자열을 카멜케이스로 변환합니다.

```dart
static String toCamelCase(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.toCamelCase('hello_world'); // 'helloWorld'
CustomCommonUtil.toCamelCase('hello-world'); // 'helloWorld'
```

##### `toSnakeCase`

문자열을 스네이크케이스로 변환합니다.

```dart
static String toSnakeCase(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.toSnakeCase('helloWorld'); // 'hello_world'
```

##### `truncate`

문자열을 지정된 길이로 자르고 말줄임표를 추가합니다.

```dart
static String truncate(String value, {required int maxLength, String ellipsis = '...'})
```

**사용 예시:**

```dart
CustomCommonUtil.truncate('긴 텍스트입니다', maxLength: 5); // '긴 텍스트...'
```

##### `formatNumberString`

숫자 문자열에 천단위 콤마를 추가합니다.

```dart
static String formatNumberString(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.formatNumberString('1234567'); // '1,234,567'
```

##### `removeChar`

문자열에서 특정 문자를 제거합니다.

```dart
static String removeChar(String value, String char)
```

**사용 예시:**

```dart
CustomCommonUtil.removeChar('010-1234-5678', '-'); // '01012345678'
```

##### `removeChars`

문자열에서 여러 문자를 제거합니다.

```dart
static String removeChars(String value, List<String> chars)
```

**사용 예시:**

```dart
CustomCommonUtil.removeChars('010-1234-5678', ['-', ' ']); // '01012345678'
```

---

#### 검증 관련 유틸리티

##### `isEmail`

이메일 형식을 검증합니다.

```dart
static bool isEmail(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.isEmail('test@example.com'); // true
CustomCommonUtil.isEmail('invalid'); // false
```

##### `isPhoneNumber`

한국 전화번호 형식을 검증합니다 (010-1234-5678, 01012345678 등).

```dart
static bool isPhoneNumber(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.isPhoneNumber('010-1234-5678'); // true
CustomCommonUtil.isPhoneNumber('01012345678'); // true
CustomCommonUtil.isPhoneNumber('02-1234-5678'); // true
```

##### `isUrl`

URL 형식을 검증합니다.

```dart
static bool isUrl(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.isUrl('https://example.com'); // true
CustomCommonUtil.isUrl('http://example.com'); // true
CustomCommonUtil.isUrl('invalid'); // false
```

##### `validatePassword`

비밀번호 강도를 검증합니다. 반환값: 0 (약함), 1 (보통), 2 (강함), 3 (매우 강함)

```dart
static int validatePassword(String password)
```

**사용 예시:**

```dart
CustomCommonUtil.validatePassword('password'); // 0 (약함)
CustomCommonUtil.validatePassword('Password123'); // 2 (강함)
CustomCommonUtil.validatePassword('P@ssw0rd!'); // 3 (매우 강함)
```

##### `isNumeric`

숫자만 포함하는지 검증합니다.

```dart
static bool isNumeric(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.isNumeric('123'); // true
CustomCommonUtil.isNumeric('12a'); // false
```

##### `isAlphabetic`

영문자만 포함하는지 검증합니다.

```dart
static bool isAlphabetic(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.isAlphabetic('abc'); // true
CustomCommonUtil.isAlphabetic('abc123'); // false
```

##### `isAlphanumeric`

영문자와 숫자만 포함하는지 검증합니다.

```dart
static bool isAlphanumeric(String value)
```

**사용 예시:**

```dart
CustomCommonUtil.isAlphanumeric('abc123'); // true
CustomCommonUtil.isAlphanumeric('abc-123'); // false
```

---

#### 포맷팅 관련 유틸리티

##### `formatFileSize`

파일 크기를 읽기 쉬운 형식으로 포맷팅합니다 (KB, MB, GB).

```dart
static String formatFileSize(int bytes)
```

**사용 예시:**

```dart
CustomCommonUtil.formatFileSize(1024); // '1.0 KB'
CustomCommonUtil.formatFileSize(1048576); // '1.0 MB'
CustomCommonUtil.formatFileSize(1073741824); // '1.0 GB'
```

##### `formatDuration`

Duration을 읽기 쉬운 형식으로 포맷팅합니다 (분:초, 시간:분:초).

```dart
static String formatDuration(Duration duration)
```

**사용 예시:**

```dart
CustomCommonUtil.formatDuration(Duration(seconds: 125)); // '2:05'
CustomCommonUtil.formatDuration(Duration(hours: 2, minutes: 30, seconds: 45)); // '2:30:45'
```

##### `formatDistance`

거리를 읽기 쉬운 형식으로 포맷팅합니다 (미터 → km).

```dart
static String formatDistance(int meters)
```

**사용 예시:**

```dart
CustomCommonUtil.formatDistance(1500); // '1.5 km'
CustomCommonUtil.formatDistance(500); // '500 m'
```

##### `formatPrice`

가격을 원화 형식으로 포맷팅합니다.

```dart
static String formatPrice(int price)
```

**사용 예시:**

```dart
CustomCommonUtil.formatPrice(10000); // '10,000원'
CustomCommonUtil.formatPrice(1000000); // '1,000,000원'
```

##### `formatPercent`

퍼센트를 포맷팅합니다.

```dart
static String formatPercent(double value, {int decimals = 0})
```

**사용 예시:**

```dart
CustomCommonUtil.formatPercent(0.25); // '25%'
CustomCommonUtil.formatPercent(0.1234, decimals: 2); // '12.34%'
```

---

#### 숫자 관련 유틸리티

##### `formatNumber`

숫자에 천단위 콤마를 추가합니다.

```dart
static String formatNumber(num value, {int? decimals})
```

**사용 예시:**

```dart
CustomCommonUtil.formatNumber(1234567); // '1,234,567'
CustomCommonUtil.formatNumber(1234567.89); // '1,234,567.89'
CustomCommonUtil.formatNumber(1234567.89, decimals: 2); // '1,234,567.89'
```

##### `safeParseInt`

문자열을 안전하게 int로 변환합니다 (실패 시 null 반환).

```dart
static int? safeParseInt(String? value)
```

**사용 예시:**

```dart
CustomCommonUtil.safeParseInt('123'); // 123
CustomCommonUtil.safeParseInt('abc'); // null
```

##### `safeParseDouble`

문자열을 안전하게 double로 변환합니다 (실패 시 null 반환).

```dart
static double? safeParseDouble(String? value)
```

**사용 예시:**

```dart
CustomCommonUtil.safeParseDouble('123.45'); // 123.45
CustomCommonUtil.safeParseDouble('abc'); // null
```

##### `isPositive`

숫자가 양수인지 확인합니다.

```dart
static bool isPositive(num value)
```

**사용 예시:**

```dart
CustomCommonUtil.isPositive(5); // true
CustomCommonUtil.isPositive(-5); // false
```

##### `isNegative`

숫자가 음수인지 확인합니다.

```dart
static bool isNegative(num value)
```

**사용 예시:**

```dart
CustomCommonUtil.isNegative(-5); // true
CustomCommonUtil.isNegative(5); // false
```

##### `isInRange`

숫자가 범위 내에 있는지 확인합니다.

```dart
static bool isInRange(num value, {required num min, required num max})
```

**사용 예시:**

```dart
CustomCommonUtil.isInRange(5, min: 1, max: 10); // true
CustomCommonUtil.isInRange(15, min: 1, max: 10); // false
```

##### `formatCurrency`

숫자를 원화 형식으로 포맷팅합니다.

```dart
static String formatCurrency(int value)
```

**사용 예시:**

```dart
CustomCommonUtil.formatCurrency(10000); // '10,000원'
```

##### `toPercent`

숫자를 퍼센트로 변환합니다.

```dart
static String toPercent(double value, {int decimals = 0})
```

**사용 예시:**

```dart
CustomCommonUtil.toPercent(0.25); // '25%'
```

---

## CustomListView

ListView.builder를 간편하게 사용할 수 있는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomListView(
  itemCount: 10,
  itemBuilder: (context, index) {
    return CustomText("항목 $index");
  },
)
```

### 주요 속성

| 속성              | 타입                                 | 기본값                    | 설명                              |
| ----------------- | ------------------------------------ | ------------------------- | --------------------------------- |
| `itemCount`       | `int`                                | 필수                      | 리스트 아이템 개수                |
| `itemBuilder`     | `Widget Function(BuildContext, int)` | 필수                      | 각 아이템을 생성하는 빌더 함수    |
| `scrollDirection` | `Axis`                               | `Axis.vertical`           | 스크롤 방향                       |
| `itemSpacing`     | `double?`                            | `null`                    | 리스트 아이템들 사이의 간격       |
| `padding`         | `EdgeInsets?`                        | `null`                    | 리스트 전체에 적용할 패딩         |
| `separator`       | `Widget?`                            | `null`                    | 리스트 아이템들 사이의 구분선     |
| `physics`         | `ScrollPhysics?`                     | `BouncingScrollPhysics()` | 스크롤 물리 효과                  |
| `emptyWidget`     | `Widget?`                            | `null`                    | 리스트가 비어있을 때 표시할 위젯  |
| `loadingWidget`   | `Widget?`                            | `null`                    | 리스트가 로딩 중일 때 표시할 위젯 |
| `isLoading`       | `bool`                               | `false`                   | 로딩 중 여부                      |

### 사용 예시

```dart
// 기본 사용
CustomListView(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return CustomCard(
      child: CustomText(items[index]),
    );
  },
)

// 간격 지정
CustomListView(
  itemCount: items.length,
  itemSpacing: 8,
  itemBuilder: (context, index) {
    return CustomCard(
      child: CustomText(items[index]),
    );
  },
)

// 구분선 사용
CustomListView(
  itemCount: items.length,
  separator: Divider(height: 1),
  itemBuilder: (context, index) {
    return ListTile(
      title: CustomText(items[index]),
    );
  },
)

// 로딩 및 빈 상태 처리
CustomListView(
  itemCount: items.length,
  isLoading: isLoading,
  loadingWidget: CircularProgressIndicator(),
  emptyWidget: CustomText("항목이 없습니다"),
  itemBuilder: (context, index) {
    return CustomCard(
      child: CustomText(items[index]),
    );
  },
)

// 수평 스크롤
CustomListView(
  itemCount: items.length,
  scrollDirection: Axis.horizontal,
  itemSpacing: 12,
  itemBuilder: (context, index) {
    return CustomCard(
      width: 200,
      child: CustomText(items[index]),
    );
  },
)
```

---

## CustomStorageUtil

로컬 스토리지 유틸리티 클래스입니다. SharedPreferences를 래핑하여 간편하게 사용할 수 있습니다.

### 주요 기능

- 타입 안전한 저장/불러오기 (String, int, bool, double)
- 객체 저장/불러오기 (JSON 직렬화/역직렬화)
- 리스트 저장/불러오기
- 키 삭제 및 전체 삭제

### 의존성

```yaml
dependencies:
  shared_preferences: ^2.2.2
```

### 초기화

앱 시작 시 한 번만 호출해야 합니다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CustomStorageUtil.init();
  runApp(MyApp());
}
```

### 기본 사용법

```dart
// 기본 타입 저장/불러오기
await CustomStorageUtil.setString('username', '홍길동');
final username = await CustomStorageUtil.getString('username');

await CustomStorageUtil.setInt('age', 25);
final age = await CustomStorageUtil.getInt('age');

// 객체 저장/불러오기
final user = User(name: '홍길동', age: 25);
await CustomStorageUtil.setObject('user', user);
final savedUser = await CustomStorageUtil.getObject<User>(
  'user',
  (json) => User.fromJson(json),
);

// 리스트 저장/불러오기
final items = [Item(name: '사과'), Item(name: '바나나')];
await CustomStorageUtil.setList('items', items);
final savedItems = await CustomStorageUtil.getList<Item>(
  'items',
  (json) => Item.fromJson(json),
);
```

### 주요 메서드

| 메서드                        | 설명                     |
| ----------------------------- | ------------------------ |
| `init()`                      | SharedPreferences 초기화 |
| `setString(key, value)`       | 문자열 저장              |
| `getString(key)`              | 문자열 불러오기          |
| `setInt(key, value)`          | 정수 저장                |
| `getInt(key)`                 | 정수 불러오기            |
| `setBool(key, value)`         | 불린 저장                |
| `getBool(key)`                | 불린 불러오기            |
| `setDouble(key, value)`       | 실수 저장                |
| `getDouble(key)`              | 실수 불러오기            |
| `setObject<T>(key, object)`   | 객체 저장 (JSON)         |
| `getObject<T>(key, fromJson)` | 객체 불러오기 (JSON)     |
| `setList<T>(key, list)`       | 리스트 저장 (JSON)       |
| `getList<T>(key, fromJson)`   | 리스트 불러오기 (JSON)   |
| `remove(key)`                 | 키 삭제                  |
| `clear()`                     | 모든 데이터 삭제         |
| `containsKey(key)`            | 키 존재 여부 확인        |

자세한 내용은 [StorageUtil README](../../lib/custom/external_util/storage/README.md)를 참고하세요.

---

## CustomCollectionUtil

컬렉션(리스트, 맵) 관련 유틸리티 클래스입니다.

### 주요 기능

- null-safe 체크
- 중복 제거
- 그룹화
- 평탄화
- 필터링/매핑
- 딥 카피
- Record 관련 유틸리티

### 의존성

외부 패키지 불필요 (순수 Dart)

### 기본 사용법

```dart
// null-safe 체크
if (CustomCollectionUtil.isEmpty(list)) {
  print('리스트가 비어있습니다');
}

// 중복 제거
final unique = CustomCollectionUtil.unique([1, 2, 2, 3, 3, 3]); // [1, 2, 3]

// 그룹화
final grouped = CustomCollectionUtil.groupBy(
  users,
  (user) => user.category,
);

// 평탄화
final flattened = CustomCollectionUtil.flatten(nestedList);

// 딥 카피
final copied = CustomCollectionUtil.deepCopyList(originalList);
final copiedMap = CustomCollectionUtil.deepCopyMap(originalMap);
```

### 주요 메서드

| 메서드                             | 설명                 |
| ---------------------------------- | -------------------- |
| `isEmpty<T>(list)`                 | 빈 리스트 확인       |
| `isNotEmpty<T>(list)`              | 비어있지 않은지 확인 |
| `unique<T>(list)`                  | 중복 제거            |
| `groupBy<T, K>(list, keySelector)` | 그룹화               |
| `flatten<T>(nestedList)`           | 평탄화               |
| `filter<T>(list, predicate)`       | 필터링               |
| `map<T, R>(list, mapper)`          | 매핑                 |
| `chunk<T>(list, size)`             | 청크로 나누기        |
| `deepCopyList<T>(list)`            | 리스트 딥 카피       |
| `deepCopyMap<K, V>(map)`           | 맵 딥 카피           |

자세한 내용은 [CollectionUtil README](../lib/common/util/collection/README.md)를 참고하세요.

---

## CustomTimerUtil

타이머 유틸리티 클래스입니다. Unity 코루틴과 유사한 기능을 제공합니다.

### 주요 기능

- 기본 타이머 (지연 실행, 반복 실행)
- 코루틴 유사 기능 (waitForSeconds, waitUntil, waitWhile)
- 고급 타이머 기능 (타임아웃, 재시도, 디바운싱, 스로틀링)
- ID 기반 타이머 관리
- 타이머 일시정지/재개

### 의존성

외부 패키지 불필요 (순수 Dart)

### 기본 사용법

```dart
// 일정 시간 후 실행
final timer = CustomTimerUtil.delayed(
  Duration(seconds: 2),
  () => print('2초 후 실행'),
);

// 반복 실행
final periodicTimer = CustomTimerUtil.periodic(
  Duration(seconds: 1),
  (timer) => print('1초마다 실행'),
);

// 코루틴 유사 기능
await CustomTimerUtil.waitForSeconds(2.0);
await CustomTimerUtil.waitUntil(() => isReady);
await CustomTimerUtil.waitWhile(() => isLoading);

// ID 기반 관리
CustomTimerUtil.createPeriodicWithId(
  'counter',
  Duration(seconds: 1),
  (timer) => print('1초마다 실행'),
);

CustomTimerUtil.pauseById('counter');
CustomTimerUtil.resumeById('counter');
CustomTimerUtil.cancelById('counter');
```

### 주요 메서드

| 메서드                                         | 설명                    |
| ---------------------------------------------- | ----------------------- |
| `delayed(duration, callback)`                  | 지연 실행 타이머        |
| `periodic(duration, callback)`                 | 반복 실행 타이머        |
| `waitForSeconds(seconds)`                      | 일정 시간 대기          |
| `waitUntil(condition)`                         | 조건 만족까지 대기      |
| `waitWhile(condition)`                         | 조건 만족되는 동안 대기 |
| `debounce(callback, delay)`                    | 디바운싱                |
| `throttle(callback, delay)`                    | 스로틀링                |
| `createDelayedWithId(id, duration, callback)`  | ID 기반 지연 타이머     |
| `createPeriodicWithId(id, duration, callback)` | ID 기반 반복 타이머     |
| `pauseById(id)`                                | ID로 일시정지           |
| `resumeById(id)`                               | ID로 재개               |
| `cancelById(id)`                               | ID로 취소               |

자세한 내용은 [TimerUtil README](../lib/common/util/timer/README.md)를 참고하세요.

---

## CustomJsonUtil

저장소와 무관한 순수 JSON 변환 유틸리티 클래스입니다.

### StorageUtil과의 차이점

- **StorageUtil**: 저장소에 저장/불러오기 + JSON 변환 (저장소 연동 필수)
- **JsonUtil**: 순수 JSON 변환만 (저장소와 무관)

### 주요 기능

- 기본 JSON 변환 (decode, encode)
- 객체 ↔ JSON 변환
- JSON 검증
- JSON 포맷팅
- JSON 병합/수정

### 의존성

외부 패키지 불필요 (`dart:convert` 기본 제공)

### 기본 사용법

```dart
// JSON 디코딩
final json = CustomJsonUtil.decode('{"name": "홍길동", "age": 25}');

// JSON 인코딩
final jsonString = CustomJsonUtil.encode({'name': '홍길동', 'age': 25});

// JSON 검증
if (CustomJsonUtil.isValid(jsonString)) {
  print('유효한 JSON입니다');
}

// 객체 변환
final user = CustomJsonUtil.fromJson<User>(
  jsonString,
  (json) => User.fromJson(json),
);

// JSON 포맷팅
final formatted = CustomJsonUtil.format('{"name":"홍길동","age":25}');

// JSON 병합
final merged = CustomJsonUtil.merge(json1, json2);

// 경로로 값 가져오기
final name = CustomJsonUtil.getValue(json, 'user.name');
```

### 주요 메서드

| 메서드                              | 설명                   |
| ----------------------------------- | ---------------------- |
| `decode(jsonString)`                | JSON 문자열 → Map/List |
| `encode(value)`                     | Map/List → JSON 문자열 |
| `isValid(jsonString)`               | JSON 유효성 검증       |
| `fromJson<T>(jsonString, fromJson)` | JSON → 객체            |
| `toJson(object)`                    | 객체 → JSON            |
| `format(jsonString)`                | JSON 포맷팅 (들여쓰기) |
| `compress(jsonString)`              | JSON 압축 (공백 제거)  |
| `merge(json1, json2)`               | JSON 병합              |
| `getValue(json, path)`              | 경로로 값 가져오기     |
| `setValue(json, path, value)`       | 경로로 값 설정         |
| `removeValue(json, path)`           | 경로로 값 삭제         |

자세한 내용은 [JsonUtil README](../lib/common/util/json/README.md)를 참고하세요.

---

## CustomNetworkUtil

HTTP 통신을 위한 네트워크 유틸리티 클래스입니다.

### 주요 기능

- GET, POST, PUT, DELETE, PATCH 요청
- JsonUtil과 연동하여 요청/응답 JSON 변환
- 헤더 관리 (기본 헤더, 인증 토큰)
- 에러 처리
- 타임아웃 설정
- 쿼리 파라미터 자동 변환

### 의존성

```yaml
dependencies:
  http: ^1.1.0
```

### 기본 설정

```dart
// 기본 URL 설정
CustomNetworkUtil.setBaseUrl('https://api.example.com');

// 기본 헤더 설정
CustomNetworkUtil.setDefaultHeaders({
  'Content-Type': 'application/json',
});

// 인증 토큰 설정
CustomNetworkUtil.setAuthToken('Bearer token123');
```

### 기본 사용법

```dart
// GET 요청
final response = await CustomNetworkUtil.get<User>(
  '/api/users/1',
  fromJson: (json) => User.fromJson(json),
);

if (response.success) {
  print(response.data?.name);
} else {
  print('에러: ${response.error}');
}

// POST 요청
final response = await CustomNetworkUtil.post<User>(
  '/api/users',
  body: {'name': '홍길동', 'age': 25},
  fromJson: (json) => User.fromJson(json),
);

// PUT 요청
final response = await CustomNetworkUtil.put<User>(
  '/api/users/1',
  body: {'name': '김철수'},
  fromJson: (json) => User.fromJson(json),
);

// DELETE 요청
final response = await CustomNetworkUtil.delete('/api/users/1');

// 쿼리 파라미터
final response = await CustomNetworkUtil.get(
  '/api/users',
  queryParams: {'page': '1', 'limit': '10'},
);
```

### 주요 메서드

| 메서드                       | 설명           |
| ---------------------------- | -------------- |
| `setBaseUrl(url)`            | 기본 URL 설정  |
| `setDefaultHeaders(headers)` | 기본 헤더 설정 |
| `setAuthToken(token)`        | 인증 토큰 설정 |
| `setTimeout(duration)`       | 타임아웃 설정  |
| `get<T>(endpoint, {...})`    | GET 요청       |
| `post<T>(endpoint, {...})`   | POST 요청      |
| `put<T>(endpoint, {...})`    | PUT 요청       |
| `delete<T>(endpoint, {...})` | DELETE 요청    |
| `patch<T>(endpoint, {...})`  | PATCH 요청     |

### NetworkResponse

모든 요청은 `NetworkResponse<T>` 객체를 반환합니다.

```dart
class NetworkResponse<T> {
  final bool success;        // 성공 여부
  final T? data;             // 응답 데이터
  final String? error;       // 에러 메시지
  final int? statusCode;    // HTTP 상태 코드
  final Map<String, String>? headers;  // 응답 헤더
  final String? rawBody;    // 원본 응답 본문
}
```

자세한 내용은 [NetworkUtil README](../../lib/custom/external_util/network/README.md)를 참고하세요.

---

## CustomAddressUtil

위도/경도로 주소를 가져오는 유틸리티 클래스입니다. BigDataCloud Reverse Geocoding API를 사용하여 좌표로부터 주소 정보를 가져옵니다.

### 주요 기능

- 위도/경도로 직접 주소 가져오기 (API 자동 호출)
- BigDataCloud API 응답 JSON을 파싱하여 주소 문자열 생성
- 국가명 포함/제외 옵션
- 커스텀 구분자 설정
- 상세 주소 정보 추출
- 강화된 예외 처리 (좌표 유효성 검증, 네트워크 타임아웃, 상세한 에러 메시지)
- 타임아웃 설정 가능 (기본값: 10초)

### 기본 사용법

```dart
import 'package:custom_test_app/custom/utils_core.dart';

// 위도/경도로 주소 가져오기
try {
  final address = await CustomAddressUtil.getAddressFromCoordinates(37.497429, 127.127782);
  print(address); // "대한민국 서울특별시 송파구 가락2동"
} on AddressException catch (e) {
  print('주소 가져오기 실패: ${e.message}');
}
```

### 주요 메서드

#### `getAddressFromCoordinates`

위도와 경도를 받아서 BigDataCloud API를 호출하고 주소를 반환합니다.

```dart
static Future<String?> getAddressFromCoordinates(
  double latitude,
  double longitude, {
  String language = 'ko',
  String separator = " ",
  bool includeCountry = true,
  Duration? timeout,
})
```

**파라미터:**
- `latitude`: 위도 (-90 ~ 90)
- `longitude`: 경도 (-180 ~ 180)
- `language`: 언어 코드 (기본값: "ko" - 한국어)
- `separator`: 주소 구성 요소 사이의 구분자 (기본값: " ")
- `includeCountry`: 국가명 포함 여부 (기본값: true)
- `timeout`: 요청 타임아웃 (기본값: 10초)

**반환값:** 파싱된 주소 문자열 또는 `null`

**예외:** `AddressException` - 좌표가 유효하지 않거나, 네트워크 오류, API 오류 발생 시

#### `getSimpleAddressFromCoordinates`

위도와 경도로 간단한 주소를 가져옵니다 (국가 제외).

```dart
static Future<String?> getSimpleAddressFromCoordinates(
  double latitude,
  double longitude, {
  String language = 'ko',
  Duration? timeout,
})
```

#### `getAddressInfoFromCoordinates`

위도와 경도로 상세 주소 정보를 가져옵니다.

```dart
static Future<Map<String, String?>?> getAddressInfoFromCoordinates(
  double latitude,
  double longitude, {
  String language = 'ko',
  Duration? timeout,
})
```

**반환값:** 주소 정보가 담긴 Map
- `countryName`: 국가명
- `province`: 시/도
- `city`: 시
- `district`: 구/군
- `locality`: 동/읍/면
- `fullAddress`: 전체 주소

#### `parseAddress`

JSON 문자열을 파싱하여 주소 텍스트를 반환합니다.

```dart
static String? parseAddress(
  String jsonString, {
  String separator = " ",
  bool includeCountry = true,
})
```

### 예외 처리

모든 API 호출 메서드는 `AddressException`을 던질 수 있습니다. 예외 코드로 오류 유형을 구분할 수 있습니다:

- `INVALID_COORDINATE`: 유효하지 않은 좌표
- `TIMEOUT`: API 요청 타임아웃
- `NETWORK_ERROR`: 네트워크 연결 오류
- `HTTP_ERROR`: HTTP 상태 코드 오류
- `PARSE_ERROR`: JSON 파싱 오류
- `DECODE_ERROR`: JSON 디코딩 오류
- `INVALID_FORMAT`: 잘못된 JSON 형식
- `EMPTY_JSON`: 빈 JSON 문자열
- `NO_ADDRESS_DATA`: 주소 데이터 없음
- `UNKNOWN_ERROR`: 알 수 없는 오류

### 사용 예시

```dart
// 위도/경도로 주소 가져오기
try {
  final address = await CustomAddressUtil.getAddressFromCoordinates(37.497429, 127.127782);
  print(address); // "대한민국 서울특별시 송파구 가락2동"
} on AddressException catch (e) {
  switch (e.code) {
    case 'INVALID_COORDINATE':
      print('좌표가 유효하지 않습니다.');
      break;
    case 'TIMEOUT':
      print('요청 시간이 초과되었습니다.');
      break;
    case 'NETWORK_ERROR':
      print('네트워크 연결을 확인해주세요.');
      break;
    default:
      print('오류 발생: ${e.message}');
  }
}

// 간단한 주소 (국가 제외)
final simpleAddress = await CustomAddressUtil.getSimpleAddressFromCoordinates(37.497429, 127.127782);
print(simpleAddress); // "서울특별시 송파구 가락2동"

// 상세 주소 정보
final addressInfo = await CustomAddressUtil.getAddressInfoFromCoordinates(37.497429, 127.127782);
print(addressInfo?['district']); // "송파구"
print(addressInfo?['fullAddress']); // "대한민국 서울특별시 송파구 가락2동"
```

자세한 내용은 [AddressUtil README](../../lib/custom/util/address/README.md)를 참고하세요.

---

## 유틸리티 클래스 요약

| 클래스                 | 위치                          | 의존성               | 주요 용도                                        |
| ---------------------- | ----------------------------- | -------------------- | ------------------------------------------------ |
| `CustomCommonUtil`     | `lib/common/`                 | 없음                 | 위젯 헬퍼, 날짜/시간, 문자열, 검증, 포맷팅, 숫자 |
| `CustomStorageUtil`    | `lib/custom/external_util/storage/`    | `shared_preferences` | 로컬 데이터 저장                                 |
| `CustomCollectionUtil` | `lib/common/util/collection/` | 없음                 | 리스트/맵 조작                                   |
| `CustomTimerUtil`      | `lib/common/util/timer/`      | 없음                 | 타이머 관리, 코루틴 유사 기능                    |
| `CustomJsonUtil`       | `lib/common/util/json/`       | 없음                 | JSON 변환                                        |
| `CustomAddressUtil`    | `lib/custom/util/address/`    | `http`               | 위도/경도로 주소 가져오기                        |
| `CustomNetworkUtil`    | `lib/custom/external_util/network/`    | `http`               | HTTP 통신                                        |

## 예제 페이지

모든 유틸리티 클래스의 사용 예제는 `UtilPage`에서 확인할 수 있습니다.

```dart
// UtilPage로 이동
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const UtilPage()),
);
```

---

## 실전 예제

### CustomListView 실전 예제

#### 기본 사용

```dart
CustomListView(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return CustomCard(
      child: CustomText(items[index]),
    );
  },
)
```

#### 간격 및 구분선

```dart
CustomListView(
  itemCount: items.length,
  itemSpacing: 8,
  separator: Divider(height: 1),
  itemBuilder: (context, index) {
    return ListTile(
      title: CustomText(items[index]),
    );
  },
)
```

#### 로딩 및 빈 상태 처리

```dart
CustomListView(
  itemCount: items.length,
  isLoading: isLoading,
  loadingWidget: CircularProgressIndicator(),
  emptyWidget: CustomText("항목이 없습니다"),
  itemBuilder: (context, index) {
    return CustomCard(
      child: CustomText(items[index]),
    );
  },
)
```
