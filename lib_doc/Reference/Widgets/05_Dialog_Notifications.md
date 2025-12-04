# 다이얼로그 및 알림 위젯 클래스

## CustomDialog

AlertDialog를 간편하게 표시하는 헬퍼 클래스입니다.

### 기본 사용법

```dart
CustomDialog.show(
  context,
  title: "알림",
  message: "메시지입니다",
)
```

### 주요 메서드

#### `show`

다이얼로그를 표시하는 정적 메서드입니다.

**파라미터:**

| 파라미터             | 타입                     | 기본값                     | 설명                                   |
| -------------------- | ------------------------ | -------------------------- | -------------------------------------- |
| `context`            | `BuildContext`           | 필수                       | BuildContext                           |
| `title`              | `dynamic`                | 필수                       | 다이얼로그 제목 (String 또는 Widget)   |
| `message`            | `dynamic`                | 필수                       | 다이얼로그 메시지 (String 또는 Widget) |
| `type`               | `DialogType`             | `DialogType.single`        | 다이얼로그 타입                        |
| `confirmText`        | `String`                 | "확인"                     | 확인 버튼 텍스트                       |
| `cancelText`         | `String`                 | "취소"                     | 취소 버튼 텍스트                       |
| `onConfirm`          | `VoidCallback?`          | `null`                     | 확인 버튼 클릭 시 콜백                 |
| `onCancel`           | `VoidCallback?`          | `null`                     | 취소 버튼 클릭 시 콜백                 |
| `autoDismissOnConfirm` | `bool`                 | `true`                     | 확인 버튼 클릭 시 자동으로 다이얼로그 닫기 여부 |
| `autoDismissOnCancel` | `bool`                  | `true`                     | 취소 버튼 클릭 시 자동으로 다이얼로그 닫기 여부 |
| `customActions`      | `List<DialogActionItem>?` | `null`                     | 커스텀 버튼 리스트 (세로 배치, 하위 호환성) |
| `customActionGroups` | `List<DialogActionGroup>?` | `null`                     | 커스텀 버튼 그룹 리스트 (가로/세로 배치 자율성) |
| `actions`            | `List<Widget>?`         | `null`                     | 직접 위젯 리스트 전달 (완전한 자율성) |
| `barrierDismissible` | `bool`                   | `false`                    | 배경 탭으로 닫기 가능 여부             |
| `backgroundColor`    | `Color?`                 | `Colors.white`             | 다이얼로그 배경색                      |
| `borderRadius`       | `double?`                | `null`                     | 다이얼로그 모서리 둥글기               |
| `actionsAlignment`   | `MainAxisAlignment`      | `MainAxisAlignment.center` | 버튼 정렬 방식 (기본 버튼 2개일 때만 적용) |

### DialogType

- `DialogType.single`: 확인 버튼만 있는 다이얼로그
- `DialogType.dual`: 확인/취소 버튼이 있는 다이얼로그
- `DialogType.custom`: 커스텀 버튼들을 사용하는 다이얼로그 (`customActions` 사용 시 자동 설정)

### DialogActionItem

커스텀 버튼의 정보를 담는 클래스입니다. 여러 버튼을 사용할 때 각 버튼의 설정을 정의합니다.

**속성:**

| 속성             | 타입            | 기본값                   | 설명                                              |
| ---------------- | --------------- | ------------------------ | ------------------------------------------------- |
| `label`          | `dynamic`       | 필수                     | 버튼 라벨 (String 또는 Widget)                    |
| `onTap`          | `VoidCallback?` | `null`                   | 버튼 클릭 시 실행될 콜백                          |
| `buttonType`     | `ButtonType`    | `ButtonType.text`        | 버튼 타입 (text, elevated, outlined)             |
| `backgroundColor` | `Color?`        | `null`                   | 버튼 배경색                                       |
| `foregroundColor` | `Color?`        | `null`                   | 버튼 전경색/텍스트 색상                           |
| `minimumSize`    | `Size?`         | `null`                   | 버튼 최소 크기                                    |
| `borderRadius`   | `double?`       | `null`                   | 버튼 모서리 둥글기                                |
| `autoDismiss`    | `bool`          | `true`                   | 버튼 클릭 시 다이얼로그가 자동으로 닫힐지 여부    |

### DialogActionGroup

