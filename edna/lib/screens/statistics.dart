/* 
==============================
*    Title: statistics.dart
*    Author: Kimberly Meza Martinez
*    Date: Dec 2022
==============================
*/

/* Referenced code:
* https://www.syncfusion.com/flutter-widgets/flutter-charts/chart-types/doughnut-chart?utm_source=pubdev&utm_medium=listing&utm_campaign=flutter-charts-pubdev 
*/

//import 'dart:ffi';    //automatically added in, says its a ffi (foreign function interface), when running on dart native platform uses to call native c api's and to read, write, allocate & deallocate native mem

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  StatsPageState createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  late List<FoodGroupData> _chartData; //where we get our data from

  @override
  void initState() {
    _chartData = getChartData();
    super
        .initState(); //forwards default implementation to State<T> base class of widget
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        //where the graph will load

        child: Scaffold(
            body: SfCircularChart(
      //type of chart
      title: ChartTitle(
          text: 'Statistics for Food Groups',
          textStyle: GoogleFonts.notoSerif(
            fontSize: 31,
            color: Colors.black,
          )),
      legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode
              .wrap), //legendis visible and wraps to show on page size
      series: <CircularSeries>[
        DoughnutSeries<FoodGroupData, String>(
            dataSource: _chartData,
            xValueMapper: (FoodGroupData data, _) => data.foodType, //maps
            yValueMapper: (FoodGroupData data, _) => data.percent,
            dataLabelSettings: DataLabelSettings(isVisible: true))
      ],
    )));
  }

  List<FoodGroupData> getChartData() {
    //list containing our info, later info will be from our database containing our items
    final List<FoodGroupData> chartData = [
      FoodGroupData('Grain', 7),
      FoodGroupData('Fruits', 20),
      FoodGroupData('Dairy', 8),
      FoodGroupData('Vegetables', 25),
      FoodGroupData('Protein', 40),
    ];
    return chartData;
  }
}

class FoodGroupData {
  //class containing the types
  FoodGroupData(this.foodType, this.percent);
  final String foodType;
  final int percent;
}
