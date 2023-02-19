// ref: https://www.youtube.com/watch?v=noi6aYsP7Go
import 'dart:io'; // Directory
import 'dart:async';
import 'package:sqflite/sqflite.dart'; // sqlflite
import 'package:path/path.dart'; // join
import 'package:path_provider/path_provider.dart'; // commonly used paths, // getApplicationDocumentsDirectory

class Pantry {
  final int? id;
  String name;
  final DateTime? dateAdded;
  DateTime? dateRemoved;
  DateTime? expirationDate;
  int? quantity;
  final int? upc;
  final int? plu;
  int? storageLocation;
  int? isDeleted;

  Pantry({
    this.id,
    required this.name,
    this.dateAdded,
    this.dateRemoved,
    this.expirationDate,
    this.quantity = 1,
    this.upc,
    this.plu,
    this.storageLocation,
    this.isDeleted = 0,
  });

  factory Pantry.fromMap(Map<String, dynamic> json) => Pantry(
      id: json["id"],
      name: json["name"],
      dateAdded:
          json["dateAdded"] == null ? null : DateTime.parse(json["dateAdded"]),
      dateRemoved: json["dateRemoved"] == null
          ? null
          : DateTime.parse(json["dateRemoved"]),
      expirationDate: json["expirationDate"] == null
          ? null
          : DateTime.parse(json["expirationDate"]),
      quantity: json["quantity"],
      upc: json["upc"],
      plu: json["plu"],
      storageLocation: json["storageLocation"],
      isDeleted: json["isDeleted"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "dateAdded": dateAdded == null ? null : dateAdded!.toIso8601String(),
        "dateRemoved":
            dateRemoved == null ? null : dateRemoved!.toIso8601String(),
        "expirationDate":
            expirationDate == null ? null : expirationDate!.toIso8601String(),
        "quantity": quantity,
        "upc": upc,
        "plu": plu,
        "storageLocation": storageLocation,
        "isDeleted": isDeleted,
      };
}

class PantryDatabase {
  PantryDatabase._privateConstructor();
  static final PantryDatabase instance = PantryDatabase._privateConstructor();

  static Database? _database;
  // init database if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // init database
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "pantry.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // create database
  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE pantry (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      dateAdded TEXT,
      dateRemoved TEXT,
      expirationDate TEXT,
      upc INTEGER,
      plu INTEGER,
      storageLocation INTEGER,
      isDeleted INTEGER
    )''');
  }

  // get all pantry items
  Future<List<Pantry>> getAllPantry() async {
    Database db = await instance.database;
    var items = await db.query("pantry", orderBy: "expirationDate DESC");
    // note: sqlite considers NULL to be smaller than any other value, so nulls will show at the bottom of the list
    List<Pantry> pantryList =
        items.isNotEmpty ? items.map((c) => Pantry.fromMap(c)).toList() : [];
    return pantryList;
  }

  // get all pantry items where isDeleted is 0
  Future<List<Pantry>> getActivePantry() async {
    Database db = await instance.database;
    var items = await db.query("pantry",
        where: "isDeleted = 0", orderBy: "dateAdded DESC");
    List<Pantry> pantryList =
        items.isNotEmpty ? items.map((c) => Pantry.fromMap(c)).toList() : [];
    return pantryList;
  }

  // add pantry item
  Future<int> insert(Pantry pantry) async {
    Database db = await instance.database;
    return await db.insert("pantry", pantry.toMap());
  }

  // delete pantry item
  // Future<int> delete(int id) async {
  //   Database db = await instance.database;
  //   return await db.delete("pantry", where: "id = ?", whereArgs: [id]);
  // }

  // set isDeleted to true
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.update("pantry", {"isDeleted": 1},
        where: "id = ?", whereArgs: [id]);
  }

  // undo delete
  Future<int> undoDelete(int id) async {
    Database db = await instance.database;
    return await db.update("pantry", {"isDeleted": 0},
        where: "id = ?", whereArgs: [id]);
  }

  // update pantry item
  Future<int> update(Pantry pantry) async {
    Database db = await instance.database;
    return await db.update("pantry", pantry.toMap(),
        where: "id = ?", whereArgs: [pantry.id]);
  }

  // drop database
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "pantry.db");
    databaseFactory.deleteDatabase(path);
  }
}