버튼들을 그룹으로 묶어서 배치 방향을 지정할 수 있는 클래스입니다. Column과 Row를 섞어서 그리드처럼 배치할 수 있습니다.

**속성:**

| 속성             | 타입            | 기본값                   | 설명                                              |
| ---------------- | --------------- | ------------------------ | ------------------------------------------------- |
| `actions`        | `List<DialogActionItem>` | 필수                     | 이 그룹의 버튼들                                  |
| `direction`      | `Axis`           | `Axis.vertical`           | 배치 방향 (horizontal: 가로, vertical: 세로)      |
| `mainAxisAlignment` | `MainAxisAlignment` | `MainAxisAlignment.start` | 주축 정렬 방식                                    |
| `crossAxisAlignment` | `CrossAxisAlignment` | `CrossAxisAlignment.stretch` | 교차축 정렬 방식                                |
| `spacing`        | `double?`        | `null`                    | 버튼 간 간격                                      |

**우선순위:**
- `actions` (최우선) → `customActionGroups` → `customActions` (하위 호환)

### 사용 예시

```dart
// 단일 버튼 다이얼로그 (String)
CustomDialog.show(
  context,
  title: "알림",
  message: "작업이 완료되었습니다.",
  type: DialogType.single,
)

// 이중 버튼 다이얼로그
CustomDialog.show(
  context,
  title: "확인",
  message: "진행하시겠습니까?",
  type: DialogType.dual,
  onConfirm: () {
    print("확인 버튼 클릭");
  },
  onCancel: () {
    print("취소 버튼 클릭");
  },
)

// Widget 사용
CustomDialog.show(
  context,
  title: Row(
    children: [
      Icon(Icons.info, color: Colors.blue),
      SizedBox(width: 8),
      Text("정보"),
    ],
  ),
  message: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("이것은 Widget을 사용한 다이얼로그입니다."),
      SizedBox(height: 8),
      Text("제목과 메시지 모두 Widget으로 지정할 수 있습니다."),
    ],
  ),
  type: DialogType.single,
)

// 버튼 정렬
CustomDialog.show(
  context,
  title: "정렬 예시",
  message: "버튼이 왼쪽 정렬됩니다.",
  type: DialogType.dual,
  actionsAlignment: MainAxisAlignment.start,
)

// 자동 닫힘 제어 - 확인 버튼 클릭 시 닫히지 않음
CustomDialog.show(
  context,
  title: "처리 중",
  message: "확인 버튼을 눌러도 닫히지 않습니다.",
  type: DialogType.single,
  autoDismissOnConfirm: false,
  onConfirm: () {
    // 다이얼로그가 자동으로 닫히지 않음
    // 필요 시 수동으로 Navigator.pop(context) 호출
  },
)

// 자동 닫힘 제어 - 확인은 닫지 않고 취소만 닫기
CustomDialog.show(
  context,
  title: "확인",
  message: "확인 버튼은 닫히지 않고, 취소 버튼만 닫습니다.",
  type: DialogType.dual,
  autoDismissOnConfirm: false,
  autoDismissOnCancel: true,
  onConfirm: () {
    print("확인 클릭 - 다이얼로그는 열려있음");
  },
  onCancel: () {
    print("취소 클릭 - 다이얼로그가 닫힘");
  },
)

// 커스텀 버튼 - 여러 버튼 사용
CustomDialog.show(
  context,
  title: "작업 선택",
  message: "원하는 작업을 선택해주세요.",
  customActions: [
    DialogActionItem(
      label: "저장",
      backgroundColor: Colors.green,
      onTap: () {
        print("저장");
      },
      autoDismiss: true,
    ),
    DialogActionItem(
      label: "수정",
      backgroundColor: Colors.blue,
      onTap: () {
        print("수정");
      },
    ),
    DialogActionItem(
      label: "취소",
      buttonType: ButtonType.outlined,
      backgroundColor: Colors.grey,
      onTap: () {
        print("취소");
      },
    ),
  ],
)

// 커스텀 버튼 - Widget 라벨 사용 (아이콘 포함)
CustomDialog.show(
  context,
  title: "선택",
  message: "버튼 라벨에 아이콘을 포함할 수 있습니다.",
  customActions: [
    DialogActionItem(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save, color: Colors.white, size: 20),
          SizedBox(width: 4),
          Text("저장"),
        ],
      ),
      backgroundColor: Colors.green,
      onTap: () {
        print("저장");
      },
    ),
    DialogActionItem(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 20),
          SizedBox(width: 4),
          Text("삭제"),
        ],
      ),
      backgroundColor: Colors.red,
      onTap: () {
        print("삭제");
      },
    ),
  ],
)

// 커스텀 버튼 - 자동 닫힘 제어
CustomDialog.show(
  context,
  title: "선택",
  message: "저장 버튼은 다이얼로그를 닫지 않습니다.",
  customActions: [
    DialogActionItem(
      label: "저장",
      backgroundColor: Colors.green,
      onTap: () {
        print("저장 중... (다이얼로그는 열려있음)");
      },
      autoDismiss: false, // 자동으로 닫히지 않음
    ),
    DialogActionItem(
      label: "취소",
      buttonType: ButtonType.outlined,
      backgroundColor: Colors.grey,
      onTap: () {
        print("취소 (다이얼로그 닫힘)");
      },
      autoDismiss: true, // 자동으로 닫힘
    ),
  ],
)
```

