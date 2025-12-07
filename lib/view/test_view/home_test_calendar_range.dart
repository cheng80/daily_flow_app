import 'package:flutter/material.dart';
import '../../custom/custom.dart';
import '../../app_custom/custom_calendar_range_body.dart';
import '../../app_custom/custom_calendar_range_header.dart';
import '../../vm/database_handler.dart';
import '../../theme/app_colors.dart';

// 범위 선택 달력 테스트 화면
//
// **목적:** `CustomCalendarRangeBody` 위젯의 동작을 테스트하고 검증합니다.
//
// **기능:**
// - 범위 선택 달력 표시
// - 시작일/종료일 선택
// - 선택된 범위 표시
// - 날짜 범위 제약 (DB 최소/최대 날짜)
class HomeTestCalendarRange extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeTestCalendarRange({super.key, required this.onToggleTheme});

  @override
  State<HomeTestCalendarRange> createState() => _HomeTestCalendarRangeState();
}

class _HomeTestCalendarRangeState extends State<HomeTestCalendarRange> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now(); // 싱글 모드용 선택된 날짜 (초기값: 오늘)
  DateTimeRange? _selectedRange;
  DateTime? _minDate;
  DateTime? _maxDate;
  bool _isLoading = true;
  Map<String, List<dynamic>> _eventCache = {};
  final DatabaseHandler _dbHandler = DatabaseHandler();
  bool _enableRangeMode = false; // 범위 선택 모드 활성화 여부 (기본값: false = 싱글 모드)

  // 달력 크기 조절 변수
  double _calendarHeight = 400.0;
  double _cellAspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadDateConstraints();
    _loadCalendarEvents();
  }

  // 날짜 제약 조건 로드 (DB 최소/최대 날짜)
  Future<void> _loadDateConstraints() async {
    try {
      final minDateStr = await _dbHandler.queryMinDate();
      final maxDateStr = await _dbHandler.queryMaxDate();

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

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 달력 이벤트 로드 (현재 보이는 달의 데이터)
  Future<void> _loadCalendarEvents() async {
    try {
      // 현재 포커스된 달의 시작일과 종료일 계산
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // 해당 달의 모든 날짜에 대해 데이터 조회
      final newCache = <String, List<dynamic>>{};
      for (
        var day = firstDay;
        day.isBefore(lastDay.add(const Duration(days: 1)));
        day = day.add(const Duration(days: 1))
      ) {
        final dateStr = CustomCommonUtil.formatDate(day, 'yyyy-MM-dd');
        try {
          final todos = await _dbHandler.queryDataByDate(dateStr);
          newCache[dateStr] = todos;
        } catch (e) {
          newCache[dateStr] = [];
        }
      }

      setState(() {
        _eventCache = newCache;
      });
    } catch (e) {
      // 오류 처리
    }
  }

  // 이전 월 이동
  void _onPreviousMonth() {
    setState(() {
      final newFocusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month - 1,
        1,
      );
      // minDate 범위 내로 제한
      if (_minDate != null && newFocusedDay.isBefore(_minDate!)) {
        _focusedDay = _minDate!;
      } else {
        _focusedDay = newFocusedDay;
      }
    });
    _loadCalendarEvents();
  }

  // 다음 월 이동
  void _onNextMonth() {
    setState(() {
      final newFocusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month + 1,
        1,
      );
      // maxDate 범위 내로 제한
      if (_maxDate != null && newFocusedDay.isAfter(_maxDate!)) {
        _focusedDay = _maxDate!;
      } else {
        _focusedDay = newFocusedDay;
      }
    });
    _loadCalendarEvents();
  }

  // 오늘로 이동
  void _onTodayPressed() {
    setState(() {
      final today = DateTime.now();
      // minDate와 maxDate 범위 내로 제한
      if (_minDate != null && today.isBefore(_minDate!)) {
        _focusedDay = _minDate!;
      } else if (_maxDate != null && today.isAfter(_maxDate!)) {
        _focusedDay = _maxDate!;
      } else {
        _focusedDay = today;
      }
    });
    _loadCalendarEvents();
  }

  // 페이지 변경 (월 이동 시)
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      // minDate와 maxDate 범위 내로 제한
      if (_minDate != null && focusedDay.isBefore(_minDate!)) {
        _focusedDay = _minDate!;
      } else if (_maxDate != null && focusedDay.isAfter(_maxDate!)) {
        _focusedDay = _maxDate!;
      } else {
        _focusedDay = focusedDay;
      }
    });
    _loadCalendarEvents();
  }

  // 날짜 범위 선택
  // 싱글 모드용 날짜 선택 콜백
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _selectedRange = null; // 싱글 모드일 때는 범위 선택 해제
      _enableRangeMode = false; // 싱글 모드 유지
    });
  }

  void _onRangeSelected(DateTime start, DateTime? end) {
    print('🔵 _onRangeSelected 호출: start=$start, end=$end');
    setState(() {
      if (end != null) {
        // 시작일과 종료일이 모두 선택된 경우
        _selectedRange = DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: DateTime(end.year, end.month, end.day, 23, 59, 59, 999),
        );
        _selectedDay = null; // 범위 선택 모드일 때는 싱글 선택 해제
        _enableRangeMode = true; // 범위 선택 모드 활성화
        print('✅ 범위 선택 완료: ${_selectedRange!.start} ~ ${_selectedRange!.end}');
      } else {
        // 시작일만 선택된 경우 (임시로 시작일만 저장)
        _selectedRange = DateTimeRange(
          start: DateTime(start.year, start.month, start.day),
          end: DateTime(start.year, start.month, start.day, 23, 59, 59, 999),
        );
        print('⚠️ 시작일만 선택: ${_selectedRange!.start}');
      }
    });
  }

  // 날짜별 이벤트 로더
  // TableCalendar의 eventLoader는 동기 함수이므로 캐시된 데이터를 반환
  List<dynamic> _eventLoader(DateTime day) {
    try {
      final dateStr = CustomCommonUtil.formatDate(day, 'yyyy-MM-dd');
      // 캐시에서 해당 날짜의 Todo 리스트 반환
      return _eventCache[dateStr] ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: p.background,
        appBar: AppBar(
          backgroundColor: p.primary,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: p.textOnPrimary),
            onPressed: () {
              CustomNavigationUtil.back(context);
            },
          ),
          title: CustomText(
            "범위 선택 달력 테스트",
            style: TextStyle(color: p.textOnPrimary, fontSize: 24),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: p.primary)),
      );
    }

    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: p.textOnPrimary),
          onPressed: () {
            CustomNavigationUtil.back(context);
          },
        ),
        title: CustomText(
          "범위 선택 달력 테스트",
          style: TextStyle(color: p.textOnPrimary, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          // 상단 정보 박스와 달력 영역
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CustomPadding.all(
                    16,
                    child: CustomColumn(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 선택된 범위 표시와 날짜 제약 정보를 가로로 배치
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 선택된 범위 표시 박스
                            SizedBox(
                              width: 200,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: p.cardBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _selectedRange != null
                                    ? CustomColumn(
                                        spacing: 8,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            '선택된 날짜 범위',
                                            style: TextStyle(
                                              color: p.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          CustomText(
                                            '시작일: ${CustomCommonUtil.formatDate(_selectedRange!.start, 'yyyy-MM-dd')}',
                                            style: TextStyle(
                                              color: p.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          CustomText(
                                            '종료일: ${CustomCommonUtil.formatDate(_selectedRange!.end, 'yyyy-MM-dd')}',
                                            style: TextStyle(
                                              color: p.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          CustomText(
                                            '일수: ${_selectedRange!.duration.inDays + 1}일',
                                            style: TextStyle(
                                              color: p.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    : CustomColumn(
                                        spacing: 4,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            '선택된 날짜 범위',
                                            style: TextStyle(
                                              color: p.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          CustomText(
                                            '날짜 범위를 선택하세요',
                                            style: TextStyle(
                                              color: p.textSecondary,
                                              fontSize: 14,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // 날짜 제약 정보 박스
                            SizedBox(
                              width: 200,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: p.cardBackground,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomColumn(
                                  spacing: 8,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      '선택 가능한 날짜 범위',
                                      style: TextStyle(
                                        color: p.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    CustomText(
                                      _minDate != null
                                          ? '최소 날짜: ${CustomCommonUtil.formatDate(_minDate!, 'yyyy-MM-dd')}'
                                          : '최소 날짜: 제한 없음',
                                      style: TextStyle(
                                        color: p.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    CustomText(
                                      _maxDate != null
                                          ? '최대 날짜: ${CustomCommonUtil.formatDate(_maxDate!, 'yyyy-MM-dd')}'
                                          : '최대 날짜: 제한 없음',
                                      style: TextStyle(
                                        color: p.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // 달력 헤더
                        CustomCalendarRangeHeader(
                          focusedDay: _focusedDay,
                          onPreviousMonth: _onPreviousMonth,
                          onNextMonth: _onNextMonth,
                          onTodayPressed: _onTodayPressed,
                        ),

                        // 달력 본체
                        CustomCalendarRangeBody(
                          selectedDay: _selectedDay, // 싱글 모드용
                          focusedDay: _focusedDay,
                          onDaySelected: _onDaySelected, // 싱글 모드용
                          selectedRange: _selectedRange,
                          enableRangeSelection:
                              _enableRangeMode, // 명시적으로 범위 모드 제어
                          onRangeSelected: _onRangeSelected,
                          onPageChanged: _onPageChanged,
                          eventLoader: _eventLoader,
                          calendarHeight: _calendarHeight,
                          cellAspectRatio: _cellAspectRatio,
                          cellMargin: _enableRangeMode
                              ? EdgeInsets.zero
                              : const EdgeInsets.all(
                                  2.0,
                                ), // 싱글 모드일 때 cellMargin 명시적 설정
                          minDate: _minDate,
                          maxDate: _maxDate,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 크기 조절 슬라이더 (하단)
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: CustomPadding.all(
                16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: p.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomColumn(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        '달력 크기 조절',
                        style: TextStyle(
                          color: p.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 달력 높이 조절
                      CustomColumn(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            '달력 높이: ${_calendarHeight.toInt()}px',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            value: _calendarHeight,
                            min: 300.0,
                            max: 600.0,
                            divisions: 30,
                            label: '${_calendarHeight.toInt()}px',
                            onChanged: (value) {
                              setState(() {
                                _calendarHeight = value;
                              });
                            },
                          ),
                        ],
                      ),
                      // 셀 비율 조절
                      CustomColumn(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            '셀 비율: ${_cellAspectRatio.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: p.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Slider(
                            value: _cellAspectRatio,
                            min: 0.5,
                            max: 2.0,
                            divisions: 30,
                            label: _cellAspectRatio.toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                _cellAspectRatio = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
