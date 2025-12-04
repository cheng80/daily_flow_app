# 네비게이션 위젯 클래스

## CustomAppBar

AppBar를 표시하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomAppBar(title: "홈")
```

### 주요 속성

| 속성                        | 타입            | 기본값           | 설명                             |
| --------------------------- | --------------- | ---------------- | -------------------------------- |
| `title`                     | `dynamic`       | 필수             | AppBar 제목 (String 또는 Widget) |
| `backgroundColor`           | `Color?`        | `Colors.blue`    | AppBar 배경색                    |
| `foregroundColor`           | `Color?`        | `Colors.white`   | AppBar 전경색/아이콘 색상        |
| `centerTitle`               | `bool`          | `true`           | 제목 중앙 정렬 여부              |
| `leading`                   | `Widget?`       | `null`           | 왼쪽에 표시할 위젯               |
| `drawerIcon`                | `IconData?`     | `null`           | Drawer 아이콘 (drawer가 있고 leading이 없을 때 사용) |
| `drawerIconColor`           | `Color?`        | `foregroundColor` | Drawer 아이콘 색상 (drawerIcon 사용 시) |
| `drawerIconSize`            | `double?`       | `24.0`           | Drawer 아이콘 크기 (drawerIcon 사용 시) |
| `drawerIconWidget`          | `Widget?`       | `null`           | Drawer 아이콘 위젯 (완전한 커스터마이징, drawerIcon보다 우선) |
| `actions`                   | `List<Widget>?` | `null`           | 오른쪽에 표시할 액션 버튼들      |
| `toolbarHeight`             | `double?`       | `kToolbarHeight` | AppBar 높이                      |
| `titleTextStyle`            | `TextStyle?`    | `null`           | 제목 텍스트 스타일               |
| `automaticallyImplyLeading` | `bool`          | `true`           | 자동으로 뒤로가기 버튼 표시 여부 |

### 사용 예시

```dart
// 기본 사용 (String)
CustomAppBar(title: "홈")

// 색상 지정
CustomAppBar(
  title: "홈",
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
)

// Widget 사용
CustomAppBar(
  title: Row(
    children: [
      Icon(Icons.home),
      SizedBox(width: 8),
      Text("홈"),
    ],
  ),
  backgroundColor: Colors.blue,
)

// 액션 버튼 추가
CustomAppBar(
  title: "홈",
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () {},
    ),
  ],
)

// Drawer 아이콘 커스텀 (IconData만)
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    drawerIcon: Icons.menu_open, // 커스텀 Drawer 아이콘
  ),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
    ],
  ),
  body: Container(),
)

// Drawer 아이콘 색상 및 크기 커스텀
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    drawerIcon: Icons.menu,
    drawerIconColor: Colors.red, // 아이콘 색상 커스텀
    drawerIconSize: 32.0, // 아이콘 크기 커스텀
  ),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
    ],
  ),
  body: Container(),
)

// Drawer 아이콘 완전 커스텀 (Widget 사용)
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    drawerIconWidget: Icon(
      Icons.menu,
      color: Colors.purple,
      size: 28,
    ), // 완전히 커스텀된 위젯 사용
  ),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
    ],
  ),
  body: Container(),
)

// leading과 drawerIcon 함께 사용
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    // leading이 있으면 drawerIcon은 무시됩니다.
    drawerIcon: Icons.menu,
  ),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
    ],
  ),
  body: Container(),
)

// leading에서 Drawer 열기 (Builder 사용 권장)
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    leading: Builder(
      builder: (context) => CustomIconButton(
        icon: Icons.menu,
        onPressed: () {
          Scaffold.maybeOf(context)?.openDrawer();
        },
      ),
    ),
  ),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
    ],
  ),
  body: Container(),
)

// leading에서 Drawer 열기 (간단한 방법, Builder 없이)
// 주의: CustomAppBar의 build context가 Scaffold 하위가 아닐 수 있으므로
// Builder를 사용하는 것이 더 안전합니다.
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    leading: CustomIconButton(
      icon: Icons.menu,
      onPressed: () {
        // Scaffold.maybeOf를 사용하여 null-safe 처리
        Scaffold.maybeOf(context)?.openDrawer();
      },
    ),
  ),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
    ],
  ),
  body: Container(),
)
```

---

## CustomBottomNavBar

하단 네비게이션 바를 표시하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomBottomNavBar(
  items: [
    BottomNavItem(icon: Icons.home, label: "홈", page: HomePage()),
    BottomNavItem(icon: Icons.search, label: "검색", page: SearchPage()),
  ],
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
)
```

