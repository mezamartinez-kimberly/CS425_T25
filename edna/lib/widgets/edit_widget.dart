import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class EditWidget extends StatefulWidget {
//   const EditWidget({super.key});

//   @override
//   _EditWidgetState createState() => _EditWidgetState();

//   // _buildEditDialogBox(ProductWidget productWidget, BuildContext context) {}

//   // void buildEdit(ProductWidget widget, BuildContext context) {
//   //   _buildEditDialogBox(widget, context);
//   // }
// }

//ref: https://levelup.gitconnected.com/date-picker-in-flutter-ec6080f3508a

class EditWidget extends StatefulWidget {
  @override
  _EditWidgetState createState() => _EditWidgetState();

  final Pantry pantryItem;
  String? notes;
  bool isEditing;

  // constructor
  EditWidget({
    Key? key,
    required this.pantryItem,
    this.notes,
    this.isEditing = true,
  }) : super(key: key);
}

class _EditWidgetState extends State<EditWidget> {
  @override
  Widget build(BuildContext context) {
    print("here");
    return Scaffold(body: Container(child: _buildEdit()));
  }

  // dialog box
  _buildEdit() {
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
                    ..text = widget.pantryItem.name,
                  onChanged: (value) {
                    widget.pantryItem.name = value;
                  },
                ),
                // expiration date
                _buildDatePicker(),

                // notes
                TextField(
                  controller: TextEditingController()
                    ..text = widget.notes ?? "Notes",
                  onChanged: (value) {
                    widget.notes = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  // set is not editing
                  widget.isEditing = false;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  // is not editing
                  widget.isEditing = false;
                  // update pantry item

                  PantryDatabase.instance.update(widget.pantryItem);
                  // re-set state
                  setState(() {});
                  // close dialog box
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _buildDatePicker() {
    TextEditingController dateController = TextEditingController();

    return TextField(
        controller: dateController, //editing controller of this TextField
        decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today), //icon of text field
            labelText: "Enter Date" //label text of field
            ),
        readOnly: true, // when true user cannot edit text
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            //get the picked date in the format => 2022-07-04 00:00:00.000
            String formattedDate = DateFormat('yyyy-MM-dd').format(
                pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
            //formatted date output using intl package =>  2022-07-04
            //You can format date as per your need

            setState(() {
              dateController.text =
                  formattedDate; //set foratted date to TextField value.
            });

            widget.pantryItem.expirationDate = pickedDate;
            PantryDatabase.instance.update(widget.pantryItem);
          } else {
            throw Exception('Date is not selected');
          }
        });
  }
}
