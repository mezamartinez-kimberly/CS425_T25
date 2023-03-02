import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:edna/screens/camera.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // barcode scanner

void main() {
  test('Test widget creation', () async {
    // assert that camera page is not null
    expect(CameraPage(), isNotNull);

    CameraPage cameraPage = CameraPage();
    CameraPageState cameraPageState = CameraPageState();

    // create barcode result
    Barcode? testBarcode = Barcode(
        '096619295203', BarcodeFormat.upcA, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
    // assert that barcode is created successfully
    expect(testBarcode, isNotNull);

    var productName = await cameraPageState.getProductName(testBarcode);
    // .then((productName) => print("Product name: $productName"));
    expect(productName, isNotNull);
    //print(productName);
    //
    // expect(productName, isNotNull);
    // print(productName);
    // cameraPageState.addItemToList();

    // } else if (snapshot.data == 'UPC not found') {
    //   print("UPC ${result!.code} not found");
    // } else {
    // if UPC found, add product to camera page's list of items

    // list should have 1 item
    //expect(cameraPage.itemsToInsert, 1);

    // assert that the UPC code is the same as the one added to the list
    // expect(cameraPage.itemsToInsert![0].pantryItem.upc, result.code);
  });
  // test('Test widget creation', () async {

  // });
}
