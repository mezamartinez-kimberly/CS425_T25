import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      height: 500,
      child: Image.asset(
        treeStages[index],
        fit: BoxFit.cover,
      ),
    );
  }

  // build widget to hold the progress bar with icon milestones
  Widget buildProgressBar() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        // add edge padding to the progress bar
        children: [
          LinearProgressIndicator(
            value: _progress,
            minHeight: 5,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          Row(
            children: [
              //add a sized box to add space between the icons
              const SizedBox(width: 21),
              Icon(
                Icons.star,
                color: _progress >= 0.1 ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 9),
              Icon(
                Icons.star,
                color: _progress >= 0.2 ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 42),
              Icon(
                Icons.star,
                color: _progress >= 0.4 ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 42),
              Icon(
                Icons.star,
                color: _progress >= 0.6 ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 98),
              Icon(
                Icons.star,
                color: _progress >= 1.0 ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
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
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTitle(),
            buildTree(index),
            buildProgressBar(),
          ],
        ),
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
                } else if (_progress == 0.0) {
                  _progress = 0.0;
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
