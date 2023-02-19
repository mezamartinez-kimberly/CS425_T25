import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/widgets/edit_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // DateFormat

class ProductWidget extends StatefulWidget {
  @override
  _ProductWidgetState createState() => _ProductWidgetState();

  final Pantry pantryItem;
  int quantity;
  bool enableCheckbox;
  final Function()? refreshPantryList;

  // constructor
  ProductWidget({
    Key? key,
    required this.pantryItem,
    this.quantity = 1,
    this.enableCheckbox = false, // enabled by default
    this.refreshPantryList,
  }) : super(key: key);
}

class _ProductWidgetState extends State<ProductWidget> {
  bool _isChecked = false;
  bool _isEditing = false;

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
    //  return Dismissible(
    //                 key: UniqueKey(),
    //                 background: Container(color: Colors.red),
    //                 onDismissed: (direction) {
    //                   PantryDatabase.instance.delete(item.id!);
    //                   setState(() {

    //                     // snapshot.data!.removeAt(index);
    //                   });
    //                 },
    //                 child:
    return Padding(
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
                  title: Text(widget.pantryItem.name,
                      style: TextStyle(
                          // if deleted, strikethrough text
                          decoration: widget.pantryItem.isDeleted! == 1
                              ? TextDecoration.lineThrough
                              : TextDecoration.none)),
                  subtitle: Text(_formatDate()),
                  trailing: _buildEditButton(),
                );
              },
            ),
          ),
        ));
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        _isEditing = true;
        showDialog(
            context: context,
            builder: (context) {
              return EditWidget(
                pantryItem: widget.pantryItem,
                updateProductWidget: refresh,
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
                // if isDeleted is true and user clicks on checkbox, change checkbox to unchecked, "undelete" item
                ? (bool? value) {
                    setState(() {
                      _isChecked = false;
                      widget.pantryItem.isDeleted = 0;
                      PantryDatabase.instance.undoDelete(widget.pantryItem.id!);
                      widget.refreshPantryList!();
                    });
                  }
                :
                // if isDeleted is not true and user clicks on checkbox, check box and delete item
                (bool? value) {
                    setState(() {
                      _isChecked = true;
                      widget.pantryItem.isDeleted = 1;
                      PantryDatabase.instance.delete(widget.pantryItem.id!);
                      widget.refreshPantryList!();
                    });
                  },
          )
        : // if checkmark disabled, return empty container
        const SizedBox();
  }

  String _formatDate() {
    // format date
    DateTime? date = widget.pantryItem.expirationDate;
    if (date != null) {
      return "Expires: ${DateFormat.MMMEd().format(date)}";
    } else {
      return "No Expiration Date";
    }
  }
}
