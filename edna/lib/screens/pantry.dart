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
import 'package:edna/utils/pantry_db.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(PantryPage());
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
  // for editing items
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pantry Page',
        theme: ThemeData(
          primarySwatch: Colors.red,
          textTheme:
              GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
        ),
        home: SafeArea(
            child: Scaffold(
                body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text('Pantry',
                style:
                    GoogleFonts.notoSerif(fontSize: 35, color: Colors.black)),
          ),
          Center(
            child: FutureBuilder<List<Pantry>>(
              future: PantryDatabase.instance.getAllPantry(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Pantry>> snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return snapshot.data!.isEmpty
                    ? const Center(
                        child: Text('No items in pantry',
                            style: TextStyle(fontSize: 20)))
                    : ListView.builder(
                        shrinkWrap: true,
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
                            child: ListTile(
                              onTap: // update item
                                  // todo: open edit item page
                                  () {
                                setState(() {
                                  selectedId = item.id;
                                });
                              },
                              onLongPress: // delete item
                                  () {
                                PantryDatabase.instance.delete(item.id!);
                                setState(() {
                                  snapshot.data!.removeAt(index);
                                });
                              },
                              title: Text(item.name),
                              //subtitle: Text(expirationDate),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 0, bottom: 20, right: 5, top: 10),
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () async {
                selectedId != null
                    ? await PantryDatabase.instance.update(
                        Pantry(id: selectedId, name: 'update'),
                      )
                    : await PantryDatabase.instance.insert(
                        Pantry(name: 'test', dateAdded: DateTime.now()),
                      );
                // refresh list
                setState(() {
                  selectedId = null;
                });
              },
              elevation: 2.0,
              child: const Icon(
                Icons.add,
                size: 35.0,
              ),
            ),
          )
        ]))));
  }
}
