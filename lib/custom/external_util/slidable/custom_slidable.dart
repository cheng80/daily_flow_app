import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// flutter_slidable 주요 클래스 re-export
// 사용처에서 flutter_slidable를 별도로 import할 필요 없이
// custom_slidable.dart만 import하면 됩니다.
export 'package:flutter_slidable/flutter_slidable.dart'
    show ActionPane, SlidableAction, BehindMotion, DrawerMotion, ScrollMotion, StretchMotion;

// 슬라이더블 컨트롤러 레지스트리
//
// 각 Slidable이 자체 생성한 SlidableController를 등록/해제하는 가벼운 레지스트리입니다.
// CustomSlidableList가 InheritedWidget으로 이 레지스트리를 하위에 제공하고,
// closeAll() 호출 시 등록된 모든 컨트롤러를 닫습니다.
class _SlidableRegistry {
  final String groupTag;
  final Set<SlidableController> _controllers = {};

  _SlidableRegistry({String? groupTag})
      : groupTag = groupTag ?? 'default_slidable_group';

  // 컨트롤러 등록
  void register(SlidableController controller) {
    _controllers.add(controller);
  }

  // 컨트롤러 해제
  void unregister(SlidableController controller) {
    _controllers.remove(controller);
  }

  // 모든 슬라이더블 닫기
  Future<void> closeAll() async {
    await Future.wait(
      _controllers
          .where((c) => !c.closing)
          .map((c) => c.close(duration: const Duration(milliseconds: 200))),
    );
  }
}

// 커스텀 슬라이더블 위젯
//
// flutter_slidable의 Slidable을 감싸서, 그룹 태그를
// InheritedWidget을 통해 자동으로 주입받고,
// SlidableController를 내부에서 자체 생성/관리하는 위젯입니다.
//
// 중요: 각 Slidable이 자신의 SlidableController를 직접 생성하므로
// 상위에서 AnimationController를 미리 만들 필요가 없습니다.
//
// 사용 예시:
// ```dart
// CustomSlidable(
//   id: todo.id!,
//   startActionPane: ActionPane(
//     motion: BehindMotion(),
//     children: [
//       SlidableAction(
//         onPressed: (context) async {
//           await _slidableKey.currentState?.closeAll();
//           // 액션 처리
//         },
//         backgroundColor: Colors.blue,
//         icon: Icons.edit,
//         label: '수정',
//       ),
//     ],
//   ),
//   child: TodoCard(todo),
// )
// ```
class CustomSlidable extends StatefulWidget {
  // 아이템의 고유 ID (필수)
  final int id;

  // 시작 액션 패널
  final ActionPane? startActionPane;

  // 끝 액션 패널
  final ActionPane? endActionPane;

  // 슬라이더블의 자식 위젯 (필수)
  final Widget child;

  // 슬라이더블 키
  final Key? keyValue;

  const CustomSlidable({
    super.key,
    required this.id,
    this.startActionPane,
    this.endActionPane,
    required this.child,
    this.keyValue,
  });

  @override
  State<CustomSlidable> createState() => _CustomSlidableState();
}

class _CustomSlidableState extends State<CustomSlidable>
    with SingleTickerProviderStateMixin {
  late SlidableController _controller;
  _SlidableRegistry? _registry;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 이전 레지스트리에서 해제 후 새 레지스트리에 등록
    final newRegistry = _SlidableRegistryProvider.of(context);
    if (newRegistry != _registry) {
      _registry?.unregister(_controller);
      _registry = newRegistry;
      _registry?.register(_controller);
    }
  }

  @override
  void dispose() {
    _registry?.unregister(_controller);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = _SlidableRegistryProvider.of(context);

    if (registry == null) {
      return widget.child;
    }

    return Slidable(
      key: widget.keyValue ?? ValueKey<int>(widget.id),
      controller: _controller,
      groupTag: registry.groupTag,
      startActionPane: widget.startActionPane,
      endActionPane: widget.endActionPane,
      child: widget.child,
    );
  }
}

// 커스텀 슬라이더블 리스트 래퍼
//
// 슬라이더블 그룹(한 번에 하나만 열림, 일괄 닫기)을 자동 관리하는 래퍼 위젯입니다.
// SlidableAutoCloseBehavior + 레지스트리만 담당하고,
// 리스트 빌딩은 사용자에게 맡깁니다.
//
// closeAll 호출:
//   GlobalKey<CustomSlidableListState>를 통해 어디서든 호출 가능합니다.
//   _slidableKey.currentState?.closeAll()
//
// 사용 예시:
// ```dart
// final _slidableKey = GlobalKey<CustomSlidableListState>();
//
// Scaffold(
//   floatingActionButton: FloatingActionButton(
//     onPressed: () async {
//       await _slidableKey.currentState?.closeAll();
//       // 화면 이동 등
//     },
//   ),
//   body: CustomSlidableList(
//     key: _slidableKey,
//     child: ListView.builder(...),
//   ),
// )
// ```
class CustomSlidableList extends StatefulWidget {
  // 리스트 위젯 (ListView, CustomListView 등)
  final Widget child;

  // 그룹 태그 (기본값: 'default_slidable_group')
  final String? groupTag;

  const CustomSlidableList({
    super.key,
    required this.child,
    this.groupTag,
  });

  @override
  CustomSlidableListState createState() => CustomSlidableListState();
}

class CustomSlidableListState extends State<CustomSlidableList> {
  late _SlidableRegistry _registry;

  @override
  void initState() {
    super.initState();
    _registry = _SlidableRegistry(groupTag: widget.groupTag);
  }

  @override
  void dispose() {
    // 레지스트리만 비우면 됨 (컨트롤러는 각 CustomSlidable이 dispose)
    _registry._controllers.clear();
    super.dispose();
  }

  // 모든 슬라이더블 닫기
  //
  // GlobalKey<CustomSlidableListState>를 통해 호출합니다.
  // _slidableKey.currentState?.closeAll()
  Future<void> closeAll() async {
    await _registry.closeAll();
  }

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: _SlidableRegistryProvider(
        registry: _registry,
        child: widget.child,
      ),
    );
  }
}

// _SlidableRegistry를 하위 위젯에 제공하는 InheritedWidget
class _SlidableRegistryProvider extends InheritedWidget {
  final _SlidableRegistry registry;

  const _SlidableRegistryProvider({
    required this.registry,
    required super.child,
  });

  static _SlidableRegistry? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_SlidableRegistryProvider>()
        ?.registry;
  }

  @override
  bool updateShouldNotify(_SlidableRegistryProvider oldWidget) {
    return registry != oldWidget.registry;
  }
}
