# 입력 위젯 클래스

## CustomTextField

텍스트 입력 필드를 표시하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomTextField(
  controller: TextEditingController(),
  labelText: "이름",
)
```

### 주요 속성

| 속성              | 타입                         | 기본값                 | 설명                  |
| ----------------- | ---------------------------- | ---------------------- | --------------------- |
| `controller`      | `TextEditingController`      | 필수                   | 텍스트 입력 컨트롤러  |
| `labelText`       | `String?`                    | `null`                 | 라벨 텍스트           |
| `hintText`        | `String?`                    | `null`                 | 힌트 텍스트           |
| `obscureText`     | `bool`                       | `false`                | 비밀번호 입력 모드    |
| `keyboardType`    | `TextInputType?`             | `TextInputType.text`   | 키보드 타입           |
| `maxLength`       | `int?`                       | `null`                 | 최대 입력 길이        |
| `maxLines`        | `int?`                       | `1`                    | 최대 줄 수            |
| `readOnly`        | `bool`                       | `false`                | 읽기 전용 여부        |
| `enabled`         | `bool`                       | `true`                 | 입력 필드 활성화 여부 |
| `required`        | `bool`                       | `false`                | 필수 입력 여부        |
| `requiredMessage` | `String?`                    | "이 필드는 필수입니다" | 필수 입력 에러 메시지 |
| `validator`       | `String? Function(String?)?` | `null`                 | 입력 검증 함수        |
| `onChanged`       | `ValueChanged<String>?`      | `null`                 | 입력 변경 콜백        |
| `onSubmitted`     | `ValueChanged<String>?`      | `null`                 | 입력 완료 콜백        |

### 사용 예시

```dart
// 기본 사용
CustomTextField(
  controller: _nameController,
  labelText: "이름",
)

// 비밀번호 입력
CustomTextField(
  controller: _passwordController,
  labelText: "비밀번호",
  obscureText: true,
)

// 숫자 입력
CustomTextField(
  controller: _numberController,
  labelText: "숫자",
  keyboardType: TextInputType.number,
)

// 필수 입력
CustomTextField(
  controller: _emailController,
  labelText: "이메일",
  required: true,
  requiredMessage: "이메일을 입력해주세요",
)

// 검증 함수 사용
CustomTextField(
  controller: _phoneController,
  labelText: "전화번호",
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "전화번호를 입력해주세요";
    }
    if (!RegExp(r'^[0-9-]+$').hasMatch(value)) {
      return "올바른 전화번호 형식이 아닙니다";
    }
    return null;
  },
)
```

### 정적 메서드

#### `textCheck`

빈 입력값을 체크하는 정적 메서드입니다.

```dart
static bool textCheck(
  BuildContext context,
  TextEditingController controller,
)
```

**사용 예시:**

```dart
if (CustomTextField.textCheck(context, _nameController)) {
  // 입력값이 있음
  print("이름: ${_nameController.text}");
} else {
  // 입력값이 없음 (키보드도 자동으로 내려짐)
  print("이름을 입력해주세요");
}
```

### Form과 함께 사용

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      CustomTextField(
        controller: _nameController,
        labelText: "이름",
        required: true,
      ),
      CustomTextField(
        controller: _emailController,
        labelText: "이메일",
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "이메일을 입력해주세요";
          }
          if (!value.contains('@')) {
            return "올바른 이메일 형식이 아닙니다";
          }
          return null;
        },
      ),
      CustomButton(
        btnText: "제출",
        onCallBack: () {
          if (_formKey.currentState!.validate()) {
            // 폼 검증 성공
            print("제출 성공");
          }
        },
      ),
    ],
  ),
)
```

---

## CustomSwitch

스위치(켜짐/꺼짐) 토글 위젯입니다.

### 기본 사용법

```dart
CustomSwitch(
  value: _isSwitched,
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)
```

### 주요 속성

| 속성                    | 타입                     | 기본값        | 설명                           |
| ----------------------- | ------------------------ | ------------- | ------------------------------ |
| `value`                 | `bool`                   | 필수          | Switch의 현재 값               |
| `onChanged`             | `ValueChanged<bool>`     | 필수          | 값 변경 시 호출되는 콜백       |
| `activeColor`           | `Color?`                 | `Colors.blue` | 활성화 상태의 색상             |
| `inactiveColor`         | `Color?`                 | `null`        | 비활성화 상태의 색상           |
| `inactiveThumbColor`    | `Color?`                 | `null`        | 비활성화 상태의 썸(thumb) 색상 |
| `inactiveTrackColor`    | `Color?`                 | `null`        | 비활성화 상태의 트랙 색상      |
| `thumbColor`            | `Color?`                 | `null`        | 활성화 상태의 썸(thumb) 색상   |
| `trackColor`            | `Color?`                 | `null`        | 활성화 상태의 트랙 색상        |
| `label`                 | `String?`                | `null`        | Switch 옆에 표시할 레이블      |
| `labelStyle`            | `TextStyle?`             | `null`        | 레이블 텍스트 스타일           |
| `spacing`               | `double?`                | `12`          | Switch와 레이블 사이의 간격    |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | `null`        | Switch 크기 조절               |
| `switchTheme`           | `SwitchThemeData?`       | `null`        | 커스텀 SwitchThemeData         |