---

## CustomSnackBar

SnackBar를 간편하게 표시하는 헬퍼 클래스입니다.

### 주요 메서드

#### `show`

SnackBar를 표시하는 정적 메서드입니다.

**파라미터:**

| 파라미터          | 타입                    | 기본값                   | 설명                                                      |
| ----------------- | ----------------------- | ------------------------ | --------------------------------------------------------- |
| `context`         | `BuildContext`          | 필수                     | BuildContext                                              |
| `message`         | `dynamic`               | 필수                     | 메시지 (String 또는 Widget)                                |
| `actionLabel`     | `String?`               | `null`                   | 액션 버튼 라벨                                            |
| `onAction`        | `VoidCallback?`         | `null`                   | 액션 버튼 클릭 시 콜백                                    |
| `duration`        | `Duration`              | `Duration(seconds: 3)`   | 표시 시간                                                 |
| `backgroundColor` | `Color?`                | `Colors.grey.shade800`   | 배경색                                                    |
| `textColor`       | `Color?`                | `Colors.white`           | 텍스트 색상 (String인 경우)                                |
| `behavior`        | `SnackBarBehavior`      | `SnackBarBehavior.fixed` | SnackBar 동작 방식 (`fixed` 또는 `floating`)             |
| `margin`          | `EdgeInsetsGeometry?`  | `null`                   | SnackBar 여백 (floating에서만 사용 가능)                  |

#### `showSuccess`

성공 메시지를 표시하는 메서드 (녹색 배경)

#### `showError`

에러 메시지를 표시하는 메서드 (빨간색 배경)

#### `showWarning`

경고 메시지를 표시하는 메서드 (주황색 배경)

#### `showInfo`

정보 메시지를 표시하는 메서드 (파란색 배경)

### 사용 예시

```dart
// 기본 사용 (String)
CustomSnackBar.show(
  context,
  message: "기본 SnackBar 메시지입니다.",
)

// 성공 메시지
CustomSnackBar.showSuccess(
  context,
  message: "작업이 성공적으로 완료되었습니다!",
)

// 에러 메시지
CustomSnackBar.showError(
  context,
  message: "에러가 발생했습니다. 다시 시도해주세요.",
)

// 경고 메시지
CustomSnackBar.showWarning(
  context,
  message: "주의가 필요한 상황입니다.",
)

// 정보 메시지
CustomSnackBar.showInfo(
  context,
  message: "이것은 정보 메시지입니다.",
)

// 액션 버튼 포함
CustomSnackBar.show(
  context,
  message: "메시지를 삭제하시겠습니까?",
  actionLabel: "실행",
  onAction: () {
    print("삭제 실행");
  },
)

// Widget 사용
CustomSnackBar.show(
  context,
  message: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 8),
      Text("성공적으로 완료되었습니다!", style: TextStyle(color: Colors.white)),
    ],
  ),
  backgroundColor: Colors.green,
)

// behavior 옵션 사용
CustomSnackBar.show(
  context,
  message: "메시지",
  behavior: SnackBarBehavior.floating, // 공중에 떠있는 형태
)

// margin 사용 (floating에서만 가능)
CustomSnackBar.show(
  context,
  message: "메시지",
  behavior: SnackBarBehavior.floating,
  margin: EdgeInsets.all(16), // 여백 설정
)
```