### 주요 속성

| 속성                 | 타입                      | 기본값        | 설명                                     |
| -------------------- | ------------------------- | ------------- | ---------------------------------------- |
| `items`              | `List<BottomNavItem>`     | 필수          | 하단 네비게이션 바 아이템 리스트 (2-5개) |
| `currentIndex`       | `int`                     | 필수          | 현재 선택된 인덱스                       |
| `onTap`              | `ValueChanged<int>`       | 필수          | 탭 선택 시 호출되는 콜백                 |
| `selectedColor`      | `Color?`                  | `Colors.blue` | 선택된 아이템 색상                       |
| `unselectedColor`    | `Color?`                  | `Colors.grey` | 선택되지 않은 아이템 색상                |
| `backgroundColor`    | `Color?`                  | `null`        | 배경색                                   |
| `type`               | `BottomNavigationBarType` | `fixed`       | 아이템 타입                              |
| `iconSize`           | `double?`                 | `24`          | 아이콘 크기                              |
| `selectedFontSize`   | `double?`                 | `14`          | 선택된 아이템 폰트 크기                  |
| `unselectedFontSize` | `double?`                 | `12`          | 선택되지 않은 아이템 폰트 크기           |

### BottomNavItem 속성

| 속성              | 타입        | 기본값 | 설명                                                   |
| ----------------- | ----------- | ------ | ------------------------------------------------------ |
| `icon`            | `IconData?` | `null` | 아이콘 (icon과 label 중 하나는 필수)                   |
| `selectedIcon`    | `IconData?` | `null` | 선택된 아이콘                                          |
| `label`           | `dynamic`   | `null` | 라벨 (String 또는 Widget, icon과 label 중 하나는 필수) |
| `page`            | `Widget`    | 필수   | 페이지 위젯                                            |
| `selectedColor`   | `Color?`    | `null` | 이 아이템의 선택된 색상                                |
| `unselectedColor` | `Color?`    | `null` | 이 아이템의 선택되지 않은 색상                         |

### 사용 예시

```dart
// 아이콘 + 텍스트
BottomNavItem(
  icon: Icons.home,
  label: "홈",
  page: HomePage(),
)

// 아이콘만
BottomNavItem(
  icon: Icons.favorite,
  selectedIcon: Icons.favorite,
  page: FavoritePage(),
)

// 텍스트만 (String)
BottomNavItem(
  label: "프로필",
  page: ProfilePage(),
)

// 텍스트만 (Widget) - 개별 색상 지정
BottomNavItem(
  label: CustomText("프로필", fontSize: 14, color: Colors.purple),
  page: ProfilePage(),
  selectedColor: Colors.purple,
  unselectedColor: Colors.grey.shade700,
)

// 전체 사용 예시
CustomBottomNavBar(
  items: [
    BottomNavItem(icon: Icons.home, label: "홈", page: _buildHomePage()),
    BottomNavItem(icon: Icons.search, label: "검색", page: _buildSearchPage()),
    BottomNavItem(icon: Icons.favorite, page: _buildFavoritePage()),
    BottomNavItem(
      label: "프로필",
      page: _buildProfilePage(),
      selectedColor: Colors.purple,
      unselectedColor: Colors.grey.shade700,
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
  selectedColor: Colors.blue,
  unselectedColor: Colors.grey,
)
```

---

## CustomTabBar

상단 또는 하단에 탭바를 표시하는 커스텀 위젯입니다.

### 기본 사용법

```dart
CustomTabBar(
  tabs: ["탭1", "탭2", "탭3"],
  children: [
    Tab1Content(),
    Tab2Content(),
    Tab3Content(),
  ],
)
```

### 주요 속성