### 사용 예시

```dart
// 기본 사용
CustomSwitch(
  value: _isSwitched,
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)

// 레이블 포함
CustomSwitch(
  value: _isSwitched,
  label: "알림 받기",
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)

// 색상 변경
CustomSwitch(
  value: _isSwitched,
  activeColor: Colors.green,
  label: "다크 모드",
  onChanged: (value) {
    setState(() {
      _isSwitched = value;
    });
  },
)
```

---

## CustomCheckbox

체크박스 위젯입니다.

### 기본 사용법

```dart
CustomCheckbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value;
    });
  },
)
```

### 주요 속성

| 속성                    | 타입                     | 기본값         | 설명                          |
| ----------------------- | ------------------------ | -------------- | ----------------------------- |
| `value`                 | `bool?`                  | 필수           | Checkbox의 현재 값            |
| `onChanged`             | `ValueChanged<bool?>?`   | 필수           | 값 변경 시 호출되는 콜백      |
| `activeColor`           | `Color?`                 | `Colors.blue`  | 활성화 상태의 색상            |
| `inactiveColor`         | `Color?`                 | `null`         | 비활성화 상태의 색상          |
| `checkColor`            | `Color?`                 | `Colors.white` | 체크 마크 색상                |
| `label`                 | `String?`                | `null`         | Checkbox 옆에 표시할 레이블   |
| `labelStyle`            | `TextStyle?`             | `null`         | 레이블 텍스트 스타일          |
| `spacing`               | `double?`                | `8`            | Checkbox와 레이블 사이의 간격 |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | `null`         | Checkbox 크기 조절            |
| `visualDensity`         | `VisualDensity?`         | `null`         | 시각적 밀도                   |
| `checkboxTheme`         | `CheckboxThemeData?`     | `null`         | 커스텀 CheckboxThemeData      |

### 사용 예시

```dart
// 기본 사용
CustomCheckbox(
  value: _isChecked,
  onChanged: (value) {
    setState(() {
      _isChecked = value;
    });
  },
)

// 레이블 포함
CustomCheckbox(
  value: _isChecked,
  label: "이용약관 동의",
  onChanged: (value) {
    setState(() {
      _isChecked = value;
    });
  },
)

// 색상 변경
CustomCheckbox(
  value: _isChecked,
  activeColor: Colors.purple,
  label: "개인정보 처리방침 동의",
  onChanged: (value) {
    setState(() {
      _isChecked = value;
    });
  },
)
```

---

## CustomRadio

라디오 버튼 위젯입니다. 여러 옵션 중 하나를 선택할 때 사용합니다.

**Flutter 3.24+ 버전에서는 `Radio.adaptive`를 사용하여 플랫폼에 맞는 스타일을 자동으로 적용합니다.**

### 기본 사용법

```dart
CustomRadio<String>(
  value: "option1",
  groupValue: _selectedOption,
  onChanged: (value) {
    setState(() {
      _selectedOption = value;
    });
  },
)
```

### 주요 속성

| 속성                    | 타입                     | 기본값        | 설명                       |
| ----------------------- | ------------------------ | ------------- | -------------------------- |
| `value`                 | `T`                      | 필수          | Radio의 값                 |
| `groupValue`            | `T?`                     | 필수          | 현재 선택된 그룹 값        |
| `onChanged`             | `ValueChanged<T?>?`      | 필수          | 값 변경 시 호출되는 콜백   |
| `activeColor`           | `Color?`                 | `Colors.blue` | 활성화 상태의 색상         |
| `inactiveColor`         | `Color?`                 | `null`        | 비활성화 상태의 색상       |
| `label`                 | `String?`                | `null`        | Radio 옆에 표시할 레이블   |
| `labelStyle`            | `TextStyle?`             | `null`        | 레이블 텍스트 스타일       |
| `spacing`               | `double?`                | `8`           | Radio와 레이블 사이의 간격 |
| `materialTapTargetSize` | `MaterialTapTargetSize?` | `null`        | Radio 크기 조절            |
| `visualDensity`         | `VisualDensity?`         | `null`        | 시각적 밀도                |
| `adaptive`              | `bool`                   | `true`        | Radio.adaptive 사용 여부   |
| `radioTheme`            | `RadioThemeData?`        | `null`        | 커스텀 RadioThemeData      |