### Dialog 내부에서 SnackBar 사용

Dialog 내부에서 SnackBar를 표시할 때는 `CustomDialog`의 `onConfirmWithContexts` 콜백을 사용하여 Dialog 위에 SnackBar가 표시되도록 할 수 있습니다.

```dart
CustomDialog.show(
  context,
  title: "알림",
  message: "확인 버튼을 누르면 SnackBar가 표시됩니다.",
  type: DialogType.dual,
  autoDismissOnConfirm: false,
  onConfirmWithContexts: (dialogContext, dialogScaffoldCtx) {
    // Dialog 내부 Scaffold의 context를 사용하여 SnackBar 표시
    // Dialog 위에 SnackBar가 표시됨
    CustomSnackBar.showSuccess(
      dialogScaffoldCtx,
      message: "Dialog 내부에서 표시된 SnackBar",
      behavior: SnackBarBehavior.floating, // Dialog 위에 띄울 때는 floating 권장
    );
  },
)
```

**주의사항:**
- `margin`은 `SnackBarBehavior.floating`에서만 사용 가능합니다.
- `SnackBarBehavior.fixed`에서는 `margin`을 사용할 수 없습니다.
- Dialog 내부에서 SnackBar를 표시할 때는 `floating`을 사용하는 것이 깔끔합니다.
```

---

## CustomActionSheet

ActionSheet를 간편하게 표시하는 헬퍼 클래스입니다.

### 주요 메서드

#### `show`

ActionSheet를 표시하는 정적 메서드입니다.

**파라미터:**

| 파라미터          | 타입                    | 기본값         | 설명                |
| ----------------- | ----------------------- | -------------- | ------------------- |
| `context`         | `BuildContext`          | 필수           | BuildContext        |
| `title`           | `String?`               | `null`         | 제목                |
| `message`         | `String?`               | `null`         | 메시지              |
| `items`           | `List<ActionSheetItem>` | 필수           | 액션 항목 리스트    |
| `showCancel`      | `bool`                  | `true`         | 취소 버튼 표시 여부 |
| `cancelText`      | `String`                | "취소"         | 취소 버튼 텍스트    |
| `backgroundColor` | `Color?`                | `Colors.white` | 배경색              |
| `borderRadius`    | `double?`               | `20`           | 모서리 둥글기       |

#### `showSimple`

간단한 액션시트를 표시하는 메서드 (라벨만 있는 경우)

**파라미터:**

| 파라미터     | 타입                 | 기본값 | 설명                             |
| ------------ | -------------------- | ------ | -------------------------------- |
| `context`    | `BuildContext`       | 필수   | BuildContext                     |
| `labels`     | `List<String>`       | 필수   | 라벨 리스트                      |
| `callbacks`  | `List<VoidCallback>` | 필수   | 콜백 리스트 (labels와 개수 동일) |
| `title`      | `String?`            | `null` | 제목                             |
| `showCancel` | `bool`               | `true` | 취소 버튼 표시 여부              |
| `cancelText` | `String`             | "취소" | 취소 버튼 텍스트                 |

### ActionSheetItem 속성

| 속성            | 타입            | 기본값         | 설명                                              |
| --------------- | --------------- | -------------- | ------------------------------------------------- |
| `label`         | `dynamic`       | 필수           | 액션 항목의 텍스트 또는 위젯 (String 또는 Widget) |
| `icon`          | `IconData?`     | `null`         | 액션 항목의 아이콘                                |
| `textColor`     | `Color?`        | `Colors.black` | 액션 항목의 텍스트 색상                           |
| `onTap`         | `VoidCallback?` | `null`         | 액션 항목 클릭 시 실행될 콜백                     |
| `isDestructive` | `bool`          | `false`        | 위험한 작업 여부 (true일 경우 빨간색 표시)        |

### 사용 예시

```dart
// 기본 사용 (String)
CustomActionSheet.show(
  context,
  title: "선택하세요",
  items: [
    ActionSheetItem(
      label: "옵션 1",
      icon: Icons.check_circle,
      onTap: () {
        print("옵션 1 선택");
      },
    ),
    ActionSheetItem(
      label: "옵션 2",
      icon: Icons.favorite,
      onTap: () {
        print("옵션 2 선택");
      },
    ),
  ],
)

