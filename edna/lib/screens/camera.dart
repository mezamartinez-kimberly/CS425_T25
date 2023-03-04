// /*
// ==============================
// *    Title: camera.dart
// *    Author: Julian Fliegler
// *    Date: Dec 2022
// ==============================
// */

// /* Referenced code:
//  - https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
// - https://stackoverflow.com/questions/65992435/how-to-open-barcode-scanner-in-a-custom-widget
// */

import 'dart:developer'; // for debugPrint
import 'dart:io'; // for Platform

import 'package:edna/main.dart'; // for main
import 'package:edna/screens/all.dart'; // for pantry page
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // for material design
import 'package:qr_code_scanner/qr_code_scanner.dart'; // barcode scanner
import 'package:edna/backend_utils.dart'; // for API calls
import 'package:google_fonts/google_fonts.dart'; // for fonts

import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // product widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget

// ignore: must_be_immutable
class CameraPage extends StatefulWidget {
  List<ProductWidget>? itemsToInsert;
  addItem(ProductWidget product) {
    itemsToInsert ??= []; // initialize if null
    itemsToInsert?.add(product);
  }

  CameraPage({Key? key, this.itemsToInsert}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String productName = '';
  bool _flashOn = false;

  bool itemAdded = false; // flag to check if item was just added to pantry

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: MyTheme().blueColor,
        // accent color
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: MyTheme().blueColor),
      ),
      home: DefaultTextStyle(
        style: TextStyle(
            color: Colors.black, fontFamily: GoogleFonts.roboto().fontFamily),
        child: Column(
          children: <Widget>[
            // scan area
            Expanded(flex: 4, child: _buildQrView(context)),
            // toolbar
            Expanded(
                flex: 1,
                child: Container(
                    color: Colors.black,
                    // rounded corners
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 201, 201, 201),
                              // black line at bottom of toolbar
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: _buildToolbar())))),
            // items list
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    FutureBuilder(
                        // get product name from UPC code
                        future: _getProductName(),
                        builder: (context, snapshot) {
                          // while not scanning, or if waiting for flag to reset
                          // return empty container
                          if (result == null ||
                              snapshot.data == "resetting flag") {
                            return Container();
                          }
                          // while waiting for API call to UPC db to complete, show loading indicator
                          if (snapshot.data == null) {
                            return const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator());
                            // if error, show error message
                          } else if (snapshot.hasError) {
                            return const MyApp().createErrorMessage(
                                context, 'Error: ${snapshot.error}');
                            // if UPC not found, show error message
                          } else if (snapshot.data == 'UPC not found') {
                            return const MyApp().createErrorMessage(
                                context, "UPC ${result!.code} not found");
                            // if UPC found, add product to camera page's list of items
                          } else {
                            _addItemToList();

                            // return empty container so return value is a widget
                            return Container();
                          }
                        }),
                    _buildItemList(),
                  ],
                ),
              ),
            ),

            // buttons
            Padding(
              padding: const EdgeInsets.only(right: 5.0, bottom: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _buildManualButton(),
                  const SizedBox(width: 5), // spacing
                  _buildSubmitButton(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // define style of manual and submit buttons
  buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      backgroundColor: MyTheme().pinkColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      // black border
      side: const BorderSide(color: Colors.black, width: 1),
    );
  }

  Widget _buildManualButton() {
    return ElevatedButton.icon(
      style: buttonStyle(),
      onPressed: () {
        // show edit widget
        showDialog(
            context: context,
            builder: (context) {
              return EditWidget(
                pantryItem: Pantry(
                  id: 401, // id should be static var incremented each time?
                  name: "",
                ),
                callingWidget: widget,
                updateProductWidget: () {},
                refreshPantryList: () {},
                // on camera page, so only need refresh function for camera page
                refreshCameraPage: refresh,
              );
            });
      },
      icon: const Icon(Icons.add),
      label: const Text(
        "Manual",
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      style: buttonStyle(),
      onPressed: () async {
        // insert scanned items into pantry database
        if (widget.itemsToInsert != null) {
          for (ProductWidget product in widget.itemsToInsert!) {
            // add to pantry db
            var backendResult =
                await BackendUtils.addPantry(product.pantryItem);

            if (!mounted) return;

            print(backendResult);

            // if success do nothing else show error with the name and allow the user to edit it
            if (backendResult.statusCode != 200 &&
                backendResult.statusCode != 201) {
              const MyApp().createErrorMessage(context,
                  "Error ${backendResult.statusCode}: ${backendResult.body}");
              print(backendResult.body);
            } else {
              // const MyApp()
              //     .createSuccessMessage(context, "Item added to pantry");
            }
          }
          // show loading indicator for 0.5 sec
          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              builder: (context) {
                // wait 0.5 sec
                Future.delayed(const Duration(milliseconds: 500), () {
                  // clear scanned list
                  widget.itemsToInsert!.clear();
                  // refresh page
                  refresh(); // resets state
                  // close dialog
                  Navigator.of(context).pop(true);
                });
                return const Center(
                  child: CircularProgressIndicator(),
                );
              });
        }
      },
      icon: const Icon(Icons.check),
      label: const Text(
        'Submit',
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        const Spacer(
          flex: 10,
        ),
        const Text(
          'Add items',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(
          flex: 2,
        ),
        _buildFlashButton(),
        _buildCameraToggleButton(),
        const Spacer(
          flex: 1,
        ),
      ],
    );
  }

  Widget _buildScanInstructions() {
    return const Padding(
      // spacing between card edges and page edges
      padding: EdgeInsets.all(30),
      child: Expanded(
        child: Padding(
          // spacing between card edges and text
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Text('Scan or manually enter an item.',
              textAlign: TextAlign.center,
              // text size
              style: TextStyle(fontSize: 35)),
        ),
      ),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: MyTheme().blueColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  // private
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _buildFlashButton() {
    return IconButton(
      icon: _flashOn
          ? const Icon(
              Icons.flash_on,
              size: 40,
            )
          : const Icon(
              Icons.flash_off,
              size: 40,
            ),
      onPressed: () async {
        await controller?.toggleFlash();
        setState(() {
          _flashOn = !_flashOn;
        });
        FutureBuilder(
          future: controller?.getFlashStatus(),
          builder: (context, snapshot) {
            return Text('Flash: ${snapshot.data}');
          },
        );
      },
    );
  }

  Widget _buildCameraToggleButton() {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: IconButton(
        icon: const Icon(
          Icons.flip_camera_ios,
          size: 40,
        ),
        onPressed: () async {
          await controller?.flipCamera();
          setState(() {});
          FutureBuilder(
            future: controller?.getCameraInfo(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Text('Camera facing ${describeEnum(snapshot.data!)}');
              } else {
                return const Text('loading');
              }
            },
          );
        },
      ),
    );
  }

  // for debugging
  void printYellow(String text) {
    print('\x1B[33m$text\x1B[0m');
  }

  Future<String> name = Future.value("");
  Function get onError => // print error message
      (error) => printYellow("error = $error");

  // private class method
  _getProductName() async {
    // if successfully scanned
    if (result != null) {
      // if code can be found in UPC database
      if (result!.format == BarcodeFormat.ean13 ||
          result!.format == BarcodeFormat.ean8 ||
          result!.format == BarcodeFormat.upcA ||
          result!.format == BarcodeFormat.upcE) {
        return productName =
            await BackendUtils.getUpcData(result!.code as String);
      }
    }
  }

  _addItemToList() {
    // itemAdded is used to prevent items from being added multiple times
    if (!itemAdded) {
      // convert upc code to int
      //  int upc = int.parse(result!.code as String);

      // create new pantry item with values
      Pantry newPantryItem = Pantry(
        name: productName,
        dateAdded: DateTime.now(),
        upc: result!.code,
        isDeleted: 0,
      );

      // create product widget with new pantry item
      ProductWidget newProductWidget = ProductWidget(
          key: UniqueKey(),
          pantryItem: newPantryItem,
          enableCheckbox: false,
          // no need to refresh pantry since we're on camera page
          refreshPantryList: () {});

      // add to camera page's list of items
      widget.addItem(newProductWidget);
      // toggle itemAdded so item doesn't duplicate
      itemAdded = true;
    } else {
      // wait 5 seconds before user can scan another item
      // this way item doesn't duplicate over and over
      Future.delayed(const Duration(seconds: 5), () {
        itemAdded = false;
      });
    }
  }

  _buildItemList() {
    // if there are items to insert, return list of items
    return widget.itemsToInsert != null
        ? Expanded(
            child: ListView.builder(
            shrinkWrap: true, // prevents overflow
            itemCount: widget.itemsToInsert?.length,
            itemBuilder: (context, index) {
              return widget.itemsToInsert![index];
            },
          ))
        : Container();
  }
}
