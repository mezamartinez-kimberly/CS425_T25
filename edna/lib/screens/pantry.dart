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

class PantryPageState extends State<PantryPage> {
  late bool _showDeletedItems;
  List<Pantry> _activePantryItems = [];
  List<Pantry> _allPantryItems = [];

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
    _showDeletedItems = false;
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
                  child: FutureBuilder(
                future: _loadPantryItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return _showDeletedItems
                        ? _listAllItems()
                        : _listActiveItems();
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )),
              _buildAddButton(),
            ]),
          ),
        ));
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, bottom: 15, top: 15),
        ),
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
                //     _showDeletedItems ? _listAllItems() : _listActiveItems();
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _loadPantryItems() async {
    _allPantryItems = await BackendUtils.getAllPantry();
    _activePantryItems =
        _allPantryItems.where((item) => item.isDeleted == 0).toList();
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
        ? const Center(
            child: Text('No items in pantry', style: TextStyle(fontSize: 20)))
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
                            height: item.isDeleted == 1 ? 0.0 : null,
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
                  callingWidget: widget,
                );
              });
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
