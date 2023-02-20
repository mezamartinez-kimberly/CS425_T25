import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/screens/all.dart';
import 'package:edna/widgets/product_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
// https://api.flutter.dev/flutter/material/ToggleButtons-class.html

class EditWidget extends StatefulWidget {
  @override
  _EditWidgetState createState() => _EditWidgetState();

  final Pantry pantryItem;
  Widget? callingWidget;
  String? notes;
  bool isEditing;
  final Function()? updateProductWidget;
  final Function()? refreshPantryList;
  final Function()? refreshCameraPage;

  // constructor
  EditWidget({
    Key? key,
    required this.pantryItem,
    this.callingWidget,
    this.notes,
    this.isEditing = true,
    this.updateProductWidget,
    this.refreshPantryList,
    this.refreshCameraPage,
  }) : super(key: key);
}

class _EditWidgetState extends State<EditWidget> {
  // for upc/plu input
  final List<bool> _selectedCodeType = <bool>[false, false];
  final List<Widget> codeTypes = <Widget>[const Text('UPC'), const Text('PLU')];

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
  Widget _buildNameField() {
    String initValue = "";
    if (widget.pantryItem.name != "") {
      initValue = widget.pantryItem.name;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: TextFormField(
          initialValue: initValue,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0),
              icon: const Icon(Icons.shopping_cart),
              // only show hint text if name null
              hintText: widget.pantryItem.name == "" ? "Enter Name" : ""),
          onChanged: (value) {
            if (value != "") {
              widget.pantryItem.name = value;
            } else {
              // if user deletes all text
              widget.pantryItem.name = "";
            }
            setState(() {});
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

  Widget _buildNotesField() {
    return TextField(
      //controller: TextEditingController()..text = widget.notes ?? "Notes",
      decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          icon: Icon(Icons.notes),
          hintText: "Enter Notes"),
      onChanged: (value) {
        widget.notes = value;
      },
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      child: const Text('Cancel'),
      onPressed: () {
        // set is not editing
        widget.isEditing = false;
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      child: const Text('Save'),
      onPressed: () async {
        widget.isEditing = false; // is not editing
        // if product widget doesn't exist, create
        print(widget.callingWidget.runtimeType);

        // if user just scanned item
        if (widget.callingWidget.runtimeType == CameraPage) {
          // get calling widget
          CameraPage cameraPage = widget.callingWidget as CameraPage;
          // create new pantry item with user entered values
          Pantry newPantryItem = Pantry(
            name: widget.pantryItem.name,
            expirationDate: widget.pantryItem.expirationDate,
            quantity: widget.pantryItem.quantity,
            dateAdded: DateTime.now(),
            upc: widget.pantryItem.upc,
            plu: widget.pantryItem.plu,
            isDeleted: 0,
          );

          // create product widget with new pantry item
          ProductWidget newProductWidget = ProductWidget(
              pantryItem: newPantryItem,
              enableCheckbox: false,
              // no need to refresh pantry since we're still on camera page
              refreshPantryList: () {});

          // add to scanned list on camera page
          cameraPage.addScannedProduct(newProductWidget);
          // refresh camera page
          widget.refreshCameraPage!();
        }

        // if user is editing pantry item
        if (widget.callingWidget.runtimeType == PantryPage) {
          await PantryDatabase.instance.insert(
            Pantry(
              name: widget.pantryItem.name,
              expirationDate: widget.pantryItem.expirationDate,
              quantity: widget.pantryItem.quantity,
              dateAdded: DateTime.now(),
              upc: widget.pantryItem.upc,
              plu: widget.pantryItem.plu,
              isDeleted: 0,
            ),
          );
          setState(() {}); // refresh list
        }
        // else, update existing
        setState(() {
          // update pantry item with new values
          PantryDatabase.instance.update(widget.pantryItem);
          // update product widget
          widget.updateProductWidget!();
        });
        // refresh pantry list
        widget.refreshPantryList!();
        // close dialog box
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildQuantityPicker() {
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
              child: ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedCodeType.length; i++) {
                      _selectedCodeType[i] = i == index;
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedCodeType,
                children: codeTypes,
              ),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     // upc code button
              //     SizedBox(
              //       width: 150,
              //       child: TextButton(
              //           child: const Text("UPC Code",
              //               style: TextStyle(fontSize: 20)),
              //           onPressed: () {
              //             setState(() {
              //               showUPC = true;
              //               showPLU = false;
              //             });
              //           }),
              //     ),
              //     // plu code button
              //     SizedBox(
              //       width: 150,
              //       child: TextButton(
              //         child: const Text("PLU Code",
              //             style: TextStyle(fontSize: 20)),
              //         onPressed: () {
              //           setState(() {
              //             showUPC = false;
              //             showPLU = true;
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),
            ),
            SizedBox(
              height: 50,
              width: 180,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: (_selectedCodeType[0]) // if upc code is selected
                      ? _takeUPCInput()
                      : _takePLUInput()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _takeUPCInput() {
    setState(() {});
    String initValue = "";
    if (widget.pantryItem.upc != null) {
      initValue = widget.pantryItem.upc.toString();
    }
    return TextFormField(
      initialValue: initValue,
      onChanged: (value) {
        if (value != "") {
          widget.pantryItem.upc = int.parse(value);
        } else {
          // if user deletes all text
          widget.pantryItem.upc = null;
        }
        setState(() {});
      },
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          // only show hint text if upc null
          hintText: widget.pantryItem.upc == null ? "Enter UPC Code" : ""),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // only allow nums
        LengthLimitingTextInputFormatter(12) // 12 digits
      ],
    );
  }

  Widget _takePLUInput() {
    String initValue = "";
    if (widget.pantryItem.plu != null) {
      initValue = widget.pantryItem.plu.toString();
    }
    return TextFormField(
      initialValue: initValue,
      onChanged: (value) {
        if (value != "") {
          widget.pantryItem.plu = int.parse(value);
        } else {
          // if user deletes all text
          widget.pantryItem.plu = null;
        }
        setState(() {});
      },
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          // only show hint text if upc null
          hintText: widget.pantryItem.upc == null ? "Enter PLU Code" : ""),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly, // only allow nums
        LengthLimitingTextInputFormatter(4) // 4 digits
      ],
    );
  }
}
