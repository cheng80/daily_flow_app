import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../app_custom/custom_filter_radio.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../app_custom/custom_calendar_range_header_v2.dart';
import '../app_custom/custom_calendar_range_body_v2.dart';
import '../app_custom/app_common_util.dart';
import '../app_custom/step_mapper_util.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';
import '../service/notification_service.dart';
import '../custom/util/log/custom_log_util.dart';
import 'create_todo_view.dart';
import 'edit_todo_view.dart';
import 'deleted_todos_view.dart';
import 'todo_detail_dialog.dart';
import 'home.dart';

// 함수 타입 enum
enum FunctionType { update, delete }

// 범위 선택 메인 뷰 (V2 - 단계적 개발)
//
// MainView를 기반으로 범위 선택 기능을 단계적으로 추가합니다.
// Phase 1: 싱글 모드 정상 동작 (MainView와 동일)
// Phase 2: 범위 선택 기능 추가 예정
class MainRangeViewV2 extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const MainRangeViewV2({super.key, required this.onToggleTheme});

  @override
  State<MainRangeViewV2> createState() => _MainRangeViewV2State();
}

class _MainRangeViewV2State extends State<MainRangeViewV2> {
  late bool _themeBool;
  late DatabaseHandler _handler;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  // Step 1: 범위 선택 상태 변수 추가
  DateTimeRange? _selectedRange; // 선택된 날짜 범위
  DateTime? _rangeStart; // 범위 선택 시작일 (종료일이 없을 때도 표시용)
  int _rangeSelectionCount = 0; // 범위 선택 클릭 카운트 (0: 초기, 1: 시작일 선택, 2: 종료일 선택)
  DateTime? _minDate; // 선택 가능한 최소 날짜
  DateTime? _maxDate; // 선택 가능한 최대 날짜
  int? _selectedStep; // null=전체, 0=오전, 1=오후, 2=저녁, 3=야간, 4=종일
  Map<String, List<Todo>> _todoCache = {};
  double _morningRatio = 0.0;
  double _noonRatio = 0.0;
  double _eveningRatio = 0.0;
  double _nightRatio = 0.0;
  double _anytimeRatio = 0.0;
  bool _sortByTime = false; // true=중요도순, false=시간순
  bool _calendarExpanded = true;
  bool _filterExpanded = false;
  bool _isRangeMode = true; // 범위 선택 모드 활성화 여부
  final double _barHeight = 20.0;

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
    // Step 1: 범위 선택 상태 변수 초기화
    _selectedRange = null;
    _rangeStart = null;
    _rangeSelectionCount = 0;
    _minDate = null;
    _maxDate = null;
    // Step 2: 날짜 제약 조건 로드
    _loadDateConstraints();
    // 초기 데이터 로드
    _loadCalendarEvents();
    // 초기 Summary Bar 비율 계산
    _calculateSummaryRatios();
  }

  // Step 2: 날짜 제약 조건 로드 (DB 최소/최대 날짜)
  Future<void> _loadDateConstraints() async {
    try {
      final minDateStr = await _handler.queryMinDate();
      final maxDateStr = await _handler.queryMaxDate();

      setState(() {
        if (minDateStr != null) {
          _minDate = DateTime.parse(minDateStr);
        }
        if (maxDateStr != null) {
          _maxDate = DateTime.parse(maxDateStr);
        }

        // focusedDay가 날짜 범위 내에 있는지 확인하고 조정
        if (_minDate != null && _focusedDay.isBefore(_minDate!)) {
          _focusedDay = _minDate!;
        }
        if (_maxDate != null && _focusedDay.isAfter(_maxDate!)) {
          _focusedDay = _maxDate!;
        }
      });
    } catch (e) {
      AppLogger.e('날짜 제약 조건 로드 오류', tag: 'MainRangeViewV2', error: e);
    }
  }

  // 달력 이벤트 데이터 로드 (현재 보이는 달의 데이터)
  Future<void> _loadCalendarEvents() async {
    // 현재 포커스된 달의 시작일과 종료일 계산
    // 예시 :
    // _focusedDay = 2024-03-15 인 경우:
    // firstDay = DateTime(2024, 3, 1)   // → 2024-03-01
    // lastDay = DateTime(2024, 4, 0)    // → 2024-03-31 (4월 0일 = 3월 마지막 날)

    // // _focusedDay = 2024-02-10 인 경우:
    // firstDay = DateTime(2024, 2, 1)   // → 2024-02-01
    // lastDay = DateTime(2024, 3, 0)    // → 2024-02-29 (윤년) 또는 2024-02-28

    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // 해당 달의 모든 날짜에 대해 데이터 조회
    final newCache = <String, List<Todo>>{};
    for (
      var day = firstDay;
      day.isBefore(lastDay.add(const Duration(days: 1)));
      day = day.add(const Duration(days: 1))
    ) {
      final dateStr = CustomCommonUtil.formatDate(day, 'yyyy-MM-dd');
      try {
        final todos = await _handler.queryDataByDate(dateStr);
        newCache[dateStr] = todos;
      } catch (e) {
        AppLogger.e(
          "Error loading events for $dateStr",
          tag: 'MainView',
          error: e,
        );
        newCache[dateStr] = [];
      }
    }

    setState(() {
      _todoCache = newCache;
    });
  }

  // 위젯 빌드
  //
  // 테스트 화면 선택 메뉴를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      // FAB는 body 밖에서 자동으로 고정됨
      floatingActionButton: CustomFloatingActionButton(
        onPressed: _navigateToCreateTodo,
        icon: Icons.add,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // 위치 지정
      backgroundColor: p.background,
      // 드로워 슬라이드 제스처 비활성화
      drawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(
        // drawerIconColor: p.textOnPrimary,
        // drawerIcon: Icons.menu_rounded,
        foregroundColor: p.textOnPrimary,
        toolbarHeight: 50,
        title: CustomText(
          "현재 진행 중...",
          style: TextStyle(color: p.textOnPrimary, fontSize: 24),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.cardBackground.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomRow(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  "단일",
                  style: TextStyle(color: p.textOnPrimary, fontSize: 12),
                ),
                Switch(
                  value: _isRangeMode,
                  onChanged: (value) async {
                    // 모드 전환 전 현재 상태 로그
                    AppLogger.d(
                      '[모드 전환 시작] 현재 모드: ${_isRangeMode ? "범위" : "단일"} → ${value ? "범위" : "단일"}',
                      tag: 'MainRangeViewV2',
                    );
                    AppLogger.d(
                      '[모드 전환 전] focusedDay: ${_focusedDay.toString().split(' ')[0]} (${_focusedDay.year}년 ${_focusedDay.month}월), selectedDay: ${_selectedDay.toString().split(' ')[0]}',
                      tag: 'MainRangeViewV2',
                    );

                    // 모드 전환 전 현재 focusedDay 저장
                    final currentFocusedDay = _focusedDay;

                    setState(() {
                      _isRangeMode = value;

                      // 아직 달력 클릭 이벤트가 없다면 today 기준으로 달력 새로 로드
                      final now = DateTime.now();
                      final isInitialState =
                          _selectedDay.year == now.year &&
                          _selectedDay.month == now.month &&
                          _selectedDay.day == now.day &&
                          _focusedDay.year == now.year &&
                          _focusedDay.month == now.month &&
                          _focusedDay.day == now.day;

                      if (isInitialState) {
                        // 사용자가 아직 클릭하지 않았다면 today 기준으로 설정
                        _focusedDay = now;
                        _selectedDay = now;
                        AppLogger.d(
                          '[모드 전환] 아직 클릭 이벤트 없음, today 기준으로 설정: ${now.toString().split(' ')[0]}',
                          tag: 'MainRangeViewV2',
                        );
                      }

                      if (!_isRangeMode) {
                        // 싱글 모드로 전환 시 범위 선택 해제
                        _selectedRange = null;
                        _rangeStart = null;
                        _rangeSelectionCount = 0;
                        // focusedDay는 현재 달력이 보고 있는 달로 유지 (변경하지 않음)
                        // 초기 상태가 아니면 focusedDay 유지, 초기 상태면 현재 날짜로
                        if (isInitialState) {
                          _focusedDay = now;
                          _selectedDay = now;
                        }
                        // selectedDay는 focusedDay와 동기화 (단일 모드에서는 선택된 날짜 = focusedDay)
                        _selectedDay = _focusedDay;
                        // focusedDay를 명시적으로 새 인스턴스로 생성하여 달력 위젯이 변경을 감지하도록 함
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month,
                          _focusedDay.day,
                        );
                        AppLogger.d(
                          '[단일 모드로 전환] focusedDay 유지: ${_focusedDay.toString().split(' ')[0]} (${_focusedDay.year}년 ${_focusedDay.month}월), selectedDay 동기화: ${_selectedDay.toString().split(' ')[0]}',
                          tag: 'MainRangeViewV2',
                        );
                      } else {
                        // 범위 모드로 전환 시 범위 선택 초기화
                        _selectedRange = null;
                        _rangeStart = null;
                        _rangeSelectionCount = 0;
                        // focusedDay는 현재 달력이 보고 있는 달로 유지 (변경하지 않음)
                        // 초기 상태면 현재 날짜로 설정
                        if (isInitialState) {
                          _focusedDay = now;
                          _selectedDay = now;
                        }

                        // minDate/maxDate 제약 확인 및 조정
                        if (_minDate != null &&
                            _focusedDay.isBefore(_minDate!)) {
                          AppLogger.d(
                            '[범위 모드 전환] focusedDay가 minDate보다 이전: ${_focusedDay.toString().split(' ')[0]} < ${_minDate!.toString().split(' ')[0]}, minDate로 조정',
                            tag: 'MainRangeViewV2',
                          );
                          _focusedDay = _minDate!;
                        }
                        if (_maxDate != null &&
                            _focusedDay.isAfter(_maxDate!)) {
                          AppLogger.d(
                            '[범위 모드 전환] focusedDay가 maxDate보다 이후: ${_focusedDay.toString().split(' ')[0]} > ${_maxDate!.toString().split(' ')[0]}, maxDate로 조정',
                            tag: 'MainRangeViewV2',
                          );
                          _focusedDay = _maxDate!;
                        }
                        // selectedDay도 focusedDay와 동기화
                        _selectedDay = _focusedDay;
                        AppLogger.d(
                          '[범위 모드로 전환] focusedDay 설정: ${_focusedDay.toString().split(' ')[0]} (${_focusedDay.year}년 ${_focusedDay.month}월), selectedDay 동기화: ${_selectedDay.toString().split(' ')[0]}, minDate: ${_minDate?.toString().split(' ')[0] ?? "null"}, maxDate: ${_maxDate?.toString().split(' ')[0] ?? "null"}',
                          tag: 'MainRangeViewV2',
                        );
                      }
                    });

                    // 달력 갱신
                    _reloadData();

                    // 모드 전환 후 달력을 올바른 위치로 이동
                    // WidgetsBinding.instance.addPostFrameCallback을 사용하여
                    // setState 완료 후 달력 위치 조정
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        // focusedDay를 명시적으로 다시 설정하여 달력이 올바른 위치로 이동
                        setState(() {
                          // focusedDay를 현재 값으로 다시 설정 (달력 위젯 재생성 유도)
                          final targetFocusedDay = _focusedDay;
                          _focusedDay = DateTime(
                            targetFocusedDay.year,
                            targetFocusedDay.month,
                            targetFocusedDay.day,
                          );
                        });
                        // 달력 페이지 변경 이벤트 호출
                        _onPageChanged(_focusedDay);
                      }
                    });

                    // 모드 전환 후 최종 상태 로그
                    AppLogger.d(
                      '[모드 전환 완료] 최종 focusedDay: ${_focusedDay.toString().split(' ')[0]} (${_focusedDay.year}년 ${_focusedDay.month}월), 변경 여부: ${_focusedDay != currentFocusedDay}',
                      tag: 'MainRangeViewV2',
                    );
                  },
                  activeThumbColor: p.cardBackground,
                  activeTrackColor: p.accent,
                  inactiveThumbColor: p.cardBackground,
                  inactiveTrackColor: p.textOnPrimary.withOpacity(0.3),
                ),
                CustomText(
                  "범위",
                  style: TextStyle(color: p.textOnPrimary, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
        ],
      ),

      /*------------------ Drawer (설정 화면) ---------------------*/
      drawer: CustomDrawer(
        header: DrawerHeader(
          decoration: BoxDecoration(color: p.primary),
          child: CustomColumn(
            width: double.infinity,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Icon(Icons.settings_outlined, size: 48, color: p.textOnPrimary),
              CustomText(
                "설정",
                style: TextStyle(
                  color: p.textOnPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        items: [
          // 다크 모드 토글
          DrawerItem(
            label: CustomRow(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomRow(
                  spacing: 12,
                  children: [
                    Icon(
                      _themeBool
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: p.textPrimary,
                    ),
                    CustomText(
                      "다크 모드",
                      style: TextStyle(color: p.textPrimary, fontSize: 16),
                    ),
                  ],
                ),
                Switch(
                  value: _themeBool,
                  onChanged: (value) {
                    setState(() {
                      _themeBool = value;
                    });
                    widget.onToggleTheme();
                  },
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _themeBool = !_themeBool;
              });
              widget.onToggleTheme();
            },
          ),
          // 삭제 보관함
          DrawerItem(
            label: "삭제 보관함",
            icon: Icons.delete_outline,
            onTap: _navigateToDeletedTodos,
          ),
          // TODO: 삭제 예정 - 임시 Home 버튼
          DrawerItem(
            label: "Home (임시)",
            icon: Icons.home_outlined,
            onTap: _navigateToHome,
          ),
        ],
        footer: Container(
          padding: const EdgeInsets.all(16),
          child: CustomColumn(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 4,
            children: [
              Divider(color: p.textSecondary.withValues(alpha: 0.2)),
              CustomText(
                "DailyFlow v1.0.0",
                style: TextStyle(color: p.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),

      /*-----------------------------------------------*/
      body: SingleChildScrollView(
        child: CustomColumn(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //----------------------------------
            //-- Calendar ExpansionTile
            //----------------------------------
            CustomExpansionTile(
              iconColor: p.priorityVeryHigh,
              collapsedIconColor: p.priorityVeryHigh,
              title: CustomCalendarRangeHeaderV2(
                focusedDay: _focusedDay,
                onPreviousMonth: _onPreviousMonth,
                onNextMonth: _onNextMonth,
                onTodayPressed: _onTodayPressed,
              ),
              initiallyExpanded: _calendarExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _calendarExpanded = expanded;
                });
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
              children: [
                CustomCalendarRangeBodyV2(
                  key: ValueKey(
                    'calendar_${_isRangeMode}_${_focusedDay.year}_${_focusedDay.month}_${_focusedDay.day}',
                  ), // 모드와 focusedDay 변경 시 재생성
                  calendarHeight: MediaQuery.of(context).size.width * 0.9,
                  cellAspectRatio: 1.0,
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onDaySelected: _onDaySelected,
                  selectedRange: _selectedRange,
                  rangeStart: _rangeStart, // 범위 선택 시작일 (종료일이 없을 때도 표시용)
                  enableRangeSelection: _isRangeMode, // 범위 선택 모드 토글
                  onRangeSelected: _onRangeSelected,
                  onPageChanged: _onPageChanged,
                  eventLoader: _eventLoader,
                  minDate: _minDate,
                  maxDate: _maxDate,
                ),
              ],
            ),

            //----------------------------------
            //-- 범위 선택 정보 표시 (범위 모드일 때 항상 표시)
            //----------------------------------
            if (_isRangeMode)
              CustomPadding.all(
                16,
                child: CustomContainer(
                  padding: const EdgeInsets.all(12),
                  child: CustomRow(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomRow(
                        spacing: 8,
                        children: [
                          CustomText(
                            "시작 날짜:",
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CustomText(
                            (_selectedRange != null || _rangeStart != null)
                                ? CustomCommonUtil.formatDate(
                                    _selectedRange?.start ?? _rangeStart!,
                                    'yyyy-MM-dd',
                                  )
                                : "선택 안됨",
                            style: TextStyle(
                              color:
                                  (_selectedRange != null ||
                                      _rangeStart != null)
                                  ? p.primary
                                  : p.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CustomRow(
                        spacing: 8,
                        children: [
                          CustomText(
                            "종료 날짜:",
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CustomText(
                            _selectedRange != null
                                ? CustomCommonUtil.formatDate(
                                    _selectedRange!.end,
                                    'yyyy-MM-dd',
                                  )
                                : "선택 안됨",
                            style: TextStyle(
                              color: _selectedRange != null
                                  ? p.accent
                                  : p.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            //----------------------------------
            //-- Summary Bar & Filter Radio ExpansionTile
            //----------------------------------
            CustomExpansionTile(
              iconColor: p.priorityVeryHigh,
              collapsedIconColor: p.priorityVeryHigh,
              title: CustomRow(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    "필터 및 요약 : ",
                    style: TextStyle(
                      color: p.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Summary Bar (남은 공간 거의 다 차지)
                  Flexible(
                    child: CustomContainer(
                      height: _barHeight,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return actionFourRangeBar(
                            context,
                            barWidth: constraints.maxWidth,
                            barHeight: _barHeight,
                            morningRatio: _morningRatio,
                            noonRatio: _noonRatio,
                            eveningRatio: _eveningRatio,
                            nightRatio: _nightRatio,
                            anytimeRatio: _anytimeRatio,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              initiallyExpanded: _filterExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _filterExpanded = expanded;
                });
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 0,
              ),
              children: [
                CustomColumn(
                  spacing: 12,
                  children: [
                    // Filter Radio
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
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var option
                                in FilterRadioUtil.getDefaultOptions())
                              _filterRadioCreate(80, 40, 16, option),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //----------------------------------

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
                    SizedBox(width: 16),
                  ],
                ),
              ],
            ),

            //----------------------------------
            //-- FutureBuilder 삽입위치 ----------
            CustomPadding.all(
              16,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: FutureBuilder<List<Todo>>(
                  future: _selectedRange != null
                      ? _handler.queryDataByDateRange(
                          CustomCommonUtil.formatDate(
                            _selectedRange!.start,
                            'yyyy-MM-dd',
                          ),
                          CustomCommonUtil.formatDate(
                            _selectedRange!.end,
                            'yyyy-MM-dd',
                          ),
                        )
                      : (_selectedStep == null
                            ? _handler.queryDataByDate(
                                CustomCommonUtil.formatDate(
                                  _selectedDay,
                                  'yyyy-MM-dd',
                                ),
                              )
                            : _handler.queryDataByDateAndStep(
                                CustomCommonUtil.formatDate(
                                  _selectedDay,
                                  'yyyy-MM-dd',
                                ),
                                _selectedStep!,
                              )),
                  builder: (context, snapshot) {
                    final queryDate = CustomCommonUtil.formatDate(
                      _selectedDay,
                      'yyyy-MM-dd',
                    );
                    AppLogger.d(
                      "Query date: $queryDate, Selected step: $_selectedStep",
                      tag: 'MainView',
                    );
                    AppLogger.d(
                      snapshot.hasData && snapshot.data!.isNotEmpty
                          ? "Data length: ${snapshot.data!.length}"
                          : "No data",
                      tag: 'MainView',
                    );
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      AppLogger.d(
                        "First todo: ${snapshot.data!.first.title}, date: ${snapshot.data!.first.date}",
                        tag: 'MainView',
                      );
                    }

                    // 정렬된 데이터 가져오기
                    final sortedData =
                        snapshot.hasData && snapshot.data!.isNotEmpty
                        ? _sortTodos(snapshot.data!)
                        : <Todo>[];

                    return sortedData.isNotEmpty
                        ? CustomListView(
                            itemCount: sortedData.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                startActionPane: _getActionPlane(
                                  p.dailyFlow.priorityMedium,
                                  Icons.edit,
                                  '수정',
                                  (context) async {
                                    await _dataChangeFn(
                                      FunctionType.update,
                                      sortedData,
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
                                      sortedData,
                                      index,
                                    );
                                  },
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    _showTodoDetail(sortedData[index]);
                                  },
                                  child: _buildTodoCardFromList(
                                    sortedData,
                                    index,
                                    p,
                                  ),
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

  // Todo 리스트 정렬
  //
  // [todos] 정렬할 Todo 리스트
  // 반환값: 정렬된 Todo 리스트
  // - 중요도순: priority 내림차순, 같으면 time 오름차순
  // - 시간순: time이 null이면 뒤로, 같으면 priority 내림차순
  List<Todo> _sortTodos(List<Todo> todos) {
    final sorted = List<Todo>.from(todos);

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

  // 오늘 날짜로 이동
  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = now;
      _focusedDay = now;
    });
  }

  // 날짜 선택 콜백
  //
  // [selectedDay] 사용자가 선택한 날짜
  // [focusedDay] 현재 포커스된 날짜
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    AppLogger.d(
      '[날짜 선택 시작] selectedDay: ${selectedDay.toString().split(' ')[0]}, focusedDay: ${focusedDay.toString().split(' ')[0]}',
      tag: 'MainRangeViewV2',
    );

    // 날짜 유효성 검사: 현재 날짜 기준 ±5년 이내만 허용
    final now = DateTime.now();
    final minValidDate = DateTime(now.year - 5, 1, 1);
    final maxValidDate = DateTime(now.year + 5, 12, 31);

    // selectedDay가 유효 범위를 벗어나면 무시하고 현재 focusedDay 사용
    if (selectedDay.isBefore(minValidDate) ||
        selectedDay.isAfter(maxValidDate)) {
      AppLogger.e(
        '[날짜 선택 무시] 비정상적인 날짜: ${selectedDay.toString().split(' ')[0]} (범위: ${minValidDate.toString().split(' ')[0]} ~ ${maxValidDate.toString().split(' ')[0]}), focusedDay로 대체',
        tag: 'MainRangeViewV2',
      );
      setState(() {
        // focusedDay가 유효하면 focusedDay 사용, 아니면 현재 날짜 사용
        if (focusedDay.isBefore(minValidDate) ||
            focusedDay.isAfter(maxValidDate)) {
          _selectedDay = now;
          _focusedDay = now;
        } else {
          _selectedDay = focusedDay;
          _focusedDay = focusedDay;
        }
      });
    } else {
      setState(() {
        _selectedDay = selectedDay;
        // focusedDay도 유효한 범위인지 확인
        if (focusedDay.isBefore(minValidDate) ||
            focusedDay.isAfter(maxValidDate)) {
          AppLogger.e(
            '[focusedDay 조정] 비정상적인 focusedDay: ${focusedDay.toString().split(' ')[0]}, selectedDay로 대체',
            tag: 'MainRangeViewV2',
          );
          _focusedDay = selectedDay;
        } else {
          _focusedDay = focusedDay;
        }
      });
    }

    // 날짜 선택 시 Summary Bar 비율 재계산
    _calculateSummaryRatios();

    AppLogger.d(
      '[날짜 선택 완료] 최종 selectedDay: ${_selectedDay.toString().split(' ')[0]}, focusedDay: ${_focusedDay.toString().split(' ')[0]}',
      tag: 'MainRangeViewV2',
    );
  }

  // Step 3: 날짜 범위 선택 콜백 (범위 모드에서 날짜 클릭 시 호출)
  //
  // [start] 시작일
  // [end] 종료일 (null일 수 있음)
  // table_calendar의 onRangeSelected는:
  // - 첫 번째 클릭: start는 클릭한 날짜, end는 null
  // - 두 번째 클릭: start는 첫 번째 날짜, end는 두 번째 날짜
  // 하지만 실제로는 두 번째 클릭도 end가 null로 올 수 있으므로,
  // onDaySelected를 함께 사용하여 두 번째 클릭을 감지합니다.
  void _onRangeSelected(DateTime start, DateTime? end) {
    final clickedDate = DateTime(start.year, start.month, start.day);

    // 중복 호출 방지: 같은 날짜를 같은 상태에서 다시 호출하면 무시
    if (_rangeSelectionCount == 0 && end == null) {
      // 첫 번째 클릭인데 이미 _rangeStart가 같은 날짜면 무시
      if (_rangeStart != null &&
          _rangeStart!.year == clickedDate.year &&
          _rangeStart!.month == clickedDate.month &&
          _rangeStart!.day == clickedDate.day) {
        AppLogger.d(
          '[중복 호출 무시] 카운트: $_rangeSelectionCount, start: ${start.toString().split(' ')[0]}, end: ${end?.toString().split(' ')[0] ?? "null"}',
          tag: 'MainRangeViewV2',
        );
        return;
      }
    }

    AppLogger.d(
      '[범위 선택 시작] 카운트: $_rangeSelectionCount, start: ${start.toString().split(' ')[0]}, end: ${end?.toString().split(' ')[0] ?? "null"}',
      tag: 'MainRangeViewV2',
    );

    setState(() {
      if (_rangeSelectionCount == 0) {
        // 첫 번째 클릭: 시작일만 설정 (범위는 아직 없음)
        // end가 null이면 첫 번째 클릭
        if (end == null) {
          AppLogger.d(
            '[첫 번째 클릭] 시작일 설정: ${clickedDate.toString().split(' ')[0]}',
            tag: 'MainRangeViewV2',
          );
          _selectedRange = null;
          _rangeStart = clickedDate;
          _rangeSelectionCount = 1;
          _selectedDay = clickedDate;
        }
      } else if (_rangeSelectionCount == 1) {
        // 두 번째 클릭: 종료일 설정 + 범위 완성
        if (_rangeStart != null) {
          // 같은 날짜를 다시 클릭하면 리셋
          if (clickedDate.year == _rangeStart!.year &&
              clickedDate.month == _rangeStart!.month &&
              clickedDate.day == _rangeStart!.day &&
              end == null) {
            AppLogger.d(
              '[같은 날짜 재클릭] 리셋: ${clickedDate.toString().split(' ')[0]}',
              tag: 'MainRangeViewV2',
            );
            _selectedRange = null;
            _rangeStart = null;
            _rangeSelectionCount = 0; // 리셋
            _selectedDay = clickedDate;
          } else if (end != null) {
            // end가 null이 아니면 두 번째 클릭으로 범위 완성
            AppLogger.d(
              '[두 번째 클릭] 종료일 설정: ${_rangeStart!.toString().split(' ')[0]} ~ ${end.toString().split(' ')[0]}',
              tag: 'MainRangeViewV2',
            );
            final startDate = _rangeStart!;
            final endDate = DateTime(end.year, end.month, end.day);

            if (startDate.isAfter(endDate)) {
              // 역순 선택 시 교환
              _selectedRange = DateTimeRange(
                start: endDate,
                end: DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day,
                  23,
                  59,
                  59,
                  999,
                ),
              );
              _selectedDay = endDate;
            } else {
              _selectedRange = DateTimeRange(
                start: startDate,
                end: DateTime(
                  endDate.year,
                  endDate.month,
                  endDate.day,
                  23,
                  59,
                  59,
                  999,
                ),
              );
              _selectedDay = startDate;
            }
            _rangeSelectionCount = 2; // 범위 완성
            _rangeStart = null; // 범위 완성 후 초기화
          } else {
            // end가 null이고 다른 날짜를 클릭한 경우
            // table_calendar는 두 번째 클릭에서도 end를 null로 보낼 수 있으므로,
            // 두 번째 클릭으로 간주하여 종료일을 설정
            AppLogger.d(
              '[두 번째 클릭 (end=null)] 종료일 설정: ${_rangeStart!.toString().split(' ')[0]} ~ ${clickedDate.toString().split(' ')[0]}',
              tag: 'MainRangeViewV2',
            );
            final startDate = _rangeStart!;
            final endDate = clickedDate;

            if (startDate.isAfter(endDate)) {
              // 역순 선택 시 교환
              _selectedRange = DateTimeRange(
                start: endDate,
                end: DateTime(
                  startDate.year,
                  startDate.month,
                  startDate.day,
                  23,
                  59,
                  59,
                  999,
                ),
              );
              _selectedDay = endDate;
            } else {
              _selectedRange = DateTimeRange(
                start: startDate,
                end: DateTime(
                  endDate.year,
                  endDate.month,
                  endDate.day,
                  23,
                  59,
                  59,
                  999,
                ),
              );
              _selectedDay = startDate;
            }
            _rangeSelectionCount = 2; // 범위 완성
            _rangeStart = null; // 범위 완성 후 초기화
          }
        }
      } else if (_rangeSelectionCount == 2) {
        // 세 번째 클릭: 리셋 후 새로운 시작일로 시작
        // 범위가 확정된 후 클릭하면 항상 새로운 시작일로 시작
        AppLogger.d(
          '[세 번째 클릭] 리셋 후 새로운 시작일: ${clickedDate.toString().split(' ')[0]}',
          tag: 'MainRangeViewV2',
        );
        _selectedRange = null; // 범위 해제하여 시작일 박스가 표시되도록 함
        _rangeStart = clickedDate; // 새로운 시작일 설정
        _rangeSelectionCount = 1; // 새로운 시작일 선택 상태
        _selectedDay = clickedDate;
      }

      _focusedDay = start;
    });

    // 범위 선택 시 Summary Bar 비율 재계산
    _calculateSummaryRatios();

    AppLogger.d(
      '[범위 선택 완료] 카운트: $_rangeSelectionCount, 시작일: ${_rangeStart?.toString().split(' ')[0] ?? "null"}, 종료일: ${_selectedRange?.end.toString().split(' ')[0] ?? "null"}',
      tag: 'MainRangeViewV2',
    );
  }

  // 오늘 버튼 클릭 콜백
  void _onTodayPressed() {
    _goToToday();
    _loadCalendarEvents();
    _calculateSummaryRatios();
  }

  // 달력 페이지 변경 콜백
  //
  // [focusedDay] 변경된 포커스 날짜
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    // 월 변경 시 이벤트 데이터 다시 로드
    _loadCalendarEvents();
  }

  // 이전 월 이동 버튼 클릭 콜백
  void _onPreviousMonth() {
    final previousMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month - 1,
      _focusedDay.day,
    );
    _onPageChanged(previousMonth);
  }

  // 다음 월 이동 버튼 클릭 콜백
  void _onNextMonth() {
    final nextMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      _focusedDay.day,
    );
    _onPageChanged(nextMonth);
  }

  // 이벤트 로더 콜백
  //
  // [day] 조회할 날짜
  // 반환값: 해당 날짜의 Todo 리스트
  List<Todo> _eventLoader(DateTime day) {
    // 날짜를 'YYYY-MM-DD' 형식으로 변환
    final dateStr = CustomCommonUtil.formatDate(day, 'yyyy-MM-dd');
    // 캐시에서 해당 날짜의 Todo 리스트 반환
    return _todoCache[dateStr] ?? [];
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

  // 선택된 날짜의 일정을 Step별로 비율 계산하여 Summary Bar에 적용
  //
  // 범위 모드일 때는 calculateRangeSummaryRatios를 사용하고,
  // 싱글 모드일 때는 calculateAndUpdateSummaryRatios를 사용합니다.
  Future<void> _calculateSummaryRatios() async {
    if (_selectedRange != null) {
      // 범위 모드: calculateRangeSummaryRatios 사용
      final ratios = await calculateRangeSummaryRatios(
        _handler,
        CustomCommonUtil.formatDate(_selectedRange!.start, 'yyyy-MM-dd'),
        CustomCommonUtil.formatDate(_selectedRange!.end, 'yyyy-MM-dd'),
      );
      if (!mounted) return;
      setState(() {
        _morningRatio = ratios.morningRatio;
        _noonRatio = ratios.noonRatio;
        _eveningRatio = ratios.eveningRatio;
        _nightRatio = ratios.nightRatio;
        _anytimeRatio = ratios.anytimeRatio;
      });
    } else {
      // 싱글 모드: 기존 로직 사용
      await calculateAndUpdateSummaryRatios(
        _handler,
        _selectedDay,
        onRatiosCalculated: (ratios) {
          if (!mounted) return;
          setState(() {
            _morningRatio = ratios.morningRatio;
            _noonRatio = ratios.noonRatio;
            _eveningRatio = ratios.eveningRatio;
            _nightRatio = ratios.nightRatio;
            _anytimeRatio = ratios.anytimeRatio;
          });
        },
      );
    }
  }

  // 완료 상태에 따른 제목 텍스트 스타일 반환
  //
  // [isDone] 완료 여부
  // [p] AppColorScheme 객체
  // 반환값: 완료된 경우 취소선이 적용된 TextStyle, 미완료인 경우 일반 TextStyle
  TextStyle _getTitleTextStyle(bool isDone, AppColorScheme p) {
    return TextStyle(
      color: p.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
    );
  }

  // Todo 카드 위젯 생성
  // Todo 카드 빌드 (AsyncSnapshot 사용)
  // Todo 카드 빌드 (List 사용)
  Widget _buildTodoCardFromList(List<Todo> todos, int index, AppColorScheme p) {
    final todo = todos[index];

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      elevation: 4,
      borderRadius: 16,
      color: p.cardBackground,
      child: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          const checkboxWidth = 48.0;
          const priorityStripWidth = 60.0;
          const cardMargin = 16.0 * 2; // 좌우 마진
          final contentWidth =
              screenWidth - checkboxWidth - priorityStripWidth - cardMargin;

          return IntrinsicHeight(
            child: CustomRow(
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 체크박스 영역 (고정 크기)
                SizedBox(
                  width: checkboxWidth,
                  child: CustomPadding(
                    padding: const EdgeInsets.only(top: 0, left: 16),
                    child: CustomCheckbox(
                      value: todo.isDone,
                      onChanged: (value) => _toggleTodoDone(todo, value),
                    ),
                  ),
                ),
                // 2. 내용 영역 (계산된 크기)
                SizedBox(
                  width: contentWidth,
                  child: CustomPadding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 12,
                      bottom: 10,
                      right: 12,
                    ),
                    child: CustomColumn(
                      spacing: 0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목
                        CustomText(
                          todo.title,
                          style: _getTitleTextStyle(todo.isDone, p),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // 날짜와 시간대
                        CustomRow(
                          spacing: 4,
                          children: [
                            CustomText(
                              todo.date,
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            if (todo.time != null) ...[
                              CustomText(
                                "•",
                                style: TextStyle(color: p.textSecondary),
                              ),
                              CustomText(
                                todo.time!,
                                style: TextStyle(
                                  color: p.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              // 알람 아이콘 (시간이 있고 알람이 활성화된 경우)
                              if (todo.hasAlarm) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.alarm, size: 16, color: p.primary),
                              ],
                            ],
                            CustomText(
                              "•",
                              style: TextStyle(color: p.textSecondary),
                            ),
                            CustomText(
                              StepMapperUtil.stepToKorean(todo.step),
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // 메모 표시 (항상 표시하여 카드 크기 일관성 유지)
                        const SizedBox(height: 2),
                        CustomText(
                          '메모 : ${todo.memo != null && todo.memo!.isNotEmpty ? todo.memo! : "없음"}',
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // 3. 우선순위 띠 영역 (고정 크기)
                SizedBox(
                  width: priorityStripWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: getPriorityColor(todo.priority, p),
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

  //----------------------------------
  //-- Data Management Functions
  //----------------------------------

  // 데이터 다시 로드
  //
  // Todo 리스트, 달력 이벤트, Summary Bar 비율을 모두 갱신합니다.
  void _reloadData() {
    setState(() {});
    _loadCalendarEvents();
    _calculateSummaryRatios();
  }

  // Todo 완료 상태 토글
  //
  // [todo] 완료 상태를 변경할 Todo 객체
  // [value] 새로운 완료 상태 (null일 수 있음)
  Future<void> _toggleTodoDone(Todo todo, bool? value) async {
    if (todo.id != null) {
      await _handler.toggleDone(todo.id!, value ?? false);
      _reloadData();
    }
  }

  // 데이터 변경 함수 (수정/삭제)
  Future<void> _dataChangeFn(
    FunctionType type,
    List<Todo> todos,
    int index,
  ) async {
    final todo = todos[index];

    AppLogger.d("Selected todo id: ${todo.id}", tag: 'MainView');

    if (type == FunctionType.update) {
      // 수정 페이지로 이동
      final result = await CustomNavigationUtil.to(
        context,
        EditTodoView(onToggleTheme: widget.onToggleTheme, todo: todo),
      );
      if (result == true) {
        _reloadData();
      }
    } else if (type == FunctionType.delete) {
      // 삭제 확인 다이얼로그 표시
      await CustomDialog.show(
        context,
        title: "일정 삭제",
        message: "일정을 삭제 하시겠습니까?",
        type: DialogType.dual,
        confirmText: "삭제",
        cancelText: "취소",
        onConfirm: () async {
          // 알람이 있으면 취소
          if (todo.notificationId != null) {
            final notificationService = NotificationService();
            await notificationService.cancelNotification(todo.notificationId!);
            AppLogger.s(
              "알람 취소 완료: notificationId=${todo.notificationId}",
              tag: 'MainView',
            );
          }

          await _handler.deleteData(todo);
          _reloadData();
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

  // 액션 패널 생성
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

  // 일정 등록 화면으로 이동
  //
  // 플로팅 액션 버튼 클릭 시 CreateTodoView로 이동하고,
  // 현재 선택된 날짜를 initialDate로 전달합니다.
  // 저장 완료 후 돌아오면 데이터를 새로고침합니다.
  Future<void> _navigateToCreateTodo() async {
    final result = await CustomNavigationUtil.to(
      context,
      CreateTodoView(
        onToggleTheme: widget.onToggleTheme,
        initialDate: _selectedDay,
      ),
    );

    // 저장 완료 후 데이터 새로고침
    if (result == true) {
      _reloadData();
    }
  }

  // 삭제된 Todo 화면으로 이동
  //
  // AppBar의 쓰레기통 아이콘 버튼 클릭 시 DeletedTodosView로 이동합니다.
  Future<void> _navigateToDeletedTodos() async {
    await CustomNavigationUtil.to(
      context,
      DeletedTodosView(onToggleTheme: widget.onToggleTheme),
    );
  }

  // TODO: 삭제 예정 - 임시 Home 화면으로 이동
  Future<void> _navigateToHome() async {
    await CustomNavigationUtil.to(
      context,
      Home(onToggleTheme: widget.onToggleTheme),
    );
  }

  // Todo 상세 다이얼로그 표시
  //
  // [todo] 표시할 Todo 객체
  Future<void> _showTodoDetail(Todo todo) async {
    // 다이얼로그 표시
    final result = await TodoDetailDialog.show(context: context, todo: todo);

    // Edit 버튼을 눌렀을 경우 (result == true)
    if (result == true) {
      // 다이얼로그가 닫힌 후 수정 화면으로 이동
      if (context.mounted) {
        final editResult = await CustomNavigationUtil.to(
          context,
          EditTodoView(onToggleTheme: widget.onToggleTheme, todo: todo),
        );
        // 수정 화면에서 돌아올 때 데이터 갱신
        if (editResult == true) {
          _reloadData();
        }
      }
    }
  }
}
