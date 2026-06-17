import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_custom/custom_filter_radio.dart';
import '../app_custom/app_common_util.dart';
import '../custom/custom.dart';
import '../custom/external_util/slidable/custom_slidable.dart';
import '../theme/app_colors.dart';
import '../vm/vm_notifier.dart';
import '../vm/view_model/deleted_todos_view_model.dart';
import '../model/deleted_todo_model.dart';
import '../custom/util/log/custom_log_util.dart';

//----------------------------------
//-- DeletedTodosView
//----------------------------------

// 삭제된 Todo 화면
//
// 삭제 보관함에 있는 일정들을 표시하고, 복구 또는 완전 삭제할 수 있습니다.
class DeletedTodosView extends ConsumerStatefulWidget {
  const DeletedTodosView({super.key});

  @override
  ConsumerState<DeletedTodosView> createState() => _DeletedTodosViewState();
}

class _DeletedTodosViewState extends ConsumerState<DeletedTodosView> {
  final _slidableKey = GlobalKey<CustomSlidableListState>();

  //----------------------------------
  //-- Build
  //----------------------------------

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: _buildAppBar(p),
      body: SafeArea(
        top: false,
        child: CustomColumn(
          spacing: 0,
          children: [
            _buildFilterSection(p),
            _buildSortSection(p),
            _buildTodoListSection(p),
          ],
        ),
      ),
    );
  }

  // AppBar
  CustomAppBar _buildAppBar(AppColorScheme p) {
    return CustomAppBar(
      foregroundColor: p.textOnPrimary,
      toolbarHeight: 50,
      title: CustomText(
        "삭제 보관함",
        style: TextStyle(color: p.textOnPrimary, fontSize: 24),
      ),
      actions: [],
    );
  }

  //----------------------------------
  //-- 필터 섹션
  //----------------------------------

  // 날짜 필터 라디오
  Widget _buildFilterSection(AppColorScheme p) {
    return Consumer(
      builder: (context, ref, child) {
        final viewModel = ref.watch(deletedTodosViewModelProvider);

        return CustomPadding.all(
          16,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var option in _getFilterOptions())
                CustomFilterRadio(
                  width: 80,
                  height: 40,
                  fontSize: 16,
                  option: option,
                  padding: EdgeInsets.zero,
                  mainAxisAlignment: MainAxisAlignment.start,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedStep: viewModel.selectedDateFilter,
                  onStepSelected: (step) {
                    _slidableKey.currentState?.closeAll();
                    ref
                        .read(deletedTodosViewModelProvider.notifier)
                        .setDateFilter(step ?? 0);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // 날짜 필터 옵션 리스트
  List<FilterRadioOption> _getFilterOptions() {
    return [
      FilterRadioOption(
        label: "전체",
        step: 0,
        getBackgroundColor: (p) => p.chipSelectedBg,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "오늘",
        step: 1,
        getBackgroundColor: (p) => p.primary,
        getTextColor: (p) => p.textOnPrimary,
      ),
      FilterRadioOption(
        label: "7일",
        step: 2,
        getBackgroundColor: (p) => p.accent,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "30일",
        step: 3,
        getBackgroundColor: (p) => p.dailyFlow.priorityHigh,
        getTextColor: (p) => p.chipSelectedText,
      ),
    ];
  }

  //----------------------------------
  //-- 정렬 섹션
  //----------------------------------

  // 정렬 스위치 (시간순 / 중요도)
  Widget _buildSortSection(AppColorScheme p) {
    return Consumer(
      builder: (context, ref, child) {
        final viewModel = ref.watch(deletedTodosViewModelProvider);

        return CustomColumn(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomRow(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomText(
                  "시간순",
                  style: TextStyle(color: p.textPrimary, fontSize: 14),
                ),
                Switch(
                  value: viewModel.sortByTime,
                  onChanged: (value) {
                    _slidableKey.currentState?.closeAll();
                    ref
                        .read(deletedTodosViewModelProvider.notifier)
                        .setSortByTime(value);
                  },
                ),
                CustomText(
                  "중요도",
                  style: TextStyle(color: p.textPrimary, fontSize: 14),
                ),
                const SizedBox(width: 16),
              ],
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
      child: Consumer(
        builder: (context, ref, child) {
          final viewModel = ref.watch(deletedTodosViewModelProvider);

          // Provider 선택 로직
          AsyncValue<List<DeletedTodo>> deletedTodosAsync;

          if (viewModel.selectedDateFilter == 0) {
            // 전체
            deletedTodosAsync = ref.watch(deletedTodoNotifierProvider);
          } else {
            // 캐시된 날짜 범위 사용
            final startDate = viewModel.cachedStartDate;
            final endDate = viewModel.cachedEndDate;

            if (startDate != null && endDate != null) {
              deletedTodosAsync = ref.watch(
                deletedTodoByDateRangeProvider((
                  startDate: startDate,
                  endDate: endDate,
                )),
              );
            } else {
              deletedTodosAsync = ref.watch(deletedTodoNotifierProvider);
            }
          }

          return deletedTodosAsync.when(
            data: (deletedTodos) {
              if (deletedTodos.isEmpty) {
                return Center(
                  child: CustomText(
                    "삭제된 일정이 없습니다.",
                    style: TextStyle(color: p.textSecondary),
                  ),
                );
              }

              final sortedData = _sortDeletedTodos(
                deletedTodos,
                viewModel.sortByTime,
              );

              return _buildSlidableList(sortedData, p);
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: p.primary),
            ),
            error: (error, stack) => Center(
              child: CustomText(
                "오류가 발생했습니다: $error",
                style: TextStyle(color: p.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }

  // 슬라이더블 리스트
  Widget _buildSlidableList(List<DeletedTodo> sortedData, AppColorScheme p) {
    return CustomSlidableList(
      key: _slidableKey,
      child: CustomListView(
        itemCount: sortedData.length,
        itemBuilder: (context, index) {
          if (index < sortedData.length) {
            return _buildSlidableItem(context, sortedData[index], p);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // 슬라이더블 아이템 (스와이프 액션 + 카드)
  Widget _buildSlidableItem(
    BuildContext context,
    DeletedTodo deletedTodo,
    AppColorScheme p,
  ) {
    final todoId = deletedTodo.id;

    if (todoId == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        child: _DeletedTodoCard(deletedTodo: deletedTodo),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: CustomSlidable(
        id: todoId,
        startActionPane: _buildActionPane(
          p.dailyFlow.priorityMedium,
          Icons.restore,
          '복구',
          (context) async {
            await _slidableKey.currentState?.closeAll();
            if (!context.mounted) return;
            await _handleRestore(context, deletedTodo);
          },
        ),
        endActionPane: _buildActionPane(
          p.dailyFlow.priorityVeryHigh,
          Icons.delete_forever,
          '완전 삭제',
          (context) async {
            await _slidableKey.currentState?.closeAll();
            if (!context.mounted) return;
            await _handlePermanentDelete(context, deletedTodo);
          },
        ),
        child: _DeletedTodoCard(deletedTodo: deletedTodo),
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
      extentRatio: 0.25,
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
  //-- Data
  //----------------------------------

  // Todo 복구
  Future<void> _handleRestore(
    BuildContext context,
    DeletedTodo deletedTodo,
  ) async {
    try {
      final notifier = ref.read(deletedTodoNotifierProvider.notifier);
      await notifier.restoreTodo(deletedTodo);
      CustomSnackBar.show(
        context,
        message: "일정이 복구되었습니다.",
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      AppLogger.e("Todo 복구 오류", tag: 'DeletedTodos', error: e);
      await CustomDialog.show(
        context,
        title: "복구 실패",
        message: "일정 복구에 실패하였습니다.",
        type: DialogType.single,
        confirmText: "확인",
        barrierDismissible: false,
      );
    }
  }

  // Todo 완전 삭제
  Future<void> _handlePermanentDelete(
    BuildContext context,
    DeletedTodo deletedTodo,
  ) async {
    await CustomDialog.show(
      context,
      title: "완전 삭제",
      message: "일정을 완전히 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.",
      type: DialogType.dual,
      confirmText: "삭제",
      cancelText: "취소",
      onConfirm: () async {
        try {
          final notifier = ref.read(deletedTodoNotifierProvider.notifier);
          await notifier.permanentlyDeleteTodo(deletedTodo);
          CustomSnackBar.show(
            context,
            message: "일정이 완전히 삭제되었습니다.",
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          AppLogger.e("Todo 완전 삭제 오류", tag: 'DeletedTodos', error: e);
          await CustomDialog.show(
            context,
            title: "삭제 실패",
            message: "일정 삭제에 실패하였습니다.",
            type: DialogType.single,
            confirmText: "확인",
            barrierDismissible: false,
          );
        }
      },
    );
  }

  //----------------------------------
  //-- 유틸리티
  //----------------------------------

  // 삭제된 Todo 정렬
  //
  // - 중요도순: priority 내림차순, 같으면 time 오름차순
  // - 시간순: time이 null이면 뒤로, 같으면 priority 내림차순
  List<DeletedTodo> _sortDeletedTodos(
    List<DeletedTodo> todos,
    bool sortByTime,
  ) {
    final sorted = List<DeletedTodo>.from(todos);

    if (sortByTime) {
      sorted.sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;

        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1;
        if (b.time == null) return -1;

        return a.time!.compareTo(b.time!);
      });
    } else {
      sorted.sort((a, b) {
        if (a.time == null && b.time == null) {
          return b.priority.compareTo(a.priority);
        }
        if (a.time == null) return 1;
        if (b.time == null) return -1;

        final timeCompare = a.time!.compareTo(b.time!);
        if (timeCompare != 0) return timeCompare;

        return b.priority.compareTo(a.priority);
      });
    }

    return sorted;
  }

}

//----------------------------------
//-- _DeletedTodoCard (삭제된 Todo 카드 위젯)
//----------------------------------

// 삭제된 Todo 카드
//
// 개별 삭제된 Todo 아이템의 카드 UI를 담당합니다.
// 제목, 날짜/시간 정보, 삭제 일시, 메모, 우선순위 띠로 구성됩니다.
class _DeletedTodoCard extends StatelessWidget {
  final DeletedTodo deletedTodo;

  const _DeletedTodoCard({required this.deletedTodo});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final priorityColor = getPriorityColor(deletedTodo.priority, p);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: p.textSecondary.withOpacity(0.2), width: 1.5),
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

  // 내용 영역
  Widget _buildContent(AppColorScheme p) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: CustomColumn(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(p),
          _buildDateTimeInfo(p),
          if (deletedTodo.memo != null && deletedTodo.memo!.isNotEmpty)
            _buildMemo(p),
        ],
      ),
    );
  }

  // 제목 + 완료 배지
  Widget _buildTitleRow(AppColorScheme p) {
    return CustomRow(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomText(
            deletedTodo.title,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              decoration:
                  deletedTodo.isDone ? TextDecoration.lineThrough : null,
              decorationThickness: 2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (deletedTodo.isDone) _buildDoneBadge(),
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

  // 날짜/시간 + 삭제 일시 정보
  Widget _buildDateTimeInfo(AppColorScheme p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomColumn(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateAndTime(p),
          _buildDeletedAtBadge(),
        ],
      ),
    );
  }

  // 날짜 + 시간
  Widget _buildDateAndTime(AppColorScheme p) {
    return CustomRow(
      spacing: 12,
      children: [
        CustomRow(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: p.textSecondary),
            CustomText(
              deletedTodo.date,
              style: TextStyle(
                color: p.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (deletedTodo.time != null)
          CustomRow(
            spacing: 6,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: p.textSecondary),
              CustomText(
                deletedTodo.time!,
                style: TextStyle(
                  color: p.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // 삭제 일시 배지
  Widget _buildDeletedAtBadge() {
    // 삭제 일시 포맷팅 (인라인)
    String formatDeletedAt(String deletedAt) {
      try {
        final parts = deletedAt.split(' ');
        if (parts.length >= 2) {
          final datePart = parts[0].split('-');
          final timePart = parts[1].split(':');
          if (datePart.length == 3 && timePart.length >= 2) {
            return '${datePart[0]}년 ${int.parse(datePart[1])}월 ${int.parse(datePart[2])}일 ${timePart[0]}:${timePart[1]}';
          }
        }
        return deletedAt;
      } catch (e) {
        return deletedAt;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomRow(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
          CustomText(
            '삭제됨: ${formatDeletedAt(deletedTodo.deletedAt)}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomColumn(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "메모",
            style: TextStyle(
              color: p.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          CustomText(
            deletedTodo.memo!,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