| 속성                   | 타입             | 기본값               | 설명                                            |
| ---------------------- | ---------------- | -------------------- | ----------------------------------------------- |
| `tabs`                 | `List<String>`   | 필수                 | 탭 라벨 리스트                                  |
| `children`             | `List<Widget>`   | 필수                 | 각 탭에 해당하는 위젯 리스트 (tabs와 개수 동일) |
| `tabColor`             | `Color?`         | `Colors.blue`        | 탭 색상                                         |
| `unselectedTabColor`   | `Color?`         | `Colors.grey`        | 선택되지 않은 탭 색상                           |
| `indicatorColor`       | `Color?`         | `tabColor`           | 탭 인디케이터 색상                              |
| `indicatorHeight`      | `double?`        | `3`                  | 탭 인디케이터 높이                              |
| `labelStyle`           | `TextStyle?`     | `null`               | 탭 라벨 스타일                                  |
| `unselectedLabelStyle` | `TextStyle?`     | `null`               | 선택되지 않은 탭 라벨 스타일                    |
| `isScrollable`         | `bool`           | `false`              | 탭이 스크롤 가능한지 여부                       |
| `position`             | `TabBarPosition` | `TabBarPosition.top` | 탭 위치 (top, bottom)                           |
| `onTap`                | `ValueChanged<int>?` | `null`            | 탭 클릭 시 콜백 (선택된 탭 인덱스 전달)         |

### TabBarPosition

- `TabBarPosition.top`: 상단에 탭바 표시
- `TabBarPosition.bottom`: 하단에 탭바 표시

### 사용 예시

```dart
// 기본 사용
CustomTabBar(
  tabs: ["동물", "과일", "꽃"],
  children: [
    AnimalTab(),
    FruitTab(),
    FlowerTab(),
  ],
)

// 색상 지정
CustomTabBar(
  tabs: ["탭1", "탭2"],
  tabColor: Colors.purple,
  unselectedTabColor: Colors.grey.shade600,
  indicatorColor: Colors.purple,
  children: [
    Tab1Content(),
    Tab2Content(),
  ],
)

// 하단 탭바
CustomTabBar(
  tabs: ["홈", "검색", "프로필"],
  position: TabBarPosition.bottom,
  children: [
    HomePage(),
    SearchPage(),
    ProfilePage(),
  ],
)

// 스크롤 가능한 탭바
CustomTabBar(
  tabs: ["탭1", "탭2", "탭3", "탭4", "탭5"],
  isScrollable: true,
  children: [
    Tab1Content(),
    Tab2Content(),
    Tab3Content(),
    Tab4Content(),
    Tab5Content(),
  ],
)

// 탭 클릭 이벤트 처리
CustomTabBar(
  tabs: ["동물", "과일", "꽃"],
  tabColor: Colors.blue,
  children: [
    AnimalTab(),
    FruitTab(),
    FlowerTab(),
  ],
  onTap: (index) {
    print("탭 $index 선택됨");
    // 탭 변경 시 필요한 로직 처리
    final tabNames = ["동물", "과일", "꽃"];
    print("${tabNames[index]} 탭 선택됨");
  },
)
```

---

## 실전 예제

### CustomAppBar 실전 예제

#### 액션 버튼 포함

```dart
Scaffold(
  appBar: CustomAppBar(
    title: "홈",
    actions: [
      IconButton(
        icon: Icon(Icons.search),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () {},
      ),
    ],
  ),
  body: Container(),
)
```

#### Widget 사용 - 아이콘 + 텍스트

```dart
Scaffold(
  appBar: CustomAppBar(
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.home, color: Colors.white),
        SizedBox(width: 8),
        Text("홈", style: TextStyle(color: Colors.white)),
      ],
    ),
    backgroundColor: Colors.blue,
  ),
  body: Container(),
)
```

#### Widget 사용 - 복잡한 레이아웃

```dart
Scaffold(
  appBar: CustomAppBar(
    title: Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 16, color: Colors.blue),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("홈", style: TextStyle(color: Colors.white, fontSize: 18)),
            Text("서브타이틀", style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    ),
    backgroundColor: Colors.blue,
  ),
  body: Container(),
)
```

### CustomBottomNavBar 실전 예제

#### 기본 사용

```dart
int _currentIndex = 0;

CustomBottomNavBar(
  items: [
    BottomNavItem(
      icon: Icons.home,
      label: "홈",
      page: HomePage(),
    ),
    BottomNavItem(
      icon: Icons.search,
      label: "검색",
      page: SearchPage(),
    ),
    BottomNavItem(
      icon: Icons.favorite,
      page: FavoritePage(),
    ),
    BottomNavItem(
      label: "프로필",
      page: ProfilePage(),
      selectedColor: Colors.purple,
      unselectedColor: Colors.grey.shade700,
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
)
```

#### 각 페이지가 Scaffold인 경우

