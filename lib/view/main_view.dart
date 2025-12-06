import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../app_custom/custom_filter_radio.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../app_custom/custom_calendar.dart';
import '../util/common_util.dart';
import '../util/step_mapper_util.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';

/// 함수 타입 enum
enum FunctionType { update, delete }

class MainView extends StatefulWidget {
  /// 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const MainView({super.key, required this.onToggleTheme});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// 테마 상태를 라이트 모드(false)로 초기화합니다.
  /// 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  /// 데이터베이스 핸들러
  late DatabaseHandler _handler;

  /// 선택된 날짜
  late DateTime _selectedDay;

  /// 포커스된 날짜 (현재 보이는 달의 날짜)
  late DateTime _focusedDay;

  /// 선택된 Step 값 (null = 전체, 0=오전, 1=오후, 2=저녁, 3=종일)
  int? _selectedStep;

  /// 날짜별 Todo 데이터 캐시 (달력 이벤트 표시용)
  /// 키: 'YYYY-MM-DD' 형식의 날짜 문자열
  /// 값: 해당 날짜의 Todo 리스트
  Map<String, List<Todo>> _todoCache = {};

  /// 오전 비율 (0.0 ~ 1.0) - 선택된 날짜 기준으로 계산
  double _morningRatio = 0.0;

  /// 오후 비율 (0.0 ~ 1.0) - 선택된 날짜 기준으로 계산
  double _noonRatio = 0.0;

  /// 저녁 비율 (0.0 ~ 1.0) - 선택된 날짜 기준으로 계산
  double _eveningRatio = 0.0;

  /// 종일 비율 (0.0 ~ 1.0) - 선택된 날짜 기준으로 계산
  double _anytimeRatio = 0.0;

  /// 바 너비 (픽셀)
  final double _barWidth = 300.0;

  /// 바 높이 (픽셀)
  final double _barHeight = 20.0;

  /// 위젯 초기화
  ///
  /// 페이지가 새로 생성될 때 한 번 호출됩니다.
  /// 테마 상태를 라이트 모드(false)로 초기화하고, 날짜를 오늘로 설정합니다.
  @override
  void initState() {
    super.initState();
    _themeBool = false;
    final now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
    _selectedStep = null;
    _handler = DatabaseHandler();
    _todoCache = {};
    // 초기 데이터 로드
    _loadCalendarEvents();
    // 초기 Summary Bar 비율 계산
    _calculateSummaryRatios();
  }

  /// 달력 이벤트 데이터 로드 (현재 보이는 달의 데이터)
  Future<void> _loadCalendarEvents() async {
    // 현재 포커스된 달의 시작일과 종료일 계산
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // 해당 달의 모든 날짜에 대해 데이터 조회
    final newCache = <String, List<Todo>>{};
    for (
      var day = firstDay;
      day.isBefore(lastDay.add(const Duration(days: 1)));
      day = day.add(const Duration(days: 1))
    ) {
      final dateStr = _formatDate(day);
      try {
        final todos = await _handler.queryDataByDate(dateStr);
        newCache[dateStr] = todos;
      } catch (e) {
        print("Error loading events for $dateStr: $e");
        newCache[dateStr] = [];
      }
    }

    setState(() {
      _todoCache = newCache;
    });
  }

  /// 위젯 빌드
  ///
  /// 테스트 화면 선택 메뉴를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      // FAB는 body 밖에서 자동으로 고정됨
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {},
        icon: Icons.add,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 위치 지정
      backgroundColor: p.background,
      appBar: CustomAppBar(
        //
        title: CustomText(
          _selectedDay.toString().split(' ')[0],
          style: TextStyle(color: p.textPrimary, fontSize: 16),
        ),
        actions: [
          Switch(
            value: _themeBool,
            onChanged: (value) {
              setState(() {
                _themeBool = value;
              });
              widget.onToggleTheme();
            },
          ),
          CustomIconButton(
            icon: Icons.calendar_today_rounded,
            onPressed: () {
              _goToToday();
            },
          ),
        ],
      ),

