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
import 'dart:convert';

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
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CameraPage extends StatefulWidget {
  List<ProductWidget>? itemsToInsert;
  addItem(ProductWidget product) {
    itemsToInsert ??= []; // initialize if null
    itemsToInsert?.add(product);
  }

  clearList() {
    itemsToInsert = [];
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    // add items to pantry
                    FutureBuilder(
                      future: _addToPantry(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Container();
                        }
                      },
                    ),
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
          await BackendUtils.changeVisibility();

          if (!mounted) return;
          
          showDialog(
              context: context,
              builder: (context) {
                // wait 0.5 sec
                Future.delayed(const Duration(milliseconds: 200), () {
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
          // insert scanned items into pantry database
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
    if (!itemAdded) {
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

          // add the new pantry item using the backend utils functinon addPantry
          // capture the response of the function and get the pantry item from the json response
          await BackendUtils.addPantry(newPantryItem).then((value) {
            // get the json response from the backend
            dynamic jsonResponse = json.decode(value.body);
            Pantry pantryItem = Pantry.fromMap(jsonResponse);

            ProductWidget newProductWidget = ProductWidget(
              key: UniqueKey(),
              pantryItem: pantryItem,
              enableCheckbox: false,
              // no need to refresh pantry since we're on camera page
              refreshPantryList: () {},
              callingWidget: widget,
            );

            // add to camera page's list of items
            widget.addItem(newProductWidget);
            // toggle itemAdded so item doesn't duplicate
            itemAdded = true;
          });
        }
      }
    } else {
      // wait 5 seconds before user can scan another item
      // this way item doesn't duplicate over and over
      Future.delayed(const Duration(seconds: 5), () {
        itemAdded = false;
      });
    }
  }

// widget for list of items on camera page
  _buildItemList() {
    // if there are items to insert, return list of items
    if (widget.itemsToInsert != null && widget.itemsToInsert!.isNotEmpty) {
      return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.itemsToInsert!.length,
        itemBuilder: (context, index) {
          return widget.itemsToInsert![index];
        },

        // enable scrolling on list
        physics: const BouncingScrollPhysics(),
      );
    } else {
      // if no items to insert, return empty container
      return Container();
    }
  }
}
