/// StorageLocation is used in the pantry_db.dart file to store the storage location of a pantry item.

class StorageLocation {
  final int id;
  final String name;

  // constructor
  const StorageLocation._internal(this.id, this.name);

  // lookup table
  static const StorageLocation fridge = StorageLocation._internal(1, 'fridge');
  static const StorageLocation freezer =
      StorageLocation._internal(2, 'freezer');
  static const StorageLocation pantry = StorageLocation._internal(3, 'pantry');

  // list of all values
  static List<StorageLocation> get values => [fridge, freezer, pantry];

  // lookup by id
  static StorageLocation fromId(int id) {
    return values.firstWhere((location) => location.id == id);
  }
}