      /*------------------ Drawer ---------------------*/
      drawer: CustomDrawer(
        header: DrawerHeader(
          decoration: BoxDecoration(color: p.cardBackground),
          // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: CustomColumn(
            width: double.infinity,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              CustomText("테마 변경"),
              CustomSwitch(
                value: _themeBool,
                onChanged: (value) {
                  setState(() {
                    _themeBool = value;
                  });
                  widget.onToggleTheme();
                },
              ),

              //-----------
            ],
          ),
        ),
        items: [],
        middleChildren: [
          Container(
            padding: const EdgeInsets.all(16),
            child: CustomColumn(
              children: [
                CustomButton(
                  btnText: "Home",
                  onCallBack: () {
                    CustomNavigationUtil.back(context);
                    CustomNavigationUtil.back(context);
                  },
                ),
              ],
            ),
          ),
        ],
        footer: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          padding: const EdgeInsets.all(16),
          child: CustomColumn(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [CustomText("DailyFlow v1.0.0")],
          ),
        ),
      ),

      /*-----------------------------------------------*/
      body: Center(
        child: CustomColumn(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            //----------------------------------
            //-- Calendar
            //----------------------------------
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              // height: 420,
              child: CustomCalendar(
                selectedDay: _selectedDay,
                focusedDay: _focusedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  final previousMonth = _focusedDay.month;
                  final previousYear = _focusedDay.year;

                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  // 월이 변경된 경우 이벤트 데이터 다시 로드
                  if (previousMonth != focusedDay.month ||
                      previousYear != focusedDay.year) {
                    _loadCalendarEvents();
                  }

                  // 날짜 선택 시 Summary Bar 비율 재계산
                  _calculateSummaryRatios();

                  print('선택된 날짜: ${_selectedDay.toString().split(' ')[0]}');
                },
                eventLoader: (day) {
                  // 날짜를 'YYYY-MM-DD' 형식으로 변환
                  final dateStr = _formatDate(day);
                  // 캐시에서 해당 날짜의 Todo 리스트 반환
                  return _todoCache[dateStr] ?? [];
                },
              ),
            ),
            //----------------------------------
            //-- Summary Bar
            //----------------------------------
            CustomContainer(
              width: _barWidth,
              height: _barHeight,
              child: actionFourRangeBar(
                context,
                barWidth: _barWidth,
                barHeight: _barHeight,
                morningRatio: _morningRatio,
                noonRatio: _noonRatio,
                eveningRatio: _eveningRatio,
                anytimeRatio: _anytimeRatio,
              ),
            ),
            //----------------------------------
            //-- Filter Radio
            //----------------------------------
            RadioGroup<int?>(
              groupValue: _selectedStep,
              onChanged: (value) {
                setState(() {
                  _selectedStep = value;
                });
              },
              child: Transform.scale(
                scale: 0.95,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (var option in FilterRadioUtil.getDefaultOptions())
                      _filterRadioCreate(70, 40, 12, option),
                  ],
                ),
              ),
            ),
            //----------------------------------

            //----------------------------------
            //-- FutureBuilder 삽입위치 ----------
            Expanded(
              child: CustomPadding.all(
                16,
                child: FutureBuilder<List<Todo>>(
                  future: _selectedStep == null
                      ? _handler.queryDataByDate(_formatDate(_selectedDay))
                      : _handler.queryDataByDateAndStep(
                          _formatDate(_selectedDay),
                          _selectedStep!,
                        ),
                  builder: (context, snapshot) {
                    final queryDate = _formatDate(_selectedDay);
                    print(
                      "Query date: $queryDate, Selected step: $_selectedStep",
                    );
                    print(
                      snapshot.hasData && snapshot.data!.isNotEmpty
                          ? "Data length: ${snapshot.data!.length}"
                          : "No data",
                    );
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      print(
                        "First todo: ${snapshot.data!.first.title}, date: ${snapshot.data!.first.date}",
                      );
                    }

                    return snapshot.hasData && snapshot.data!.isNotEmpty
                        ? CustomListView(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                startActionPane: _getActionPlane(
                                  p.dailyFlow.priorityMedium,
                                  Icons.edit,
                                  '수정',
                                  (context) async {
                                    await _dataChangeFn(
                                      FunctionType.update,
                                      snapshot,
                                      index,
                                    );
                                  },
                                ),
                                endActionPane: _getActionPlane(
                                  p.dailyFlow.priorityVeryHigh,
                                  Icons.delete,
                                  '삭제',
                                  (context) async {
                                    await _dataChangeFn(
                                      FunctionType.delete,
                                      snapshot,
                                      index,
                                    );
                                  },
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // TODO: 상세 페이지로 이동
                                    // _gotoDetail(snapshot, index);
                                  },
                                  child: _buildTodoCard(snapshot, index, p),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: CustomText(
                              "데이터가 없습니다.",
                              style: TextStyle(color: p.textSecondary),
                            ),
                          );
                  },
                ),
              ),
            ),
            //----------------------------------
          ],
        ),
      ),
    );
  }

  //----------------------------------
  //-- Function
  //----------------------------------

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now;
      _focusedDay = now;
    });
  }

  //-----------------
  //--Function
  //-----------------

  // CustomFilterRadio 위젯 생성
  Widget _filterRadioCreate(
    double width,
    double height,
    double fontSize,
    FilterRadioOption option,
  ) {
    return CustomFilterRadio(
      width: width,
      height: height,
      option: option,
      padding: EdgeInsets.zero, // 패딩 제거
      mainAxisAlignment: MainAxisAlignment.start,
      labelStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      selectedStep: _selectedStep,
      onStepSelected: (step) {
        setState(() {
          _selectedStep = step;
        });
      },
    );
  }

  /// 날짜를 'YYYY-MM-DD' 형식으로 변환
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// 선택된 날짜의 일정을 Step별로 비율 계산하여 Summary Bar에 적용
  ///
  /// common_util.dart의 calculateAndUpdateSummaryRatios 함수를 사용하여
  /// 비율을 계산하고 상태 변수에 저장합니다.
  Future<void> _calculateSummaryRatios() async {
    await calculateAndUpdateSummaryRatios(
      _handler,
      _selectedDay,
      onRatiosCalculated: (ratios) {
        setState(() {
          _morningRatio = ratios.morningRatio;
          _noonRatio = ratios.noonRatio;
          _eveningRatio = ratios.eveningRatio;
          _anytimeRatio = ratios.anytimeRatio;
        });
      },
    );
  }

  /// Todo 카드 위젯 생성
  Widget _buildTodoCard(
    AsyncSnapshot<List<Todo>> snapshot,
    int index,
    AppColorScheme p,
  ) {
    final todo = snapshot.data![index];
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      elevation: 4,
      borderRadius: 16,
      color: p.cardBackground,
      child: CustomColumn(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          CustomText(
            todo.title,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // 날짜와 시간대
          CustomRow(
            spacing: 8,
            children: [
              CustomText(
                todo.date,
                style: TextStyle(color: p.textSecondary, fontSize: 14),
              ),
              if (todo.time != null) ...[
                CustomText("•", style: TextStyle(color: p.textSecondary)),
                CustomText(
                  todo.time!,
                  style: TextStyle(color: p.textSecondary, fontSize: 14),
                ),
              ],
              CustomText("•", style: TextStyle(color: p.textSecondary)),
              CustomText(
                StepMapperUtil.stepToKorean(todo.step),
                style: TextStyle(color: p.textSecondary, fontSize: 14),
              ),
            ],
          ),
          // 메모가 있는 경우 표시
          if (todo.memo != null && todo.memo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            CustomText(
              todo.memo!,
              style: TextStyle(color: p.textSecondary, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // 우선순위와 완료 상태
          const SizedBox(height: 8),
          CustomRow(
            spacing: 8,
            children: [
              CustomText(
                "우선순위: ${todo.priority}",
                style: TextStyle(color: p.textSecondary, fontSize: 12),
              ),
              CustomText("•", style: TextStyle(color: p.textSecondary)),
              CustomText(
                todo.isDone ? "완료" : "미완료",
                style: TextStyle(
                  color: todo.isDone
                      ? p.dailyFlow.priorityMedium
                      : p.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //----------------------------------
  //-- Data Management Functions
  //----------------------------------

  /// 데이터 다시 로드
  void _reloadData() {
    setState(() {});
  }

  /// 데이터 변경 함수 (수정/삭제)
  Future<void> _dataChangeFn(
    FunctionType type,
    AsyncSnapshot<List<Todo>> snapshot,
    int index,
  ) async {
    final todo = snapshot.data![index];

    print("Selected todo id: ${todo.id}");

    if (type == FunctionType.update) {
      // TODO: 수정 페이지로 이동
      // await CustomNavigationUtil.to(
      //   context,
      //   EditTodoView(todo: todo),
      // );
      // _reloadData();
      CustomSnackBar.show(
        context,
        message: "수정 기능은 준비 중입니다.",
        duration: const Duration(seconds: 2),
      );
    } else if (type == FunctionType.delete) {
      // 삭제 확인 다이얼로그 표시
      await CustomDialog.show(
        context,
        title: "일정 삭제",
        message: "'${todo.title}' 일정을 삭제하시겠습니까?",
        type: DialogType.dual,
        confirmText: "삭제",
        cancelText: "취소",
        onConfirm: () async {
          await _handler.deleteData(todo);
          _reloadData();
          // 삭제 후 Summary Bar 비율 재계산
          _calculateSummaryRatios();
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

  /// 액션 패널 생성
  ActionPane _getActionPlane(
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
        ),
      ],
    );
  }
}
