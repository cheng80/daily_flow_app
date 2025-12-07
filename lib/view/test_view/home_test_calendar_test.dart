import 'package:flutter/material.dart';
import '../../custom/custom.dart';
import '../../app_custom/custom_calendar.dart';
import '../../theme/app_colors.dart';
import '../../vm/database_handler.dart';

// 테스트용 크기 조절 가능한 달력 위젯 테스트 화면
//
// **목적:** `CustomCalendar` 위젯의 동작을 테스트하고 검증합니다.
//
// 테스트 항목:
// - 크기 조절 기능 (rowHeight, cellMargin, cellPadding 등)
// - 오늘로 가기 버튼 동작
// - 월 이동 버튼 동작
// - 날짜 선택 기능
// - 이벤트 표시 (배지 및 언더바)
// - 테마 색상 적용
// - 주말 색상 구분
class HomeTestCalendarTest extends StatefulWidget {
  // 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestCalendarTest({super.key, required this.onToggleTheme});

  @override
  State<HomeTestCalendarTest> createState() => _HomeTestCalendarTestState();
}

class _HomeTestCalendarTestState extends State<HomeTestCalendarTest> {
  // 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  // 선택된 날짜
  late DateTime _selectedDay;

  // 포커스된 날짜 (현재 보이는 달의 날짜)
  late DateTime _focusedDay;

  // 달력 높이 (픽셀) - 입력값
  double _calendarHeight = 400.0;

  // 셀 비율 (가로:세로) - 기본값 1.0 (정사각형)
  double _cellAspectRatio = 1.0;

  // 달력 너비 (픽셀) - 자동 계산됨
  // 세로 길이와 셀 비율을 기준으로 자동 계산
  double? _calendarWidth;

  // 행 높이 (각 날짜 셀의 높이)
  double _rowHeight = 52.0;

  // 셀 마진 (각 날짜 셀 주변의 여백)
  EdgeInsets _cellMargin = const EdgeInsets.all(2.0);

  // 셀 패딩 (각 날짜 셀 내부의 여백)
  final EdgeInsets _cellPadding = EdgeInsets.zero;

  // 요일 헤더 높이
  double _daysOfWeekHeight = 40.0;

  // 헤더 높이 (월/연도 표시 영역)
  double _headerHeight = 50.0;

  // DatabaseHandler 인스턴스
  final DatabaseHandler _dbHandler = DatabaseHandler();

  // 날짜별 이벤트 캐시 (동기 접근을 위한 캐싱)
  final Map<String, List<dynamic>> _eventCache = {};

  // 위젯 초기화
  @override
  void initState() {
    super.initState();
    _themeBool = false;
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    // 초기 데이터 로드
    _loadCalendarEvents();
    // 초기 크기 계산
    _updateCalendarDimensions();
  }

  // 세로 길이와 셀 비율을 기준으로 가로 길이와 내부 요소들을 자동 계산
  // 셀 비율 = 달력 비율 (가로:세로)
  void _updateCalendarDimensions() {
    // 셀 비율에 맞춰 달력 전체 비율 계산: 가로 = 세로 * 셀 비율
    _calendarWidth = _calendarHeight * _cellAspectRatio;

    // 전체 높이에서 패딩 제외 (상하 8px * 2 = 16px)
    final availableHeight = _calendarHeight - 16.0;

    // 헤더와 요일 헤더 높이 계산
    _headerHeight = (availableHeight * 0.12).clamp(40.0, 60.0);
    _daysOfWeekHeight = (availableHeight * 0.10).clamp(30.0, 50.0);

    // 가로 길이에서 패딩 제외 (좌우 8px * 2 = 16px)
    final availableWidth = _calendarWidth! - 16.0;

    // 셀 너비 계산: (가로 - 패딩) / 7일
    final cellWidth = availableWidth / 7.0;

    // 셀 비율에 맞춰 행 높이 계산: rowHeight = cellWidth / 비율
    // (셀 비율 = 가로/세로 이므로, 세로 = 가로/비율)
    final rowH = (cellWidth / _cellAspectRatio).clamp(30.0, 80.0);
    _rowHeight = rowH;
  }

