# 레이아웃 위젯 클래스

## CustomCard

Material Design의 Card 위젯을 기반으로 한 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomCard(
  child: CustomText("카드 내용"),
)
```

### 주요 속성

| 속성           | 타입           | 기본값               | 설명                         |
| -------------- | -------------- | -------------------- | ---------------------------- |
| `child`        | `Widget`       | 필수                 | 카드 내부에 표시할 자식 위젯 |
| `color`        | `Color?`       | `null`               | 카드 배경색                  |
| `elevation`    | `double?`      | `2`                  | 카드 elevation (그림자 효과) |
| `borderRadius` | `double?`      | `12`                 | 카드 모서리 둥글기           |
| `padding`      | `EdgeInsets?`  | `EdgeInsets.all(16)` | 카드 내부 패딩               |
| `margin`       | `EdgeInsets?`  | `null`               | 카드 마진                    |
| `width`        | `double?`      | `null`               | 카드 너비                    |
| `height`       | `double?`      | `null`               | 카드 높이                    |
| `shape`        | `ShapeBorder?` | `null`               | 카드 모양                    |

### 사용 예시

```dart
// 기본 사용
CustomCard(
  child: CustomText("카드 내용"),
)

// 스타일 커스터마이징
CustomCard(
  color: Colors.white,
  elevation: 4,
  borderRadius: 16,
  padding: EdgeInsets.all(20),
  child: CustomText("커스텀 카드"),
)

// 크기 지정
CustomCard(
  width: 200,
  height: 150,
  child: CustomText("고정 크기 카드"),
)
```

---

## CustomContainer

Container를 기반으로 한 커스텀 위젯입니다. CustomCard보다 더 유연한 커스터마이징이 가능합니다.

### 기본 사용법

```dart
CustomContainer(
  child: CustomText("컨테이너 내용"),
)
```

### 주요 속성

| 속성              | 타입                 | 기본값         | 설명                             |
| ----------------- | -------------------- | -------------- | -------------------------------- |
| `child`           | `Widget`             | 필수           | 컨테이너 내부에 표시할 자식 위젯 |
| `backgroundColor` | `Color?`             | `null`         | 배경색                           |
| `borderRadius`    | `double?`            | `null`         | 모서리 둥글기                    |
| `padding`         | `EdgeInsets?`        | `null`         | 내부 패딩                        |
| `margin`          | `EdgeInsets?`        | `null`         | 마진                             |
| `borderColor`     | `Color?`             | `null`         | 테두리 색상                      |
| `borderWidth`     | `double?`            | `1.0`          | 테두리 두께                      |
| `shadowColor`     | `Color?`             | `null`         | 그림자 색상                      |
| `blurRadius`      | `double?`            | `8.0`          | 그림자 블러 반경                 |
| `spreadRadius`    | `double?`            | `1.0`          | 그림자 확산 반경                 |
| `shadowOffset`    | `Offset?`            | `Offset(0, 2)` | 그림자 오프셋                    |
| `width`           | `double?`            | `null`         | 너비                             |
| `height`          | `double?`            | `null`         | 높이                             |
| `alignment`       | `AlignmentGeometry?` | `null`         | 정렬 방식                        |
| `constraints`     | `BoxConstraints?`    | `null`         | 제약 조건                        |

### 사용 예시

```dart
// 기본 사용
CustomContainer(
  child: CustomText("컨테이너 내용"),
)

// 배경색과 테두리
CustomContainer(
  backgroundColor: Colors.blue.shade50,
  borderRadius: 12,
  borderColor: Colors.blue,
  borderWidth: 2,
  padding: EdgeInsets.all(16),
  child: CustomText("스타일 적용 컨테이너"),
)

// 그림자 효과
CustomContainer(
  backgroundColor: Colors.white,
  borderRadius: 12,
  shadowColor: Colors.grey.withOpacity(0.3),
  blurRadius: 10,
  spreadRadius: 2,
  shadowOffset: Offset(0, 4),
  padding: EdgeInsets.all(16),
  child: CustomText("그림자 효과 컨테이너"),
)
```

### CustomCard vs CustomContainer

| 특징            | CustomCard           | CustomContainer           |
| --------------- | -------------------- | ------------------------- |
| 기반 위젯       | Card                 | Container                 |
| Material Design | 자동 적용            | 수동 설정                 |
| elevation       | 지원                 | 미지원 (boxShadow 사용)   |
| 커스터마이징    | 제한적               | 매우 유연함               |
| 테두리          | shape로 제어         | borderColor/borderWidth   |
| 사용 시기       | Material 스타일 카드 | 세부 커스터마이징 필요 시 |

---

## CustomImage

이미지를 표시하는 커스텀 위젯입니다. Asset 이미지, File 이미지, Memory 이미지를 모두 지원합니다.

### 기본 사용법

```dart
// Asset 이미지 사용
CustomImage("images/logo.png")

