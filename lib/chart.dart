import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:medication_structure/home.dart';

class linechart extends StatefulWidget {
  const linechart({super.key});

  @override
  State<linechart> createState() => _linechartState();
}

class _linechartState extends State<linechart> {
  @override
  void initState() {
    // TODO: implement initState
    chartData = getchartdata();
    super.initState();
  }

  late List<LiveData> chartData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCartesianChart(
            series: <LineSeries<LiveData, int>>[
          LineSeries<LiveData, int>(
            dataSource: chartData,
            color: Colors.amber,
            xValueMapper: (LiveData sales, _) => sales.time,
            yValueMapper: (LiveData sales, _) => sales.speed,
          ) // LineSeries
        ], // <LineSeries<LiveData, int>>[]
            primaryXAxis: NumericAxis(
                majorGridLines: const MajorGridLines(width: 0),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                interval: 3,
                title: AxisTitle(text: 'Time (seconds) ')), // NumericAxis
            primaryYAxis: NumericAxis(
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                title: AxisTitle(text: 'Internet speed (Mbps)'))));
  }
}

List<LiveData> getchartdata() {
  return <LiveData>[
    LiveData(0, 43),
    LiveData(1, 47),
    LiveData(2, 43),
    LiveData(3, 49),
    LiveData(4, 54),
    LiveData(5, 41),
    LiveData(6, 58),
    LiveData(7, 51),
    LiveData(8, 98),
    LiveData(9, 41),
    LiveData(10, 53),
    LiveData(11, 72),
    LiveData(12, 86),
    LiveData(13, 52),
    LiveData(14, 94),
    LiveData(15, 92),
    LiveData(16, 16),
    LiveData(17, 72),
    LiveData(18, 94)
  ];
}

class LiveData {
  LiveData(this.time, this.speed);
  int time;
  double speed;
}