### 사용 예시

```dart
// 기본 사용
CustomRadio<String>(
  value: "option1",
  groupValue: _selectedOption,
  onChanged: (value) {
    setState(() {
      _selectedOption = value;
    });
  },
)

// 레이블 포함
CustomRadio<String>(
  value: "option1",
  groupValue: _selectedOption,
  label: "옵션 1",
  onChanged: (value) {
    setState(() {
      _selectedOption = value;
    });
  },
)

// 여러 옵션 그룹
Column(
  children: [
    CustomRadio<String>(
      value: "option1",
      groupValue: _selectedOption,
      label: "옵션 1",
      onChanged: (value) {
        setState(() {
          _selectedOption = value;
        });
      },
    ),
    CustomRadio<String>(
      value: "option2",
      groupValue: _selectedOption,
      label: "옵션 2",
      activeColor: Colors.orange,
      onChanged: (value) {
        setState(() {
          _selectedOption = value;
        });
      },
    ),
    CustomRadio<String>(
      value: "option3",
      groupValue: _selectedOption,
      label: "옵션 3",
      activeColor: Colors.teal,
      onChanged: (value) {
        setState(() {
          _selectedOption = value;
        });
      },
    ),
  ],
)
```

---

## CustomSlider

슬라이더 위젯입니다. 연속적인 값이나 범위를 선택할 때 사용합니다.

### 기본 사용법

```dart
CustomSlider(
  value: _sliderValue,
  onChanged: (value) {
    setState(() {
      _sliderValue = value;
    });
  },
)
```

### 주요 속성

| 속성            | 타입                    | 기본값                 | 설명                          |
| --------------- | ----------------------- | ---------------------- | ----------------------------- |
| `value`         | `double`                | 필수                   | Slider의 현재 값              |
| `onChanged`     | `ValueChanged<double>?` | 필수                   | 값 변경 시 호출되는 콜백      |
| `onChangeEnd`   | `ValueChanged<double>?` | `null`                 | 값 변경 완료 시 호출되는 콜백 |
| `onChangeStart` | `ValueChanged<double>?` | `null`                 | 값 변경 시작 시 호출되는 콜백 |
| `min`           | `double?`               | `0.0`                  | Slider의 최소값               |
| `max`           | `double?`               | `1.0`                  | Slider의 최대값               |
| `divisions`     | `int?`                  | `null`                 | 분할 수 (null이면 연속)       |
| `label`         | `String?`               | `null`                 | Slider의 레이블 텍스트        |
| `activeColor`   | `Color?`                | `Colors.blue`          | 활성화 상태의 색상            |
| `inactiveColor` | `Color?`                | `Colors.grey.shade300` | 비활성화 상태의 색상          |
| `thumbColor`    | `Color?`                | `null`                 | 썸(thumb) 색상                |
| `overlayColor`  | `Color?`                | `null`                 | 오버레이 색상                 |
| `title`         | `String?`               | `null`                 | Slider 위에 표시할 제목       |
| `titleStyle`    | `TextStyle?`            | `null`                 | 제목 텍스트 스타일            |
| `showValue`     | `bool`                  | `false`                | 현재 값 표시 여부             |
| `valueStyle`    | `TextStyle?`            | `null`                 | 값 텍스트 스타일              |
| `spacing`       | `double?`               | `8`                    | 제목/값과 Slider 사이의 간격  |
| `visualDensity` | `VisualDensity?`        | `null`                 | 시각적 밀도                   |
| `sliderTheme`   | `SliderThemeData?`      | `null`                 | 커스텀 SliderThemeData        |

### 사용 예시

```dart
// 기본 사용
CustomSlider(
  value: _sliderValue,
  onChanged: (value) {
    setState(() {
      _sliderValue = value;
    });
  },
)

// 범위 지정
CustomSlider(
  value: _sliderValue,
  min: 0,
  max: 100,
  onChanged: (value) {
    setState(() {
      _sliderValue = value;
    });
  },
)

// 제목과 값 표시
CustomSlider(
  value: _sliderValue,
  min: 0,
  max: 100,
  divisions: 10,
  title: "볼륨 조절",
  showValue: true,
  onChanged: (value) {
    setState(() {
      _sliderValue = value;
    });
  },
)

// 진행률 표시
CustomSlider(
  value: _progress,
  min: 0,
  max: 1,
  title: "진행률",
  showValue: true,
  activeColor: Colors.green,
  onChanged: (value) {
    setState(() {
      _progress = value;
    });
  },
)
```

---

## CustomRating

별점 위젯입니다. 사용자가 별을 클릭하여 점수를 선택할 수 있습니다.

### 기본 사용법

```dart
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) {
    setState(() {
      _rating = rating;
    });
  },
)
```

