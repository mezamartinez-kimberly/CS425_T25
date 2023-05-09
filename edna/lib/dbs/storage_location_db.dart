/* 
==============================
*    Title: storage_location.dart
*    Author: Julian Fliegler
*    Date: May 2023
==============================
*/

import 'package:edna/screens/all.dart';
import 'package:flutter/material.dart';

class StorageLocation {
  final int id;
  final String name;
  final Icon icon;

  // constructor
  const StorageLocation(this.id, this.name, this.icon);
  //const StorageLocation._internal(this.id, this.name);

  // lookup table
  static StorageLocation fridge = StorageLocation(
      1, 'Pantry', Icon(Icons.shelves, color: MyTheme().orangeColor));
  static StorageLocation freezer = StorageLocation(
      2, 'Fridge', Icon(Icons.kitchen_outlined, color: MyTheme().greenColor));
  static StorageLocation pantry = StorageLocation(
      3, 'Freezer', Icon(Icons.ac_unit, color: MyTheme().blueColor));

  // list of all values
  static List<StorageLocation> get values => [pantry, fridge, freezer];

  // lookup by id
  static StorageLocation fromId(int id) {
    return values.firstWhere((location) => location.id == id);
  }

  // lookup name by id
  static String nameFromId(int id) {
    return fromId(id).name;
  }

  // lookup id by name
  static int idFromName(String name) {
    return values.firstWhere((location) => location.name == name).id;
  }

  // lookup icon by id
  static Icon iconFromId(int id) {
    return fromId(id).icon;
  }
}
