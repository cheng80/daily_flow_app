# 기본 위젯 클래스

## CustomText

텍스트를 표시하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomText("안녕하세요")
```

### 주요 속성

| 속성         | 타입            | 기본값            | 설명                        |
| ------------ | --------------- | ----------------- | --------------------------- |
| `text`       | `String`        | 필수              | 표시할 텍스트 내용          |
| `fontSize`   | `double?`       | `20`              | 텍스트 크기                 |
| `fontWeight` | `FontWeight?`   | `FontWeight.bold` | 텍스트 굵기                 |
| `color`      | `Color?`        | `Colors.black`    | 텍스트 색상                 |
| `textAlign`  | `TextAlign?`    | `null`            | 텍스트 정렬 방식            |
| `maxLines`   | `int?`          | `null`            | 최대 줄 수                  |
| `overflow`   | `TextOverflow?` | `null`            | 텍스트 오버플로우 처리 방식 |
| `style`      | `TextStyle?`    | `null`            | 커스텀 TextStyle            |

### 사용 예시

```dart
// 기본 사용
CustomText("확인")

// 스타일 커스터마이징
CustomText(
  "안녕하세요",
  fontSize: 24,
  color: Colors.blue,
  fontWeight: FontWeight.normal,
)

// 정렬 및 오버플로우 처리
CustomText(
  "긴 텍스트 내용...",
  textAlign: TextAlign.center,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

---

## CustomButton

버튼을 표시하는 커스텀 위젯입니다. TextButton, ElevatedButton, OutlinedButton을 지원합니다.

### 기본 사용법

```dart
CustomButton(
  btnText: "확인",
  onCallBack: () {
    print("버튼 클릭");
  },
)
```

### 주요 속성

| 속성              | 타입           | 기본값            | 설명                                 |
| ----------------- | -------------- | ----------------- | ------------------------------------ |
| `btnText`         | `dynamic`      | 필수              | 버튼 텍스트 (String 또는 Widget)     |
| `onCallBack`      | `VoidCallback` | 필수              | 버튼 클릭 시 실행될 콜백             |
| `buttonType`      | `ButtonType`   | `ButtonType.text` | 버튼 타입 (text, elevated, outlined) |
| `backgroundColor` | `Color?`       | `Colors.blue`     | 버튼 배경색                          |
| `foregroundColor` | `Color?`       | 자동              | 버튼 전경색/텍스트 색상              |
| `minimumSize`     | `Size?`        | `Size(100, 60)`   | 버튼 최소 크기                       |
| `borderRadius`    | `double?`      | `10`              | 버튼 모서리 둥글기                   |
| `textFontSize`    | `double?`      | `20`              | 텍스트 크기 (String인 경우)          |
| `textFontWeight`  | `FontWeight?`  | `FontWeight.bold` | 텍스트 굵기 (String인 경우)          |
| `textColor`       | `Color?`       | 자동              | 텍스트 색상 (String인 경우)          |

### 버튼 타입

- `ButtonType.text`: TextButton (배경색 있음, 기본 텍스트 색상: 흰색)
- `ButtonType.elevated`: ElevatedButton (배경색 있음, 기본 텍스트 색상: 흰색)
- `ButtonType.outlined`: OutlinedButton (배경색 없음, 기본 텍스트 색상: 검은색)

### 사용 예시

```dart
// 기본 사용 (String)
CustomButton(
  btnText: "확인",
  onCallBack: () {},
)

// ElevatedButton
CustomButton(
  btnText: "저장",
  buttonType: ButtonType.elevated,
  backgroundColor: Colors.green,
  onCallBack: () {},
)

// OutlinedButton
CustomButton(
  btnText: "취소",
  buttonType: ButtonType.outlined,
  backgroundColor: Colors.red,
  onCallBack: () {},
)

// Widget 사용
CustomButton(
  btnText: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check, color: Colors.white),
      SizedBox(width: 8),
      Text("확인", style: TextStyle(color: Colors.white)),
    ],
  ),
  backgroundColor: Colors.blue,
  onCallBack: () {},
)
```

---

## CustomColumn

세로 방향으로 위젯을 배치하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomColumn(
  children: [
    CustomText("첫 번째"),
    CustomText("두 번째"),
  ],
)
```

### 주요 속성

| 속성                 | 타입                  | 기본값                      | 설명                    |
| -------------------- | --------------------- | --------------------------- | ----------------------- |
| `children`           | `List<Widget>`        | 필수                        | 자식 위젯들             |
| `spacing`            | `double?`             | `12`                        | 자식 위젯들 사이의 간격 |
| `mainAxisAlignment`  | `MainAxisAlignment?`  | `MainAxisAlignment.start`   | 주축 정렬 방식          |
| `crossAxisAlignment` | `CrossAxisAlignment?` | `CrossAxisAlignment.center` | 교차축 정렬 방식        |
| `padding`            | `EdgeInsets?`         | `null`                      | 전체 패딩               |
| `width`              | `double?`             | `null`                      | 너비                    |
| `height`             | `double?`             | `null`                      | 높이                    |
| `backgroundColor`    | `Color?`              | `null`                      | 배경색                  |

### 사용 예시

```dart
// 기본 사용
CustomColumn(
  children: [
    CustomText("항목 1"),
    CustomText("항목 2"),
    CustomText("항목 3"),
  ],
)

// 간격 지정
CustomColumn(
  spacing: 20,
  children: [...],
)

// 정렬 및 패딩
CustomColumn(
  spacing: 16,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  padding: EdgeInsets.all(16),
  backgroundColor: Colors.grey.shade100,
  children: [...],
)
```

---

## CustomRow

가로 방향으로 위젯을 배치하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomRow(
  children: [
    CustomText("왼쪽"),
    CustomText("오른쪽"),
  ],
)
```

### 주요 속성

| 속성                 | 타입                  | 기본값                      | 설명                    |
| -------------------- | --------------------- | --------------------------- | ----------------------- |
| `children`           | `List<Widget>`        | 필수                        | 자식 위젯들             |
| `spacing`            | `double?`             | `12`                        | 자식 위젯들 사이의 간격 |
| `mainAxisAlignment`  | `MainAxisAlignment?`  | `MainAxisAlignment.start`   | 주축 정렬 방식          |
| `crossAxisAlignment` | `CrossAxisAlignment?` | `CrossAxisAlignment.center` | 교차축 정렬 방식        |
| `padding`            | `EdgeInsets?`         | `null`                      | 전체 패딩               |
| `width`              | `double?`             | `null`                      | 너비                    |
| `height`             | `double?`             | `null`                      | 높이                    |
| `backgroundColor`    | `Color?`              | `null`                      | 배경색                  |

### 사용 예시

```dart
// 기본 사용
CustomRow(
  children: [
    CustomText("왼쪽"),
    CustomText("오른쪽"),
  ],
)

// 간격 및 정렬
CustomRow(
  spacing: 16,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [...],
)
```

---

## CustomPadding

패딩을 적용하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomPadding.all(16, child: CustomText("텍스트"))
```

### 주요 속성

| 속성                             | 타입          | 설명                    |
| -------------------------------- | ------------- | ----------------------- |
| `child`                          | `Widget`      | 패딩을 적용할 자식 위젯 |
| `padding`                        | `EdgeInsets?` | 커스텀 패딩 값          |
| `all`                            | `double?`     | 모든 방향에 동일한 패딩 |
| `horizontal`                     | `double?`     | 수평 방향(좌우) 패딩    |
| `vertical`                       | `double?`     | 수직 방향(상하) 패딩    |
| `top`, `bottom`, `left`, `right` | `double?`     | 개별 방향 패딩          |

### 편의 생성자

- `CustomPadding.all(value, child: widget)`: 모든 방향에 동일한 패딩
- `CustomPadding.horizontal(value, child: widget)`: 좌우 패딩
- `CustomPadding.vertical(value, child: widget)`: 상하 패딩

### 사용 예시

```dart
// 모든 방향
CustomPadding.all(16, child: CustomText("텍스트"))

// 수평 방향만
CustomPadding.horizontal(16, child: CustomText("텍스트"))

// 수직 방향만
CustomPadding.vertical(16, child: CustomText("텍스트"))

// 커스텀 패딩
CustomPadding(
  child: CustomText("텍스트"),
  padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
)
```

---

## 실전 예제

### CustomText 실전 예제

#### 스타일 커스터마이징

```dart
CustomText(
  "커스텀 텍스트",
  fontSize: 24,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  textAlign: TextAlign.center,
)
```

### CustomButton 실전 예제

#### 다양한 버튼 타입

```dart
// TextButton
CustomButton(
  btnText: "TextButton",
  buttonType: ButtonType.text,
  backgroundColor: Colors.blue,
  onCallBack: () {},
)

// ElevatedButton
CustomButton(
  btnText: "Elevated",
  buttonType: ButtonType.elevated,
  backgroundColor: Colors.green,
  onCallBack: () {},
)

// OutlinedButton
CustomButton(
  btnText: "Outlined",
  buttonType: ButtonType.outlined,
  backgroundColor: Colors.red,
  onCallBack: () {},
)
```

#### 버튼 스타일 커스터마이징

```dart
CustomButton(
  btnText: "커스텀 버튼",
  backgroundColor: Colors.purple,
  minimumSize: Size(150, 50),
  borderRadius: 20,
  textFontSize: 18,
  textColor: Colors.white,
  onCallBack: () {},
)
```

#### Widget 사용 - 아이콘 + 텍스트

```dart
CustomButton(
  btnText: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, color: Colors.white, size: 20),
      SizedBox(width: 8),
      Text("확인", style: TextStyle(color: Colors.white)),
    ],
  ),
  backgroundColor: Colors.blue,
  onCallBack: () {
    print("확인 버튼 클릭");
  },
)
```

#### Widget 사용 - 커스텀 스타일 텍스트

```dart
CustomButton(
  btnText: CustomText(
    "커스텀 버튼",
    fontSize: 18,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
  backgroundColor: Colors.purple,
  onCallBack: () {},
)
```

#### Widget 사용 - 복잡한 레이아웃

```dart
CustomButton(
  btnText: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.download, color: Colors.white),
      SizedBox(height: 4),
      Text("다운로드", style: TextStyle(color: Colors.white)),
    ],
  ),
  backgroundColor: Colors.green,
  minimumSize: Size(120, 80),
  onCallBack: () {},
)
```

### CustomColumn / CustomRow 실전 예제

#### CustomColumn - 정렬 및 스타일

```dart
CustomColumn(
  spacing: 16,
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  padding: EdgeInsets.all(16),
  backgroundColor: Colors.grey.shade100,
  children: [
    CustomText("첫 번째 항목"),
    CustomText("두 번째 항목"),
    CustomText("세 번째 항목"),
  ],
)
```

#### CustomRow - 간격 및 정렬

```dart
CustomRow(
  spacing: 12,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    CustomText("왼쪽"),
    CustomText("가운데"),
    CustomText("오른쪽"),
  ],
)
```

### CustomPadding 실전 예제

#### 편의 생성자 사용

```dart
// 모든 방향
CustomPadding.all(16, child: CustomText("텍스트"))

// 수평 방향만
CustomPadding.horizontal(16, child: CustomText("텍스트"))

// 수직 방향만
CustomPadding.vertical(16, child: CustomText("텍스트"))

// 개별 방향
CustomPadding(
  child: CustomText("텍스트"),
  top: 20,
  bottom: 10,
  left: 16,
  right: 16,
)
```
