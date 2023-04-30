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
import 'package:edna/dbs/storage_location_db.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart';
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // pantry item widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget
import 'package:edna/provider.dart';
import 'package:provider/provider.dart';

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
    await _loadPantryItems(_currentTab)
        .then((value) => setState(() {}), onError: (e) => print("error: $e"));
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: 3, vsync: this);
  //   _currentTab = _tabController.index + 1;
  //   _showDeletedItems = false;
  //   _loadPantryItems(_currentTab);
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController = TabController(length: 3, vsync: this);
    _currentTab = _tabController.index + 1;
    _showDeletedItems = false;
    _loadPantryItems(_currentTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PantryProvider(),
      builder: (context, child) {
        final pantryProvider = Provider.of<PantryProvider>(context);
        if (pantryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: MyTheme().pinkColor,
                tabs: const [
                  Tab(
                      child: Text('Pantry',
                          style: TextStyle(color: Colors.black))),
                  Tab(
                      child: Text('Fridge',
                          style: TextStyle(color: Colors.black))),
                  Tab(
                      child: Text('Freezer',
                          style: TextStyle(color: Colors.black))),
                ],
                onTap: (index) {
                  setState(() {
                    _currentTab = index + 1;
                  });
                  _loadPantryItems(_currentTab);
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
                Expanded(
                  flex: 1,
                  child: _buildHeader(),
                ),
                Expanded(
                  flex: 8,
                  child:
                      _showDeletedItems ? _listAllItems() : _listActiveItems(),
                ),
                _buildAddButton(),
              ],
            ),
          );
        }
      },
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

                _loadPantryItems(_currentTab);
              },
            ),
          ),
        ),
      ],
    );
  }

  _loadPantryItems(int location) async {
    // ignore: use_build_context_synchronously
    final pantryProvider = Provider.of<PantryProvider>(context, listen: false);
    //mounting catch

    await BackendUtils.getAllPantry().then((value) {
      allPantryItems = value;

      // only get pantry items for current location
      allPantryItems = allPantryItems
          .where((item) =>
              item.storageLocation == location && item.isVisibleInPantry == 1)
          .toList();

      pantryProvider.setAllPantryItems(allPantryItems);

      // only get active pantry items for current location
      activePantryItems = allPantryItems
          .where((item) =>
              item.storageLocation == location &&
              item.isDeleted == 0 &&
              item.isVisibleInPantry == 1)
          .toList();

      pantryProvider.setActivePantryItems(activePantryItems);

      _showDeletedItems ? _listAllItems() : _listActiveItems();

      setState(() {});
    }, onError: (e) => print("error: $e"));
  }

  Widget _listActiveItems() {
    return Center(
      child: _buildPantryList(activePantryItems),
    );
  }

  Widget _listAllItems() {
    return Center(
      child: _buildPantryList(allPantryItems),
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
                        callingWidget: widget,
                      )
                    : item.isDeleted == 1
                        ? Container()
                        : SizedBox(
                            child: ProductWidget(
                              pantryItem: item,
                              enableCheckbox: true,
                              refreshPantryList: refresh,
                              callingWidget: widget,
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
          elevation: 3,
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
