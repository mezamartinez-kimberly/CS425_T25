import 'package:flutter/material.dart';
import 'package:edna/screens/theme.dart'; // for main

import 'package:timelines/timelines.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';

class TreePage extends StatefulWidget {
  const TreePage({Key? key}) : super(key: key);

  @override
  TreePageState createState() => TreePageState();
}

class TreePageState extends State<TreePage> {
  // create an array of filepaths for each of the stages of the tree
  List<String> treeStages = [
    'assets/images/Stage_1.png',
    'assets/images/Stage_2.png',
    'assets/images/Stage_3.png',
    'assets/images/Stage_4.png',
    'assets/images/Stage_5.png',
    'assets/images/Stage_6.png',
  ];

  List<String> thumbnails = [
    'assets/images/tb1.png',
    'assets/images/tb2.png',
    'assets/images/tb3.png',
    'assets/images/tb4.png',
    'assets/images/tb5.png',
    'assets/images/tb6.png',
  ];

  double _progress = 0.9;

  // create a title widget
  Widget buildTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      // align letters to the left
      alignment: Alignment.centerLeft,
      child: Text(
        'Tree',
        style: GoogleFonts.roboto(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // build widget to hold the picture of the tree
  Widget buildTree(int index) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      height: 500,
      child: Image.asset(
        treeStages[index],
        fit: BoxFit.contain,
      ),
    );
  }

  // build widget to hold the time line
  Widget buildTimeline(int stageNumber) {
    double availableWidth = MediaQuery.of(context).size.width - 20;

    int numItems = 6; // number of timeline items

    // available width minus padding
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 120,
          child: Timeline.tileBuilder(
            clipBehavior: Clip.hardEdge,
            theme: TimelineThemeData(
              direction: Axis.horizontal,
              connectorTheme: const ConnectorThemeData(
                thickness: 3.0,
              ),
            ),
            builder: TimelineTileBuilder.connected(
              contentsAlign: ContentsAlign.reverse,
              itemCount: numItems,
              itemExtent: availableWidth / numItems,
              contentsBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    thumbnails[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
              connectorBuilder: (context, index, type) {
                return const SolidLineConnector(
                  color: Colors.black,
                );
              },
              indicatorBuilder: (context, index) {
                // check if index is less than or equal to current stage number
                if (index <= stageNumber) {
                  // display a solid black dot indicator for completed stages
                  return DotIndicator(
                    color: MyTheme().pinkColor,
                    child: const Padding(
                      padding: EdgeInsets.all(2.5),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  );
                } else {
                  // display an outlined black dot indicator for incomplete stages
                  return const OutlinedDotIndicator(
                      color: Colors.black, size: 18.5);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: RoundedProgressBar(
            height: 30,
            milliseconds: 1000,
            percent: _progress * 100,
            style: RoundedProgressBarStyle(
                widthShadow: 5,
                colorBorder: Colors.white,
                colorProgress: MyTheme().pinkColor,
                colorProgressDark: MyTheme().blueColor),
            borderRadius: BorderRadius.circular(12)));
  }

  @override
  Widget build(BuildContext context) {
    // create a case switch to assign index a value based on the progress
    int index = 0;

    if (_progress > 0 && _progress < 0.1) {
      index = 0;
    } else if (_progress >= 0.1 && _progress < 0.2) {
      index = 1;
    } else if (_progress >= 0.2 && _progress < 0.4) {
      index = 2;
    } else if (_progress >= 0.4 && _progress < 0.6) {
      index = 3;
    } else if (_progress >= 0.6 && _progress < 1.0) {
      index = 4;
    } else if (_progress == 1.0) {
      index = 5;
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 550,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: const Color(0xff62a082),
            ),
          ),

          // Set the height of the white container based on the progress
          // Positioned(
          //   top: 555,
          //   left: 10,
          //   right: 10,
          //   bottom: 45,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(12.0),
          //     ),
          //   ),
          // ),

          Column(
            children: [
              buildTitle(),
              const SizedBox(
                height: 30,
              ),
              buildTree(index),
              buildProgressBar(),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 515,
            child: buildTimeline(index),
          ),
        ],
      ),
      // Add 2 buttons, one that increases progress and one that decreases progress
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_progress == 1.0) {
                  _progress = 1.0;
                } else if (_progress < 1.0) {
                  _progress += 0.1;
                }
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_progress > 0.1) {
                  _progress -= 0.1;
                }
              });
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
