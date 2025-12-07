import 'package:flutter/material.dart';
import '../../custom/custom.dart';
import '../../app_custom/custom_calendar.dart';
import '../../theme/app_colors.dart';

// 메인 화면용 캘린더 위젯 테스트 화면
//
// **목적:** `CustomCalendar` 위젯의 동작을 테스트하고 검증합니다.
//
// 테스트 항목:
// - 날짜 선택 기능
// - 이벤트 표시 (배지 및 언더바)
// - 달력 높이 조정
// - 테마 색상 적용
// - 주말 색상 구분
class HomeTestCalendar extends StatefulWidget {
  // 테마 토글 콜백 함수
  final VoidCallback onToggleTheme;

  const HomeTestCalendar({super.key, required this.onToggleTheme});

  @override
  State<HomeTestCalendar> createState() => _HomeTestCalendarState();
}

class _HomeTestCalendarState extends State<HomeTestCalendar> {
  // 테마 모드 상태 (false: 라이트 모드, true: 다크 모드)
  late bool _themeBool;

  // 선택된 날짜
  late DateTime _selectedDay;

  // 포커스된 날짜 (현재 보이는 달의 날짜)
  late DateTime _focusedDay;

  // 테스트용 이벤트 표시 여부
  //
  // true: 이벤트 배지와 진행도 바 표시
  // false: 이벤트 표시 안 함
  bool _showTestEvents = true;

  // 달력 높이 (픽셀)
  //
  // 테스트용으로 높이를 변경할 수 있습니다.
  // 0: 자동 (반응형), 그 외: 지정된 높이 (px)
  // 기본값: 0 (자동)
  double _calendarHeight = 0;

  // 위젯 초기화
  //
  // 페이지가 새로 생성될 때 한 번 호출됩니다.
  // 테마 상태를 라이트 모드(false)로 초기화하고, 날짜를 오늘로 설정합니다.
  @override
  void initState() {
    super.initState();
    _themeBool = false;
    final now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
  }

