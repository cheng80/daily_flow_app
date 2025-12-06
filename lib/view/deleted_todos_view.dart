import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../app_custom/custom_filter_radio.dart';
import '../app_custom/app_common_util.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../vm/database_handler.dart';
import '../model/deleted_todo_model.dart';
import '../app_custom/step_mapper_util.dart';

/// 삭제된 Todo 화면
///
/// 삭제 보관함에 있는 일정들을 표시하고, 복구 또는 완전 삭제할 수 있습니다.
class DeletedTodosView extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const DeletedTodosView({super.key, required this.onToggleTheme});

  @override
  State<DeletedTodosView> createState() => _DeletedTodosViewState();
}

class _DeletedTodosViewState extends State<DeletedTodosView> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  // late bool _themeBool;

  /// 데이터베이스 핸들러
  late DatabaseHandler _handler;

  /// 선택된 날짜 필터 (null = 전체, 0 = 오늘, 1 = 7일, 2 = 30일)
  int? _selectedDateFilter;

  /// 정렬 방식 (true: 중요도순, false: 시간순)
  bool _sortByTime = false;

  /// 위젯 초기화
  @override
  void initState() {
    super.initState();
    // _themeBool = false;
    _handler = DatabaseHandler();
    _selectedDateFilter = null; // 기본값: 전체
    _sortByTime = false; // 기본값: 시간순
  }

  /// 위젯 빌드
  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      // 드로워 슬라이드 제스처 비활성화
      drawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        foregroundColor: p.textOnPrimary,
        toolbarHeight: 50,
        title: CustomText(
          "삭제 보관함",
          style: TextStyle(color: p.textOnPrimary, fontSize: 24),
        ),
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: p.textOnPrimary),
        //   onPressed: () {
        //     CustomNavigationUtil.back(context);
        //   },
        // ),
        actions: [
          // Switch(
          //   value: _themeBool,
          //   onChanged: (value) {
          //     setState(() {
          //       _themeBool = value;
          //     });
          //     widget.onToggleTheme();
          //   },
          // ),
        ],
      ),
      body: CustomColumn(
        spacing: 0,
        children: [
          //----------------------------------
          //-- 날짜 필터 라디오
          //----------------------------------
          CustomPadding.all(
            16,
            child: RadioGroup<int?>(
              groupValue: _selectedDateFilter,
              onChanged: (value) {
                setState(() {
                  _selectedDateFilter = value;
                });
              },
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var option in _getDateFilterOptions())
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
                      selectedStep: _selectedDateFilter,
                      onStepSelected: (step) {
                        setState(() {
                          _selectedDateFilter = step;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          //----------------------------------
          //-- 정렬 설정
          //----------------------------------
          CustomColumn(
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
                    value: _sortByTime,
                    onChanged: (value) {
                      setState(() {
                        _sortByTime = value;
                      });
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
          ),

          //----------------------------------
          //-- 삭제된 Todo 리스트
          //----------------------------------
          Expanded(
            child: FutureBuilder<List<DeletedTodo>>(
              future: _loadDeletedTodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: p.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      "오류가 발생했습니다: ${snapshot.error}",
                      style: TextStyle(color: p.textSecondary),
                    ),
                  );
                }

                final deletedTodos = snapshot.data ?? [];

                if (deletedTodos.isEmpty) {
                  return Center(
                    child: CustomText(
                      "삭제된 일정이 없습니다.",
                      style: TextStyle(color: p.textSecondary),
                    ),
                  );
                }

                // 정렬된 데이터 사용
                final sortedData = _sortDeletedTodos(deletedTodos);

                return CustomListView(
                  itemCount: sortedData.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                      startActionPane: _getActionPane(
                        p.dailyFlow.priorityMedium,
                        Icons.restore,
                        '복구',
                        (context) async {
                          await _restoreTodo(sortedData[index]);
                        },
                      ),
                      endActionPane: _getActionPane(
                        p.dailyFlow.priorityVeryHigh,
                        Icons.delete_forever,
                        '완전 삭제',
                        (context) async {
                          await _permanentlyDeleteTodo(sortedData[index]);
                        },
                      ),
                      child: _buildDeletedTodoCard(sortedData[index], p),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------
  //-- Function
  //----------------------------------

  /// 날짜 필터 옵션 리스트 반환
  ///
  /// 전체/오늘/7일/30일 4개의 옵션 정보를 반환합니다.
  List<FilterRadioOption> _getDateFilterOptions() {
    return [
      FilterRadioOption(
        label: "전체",
        step: null,
        getBackgroundColor: (p) => p.chipSelectedBg,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "오늘",
        step: 0,
        getBackgroundColor: (p) => p.primary,
        getTextColor: (p) => p.textOnPrimary,
      ),
      FilterRadioOption(
        label: "7일",
        step: 1,
        getBackgroundColor: (p) => p.accent,
        getTextColor: (p) => p.chipSelectedText,
      ),
      FilterRadioOption(
        label: "30일",
        step: 2,
        getBackgroundColor: (p) => p.dailyFlow.priorityHigh,
        getTextColor: (p) => p.chipSelectedText,
      ),
    ];
  }

  /// 삭제된 Todo 데이터 로드
  ///
  /// 선택된 날짜 필터에 따라 삭제된 Todo 리스트를 조회합니다.
  Future<List<DeletedTodo>> _loadDeletedTodos() async {
    if (_selectedDateFilter == null) {
      // 전체
      return await _handler.queryDeletedData();
    } else if (_selectedDateFilter == 0) {
      // 오늘
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return await _handler.queryDeletedDataByDateRange(startDate, endDate);
    } else if (_selectedDateFilter == 1) {
      // 7일
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      return await _handler.queryDeletedDataByDateRange(startDate, now);
    } else if (_selectedDateFilter == 2) {
      // 30일
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      return await _handler.queryDeletedDataByDateRange(startDate, now);
    }
    return [];
  }

  /// 삭제된 Todo 카드 빌드
  Widget _buildDeletedTodoCard(DeletedTodo deletedTodo, AppColorScheme p) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      padding: EdgeInsets.zero,
      elevation: 4,
      borderRadius: 16,
      color: p.cardBackground,
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          const priorityStripWidth = 60.0;
          const cardMargin = 16.0 * 2; // 좌우 마진
          final contentWidth = screenWidth - priorityStripWidth - cardMargin;

          return IntrinsicHeight(
            child: CustomRow(
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 내용 영역
                SizedBox(
                  width: contentWidth,
                  child: CustomPadding(
                    padding: const EdgeInsets.all(12),
                    child: CustomColumn(
                      spacing: 0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        CustomText(
                          deletedTodo.title,
                          style: TextStyle(
                            color: p.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: deletedTodo.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // 날짜와 시간대
                        CustomRow(
                          spacing: 4,
                          children: [
                            CustomText(
                              deletedTodo.date,
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            if (deletedTodo.time != null) ...[
                              CustomText(
                                "•",
                                style: TextStyle(color: p.textSecondary),
                              ),
                              CustomText(
                                deletedTodo.time!,
                                style: TextStyle(
                                  color: p.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            CustomText(
                              "•",
                              style: TextStyle(color: p.textSecondary),
                            ),
                            CustomText(
                              StepMapperUtil.stepToKorean(deletedTodo.step),
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // 삭제 일시
                        const SizedBox(height: 4),
                        CustomText(
                          '삭제: ${_formatDeletedAt(deletedTodo.deletedAt)}',
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        // 메모가 있는 경우 표시
                        if (deletedTodo.memo != null &&
                            deletedTodo.memo!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          CustomText(
                            '${deletedTodo.isDone ? "완료" : "미완료"} : ${deletedTodo.memo!}',
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // 2. 우선순위 띠 영역
                SizedBox(
                  width: priorityStripWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: getPriorityColor(deletedTodo.priority, p),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 액션 패널 생성
  ActionPane _getActionPane(
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
          borderRadius: BorderRadius.zero,
        ),
      ],
    );
  }

  /// 삭제된 Todo 정렬 함수
  ///
  /// 정렬 방식:
  /// - 중요도순: priority 내림차순, 같으면 time 오름차순
  /// - 시간순: time이 null이면 뒤로, 같으면 priority 내림차순
  List<DeletedTodo> _sortDeletedTodos(List<DeletedTodo> todos) {
    final sorted = List<DeletedTodo>.from(todos);

    if (_sortByTime) {
      // 중요도순 정렬: priority 내림차순, 같으면 time 오름차순
      sorted.sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;

        // priority가 같으면 time 비교
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return 1; // a가 null이면 뒤로
        if (b.time == null) return -1; // b가 null이면 뒤로

        return a.time!.compareTo(b.time!); // time 오름차순
      });
    } else {
      // 시간순 정렬: time이 null이면 뒤로, 같으면 priority 내림차순
      sorted.sort((a, b) {
        if (a.time == null && b.time == null) {
          return b.priority.compareTo(a.priority); // priority 내림차순
        }
        if (a.time == null) return 1; // a가 null이면 뒤로
        if (b.time == null) return -1; // b가 null이면 뒤로

        // time 오름차순 비교
        final timeCompare = a.time!.compareTo(b.time!);
        if (timeCompare != 0) return timeCompare;

        // time이 같으면 priority 내림차순
        return b.priority.compareTo(a.priority);
      });
    }

    return sorted;
  }

  /// 삭제 일시 포맷팅
  String _formatDeletedAt(String deletedAt) {
    try {
      // 'YYYY-MM-DD HH:MM:SS' 형식을 'YYYY년 MM월 DD일 HH:MM' 형식으로 변환
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

  /// Todo 복구
  Future<void> _restoreTodo(DeletedTodo deletedTodo) async {
    try {
      await _handler.restoreData(deletedTodo, context: context);
      if (context.mounted) {
        setState(() {}); // 데이터 갱신
      }
    } catch (e) {
      print("Todo 복구 오류: $e");
      if (context.mounted) {
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
  }

  /// Todo 완전 삭제
  Future<void> _permanentlyDeleteTodo(DeletedTodo deletedTodo) async {
    try {
      await _handler.realDeleteData(deletedTodo, context: context);
      if (context.mounted) {
        setState(() {}); // 데이터 갱신
      }
    } catch (e) {
      print("Todo 완전 삭제 오류: $e");
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "삭제 실패",
          message: "일정 삭제에 실패하였습니다.",
          type: DialogType.single,
          confirmText: "확인",
          barrierDismissible: false,
        );
      }
    }
  }
}
