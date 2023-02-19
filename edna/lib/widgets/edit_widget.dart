import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // input formatter

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
// https://stackoverflow.com/questions/48481590/how-to-set-update-state-of-statefulwidget-from-other-statefulwidget-in-flutter

class EditWidget extends StatefulWidget {
  @override
  _EditWidgetState createState() => _EditWidgetState();

  final Pantry pantryItem;
  String? notes;
  bool isEditing;
  final Function() updateProductWidget;

  // constructor
  EditWidget({
    Key? key,
    required this.pantryItem,
    this.notes,
    this.isEditing = true,
    required this.updateProductWidget,
  }) : super(key: key);
}

class _EditWidgetState extends State<EditWidget> {
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNameField(), // name
                      _buildDatePicker(), // date
                      _buildQuantityPicker(), // quantity
                      _buildNotesField(), // notes
                      _buildCodeInput(), // upc/plu code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildCancelButton(), // cancel
                          _buildSaveButton(), // save
                        ],
                      )
                    ],
                  ),
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
            String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
            setState(() {
              dateController.text = formattedDate;
            });
            widget.pantryItem.expirationDate = pickedDate;
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
        setState(() {
          // update pantry item with new values
          PantryDatabase.instance.update(widget.pantryItem);
          // update product widget
          widget.updateProductWidget();
        });
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

  Widget _buildCodeInput() {
    bool _showUPC = false;
    bool _showPLU = false;

    // select between option A and option B
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // option A
              // text button reading "Enter UPC Code"
              TextButton(
                  child: const Text("UPC Code"),
                  onPressed: () {
                    setState(() {
                      _showUPC = true;
                      _showPLU = false;
                      // _buildUPCInput(_showUPC, _showPLU);
                    });
                  }),

              // text button reading "Enter PLU Code"
              TextButton(
                child: const Text("PLU Code"),
                onPressed: () {},
              ),
            ],
          ),
          TextField(
            textAlign: TextAlign.center,
            //  decoration: const InputDecoration(labelText: "Enter Code"),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // only allow nums
              LengthLimitingTextInputFormatter(4) // only allow 4 nums
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildUPCInput(bool _showUPC, bool _showPLU) {
  //   // display upc input text field
  //   return Visibility(
  //     visible: true,
  //     child:
  //   );
  // }
}