// File 이미지 사용
CustomImage.file(File("/path/to/image.png"))

// Memory 이미지 사용
CustomImage.memory(Uint8List.fromList([...]))
```

### 주요 속성

| 속성             | 타입                 | 기본값                 | 설명                            |
| ---------------- | -------------------- | ---------------------- | ------------------------------- |
| `path`           | `String?`            | Asset 이미지 사용 시 필수 | 이미지 경로 (Asset 이미지)     |
| `file`           | `File?`              | File 이미지 사용 시 필수 | 이미지 파일 (File 이미지)      |
| `bytes`          | `Uint8List?`         | Memory 이미지 사용 시 필수 | 이미지 바이트 데이터 (Memory 이미지) |
| `width`          | `double?`            | `null`                 | 이미지 너비                     |
| `height`         | `double?`            | `null`                 | 이미지 높이                     |
| `fit`            | `BoxFit?`            | `BoxFit.contain`       | 이미지 크기 조정 방식           |
| `errorWidget`    | `Widget?`            | 기본 위젯              | 이미지 로드 실패 시 표시할 위젯 |
| `loadingWidget`  | `Widget?`            | `null`                 | 이미지 로드 중 표시할 위젯      |
| `color`          | `Color?`             | `null`                 | 이미지 색상 필터                |
| `colorBlendMode` | `BlendMode?`         | `null`                 | 이미지 색상 블렌드 모드         |
| `repeat`         | `ImageRepeat?`       | `ImageRepeat.noRepeat` | 이미지 반복 방식                |
| `alignment`      | `AlignmentGeometry?` | `Alignment.center`     | 이미지 정렬 방식                |

### 사용 예시

#### Asset 이미지

```dart
// 기본 사용
CustomImage("images/logo.png")

// 크기 지정
CustomImage(
  "images/logo.png",
  width: 100,
  height: 100,
)