### 주요 속성

| 속성              | 타입                    | 기본값              | 설명                      |
| ----------------- | ----------------------- | ------------------- | ------------------------- |
| `rating`          | `double`                | 필수                | 현재 점수 (0~maxRating)   |
| `onRatingChanged` | `ValueChanged<double>?`  | `null`              | 점수 변경 시 호출되는 콜백 |
| `maxRating`       | `int`                   | `5`                 | 최대 별 개수              |
| `readOnly`        | `bool`                  | `false`             | 읽기 전용 여부            |
| `starSize`        | `double`                | `24.0`              | 별 크기                  |
| `filledColor`     | `Color`                 | `Colors.amber`      | 채워진 별 색상            |
| `unfilledColor`   | `Color`                 | `Colors.grey`       | 비어있는 별 색상          |
| `starSpacing`     | `double`                | `4.0`               | 별 사이 간격              |
| `filledIcon`      | `IconData`              | `Icons.star`        | 채워진 아이콘             |
| `unfilledIcon`    | `IconData`              | `Icons.star_border` | 비어있는 아이콘           |

### 사용 예시

```dart
// 기본 사용
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) {
    setState(() {
      _rating = rating;
    });
  },
)

// 읽기 전용 모드
CustomRating(
  rating: 4.0,
  readOnly: true,
)

// 커스터마이징
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) => setState(() => _rating = rating),
  maxRating: 5,
  starSize: 32.0,
  filledColor: Colors.orange,
  unfilledColor: Colors.grey.shade300,
  starSpacing: 8.0,
)

// 다양한 아이콘 사용
// 하트 아이콘
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) => setState(() => _rating = rating),
  filledIcon: Icons.favorite,
  unfilledIcon: Icons.favorite_border,
  filledColor: Colors.red,
  unfilledColor: Colors.grey.shade300,
)

// 좋아요 아이콘
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) => setState(() => _rating = rating),
  filledIcon: Icons.thumb_up,
  unfilledIcon: Icons.thumb_up_outlined,
  filledColor: Colors.blue,
  unfilledColor: Colors.grey.shade300,
)

// 다이아몬드 아이콘
CustomRating(
  rating: _rating,
  onRatingChanged: (rating) => setState(() => _rating = rating),
  filledIcon: Icons.diamond,
  unfilledIcon: Icons.diamond_outlined,
  filledColor: Colors.cyan,
  unfilledColor: Colors.grey.shade300,
)
```

### TextField와 함께 사용 (리뷰 작성 예제)

```dart
final TextEditingController _commentController = TextEditingController();
double _rating = 0.0;

CustomCard(
  padding: const EdgeInsets.all(16),
  child: CustomColumn(
    spacing: 12,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomText(
        "리뷰 작성",
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      CustomText(
        "별점을 선택해주세요",
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
      CustomRating(
        rating: _rating,
        onRatingChanged: (rating) {
          setState(() {
            _rating = rating;
          });
        },
        starSize: 28.0,
      ),
      if (_rating > 0)
        CustomText(
          "선택된 점수: $_rating / 5",
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.amber.shade700,
        ),
      const SizedBox(height: 8),
      CustomTextField(
        controller: _commentController,
        labelText: "리뷰 내용",
        hintText: "리뷰를 작성해주세요",
        maxLines: 3,
      ),
      if (_rating > 0 && _commentController.text.isNotEmpty)
        CustomButton(
          btnText: "리뷰 제출",
          backgroundColor: Colors.green,
          onCallBack: () {
            print("별점: $_rating, 리뷰: ${_commentController.text}");
          },
        ),
    ],
  ),
)
```

---

## 실전 예제

### CustomTextField 실전 예제

#### Form과 함께 사용

```dart
final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController();
final _emailController = TextEditingController();

Form(
  key: _formKey,
  child: CustomColumn(
    spacing: 16,
    children: [
      CustomTextField(
        controller: _nameController,
        labelText: "이름",
        required: true,
        requiredMessage: "이름을 입력해주세요",
      ),
      CustomTextField(
        controller: _emailController,
        labelText: "이메일",
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "이메일을 입력해주세요";
          }
          if (!value.contains('@')) {
            return "올바른 이메일 형식이 아닙니다";
          }
          return null;
        },
      ),
      CustomButton(
        btnText: "제출",
        onCallBack: () {
          if (_formKey.currentState!.validate()) {
            print("제출 성공");
          }
        },
      ),
    ],
  ),
)
```

#### 키보드 자동 내리기

```dart
GestureDetector(
  onTap: () {
    FocusScope.of(context).unfocus();
  },
  child: Scaffold(
    body: CustomTextField(
      controller: _controller,
      labelText: "입력",
    ),
  ),
)
```
