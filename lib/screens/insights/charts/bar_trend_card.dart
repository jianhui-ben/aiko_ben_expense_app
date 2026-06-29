import 'package:aiko_ben_expense_app/core/theme/app_colors.dart';
import 'package:aiko_ben_expense_app/core/theme/app_spacing.dart';
import 'package:aiko_ben_expense_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TrendBar {
  final String label;
  final double value;

  const TrendBar(this.label, this.value);
}

/// Reusable column-chart card for spend-over-time across any cadence (days,
/// months). Optionally draws an average reference line and highlights one bar
/// (e.g. today / the current month). Shared by the week, month, and year tabs.
class BarTrendCard extends StatelessWidget {
  final String title;
  final List<TrendBar> bars;
  final bool showAverage;
  final int? highlightIndex;
  final bool showValueLabels;
  final double height;

  const BarTrendCard({
    super.key,
    required this.title,
    required this.bars,
    this.showAverage = true,
    this.highlightIndex,
    this.showValueLabels = false,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spending = bars.where((b) => b.value > 0).toList();
    final average = spending.isEmpty
        ? 0.0
        : spending.fold<double>(0, (s, b) => s + b.value) / spending.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const Spacer(),
              if (showAverage && average > 0)
                Text('Avg \$${average.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: height,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: theme.textTheme.labelSmall,
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
                majorGridLines: const MajorGridLines(color: AppColors.border),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                plotBands: (showAverage && average > 0)
                    ? <PlotBand>[
                        PlotBand(
                          isVisible: true,
                          start: average,
                          end: average,
                          borderColor: AppColors.textSecondary,
                          borderWidth: 1,
                          dashArray: const <double>[5, 5],
                          text: 'Avg',
                          horizontalTextAlignment: TextAnchor.end,
                          verticalTextAlignment: TextAnchor.start,
                          textStyle: theme.textTheme.labelSmall,
                        ),
                      ]
                    : const <PlotBand>[],
              ),
              series: <CartesianSeries<TrendBar, String>>[
                ColumnSeries<TrendBar, String>(
                  dataSource: bars,
                  xValueMapper: (b, _) => b.label,
                  yValueMapper: (b, _) => b.value,
                  pointColorMapper: (b, index) => index == highlightIndex
                      ? AppColors.primary
                      : AppColors.categoryAccent,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  width: 0.62,
                  dataLabelSettings: DataLabelSettings(
                    isVisible: showValueLabels,
                    labelAlignment: ChartDataLabelAlignment.outer,
                    textStyle: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
