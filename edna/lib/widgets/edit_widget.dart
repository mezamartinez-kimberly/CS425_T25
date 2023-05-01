//ref:
// https://levelup.gitconnected.com/date-picker-in-flutter-ec6080f3508a
// https://stackoverflow.com/questions/59455869/how-to-make-fullscreen-alertdialog-in-flutter
// https://stackoverflow.com/questions/48481590/how-to-set-update-state-of-statefulwidget-from-other-statefulwidget-in-flutter
// https://stackoverflow.com/questions/70927812/flutter-textfield-should-open-when-button-is-pressed
// https://api.flutter.dev/flutter/material/ToggleButtons-class.html

// ignore_for_file: avoid_print

import 'package:edna/backend_utils.dart';
import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/dbs/storage_location_db.dart';
import 'package:edna/main.dart';
import 'package:edna/screens/all.dart';
import 'package:edna/widgets/product_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // material design
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // json

class EditWidget extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EditWidgetState createState() => _EditWidgetState();

  final Pantry pantryItem;
  Widget? callingWidget;
  String? notes;
  final Function()? updateProductWidget;
  final Function()? refreshPantryList;
  final Function()? refreshCameraPage;

  // constructor
  EditWidget({
    Key? key,
    required this.pantryItem,
    this.callingWidget,
    this.notes,
    this.updateProductWidget,
    this.refreshPantryList,
    this.refreshCameraPage,
  }) : super(key: key);
}

class _EditWidgetState extends State<EditWidget> {
  // for upc/plu input
  final List<bool> _selectedCodeType = <bool>[false, false];
  final List<Widget> codeTypes = <Widget>[const Text('UPC'), const Text('PLU')];
  // for exp date
  TextEditingController dateController = TextEditingController();
  // for errors
  var errorText = const Color.fromARGB(255, 88, 15, 15);
  var errorBackground = const Color.fromARGB(255, 238, 37, 37);

