import 'package:flutter/material.dart';
import '../app_custom/custom_calendar_picker.dart';
import '../app_custom/custom_time_picker.dart';
import '../app_custom/app_common_util.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../app_custom/step_mapper_util.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';
import '../service/notification_service.dart';
import '../custom/util/log/custom_log_util.dart';

/// 함수 타입 enum
enum FunctionType { update, delete }

class CreateTodoView extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  /// 초기 선택 날짜 (아규먼트로 전달, 없으면 현재 날짜 사용)
  final DateTime? initialDate;

  const CreateTodoView({
    super.key,
    required this.onToggleTheme,
    this.initialDate,
  });

  @override
  State<CreateTodoView> createState() => _CreateTodoViewState();
}

class _CreateTodoViewState extends State<CreateTodoView> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  // late bool _themeBool;

  /// 데이터베이스 핸들러
  late DatabaseHandler _handler;

  /// 선택된 날짜
  late DateTime _selectedDay;

  /// 제목 입력 컨트롤러
  final TextEditingController _titleController = TextEditingController();

  /// 메모 입력 컨트롤러
  final TextEditingController _memoController = TextEditingController();

  /// 선택된 시간 (HH:MM 형식, null이면 시간 없음)
  String? _selectedTime;

  /// 알람 활성 여부
  bool _hasAlarm = false;

  /// 선택된 Step 값 (0=오전, 1=오후, 2=저녁, 3=야간, 4=종일, 기본값: 4=종일)
  int _selectedStep = StepMapperUtil.stepAnytime;

  /// 선택된 중요도 (1~5, 기본값: 3=보통)
  int _selectedPriority = 3;

  /// 위젯 초기화
  ///
  /// 페이지가 새로 생성될 때 한 번 호출됩니다.
  /// 테마 상태를 라이트 모드(false)로 초기화하고, 날짜를 오늘로 설정합니다.
  @override
  void initState() {
    super.initState();
    // _themeBool = false;
    _selectedDay = widget.initialDate ?? DateTime.now();
    _handler = DatabaseHandler();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 위젯 빌드
  ///
  /// 테스트 화면 선택 메뉴를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      // FAB는 body 밖에서 자동으로 고정됨
      backgroundColor: p.background,
      // 드로워 슬라이드 제스처 비활성화
      drawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        foregroundColor: p.textOnPrimary,
        toolbarHeight: 50,
        title: CustomText(
          "일정 등록",
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

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: CustomPadding.all(
            16,
            child: CustomColumn(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //----------------------------------
                //-- 날짜 선택
                //----------------------------------
                CustomText(
                  "날짜 선택",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomButton(
                  btnText: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, color: p.primary, size: 24),
                      const SizedBox(width: 8),
                      CustomText(
                        CustomCommonUtil.formatDate(
                          _selectedDay,
                          'yyyy년 MM월 dd일',
                        ),
                        fontSize: 16,
                        color: p.textPrimary,
                      ),
                    ],
                  ),
                  buttonType: ButtonType.outlined,
                  backgroundColor: p.primary,
                  onCallBack: _showDatePicker,
                  minimumSize: const Size(double.infinity, 48),
                ),

                //----------------------------------
                //-- 시간 설정 & 알람 설정
                //----------------------------------
                CustomRow(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 120,
                        child: CustomCard(
                          padding: const EdgeInsets.all(12),
                          child: CustomColumn(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomText(
                                "시간 설정 (선택 사항)",
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CustomButton(
                                btnText: Row(
                                  spacing: 8,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: p.primary,
                                      size: 24,
                                    ),
                                    Flexible(
                                      child: CustomText(
                                        _selectedTime != null
                                            ? CustomCommonUtil.formatTime12Hour(
                                                _selectedTime!,
                                              )
                                            : "시간 선택",
                                        fontSize: 16,
                                        color: p.textPrimary,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                buttonType: ButtonType.outlined,
                                backgroundColor: p.primary,
                                onCallBack: _showTimePicker,
                                minimumSize: const Size(80, 45),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: SizedBox(
                        height: 120,
                        child: CustomCard(
                          padding: const EdgeInsets.all(8),
                          child: CustomColumn(
                            spacing: 0,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomText(
                                "알람 설정",
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CustomRow(
                                spacing: 6,
                                children: [
                                  Icon(
                                    Icons.alarm_add,
                                    color: _hasAlarm && _selectedTime != null
                                        ? p.primary
                                        : p.textSecondary,
                                    size: 24,
                                  ),
                                  Switch(
                                    value: _hasAlarm,
                                    onChanged: _selectedTime != null
                                        ? (value) {
                                            setState(() {
                                              _hasAlarm = value;
                                            });
                                          }
                                        : null, // 시간이 선택되지 않으면 비활성화
                                  ),
                                ],
                              ),
                              CustomText(
                                "시간 설정 시 사용 가능",
                                style: TextStyle(
                                  color: p.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                //----------------------------------
                //-- 시간대 선택 & 중요도 설정
                //----------------------------------
                CustomText(
                  "시간대 선택 & 중요도 설정",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomRow(
                  spacing: 12,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomColumn(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            "시간대 선택",
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          CustomDropdownButton<int>(
                            value: _selectedStep,
                            items: [
                              StepMapperUtil.stepMorning,
                              StepMapperUtil.stepNoon,
                              StepMapperUtil.stepEvening,
                              StepMapperUtil.stepNight,
                              StepMapperUtil.stepAnytime,
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  // "종일"로 변경하면 무조건 시간 초기화
                                  if (value == StepMapperUtil.stepAnytime) {
                                    _selectedTime = null;
                                    _hasAlarm = false;
                                  } else {
                                    // 현재 선택한 시간의 시간대 확인
                                    int? currentTimeStep;
                                    if (_selectedTime != null) {
                                      currentTimeStep =
                                          StepMapperUtil.mapTimeToStep(
                                            _selectedTime!,
                                          );
                                    }

                                    // 선택한 시간대가 현재 시간의 시간대와 다르면
                                    // 시간 초기화 및 알람 비활성화
                                    if (currentTimeStep != null &&
                                        value != currentTimeStep) {
                                      _selectedTime = null;
                                      _hasAlarm = false;
                                    }
                                  }

                                  _selectedStep = value;
                                });
                              }
                            },
                            selectedItemBuilder: (value) {
                              if (value == null) {
                                return CustomText(
                                  "시간대 선택",
                                  style: TextStyle(color: p.textSecondary),
                                );
                              }
                              return CustomText(
                                "${StepMapperUtil.stepToKorean(value)} (${StepMapperUtil.stepToTimeRange(value)})",
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                            itemBuilder: (item) {
                              return CustomText(
                                "${StepMapperUtil.stepToKorean(item)} (${StepMapperUtil.stepToTimeRange(item)})",
                                style: TextStyle(
                                  color: p.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                            width: double.infinity,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: CustomColumn(
                        spacing: 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            "중요도 설정",
                            style: TextStyle(
                              color: p.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          CustomDropdownButton<int>(
                            value: _selectedPriority,
                            items: [1, 2, 3, 4, 5],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedPriority = value;
                                });
                              }
                            },
                            selectedItemBuilder: (value) {
                              if (value == null) {
                                return CustomText(
                                  "중요도 선택",
                                  style: TextStyle(color: p.textSecondary),
                                );
                              }
                              final priorityColor = getPriorityColor(value, p);
                              return CustomRow(
                                spacing: 6,
                                children: [
                                  CustomContainer(
                                    width: 12,
                                    height: 12,
                                    borderRadius: 6,
                                    backgroundColor: priorityColor,
                                    child: const SizedBox.shrink(),
                                  ),
                                  Flexible(
                                    child: CustomText(
                                      getPriorityText(value),
                                      style: TextStyle(
                                        color: p.textPrimary,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                            itemBuilder: (item) {
                              final priorityColor = getPriorityColor(item, p);
                              return CustomRow(
                                spacing: 6,
                                children: [
                                  CustomContainer(
                                    width: 12,
                                    height: 12,
                                    borderRadius: 6,
                                    backgroundColor: priorityColor,
                                    child: const SizedBox.shrink(),
                                  ),
                                  Flexible(
                                    child: CustomText(
                                      getPriorityText(item),
                                      style: TextStyle(
                                        color: p.textPrimary,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                            width: double.infinity,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                //----------------------------------
                //-- 제목 입력
                //----------------------------------
                CustomText(
                  "제목",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextField(
                  controller: _titleController,
                  hintText: "제목 입력 (최대 50자)",
                  labelText: "제목",
                  maxLength: 50,
                ),

                //----------------------------------
                //-- 메모 입력
                //----------------------------------
                CustomText(
                  "메모",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomTextField(
                  controller: _memoController,
                  hintText: "메모 입력 (최대 200자)",
                  labelText: "메모",
                  maxLines: 5,
                  maxLength: 200,
                ),

                //----------------------------------
                //-- 저장 버튼
                //----------------------------------
                CustomButton(
                  btnText: "저장",
                  buttonType: ButtonType.elevated,
                  backgroundColor: p.primary,
                  onCallBack: _saveTodo,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //----------------------------------
  //-- Function
  //----------------------------------

  /// 날짜 선택 다이얼로그 표시
  Future<void> _showDatePicker() async {
    final selectedDate = await CustomCalendarPicker.showDatePicker(
      context: context,
      initialDate: _selectedDay,
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDay = selectedDate;
      });
    }
  }

  /// 시간 선택 다이얼로그 표시
  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await CustomTimePicker.showTimePicker(
      context: context,
      initialTime: _selectedTime != null
          ? TimeOfDay(
              hour: int.parse(_selectedTime!.split(':')[0]),
              minute: int.parse(_selectedTime!.split(':')[1]),
            )
          : TimeOfDay.now(),
      use24HourFormat: false, // 12시간 형식 (오전/오후)으로 표시
    );

    if (picked != null) {
      setState(() {
        _selectedTime = CustomCommonUtil.formatTime(
          picked,
        ); // TimeOfDay는 항상 24시간 형식으로 저장됨
        // 시간이 선택되면 자동으로 Step 매핑
        _selectedStep = StepMapperUtil.mapTimeToStep(_selectedTime);
        // 알람은 활성화되지만 기본값은 false로 유지
      });
    }
  }

  /// Todo 저장
  Future<void> _saveTodo() async {
    // 제목 필수 입력 검증
    if (!CustomTextField.textCheck(context, _titleController)) {
      CustomSnackBar.show(
        context,
        message: "제목이 비었습니다.",
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      // TODO: 테스트용 강제 실패 로직 (제거 예정)
      // 실패 다이얼로그 테스트를 위해 주석 해제
      // throw Exception("테스트용 강제 실패");

      // "종일"이면 시간을 null로 강제 설정
      String? finalTime = _selectedTime;
      if (_selectedStep == StepMapperUtil.stepAnytime) {
        finalTime = null;
        _hasAlarm = false; // 종일이면 알람도 무조건 false
      } else if (_selectedTime != null) {
        // 시간이 선택된 경우 Step 자동 매핑
        _selectedStep = StepMapperUtil.mapTimeToStep(_selectedTime);
      }

      // Todo 생성 (createNew는 이미 null을 허용하므로 별도 처리 불필요)
      final todo = Todo.createNew(
        title: _titleController.text.trim(),
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        date: CustomCommonUtil.formatDate(_selectedDay, 'yyyy-MM-dd'),
        time: finalTime, // null이면 그대로 null로 전달됨
        step: _selectedStep,
        priority: _selectedPriority,
        hasAlarm: _hasAlarm && finalTime != null,
      );

      // 디버그: 저장할 데이터 확인
      AppLogger.d("=== Todo 저장 ===", tag: 'CreateTodo');
      AppLogger.d(
        "todo: id=${todo.id}, step=${todo.step}, time=${todo.time}, hasAlarm=${todo.hasAlarm}",
        tag: 'CreateTodo',
      );
      AppLogger.d(
        "_selectedStep: $_selectedStep, finalTime: $finalTime",
        tag: 'CreateTodo',
      );

      // 알람 등록 (hasAlarm=true이고 time이 있을 때만)
      // 알람이 설정된 경우, DB 저장 전에 시간 체크
      if (todo.hasAlarm && todo.time != null) {
        // 알람 시간이 현재 시간보다 2분 이후인지 먼저 체크
        final alarmDateTime = parseDateTime(todo.date, todo.time!);
        if (alarmDateTime != null) {
          final now = DateTime.now();
          final duration = alarmDateTime.difference(now);

          if (duration.inMinutes < 2) {
            // 2분 미만이면 다이얼로그 표시하고 저장 중단 (scheduleNotification 호출하지 않음)
            AppLogger.w("[일정 등록] 알람 시간이 2분 미만 - 저장 중단", tag: 'CreateTodo');
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
            return; // 저장 중단 (DB 저장도 안 함, scheduleNotification도 호출 안 함)
          }
        }
      }

      // 데이터베이스에 저장
      final id = await _handler.insertData(todo);
      AppLogger.s("Todo 저장 완료: id=$id", tag: 'CreateTodo');

      // 알람 등록 (hasAlarm=true이고 time이 있을 때만)
      // DB 저장 후 알람 등록
      if (todo.hasAlarm && todo.time != null) {
        AppLogger.d(
          "[일정 등록] 알람 등록 시작: 제목=${todo.title}, 날짜=${todo.date}, 시간=${todo.time}",
          tag: 'CreateTodo',
        );
        final notificationService = NotificationService();

        // 저장된 Todo로 알람 등록
        final savedTodo = await _handler.queryDataById(id);
        if (savedTodo != null) {
          final notificationId = await notificationService.scheduleNotification(
            savedTodo,
          );

          if (notificationId != null) {
            final updatedTodo = savedTodo.copyWith(
              notificationId: notificationId,
            );
            await _handler.updateData(updatedTodo);
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

      // 디버그: 저장 후 데이터 확인
      final verifyTodo = await _handler.queryDataById(id);
      if (verifyTodo != null) {
        AppLogger.d("=== 저장 후 DB 확인 ===", tag: 'CreateTodo');
        AppLogger.d(
          "DB의 Todo: id=${verifyTodo.id}, step=${verifyTodo.step}, time=${verifyTodo.time}, hasAlarm=${verifyTodo.hasAlarm}, notificationId=${verifyTodo.notificationId}",
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
          barrierDismissible: false, // 배경 터치로 닫기 방지
        );
        // 다이얼로그가 닫힌 후 화면도 닫기
        if (context.mounted) {
          CustomNavigationUtil.back(context, result: true); // main_view로 복귀
        }
      }
    } catch (e) {
      AppLogger.e("Todo 저장 오류", tag: 'CreateTodo', error: e);
      // 저장 실패 다이얼로그
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "저장 실패",
          message: "저장에 실패하였습니다.",
          type: DialogType.single,
          confirmText: "확인",
          barrierDismissible: false, // 배경 터치로 닫기 방지
          onConfirm: () {
            CustomNavigationUtil.back(context); // 다이얼로그만 닫기
          },
        );
      }
    }
  }
}
