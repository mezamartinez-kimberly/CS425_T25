/* 
==============================
*    Title: camera_test.dart
*    Author: Julian Fliegler
*    Date: Feb 2023
==============================
*/

// import 'package:test/test.dart';                        // test package
// import 'package:edna/screens/camera.dart';              // camera page
// import 'package:qr_code_scanner/qr_code_scanner.dart';  // barcode scanner
// import 'package:edna/widgets/product_widget.dart';      // product widget

// void main() {
//   test('Test widget creation', () async {
//     // assert that camera page is not null
//     expect(CameraPage(), isNotNull);
//     // get access to camera page stateful widget
//     CameraPageState cameraPageState = CameraPageState();

//     // create test barcode object
//     Barcode? testBarcode = Barcode(
//         '096619295203', BarcodeFormat.upcA, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
//     // assert that barcode is created successfully
//     expect(testBarcode, isNotNull);

//     // get product name from barcode
//     String productName = await cameraPageState.getProductName(testBarcode);
//     // assert that product name retrieved successfully
//     expect(productName, isNotNull);

//     // create product widget from barcode and product name
//     ProductWidget productWidget =
//         cameraPageState.createProductWidget(testBarcode, productName);
//     // assert that widget is not null
//     expect(productWidget, isNotNull);

//     // print all properties of object stored in product widget
//     ProductWidgetState().printProductWidget(productWidget);
//   });
// }
