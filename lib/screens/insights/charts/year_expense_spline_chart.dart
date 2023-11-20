import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class YearExpenseSplineChart extends StatefulWidget {
  final List<Transaction> transactions;
  const YearExpenseSplineChart({super.key, required this.transactions});

  @override
  State<YearExpenseSplineChart> createState() => _YearExpenseSplineChartState();
}

class _YearExpenseSplineChartState extends State<YearExpenseSplineChart> {
  late List<_ChartData> _chartData;
  late TooltipBehavior _tooltipBehaviror;

  @override
  void initState() {
    _chartData = convertTransactionsToChartData(widget.transactions);
    _tooltipBehaviror = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // debug
    // _chartData.forEach((entry) {
    //   print('Month: ${entry.x}, Amount: ${entry.y}');
    // });

    return SafeArea(child: SfCartesianChart(
      title: ChartTitle(text: 'Current Month Expenses by Date'),
      tooltipBehavior: _tooltipBehaviror,
      primaryXAxis: DateTimeAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        dateFormat: DateFormat('MMM'),
      ),
      primaryYAxis: NumericAxis(
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
          majorGridLines: const MajorGridLines(color: Colors.transparent)),
      series: <ChartSeries<_ChartData, DateTime>>[
        SplineSeries<_ChartData, DateTime>(
          name: 'expense',
          animationDuration: 0,
          dataSource: _chartData,
          xValueMapper: (_ChartData transactions, _) => transactions.x,
          yValueMapper: (_ChartData transactions, _) => transactions.y,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
          color: Color(0xFF6200EE),
          width: 4,
          opacity: 0.4,
          splineType: SplineType.monotonic,
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 5,
            width: 5,
            shape: DataMarkerType.circle,
          ),
        ),
      ],));
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}

List<_ChartData> convertTransactionsToChartData(List<Transaction> transactions) {
  final Map<DateTime, double> monthAmountMap = {};

  final currentYear = DateTime.now().year;
  final currentMonth = DateTime.now().month;

  // Iterate through transactions and calculate the sum of amounts for each month
  for (final transaction in transactions) {
    final transactionYear = transaction.dateTime!.year;
    final transactionMonth = transaction.dateTime!.month;

    // Skip transactions that are not from the current year or from a future month
    if (transactionYear != currentYear || transactionMonth > currentMonth) {
      continue;
    }

    final transactionMonthStart = DateTime(transactionYear, transactionMonth);

    if (monthAmountMap.containsKey(transactionMonthStart)) {
      monthAmountMap[transactionMonthStart] = (monthAmountMap[transactionMonthStart] ?? 0.0) + transaction.transactionAmount;
    } else {
      monthAmountMap[transactionMonthStart] = transaction.transactionAmount;
    }
  }

  // Include every month of the current year with a value of 0 if it's not already in the map
  for (int i = 1; i <= currentMonth; i++) {
    final monthStart = DateTime(currentYear, i);
    if (!monthAmountMap.containsKey(monthStart)) {
      monthAmountMap[monthStart] = 0.0;
    }
  }

  // Create _ChartData objects from the month and amount
  final List<_ChartData> chartDataList = monthAmountMap.entries.map((entry) {
    return _ChartData(entry.key, entry.value);
  }).toList();

  // Sort the list by month
  chartDataList.sort((a, b) => a.x.compareTo(b.x));
  return chartDataList;
}
