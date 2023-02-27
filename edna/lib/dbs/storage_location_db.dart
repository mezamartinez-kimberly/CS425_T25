// StorageLocation is used in the pantry_db.dart file to store the storage location of a pantry item.

class StorageLocation {
  final int id;
  final String name;

  // constructor
  const StorageLocation(this.id, this.name);
  //const StorageLocation._internal(this.id, this.name);

  // lookup table
  static const StorageLocation fridge = StorageLocation(0, 'Pantry');
  static const StorageLocation freezer = StorageLocation(1, 'Fridge');
  static const StorageLocation pantry = StorageLocation(2, 'Freezer');

  // list of all values
  static List<StorageLocation> get values => [fridge, freezer, pantry];

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
}
