import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/charts.dart/';

class SplineChart extends StatefulWidget {
  const SplineChart({super.key});

  @override
  State<SplineChart> createState() => _SplineChartState();
}

class _SplineChartState extends State<SplineChart> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SfCartesianChart());
  }
}
