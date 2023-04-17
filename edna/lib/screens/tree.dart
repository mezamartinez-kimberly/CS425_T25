import 'dart:math';

import 'package:flutter/material.dart';
import 'package:edna/screens/theme.dart'; // for main
import 'package:edna/backend_utils.dart'; // for main

import 'package:timelines/timelines.dart';
import 'package:confetti/confetti.dart';
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

  int points = 0;
  int previous_index = 0;

  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    getPoints();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // create a function to retreive the points from the database
  Future<void> getPoints() async {
    int retrievedPoints =
        await BackendUtils.getPoints(); // call getPoints function here
    setState(() {
      points = retrievedPoints;
    });
  }

  double _progress = 0.0;

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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Image.asset(
          treeStages[index],
          key: ValueKey(index),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

// create a function that displays an alert dialog congratulating the user on reaching a new stage
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // rounded corners
          ),
          title: const Text(
            'Congratulations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0, // increase font size
              fontWeight: FontWeight.bold, // bold text
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10), // decreased padding
          content: const Text(
            'You have reached a new stage!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0, // increase font size
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();

                // create a confetti widget
                _confettiController.play();
              },
            ),
          ],
        );
      },
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

    if (points > 0 && points < 50) {
      _progress = points / 50;
      index = 0;
    } else if (points >= 50 && points < 150) {
      _progress = (points - 50) / 100;
      index = 1;
    } else if (points >= 150 && points < 300) {
      _progress = (points - 150) / 150;
      index = 2;
    } else if (points >= 300 && points < 500) {
      _progress = (points - 300) / 200;
      index = 3;
    } else if (points >= 500 && points < 800) {
      _progress = (points - 500) / 300;
      index = 4;
    } else if (points >= 800) {
      _progress = 1;
      index = 5;
    }

    if (index != previous_index) {
      previous_index = index;

      // wait until the build task is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDialog();
      });
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
          Column(
            children: [
              buildTitle(),
              const SizedBox(
                height: 20,
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
          Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                blastDirection: pi / 2,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              )),
        ],
      ),
      // Add 2 buttons, one that increases progress and one that decreases progress
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (points > 25) {
                  // print(points);
                  points += 25;
                }
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                if (points > 25) {
                  // print(points);
                  points -= 25;
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
