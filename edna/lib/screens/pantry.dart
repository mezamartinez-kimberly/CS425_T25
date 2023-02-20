/* 
==============================
*    Title: pantry.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

/* Referenced code:
* https://api.flutter.dev/flutter/widgets/ListView-class.html
*/

import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart';
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // pantry item widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget

main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PantryPage());
}

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  PantryPageState createState() => PantryPageState();
}

int count = 0; // debugging

class PantryPageState extends State<PantryPage> {
  bool _showDeletedItems = false;

  refresh() {
    // wait 400 ms
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(child: Text('Pantry')),
                  Tab(child: Text('Fridge')),
                  Tab(child: Text('Freezer')),
                ],
              ),
              title: const Text('Shelf'),
            ),
            body: Column(children: [
              // make scrollable
              _buildHeader(),
              Expanded(
                  child:
                      _showDeletedItems ? _listAllItems() : _listActiveItems()),
              _buildAddButton(),
            ]),
          ),
        ));

    // home: SafeArea(
    //     child: Scaffold(
    //         body: Column(children: [
    //   // _buildHeader(),
    //   // make scrollable
    //   Expanded(
    //       child: _showDeletedItems ? _listAllItems() : _listActiveItems()),
    //   _buildAddButton()
    // ]))));
  }

  Widget _buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 15, top: 15),
        // child: Text('Pantry',
        //   style: GoogleFonts.notoSerif(fontSize: 35, color: Colors.black)),
      ),
      // delete database button for debugging
      // IconButton(
      //   icon: const Icon(
      //     Icons.delete_forever,
      //     size: 40,
      //   ),
      //   onPressed: () {
      //     PantryDatabase.instance.deleteDatabase();
      //   },
      // ),
      // eye button
      Padding(
        padding: const EdgeInsets.only(right: 30),
        child: IconButton(
          icon: _showDeletedItems
              ? const Icon(
                  Icons.remove_red_eye,
                  size: 40,
                  color: Color.fromARGB(255, 139, 14, 14),
                )
              : const Icon(
                  Icons.visibility_off,
                  size: 40,
                  color: Color.fromARGB(255, 139, 14, 14),
                ),
          onPressed: () {
            setState(() {
              _showDeletedItems = !_showDeletedItems;
              _showDeletedItems ? _listAllItems() : _listActiveItems();
            });
          },
        ),
      ),
    ]);
  }

  Widget _listAllItems() {
    return Center(
      child: FutureBuilder<List<Pantry>>(
          future: PantryDatabase.instance.getAllPantry(),
          builder: _buildPantryList()!),
    );
  }

  Widget _listActiveItems() {
    return Center(
      child: FutureBuilder<List<Pantry>>(
          future: PantryDatabase.instance.getActivePantry(),
          builder: _buildPantryList()!),
    );
  }

  _buildPantryList() {
    return (BuildContext context, AsyncSnapshot<List<Pantry>> snapshot) {
      if (!snapshot.hasData) {
        return const CircularProgressIndicator();
      }
      return snapshot.data!.isEmpty
          ? const Center(
              child: Text('No items in pantry', style: TextStyle(fontSize: 20)))
          : ListView.builder(
              shrinkWrap: true, // fix sizing
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                // instantiate new item
                Pantry item = snapshot.data![index];
                // return widget containing item
                return _showDeletedItems
                    ? ProductWidget(
                        pantryItem: item,
                        enableCheckbox: true,
                        refreshPantryList: refresh,
                      )
                    : item.isDeleted == 1
                        ? Container() // return dialog box instead ?
                        : ProductWidget(
                            pantryItem: item,
                            enableCheckbox: true,
                            refreshPantryList: refresh,
                          );
              },
            );
    };
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.only(left: 0, bottom: 20, right: 15, top: 10),
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        onPressed: () {
          // show edit widget
          showDialog(
              context: context,
              builder: (context) {
                return EditWidget(
                  pantryItem: Pantry(
                    id: 401, // static var incremented each time?
                    name: "",
                  ),
                  updateProductWidget: () {},
                  refreshPantryList: refresh,
                );
              });
          // count++; // debugging
          // await PantryDatabase.instance.insert(
          //   Pantry(
          //     name: "#$count",
          //     dateAdded: DateTime.now(),
          //     isDeleted: 0,
          //   ),
          // );
          // // refresh list
          // setState(() {});
        },
        elevation: 2.0,
        child: const Icon(
          Icons.add,
          size: 35.0,
        ),
      ),
    );
  }
}