// 위험 작업 포함
CustomActionSheet.show(
  context,
  title: "계정 관리",
  items: [
    ActionSheetItem(
      label: "프로필 수정",
      icon: Icons.edit,
      onTap: () {},
    ),
    ActionSheetItem(
      label: "계정 삭제",
      icon: Icons.delete,
      isDestructive: true,
      onTap: () {
        print("계정 삭제");
      },
    ),
  ],
)

// Widget 사용
CustomActionSheet.show(
  context,
  title: "선택하세요",
  items: [
    ActionSheetItem(
      label: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 8),
          Text("수정"),
        ],
      ),
      onTap: () {
        print("수정 선택");
      },
    ),
    ActionSheetItem(
      label: Row(
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 8),
          Text("삭제", style: TextStyle(color: Colors.red)),
        ],
      ),
      isDestructive: true,
      onTap: () {
        print("삭제 선택");
      },
    ),
  ],
)

// 간단한 사용
CustomActionSheet.showSimple(
  context,
  title: "색상 선택",
  labels: ["빨강", "파랑", "초록"],
  callbacks: [
    () => print("빨강 선택"),
    () => print("파랑 선택"),
    () => print("초록 선택"),
  ],
)
```

---

## 실전 예제

### CustomDialog 실전 예제

#### 이중 버튼 다이얼로그

```dart
CustomDialog.show(
  context,
  title: "확인",
  message: "정말로 삭제하시겠습니까?",
  type: DialogType.dual,
  confirmText: "삭제",
  cancelText: "취소",
  onConfirm: () {
    print("삭제 확인");
  },
  onCancel: () {
    print("취소");
  },
)
```

#### 버튼 정렬

```dart
CustomDialog.show(
  context,
  title: "정렬 예시",
  message: "버튼이 왼쪽 정렬됩니다.",
  type: DialogType.dual,
  actionsAlignment: MainAxisAlignment.start,
)
```

#### Widget 사용 - 제목에 아이콘 포함

```dart
CustomDialog.show(
  context,
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.info, color: Colors.blue),
      SizedBox(width: 8),
      CustomText(
        "정보",
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ],
  ),
  message: "이것은 정보 다이얼로그입니다.",
  type: DialogType.single,
)
```

#### Widget 사용 - 복잡한 메시지 레이아웃

```dart
CustomDialog.show(
  context,
  title: "알림",
  message: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.warning, color: Colors.orange, size: 48),
      SizedBox(height: 16),
      CustomText("주의", fontSize: 20, fontWeight: FontWeight.bold),
      SizedBox(height: 8),
      CustomText("이 작업은 되돌릴 수 없습니다.", fontSize: 16),
    ],
  ),
  type: DialogType.dual,
  onConfirm: () {
    print("확인");
  },
)
```

#### 자동 닫힘 제어 - 비동기 작업 후 수동으로 닫기

```dart
CustomDialog.show(
  context,
  title: "처리 중",
  message: "작업을 수행한 후 자동으로 닫힙니다...",
  type: DialogType.single,
  autoDismissOnConfirm: false,
  confirmText: "처리 시작",
  onConfirm: () async {
    // 비동기 작업 시뮬레이션
    await Future.delayed(Duration(seconds: 2));
    if (context.mounted) {
      Navigator.pop(context);
      // 완료 다이얼로그 표시
      CustomDialog.show(
        context,
        title: "완료",
        message: "작업이 완료되었습니다!",
        type: DialogType.single,
      );
    }
  },
)
```

#### 커스텀 버튼 - 여러 버튼 사용

```dart
CustomDialog.show(
  context,
  title: "파일 관리",
  message: "이 파일에 대해 어떤 작업을 하시겠습니까?",
  customActions: [
    DialogActionItem(
      label: "저장",
      backgroundColor: Colors.green,
      minimumSize: Size(70, 40),
      onTap: () {
        print("저장");
        Navigator.pop(context);
        CustomDialog.show(
          context,
          title: "저장 완료",
          message: "파일이 저장되었습니다.",
          type: DialogType.single,
        );
      },
    ),
    DialogActionItem(
      label: "수정",
      backgroundColor: Colors.blue,
      minimumSize: Size(70, 40),
      onTap: () {
        print("수정");
      },
    ),
    DialogActionItem(
      label: "삭제",
      backgroundColor: Colors.red,
      buttonType: ButtonType.outlined,
      minimumSize: Size(70, 40),
      onTap: () {
        print("삭제");
      },
    ),
    DialogActionItem(
      label: "취소",
      buttonType: ButtonType.outlined,
      backgroundColor: Colors.grey,
      minimumSize: Size(70, 40),
      onTap: () {},
    ),
  ],
)
```

#### 커스텀 버튼 - Widget 라벨 사용

```dart
CustomDialog.show(
  context,
  title: "선택",
  message: "버튼 라벨에 아이콘을 포함할 수 있습니다.",
  customActions: [
    DialogActionItem(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save, color: Colors.white, size: 20),
          SizedBox(width: 4),
          CustomText("저장", fontSize: 16),
        ],
      ),
      backgroundColor: Colors.green,
      onTap: () {
        print("저장");
      },
    ),
    DialogActionItem(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete, color: Colors.white, size: 20),
          SizedBox(width: 4),
          CustomText("삭제", fontSize: 16),
        ],
      ),
      backgroundColor: Colors.red,
      onTap: () {
        print("삭제");
      },
    ),
    DialogActionItem(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, color: Colors.grey.shade700, size: 20),
          SizedBox(width: 4),
          CustomText("취소", fontSize: 16, color: Colors.grey.shade700),
        ],
      ),
      buttonType: ButtonType.outlined,
      backgroundColor: Colors.grey,
      onTap: () {},
    ),
  ],
)
```

#### 커스텀 버튼 그룹 - 가로 배치

```dart
CustomDialog.show(
  context,
  title: "작업 선택",
  message: "원하는 작업을 선택해주세요.",
  customActionGroups: [
    DialogActionGroup(
      actions: [
        DialogActionItem(
          label: "저장",
          backgroundColor: Colors.green,
          onTap: () {
            print("저장 선택");
          },
          autoDismiss: true,
        ),
        DialogActionItem(
          label: "수정",
          backgroundColor: Colors.blue,
          onTap: () {
            print("수정 선택");
          },
          autoDismiss: true,
        ),
        DialogActionItem(
          label: "취소",
          buttonType: ButtonType.outlined,
          backgroundColor: Colors.grey,
          onTap: () {
            print("취소 선택");
          },
          autoDismiss: true,
        ),
      ],
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
    ),
  ],
)
```

#### 커스텀 버튼 그룹 - 그리드 배치 (Row + Column 혼합)

```dart
CustomDialog.show(
  context,
  title: "작업 선택",
  message: "원하는 작업을 선택해주세요.",
  customActionGroups: [
    // 첫 번째 행: 가로 배치
    DialogActionGroup(
      actions: [
        DialogActionItem(
          label: "저장",
          backgroundColor: Colors.green,
          onTap: () {
            print("저장 선택");
          },
          autoDismiss: true,
        ),
        DialogActionItem(
          label: "수정",
          backgroundColor: Colors.blue,
          onTap: () {
            print("수정 선택");
          },
          autoDismiss: true,
        ),
      ],
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
    ),
    // 두 번째 행: 가로 배치
    DialogActionGroup(
      actions: [
        DialogActionItem(
          label: "삭제",
          backgroundColor: Colors.red,
          onTap: () {
            print("삭제 선택");
          },
          autoDismiss: true,
        ),
        DialogActionItem(
          label: "취소",
          buttonType: ButtonType.outlined,
          backgroundColor: Colors.grey,
          onTap: () {
            print("취소 선택");
          },
          autoDismiss: true,
        ),
      ],
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
    ),
  ],
)
```

#### 직접 위젯 전달 (actions 파라미터)

```dart
CustomDialog.show(
  context,
  title: "작업 선택",
  message: "원하는 작업을 선택해주세요.",
  actions: [
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: CustomButton(
            btnText: "저장",
            backgroundColor: Colors.green,
            minimumSize: const Size(0, 40),
            onCallBack: () {
              print("저장 선택");
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomButton(
            btnText: "수정",
            backgroundColor: Colors.blue,
            minimumSize: const Size(0, 40),
            onCallBack: () {
              print("수정 선택");
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomButton(
            btnText: "취소",
            buttonType: ButtonType.outlined,
            backgroundColor: Colors.grey,
            minimumSize: const Size(0, 40),
            onCallBack: () {
              print("취소 선택");
              Navigator.pop(context);
            },
          ),
        ),
      ],
    ),
  ],
)
```

### CustomSnackBar 실전 예제

#### 다양한 타입

```dart
// 성공
CustomSnackBar.showSuccess(
  context,
  message: "작업이 성공적으로 완료되었습니다!",
)

// 에러
CustomSnackBar.showError(
  context,
  message: "에러가 발생했습니다.",
)

// 경고
CustomSnackBar.showWarning(
  context,
  message: "주의가 필요한 상황입니다.",
)

// 정보
CustomSnackBar.showInfo(
  context,
  message: "이것은 정보 메시지입니다.",
)
```

#### 액션 버튼 포함

```dart
CustomSnackBar.show(
  context,
  message: "메시지를 삭제하시겠습니까?",
  actionLabel: "실행",
  onAction: () {
    print("삭제 실행");
  },
)
```

#### Widget 사용 - 아이콘 + 텍스트

```dart
CustomSnackBar.show(
  context,
  message: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 8),
      Text(
        "성공적으로 완료되었습니다!",
        style: TextStyle(color: Colors.white),
      ),
    ],
  ),
  backgroundColor: Colors.green,
)
```

#### Widget 사용 - 여러 줄 메시지

```dart
CustomSnackBar.show(
  context,
  message: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "제목",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      SizedBox(height: 4),
      Text(
        "상세 메시지 내용",
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ],
  ),
  backgroundColor: Colors.blue,
  duration: Duration(seconds: 5),
)
```

### CustomActionSheet 실전 예제

#### 위험 작업 포함

```dart
CustomActionSheet.show(
  context,
  title: "계정 관리",
  items: [
    ActionSheetItem(
      label: "프로필 수정",
      icon: Icons.edit,
      onTap: () {},
    ),
    ActionSheetItem(
      label: "계정 삭제",
      icon: Icons.delete,
      isDestructive: true,
      onTap: () {
        print("계정 삭제");
      },
    ),
  ],
)
```

#### 간단한 사용

```dart
CustomActionSheet.showSimple(
  context,
  title: "색상 선택",
  labels: ["빨강", "파랑", "초록"],
  callbacks: [
    () => print("빨강 선택"),
    () => print("파랑 선택"),
    () => print("초록 선택"),
  ],
)
```

#### Widget 사용 - 아이콘 + 텍스트

```dart
CustomActionSheet.show(
  context,
  title: "선택하세요",
  items: [
    ActionSheetItem(
      label: Row(
        children: [
          Icon(Icons.edit, color: Colors.blue),
          SizedBox(width: 8),
          Text("수정"),
        ],
      ),
      onTap: () {
        print("수정 선택");
      },
    ),
    ActionSheetItem(
      label: Row(
        children: [
          Icon(Icons.delete, color: Colors.red),
          SizedBox(width: 8),
          Text("삭제", style: TextStyle(color: Colors.red)),
        ],
      ),
      isDestructive: true,
      onTap: () {
        print("삭제 선택");
      },
    ),
  ],
)
```

#### Widget 사용 - 복잡한 레이아웃

```dart
CustomActionSheet.show(
  context,
  title: "계정 관리",
  items: [
    ActionSheetItem(
      label: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, color: Colors.blue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "프로필 수정",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "프로필 정보를 수정합니다",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {},
    ),
  ],
)
```

---

## CustomBottomSheet

하단 시트 다이얼로그를 간편하게 표시하는 헬퍼 클래스입니다.

### 기본 사용법

```dart
CustomBottomSheet.show(
  context: context,
  title: "옵션 선택",
  items: [
    BottomSheetItem(label: "옵션 1", onTap: () {}),
    BottomSheetItem(label: "옵션 2", onTap: () {}),
  ],
)
```

### 주요 메서드

#### `show`

BottomSheet를 표시하는 정적 메서드입니다.

**파라미터:**

| 파라미터            | 타입                    | 기본값         | 설명                                    |
| ------------------- | ----------------------- | -------------- | --------------------------------------- |
| `context`           | `BuildContext`          | 필수           | BuildContext                            |
| `title`             | `String?`               | `null`         | 제목                                    |
| `message`           | `String?`               | `null`         | 메시지                                  |
| `items`             | `List<BottomSheetItem>?` | `null`         | BottomSheet 항목 리스트 (items 또는 child 중 하나 필수) |
| `child`             | `Widget?`               | `null`         | 커스텀 위젯 (items 또는 child 중 하나 필수) |
| `isDismissible`     | `bool`                  | `true`         | 배경 탭으로 닫기 가능 여부              |
| `enableDrag`        | `bool`                  | `true`         | 드래그로 닫기 가능 여부                 |
| `backgroundColor`    | `Color?`                | `Colors.white` | 배경색                                  |
| `borderRadius`      | `double?`               | `20`           | 모서리 둥글기                           |
| `isScrollControlled` | `bool`                  | `false`        | 스크롤 제어 여부                        |
| `height`            | `double?`               | `null`         | 높이                                    |

### BottomSheetItem 속성

| 속성            | 타입            | 기본값         | 설명                                              |
| --------------- | --------------- | -------------- | ------------------------------------------------- |
| `label`         | `dynamic`       | 필수           | 항목의 텍스트 또는 위젯 (String 또는 Widget)     |
| `icon`          | `IconData?`     | `null`         | 항목의 아이콘                                     |
| `textColor`     | `Color?`        | `Colors.black` | 항목의 텍스트 색상                                 |
| `onTap`         | `VoidCallback?` | `null`         | 항목 클릭 시 실행될 콜백                           |
| `isDestructive` | `bool`          | `false`        | 위험한 작업 여부 (true일 경우 빨간색 표시)        |

### 사용 예시

```dart
// 기본 사용 (String)
CustomBottomSheet.show(
  context: context,
  title: "옵션 선택",
  items: [
    BottomSheetItem(
      label: "옵션 1",
      icon: Icons.check_circle,
      onTap: () {
        print("옵션 1 선택");
      },
    ),
    BottomSheetItem(
      label: "옵션 2",
      icon: Icons.favorite,
      onTap: () {
        print("옵션 2 선택");
      },
    ),
  ],
)

