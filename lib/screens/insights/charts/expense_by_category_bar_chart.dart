import 'package:aiko_ben_expense_app/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExpenseByCategoryBarChart extends StatefulWidget {
  final List<Transaction> transactions;
  const ExpenseByCategoryBarChart({super.key, required this.transactions});

  @override
  State<ExpenseByCategoryBarChart> createState() => _ExpenseByCategoryBarChartState();
}

class _ExpenseByCategoryBarChartState extends State<ExpenseByCategoryBarChart> {
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
    // //debug
    // _chartData.forEach((entry) {
    //   print('category: ${entry.categoryName}, Amount: ${entry.transactionAmount}');
    // });

    return SafeArea(child: SfCartesianChart(
      title: ChartTitle(text: 'Expense By Category'),
      tooltipBehavior: _tooltipBehaviror,
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
          majorGridLines: const MajorGridLines(color: Colors.transparent),
          title: AxisTitle(text: 'Expense amount'),
      ),
      series: <ChartSeries>[
        BarSeries<_ChartData, String>(
          name: 'expense',
          animationDuration: 0,
          dataSource: _chartData,
          xValueMapper: (_ChartData transactions, _) => transactions.categoryName,
          yValueMapper: (_ChartData transactions, _) => transactions.transactionAmount,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
          color: Color(0xFF6200EE),
          opacity: 0.4,
        ),
      ],));
  }
}

class _ChartData {
  _ChartData(this.categoryName, this.transactionAmount);
  final String categoryName;
  final double transactionAmount;
}

List<_ChartData> convertTransactionsToChartData(List<Transaction> transactions) {
  final Map<String, double> categoryAmountMap = {};

  // Iterate through transactions and calculate the sum of amounts for each category
  for (final transaction in transactions) {
    final categoryName = transaction.category.categoryName;

    if (categoryAmountMap.containsKey(categoryName)) {
      categoryAmountMap[categoryName] = (categoryAmountMap[categoryName]  ?? 0.0)
          + transaction.transactionAmount;
    } else {
      categoryAmountMap[categoryName] = transaction.transactionAmount;
    }
  }

  // Create _ChartData objects from the category and amount
  final List<_ChartData> chartDataList = categoryAmountMap.entries.map((entry) {
    return _ChartData(entry.key, entry.value);
  }).toList();

  // Sort the list by transaction amount in descending order
  chartDataList.sort((b, a) => b.transactionAmount.compareTo(a.transactionAmount));

  return chartDataList;
}
