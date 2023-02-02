import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Food {
  final int id;
  final String name;
  final String foodGroup;
  final DateTime expirationDate;

  const Food({
    required this.id,
    required this.name,
    required this.foodGroup,
    required this.expirationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'foodGroup': foodGroup,
      'expirationDate': expirationDate.millisecondsSinceEpoch,
    };
  }

  // factory constructor that converts a map to an instance of Food class
  // it extracts the values from the map and initializes the class with them
  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      foodGroup: map['foodGroup'],
      expirationDate:
          DateTime.fromMillisecondsSinceEpoch(map['expirationDate']),
    );
  }

  @override
  String toString() {
    return 'Food{id: $id, name: $name, foodGroup: $foodGroup, expirationDate: $expirationDate}';
  }
}

// Citation:
// https://docs.flutter.dev/cookbook/persistence/sqlite
void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'food_database.db'),
    // When the database is first created, create a table to store dogs.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE Food (id INTEGER PRIMARY KEY, name TEXT, foodGroup TEXT, expirationDate INTEGER)',
      );
    },
    // Set the version. This executes the onCreate function and provides a
    // path to perform database upgrades and downgrades.
    version: 1,
  );

  // This should return the ID of the Food once its inserted
  Future<int> insertFood(Food food) async {
    final db = await database;
    return db.insert('Food', food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Food> getFood(int id) async {
    final db = await database;
    final result = await db.query('Food', where: 'id = ?', whereArgs: [id]);
    return Future.value(result.isNotEmpty ? Food.fromMap(result[0]) : null);
  }

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Food');
    return List.generate(maps.length, (i) => Food.fromMap(maps[i]));
  }

  Future<int> updateFood(Food food) async {
    final db = await database;
    return db
        .update('Food', food.toMap(), where: 'id = ?', whereArgs: [food.id]);
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return db.delete('Food', where: 'id = ?', whereArgs: [id]);
  }

  // create a default food object
  Food apple = Food(
    id: 0,
    name: 'Apple',
    foodGroup: 'Fruit',
    expirationDate: DateTime.now(),
  );

  // insert a food object into the database
  await insertFood(apple);

  print(await getAllFoods());
}
