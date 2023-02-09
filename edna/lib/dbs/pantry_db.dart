// ref: https://www.youtube.com/watch?v=noi6aYsP7Go
import 'dart:io'; // Directory
import 'dart:async';
import 'package:sqflite/sqflite.dart'; // sqlflite
import 'package:path/path.dart'; // join
import 'package:path_provider/path_provider.dart'; // commonly used paths, // getApplicationDocumentsDirectory

class Pantry {
  final int? id;

  // is name final? should user be able to change the name of an item?
  String name;
  final DateTime? dateAdded;
  final DateTime? dateRemoved;
  final int? upc;
  final int? plu;
  final int? storageLocation;
  // i think we should have separate exp date field

  Pantry({
    this.id,
    required this.name,
    this.dateAdded,
    this.dateRemoved,
    this.upc,
    this.plu,
    this.storageLocation,
  });

  factory Pantry.fromMap(Map<String, dynamic> json) => Pantry(
      id: json["id"],
      name: json["name"],
      dateAdded:
          json["dateAdded"] == null ? null : DateTime.parse(json["dateAdded"]),
      dateRemoved: json["dateRemoved"] == null
          ? null
          : DateTime.parse(json["dateRemoved"]),
      upc: json["upc"],
      plu: json["plu"],
      storageLocation: json["storageLocation"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "dateAdded": dateAdded == null ? null : dateAdded!.toIso8601String(),
        "dateRemoved":
            dateRemoved == null ? null : dateRemoved!.toIso8601String(),
        "upc": upc,
        "plu": plu,
        "storageLocation": storageLocation,
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
      upc INTEGER,
      plu INTEGER,
      storageLocation INTEGER
    )''');
  }

  // get all pantry items
  Future<List<Pantry>> getAllPantry() async {
    Database db = await instance.database;
    var items = await db.query("pantry", orderBy: "dateAdded DESC");
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
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete("pantry", where: "id = ?", whereArgs: [id]);
  }

  // update pantry item
  Future<int> update(Pantry pantry) async {
    Database db = await instance.database;
    return await db.update("pantry", pantry.toMap(),
        where: "id = ?", whereArgs: [pantry.id]);
  }
}