```dart
CustomBottomNavBar(
  items: [
    BottomNavItem(
      icon: Icons.home,
      label: "홈",
      page: Scaffold(
        appBar: CustomAppBar(title: "홈"),
        body: HomeContent(),
      ),
    ),
    BottomNavItem(
      icon: Icons.search,
      label: "검색",
      page: Scaffold(
        appBar: CustomAppBar(title: "검색"),
        body: SearchContent(),
      ),
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
)
```

#### Widget 사용 - 텍스트만

```dart
CustomBottomNavBar(
  items: [
    BottomNavItem(
      icon: Icons.home,
      label: "홈",
      page: HomePage(),
    ),
    BottomNavItem(
      label: CustomText(
        "프로필",
        fontSize: 14,
        color: Colors.purple,
      ),
      page: ProfilePage(),
      selectedColor: Colors.purple,
      unselectedColor: Colors.grey.shade700,
    ),
  ],
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
)
```

### CustomTabBar 실전 예제

#### Scaffold와 함께 사용

```dart
Scaffold(
  appBar: CustomAppBar(title: "홈"),
  body: CustomTabBar(
    tabs: ["탭1", "탭2", "탭3"],
    tabColor: Colors.blue,
    children: [
      Tab1Content(),
      Tab2Content(),
      Tab3Content(),
    ],
  ),
)
```

---

## CustomFloatingActionButton

FloatingActionButton을 래핑한 위젯입니다.

### 기본 사용법

```dart
CustomFloatingActionButton(
  onPressed: () {},
  icon: Icons.add,
)
```

### 주요 속성

| 속성              | 타입                        | 기본값 | 설명                                    |
| ----------------- | --------------------------- | ------ | --------------------------------------- |
| `onPressed`       | `VoidCallback?`             | 필수   | 버튼 클릭 시 실행될 콜백                |
| `icon`            | `IconData?`                 | 필수*  | 버튼에 표시할 아이콘 (일반/작은 크기일 때 필수) |
| `label`           | `String?`                   | 필수*  | 버튼에 표시할 라벨 (확장형일 때 필수)   |
| `backgroundColor` | `Color?`                    | `null` | 버튼 배경색                              |
| `foregroundColor` | `Color?`                    | `null` | 버튼 전경색/아이콘 색상                  |
| `tooltip`         | `String?`                   | `null` | 툴팁 메시지                              |
| `type`            | `FloatingActionButtonType`  | -      | 버튼 타입 (생성자에 따라 결정)           |
| `location`        | `FloatingActionButtonLocation?` | `null` | 버튼 위치                                |

### FloatingActionButtonType

- `FloatingActionButtonType.regular`: 일반 크기의 FloatingActionButton
- `FloatingActionButtonType.small`: 작은 크기의 FloatingActionButton
- `FloatingActionButtonType.extended`: 확장형 FloatingActionButton (라벨 포함)

### 사용 예시

```dart
// 기본 사용
CustomFloatingActionButton(
  onPressed: () {
    print("클릭됨");
  },
  icon: Icons.add,
)

// 작은 크기
CustomFloatingActionButton.small(
  onPressed: () {},
  icon: Icons.add,
)

// 확장형
CustomFloatingActionButton.extended(
  onPressed: () {},
  label: "추가",
  icon: Icons.add,
)

// 색상 지정
CustomFloatingActionButton(
  onPressed: () {},
  icon: Icons.add,
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
)

// 툴팁 포함
CustomFloatingActionButton(
  onPressed: () {},
  icon: Icons.add,
  tooltip: "항목 추가",
)
```

---

## CustomDrawer

사이드 드로어 메뉴 위젯입니다.

### 기본 사용법

```dart
Scaffold(
  appBar: CustomAppBar(title: "홈"),
  drawer: CustomDrawer(
    items: [
      DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
      DrawerItem(label: "설정", icon: Icons.settings, onTap: () {}),
    ],
  ),
)
```

### 주요 속성

| 속성              | 타입            | 기본값         | 설명                             |
| ----------------- | --------------- | -------------- | -------------------------------- |
| `header`          | `Widget?`        | `null`         | Drawer 상단에 표시할 헤더 위젯    |
| `items`           | `List<DrawerItem>` | 필수         | Drawer 메뉴 항목 리스트           |
| `backgroundColor`  | `Color?`        | `Colors.white` | Drawer 배경색                    |
| `width`           | `double?`       | `null`         | Drawer 너비                      |
| `footer`          | `Widget?`       | `null`         | Drawer 하단에 표시할 위젯         |

### DrawerItem 속성

