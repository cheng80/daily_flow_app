// 범위 통계 화면
//
// 날짜 범위를 선택하여 기간 내 일정 통계를 확인할 수 있는 화면입니다.
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../custom/custom.dart';
import '../theme/app_colors.dart';
import '../app_custom/app_common_util.dart';
import '../app_custom/step_mapper_util.dart';
import '../vm/database_handler.dart';
import '../model/todo_model.dart';
import '../custom/util/log/custom_log_util.dart';

class StatisticsRangeView extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final DateTimeRange? initialRange; // 메인 화면에서 전달받은 날짜 범위
  final int? initialStep; // 메인 화면에서 전달받은 Step 필터 (null=전체)

  const StatisticsRangeView({
    super.key,
    required this.onToggleTheme,
    this.initialRange,
    this.initialStep,
  });

  @override
  State<StatisticsRangeView> createState() => _StatisticsRangeViewState();
}

class _StatisticsRangeViewState extends State<StatisticsRangeView> {
  late DatabaseHandler _handler;
  DateTimeRange? _selectedRange;
  DateTime? _minDate;
  DateTime? _maxDate;
  int? _selectedStep; // Step 필터 (null=전체)
  List<Todo> _rangeTodos = [];
  AppSummaryRatios? _rangeRatios;
  AppRangeStatistics? _rangeStatistics;
  bool _isLoading = false;
  final double _barHeight = 20.0;

  @override
  void initState() {
    super.initState();
    _handler = DatabaseHandler();
    _selectedRange = widget.initialRange; // 메인 화면에서 전달받은 범위 설정
    _selectedStep = widget.initialStep; // 메인 화면에서 전달받은 Step 필터
    _minDate = null;
    _maxDate = null;
    _rangeTodos = [];
    _rangeRatios = null;
    _rangeStatistics = null;
    // 날짜 제약 조건 로드
    _loadDateConstraints().then((_) {
      // 초기 범위가 있으면 통계 계산
      if (_selectedRange != null) {
        _calculateRangeStatistics();
      }
    });
  }

