import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/widgets/edit_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductWidget extends StatefulWidget {
  @override
  _ProductWidgetState createState() => _ProductWidgetState();

  final Pantry pantryItem;
  int quantity;
  bool isEditing;
  bool enableCheckbox;
  String? notes;

  // constructor
  ProductWidget({
    Key? key,
    required this.pantryItem,
    this.quantity = 1,
    this.isEditing = false,
    this.enableCheckbox = true, // enabled by default
    this.notes,
  }) : super(key: key);
}

class _ProductWidgetState extends State<ProductWidget> {
  bool _isChecked = false;
  final EditWidget editWidget = EditWidget();

  @override
  Widget build(BuildContext context) {
    // if item deleted, remove
    return widget.pantryItem.isDeleted! == 1
        ? FutureBuilder(
            future: Future.delayed(
                // wait 400 ms before deleting
                const Duration(milliseconds: 400)),
            builder: (context, snapshot) {
              // while waiting, return product widget
              return _buildItemContainer();
            })
        // if not deleted, create the product widget
        : _buildItemContainer();
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
        child: ListTile(
            leading: _buildCheckBox(widget.enableCheckbox),
            title: Text(widget.pantryItem.name,
                style: TextStyle(
                    // if deleted, strikethrough text
                    decoration: widget.pantryItem.isDeleted! == 1
                        ? TextDecoration.lineThrough
                        : TextDecoration.none)),
            subtitle: Text(_formatDate()),
            trailing: _buildEditButton()),
      ),
    );
  }

  Widget _buildEditButton() {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        widget.isEditing = true; // is editing
        // display dialog box
        editWidget.buildEdit(widget, context);
      },
    );
  }

  Widget _buildCheckBox(bool enableCheckbox) {
    // if pantry item is deleted, keep box checked
    if (widget.pantryItem.isDeleted! == 1) {
      _isChecked = true;
    } else {
      _isChecked = false;
    }
    return enableCheckbox
        ? // if checkmark is enabled, show checkmark
        Container(
            child: Checkbox(
            value: _isChecked, // unchecked by default
            onChanged: widget.pantryItem.isDeleted! == 1
                // if isDeleted is true and user clicks on checkbox, change checkbox to unchecked, "undelete" item
                ? (bool? value) {
                    setState(() {
                      _isChecked = false;
                      widget.pantryItem.isDeleted = 0;
                      PantryDatabase.instance.undoDelete(widget.pantryItem.id!);
                    });
                  }
                :
                // if isDeleted is not true and user clicks on checkbox, check box and delete item
                (bool? value) {
                    setState(() {
                      _isChecked = true;
                      widget.pantryItem.isDeleted = 1;
                      PantryDatabase.instance.delete(widget.pantryItem.id!);
                    });
                  },
          ))
        : // if checkmark disabled, return empty container
        Container();
  }

  String _formatDate() {
    // format date
    DateTime? date = widget.pantryItem.expirationDate;
    if (date != null) {
      return "Expires: ${DateFormat.yMMMEd().format(date)}";
    } else {
      return "No Expiration Date";
    }
  }
}
