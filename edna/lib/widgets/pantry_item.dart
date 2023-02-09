import 'package:edna/dbs/pantry_db.dart';
import 'package:flutter/material.dart';

class PantryItem extends StatefulWidget {
  @override
  _PantryItemState createState() => _PantryItemState();

  final Pantry pantryItem;
  bool isEditing;
  bool enableCheckbox;
  String? notes;
  bool? isDeleted;

  // constructor
  PantryItem({
    Key? key,
    required this.pantryItem,
    this.isEditing = false,
    this.enableCheckbox = true, // enabled by default
    this.notes,
    this.isDeleted = false,
  }) : super(key: key);
}

class _PantryItemState extends State<PantryItem> {
  bool _isChecked = false;

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
              // if done, return empty container
              return Container();
            })
        : _buildItemContainer();
  }

  ListTile _buildItemContainer() {
    return ListTile(
        leading: _buildCheckBox(widget.enableCheckbox),
        title: Text(widget.pantryItem.name,
            style: TextStyle(
                // if deleted, strikethrough text
                decoration: widget.isDeleted!
                    ? TextDecoration.lineThrough
                    : TextDecoration.none)),
        // subtitle: Text(widget.pantryItem.expirationDate),
        trailing: _buildEditButton());
  }

  IconButton _buildEditButton() {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        widget.isEditing = true; // is editing
        // display dialog box
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Edit Item'),
                content: TextField(
                  controller: TextEditingController()
                    ..text = widget.pantryItem.name,
                  onChanged: (value) {
                    widget.pantryItem.name = value;
                  },
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      // is not editing
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
                      // close dialog box
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
    );
  }

  Container _buildCheckBox(bool enableCheckbox) {
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
}