// 위험 작업 포함
CustomBottomSheet.show(
  context: context,
  title: "계정 관리",
  items: [
    BottomSheetItem(
      label: "프로필 수정",
      icon: Icons.edit,
      onTap: () {},
    ),
    BottomSheetItem(
      label: "계정 삭제",
      icon: Icons.delete,
      isDestructive: true,
      onTap: () {
        print("계정 삭제");
      },
    ),
  ],
)

// 커스텀 위젯 사용
CustomBottomSheet.show(
  context: context,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(title: Text("커스텀 위젯")),
      ListTile(title: Text("항목 1")),
      ListTile(title: Text("항목 2")),
    ],
  ),
)

// 높이 지정
CustomBottomSheet.show(
  context: context,
  title: "옵션",
  items: [
    BottomSheetItem(label: "옵션 1", onTap: () {}),
  ],
  height: 300,
)
```

---

## 실전 예제

### CustomBottomSheet 실전 예제

#### 기본 사용

```dart
CustomBottomSheet.show(
  context: context,
  title: "선택하세요",
  items: [
    BottomSheetItem(
      label: "옵션 1",
      icon: Icons.check_circle,
      onTap: () {
        print("옵션 1 선택");
      },
    ),
    BottomSheetItem(
      label: "옵션 2",
      icon: Icons.favorite,
      onTap: () {
        print("옵션 2 선택");
      },
    ),
  ],
)
```

#### 위험 작업 포함

```dart
CustomBottomSheet.show(
  context: context,
  title: "계정 관리",
  items: [
    BottomSheetItem(
      label: "프로필 수정",
      icon: Icons.edit,
      onTap: () {},
    ),
    BottomSheetItem(
      label: "계정 삭제",
      icon: Icons.delete,
      isDestructive: true,
      onTap: () {
        print("계정 삭제");
      },
    ),
  ],
)
```

#### 커스텀 위젯 사용

```dart
CustomBottomSheet.show(
  context: context,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "커스텀 위젯",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      ListTile(title: Text("항목 1")),
      ListTile(title: Text("항목 2")),
    ],
  ),
)
```