  // 날짜 제약 조건 로드
  Future<void> _loadDateConstraints() async {
    try {
      final minDateStr = await _handler.queryMinDate();
      final maxDateStr = await _handler.queryMaxDate();

      setState(() {
        if (minDateStr != null) {
          final parts = minDateStr.split('-');
          _minDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
        if (maxDateStr != null) {
          final parts = maxDateStr.split('-');
          _maxDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      });
    } catch (e) {
      AppLogger.e('날짜 제약 조건 로드 오류', tag: 'StatisticsRangeView', error: e);
    }
  }

  // 날짜 범위 선택
  Future<void> _selectDateRange() async {
    if (!mounted) return;
    try {
      setState(() {
        _isLoading = true;
      });

      final range = await CustomDatePicker.showRange(
        context: context,
        firstDate: _minDate ?? DateTime(1900, 1, 1),
        lastDate: _maxDate ?? DateTime(2100, 12, 31),
        helpText: '날짜 범위를 선택하세요',
      );

      if (!mounted) return;
      if (range != null) {
        setState(() {
          _selectedRange = range;
        });
        // 범위 선택 시 통계 계산
        await _calculateRangeStatistics();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('날짜 범위 선택 오류', tag: 'StatisticsRangeView', error: e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 범위 내 통계 계산
  Future<void> _calculateRangeStatistics() async {
    if (_selectedRange == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final startDate = CustomCommonUtil.formatDate(
        _selectedRange!.start,
        'yyyy-MM-dd',
      );
      final endDate = CustomCommonUtil.formatDate(
        _selectedRange!.end,
        'yyyy-MM-dd',
      );

      AppLogger.d(
        '범위 통계 계산 시작: $startDate ~ $endDate, Step 필터: ${_selectedStep ?? "전체"}',
        tag: 'StatisticsRangeView',
      );

      // 범위 내 Todo 조회 (필터 적용)
      final todos = _selectedStep == null
          ? await _handler.queryDataByDateRange(startDate, endDate)
          : await _handler.queryDataByDateRangeAndStep(
              startDate,
              endDate,
              _selectedStep!,
            );
      AppLogger.d(
        '범위 내 Todo 개수: ${todos.length} (필터: ${_selectedStep ?? "전체"})',
        tag: 'StatisticsRangeView',
      );

      // 필터링된 Todo 리스트로 Step별 비율 계산
      final ratios = _calculateRatiosFromTodos(todos);

      // 필터링된 Todo 리스트로 통계 계산
      final statistics = _calculateStatisticsFromTodos(
        todos,
        _selectedRange!.start,
        _selectedRange!.end,
      );

      AppLogger.d(
        '범위 통계 계산 완료: 일수=${statistics.dayCount}일, '
        '총 개수=${statistics.totalCount}개, '
        '완료율=${(statistics.completionRate * 100).toStringAsFixed(1)}%',
        tag: 'StatisticsRangeView',
      );

      if (!mounted) return;
      setState(() {
        _rangeTodos = todos;
        _rangeRatios = ratios;
        _rangeStatistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('범위 통계 계산 오류', tag: 'StatisticsRangeView', error: e);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Todo 리스트로부터 Step별 비율 계산
  AppSummaryRatios _calculateRatiosFromTodos(List<Todo> todos) {
    if (todos.isEmpty) {
      return AppSummaryRatios.empty;
    }

    int morningCount = 0;
    int noonCount = 0;
    int eveningCount = 0;
    int nightCount = 0;
    int anytimeCount = 0;

    for (var todo in todos) {
      switch (todo.step) {
        case StepMapperUtil.stepMorning:
          morningCount++;
          break;
        case StepMapperUtil.stepNoon:
          noonCount++;
          break;
        case StepMapperUtil.stepEvening:
          eveningCount++;
          break;
        case StepMapperUtil.stepNight:
          nightCount++;
          break;
        case StepMapperUtil.stepAnytime:
          anytimeCount++;
          break;
      }
    }

    final total = todos.length;
    return AppSummaryRatios(
      morningRatio: morningCount / total,
      noonRatio: noonCount / total,
      eveningRatio: eveningCount / total,
      nightRatio: nightCount / total,
      anytimeRatio: anytimeCount / total,
    );
  }

  // Todo 리스트로부터 통계 계산
  AppRangeStatistics _calculateStatisticsFromTodos(
    List<Todo> todos,
    DateTime startDate,
    DateTime endDate,
  ) {
    // 날짜 일수 계산
    final dayCount = endDate.difference(startDate).inDays + 1;

    // 기본 통계
    final totalCount = todos.length;
    final doneCount = todos.where((todo) => todo.isDone).length;
    final completionRate = totalCount > 0 ? doneCount / totalCount : 0.0;

    // Step별 집계
    final stepCounts = <int, int>{
      StepMapperUtil.stepMorning: 0,
      StepMapperUtil.stepNoon: 0,
      StepMapperUtil.stepEvening: 0,
      StepMapperUtil.stepNight: 0,
      StepMapperUtil.stepAnytime: 0,
    };

    final stepDoneCounts = <int, int>{
      StepMapperUtil.stepMorning: 0,
      StepMapperUtil.stepNoon: 0,
      StepMapperUtil.stepEvening: 0,
      StepMapperUtil.stepNight: 0,
      StepMapperUtil.stepAnytime: 0,
    };

    // 중요도별 집계
    final priorityCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final priorityDoneCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    // Todo 분석
    for (var todo in todos) {
      // Step별 집계
      final step = todo.step;
      stepCounts[step] = (stepCounts[step] ?? 0) + 1;
      if (todo.isDone) {
        stepDoneCounts[step] = (stepDoneCounts[step] ?? 0) + 1;
      }

      // 중요도별 집계
      final priority = todo.priority;
      priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
      if (todo.isDone) {
        priorityDoneCounts[priority] = (priorityDoneCounts[priority] ?? 0) + 1;
      }
    }

    // Step별 비율 계산
    final stepRatios = totalCount > 0
        ? AppSummaryRatios(
            morningRatio: stepCounts[StepMapperUtil.stepMorning]! / totalCount,
            noonRatio: stepCounts[StepMapperUtil.stepNoon]! / totalCount,
            eveningRatio: stepCounts[StepMapperUtil.stepEvening]! / totalCount,
            nightRatio: stepCounts[StepMapperUtil.stepNight]! / totalCount,
            anytimeRatio: stepCounts[StepMapperUtil.stepAnytime]! / totalCount,
          )
        : AppSummaryRatios.empty;

    // Step별 완료율 계산
    final stepCompletionRates = <int, double>{};
    for (var step in stepCounts.keys) {
      final count = stepCounts[step] ?? 0;
      final done = stepDoneCounts[step] ?? 0;
      stepCompletionRates[step] = count > 0 ? done / count : 0.0;
    }

    // 중요도별 비율 계산
    final priorityRatios = <int, double>{};
    for (var priority in priorityCounts.keys) {
      final count = priorityCounts[priority] ?? 0;
      priorityRatios[priority] = totalCount > 0 ? count / totalCount : 0.0;
    }

    // 중요도별 완료율 계산
    final priorityCompletionRates = <int, double>{};
    for (var priority in priorityCounts.keys) {
      final count = priorityCounts[priority] ?? 0;
      final done = priorityDoneCounts[priority] ?? 0;
      priorityCompletionRates[priority] = count > 0 ? done / count : 0.0;
    }

    return AppRangeStatistics(
      dayCount: dayCount,
      totalCount: totalCount,
      doneCount: doneCount,
      completionRate: completionRate,
      stepRatios: stepRatios,
      priorityDistribution: priorityCounts,
      priorityRatios: priorityRatios,
      stepCompletionRates: stepCompletionRates,
      priorityCompletionRates: priorityCompletionRates,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: CustomAppBar(
        title: "범위 통계",
        titleTextStyle: TextStyle(color: p.textOnPrimary, fontSize: 24),
        foregroundColor: p.textOnPrimary,
        actions: [],
      ),
      body: SingleChildScrollView(
        child: CustomColumn(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          padding: const EdgeInsets.all(16),
          children: [
            // 날짜 범위 선택 버튼
            CustomButton(
              btnText: _selectedRange == null
                  ? "날짜 범위 선택"
                  : "${CustomCommonUtil.formatDate(_selectedRange!.start, 'yyyy-MM-dd')} ~ ${CustomCommonUtil.formatDate(_selectedRange!.end, 'yyyy-MM-dd')}",
              minimumSize: const Size(double.infinity, 50),
              onCallBack: _selectDateRange,
            ),

            // 로딩 인디케이터
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),

            // 범위 통계 표시
            if (_selectedRange != null &&
                _rangeRatios != null &&
                _rangeStatistics != null &&
                !_isLoading) ...[
              CustomCard(
                padding: const EdgeInsets.all(16),
                color: p.cardBackground,
                child: CustomColumn(
                  spacing: 12,
                  children: [
                    // 기본 통계 정보
                    CustomText(
                      "범위 통계 (${_rangeStatistics!.dayCount}일, ${_rangeTodos.length}개 일정)",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        CustomText(
                          "${_rangeStatistics!.dayCount}일",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "•",
                          style: TextStyle(color: p.textSecondary),
                        ),
                        CustomText(
                          "총 ${_rangeStatistics!.totalCount}개",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "•",
                          style: TextStyle(color: p.textSecondary),
                        ),
                        CustomText(
                          "완료 ${_rangeStatistics!.doneCount}개",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "•",
                          style: TextStyle(color: p.textSecondary),
                        ),
                        CustomText(
                          "완료율 ${(_rangeStatistics!.completionRate * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: p.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // 완료율 진행 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 8,
                        width: double.infinity,
                        color: p.divider,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _rangeStatistics!.completionRate,
                          child: Container(color: p.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 완료율 Doughnut Chart
                    //
                    // **목적**: 선택된 날짜 범위 내 전체 일정의 완료/미완료 비율을 시각적으로 표현
                    // **데이터 소스**: _rangeStatistics!.doneCount (완료된 일정 수), _rangeStatistics!.totalCount (전체 일정 수)
                    // **차트 타입**: DoughnutSeries (도넛형 원형 차트)
                    // **사용 이유**:
                    //   - 전체 완료율을 한눈에 파악하기 쉽게 표현
                    //   - 완료된 일정과 미완료 일정의 비율을 직관적으로 비교 가능
                    //   - 범례와 데이터 레이블로 정확한 수치 확인 가능
                    // **데이터 구조**:
                    //   - '완료': doneCount (primary 색상)
                    //   - '미완료': totalCount - doneCount (divider 색상)
                    // **표시 정보**: 각 섹션의 개수와 전체 대비 비율(%)
                    CustomText(
                      "완료율",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: SfCircularChart(
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        series: <CircularSeries>[
                          DoughnutSeries<Map<String, dynamic>, String>(
                            dataSource: [
                              {
                                'label': '완료',
                                'count': _rangeStatistics!.doneCount,
                                'color': p.primary,
                              },
                              {
                                'label': '미완료',
                                'count':
                                    _rangeStatistics!.totalCount -
                                    _rangeStatistics!.doneCount,
                                'color': p.divider,
                              },
                            ],
                            xValueMapper: (data, _) => data['label'] as String,
                            yValueMapper: (data, _) => data['count'] as int,
                            pointColorMapper: (data, _) =>
                                data['color'] as Color,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              connectorLineSettings:
                                  const ConnectorLineSettings(
                                    type: ConnectorType.curve,
                                  ),
                              textStyle: TextStyle(
                                color: p.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                            dataLabelMapper: (data, _) {
                              final count = data['count'] as int;
                              final total = _rangeStatistics!.totalCount;
                              if (total == 0) return '0%';
                              return '${(count / total * 100).toStringAsFixed(0)}%';
                            },
                            name: '완료율',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 디바이더
                    Divider(color: p.divider, thickness: 1, height: 32),
                    // Summary Bar
                    SizedBox(
                      width: double.infinity,
                      height: _barHeight,
                      child: actionFourRangeBar(
                        context,
                        barWidth: MediaQuery.of(context).size.width - 64,
                        barHeight: _barHeight,
                        morningRatio: _rangeRatios!.morningRatio,
                        noonRatio: _rangeRatios!.noonRatio,
                        eveningRatio: _rangeRatios!.eveningRatio,
                        nightRatio: _rangeRatios!.nightRatio,
                        anytimeRatio: _rangeRatios!.anytimeRatio,
                      ),
                    ),
                    // 비율 텍스트
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        CustomText(
                          "오전: ${(_rangeRatios!.morningRatio * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "오후: ${(_rangeRatios!.noonRatio * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "저녁: ${(_rangeRatios!.eveningRatio * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "야간: ${(_rangeRatios!.nightRatio * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        CustomText(
                          "종일: ${(_rangeRatios!.anytimeRatio * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            color: p.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Step별 비율 Pie Chart
                    //
                    // **목적**: 선택된 날짜 범위 내 일정들이 시간대(Step)별로 어떻게 분포되어 있는지 시각화
                    // **데이터 소스**: _rangeRatios (AppSummaryRatios 객체)
                    //   - morningRatio: 오전(06:00-11:59) 일정 비율
                    //   - noonRatio: 오후(12:00-17:59) 일정 비율
                    //   - eveningRatio: 저녁(18:00-23:59) 일정 비율
                    //   - nightRatio: 야간(00:00-05:59) 일정 비율
                    //   - anytimeRatio: 종일 일정 비율
                    // **차트 타입**: PieSeries (파이 차트)
                    // **사용 이유**:
                    //   - 시간대별 일정 분포를 전체 대비 비율로 한눈에 파악
                    //   - 어떤 시간대에 일정이 집중되어 있는지 패턴 분석 가능
                    //   - 각 Step별 색상으로 구분하여 직관적 표현 (progressMorning, progressNoon 등)
                    // **데이터 구조**: 각 Step별 비율(0.0~1.0)을 100%로 변환하여 표시
                    // **표시 정보**: 각 Step의 비율(%)
                    CustomText(
                      "Step별 비율",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: SfCircularChart(
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        series: <CircularSeries>[
                          PieSeries<Map<String, dynamic>, String>(
                            dataSource: [
                              {
                                'step': '오전',
                                'ratio': _rangeRatios!.morningRatio,
                                'color': p.progressMorning,
                              },
                              {
                                'step': '오후',
                                'ratio': _rangeRatios!.noonRatio,
                                'color': p.progressNoon,
                              },
                              {
                                'step': '저녁',
                                'ratio': _rangeRatios!.eveningRatio,
                                'color': p.progressEvening,
                              },
                              {
                                'step': '야간',
                                'ratio': _rangeRatios!.nightRatio,
                                'color': p.progressNight,
                              },
                              {
                                'step': '종일',
                                'ratio': _rangeRatios!.anytimeRatio,
                                'color': p.progressAnytime,
                              },
                            ],
                            xValueMapper: (data, _) => data['step'] as String,
                            yValueMapper: (data, _) => data['ratio'] as double,
                            pointColorMapper: (data, _) =>
                                data['color'] as Color,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              connectorLineSettings:
                                  const ConnectorLineSettings(
                                    type: ConnectorType.curve,
                                  ),
                              textStyle: TextStyle(
                                color: p.textPrimary,
                                fontSize: 11,
                              ),
                            ),
                            dataLabelMapper: (data, _) {
                              final ratio = data['ratio'] as double;
                              return '${(ratio * 100).toStringAsFixed(0)}%';
                            },
                            name: 'Step별 비율',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 디바이더
                    Divider(color: p.divider, thickness: 1, height: 32),
                    // 중요도별 분포 Column Chart
                    //
                    // **목적**: 선택된 날짜 범위 내 일정들이 중요도(P1~P5)별로 몇 개씩 분포되어 있는지 막대 그래프로 표현
                    // **데이터 소스**: _rangeStatistics!.priorityDistribution (Map<int, int>)
                    //   - Key: 중요도 (1=P1, 2=P2, 3=P3, 4=P4, 5=P5)
                    //   - Value: 해당 중요도의 일정 개수
                    // **차트 타입**: ColumnSeries (세로 막대 차트)
                    // **사용 이유**:
                    //   - 중요도별 일정 개수를 정확한 수치로 비교 가능
                    //   - Y축 최대값을 전체 일정 개수로 설정하여 전체 대비 비율 파악 용이
                    //   - 각 중요도별 색상(getPriorityColor)으로 구분하여 직관적 표현
                    //   - 데이터 레이블로 정확한 개수 표시
                    // **Y축 설정**:
                    //   - minimum: 0
                    //   - maximum: totalCount (전체 일정 개수, 최소 5)
                    //   - interval: totalCount > 10이면 (totalCount / 10).ceil(), 아니면 1
                    // **표시 정보**: 각 중요도(P1~P5)별 일정 개수
                    CustomText(
                      "중요도별 분포",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          // Y축 최대값을 전체 일정 개수로 설정 (최소 5)
                          maximum: _rangeStatistics!.totalCount > 0
                              ? _rangeStatistics!.totalCount.toDouble()
                              : 5.0,
                          interval: _rangeStatistics!.totalCount > 10
                              ? (_rangeStatistics!.totalCount / 10)
                                    .ceil()
                                    .toDouble()
                              : 1,
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            name: '중요도별 분포',
                            dataSource: [
                              for (var priority in [1, 2, 3, 4, 5])
                                {
                                  'priority': 'P$priority',
                                  'count':
                                      _rangeStatistics!
                                          .priorityDistribution[priority] ??
                                      0,
                                  'color': getPriorityColor(priority, p),
                                },
                            ],
                            xValueMapper: (data, _) =>
                                data['priority'] as String,
                            yValueMapper: (data, _) => data['count'] as int,
                            pointColorMapper: (data, _) =>
                                data['color'] as Color,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: p.cardBackground,
                                fontSize: 11,
                              ),
                            ),
                            dataLabelMapper: (data, _) {
                              final count = data['count'] as int;
                              return count.toString();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 디바이더
                    Divider(color: p.divider, thickness: 1, height: 32),
                    // Step별 완료율 차트
                    //
                    // **목적**: 각 시간대(Step)별로 일정의 완료율을 비교하여 어떤 시간대의 일정을 잘 완료하는지 분석
                    // **데이터 소스**: _rangeStatistics!.stepCompletionRates (Map<int, double>)
                    //   - Key: Step 값 (stepMorning, stepNoon, stepEvening, stepNight, stepAnytime)
                    //   - Value: 해당 Step의 완료율 (0.0~1.0)
                    //   - 계산 방식: (해당 Step의 완료된 일정 수) / (해당 Step의 전체 일정 수)
                    // **차트 타입**: ColumnSeries (세로 막대 차트)
                    // **사용 이유**:
                    //   - 시간대별 완료율을 수치로 비교하여 패턴 분석 가능
                    //   - 어떤 시간대의 일정을 더 잘 완료하는지 파악하여 시간 관리 개선점 도출
                    //   - Y축을 0-100%로 설정하여 완료율을 직관적으로 표현
                    //   - 각 Step별 색상(progressMorning, progressNoon 등)으로 구분
                    // **Y축 설정**:
                    //   - minimum: 0
                    //   - maximum: 100 (%)
                    //   - interval: 20 (%)
                    //   - labelFormat: '{value}%'
                    // **데이터 변환**: stepCompletionRates 값(0.0~1.0)을 * 100하여 0-100%로 변환
                    // **표시 정보**: 각 Step(오전, 오후, 저녁, 야간, 종일)별 완료율(%)
                    CustomText(
                      "Step별 완료율",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 100,
                          interval: 20,
                          numberFormat: null,
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                          labelFormat: '{value}%',
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: [
                              {
                                'step': '오전',
                                'rate':
                                    _rangeStatistics!
                                        .stepCompletionRates[StepMapperUtil
                                        .stepMorning] ??
                                    0.0,
                              },
                              {
                                'step': '오후',
                                'rate':
                                    _rangeStatistics!
                                        .stepCompletionRates[StepMapperUtil
                                        .stepNoon] ??
                                    0.0,
                              },
                              {
                                'step': '저녁',
                                'rate':
                                    _rangeStatistics!
                                        .stepCompletionRates[StepMapperUtil
                                        .stepEvening] ??
                                    0.0,
                              },
                              {
                                'step': '야간',
                                'rate':
                                    _rangeStatistics!
                                        .stepCompletionRates[StepMapperUtil
                                        .stepNight] ??
                                    0.0,
                              },
                              {
                                'step': '종일',
                                'rate':
                                    _rangeStatistics!
                                        .stepCompletionRates[StepMapperUtil
                                        .stepAnytime] ??
                                    0.0,
                              },
                            ],
                            xValueMapper: (data, _) => data['step'] as String,
                            yValueMapper: (data, _) =>
                                (data['rate'] as double) * 100,
                            pointColorMapper: (data, _) {
                              final step = data['step'] as String;
                              if (step == '오전') return p.progressMorning;
                              if (step == '오후') return p.progressNoon;
                              if (step == '저녁') return p.progressEvening;
                              if (step == '야간') return p.progressNight;
                              return p.progressAnytime;
                            },
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: p.cardBackground,
                                fontSize: 11,
                              ),
                            ),
                            dataLabelMapper: (data, _) {
                              final rate = data['rate'] as double;
                              return '${(rate * 100).toStringAsFixed(0)}%';
                            },
                            name: 'Step별 완료율',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 디바이더
                    Divider(color: p.divider, thickness: 1, height: 32),
                    // 중요도별 완료율 차트
                    //
                    // **목적**: 각 중요도(P1~P5)별로 일정의 완료율을 비교하여 중요도에 따른 완료 패턴 분석
                    // **데이터 소스**: _rangeStatistics!.priorityCompletionRates (Map<int, double>)
                    //   - Key: 중요도 (1=P1, 2=P2, 3=P3, 4=P4, 5=P5)
                    //   - Value: 해당 중요도의 완료율 (0.0~1.0)
                    //   - 계산 방식: (해당 중요도의 완료된 일정 수) / (해당 중요도의 전체 일정 수)
                    // **차트 타입**: ColumnSeries (세로 막대 차트)
                    // **사용 이유**:
                    //   - 중요도별 완료율을 수치로 비교하여 우선순위 관리 패턴 분석
                    //   - 높은 중요도(P1, P2)의 완료율이 낮은지 확인하여 우선순위 관리 개선점 도출
                    //   - Y축을 0-100%로 설정하여 완료율을 직관적으로 표현
                    //   - 각 중요도별 색상(getPriorityColor)으로 구분하여 시각적 구분 용이
                    // **Y축 설정**:
                    //   - minimum: 0
                    //   - maximum: 100 (%)
                    //   - interval: 20 (%)
                    //   - labelFormat: '{value}%'
                    // **데이터 변환**: priorityCompletionRates 값(0.0~1.0)을 * 100하여 0-100%로 변환
                    // **표시 정보**: 각 중요도(P1~P5)별 완료율(%)
                    CustomText(
                      "중요도별 완료율",
                      style: TextStyle(
                        color: p.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        legend: Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 100,
                          interval: 20,
                          numberFormat: null,
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                          labelFormat: '{value}%',
                        ),
                        plotAreaBorderWidth: 0,
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            name: '중요도별 완료율',
                            dataSource: [
                              for (var priority in [1, 2, 3, 4, 5])
                                {
                                  'priority': 'P$priority',
                                  'rate':
                                      _rangeStatistics!
                                          .priorityCompletionRates[priority] ??
                                      0.0,
                                  'color': getPriorityColor(priority, p),
                                },
                            ],
                            xValueMapper: (data, _) =>
                                data['priority'] as String,
                            yValueMapper: (data, _) =>
                                (data['rate'] as double) * 100,
                            pointColorMapper: (data, _) =>
                                data['color'] as Color,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: p.cardBackground,
                                fontSize: 11,
                              ),
                            ),
                            dataLabelMapper: (data, _) {
                              final rate = data['rate'] as double;
                              return '${(rate * 100).toStringAsFixed(0)}%';
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
