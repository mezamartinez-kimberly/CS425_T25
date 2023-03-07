/* This file contains the Pantry class, which is used to store the information of a pantry item. 

==============================
*    Title: pantry_item.dart
*    Author: Julian Fliegler
*    Date: March 2023
==============================
*/

import 'package:intl/intl.dart'; // DateFormat

class Pantry {
  // pantry item fields
  final int? id;
  String? name;
  DateTime? dateAdded;
  DateTime? dateRemoved;
  DateTime? expirationDate;
  int? quantity;
  String? upc;
  String? plu;
  int? storageLocation;
  int? isDeleted;

  // constructor to create new pantry item
  Pantry({
    this.id,
    this.name,
    this.dateAdded,
    this.dateRemoved,
    this.expirationDate,
    this.quantity = 1,
    this.upc,
    this.plu,
    this.storageLocation,
    this.isDeleted = 0,
  });

  // factory constructor to create pantry item from map
  factory Pantry.fromMap(Map<String, dynamic> json) => Pantry(
        id: json["id"],
        name: json["name"],
        dateAdded: json["date_added"] == null
            ? null
            : DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US')
                .parse(json["date_added"]),
        dateRemoved: json["date_removed"] == null
            ? null
            : DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US')
                .parse(json["date_removed"]),
        expirationDate: json["expiration_date"] == null
            ? null
            : DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'', 'en_US')
                .parse(json["expiration_date"]),
        quantity: json["quantity"],
        upc: json["upc"],
        plu: json["plu"],
        storageLocation: json["location"],
        isDeleted: json["is_deleted"],
      );

  // convert pantry item to map
  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "date_added": dateAdded == null ? null : dateAdded!.toIso8601String(),
        "date_removed":
            dateRemoved == null ? null : dateRemoved!.toIso8601String(),
        "expiration_date":
            expirationDate == null ? null : expirationDate!.toIso8601String(),
        "quantity": quantity,
        "upc": upc,
        "plu": plu,
        "location": storageLocation,
        "is_deleted": isDeleted,
      };
}
