import 'package:flutter/material.dart';
import '../app_custom/custom_time_picker.dart';
import '../app_custom/app_common_util.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../app_custom/step_mapper_util.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';

/// 일정 수정 화면
///
/// 기존 Todo 데이터를 수정할 수 있는 화면입니다.
/// CreateTodoView와 유사한 구조를 가지며, 기존 데이터를 초기값으로 설정합니다.
class EditTodoView extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  /// 수정할 Todo 객체 (필수)
  final Todo todo;

  const EditTodoView({
    super.key,
    required this.onToggleTheme,
    required this.todo,
  });

  @override
  State<EditTodoView> createState() => _EditTodoViewState();
}

class _EditTodoViewState extends State<EditTodoView> {
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  // late bool _themeBool;

  /// 데이터베이스 핸들러
  late DatabaseHandler _handler;

  /// 선택된 날짜
  late DateTime _selectedDay;

  /// 제목 입력 컨트롤러
  late TextEditingController _titleController;

  /// 메모 입력 컨트롤러
  late TextEditingController _memoController;

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
  /// 기존 Todo 데이터를 초기값으로 설정합니다.
  @override
  void initState() {
    super.initState();
    // _themeBool = false;
    _handler = DatabaseHandler();

    // 기존 Todo 데이터로 초기화
    final todo = widget.todo;
    _selectedDay = DateTime.parse(todo.date);
    _selectedTime = todo.time;
    _hasAlarm = todo.hasAlarm;
    _selectedStep = todo.step;
    _selectedPriority = todo.priority;

    // 컨트롤러 초기화
    _titleController = TextEditingController(text: todo.title);
    _memoController = TextEditingController(text: todo.memo ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 위젯 빌드
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      backgroundColor: p.background,
      // 드로워 슬라이드 제스처 비활성화
      drawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        foregroundColor: p.textOnPrimary,
        toolbarHeight: 50,
        title: CustomText(
          "일정 수정",
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
                //-- 수정 날짜
                //----------------------------------
                CustomText(
                  "수정 날짜",
                  style: TextStyle(
                    color: p.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomText(
                  CustomCommonUtil.formatDate(_selectedDay, 'yyyy년 MM월 dd일'),
                  style: TextStyle(color: p.textPrimary, fontSize: 16),
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
                  btnText: "수정 완료",
                  buttonType: ButtonType.elevated,
                  backgroundColor: p.primary,
                  onCallBack: _updateTodo,
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

  /// Todo 수정
  Future<void> _updateTodo() async {
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
      bool shouldClearTime = false;
      if (_selectedStep == StepMapperUtil.stepAnytime) {
        finalTime = null;
        shouldClearTime = true; // 종일이면 시간을 명시적으로 null로 설정
        _hasAlarm = false; // 종일이면 알람도 무조건 false
      } else if (_selectedTime != null) {
        // 시간이 선택된 경우 Step 자동 매핑
        _selectedStep = StepMapperUtil.mapTimeToStep(_selectedTime);
      }

      // 기존 Todo의 id와 createdAt을 유지하고 나머지 필드만 업데이트
      final updatedTodo = widget.todo.copyWith(
        title: _titleController.text.trim(),
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        date: CustomCommonUtil.formatDate(_selectedDay, 'yyyy-MM-dd'),
        time: finalTime,
        clearTime: shouldClearTime, // 종일일 때 시간을 명시적으로 null로 설정
        step: _selectedStep,
        priority: _selectedPriority,
        hasAlarm: _hasAlarm && finalTime != null,
        updatedAt: CustomCommonUtil.formatDate(
          DateTime.now(),
          'yyyy-MM-dd HH:mm:ss',
        ),
      );

      // 디버그: 업데이트 전 데이터 확인
      print("=== Todo 업데이트 전 ===");
      print(
        "기존 Todo: id=${widget.todo.id}, step=${widget.todo.step}, time=${widget.todo.time}, hasAlarm=${widget.todo.hasAlarm}",
      );
      print("=== 업데이트할 데이터 ===");
      print(
        "updatedTodo: id=${updatedTodo.id}, step=${updatedTodo.step}, time=${updatedTodo.time}, hasAlarm=${updatedTodo.hasAlarm}",
      );
      print("_selectedStep: $_selectedStep, finalTime: $finalTime");

      // 데이터베이스에 업데이트
      final result = await _handler.updateData(updatedTodo);
      print("Todo 수정 완료: id=${updatedTodo.id}, 수정된 레코드 수: $result");

      // 디버그: 업데이트 후 데이터 확인
      if (updatedTodo.id != null) {
        final verifyTodo = await _handler.queryDataById(updatedTodo.id!);
        if (verifyTodo != null) {
          print("=== 업데이트 후 DB 확인 ===");
          print(
            "DB의 Todo: id=${verifyTodo.id}, step=${verifyTodo.step}, time=${verifyTodo.time}, hasAlarm=${verifyTodo.hasAlarm}",
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
          barrierDismissible: false, // 배경 터치로 닫기 방지
        );
        // 다이얼로그가 닫힌 후 화면도 닫기
        if (context.mounted) {
          CustomNavigationUtil.back(context, result: true); // main_view로 복귀
        }
      }
    } catch (e) {
      print("Todo 수정 오류: $e");
      // 수정 실패 다이얼로그
      if (context.mounted) {
        await CustomDialog.show(
          context,
          title: "수정 실패",
          message: "수정에 실패하였습니다.",
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
