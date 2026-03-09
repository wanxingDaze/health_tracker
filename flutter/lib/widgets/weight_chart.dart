import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weight_record.dart';
import '../theme/app_dimens.dart';

/// 移动平均平滑，窗口大小为 min(window, length)
List<double> _smoothWeights(List<double> weights, {int window = 7}) {
  if (weights.isEmpty) return [];
  if (weights.length == 1) return weights;
  final w = window.clamp(1, weights.length);
  final half = w ~/ 2;
  return List.generate(weights.length, (i) {
    final start = (i - half).clamp(0, weights.length - 1);
    final end = (i + half).clamp(0, weights.length - 1);
    var sum = 0.0;
    var count = 0;
    for (var j = start; j <= end; j++) {
      sum += weights[j];
      count++;
    }
    return sum / count;
  });
}

enum ChartRange { week, month, year, all }

extension ChartRangeExt on ChartRange {
  int? get days {
    switch (this) {
      case ChartRange.week:
        return 7;
      case ChartRange.month:
        return 30;
      case ChartRange.year:
        return 365;
      case ChartRange.all:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ChartRange.week:
        return '周';
      case ChartRange.month:
        return '月';
      case ChartRange.year:
        return '年';
      case ChartRange.all:
        return '所有';
    }
  }
}

class WeightChart extends StatefulWidget {
  final List<WeightRecord> records;
  final double? targetWeight;

  const WeightChart({super.key, required this.records, this.targetWeight});

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  ChartRange _range = ChartRange.week;

  List<WeightRecord> get _filteredRecords {
    if (widget.records.isEmpty) return [];
    final sorted = List<WeightRecord>.from(widget.records)..sort((a, b) => a.date.compareTo(b.date));
    final days = _range.days;
    if (days == null) return sorted;
    final latest = sorted.last.date;
    final cutoff = latest.subtract(Duration(days: days));
    return sorted.where((r) => !r.date.isBefore(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecords;
    if (filtered.length < 2) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('体重趋势', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildRangeButtons(context),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '该时间范围内记录不足',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final rawWeights = filtered.map((r) => r.weight).toList();
    final smoothedWeights = _smoothWeights(rawWeights);

    final rawSpots = filtered.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList();
    final smoothedSpots = smoothedWeights.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList();

    final rawMin = rawWeights.reduce((a, b) => a < b ? a : b);
    final rawMax = rawWeights.reduce((a, b) => a > b ? a : b);
    final yPadding = 2.0;
    final minY = (rawMin - yPadding).floorToDouble();
    final maxY = (rawMax + yPadding).ceilToDouble();

    final target = widget.targetWeight;
    final showTargetLine = target != null && target >= minY && target <= maxY;

    const deepBlue = Color(0xFF1565C0);
    final lightBlue = const Color(0xFF64B5F6).withOpacity(0.55);
    final lightBlueFill = const Color(0xFF90CAF9).withOpacity(0.2);
    final isWeek = _range == ChartRange.week;

    final tickInterval = ((maxY - minY) / 6).ceilToDouble().clamp(2.0, double.infinity);
    final xTickCount = filtered.length > 60 ? 6 : (filtered.length > 14 ? 5 : 4);
    final xInterval = (filtered.length / xTickCount).clamp(1.0, double.infinity);

    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: rawSpots,
        isCurved: false,
        color: isWeek ? deepBlue : lightBlue,
        barWidth: isWeek ? 3 : 2,
        dotData: FlDotData(
          show: filtered.length <= 40,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: isWeek ? deepBlue : lightBlue,
            strokeWidth: 1,
            strokeColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: isWeek ? deepBlue.withOpacity(0.15) : lightBlueFill,
        ),
      ),
      if (!isWeek)
        LineChartBarData(
          spots: smoothedSpots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: deepBlue,
          barWidth: 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.cardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 6,
              children: [
                Text('体重趋势', style: Theme.of(context).textTheme.titleMedium),
                if (!isWeek) _buildLegend(deepBlue, lightBlue),
                if (showTargetLine)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 1.5,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('预期', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRangeButtons(context),
            const SizedBox(height: AppDimens.sectionSpacing),
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                width: constraints.maxWidth,
                height: AppDimens.chartHeight,
                child: LineChart(
                  LineChartData(
                  minX: 0,
                  maxX: (filtered.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: lineBars,
                  extraLinesData: showTargetLine
                      ? ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: target,
                              color: Colors.orange.withOpacity(0.8),
                              strokeWidth: 2,
                              dashArray: [4, 4],
                            ),
                          ],
                        )
                      : null,
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        if (touchedSpots.isEmpty) return [];
                        final idx = touchedSpots.first.spotIndex.clamp(0, filtered.length - 1);
                        final d = filtered[idx].date;
                        final raw = rawWeights[idx];
                        final smooth = smoothedWeights[idx];
                        final text = isWeek
                            ? '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}\n${raw.toStringAsFixed(1)} kg'
                            : '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}\n原始: ${raw.toStringAsFixed(1)} kg\n平滑: ${smooth.toStringAsFixed(1)} kg';
                        final item = LineTooltipItem(text, const TextStyle(color: Colors.white, fontSize: 12));
                        return touchedSpots.asMap().entries.map((e) => e.key == 0 ? item : null).toList();
                      },
                      tooltipBgColor: deepBlue,
                      tooltipRoundedRadius: 8,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: tickInterval,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: xInterval,
                        getTitlesWidget: (value, meta) {
                          final i = value.round().clamp(0, filtered.length - 1);
                          if (i < filtered.length) {
                            final d = filtered[i].date;
                            return Text(
                              '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color deepBlue, Color lightBlue) {
    return Row(
      children: [
        Container(width: 16, height: 3, decoration: BoxDecoration(color: deepBlue, borderRadius: BorderRadius.circular(1))),
        const SizedBox(width: 4),
        Text('平滑趋势', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        const SizedBox(width: 12),
        Container(width: 16, height: 1.5, decoration: BoxDecoration(color: lightBlue, borderRadius: BorderRadius.circular(1))),
        const SizedBox(width: 4),
        Text('原始数据', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildRangeButtons(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surfaceContainerHighest;
    return SegmentedButton<ChartRange>(
      showSelectedIcon: false,
      segments: ChartRange.values
          .map((r) => ButtonSegment(value: r, label: Text(r.label)))
          .toList(),
      selected: {_range},
      onSelectionChanged: (Set<ChartRange> selected) {
        setState(() => _range = selected.first);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
        textStyle: MaterialStateProperty.resolveWith((states) =>
            theme.textTheme.labelSmall?.copyWith(fontSize: 12) ?? const TextStyle(fontSize: 12)),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.2);
          }
          return surfaceColor.withOpacity(0.5);
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return theme.colorScheme.onSurfaceVariant;
        }),
      ),
    );
  }
}