  // 위젯 빌드
  //
  // 캘린더 위젯 테스트용 UI를 구성합니다.
  @override
  Widget build(BuildContext context) {
    final p = context.palette; // AppColorScheme 객체 접근

    return Scaffold(
      backgroundColor: p.background,
      appBar: CustomAppBar(
        title: CustomText("캘린더 테스트", style: TextStyle(color: p.textPrimary)),
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
      body: SingleChildScrollView(
        child: CustomColumn(
          children: [
            // 캘린더 테스트
            // 높이 테스트를 위해 SizedBox로 감싸서 크기 제한 테스트 가능
            // _calendarHeight가 0이면 제한 없음 (반응형)
            _calendarHeight == 0
                ? CustomCalendar(
                    selectedDay: _selectedDay,
                    focusedDay: _focusedDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      print('선택된 날짜: ${_selectedDay.toString().split(' ')[0]}');
                    },
                    eventLoader: (day) {
                      // 테스트용 이벤트 표시
                      if (!_showTestEvents) {
                        return [];
                      }
                      // 오늘 날짜에만 3개의 이벤트 표시
                      final now = DateTime.now();
                      if (day.day == now.day &&
                          day.month == now.month &&
                          day.year == now.year) {
                        return [1, 2, 3];
                      }
                      // 15일에도 이벤트 표시 (테스트용)
                      if (day.day == 15) {
                        return [1, 2];
                      }
                      // 12월 26일에 10개 이벤트 표시 (테스트용)
                      if (day.day == 26 &&
                          day.month == 12 &&
                          day.year == 2025) {
                        return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
                      }
                      return [];
                    },
                  )
                : SizedBox(
                    height: _calendarHeight,
                    child: CustomCalendar(
                      selectedDay: _selectedDay,
                      focusedDay: _focusedDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        print(
                          '선택된 날짜: ${_selectedDay.toString().split(' ')[0]}',
                        );
                      },
                      eventLoader: (day) {
                        // 테스트용 이벤트 표시
                        if (!_showTestEvents) {
                          return [];
                        }
                        // 오늘 날짜에만 3개의 이벤트 표시
                        final now = DateTime.now();
                        if (day.day == now.day &&
                            day.month == now.month &&
                            day.year == now.year) {
                          return [1, 2, 3];
                        }
                        // 15일에도 이벤트 표시 (테스트용)
                        if (day.day == 15) {
                          return [1, 2];
                        }
                        // 12월 26일에 10개 이벤트 표시 (테스트용)
                        if (day.day == 26 &&
                            day.month == 12 &&
                            day.year == 2025) {
                          return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
                        }
                        return [];
                      },
                    ),
                  ),

            const SizedBox(height: 20),

            // 선택된 날짜 표시
            CustomText(
              "선택된 날짜: ${_selectedDay.toString().split(' ')[0]}",
              style: TextStyle(color: p.textPrimary, fontSize: 16),
            ),

            const SizedBox(height: 10),

            CustomText(
              "포커스된 날짜: ${_focusedDay.toString().split(' ')[0]}",
              style: TextStyle(color: p.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // ============================================
            // 테스트용 버튼 섹션
            // ============================================
            CustomText(
              "테스트 버튼",
              style: TextStyle(
                color: p.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // 날짜 이동 버튼들
            // 기능: 달력의 날짜를 빠르게 이동하여 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 오늘 날짜로 이동
                // 선택된 날짜와 포커스된 날짜를 모두 오늘로 설정
                CustomButton(
                  btnText: "오늘",
                  onCallBack: () {
                    final now = DateTime.now();
                    setState(() {
                      _selectedDay = now;
                      _focusedDay = now;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 이전 달로 이동
                // 포커스된 날짜를 한 달 앞으로 이동 (달력 화면 변경)
                CustomButton(
                  btnText: "이전 달",
                  onCallBack: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                        _focusedDay.day,
                      );
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 다음 달로 이동
                // 포커스된 날짜를 한 달 뒤로 이동 (달력 화면 변경)
                CustomButton(
                  btnText: "다음 달",
                  onCallBack: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                        _focusedDay.day,
                      );
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 특정 날짜 선택 버튼들
            // 기능: 현재 보이는 달의 특정 날짜를 선택하여 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 15일 선택
                // 현재 포커스된 달의 15일을 선택
                CustomButton(
                  btnText: "15일 선택",
                  onCallBack: () {
                    setState(() {
                      _selectedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month,
                        15,
                      );
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 1일 선택
                // 현재 포커스된 달의 1일을 선택
                CustomButton(
                  btnText: "1일 선택",
                  onCallBack: () {
                    setState(() {
                      _selectedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month,
                        1,
                      );
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 12월 26일 선택 (10개 이벤트 테스트용)
                // 2025년 12월 26일로 이동하여 10개 이벤트 확인
                CustomButton(
                  btnText: "26일 선택",
                  onCallBack: () {
                    setState(() {
                      _selectedDay = DateTime(2025, 12, 26);
                      _focusedDay = DateTime(2025, 12, 26);
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 이벤트 및 높이 조정 버튼들
            // 기능: 달력의 시각적 요소를 테스트
            CustomRow(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이벤트 표시 토글
                // 일정 갯수 배지와 진행도 바의 표시/숨김을 전환
                // true: 오늘 날짜에 3개, 15일에 2개 이벤트 표시
                // false: 모든 이벤트 숨김
                CustomButton(
                  btnText: _showTestEvents ? "이벤트 숨김" : "이벤트 표시",
                  onCallBack: () {
                    setState(() {
                      _showTestEvents = !_showTestEvents;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // 달력 높이 조정 (SizedBox로 감싸서 테스트)
                // 달력의 높이를 350px → 400px → 500px → null(자동) 순서로 순환 변경
                // 300px는 너무 낮아서 문제 발생하므로 최소 350px부터 시작
                CustomButton(
                  btnText: _calendarHeight == 0
                      ? "높이 자동"
                      : "높이 ${_calendarHeight.toInt()}px",
                  onCallBack: () {
                    setState(() {
                      if (_calendarHeight == 0) {
                        _calendarHeight = 350;
                      } else if (_calendarHeight == 350) {
                        _calendarHeight = 400;
                      } else if (_calendarHeight == 400) {
                        _calendarHeight = 500;
                      } else {
                        _calendarHeight = 0; // 0이면 자동 (null과 동일)
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
