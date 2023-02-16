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
  bool? isDeleted;

  // constructor
  ProductWidget({
    Key? key,
    required this.pantryItem,
    this.quantity = 1,
    this.isEditing = false,
    this.enableCheckbox = true, // enabled by default
    this.notes,
    this.isDeleted = false,
  }) : super(key: key);
}

class _ProductWidgetState extends State<ProductWidget> {
  bool _isChecked = false;
  final EditWidget editWidget = EditWidget();

  @override
  Widget build(BuildContext context) {
    // if item deleted, remove
    return widget.isDeleted!
        ? FutureBuilder(
            future: Future.delayed(
                // wait 0.3 seconds
                const Duration(milliseconds: 400)),
            builder: (context, snapshot) {
              // if waiting
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildItemContainer();
              }
              // if done, delete item and empty container
              int? itemID = widget.pantryItem.id;
              if (itemID != null) {
                PantryDatabase.instance.delete(itemID);
              } else {
                // throw exception
                throw Exception("Error: pantry item ID is null");
              }
              return Container();
            })
        : _buildItemContainer();
  }

  Widget _buildItemContainer() {
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
                    decoration: widget.isDeleted!
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
    return enableCheckbox
        ? // if checkmark is enabled, show checkmark
        Container(
            child: Checkbox(
            value: _isChecked, // unchecked by default
            onChanged:
                // if checked, delete from pantry
                (bool? value) {
              setState(() {
                _isChecked = value!;
                widget.isDeleted = true;
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
