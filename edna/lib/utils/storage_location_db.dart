// StorageLocation is used in the pantry_item.dart file to store the storage location of a pantry item.

class StorageLocation {
  final int id;
  final String name;

  // constructor
  const StorageLocation(this.id, this.name);

  // lookup table
  static const StorageLocation fridge = StorageLocation(1, 'Pantry');
  static const StorageLocation freezer = StorageLocation(2, 'Fridge');
  static const StorageLocation pantry = StorageLocation(3, 'Freezer');

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
}
