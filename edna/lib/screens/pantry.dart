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
import 'package:edna/dbs/pantry_db.dart';
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
          _buildPantryList(),
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
      // eye button
      Padding(
        padding: const EdgeInsets.only(right: 30),
        child: IconButton(
          icon: _showDeletedItems
              ? const Icon(
                  Icons.visibility_off,
                  size: 40,
                  color: Color.fromARGB(255, 139, 14, 14),
                )
              : const Icon(
                  Icons.remove_red_eye,
                  size: 40,
                  color: Color.fromARGB(255, 139, 14, 14),
                ),
          onPressed: () {
            setState(() {
              _showDeletedItems = !_showDeletedItems;
            });
            if (_showDeletedItems) {
              PantryDatabase.instance.getAllPantry();
            } else {
              PantryDatabase.instance.getActivePantry();
            }
          },
        ),
      ),
    ]);
  }

  Center _buildPantryList() {
    return Center(
      child: FutureBuilder<List<Pantry>>(
        future: PantryDatabase.instance.getActivePantry(),
        builder: (BuildContext context, AsyncSnapshot<List<Pantry>> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return snapshot.data!.isEmpty
              ? const Center(
                  child: Text('No items in pantry',
                      style: TextStyle(fontSize: 20)))
              : ListView.builder(
                  shrinkWrap: true, // fix sizing
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Pantry item = snapshot.data![index];
                    return Dismissible(
                        key: UniqueKey(),
                        background: Container(color: Colors.red),
                        onDismissed: (direction) {
                          PantryDatabase.instance.delete(item.id!);
                          setState(() {
                            snapshot.data!.removeAt(index);
                          });
                        },
                        child: ProductWidget(
                          pantryItem: item,
                        ));
                  },
                );
        },
      ),
    );
  }

  Container _buildAddButton() {
    return Container(
      padding: const EdgeInsets.only(left: 0, bottom: 20, right: 15, top: 10),
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        onPressed: () async {
          await PantryDatabase.instance.insert(
            Pantry(
              name: 'item_name',
              dateAdded: DateTime.now(),
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
