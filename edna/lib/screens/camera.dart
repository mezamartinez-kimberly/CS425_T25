/*
==============================
*    Title: camera.dart
*    Author: Julian Fliegler
*    Date: Dec 2022
==============================
*/

/* Referenced code:
// - https://stackoverflow.com/questions/65992435/how-to-open-barcode-scanner-in-a-custom-widget
*/

import 'dart:developer'; // for debugPrint
import 'dart:io'; // for Platform
import 'dart:convert';

import 'package:edna/main.dart'; // for main
import 'package:edna/screens/all.dart'; // for pantry page
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // for material design
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // barcode scanner
import 'package:edna/backend_utils.dart'; // for API calls
import 'package:google_fonts/google_fonts.dart'; // fonts
import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // product widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget
import 'package:rive/rive.dart';

// ignore: must_be_immutable
class CameraPage extends StatefulWidget {
  List<ProductWidget>? itemsToInsert;
  addItem(ProductWidget product) {
    itemsToInsert ??= []; // initialize if null
    itemsToInsert?.add(product);
  }

  void removeItem(ProductWidget product) {
    itemsToInsert?.remove(product);
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
  Map<String, Pantry> pantryMap = {}; // for duplicate resolution

  static bool itemAdded =
      false; // flag to check if item was just added to pantry
  static bool itemFound = false;

  late RiveAnimationController _animController;

  // define an empty list of barcodes
  List<Barcode>? barcodes = [];

// initialize the barcodes list as empty when the page loads
  @override
  void initState() {
    super.initState();
    barcodes = [];
    refresh();
    _animController = OneShotAnimation(
      'show',
    );
  }

  // for errors
  var errorText = const Color.fromARGB(255, 88, 15, 15);
  var errorBackground = const Color.fromARGB(255, 238, 37, 37);

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
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: _buildQrView(context),
            ),

            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.6,
              right: MediaQuery.of(context).size.width * 0.7 -
                  MediaQuery.of(context).size.height * 0.2,
              child: Visibility(
                visible: itemFound,
                child: SizedBox(
                  width: MediaQuery.of(context).size.height *
                      0.2, // Specify desired width of animation
                  height: MediaQuery.of(context).size.height *
                      0.2, // Specify desired height of animation
                  child: RiveAnimation.asset(
                    'assets/animation/checkmark_icon.riv',
                    controllers: [_animController],
                    onInit: (_) {
                      // Play animation once on init
                      _animController.isActive = true;
                      // trigger haptics
                      HapticFeedback.mediumImpact();
                    },
                  ),
                ),
              ),
            ),

            Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                ),

                // toolbar
                Expanded(
                    flex: 1,
                    // rounded corners
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 219, 219, 219),
                              // black line at bottom of toolbar
                              border: Border(
                                bottom: BorderSide(
                                  color: Color.fromARGB(255, 131, 131, 131),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: _buildToolbar()))),
                // items list
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    // set the edge insets
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        // add items to pantry
                        FutureBuilder(
                          future: _addToPantry(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return AlertDialog(
                                elevation: 3,
                                // make dialog red
                                backgroundColor: errorBackground,
                                // make text centered
                                contentPadding: const EdgeInsets.fromLTRB(
                                    24.0, 20.0, 24.0, 24.0),
                                // make corners rounded
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                // make text error text
                                titleTextStyle: TextStyle(color: errorText),
                                // make title larger and bold
                                title: const Text(
                                  'Error',
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                content: Text('Error: ${snapshot.error}'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      // pop alert dialog
                                      //Navigator.of(context).pop();

                                      // reload camera page
                                      Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CameraPage()));
                                    },
                                    // make text larger and white and bold
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              );
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
              ],
            ),

            // buttons
            Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 5.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      _buildAddButton(),
                      const SizedBox(width: 10), // spacing
                      _buildSubmitButton(),
                      const SizedBox(width: 5), // spacing
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.075,
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
                    refreshCameraPage: refresh,
                    callingWidget: widget,
                  );
                });
          },
          elevation: 3,
          child: Icon(
            Icons.add,
            size: MediaQuery.of(context).size.height * 0.04,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.075,
      child: FittedBox(
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
                  Future.delayed(const Duration(milliseconds: 100), () {
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
          child: Icon(
            Icons.check,
            size: MediaQuery.of(context).size.height * 0.04,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // spacer
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
          ),
          const Text(
            'Add items',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          // spacer
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          _buildFlashButton(),

          _buildCameraToggleButton(),
          // spacer
        ],
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
        ? 350.0
        : MediaQuery.of(context).size.height * 0.325;
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
      // if successfully scanned
      if (result != null) {
        // Check to see if the scanned item is alreadyin the barcode list
        bool alreadyScanned = false;
        for (Barcode barcode in barcodes!) {
          if (barcode.code == result!.code) {
            alreadyScanned = true;
          }
        }

        // if the item is not already in the barcode list
        if (!alreadyScanned) {
          // add the scanned item to the barcode list
          barcodes!.add(result!);
          // check to see if the scanned item is a valid upc code
          if (result!.format == BarcodeFormat.ean13 ||
              result!.format == BarcodeFormat.upcA ||
              result!.format == BarcodeFormat.upcE) {
            // create a new pantry object with the scanned upc code
            Pantry newPantryItem = Pantry(
              dateAdded: DateTime.now(),
              upc: result!.code,
              isDeleted: 0,
              isVisibleInPantry: 0,
            );

            // need to store upc to put in product widget later
            // since we map the pantry item from the backend json response
            // and pantry items in backend only have product id, not actual codes
            var tempUPC = result!.code;

            // add the new pantry item using the backend utils functinon addPantry
            // capture the response of the function and get the pantry item from the json response
            await BackendUtils.addPantry(newPantryItem).then((value) {
              if (value.statusCode != 200 && value.statusCode != 201) {
                if (value.statusCode == 400) {
                  const MyApp().createErrorMessage(
                      context, "Error ${value.statusCode}: Item not found.");
                } else {
                  const MyApp().createErrorMessage(context,
                      "Error ${value.statusCode}: ${value.reasonPhrase}");
                }
              } else {
                // itemFound triggers checkmark animation
                itemFound = true;
                // get the json response from the backend
                dynamic jsonResponse = json.decode(value.body);
                Pantry pantryItem = Pantry.fromMap(jsonResponse);
                // add upc code
                pantryItem.upc = tempUPC;

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
              }
            });

            // toggle itemAdded so item doesn't duplicate
            itemAdded = true;

            // wait 3 seconds before allowing another item to be added
            await Future.delayed(const Duration(seconds: 2));
            refresh();
            itemAdded = false;
            itemFound = false;
          }
        }
      }
    }
  }

// widget for list of items on camera page
  _buildItemList() {
    // if there are items to insert, return list of items
    if (widget.itemsToInsert != null && widget.itemsToInsert!.isNotEmpty) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.itemsToInsert!.length,
          itemBuilder: (context, index) {
            return widget.itemsToInsert![index];
          },
          // enable scrolling on list
          physics: const BouncingScrollPhysics(),
        ),
      );
    } else {
      // if no items to insert, return empty container
      return Container();
    }
  }
}
