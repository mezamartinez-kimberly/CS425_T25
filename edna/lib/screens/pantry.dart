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

import 'package:edna/backend_utils.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart';
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // pantry item widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget

class PantryPage extends StatefulWidget {
  // constructor
  const PantryPage({Key? key}) : super(key: key);

  @override
  PantryPageState createState() => PantryPageState();
}

class PantryPageState extends State<PantryPage> with TickerProviderStateMixin {
  late bool _showDeletedItems;
  List<Pantry> activePantryItems = [];
  List<Pantry> allPantryItems = [];
  late TabController _tabController = TabController(length: 3, vsync: this);
  int _currentTab = 0; // added variable to keep track of current tab

  refresh() async {
    await _loadPantryItems(_currentTab);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentTab = _tabController.index + 1;
    _loadPantryItems(_currentTab);
    _showDeletedItems = false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0, // remove shadow
            automaticallyImplyLeading: false, // remove back button
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: MyTheme().pinkColor,
              tabs: const [
                Tab(
                    child:
                        Text('Pantry', style: TextStyle(color: Colors.black))),
                Tab(
                    child:
                        Text('Fridge', style: TextStyle(color: Colors.black))),
                Tab(
                    child:
                        Text('Freezer', style: TextStyle(color: Colors.black))),
              ],
              onTap: (index) {
                // Set the current tab to the selected tab
                setState(() {
                  _currentTab = index + 1;
                });
                _loadPantryItems(
                    _currentTab); // load pantry items for selected tab
              },
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10),
              child: Text('Shelf',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto')),
            ),
          ),
          body: Column(
            children: [
              Expanded(flex: 1, child: _buildHeader()), // eye icon
              Expanded(
                flex: 8,
                child: FutureBuilder(
                  future: _loadPantryItems(_currentTab),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return _showDeletedItems
                          ? _listAllItems()
                          : _listActiveItems();
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // eye icon
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 10),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: MyTheme().pinkColor,
            child: IconButton(
              icon: _showDeletedItems
                  ? const Icon(Icons.remove_red_eye_outlined,
                      size: 32, color: Colors.black)
                  : const Icon(Icons.visibility_off_outlined,
                      size: 32, color: Colors.black),
              onPressed: () {
                // refresh list
                refresh();

                setState(() {
                  _showDeletedItems = !_showDeletedItems;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadPantryItems(int location) async {
    // declare pantry items for all tabs
    _allPantryItems = await BackendUtils.getAllPantry();

    // declare pantry items for selected tab where isDeleted ==
    _activePantryItems = _allPantryItems
        .where(
            (item) => item.storageLocation == location && item.isDeleted == 0)
        .toList();

    // declare pantry items for selected tab
    _allPantryItems = _allPantryItems
        .where((item) => item.storageLocation == location)
        .toList();
  }

  Widget _listActiveItems() {
    return Center(
      child: _buildPantryList(_activePantryItems),
    );
  }

  Widget _listAllItems() {
    return Center(
      child: _buildPantryList(_allPantryItems),
    );
  }

  Widget _buildPantryList(List<Pantry> pantryItems) {
    return pantryItems.isEmpty
        ? Center(
            child: Text(
              _currentTab == 1
                  ? 'No items in your Pantry'
                  : _currentTab == 2
                      ? 'No items in your Fridge'
                      : 'No items in your Freezer',
              style: const TextStyle(fontSize: 20),
            ),
          )
        : Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: pantryItems.length,
              itemBuilder: (BuildContext context, int index) {
                Pantry item = pantryItems[index];
                return _showDeletedItems
                    ? ProductWidget(
                        pantryItem: item,
                        enableCheckbox: true,
                        refreshPantryList: refresh,
                      )
                    : item.isDeleted == 1
                        ? Container()
                        : SizedBox(
                            child: ProductWidget(
                              pantryItem: item,
                              enableCheckbox: true,
                              refreshPantryList: refresh,
                            ),
                          );
              },
            ),
          );
  }

  Widget _buildAddButton() {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.only(right: 15),
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          backgroundColor: MyTheme().blueColor,
          onPressed: () {
            // show edit widget
            showDialog(
                context: context,
                builder: (context) {
                  return EditWidget(
                    pantryItem: Pantry(),
                    updateProductWidget: () {},
                    refreshPantryList: refresh,
                    callingWidget: widget,
                  );
                });
          },
          elevation: 0,
          child: const Icon(
            Icons.add,
            size: 35.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