// fit 지정
CustomImage(
  "images/logo.png",
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// 에러 처리
CustomImage(
  "images/logo.png",
  errorWidget: Icon(Icons.broken_image, size: 50),
)
```

#### File 이미지

```dart
import 'dart:io';

// 기본 사용
CustomImage.file(File("/path/to/image.png"))

// 크기 지정
CustomImage.file(
  File("/path/to/image.png"),
  width: 100,
  height: 100,
)

// fit 지정
CustomImage.file(
  File("/path/to/image.png"),
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// 에러 처리
CustomImage.file(
  File("/path/to/image.png"),
  errorWidget: Icon(Icons.broken_image, size: 50),
)

// 갤러리에서 선택한 이미지 표시
File? selectedImage = await pickImageFromGallery();
if (selectedImage != null) {
  CustomImage.file(
    selectedImage,
    width: 200,
    height: 200,
    fit: BoxFit.cover,
  )
}
```

#### Memory 이미지

```dart
import 'dart:typed_data';

// 기본 사용
CustomImage.memory(Uint8List.fromList([...]))

// 크기 지정
CustomImage.memory(
  imageBytes,
  width: 100,
  height: 100,
)

// fit 지정
CustomImage.memory(
  imageBytes,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)

// 에러 처리
CustomImage.memory(
  imageBytes,
  errorWidget: Icon(Icons.broken_image, size: 50),
)

// 네트워크에서 다운로드한 이미지 표시
final response = await http.get(Uri.parse('https://example.com/image.png'));
if (response.statusCode == 200) {
  CustomImage.memory(
    response.bodyBytes,
    width: 200,
    height: 200,
    fit: BoxFit.cover,
  )
}

// File을 Memory로 변환하여 표시
File imageFile = File('/path/to/image.png');
Uint8List imageBytes = await imageFile.readAsBytes();
CustomImage.memory(
  imageBytes,
  width: 200,
  height: 200,
)
```

---

## CustomIconButton

아이콘 버튼을 표시하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomIconButton(
  icon: Icons.favorite,
  onPressed: () {
    print("좋아요");
  },
)
```

### 주요 속성

| 속성              | 타입           | 기본값         | 설명                            |
| ----------------- | -------------- | -------------- | ------------------------------- |
| `icon`            | `IconData`     | 필수           | 표시할 아이콘                   |
| `onPressed`       | `VoidCallback` | 필수           | 아이콘 버튼 클릭 시 실행될 콜백 |
| `iconSize`        | `double?`      | `24`           | 아이콘 크기                     |
| `iconColor`       | `Color?`       | `Colors.black` | 아이콘 색상                     |
| `backgroundColor` | `Color?`       | `null`         | 아이콘 버튼 배경색              |
| `size`            | `double?`      | `48`           | 아이콘 버튼 크기                |
| `borderRadius`    | `double?`      | `null`         | 아이콘 버튼 모서리 둥글기       |
| `tooltip`         | `String?`      | `null`         | 툴팁 메시지                     |
| `enabled`         | `bool`         | `true`         | 아이콘 버튼 활성화 여부         |

### 사용 예시

```dart
// 기본 사용
CustomIconButton(
  icon: Icons.favorite,
  onPressed: () {},
)

// 배경색과 둥근 모서리
CustomIconButton(
  icon: Icons.favorite,
  iconColor: Colors.red,
  backgroundColor: Colors.red.shade50,
  borderRadius: 8,
  onPressed: () {},
)

// 크기 조정
CustomIconButton(
  icon: Icons.share,
  iconSize: 32,
  size: 64,
  onPressed: () {},
)
```

---

## 실전 예제

### CustomCard 실전 예제

#### 카드 내부 레이아웃

```dart
CustomCard(
  padding: EdgeInsets.all(20),
  elevation: 4,
  borderRadius: 16,
  child: CustomColumn(
    spacing: 12,
    children: [
      CustomText("카드 제목", fontSize: 20, fontWeight: FontWeight.bold),
      CustomText("카드 내용", fontSize: 16),
    ],
  ),
)
```

### CustomContainer 실전 예제

#### 스타일 적용 컨테이너

```dart
CustomContainer(
  padding: EdgeInsets.all(16),
  backgroundColor: Colors.blue.shade50,
  borderRadius: 12,
  borderColor: Colors.blue,
  borderWidth: 2,
  shadowColor: Colors.blue.withOpacity(0.3),
  blurRadius: 8,
  child: CustomText("컨테이너 내용"),
)
```

### CustomImage 실전 예제

#### Asset 이미지 - 크기 지정 및 fit

```dart
CustomImage(
  "images/logo.png",
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

#### Asset 이미지 - 에러 및 로딩 처리

```dart
CustomImage(
  "images/logo.png",
  errorWidget: Icon(Icons.broken_image, size: 50),
  loadingWidget: CircularProgressIndicator(),
)
```

#### File 이미지 - 갤러리에서 선택한 이미지 표시

```dart
import 'dart:io';

// 갤러리에서 이미지 선택 후 표시
File? selectedImage = await pickImageFromGallery();
if (selectedImage != null) {
  CustomImage.file(
    selectedImage,
    width: 200,
    height: 200,
    fit: BoxFit.cover,
    errorWidget: Icon(Icons.broken_image, size: 50),
    loadingWidget: CircularProgressIndicator(),
  )
}
```

#### File 이미지 - 다운로드한 이미지 표시

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// 이미지 다운로드 후 표시
Future<void> displayDownloadedImage() async {
  final directory = await getApplicationDocumentsDirectory();
  final imageFile = File('${directory.path}/downloaded_image.png');
  
  if (await imageFile.exists()) {
    CustomImage.file(
      imageFile,
      width: 300,
      height: 300,
      fit: BoxFit.contain,
    )
  }
}
```

#### Memory 이미지 - 네트워크에서 다운로드한 이미지 표시

```dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// 네트워크에서 이미지 다운로드 후 표시
Future<void> displayNetworkImage() async {
  final response = await http.get(Uri.parse('https://example.com/image.png'));
  if (response.statusCode == 200) {
    CustomImage.memory(
      response.bodyBytes,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
      errorWidget: Icon(Icons.broken_image, size: 50),
    )
  }
}
```

#### Memory 이미지 - File을 Memory로 변환하여 표시

```dart
import 'dart:io';
import 'dart:typed_data';

// File을 Memory로 변환하여 표시
Future<void> displayFileAsMemory() async {
  File imageFile = File('/path/to/image.png');
  if (await imageFile.exists()) {
    Uint8List imageBytes = await imageFile.readAsBytes();
    CustomImage.memory(
      imageBytes,
      width: 300,
      height: 300,
      fit: BoxFit.cover,
    )
  }
}
```

### CustomIconButton 실전 예제

#### 배경색과 둥근 모서리

```dart
CustomIconButton(
  icon: Icons.share,
  iconColor: Colors.blue,
  backgroundColor: Colors.blue.shade50,
  borderRadius: 8,
  onPressed: () {
    print("공유");
  },
)
```

---

## CustomExpansionTile

접을 수 있는 리스트 아이템 위젯입니다.

### 기본 사용법

```dart
CustomExpansionTile(
  title: Text("자주 묻는 질문"),
  children: [
    ListTile(title: Text("답변 1")),
    ListTile(title: Text("답변 2")),
  ],
)
```

### 주요 속성

| 속성                      | 타입                    | 기본값   | 설명                           |
| ------------------------- | ----------------------- | -------- | ------------------------------ |
| `title`                   | `Widget`                | 필수     | 확장 타일의 제목                |
| `children`                | `List<Widget>`          | 필수     | 확장 시 표시할 자식 위젯들      |
| `subtitle`                | `Widget?`               | `null`   | 확장 타일의 서브타이틀          |
| `leading`                 | `Widget?`               | `null`   | 왼쪽에 표시할 아이콘 또는 위젯  |
| `trailing`                | `Widget?`               | `null`   | 오른쪽에 표시할 위젯            |
| `initiallyExpanded`       | `bool`                  | `false`  | 초기 확장 상태                  |
| `onExpansionChanged`      | `ValueChanged<bool>?`    | `null`   | 확장 상태 변경 시 콜백          |
| `backgroundColor`          | `Color?`                | `null`   | 배경색                          |
| `collapsedBackgroundColor` | `Color?`                | `null`   | 확장된 상태의 배경색            |
| `iconColor`                | `Color?`                | `null`   | 아이콘 색상                      |
| `collapsedIconColor`      | `Color?`                | `null`   | 확장된 상태의 아이콘 색상       |
| `textColor`                | `Color?`                | `null`   | 텍스트 색상                      |
| `collapsedTextColor`       | `Color?`                | `null`   | 확장된 상태의 텍스트 색상        |
| `tilePadding`              | `EdgeInsetsGeometry?`   | `null`   | 타일 패딩                       |
| `childrenPadding`          | `EdgeInsetsGeometry?`   | `EdgeInsets.all(16)` | 자식 위젯들에 적용할 패딩 |
| `borderRadius`             | `double?`               | `null`   | 모서리 둥글기                   |

### 사용 예시

```dart
// 기본 사용
CustomExpansionTile(
  title: Text("FAQ"),
  children: [
    Text("답변 내용 1"),
    Text("답변 내용 2"),
  ],
)

// 아이콘 포함
CustomExpansionTile(
  title: Text("설정"),
  leading: Icon(Icons.settings),
  children: [
    ListTile(title: Text("설정 1")),
    ListTile(title: Text("설정 2")),
  ],
)

// 초기 확장 상태
CustomExpansionTile(
  title: Text("정보"),
  initiallyExpanded: true,
  children: [
    Text("확장된 상태로 시작합니다."),
  ],
)

// 색상 커스터마이징
CustomExpansionTile(
  title: Text("커스텀"),
  backgroundColor: Colors.blue.shade50,
  iconColor: Colors.blue,
  children: [
    Text("커스텀 스타일"),
  ],
)
```

---

## CustomChip

태그, 필터, 선택 표시용 Chip 위젯입니다.

### 기본 사용법

```dart
CustomChip(label: "태그")
```

### 주요 속성

| 속성              | 타입                    | 기본값         | 설명                                    |
| ----------------- | ----------------------- | -------------- | --------------------------------------- |
| `label`           | `dynamic`               | 필수           | Chip에 표시할 라벨 (String 또는 Widget) |
| `onDeleted`       | `VoidCallback?`         | `null`         | 삭제 버튼 클릭 시 콜백                   |
| `selectable`      | `bool`                  | `false`        | 선택 가능한 Chip인지 여부                |
| `selected`        | `bool`                  | `false`        | 선택된 상태 (selectable이 true일 때)     |
| `onSelected`      | `ValueChanged<bool>?`    | `null`         | 선택 상태 변경 시 콜백                   |
| `avatar`          | `Widget?`                | `null`         | 왼쪽에 표시할 아바타                     |
| `backgroundColor`  | `Color?`                | `null`         | 배경색                                   |
| `selectedColor`    | `Color?`                | `null`         | 선택된 상태의 배경색                     |
| `deleteIconColor` | `Color?`                | `null`         | 삭제 아이콘 색상                         |
| `labelColor`       | `Color?`                | `null`         | 라벨 색상                                |
| `selectedLabelColor` | `Color?`                | `null`         | 선택된 상태의 라벨 색상                   |
| `padding`          | `EdgeInsetsGeometry?`   | `null`         | 패딩                                     |
| `borderRadius`     | `double?`               | `null`         | 모서리 둥글기                            |
| `iconSize`         | `double?`               | `null`         | 아이콘 크기                              |
| `deleteIcon`       | `IconData?`             | `null`         | 삭제 아이콘                              |
| `tooltip`          | `String?`               | `null`         | 툴팁 메시지                              |

### 사용 예시

```dart
// 기본 사용
CustomChip(label: "태그")

// 삭제 가능
CustomChip(
  label: "태그",
  onDeleted: () {
    print("삭제됨");
  },
)

// 선택 가능
CustomChip(
  label: "필터",
  selectable: true,
  selected: true,
  onSelected: (selected) {
    print("선택됨: $selected");
  },
)

// 아바타 포함
CustomChip(
  label: "사용자",
  avatar: CircleAvatar(
    child: Icon(Icons.person),
  ),
)

// 색상 커스터마이징
CustomChip(
  label: "커스텀",
  backgroundColor: Colors.blue.shade50,
  labelColor: Colors.blue,
  borderRadius: 20,
)
```

---

## CustomProgressIndicator

로딩 및 진행률 표시 위젯입니다.

### 기본 사용법

```dart
// 원형 로딩
CustomProgressIndicator.circular()

// 선형 진행률
CustomProgressIndicator.linear(value: 0.5, label: "50%")
```

### 주요 속성

#### 원형 로딩 (circular)

| 속성          | 타입      | 기본값 | 설명           |
| ------------- | --------- | ------ | -------------- |
| `color`       | `Color?`  | `null` | 색상           |
| `strokeWidth` | `double?` | `4.0`  | 스트로크 너비   |
| `size`        | `double?` | `null` | 크기           |

#### 선형 진행률 (linear)

| 속성              | 타입      | 기본값 | 설명           |
| ----------------- | --------- | ------ | -------------- |
| `value`           | `double?` | 필수   | 진행률 (0.0~1.0) |
| `label`           | `String?` | `null` | 진행률 라벨    |
| `color`           | `Color?`  | `null` | 색상           |
| `backgroundColor`  | `Color?`  | `null` | 배경색         |
| `minHeight`       | `double?` | `4.0`  | 최소 높이      |

### 사용 예시

```dart
// 원형 로딩
CustomProgressIndicator.circular()

// 크기 지정
CustomProgressIndicator.circular(
  size: 50,
  color: Colors.blue,
)

// 선형 진행률
CustomProgressIndicator.linear(
  value: 0.5,
  label: "50%",
)

// 색상 지정
CustomProgressIndicator.linear(
  value: 0.7,
  label: "70%",
  color: Colors.green,
  backgroundColor: Colors.grey.shade200,
)
```

---

## CustomRefreshIndicator

Pull to refresh 기능을 제공하는 위젯입니다.

### 기본 사용법

```dart
CustomRefreshIndicator(
  onRefresh: () async {
    await fetchData();
  },
  child: ListView(...),
)
```

### 주요 속성

| 속성                    | 타입                              | 기본값         | 설명                                                      |
| ----------------------- | --------------------------------- | -------------- | --------------------------------------------------------- |
| `onRefresh`             | `Future<void> Function()`         | 필수           | 새로고침 시 실행될 비동기 콜백                            |
| `child`                  | `Widget`                          | 필수           | 새로고침 인디케이터 아래에 표시할 자식 위젯               |
| `color`                  | `Color?`                          | `null`         | 새로고침 인디케이터 색상                                  |
| `backgroundColor`        | `Color?`                          | `null`         | 새로고침 인디케이터 배경색                                |
| `displacement`           | `double?`                         | `40.0`         | 새로고침 인디케이터가 표시되는 위치 (화면 상단으로부터의 거리) |
| `notificationPredicate`  | `ScrollNotificationPredicate?`    | `null`         | 새로고침 인디케이터가 표시되는 동안 스크롤 가능 여부 결정 함수 |

### 사용 예시

```dart
// 기본 사용
CustomRefreshIndicator(
  onRefresh: () async {
    await Future.delayed(Duration(seconds: 2));
  },
  child: ListView(
    children: [
      ListTile(title: Text("항목 1")),
      ListTile(title: Text("항목 2")),
    ],
  ),
)

// 색상 지정
CustomRefreshIndicator(
  onRefresh: () async {
    await fetchData();
  },
  color: Colors.blue,
  backgroundColor: Colors.white,
  child: ListView(...),
)

// 위치 조정
CustomRefreshIndicator(
  onRefresh: () async {
    await fetchData();
  },
  displacement: 60,
  child: ListView(...),
)
```
