import 'package:flutter/material.dart';
import 'package:edna/dbs/pantry_db.dart';

class PantryProvider with ChangeNotifier {
  List<Pantry> _activePantryItems = [];
  List<Pantry> _allPantryItems = [];
  List<Pantry> _allPantryAllLocations = [];

  List<Pantry> get activePantryItems => _activePantryItems;
  List<Pantry> get allPantryItems => _allPantryItems;
  List<Pantry> get allPantryAllLocations => _allPantryAllLocations;

  void setActivePantryItems(List<Pantry> pantryItems) {
    _activePantryItems = pantryItems;
    notifyListeners();
  }

  void setAllPantryItems(List<Pantry> pantryItems) {
    _allPantryItems = pantryItems;
    notifyListeners();
  }

  void setAllAnyLocation(List<Pantry> pantryItems) {
    _allPantryAllLocations = pantryItems;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoaded() {
    _isLoading = false;
    notifyListeners();
  }
}
