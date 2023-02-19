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

//ref:
// https://levelup.gitconnected.com/date-picker-in-flutter-ec6080f3508a
// https://stackoverflow.com/questions/59455869/how-to-make-fullscreen-alertdialog-in-flutter

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
    return Container(
        height: // fit to screen height
            MediaQuery.of(context).size.height,
        width: // fit to screen width
            MediaQuery.of(context).size.width,
        child: createNewMessage());
  }

  createNewMessage() {
    return StatefulBuilder(
      builder: (context, setState) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(true);
            },
            child: Material(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNameField(), // name
                    _buildDatePicker(), // date
                    _buildNotesField(), // notes
                    _buildQuantityPicker(), // quantity
                  ],
                ),
              ),
            ));
      },
    );
  }

  // called functions
  _buildNameField() {
    return TextField(
        controller: TextEditingController()..text = widget.pantryItem.name,
        onChanged: (value) {
          widget.pantryItem.name = value;
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

  _buildNotesField() {
    return TextField(
      controller: TextEditingController()..text = widget.notes ?? "Notes",
      onChanged: (value) {
        widget.notes = value;
      },
    );
  }

  _buildCancelButton() {
    return TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        // set is not editing
        widget.isEditing = false;
        Navigator.of(context).pop();
      },
    );
  }

  _buildSaveButton() {
    return TextButton(
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
    );
  }

  _buildQuantityPicker() {
    return Row(children: [
      // quantity
      const Text("Quantity: "),
      // decrement butto
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(// minus circle outline
                  Icons.remove_circle_rounded),
              onPressed: () {
                setState(() {
                  widget.pantryItem.quantity = widget.pantryItem.quantity! - 1;
                });
              },
            ),

            // output quantity
            Text(widget.pantryItem.quantity.toString()),
            // increment button
            IconButton(
              icon: const Icon(Icons.add_circle_rounded),
              onPressed: () {
                setState(() {
                  widget.pantryItem.quantity = widget.pantryItem.quantity! + 1;
                });
              },
            ),
          ],
        ),
      ),
    ]);
  }
}
