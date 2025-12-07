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

  const StatisticsRangeView({super.key, required this.onToggleTheme});

  @override
  State<StatisticsRangeView> createState() => _StatisticsRangeViewState();
}

class _StatisticsRangeViewState extends State<StatisticsRangeView> {
  late DatabaseHandler _handler;
  DateTimeRange? _selectedRange;
  DateTime? _minDate;
  DateTime? _maxDate;
  List<Todo> _rangeTodos = [];
  AppSummaryRatios? _rangeRatios;
  AppRangeStatistics? _rangeStatistics;
  bool _isLoading = false;
  final double _barHeight = 20.0;

  @override
  void initState() {
    super.initState();
    _handler = DatabaseHandler();
    _selectedRange = null;
    _minDate = null;
    _maxDate = null;
    _rangeTodos = [];
    _rangeRatios = null;
    _rangeStatistics = null;
    // 날짜 제약 조건 로드
    _loadDateConstraints();
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
        '범위 통계 계산 시작: $startDate ~ $endDate',
        tag: 'StatisticsRangeView',
      );

      // 범위 내 Todo 조회
      final todos = await _handler.queryDataByDateRange(startDate, endDate);
      AppLogger.d('범위 내 Todo 개수: ${todos.length}', tag: 'StatisticsRangeView');

      // 범위 내 Step별 비율 계산
      final ratios = await calculateRangeSummaryRatios(
        _handler,
        startDate,
        endDate,
      );

      // 범위 통계 계산
      final statistics = await calculateRangeStatistics(
        _handler,
        startDate,
        endDate,
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
                      "범위 통계 (${_rangeTodos.length}개 일정)",
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
                        primaryXAxis: CategoryAxis(
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 1,
                          interval: 0.2,
                          numberFormat: null,
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                          labelFormat: '{value}',
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
                            yValueMapper: (data, _) => data['rate'] as double,
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
                          maximum: 1,
                          interval: 0.2,
                          numberFormat: null,
                          labelStyle: TextStyle(
                            color: p.textPrimary,
                            fontSize: 12,
                          ),
                          axisLine: AxisLine(color: p.divider),
                          labelFormat: '{value}',
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
                            yValueMapper: (data, _) => data['rate'] as double,
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
