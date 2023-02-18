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

main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PantryPage());
}

class PantryPage extends StatefulWidget {
  const PantryPage({super.key});

  @override
  PantryPageState createState() => PantryPageState();
}

int count = 0;

class PantryPageState extends State<PantryPage> {
  // color theme
  MyTheme myTheme = const MyTheme();
  late MaterialColor myBlue =
      myTheme.createMaterialColor(const Color(0xFF69B9BB));

  bool _showDeletedItems = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pantry Page',
        theme: ThemeData(
          primarySwatch: myBlue,
          textTheme:
              GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
        ),
        home: SafeArea(
            child: Scaffold(
                body: Column(children: [
          _buildHeader(),
          // make scrollable
          Expanded(
              child: _showDeletedItems ? _listAllItems() : _listActiveItems()),
          _buildAddButton()
        ]))));
  }

  Row _buildHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 15, top: 15),
        child: Text('Pantry',
            style: GoogleFonts.notoSerif(fontSize: 35, color: Colors.black)),
      ),
      // delete database button for debugging
      IconButton(
        icon: const Icon(
          Icons.delete_forever,
          size: 40,
        ),
        onPressed: () {
          PantryDatabase.instance.deleteDatabase();
        },
      ),
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

  _listAllItems() {
    return Center(
      child: FutureBuilder<List<Pantry>>(
          future: PantryDatabase.instance.getAllPantry(),
          builder: _buildPantryList()!),
    );
  }

  _listActiveItems() {
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
                    ? ProductWidget(pantryItem: item)
                    : item.isDeleted == 1
                        ? Container() // return dialog box instead ?
                        : ProductWidget(pantryItem: item);
              },
            );
    };
  }

  Container _buildAddButton() {
    return Container(
      padding: const EdgeInsets.only(left: 0, bottom: 20, right: 15, top: 10),
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        onPressed: () async {
          count++;
          await PantryDatabase.instance.insert(
            Pantry(
              name: "#$count",
              dateAdded: DateTime.now(),
              isDeleted: 0,
            ),
          );
          // refresh list
          setState(() {});
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