  // 달력 이벤트 로드 (캐싱)
  //
  // **참고:** 이 메서드는 테스트 페이지에서 DB를 조회하여 이벤트를 로드합니다.
  // 실제 사용 시에는 각 페이지에서 필요에 따라 데이터를 조회하고
  // `eventLoader` 콜백을 통해 달력에 전달하면 됩니다.
  Future<void> _loadCalendarEvents() async {
    try {
      // 현재 포커스된 달의 모든 날짜에 대한 이벤트 로드
      final year = _focusedDay.year;
      final month = _focusedDay.month;
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      for (var day = firstDay.day; day <= lastDay.day; day++) {
        final date = DateTime(year, month, day);
        final dateStr = CustomCommonUtil.formatDate(date, 'yyyy-MM-dd');
        try {
          final todos = await _dbHandler.queryDataByDate(dateStr);
          _eventCache[dateStr] = todos;
        } catch (e) {
          _eventCache[dateStr] = [];
        }
      }

      // 이전/다음 달의 일부 날짜도 로드 (달력에 표시되는 날짜들)
      final prevMonthLastDay = DateTime(year, month, 0);

      // 이전 달 마지막 주
      for (
        var day = prevMonthLastDay.day - 6;
        day <= prevMonthLastDay.day;
        day++
      ) {
        if (day > 0) {
          final date = DateTime(year, month - 1, day);
          final dateStr = CustomCommonUtil.formatDate(date, 'yyyy-MM-dd');
          if (!_eventCache.containsKey(dateStr)) {
            try {
              final todos = await _dbHandler.queryDataByDate(dateStr);
              _eventCache[dateStr] = todos;
            } catch (e) {
              _eventCache[dateStr] = [];
            }
          }
        }
      }

      // 다음 달 첫 주
      for (var day = 1; day <= 7; day++) {
        final date = DateTime(year, month + 1, day);
        final dateStr = CustomCommonUtil.formatDate(date, 'yyyy-MM-dd');
        if (!_eventCache.containsKey(dateStr)) {
          try {
            final todos = await _dbHandler.queryDataByDate(dateStr);
            _eventCache[dateStr] = todos;
          } catch (e) {
            _eventCache[dateStr] = [];
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('달력 이벤트 로드 오류: $e');
    }
  }

  // 날짜별 이벤트 로더 (캐시 사용)
  List<dynamic> _eventLoader(DateTime day) {
    final dateStr = CustomCommonUtil.formatDate(day, 'yyyy-MM-dd');
    return _eventCache[dateStr] ?? [];
  }

  // 위젯 빌드
  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText(
          "테스트용 달력 (크기 조절 가능)",
          style: TextStyle(color: p.textPrimary),
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
        ],
      ),
      body: Column(
        children: [
          // 달력 위젯 (최상위)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CustomPadding.all(
                    16,
                    child: CustomCalendar(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onTodayPressed: () {
                        setState(() {
                          final now = DateTime.now();
                          _selectedDay = now;
                          _focusedDay = now;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                        // 월 변경 시 이벤트 다시 로드
                        _loadCalendarEvents();
                      },
                      eventLoader: _eventLoader,
                      calendarHeight: _calendarHeight,
                      cellAspectRatio: _cellAspectRatio,
                      rowHeight: _rowHeight,
                      cellMargin: _cellMargin,
                      cellPadding: _cellPadding,
                      daysOfWeekHeight: _daysOfWeekHeight,
                      headerHeight: _headerHeight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 설정 패널 (하단)
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              child: CustomPadding.all(
                16,
                child: CustomColumn(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "크기 조절 설정",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // 달력 높이 조절 (전체 높이만 조절하면 내부 요소들이 비율에 맞춰 자동 조절)
                    CustomText(
                      "달력 전체 높이: ${_calendarHeight.toInt()}px",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CustomText(
                      "※ 세로 길이를 조절하면 셀 비율에 맞춰 가로 길이가 자동 계산됩니다.",
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
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
                          _updateCalendarDimensions();
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // 셀 비율 조절
                    CustomText(
                      "셀 비율 (가로:세로): ${_cellAspectRatio.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CustomText(
                      "※ 셀 비율 = 달력 비율입니다. 비율을 조절하면 달력 전체의 가로/세로 비율도 함께 변경됩니다.",
                      style: TextStyle(color: p.textSecondary, fontSize: 12),
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
                          _updateCalendarDimensions();
                        });
                      },
                    ),

                    // 계산된 값 표시 (참고용)
                    CustomPadding.all(
                      8,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: p.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.primary.withOpacity(0.3)),
                        ),
                        child: CustomColumn(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "자동 계산된 값 (참고용):",
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            CustomText(
                              "  • 헤더 높이: ${_headerHeight.toInt()}px",
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            CustomText(
                              "  • 요일 헤더 높이: ${_daysOfWeekHeight.toInt()}px",
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            CustomText(
                              "  • 행 높이: ${_rowHeight.toInt()}px",
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            CustomText(
                              "  • 셀 너비: ${((_calendarWidth ?? 0) - 16.0) / 7.0}px",
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            CustomText(
                              "  • 셀 비율: ${_cellAspectRatio.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: p.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 자동 계산된 너비 표시 (읽기 전용)
                    CustomText(
                      "달력 너비: ${_calendarWidth != null ? '${_calendarWidth!.toInt()}px (세로와 동일)' : '계산 중...'}",
                      style: TextStyle(
                        color: p.textSecondary,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 셀 마진 조절 (선택사항)
                    CustomText(
                      "셀 마진: ${_cellMargin.left.toInt()}px (선택사항)",
                      style: TextStyle(color: p.textSecondary),
                    ),
                    Slider(
                      value: _cellMargin.left,
                      min: 0.0,
                      max: 10.0,
                      divisions: 20,
                      label: '${_cellMargin.left.toInt()}px',
                      onChanged: (value) {
                        setState(() {
                          _cellMargin = EdgeInsets.all(value);
                        });
                      },
                    ),

                    // 선택된 날짜 표시
                    CustomText(
                      "선택된 날짜: ${CustomCommonUtil.formatDate(_selectedDay, 'yyyy-MM-dd')}",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