  // init state
  @override
  void initState() {
    super.initState();
    // set initial values for code type
    // if pantry item has upc/plu, show in text field
    if (widget.pantryItem.upc != null) {
      _selectedCodeType[0] = true;
    } else if (widget.pantryItem.plu != null) {
      _selectedCodeType[1] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(child: createEditDialog());
  }

  createEditDialog() {
    return StatefulBuilder(
      builder: (context, setState) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.center,
            scrollable: true,
            content: SingleChildScrollView(
              // padding around content in dialog
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10), // spacing
                    _buildNameField(), // name

                    const SizedBox(height: 25), // spacing
                    _buildDatePicker(), // date

                    const SizedBox(height: 25),
                    _buildStorageDropdown(), // storage location

                    const SizedBox(height: 25),
                    const Text("Manual Code Entry"),
                    const SizedBox(height: 5),
                    _buildCodeInput(), // upc/plu code

                    const SizedBox(height: 25),
                    const Text("Quantity"),
                    _buildQuantityPicker(), // quantity
                  ],
                ),
              ),
            ),
            actions: [
              _buildCancelButton(),
              const SizedBox(), // spacing
              _buildSaveButton(),
              const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  // called functions
  Widget _buildNameField() {
    String? initValue = "";
    if (widget.pantryItem.name != "" || widget.pantryItem.name != null) {
      initValue = widget.pantryItem.name;
    }
    return TextFormField(
        initialValue: initValue,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          labelText: "Food Name",
          suffixIcon: Icon(Icons.shopping_cart),
          // icon: const Icon(Icons.shopping_cart),
          // only show hint text if name null
          // hintText: widget.pantryItem.name == "" ? "Enter Name" : ""
        ),
        onChanged: (value) {
          if (value != "") {
            widget.pantryItem.name = value;
          } else {
            // if user deletes all text
            widget.pantryItem.name = "";
          }
          setState(() {});
        });
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
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 13),
            labelText: "Expiration Date",
            suffixIcon: Icon(Icons.calendar_today),
            hintText: "Enter Expiration Date"),
        readOnly: true, // text cannot be modified by keyboard
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2023), // no dates before 2023
            lastDate: DateTime(2101),
            helpText: "Select Expiration Date",
            errorInvalidText: "Invalid Date",
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: MyTheme()
                        .pinkColor, // calendar header background color, button text color
                    onPrimary: Colors.black, // calendar header text color
                    onSurface: Colors.black, // calendar day text color
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white, // button color
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

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
          icon: Icon(Icons.notes), hintText: "Enter Notes"),
      onChanged: (value) {
        widget.notes = value;
      },
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      child: const Text('Cancel',
          style: TextStyle(fontSize: 20, color: Colors.black)),
      onPressed: () {
        // set is not editing
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      child: const Text('Save',
          style: TextStyle(fontSize: 20, color: Colors.black)),
      onPressed: () async {
        if (!mounted) {
          return;
        }

        // if user creating item on camera page, add to camera's list
        if (widget.callingWidget.runtimeType == CameraPage) {
          CameraPage cameraPage = widget.callingWidget as CameraPage;

          // create new pantry item with user entered values
          Pantry newPantryItem = Pantry(
            name: widget.pantryItem.name,
            expirationDate: widget.pantryItem.expirationDate,
            quantity: widget.pantryItem.quantity,
            dateAdded: DateTime.now(),
            upc: widget.pantryItem.upc,
            plu: widget.pantryItem.plu,
            storageLocation: widget.pantryItem.storageLocation,
            isDeleted: 0,
            isVisibleInPantry: 0,
          );

          // store upc and plu codes to add to pantry item once we get name
          // since pantry items in backend only have product id, not actual codes
          var tempCodes = [widget.pantryItem.upc, widget.pantryItem.plu];

          // add to pantry
          await BackendUtils.addPantry(newPantryItem).then((value) async {
            // error check
            if (value.statusCode != 200 && value.statusCode != 201) {
              checkErrors(value, context);
            } else {
              // get the json response from the backend
              dynamic jsonResponse = json.decode(value.body);
              Pantry pantryItem = Pantry.fromMap(jsonResponse);
              pantryItem.upc = tempCodes[0];
              pantryItem.plu = tempCodes[1];

              //  create product widget with new pantry item
              ProductWidget newProductWidget = ProductWidget(
                pantryItem: pantryItem,
                enableCheckbox: false,
                // no need to refresh pantry since we're still on camera page
                refreshPantryList: () {},
                callingWidget: widget,
              );

              // add to camera page's list of items
              cameraPage.addItem(newProductWidget);
              // refresh camera page
              widget.refreshCameraPage!();
            }
          }).onError((error, stackTrace) => const MyApp().createErrorMessage(
              context, "Error adding item to pantry: $error"));
        }

        // if user is creating widget on pantry page, add product to pantry
        if (widget.callingWidget.runtimeType == PantryPage) {
          // add to pantry
          await BackendUtils.addPantry(Pantry(
            name: widget.pantryItem.name,
            expirationDate: widget.pantryItem.expirationDate,
            quantity: widget.pantryItem.quantity,
            dateAdded: DateTime.now(),
            upc: widget.pantryItem.upc,
            plu: widget.pantryItem.plu,
            isDeleted: 0,
            isVisibleInPantry: 1,
          )).then((value) async {
            // error check
            if (value.statusCode != 200 && value.statusCode != 201) {
              checkErrors(value, context);
            }
          }).onError((error, stackTrace) => const MyApp().createErrorMessage(
              context, "Error adding item to pantry: $error"));

          // refresh pantry list
          widget.refreshPantryList!();
        }

        // else if user is editing a product widget that already exists
        else if (widget.callingWidget.runtimeType == ProductWidget) {
          // get access to the product widget that is parent of edit widget
          ProductWidget productWidget = widget.callingWidget as ProductWidget;
          Widget productWidgetParent = productWidget.callingWidget;

          // if user is editing a product widget on camera page
          // save changes to backend

          if (productWidgetParent.runtimeType == CameraPage ||
              productWidgetParent.runtimeType == EditWidget) {
            // update local pantry item with new values
            await BackendUtils.updatePantryItem(widget.pantryItem);

            // update product widget
            widget.updateProductWidget!();
          }

          // if user is editing a product widget on shelf or calendar
          // then the item is already in the database
          // so update the item in the databaseelse
          else if (productWidgetParent.runtimeType == PantryPage ||
              productWidgetParent.runtimeType == CalendarClass) {
            // update pantry item in db with new values
            await BackendUtils.updatePantryItem(widget.pantryItem)
                .then((value) async {
              // error check
              if (value.statusCode != 200 && value.statusCode != 201) {
                checkErrors(value, context);
              }
            }).onError((error, stackTrace) =>
                    const MyApp().createErrorMessage(context, "Error: $error"));
            // update product widget
            widget.updateProductWidget!();

            if (productWidgetParent.runtimeType == PantryPage) {
              // refresh pantry list
              widget.refreshPantryList!();
            }
          }
        } else {
          print("Error in EditWidget._buildSaveButton");
        }

        // close dialog
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      },
    );
  }

  checkErrors(value, context) {
    // if no upc/plu code, show error
    if (widget.pantryItem.upc == null && widget.pantryItem.plu == null) {
      const MyApp()
          .createErrorMessage(context, "Please enter a UPC or PLU code.");
      return;
    }
    // if upc is not 12 digits, show error
    else if (widget.pantryItem.upc != null &&
        widget.pantryItem.upc!.length != 12) {
      const MyApp().createErrorMessage(context, "UPC code must be 12 digits.");
      return;
    }

    // if plu is not 4 digits, show error
    else if (widget.pantryItem.plu != null &&
        widget.pantryItem.plu!.length != 4) {
      const MyApp().createErrorMessage(context, "PLU code must be 4 digits.");
      return;
    } else if (value.statusCode == 400 || value.statusCode == 404) {
      const MyApp().createErrorMessage(
          context, "Error ${value.statusCode}: Item not found.");
      return;
    } else {
      // general error
      const MyApp().createErrorMessage(
          context, "Error ${value.statusCode}: ${value.reasonPhrase}");
    }
  }

  Widget _buildQuantityPicker() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // round card surrounding quantity picker
      Card(
        color: MyTheme().pinkColor, // temp color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          // black border
          side: const BorderSide(color: Color.fromARGB(104, 4, 4, 4), width: 1),
        ),
        child: SizedBox(
          width: 240,
          // height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // decrement button
              IconButton(
                icon: const Icon(Icons.remove_circle_rounded),
                onPressed: () {
                  setState(() {
                    if (widget.pantryItem.quantity! > 1) {
                      // cannot have quantity = 0
                      widget.pantryItem.quantity =
                          widget.pantryItem.quantity! - 1;
                    }
                  });
                },
              ),

              // output quantity
              Text(widget.pantryItem.quantity.toString(),
                  style: const TextStyle(fontSize: 20)),
              // increment button
              IconButton(
                icon: const Icon(Icons.add_circle_rounded),
                onPressed: () {
                  setState(() {
                    widget.pantryItem.quantity =
                        widget.pantryItem.quantity! + 1;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildCodeInput() {
    Color borderColor = const Color.fromARGB(255, 34, 34, 34);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          // upc and plu buttons
          child: ToggleButtons(
            borderColor: borderColor,
            selectedBorderColor: borderColor,
            textStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w400), // button text size
            fillColor: MyTheme().pinkColor,
            selectedColor: const Color.fromARGB(255, 0, 0, 0), // black text
            direction: Axis.horizontal,
            onPressed: (int index) {
              setState(() {
                // The button that is tapped is set to true, and the others to false.
                for (int i = 0; i < _selectedCodeType.length; i++) {
                  _selectedCodeType[i] = i == index;
                }
              });
            },
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            constraints: const BoxConstraints(
              // button sizes
              minHeight: 45.0,
              minWidth: 125.0,
            ),
            isSelected: _selectedCodeType,
            children: codeTypes,
          ),
        ),
        const SizedBox(height: 10), //spacing
        // text field for code input
        SizedBox(
          // resize text field
          child: (_selectedCodeType[0]) // if upc code is selected
              ? _takeUPCInput()
              : _takePLUInput(),
        ),
      ],
    );
  }

  Widget _takeUPCInput() {
    TextEditingController controller = TextEditingController();
    if (widget.pantryItem.upc != null) {
      controller.text = widget.pantryItem.upc.toString();
    }
    return TextField(
      style: const TextStyle(fontSize: 20),
      textAlign: TextAlign.center,
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        suffixIcon: Icon(CupertinoIcons.barcode_viewfinder),
        contentPadding: EdgeInsets.all(15),
        labelText: "UPC Code",
        // only show hint text if upc null
        //hintText: widget.pantryItem.upc == null ? "Enter UPC Code" : ""
      ),
      onChanged: (value) {
        if (value != "") {
          widget.pantryItem.upc =
              value.length <= 12 ? value : widget.pantryItem.upc;
        } else {
          // if user deletes all text
          widget.pantryItem.upc = null;
        }
      },
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // only allow nums
        LengthLimitingTextInputFormatter(12) // 12 digits
      ],
    );
  }

  Widget _takePLUInput() {
    TextEditingController controller = TextEditingController();
    if (widget.pantryItem.plu != null) {
      controller.text = widget.pantryItem.plu.toString();
    }
    return TextField(
      onChanged: (value) {
        if (value != "") {
          widget.pantryItem.plu =
              value.length <= 4 ? value : widget.pantryItem.plu;
        } else {
          // if user deletes all text
          widget.pantryItem.plu = null;
        }
      },
      style: const TextStyle(fontSize: 20),
      textAlign: TextAlign.center,
      controller: controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        suffixIcon: Icon(CupertinoIcons.barcode_viewfinder),
        contentPadding: EdgeInsets.all(15),
        labelText: "PLU Code",
        // only show hint text if upc null
        // hintText: widget.pantryItem.plu == null ? "Enter PLU Code" : ""
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // only allow nums
        LengthLimitingTextInputFormatter(4) // 4 digits
      ],
    );
  }

  Widget _buildStorageDropdown() {
    // get storage location, if null, set to "pantry" (default)
    int storageLocation = widget.pantryItem.storageLocation ??=
        StorageLocation.idFromName("Pantry");

    // get list of storage locations as dropdown menu items
    List<DropdownMenuItem<String>> locationsList = StorageLocation.values
        .map<DropdownMenuItem<String>>((StorageLocation location) {
      return DropdownMenuItem<String>(
        value: location.name,
        child: Text(location.name),
      );
    }).toList();

    // find current storage location in dropdown menu list
    DropdownMenuItem<String> dropdownValue = locationsList.firstWhere(
        (element) =>
            element.value == StorageLocation.nameFromId(storageLocation));

    // drop down displaying storage options
    return DropdownButtonFormField<String>(
      alignment: Alignment.center,
      value: dropdownValue.value,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      isDense: true,
      style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
      onChanged: (String? newValue) {
        setState(() {
          widget.pantryItem.storageLocation =
              StorageLocation.idFromName(newValue!);
        });
      },
      items: locationsList,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      decoration: const InputDecoration(
        labelText: "Storage Location",
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
        ),
      ),
    );
  }
}
