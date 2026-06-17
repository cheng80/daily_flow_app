import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_custom/custom_calendar_picker.dart';
import '../app_custom/custom_time_picker.dart';
import '../app_custom/app_common_util.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../vm/vm_notifier.dart';
import '../model/todo_model.dart';
import '../service/notification_service.dart';
import '../custom/util/log/custom_log_util.dart';

//----------------------------------
//-- EditTodoView
//----------------------------------

/// 일정 수정 화면
class EditTodoView extends ConsumerStatefulWidget {
  final Todo todo;

  const EditTodoView({
    super.key,
    required this.todo,
  });

  @override
  ConsumerState<EditTodoView> createState() => _EditTodoViewState();
}

class _EditTodoViewState extends ConsumerState<EditTodoView> {
  late DateTime _selectedDay;
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  String? _selectedTime;
  bool _hasAlarm = false;
  int _selectedPriority = 3;
  bool _isDone = false;

  //----------------------------------
  //-- Lifecycle
  //----------------------------------

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _selectedDay = DateTime.parse(todo.date);
    _selectedTime = todo.time;
    _hasAlarm = todo.hasAlarm;
    _selectedPriority = todo.priority;
    _isDone = todo.isDone;
    _titleController = TextEditingController(text: todo.title);
    _memoController = TextEditingController(text: todo.memo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  //----------------------------------
  //-- Build
  //----------------------------------

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      drawerEnableOpenDragGesture: false,
      appBar: _buildAppBar(p),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: p.background,
            child: SingleChildScrollView(
              child: CustomPadding.all(
                20,
                child: CustomColumn(
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isDone) _buildDoneBadge(),
                    _buildDateTimeSection(p),
                    _buildInfoSection(p),
                    _buildPrioritySection(p),
                    const SizedBox(height: 8),
                    _buildSaveButton(p),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------
  //-- AppBar
  //----------------------------------

  CustomAppBar _buildAppBar(AppColorScheme p) {
    return CustomAppBar(
      foregroundColor: p.textOnPrimary,
      toolbarHeight: 64,
      title: CustomText(
        "일정 수정",
        style: TextStyle(
          color: p.textOnPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: InkWell(
            onTap: _handleToggleDone,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isDone
                    ? Colors.green.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomRow(
                spacing: 8,
                children: [
                  Icon(
                    _isDone ? Icons.check_circle : Icons.circle_outlined,
                    color: _isDone ? Colors.green : p.textOnPrimary,
                    size: 20,
                  ),
                  CustomText(
                    "완료",
                    style: TextStyle(
                      color: _isDone ? Colors.green : p.textOnPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 완료 상태 배지
  Widget _buildDoneBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
      ),
      child: CustomRow(
        spacing: 12,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
          Expanded(
            child: CustomText(
              "이 일정은 완료되었습니다",
              style: TextStyle(
                color: Colors.green,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------
  //-- 날짜 및 시간 섹션
  //----------------------------------

  Widget _buildDateTimeSection(AppColorScheme p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomColumn(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(p, Icons.event_rounded, p.primary, "날짜 및 시간"),
          _buildDateSelector(p),
          _buildTimeAndAlarmRow(p),
          if (_isDone)
            _buildWarningBanner("완료된 일정은 알람을 설정할 수 없습니다")
          else if (_selectedTime == null && _hasAlarm)
            _buildWarningBanner("시간을 먼저 선택해주세요"),
        ],
      ),
    );
  }

  // 날짜 선택 버튼
  Widget _buildDateSelector(AppColorScheme p) {
    return InkWell(
      onTap: _showDatePicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.divider, width: 1.5),
        ),
        child: CustomRow(
          spacing: 12,
          children: [
            Icon(Icons.calendar_today_rounded, color: p.primary, size: 24),
            Expanded(
              child: CustomText(
                CustomCommonUtil.formatDate(_selectedDay, 'yyyy년 MM월 dd일'),
                style: TextStyle(
                  color: p.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textSecondary, size: 24),
          ],
        ),
      ),
    );
  }

  // 시간 + 알람 설정 행
  Widget _buildTimeAndAlarmRow(AppColorScheme p) {
    return CustomRow(
      spacing: 12,
      children: [
        Expanded(child: _buildTimeSelector(p)),
        _buildAlarmToggle(p),
      ],
    );
  }

  // 시간 선택
  Widget _buildTimeSelector(AppColorScheme p) {
    return InkWell(
      onTap: _showTimePicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: p.divider, width: 1.5),
        ),
        child: CustomColumn(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              "시간",
              style: TextStyle(color: p.textSecondary, fontSize: 12),
            ),
            CustomRow(
              spacing: 8,
              children: [
                Icon(Icons.access_time_rounded, color: p.accent, size: 20),
                Expanded(
                  child: CustomText(
                    _selectedTime != null
                        ? CustomCommonUtil.formatTime12Hour(_selectedTime!)
                        : "선택 안 함",
                    style: TextStyle(
                      color: _selectedTime != null
                          ? p.textPrimary
                          : p.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 알람 토글
  Widget _buildAlarmToggle(AppColorScheme p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.divider, width: 1.5),
      ),
      child: CustomColumn(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "알람",
            style: TextStyle(color: p.textSecondary, fontSize: 12),
          ),
          CustomRow(
            spacing: 8,
            children: [
              Icon(
                Icons.alarm_rounded,
                color: _hasAlarm && _selectedTime != null && !_isDone
                    ? Colors.orange
                    : p.textSecondary,
                size: 20,
              ),
              Switch(
                value: _hasAlarm,
                onChanged: _isDone
                    ? null
                    : (_selectedTime != null
                        ? (value) => setState(() => _hasAlarm = value)
                        : null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //----------------------------------
  //-- 일정 정보 섹션
  //----------------------------------

  Widget _buildInfoSection(AppColorScheme p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomColumn(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(p, Icons.edit_note_rounded, p.accent, "일정 정보"),
          _buildLabeledField(p, "제목", CustomTextField(
            controller: _titleController,
            hintText: "일정 제목을 입력하세요",
            labelText: null,
            maxLength: 50,
          )),
          _buildLabeledField(p, "메모", CustomTextField(
            controller: _memoController,
            hintText: "상세 메모를 입력하세요 (선택 사항)",
            labelText: null,
            maxLines: 5,
            maxLength: 200,
          )),
        ],
      ),
    );
  }

  //----------------------------------
  //-- 중요도 섹션
  //----------------------------------

  Widget _buildPrioritySection(AppColorScheme p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomColumn(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle(
            p,
            Icons.flag_rounded,
            getPriorityColor(_selectedPriority, p),
            "중요도",
          ),
          _buildPriorityDropdown(p),
        ],
      ),
    );
  }

  // 중요도 드롭다운
  Widget _buildPriorityDropdown(AppColorScheme p) {
    return CustomDropdownButton<int>(
      value: _selectedPriority,
      items: [1, 2, 3, 4, 5],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedPriority = value);
        }
      },
      selectedItemBuilder: (value) {
        if (value == null) {
          return CustomText(
            "중요도 선택",
            style: TextStyle(color: p.textSecondary),
          );
        }
        return _buildPriorityItem(p, value, FontWeight.w600);
      },
      itemBuilder: (item) => _buildPriorityItem(p, item, FontWeight.normal),
      width: double.infinity,
      height: 56,
    );
  }

  //----------------------------------
  //-- 저장 버튼
  //----------------------------------

  Widget _buildSaveButton(AppColorScheme p) {
    return CustomButton(
      btnText: CustomRow(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save_rounded, size: 22, color: Colors.white),
          CustomText(
            "수정 완료",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      buttonType: ButtonType.elevated,
      backgroundColor: p.primary,
      textColor: Colors.white,
      onCallBack: _handleUpdate,
      minimumSize: const Size(double.infinity, 56),
    );
  }

  //----------------------------------
  //-- 공통 UI 헬퍼
  //----------------------------------

  // 섹션 제목
  Widget _buildSectionTitle(
    AppColorScheme p,
    IconData icon,
    Color color,
    String title,
  ) {
    return CustomRow(
      spacing: 8,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        CustomText(
          title,
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // 라벨 + 입력 필드
  Widget _buildLabeledField(AppColorScheme p, String label, Widget field) {
    return CustomColumn(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          style: TextStyle(
            color: p.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        field,
      ],
    );
  }

  // 중요도 아이템 (드롭다운 공통)
  Widget _buildPriorityItem(AppColorScheme p, int value, FontWeight weight) {
    final priorityColor = getPriorityColor(value, p);
    return CustomRow(
      spacing: 10,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        Flexible(
          child: CustomText(
            getPriorityText(value),
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 16,
              fontWeight: weight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 경고 배너
  Widget _buildWarningBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomRow(
        spacing: 8,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
          Expanded(
            child: CustomText(
              message,
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------------
  //-- Dialog & Picker
  //----------------------------------

  // 날짜 선택 다이얼로그
  Future<void> _showDatePicker() async {
    final selectedDate = await CustomCalendarPicker.showDatePicker(
      context: context,
      initialDate: _selectedDay,
    );
    if (selectedDate != null) {
      setState(() => _selectedDay = selectedDate);
    }
  }

  // 시간 선택 다이얼로그
  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await CustomTimePicker.showTimePicker(
      context: context,
      initialTime: _selectedTime != null
          ? TimeOfDay(
              hour: int.parse(_selectedTime!.split(':')[0]),
              minute: int.parse(_selectedTime!.split(':')[1]),
            )
          : TimeOfDay.now(),
      use24HourFormat: false,
    );
    if (picked != null) {
      setState(() => _selectedTime = CustomCommonUtil.formatTime(picked));
    }
  }

  //----------------------------------
  //-- Handler
  //----------------------------------

  // 완료 상태 토글
  Future<void> _handleToggleDone() async {
    if (widget.todo.id != null) {
      setState(() => _isDone = !_isDone);
      final notifier =
          ref.read(todoNotifierProvider(TodoType.normal).notifier);
      await notifier.toggleDone(widget.todo.id!, _isDone);
      if (_isDone && _hasAlarm) {
        setState(() => _hasAlarm = false);
      }
    }
  }

  // Todo 수정
  Future<void> _handleUpdate() async {
    if (!CustomTextField.textCheck(context, _titleController)) {
      CustomSnackBar.show(
        context,
        message: "제목이 비었습니다.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // 완료된 항목은 알람 설정 불가
      if (_isDone && _hasAlarm) {
        CustomSnackBar.show(
          context,
          message: "완료된 일정은 알람을 설정할 수 없습니다.",
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final updatedTodo = widget.todo.copyWith(
        title: _titleController.text.trim(),
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        date: CustomCommonUtil.formatDate(_selectedDay, 'yyyy-MM-dd'),
        time: _selectedTime,
        priority: _selectedPriority,
        isDone: _isDone,
        hasAlarm: _isDone ? false : (_hasAlarm && _selectedTime != null),
        updatedAt: CustomCommonUtil.formatDate(
          DateTime.now(),
          'yyyy-MM-dd HH:mm:ss',
        ),
      );

      AppLogger.d("=== Todo 업데이트 전 ===", tag: 'EditTodo');
      AppLogger.d(
        "기존 Todo: id=${widget.todo.id}, time=${widget.todo.time}, hasAlarm=${widget.todo.hasAlarm}",
        tag: 'EditTodo',
      );
      AppLogger.d("=== 업데이트할 데이터 ===", tag: 'EditTodo');
      AppLogger.d(
        "updatedTodo: id=${updatedTodo.id}, time=${updatedTodo.time}, hasAlarm=${updatedTodo.hasAlarm}",
        tag: 'EditTodo',
      );

      // 알람 업데이트 처리
      AppLogger.d(
        "[일정 수정] 알람 업데이트 시작: 제목=${updatedTodo.title}, 날짜=${updatedTodo.date}, 시간=${updatedTodo.time}, hasAlarm=${updatedTodo.hasAlarm}",
        tag: 'EditTodo',
      );
      final notificationService = NotificationService();

      // 기존 알람 취소
      if (widget.todo.notificationId != null) {
        AppLogger.d(
          "[일정 수정] 기존 알람 취소: notificationId=${widget.todo.notificationId}, 제목=${widget.todo.title}",
          tag: 'EditTodo',
        );
        await notificationService.cancelNotification(
          widget.todo.notificationId!,
        );
        AppLogger.s(
          "[일정 수정] 기존 알람 취소 완료: notificationId=${widget.todo.notificationId}",
          tag: 'EditTodo',
        );
      }

      // 새 알람 등록 또는 비활성화
      int? newNotificationId;
      if (updatedTodo.hasAlarm && updatedTodo.time != null) {
        // 알람 시간 검증
        final alarmDateTime = parseDateTime(updatedTodo.date, updatedTodo.time!);
        if (alarmDateTime != null) {
          final duration = alarmDateTime.difference(DateTime.now());
          if (duration.inMinutes < 2) {
            AppLogger.w("[일정 수정] 알람 시간이 2분 미만 - 수정 중단",
                tag: 'EditTodo');
            if (context.mounted) {
              await CustomDialog.show(
                context,
                title: "알람 등록 불가",
                message: "알람 등록은 현재 시간보다 2분 이후만 가능합니다.",
                type: DialogType.single,
                confirmText: "확인",
                barrierDismissible: false,
              );
            }
            return;
          }
        }

        // 새 알람 등록
        AppLogger.d(
          "[일정 수정] 새 알람 등록 시작: 제목=${updatedTodo.title}, 날짜=${updatedTodo.date}, 시간=${updatedTodo.time}",
          tag: 'EditTodo',
        );
        newNotificationId =
            await notificationService.scheduleNotification(updatedTodo);

        if (newNotificationId == null) {
          AppLogger.e("[일정 수정] 알람 등록 실패 - 수정 중단", tag: 'EditTodo');
          if (context.mounted) {
            await CustomDialog.show(
              context,
              title: "알람 등록 실패",
              message: "알람 등록에 실패했습니다.",
              type: DialogType.single,
              confirmText: "확인",
              barrierDismissible: false,
            );
          }
          return;
        }
        AppLogger.s(
          "[일정 수정] 알람 등록 성공: notificationId=$newNotificationId",
          tag: 'EditTodo',
        );
      } else {
        AppLogger.i(
          "[일정 수정] 알람 비활성화: hasAlarm=${updatedTodo.hasAlarm}, time=${updatedTodo.time}",
          tag: 'EditTodo',
        );
      }

      // DB 업데이트
      final todoToUpdate = newNotificationId != null
          ? updatedTodo.copyWith(notificationId: newNotificationId)
          : (updatedTodo.notificationId != null ||
                    widget.todo.notificationId != null
                ? updatedTodo.copyWith(clearNotificationId: true)
                : updatedTodo);

      final notifier =
          ref.read(todoNotifierProvider(TodoType.normal).notifier);
      await notifier.updateTodo(todoToUpdate);
      AppLogger.s("Todo 수정 완료: id=${updatedTodo.id}", tag: 'EditTodo');

      if (newNotificationId != null) {
        AppLogger.s(
          "[일정 수정] 알람 등록 완료: notificationId=$newNotificationId, 제목=${updatedTodo.title}, 날짜=${updatedTodo.date}, 시간=${updatedTodo.time}",
          tag: 'EditTodo',
        );
      } else if (updatedTodo.notificationId != null ||
          widget.todo.notificationId != null) {
        AppLogger.i(
          "[일정 수정] 알람 비활성화 완료: 제목=${updatedTodo.title}, 기존 notificationId=${widget.todo.notificationId ?? updatedTodo.notificationId}",
          tag: 'EditTodo',
        );
      }

      // 업데이트 후 DB 확인
      if (updatedTodo.id != null) {
        final verifyTodo = await notifier.queryTodoById(updatedTodo.id!);
        if (verifyTodo != null) {
          AppLogger.d("=== 업데이트 후 DB 확인 ===", tag: 'EditTodo');
          AppLogger.d(
            "DB의 Todo: id=${verifyTodo.id}, time=${verifyTodo.time}, hasAlarm=${verifyTodo.hasAlarm}, notificationId=${verifyTodo.notificationId}",
            tag: 'EditTodo',
          );
        }
      }

      // 수정 성공 다이얼로그
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "수정 완료",
          message: "정상적으로 반영되었습니다.",
          type: DialogType.single,
          confirmText: "확인",
          barrierDismissible: false,
        );
        if (context.mounted) {
          CustomNavigationUtil.back(context, result: true);
        }
      }
    } catch (e) {
      AppLogger.e("Todo 수정 오류", tag: 'EditTodo', error: e);
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "수정 실패",
          message: "수정에 실패하였습니다.",
          type: DialogType.single,
          confirmText: "확인",
          barrierDismissible: false,
          onConfirm: () => CustomNavigationUtil.back(context),
        );
      }
    }
  }
}
