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
//-- CreateTodoView
//----------------------------------

// 새 일정 등록 화면
//
// 날짜, 시간, 알람, 제목, 메모, 중요도를 설정하여 새 일정을 등록합니다.
class CreateTodoView extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const CreateTodoView({
    super.key,
    this.initialDate,
  });

  @override
  ConsumerState<CreateTodoView> createState() => _CreateTodoViewState();
}

class _CreateTodoViewState extends ConsumerState<CreateTodoView> {
  late DateTime _selectedDay;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String? _selectedTime;
  bool _hasAlarm = false;
  int _selectedPriority = 3;

  //----------------------------------
  //-- Lifecycle
  //----------------------------------

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate ?? DateTime.now();
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

  // AppBar
  CustomAppBar _buildAppBar(AppColorScheme p) {
    return CustomAppBar(
      foregroundColor: p.textOnPrimary,
      toolbarHeight: 64,
      title: CustomText(
        "새 일정 등록",
        style: TextStyle(
          color: p.textOnPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      actions: [],
    );
  }

  //----------------------------------
  //-- 날짜 및 시간 섹션
  //----------------------------------

  // 날짜 및 시간 선택 카드
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
          if (_selectedTime == null && _hasAlarm)
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
                      color:
                          _selectedTime != null ? p.textPrimary : p.textSecondary,
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
                color: _hasAlarm && _selectedTime != null
                    ? Colors.orange
                    : p.textSecondary,
                size: 20,
              ),
              Switch(
                value: _hasAlarm,
                onChanged: _selectedTime != null
                    ? (value) => setState(() => _hasAlarm = value)
                    : null,
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

  // 제목 및 메모 입력 카드
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

  // 중요도 설정 카드
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

  // 저장 버튼
  Widget _buildSaveButton(AppColorScheme p) {
    return CustomButton(
      btnText: CustomRow(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, size: 22, color: Colors.white),
          CustomText(
            "일정 저장하기",
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
      onCallBack: _handleSave,
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
  //-- Data
  //----------------------------------

  // Todo 저장
  Future<void> _handleSave() async {
    if (!CustomTextField.textCheck(context, _titleController)) {
      CustomSnackBar.show(
        context,
        message: "제목이 비었습니다.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      final todo = Todo.createNew(
        title: _titleController.text.trim(),
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        date: CustomCommonUtil.formatDate(_selectedDay, 'yyyy-MM-dd'),
        time: _selectedTime,
        priority: _selectedPriority,
        hasAlarm: _hasAlarm && _selectedTime != null,
      );

      AppLogger.d("=== Todo 저장 ===", tag: 'CreateTodo');
      AppLogger.d(
        "todo: id=${todo.id}, time=${todo.time}, hasAlarm=${todo.hasAlarm}",
        tag: 'CreateTodo',
      );

      // 알람 시간 검증 (2분 미만이면 저장 중단)
      if (todo.hasAlarm && todo.time != null) {
        final alarmDateTime = parseDateTime(todo.date, todo.time!);
        if (alarmDateTime != null) {
          final duration = alarmDateTime.difference(DateTime.now());
          if (duration.inMinutes < 2) {
            AppLogger.w("[일정 등록] 알람 시간이 2분 미만 - 저장 중단",
                tag: 'CreateTodo');
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
      }

      // DB 저장
      final notifier =
          ref.read(todoNotifierProvider(TodoType.normal).notifier);
      final id = await notifier.insertTodo(todo);
      AppLogger.s("Todo 저장 완료: id=$id", tag: 'CreateTodo');

      // 알람 등록
      if (todo.hasAlarm && todo.time != null) {
        AppLogger.d(
          "[일정 등록] 알람 등록 시작: 제목=${todo.title}, 날짜=${todo.date}, 시간=${todo.time}",
          tag: 'CreateTodo',
        );
        final notificationService = NotificationService();
        final savedTodo = await notifier.queryTodoById(id);
        if (savedTodo != null) {
          final notificationId =
              await notificationService.scheduleNotification(savedTodo);
          if (notificationId != null) {
            final updatedTodo =
                savedTodo.copyWith(notificationId: notificationId);
            await notifier.updateTodo(updatedTodo);
            AppLogger.s(
              "[일정 등록] 알람 등록 완료: notificationId=$notificationId",
              tag: 'CreateTodo',
            );
          } else {
            AppLogger.e("[일정 등록] 알람 등록 실패", tag: 'CreateTodo');
          }
        }
      } else {
        AppLogger.i(
          "[일정 등록] 알람 미설정: hasAlarm=${todo.hasAlarm}, time=${todo.time}",
          tag: 'CreateTodo',
        );
      }

      // 저장 후 DB 확인
      final verifyTodo = await notifier.queryTodoById(id);
      if (verifyTodo != null) {
        AppLogger.d("=== 저장 후 DB 확인 ===", tag: 'CreateTodo');
        AppLogger.d(
          "DB의 Todo: id=${verifyTodo.id}, time=${verifyTodo.time}, hasAlarm=${verifyTodo.hasAlarm}, notificationId=${verifyTodo.notificationId}",
          tag: 'CreateTodo',
        );
      }

      // 저장 성공 다이얼로그
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "저장 완료",
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
      AppLogger.e("Todo 저장 오류", tag: 'CreateTodo', error: e);
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "저장 실패",
          message: "저장에 실패하였습니다.",
          type: DialogType.single,
          confirmText: "확인",
          barrierDismissible: false,
          onConfirm: () => CustomNavigationUtil.back(context),
        );
      }
    }
  }
}
