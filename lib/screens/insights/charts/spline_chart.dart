import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SplineChart extends StatefulWidget {
  final List<Transaction> transactions;
  const SplineChart({super.key, required this.transactions});

  @override
  State<SplineChart> createState() => _SplineChartState();
}

class _SplineChartState extends State<SplineChart> {
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

    //debug
    // _chartData.forEach((entry) {
    //   print('Date: ${entry.x}, Amount: ${entry.y}');
    // });

    return SafeArea(child: SfCartesianChart(
      title: ChartTitle(text: 'Current Month Expenses by Date'),
      tooltipBehavior: _tooltipBehaviror,
      primaryXAxis: DateTimeAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        dateFormat: DateFormat('MM/dd'),
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
        splineType: SplineType.natural,
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
  final Map<DateTime, double> dateAmountMap = {};

  // Iterate through transactions and calculate the sum of amounts for each date
  for (final transaction in transactions) {
    final transactionDate = DateTime(transaction.dateTime!.year, transaction.dateTime!.month, transaction.dateTime!.day);
    if (dateAmountMap.containsKey(transactionDate)) {
      dateAmountMap[transactionDate] = (dateAmountMap[transactionDate] ?? 0.0) + transaction.transactionAmount;
    } else {
      dateAmountMap[transactionDate] = transaction.transactionAmount;
    }
  }

  // Create _ChartData objects from the date and amount
  final List<_ChartData> chartDataList = dateAmountMap.entries.map((entry) {
    return _ChartData(entry.key, entry.value);
  }).toList();

  // Sort the list by date
  chartDataList.sort((a, b) => a.x.compareTo(b.x));
  return chartDataList;
}