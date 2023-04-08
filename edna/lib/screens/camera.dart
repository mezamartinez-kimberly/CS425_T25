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
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'package:loader_overlay/loader_overlay.dart'; // loading wheel

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
  Barcode? lastResult;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String productName = '';
  bool _flashOn = false;

  bool itemAdded = false; // flag to check if item was just added to pantry
  bool firstRun =
      true; // flag to check if this is the first time item is scanned

  List<Pantry> allPantryItems = [];

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
    //BackendUtils.deleteAll(); // debugging
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
                        future: _addToPantry(),
                        builder: (context, snapshot) {
                          if (result == null) {
                            return Container();
                          }
                          if (snapshot.data != null) {
                            if (snapshot.data == 'UPC not found') {
                              return Text("UPC ${result!.code} not found");
                            } else {
                              return FutureBuilder(
                                future: _retreivePantryItems(),
                                builder: (context, snapshot) {
                                  return _buildItemList();
                                },
                              );
                            }
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Container();
                          }
                        }),
                    _buildItemList() // display camera page's list of items
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
                  _buildAddButton(),
                  const SizedBox(width: 10), // spacing
                  _buildSubmitButton(),
                  const SizedBox(width: 5), // spacing
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: FittedBox(
        child: FloatingActionButton(
          heroTag: "add", // need unique tag for each button
          backgroundColor: MyTheme().pinkColor,
          // rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23.0),
          ),
          onPressed: () {
            // show edit widget
            showDialog(
                context: context,
                builder: (context) {
                  return EditWidget(
                    pantryItem: Pantry(),
                    updateProductWidget: () {},
                    refreshPantryList: () {},
                    refreshCameraPage: refresh,
                    callingWidget: widget,
                  );
                });
          },
          elevation: 3,
          child: const Icon(
            Icons.add,
            size: 40.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        heroTag: "submit", // need unique tag for each button
        backgroundColor: MyTheme().pinkColor,
        // rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(23.0),
        ),
        onPressed: () async {
          // insert scanned items into pantry database
          if (widget.itemsToInsert != null) {
            for (ProductWidget product in widget.itemsToInsert!) {
              // add to pantry database
              var backendResult = await BackendUtils.changeVisibility();

              // if camera page closed, don't do anything
              if (!mounted) return;

              // success/error messages
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
            // show loading indicator for 0.5 sec before submit
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
        elevation: 3,
        child: const Icon(
          Icons.check,
          size: 40.0,
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

  // get product name from upc code using backend
  _addToPantry() async {
    // to inialize lastResult on first scan
    if (lastResult == null && result != null) {
      lastResult = result;
    }

    // if successfully scanned
    if (result != null && result != lastResult) {
      // if code can be found in UPC database
      if (result!.format == BarcodeFormat.ean13 ||
          result!.format == BarcodeFormat.ean8 ||
          result!.format == BarcodeFormat.upcA ||
          result!.format == BarcodeFormat.upcE) {
        // create a new pantry object with the scanned upc code
        Pantry newPantryItem = Pantry(
          dateAdded: DateTime.now(),
          upc: result!.code,
          isDeleted: 0,
          isVisibleInPantry: 0,
        );

        lastResult = result;

        // add that item to the pantry
        await BackendUtils.addPantry(newPantryItem);
      }
    }
  }

  // if user scans item and gets upc and product name
  // create a pantry item and product widget from it
  // add product widget to camera page's list of items
  _retreivePantryItems() async {
    // call backend to get all pantry items
    allPantryItems = await BackendUtils.getAllPantry();

    // filter the pantry items to only get the ones with isVisibleInPantry = 0
    for (Pantry item in allPantryItems) {
      // if item is not deleted
      if (item.isVisibleInPantry == 0) {
        // create product widget with pantry item
        ProductWidget newProductWidget = ProductWidget(
          key: UniqueKey(),
          pantryItem: item,
          enableCheckbox: false,
          // no need to refresh pantry since we're on camera page
          refreshPantryList: () {},
          onCameraPage: true,
        );

        // add to camera page's list of items
        widget.addItem(newProductWidget);
      }
    }
  }

// widget for list of items on camera page
  _buildItemList() {
    // if there are items to insert, return list of items
    if (widget.itemsToInsert != null && widget.itemsToInsert!.isNotEmpty) {
      return ListView.builder(
        itemCount: widget.itemsToInsert!.length,
        itemBuilder: (context, index) {
          return widget.itemsToInsert![index];
        },
      );
    } else {
      // if no items to insert, return empty container
      return Container();
    }
  }
}
