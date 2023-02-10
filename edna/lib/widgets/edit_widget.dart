import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/widgets/product_widget.dart';
import 'package:flutter/material.dart';

// class EditWidget extends StatefulWidget {
//   const EditWidget({super.key});

//   @override
//   _EditWidgetState createState() => _EditWidgetState();

//   // _buildEditDialogBox(ProductWidget productWidget, BuildContext context) {}

//   // void buildEdit(ProductWidget widget, BuildContext context) {
//   //   _buildEditDialogBox(widget, context);
//   // }
// }

class EditWidget {
  // dialog box
  buildEdit(ProductWidget productWidget, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Item'),
            content: Column(
              children: [
                // name
                TextField(
                  controller: TextEditingController()
                    ..text = productWidget.pantryItem.name,
                  onChanged: (value) {
                    productWidget.pantryItem.name = value;
                  },
                ),
                // notes
                TextField(
                  controller: TextEditingController()
                    ..text = productWidget.notes ?? "Notes",
                  onChanged: (value) {
                    productWidget.notes = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  // set is not editing
                  productWidget.isEditing = false;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  // is not editing
                  productWidget.isEditing = false;
                  // update pantry item
                  PantryDatabase.instance.update(productWidget.pantryItem);
                  // re-set state
                  //  setState(() {});
                  // close dialog box
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Container();
  // }
}
