import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/widgets/edit_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat
import 'package:edna/backend_utils.dart';
import 'package:edna/screens/camera.dart';

class ProductWidget extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  ProductWidgetState createState() => ProductWidgetState();

  final Pantry pantryItem;
  bool enableCheckbox;
  final Function()? refreshPantryList;
  Widget callingWidget;

  // constructor
  ProductWidget({
    Key? key,
    required this.pantryItem,
    this.enableCheckbox = false, // enabled by default
    this.refreshPantryList,
    required this.callingWidget,
  }) : super(key: key);
}

class ProductWidgetState extends State<ProductWidget> {
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
  }

  refresh() {
    setState(() {});
  }

  // update product widget values
  void updateProductWidget(Pantry pantryItem) {
    setState(() {
      widget.pantryItem.name = pantryItem.name;
      widget.pantryItem.quantity = pantryItem.quantity;
      widget.pantryItem.expirationDate = pantryItem.expirationDate;
      widget.pantryItem.isDeleted = pantryItem.isDeleted;
      widget.pantryItem.dateAdded = pantryItem.dateAdded;
      widget.pantryItem.dateRemoved = pantryItem.dateRemoved;
      widget.pantryItem.upc = pantryItem.upc;
      widget.pantryItem.plu = pantryItem.plu;
      widget.pantryItem.storageLocation = pantryItem.storageLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if item deleted, remove
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildItemContainer(),
        ],
      ),
    );
  }

  Widget _buildItemContainer() {
    return Dismissible(
        key: UniqueKey(),
        // make the background red with a delete icon
        background: Container(
          color: const Color.fromARGB(255, 255, 68, 54),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ),
        onDismissed: (direction) {
          // if deleted, remove from list
          BackendUtils.deletePantryItem(widget.pantryItem);

          // if the calling widget is the CamerPage then access its removeitem function
          if (widget.callingWidget is CameraPage) {
            (widget.callingWidget as CameraPage).removeItem(widget);
          }
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Card(
              // outline
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              elevation: 5.0, // shadow
              // size of product widgets
              child: SizedBox(
                height: 70,
                width: 400,
                child: ListView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // disable scroll within individual cards
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: _buildCheckBox(widget.enableCheckbox),
                      title:
                          // if name is null or empty, show "No name"
                          Expanded(
                        child: widget.pantryItem.name == "" ||
                                widget.pantryItem.name == null
                            ? const Text("No name",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                ))
                            // otherwise, show name
                            : Text(
                                widget.pantryItem.name as String,
                                maxLines: 2,
                                style: TextStyle(
                                    // if deleted, strikethrough text
                                    decoration:
                                        widget.pantryItem.isDeleted! == 1
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none),
                              ),
                      ),
                      subtitle: _formatDate(),
                      trailing: SizedBox(
                          width: 73,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  // show quantity
                                  "(x${widget.pantryItem.quantity})",
                                  // make text smaller and gray
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: _buildEditButton(),
                              ),
                              // spacer
                            ],
                          )),
                    );
                  },
                ),
              ),
            )));
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return EditWidget(
                pantryItem: widget.pantryItem,
                callingWidget: widget,
                updateProductWidget: refresh,
                refreshPantryList: widget.refreshPantryList,
              );
            });
      },
    );
  }

  Widget _buildCheckBox(bool enableCheckbox) {
    // if pantry item is deleted, keep box checked
    widget.pantryItem.isDeleted == 1 ? _isChecked = true : _isChecked = false;
    return enableCheckbox
        ? // if checkmark is enabled, show checkmark
        Checkbox(
            value: _isChecked, // unchecked by default
            onChanged: widget.pantryItem.isDeleted! == 1
                // if isDeleted is true and user clicks on checkbox, change checkbox to unchecked, ie "undelete" item
                ? (bool? value) async {
                    _isChecked = false;
                    widget.pantryItem.isDeleted = 0;
                    // refresh the pantry item in the backend
                    await BackendUtils.updatePantryItem(widget.pantryItem)
                        .then((value) => widget.refreshPantryList!());
                    setState(() {});
                  }
                :
                // if isDeleted is not true and user clicks on checkbox, check box and delete item
                (bool? value) {
                    _isChecked = true;
                    widget.pantryItem.isDeleted = 1;
                    BackendUtils.updatePantryItem(widget.pantryItem);
                    // ask user if item is expired or not
                    _showIsExpiredDialog();
                    setState(() {});
                  },
          )
        : // if checkmark disabled, return empty container
        const SizedBox();
  }

  _showIsExpiredDialog() {
    // ask user if item is expired or not
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            //round the corners
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text("Is this item expired?"),
            actions: [
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop();

                  // set the date removed to now
                  widget.pantryItem.dateRemoved = DateTime.now();

                  // cell function to update this in the backend
                  BackendUtils.updatePantryItem(widget.pantryItem);

                  // wait 0.4 sec before deleting on page
                  Future.delayed(const Duration(milliseconds: 400), () {
                    widget.refreshPantryList!();
                  });
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();

                  // call the backend untils function to increment the points counter
                  BackendUtils.addPoints();

                  // wait 0.4 sec before deleting on page
                  Future.delayed(const Duration(milliseconds: 400), () {
                    widget.refreshPantryList!();
                  });
                },
              ),
            ],
          );
        });
  }

  Widget _formatDate() {
    // format date
    DateTime? date = widget.pantryItem.expirationDate;
    if (date != null) {
      return Text("Expires: ${DateFormat.MMMEd().format(date)}");
    } else {
      // return const Text("No expiration date",
      //     style: TextStyle(
      //       fontStyle: FontStyle.italic,
      //     ));
      // default expiration date is 7 days from current day
      return Text(
          "Expires: ${DateFormat.MMMEd().format(DateTime.now().add(const Duration(days: 7)))}");
    }
  }
}
