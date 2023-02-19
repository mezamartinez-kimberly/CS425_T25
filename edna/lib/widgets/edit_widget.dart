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
// https://stackoverflow.com/questions/70927812/flutter-textfield-should-open-when-button-is-pressed

class EditWidget extends StatefulWidget {
  @override
  _EditWidgetState createState() => _EditWidgetState();

  final Pantry pantryItem;
  String? notes;
  bool isEditing;
  final Function() updateProductWidget;
  final Function()? refreshPantryList;

  // constructor
  EditWidget({
    Key? key,
    required this.pantryItem,
    this.notes,
    this.isEditing = true,
    required this.updateProductWidget,
    this.refreshPantryList,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNameField(), // name
                    _buildDatePicker(), // date
                    _buildQuantityPicker(), // quantity
                    // _buildNotesField(), // notes

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
            ));
      },
    );
  }

  // called functions
  _buildNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: TextField(
          controller: TextEditingController()..text = widget.pantryItem.name,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(0),
              icon: Icon(Icons.shopping_cart),
              hintText: "Enter Name"),
          onChanged: (value) {
            widget.pantryItem.name = value;
          }),
    );
  }

  Widget _buildDatePicker() {
    // if already has expiration date, show in text field
    if (widget.pantryItem.expirationDate != null) {
      String formattedDate =
          DateFormat('MM/dd/yyyy').format(widget.pantryItem.expirationDate!);
      dateController.text = formattedDate;
    }

    return TextField(
        controller: dateController,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0),
            icon: Icon(Icons.calendar_today),
            hintText: "Enter Date"),
        readOnly: true, // text cannot be modified by keyboard
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2023), // no dates before 2023
              lastDate: DateTime(2101));

          // update text field to picked date
          if (pickedDate != null) {
            String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
            setState(() {
              dateController.text = formattedDate;
            });
            widget.pantryItem.expirationDate = pickedDate;
          }
        });
  }

  _buildNotesField() {
    return TextField(
      controller: TextEditingController()..text = widget.notes ?? "Notes",
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          icon: Icon(Icons.notes),
          hintText: "Enter Notes"),
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
      onPressed: () async {
        widget.isEditing = false; // is not editing
        // if product widget doesn't exist, create
        if (await PantryDatabase.instance.checkIfExists(widget.pantryItem) ==
            false) {
          await PantryDatabase.instance.insert(
            Pantry(
              name: widget.pantryItem.name,
              expirationDate: widget.pantryItem.expirationDate,
              quantity: widget.pantryItem.quantity,
              dateAdded: DateTime.now(),
              isDeleted: 0,
            ),
          );
          setState(() {}); // refresh list
        }
        // else, update existing widget and item
        else {
          setState(() {
            // update pantry item with new values
            PantryDatabase.instance.update(widget.pantryItem);
            // update product widget
            widget.updateProductWidget();
          });
        }
        // refresh pantry list
        widget.refreshPantryList!();
        // close dialog box
        Navigator.of(context).pop();
      },
    );
  }

  _buildQuantityPicker() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // const Text("Quantity: ", style: TextStyle(fontSize: 20)),
      Card(
        elevation: 5,
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
    bool showUPC = false;
    bool showPLU = false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // upc code button
                  SizedBox(
                    width: 150,
                    child: TextButton(
                        child: const Text("UPC Code",
                            style: TextStyle(fontSize: 20)),
                        onPressed: () {
                          setState(() {
                            showUPC = true;
                            showPLU = false;
                          });
                        }),
                  ),
                  // plu code button
                  SizedBox(
                    width: 150,
                    child: TextButton(
                      child: const Text("PLU Code",
                          style: TextStyle(fontSize: 20)),
                      onPressed: () {
                        setState(() {
                          showUPC = false;
                          showPLU = true;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              width: 180,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _takeUPCInput() // right now just takes UPC input

                  // showUPC
                  //     ? _takeUPCInput()
                  //     : showPLU
                  //         ? _takePLUInput()
                  //         : Container(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _takeUPCInput() {
    return TextField(
      onChanged: (value) {
        widget.pantryItem.upc = int.parse(value);
      },
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0), hintText: "Enter UPC Code"),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // only allow nums
        LengthLimitingTextInputFormatter(12) // 12 digits
      ],
    );
  }

  Widget _takePLUInput() {
    return TextField(
      onChanged: (value) {
        widget.pantryItem.plu = int.parse(value);
      },
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0), hintText: "Enter PLU Code"),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // only allow nums
        LengthLimitingTextInputFormatter(4) // 4 digits
      ],
    );
  }
}