| 속성                | 타입            | 기본값         | 설명                                              |
| ------------------- | --------------- | -------------- | ------------------------------------------------- |
| `label`             | `dynamic`       | 필수           | 메뉴 항목의 텍스트 또는 위젯 (String 또는 Widget) |
| `icon`              | `IconData?`     | `null`         | 메뉴 항목의 아이콘                                  |
| `textColor`         | `Color?`        | `Colors.black` | 메뉴 항목의 텍스트 색상                            |
| `onTap`             | `VoidCallback?` | `null`         | 메뉴 항목 클릭 시 실행될 콜백                      |
| `selected`          | `bool`          | `false`        | 이 항목이 선택된 상태인지 여부                     |
| `selectedColor`     | `Color?`        | `null`         | 선택된 상태의 배경색                               |
| `selectedTextColor`  | `Color?`        | `null`         | 선택된 상태의 텍스트 색상                          |

### 사용 예시

```dart
// 기본 사용
CustomDrawer(
  items: [
    DrawerItem(
      label: "홈",
      icon: Icons.home,
      onTap: () {
        print("홈 선택");
      },
    ),
    DrawerItem(
      label: "설정",
      icon: Icons.settings,
      onTap: () {
        print("설정 선택");
      },
    ),
  ],
)

// 헤더 포함
CustomDrawer(
  header: DrawerHeader(
    decoration: BoxDecoration(color: Colors.blue),
    child: Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 40),
        ),
        SizedBox(height: 8),
        Text("사용자 이름", style: TextStyle(color: Colors.white)),
      ],
    ),
  ),
  items: [
    DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
  ],
)

// 선택된 항목
CustomDrawer(
  items: [
    DrawerItem(
      label: "홈",
      icon: Icons.home,
      selected: true,
      selectedColor: Colors.blue.shade50,
      selectedTextColor: Colors.blue,
      onTap: () {},
    ),
    DrawerItem(
      label: "설정",
      icon: Icons.settings,
      onTap: () {},
    ),
  ],
)

// 푸터 포함
CustomDrawer(
  items: [
    DrawerItem(label: "홈", icon: Icons.home, onTap: () {}),
  ],
  footer: Container(
    padding: EdgeInsets.all(16),
    child: Text("버전 1.0.0"),
  ),
)
```

---

## 실전 예제

### CustomFloatingActionButton 실전 예제

#### Scaffold와 함께 사용

```dart
Scaffold(
  appBar: CustomAppBar(title: "홈"),
  body: Container(),
  floatingActionButton: CustomFloatingActionButton(
    onPressed: () {
      print("추가 버튼 클릭");
    },
    icon: Icons.add,
    tooltip: "항목 추가",
  ),
)
```

#### 확장형 FAB

```dart
Scaffold(
  appBar: CustomAppBar(title: "홈"),
  body: Container(),
  floatingActionButton: CustomFloatingActionButton.extended(
    onPressed: () {
      print("추가 버튼 클릭");
    },
    label: "새 항목 추가",
    icon: Icons.add,
  ),
)
```

### CustomDrawer 실전 예제

#### 헤더와 푸터 포함

```dart
Scaffold(
  appBar: CustomAppBar(title: "홈"),
  drawer: CustomDrawer(
    header: DrawerHeader(
      decoration: BoxDecoration(color: Colors.blue),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(
            "사용자 이름",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    ),
    items: [
      DrawerItem(
        label: "홈",
        icon: Icons.home,
        selected: true,
        onTap: () {},
      ),
      DrawerItem(
        label: "설정",
        icon: Icons.settings,
        onTap: () {},
      ),
      DrawerItem(
        label: "도움말",
        icon: Icons.help,
        onTap: () {},
      ),
    ],
    footer: Container(
      padding: EdgeInsets.all(16),
      child: Text(
        "버전 1.0.0",
        style: TextStyle(color: Colors.grey),
      ),
    ),
  ),
  body: Container(),
)
```

#### 선택된 항목 표시

```dart
int _selectedIndex = 0;

Scaffold(
  appBar: CustomAppBar(title: "홈"),
  drawer: CustomDrawer(
    items: [
      DrawerItem(
        label: "홈",
        icon: Icons.home,
        selected: _selectedIndex == 0,
        onTap: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      DrawerItem(
        label: "설정",
        icon: Icons.settings,
        selected: _selectedIndex == 1,
        onTap: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
      ),
    ],
  ),
  body: Container(),
)
```
