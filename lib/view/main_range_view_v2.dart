import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../custom/custom.dart';
import '../custom/external_util/slidable/custom_slidable.dart';
import '../theme/app_colors.dart';
import '../app_custom/custom_calendar_range_header_v2.dart';
import '../app_custom/custom_calendar_range_body_v2.dart';
import '../app_custom/app_common_util.dart';
import '../vm/vm_notifier.dart';
import '../vm/view_model/main_range_view_model.dart';
import '../model/todo_model.dart';
import '../custom/util/log/custom_log_util.dart';
import 'create_todo_view.dart';
import 'edit_todo_view.dart';
import 'todo_detail_dialog.dart';
import 'main_drawer.dart';

// 함수 타입 enum
enum FunctionType { update, delete }

//----------------------------------
//-- MainRangeViewV2
//----------------------------------
class MainRangeViewV2 extends ConsumerStatefulWidget {
  const MainRangeViewV2({super.key});

  @override
  ConsumerState<MainRangeViewV2> createState() => _MainRangeViewV2State();
}

class _MainRangeViewV2State extends ConsumerState<MainRangeViewV2> {
  bool _isInitialized = false;
  final _slidableKey = GlobalKey<CustomSlidableListState>();

  //----------------------------------
  //-- Lifecycle & Listener
  //----------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 날짜 제약 조건 로드 및 초기화 (didChangeDependencies에서 처리)
    if (!_isInitialized) {
      _isInitialized = true;
      final constraintsAsync = ref.read(dateConstraintsProvider);
      constraintsAsync.when(
        data: (constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(mainRangeViewModelProvider.notifier)
                .setMinDate(constraints.minDate);
            ref
                .read(mainRangeViewModelProvider.notifier)
                .setMaxDate(constraints.maxDate);
            // 앱 시작 시 무조건 오늘로 설정
            ref.read(mainRangeViewModelProvider.notifier).goToToday();
          });
        },
        loading: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(mainRangeViewModelProvider.notifier).goToToday();
          });
        },
        error: (error, stackTrace) {
          AppLogger.e('[날짜 제약 조건 로드 실패]', tag: 'MainRangeViewV2', error: error);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(mainRangeViewModelProvider.notifier).goToToday();
          });
        },
      );
    }
  }

  // 날짜 제약 조건 변경 감지
  void _listenDateConstraints() {
    ref.listen<AsyncValue<({DateTime? minDate, DateTime? maxDate})>>(
      dateConstraintsProvider,
      (previous, next) {
        if (_isInitialized && previous != null) {
          next.when(
            data: (constraints) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final currentViewModel = ref.read(mainRangeViewModelProvider);
                if (currentViewModel.minDate != constraints.minDate ||
                    currentViewModel.maxDate != constraints.maxDate) {
                  ref
                      .read(mainRangeViewModelProvider.notifier)
                      .setMinDate(constraints.minDate);
                  ref
                      .read(mainRangeViewModelProvider.notifier)
                      .setMaxDate(constraints.maxDate);
                }
              });
            },
            loading: () {},
            error: (error, stackTrace) {
              AppLogger.e(
                '[날짜 제약 조건 로드 실패]',
                tag: 'MainRangeViewV2',
                error: error,
              );
            },
          );
        }
      },
    );
  }

  //----------------------------------
  //-- Build
  //----------------------------------

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // 날짜 제약 조건 변경 감지
    _listenDateConstraints();

    return Scaffold(
      floatingActionButton: _buildFAB(p),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: p.background,
      drawerEnableOpenDragGesture: false,
      appBar: _buildAppBar(p),
      drawer: MainDrawer(
        isMounted: () => mounted,
        slidableKey: _slidableKey,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildCalendarSection(p),
              _buildSortSection(p),
              _buildTodoListSection(p),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar
  CustomAppBar _buildAppBar(AppColorScheme p) {
    return CustomAppBar(
      drawerIconColor: p.textOnPrimary,
      drawerIcon: Icons.menu_rounded,
      foregroundColor: p.textOnPrimary,
      toolbarHeight: 64,
      title: CustomText(
        "DailyFlow",
        style: TextStyle(
          color: p.textOnPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.15,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.calendar_today, color: p.textOnPrimary, size: 20),
          onPressed: () {
            _slidableKey.currentState?.closeAll();
            ref.read(mainRangeViewModelProvider.notifier).goToToday();
          },
          tooltip: '오늘로 이동',
        ),
      ],
    );
  }

  // FAB (일정 추가)
  Widget _buildFAB(AppColorScheme p) {
    return CustomFloatingActionButton(
      onPressed: () async {
        await _slidableKey.currentState?.closeAll();
        if (!context.mounted) return;
        await _navigateToCreateTodo();
      },
      icon: Icons.add,
      backgroundColor: p.primary,
      foregroundColor: Colors.white,
    );
  }

  //----------------------------------
  //-- 캘린더 섹션
  //----------------------------------

  // 캘린더 ExpansionTile
  Widget _buildCalendarSection(AppColorScheme p) {
    return Consumer(
      builder: (context, ref, child) {
        final viewModel = ref.watch(mainRangeViewModelProvider);

        return CustomExpansionTile(
          iconColor: p.priorityVeryHigh,
          collapsedIconColor: p.priorityVeryHigh,
          title: CustomCalendarRangeHeaderV2(
            focusedDay: viewModel.focusedDay,
            onPreviousMonth: () =>
                ref.read(mainRangeViewModelProvider.notifier).onPreviousMonth(),
            onNextMonth: () =>
                ref.read(mainRangeViewModelProvider.notifier).onNextMonth(),
            // onTodayPressed: AppBar actions로 이동
          ),
          initiallyExpanded: viewModel.calendarExpanded,
          onExpansionChanged: (expanded) {
            ref
                .read(mainRangeViewModelProvider.notifier)
                .setCalendarExpanded(expanded);
          },
          tilePadding: EdgeInsets.zero,
          children: [_buildCalendarCard(p)],
        );
      },
    );
  }

  // 캘린더 카드 (캘린더 바디를 감싸는 카드)
  Widget _buildCalendarCard(AppColorScheme p) {
    return CustomCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      elevation: 1,
      borderRadius: 16,
      color: p.cardBackground,
      child: Consumer(
        builder: (context, ref, child) {
          final viewModel = ref.watch(mainRangeViewModelProvider);
          final focused = viewModel.focusedDay;

          // 현재 달 + 이전/다음 달의 yearMonth 계산
          final currentYM = _toYearMonth(focused.year, focused.month);
          final prevDate = DateTime(focused.year, focused.month - 1);
          final nextDate = DateTime(focused.year, focused.month + 1);
          final prevYM = _toYearMonth(prevDate.year, prevDate.month);
          final nextYM = _toYearMonth(nextDate.year, nextDate.month);

          // 3개월 모두 watch하여, 어느 달의 데이터가 도착해도 리빌드
          final currentAsync = ref.watch(calendarEventsProvider(currentYM));
          final prevAsync = ref.watch(calendarEventsProvider(prevYM));
          final nextAsync = ref.watch(calendarEventsProvider(nextYM));

          // 3개월 캐시를 병합
          final mergedCache = <String, List<Todo>>{};
          prevAsync.whenData((cache) => mergedCache.addAll(cache));
          currentAsync.whenData((cache) => mergedCache.addAll(cache));
          nextAsync.whenData((cache) => mergedCache.addAll(cache));

          final keyBase =
              'calendar_${focused.year}_${focused.month}_${focused.day}_${mergedCache.hashCode}';

          return currentAsync.when(
            data: (_) =>
                _buildCalendarBody(viewModel, keyBase, mergedCache),
            loading: () => _buildCalendarBody(viewModel, keyBase, mergedCache.isNotEmpty ? mergedCache : null),
            error: (error, stackTrace) {
              AppLogger.e(
                '[달력 이벤트 로드 실패]',
                tag: 'MainRangeViewV2',
                error: error,
              );
              return _buildCalendarBody(viewModel, keyBase, mergedCache.isNotEmpty ? mergedCache : null);
            },
          );
        },
      ),
    );
  }

  // 달력 바디
  // [eventsCache] - calendarEventsProvider에서 직접 전달받은 캐시 데이터
  Widget _buildCalendarBody(dynamic viewModel, String keyValue, Map<String, List<Todo>>? eventsCache) {
    return CustomCalendarRangeBodyV2(
      key: ValueKey(keyValue),
      calendarHeight: MediaQuery.of(context).size.width * 0.9,
      cellAspectRatio: 1.0,
      selectedDay: viewModel.selectedDay,
      focusedDay: viewModel.focusedDay,
      onDaySelected: (selected, focused) {
        _slidableKey.currentState?.closeAll();
        ref
            .read(mainRangeViewModelProvider.notifier)
            .onDaySelected(selected, focused);
      },
      selectedRange: null,
      rangeStart: null,
      enableRangeSelection: false,
      onRangeSelected: null,
      onPageChanged: (focused) {
        _slidableKey.currentState?.closeAll();
        ref.read(mainRangeViewModelProvider.notifier).onPageChanged(focused);
      },
      eventLoader: (day) {
        // 캐시가 있고, 해당 날짜가 캐시에 포함되어 있으면 직접 사용
        if (eventsCache != null) {
          final dateStr = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          if (eventsCache.containsKey(dateStr)) {
            return eventsCache[dateStr]!;
          }
        }
        // 캐시에 없는 날짜(이전/다음 달 등)는 ViewModel을 통해 조회
        return ref.read(mainRangeViewModelProvider.notifier).eventLoader(day);
      },
      minDate: viewModel.minDate,
      maxDate: viewModel.maxDate,
    );
  }

  /// 'YYYY-MM' 형식의 yearMonth 문자열 생성
  String _toYearMonth(int year, int month) =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  //----------------------------------
  //-- 정렬 섹션
  //----------------------------------

  // 정렬 스위치 (시간순 / 중요도)
  Widget _buildSortSection(AppColorScheme p) {
    return Consumer(
      builder: (context, ref, child) {
        final viewModel = ref.watch(mainRangeViewModelProvider);

        return CustomRow(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              "시간순",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 14,
                letterSpacing: 0.25,
              ),
            ),
            Switch(
              value: viewModel.sortByTime,
              onChanged: (value) {
                _slidableKey.currentState?.closeAll();
                ref
                    .read(mainRangeViewModelProvider.notifier)
                    .setSortByTime(value);
              },
            ),
            CustomText(
              "중요도",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 14,
                letterSpacing: 0.25,
              ),
            ),
          ],
        );
      },
    );
  }

  //----------------------------------
  //-- Todo 리스트 섹션
  //----------------------------------

  // Todo 리스트 (데이터 조회 + 빈 상태 처리)
  Widget _buildTodoListSection(AppColorScheme p) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Consumer(
          builder: (context, ref, child) {
            final viewModel = ref.watch(mainRangeViewModelProvider);
            final queryDate = CustomCommonUtil.formatDate(
              viewModel.selectedDay,
              'yyyy-MM-dd',
            );

            AppLogger.d("Query date: $queryDate", tag: 'MainRangeViewV2');

            final todosAsync = ref.watch(todoByDateProvider(queryDate));

            return todosAsync.when(
              data: (todos) {
                AppLogger.d(
                  todos.isNotEmpty ? "Data length: ${todos.length}" : "No data",
                  tag: 'MainView',
                );
                if (todos.isNotEmpty) {
                  AppLogger.d(
                    "First todo: ${todos.first.title}, date: ${todos.first.date}",
                    tag: 'MainView',
                  );
                }

                final sortedData = todos.isNotEmpty
                    ? ref
                          .read(mainRangeViewModelProvider.notifier)
                          .sortTodos(todos)
                    : <Todo>[];

                return sortedData.isNotEmpty
                    ? _buildSlidableList(sortedData)
                    : Center(
                        child: CustomText(
                          "데이터가 없습니다.",
                          style: TextStyle(color: p.textSecondary),
                        ),
                      );
              },
              loading: () => Center(
                child: CustomText(
                  "로딩 중...",
                  style: TextStyle(color: p.textSecondary),
                ),
              ),
              error: (error, stack) => Center(
                child: CustomText(
                  "에러: $error",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 슬라이더블 리스트
  Widget _buildSlidableList(List<Todo> sortedData) {
    return CustomSlidableList(
      key: _slidableKey,
      child: CustomListView(
        itemCount: sortedData.length,
        itemBuilder: (context, index) {
          if (index < sortedData.length) {
            return _buildSlidableItem(
              context,
              sortedData[index],
              index,
              sortedData,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // 슬라이더블 아이템 (스와이프 액션 + 카드)
  Widget _buildSlidableItem(
    BuildContext context,
    Todo todo,
    int index,
    List<Todo> sortedData,
  ) {
    final p = context.palette;
    final todoId = todo.id;

    if (todoId == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _TodoCard(todo: todo, ref: ref),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomSlidable(
        id: todoId,
        startActionPane: _buildActionPane(
          p.dailyFlow.priorityMedium,
          Icons.edit,
          '수정',
          (context) async {
            await _slidableKey.currentState?.closeAll();
            if (!context.mounted) return;
            await _handleDataChange(
              context,
              FunctionType.update,
              sortedData,
              index,
            );
          },
        ),
        endActionPane: _buildActionPane(
          p.dailyFlow.priorityVeryHigh,
          Icons.delete,
          '삭제',
          (context) async {
            await _slidableKey.currentState?.closeAll();
            if (!context.mounted) return;
            await _handleDataChange(
              context,
              FunctionType.delete,
              sortedData,
              index,
            );
          },
        ),
        child: GestureDetector(
          onTap: () async {
            await _slidableKey.currentState?.closeAll();
            if (!context.mounted) return;
            await _showTodoDetail(context, todo);
          },
          child: _TodoCard(todo: todo, ref: ref),
        ),
      ),
    );
  }

  // 슬라이더블 액션 패널
  ActionPane _buildActionPane(
    Color bgColor,
    IconData icon,
    String label,
    Function(BuildContext)? onPressed,
  ) {
    return ActionPane(
      motion: const BehindMotion(),
      children: [
        SlidableAction(
          onPressed: onPressed,
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          icon: icon,
          label: label,
          borderRadius: BorderRadius.circular(16),
          flex: 1,
        ),
      ],
    );
  }

  //----------------------------------
  //-- Navigation & Data
  //----------------------------------

  // 일정 등록 화면으로 이동
  Future<void> _navigateToCreateTodo() async {
    final viewModel = ref.read(mainRangeViewModelProvider);
    final result = await CustomNavigationUtil.to(
      context,
      CreateTodoView(initialDate: viewModel.selectedDay),
      transitionType: PageTransitionType.fade,
    );

    if (result == true) {
      ref.read(mainRangeViewModelProvider.notifier).reloadData();
    }
  }

  // 데이터 변경 처리 (수정/삭제)
  Future<void> _handleDataChange(
    BuildContext context,
    FunctionType type,
    List<Todo> todos,
    int index,
  ) async {
    final todo = todos[index];
    final viewModel = ref.read(mainRangeViewModelProvider.notifier);

    AppLogger.d("Selected todo id: ${todo.id}", tag: 'MainView');

    if (type == FunctionType.update) {
      final result = await CustomNavigationUtil.to(
        context,
        EditTodoView(todo: todo),
        transitionType: PageTransitionType.fade,
      );
      if (result == true) {
        viewModel.reloadData();
      }
    } else if (type == FunctionType.delete) {
      await CustomDialog.show(
        context,
        title: "일정 삭제",
        message: "일정을 삭제 하시겠습니까?",
        type: DialogType.dual,
        confirmText: "삭제",
        cancelText: "취소",
        onConfirm: () async {
          await viewModel.deleteTodo(todo);
          if (context.mounted) {
            CustomSnackBar.show(
              context,
              message: "일정이 삭제되었습니다.",
              duration: const Duration(seconds: 2),
            );
          }
        },
      );
    }
  }

  // Todo 상세 다이얼로그 표시
  Future<void> _showTodoDetail(BuildContext context, Todo todo) async {
    final result = await TodoDetailDialog.show(context: context, todo: todo);

    if (result == true) {
      if (context.mounted) {
        final editResult = await CustomNavigationUtil.to(
          context,
          EditTodoView(todo: todo),
          transitionType: PageTransitionType.fade,
        );
        if (editResult == true) {
          ref.read(mainRangeViewModelProvider.notifier).reloadData();
        }
      }
    }
  }
}

//----------------------------------
//-- _TodoCard (Todo 카드 위젯)
//----------------------------------

// Todo 카드
//
// 개별 Todo 아이템의 카드 UI를 담당합니다.
// 체크박스, 제목, 메모, 시간/알람 정보, 우선순위 띠로 구성됩니다.
class _TodoCard extends StatelessWidget {
  final Todo todo;
  final WidgetRef ref;

  const _TodoCard({required this.todo, required this.ref});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final priorityColor = getPriorityColor(todo.priority, p);

    return Container(
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: todo.isDone
              ? Colors.teal.withOpacity(0.4)
              : priorityColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildContent(p)),
              _buildPriorityBar(priorityColor),
            ],
          ),
        ),
      ),
    );
  }

  //-- 카드 내부 구성 요소 --

  // 내용 영역 (체크박스 + 텍스트 정보)
  Widget _buildContent(AppColorScheme p) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: CustomRow(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 28,
              height: 28,
              child: CustomCheckbox(
                value: todo.isDone,
                onChanged: (value) => ref
                    .read(mainRangeViewModelProvider.notifier)
                    .toggleTodoDone(todo, value),
              ),
            ),
          ),
          Expanded(
            child: CustomColumn(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleRow(p),
                if (todo.memo != null && todo.memo!.isNotEmpty) _buildMemo(p),
                const SizedBox(height: 4),
                _buildTimeAndAlarm(p),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 제목 + 완료 배지
  Widget _buildTitleRow(AppColorScheme p) {
    return CustomRow(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CustomText(
            todo.title,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
              decoration: todo.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (todo.isDone) _buildDoneBadge(),
      ],
    );
  }

  //-- 배지 & 정보 표시 --

  // 완료 배지
  Widget _buildDoneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomRow(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green),
          CustomText(
            "완료",
            style: TextStyle(
              color: Colors.green,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 메모 영역
  Widget _buildMemo(AppColorScheme p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomText(
        todo.memo!,
        style: TextStyle(
          color: p.textSecondary,
          fontSize: 13,
          letterSpacing: 0.25,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // 시간 + 알람 정보
  Widget _buildTimeAndAlarm(AppColorScheme p) {
    return CustomRow(
      spacing: 12,
      children: [
        CustomRow(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: p.textSecondary),
            CustomText(
              todo.time != null
                  ? CustomCommonUtil.formatTime12Hour(todo.time!)
                  : "종일",
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (todo.hasAlarm && todo.time != null) _buildAlarmBadge(),
      ],
    );
  }

  // 알람 배지
  Widget _buildAlarmBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: CustomRow(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm_rounded, size: 12, color: Colors.orange),
          CustomText(
            "알람",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 우선순위 띠
  Widget _buildPriorityBar(Color priorityColor) {
    return Container(
      width: 60.0,
      decoration: BoxDecoration(
        color: priorityColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }
}
