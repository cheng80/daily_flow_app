# CustomSlidable 사용 가이드

`flutter_slidable`의 그룹핑(한 번에 하나만 열림) + 일괄 닫기 기능을 간단하게 감싼 래퍼 위젯입니다.

## 주요 기능

- 한 번에 하나의 슬라이더블만 열리도록 자동 관리 (`SlidableAutoCloseBehavior`)
- `GlobalKey` 기반 `closeAll()`로 어디서든 일괄 닫기
- **각 Slidable이 자체적으로 컨트롤러를 생성/관리** — 외부 `TickerProvider` 불필요
- 레지스트리 패턴으로 가볍게 추적 — AnimationController를 미리 만들지 않음

## 설계 원칙

`flutter_slidable`의 `Slidable` 위젯은 원래 자체적으로 `SlidableController`를 생성할 수 있습니다.
이 커스텀 위젯은 이 설계를 따르며, 각 `CustomSlidable`이 `SingleTickerProviderStateMixin`으로
자신의 컨트롤러를 직접 생성합니다.

`closeAll()` 기능을 위해 가벼운 레지스트리 패턴을 사용합니다:
- `CustomSlidableList`가 `_SlidableRegistry`를 `InheritedWidget`으로 하위에 제공
- 각 `CustomSlidable`이 mount 시 레지스트리에 등록, dispose 시 해제
- `closeAll()` 호출 시 등록된 컨트롤러만 닫기

## 기본 사용법

### 1. GlobalKey 선언 + CustomSlidableList로 리스트 감싸기

```dart
class _MyState extends ConsumerState<MyWidget> {
  final _slidableKey = GlobalKey<CustomSlidableListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _slidableKey.currentState?.closeAll();
          // 화면 이동 등
        },
      ),
      drawer: MainDrawer(slidableKey: _slidableKey),
      body: CustomSlidableList(
        key: _slidableKey,
        child: CustomListView(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return CustomSlidable(
              id: todo.id!,
              startActionPane: ActionPane(
                motion: BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await _slidableKey.currentState?.closeAll();
                      // 액션 처리
                    },
                    backgroundColor: Colors.blue,
                    icon: Icons.edit,
                    label: '수정',
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      await _slidableKey.currentState?.closeAll();
                      // 액션 처리
                    },
                    backgroundColor: Colors.red,
                    icon: Icons.delete,
                    label: '삭제',
                  ),
                ],
              ),
              child: TodoCard(todo),
            );
          },
        ),
      ),
    );
  }
}
```

### 2. Before / After 비교

```dart
// Before — flutter_slidable 직접 사용 (관리 코드가 많음)
class _MyState extends ConsumerState<MyWidget> with TickerProviderStateMixin {
  final Map<int, SlidableController> _controllers = {};

  void _syncControllers(List<Item> items) { /* ... */ }
  Future<void> _closeAll() async { /* ... */ }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncControllers(items);
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Slidable(
            controller: _controllers[items[index].id]!,
            groupTag: 'my_group',
            // ...
          );
        },
      ),
    );
  }
}

// After — CustomSlidableList 사용 (간결)
class _MyState extends ConsumerState<MyWidget> {
  final _slidableKey = GlobalKey<CustomSlidableListState>();

  @override
  Widget build(BuildContext context) {
    return CustomSlidableList(
      key: _slidableKey,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return CustomSlidable(
            id: items[index].id!,
            // ...
          );
        },
      ),
    );
  }
}
```

## API

### CustomSlidableList

리스트를 감싸는 래퍼 위젯. 레지스트리와 `SlidableAutoCloseBehavior`를 자동 관리합니다.

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `key` | `GlobalKey<CustomSlidableListState>` | O | closeAll 호출을 위한 GlobalKey |
| `child` | `Widget` | O | 리스트 위젯 (ListView, CustomListView 등) |
| `groupTag` | `String?` | X | 그룹 태그 (기본값: `'default_slidable_group'`) |

**closeAll 호출:**

```dart
// GlobalKey를 통해 어디서든 호출 가능
await _slidableKey.currentState?.closeAll();
```

### CustomSlidable

개별 슬라이더블 위젯. `CustomSlidableList` 내부에서 사용하면 자동으로 그룹 태그를 주입받고, 컨트롤러를 자체 생성합니다.

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `id` | `int` | O | 아이템의 고유 ID |
| `child` | `Widget` | O | 슬라이더블의 자식 위젯 |
| `startActionPane` | `ActionPane?` | X | 시작(왼쪽→오른쪽) 액션 패널 |
| `endActionPane` | `ActionPane?` | X | 끝(오른쪽→왼쪽) 액션 패널 |
| `keyValue` | `Key?` | X | 커스텀 키 (기본: `ValueKey<int>(id)`) |

## Import

`custom_slidable.dart`에서 `flutter_slidable`의 주요 클래스(`ActionPane`, `SlidableAction`, `BehindMotion` 등)를 re-export하므로, 별도로 `flutter_slidable`를 import할 필요가 없습니다.

```dart
import 'package:your_app/custom/external_util/slidable/custom_slidable.dart';
// flutter_slidable import 불필요 — ActionPane, SlidableAction 등 자동 포함
```

## 주의사항

1. **ID 필수**: 각 아이템은 고유한 `int` 타입의 ID를 가져야 합니다.
2. **액션 실행 전 닫기**: 액션을 실행하기 전에 `_slidableKey.currentState?.closeAll()`를 호출하여 모든 슬라이더블을 닫는 것을 권장합니다.
3. **GlobalKey 필수**: `CustomSlidableList`에 `GlobalKey<CustomSlidableListState>`를 전달하여 `closeAll()`을 호출합니다. 위젯 트리 위치에 관계없이 동작합니다.
