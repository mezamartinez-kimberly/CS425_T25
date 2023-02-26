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

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:edna/backend_utils.dart';

import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // product widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget

class CameraPage extends StatefulWidget {
  List<ProductWidget>? itemsToInsert;
  void addItem(ProductWidget product) {
    itemsToInsert ??= []; // initialize if null
    itemsToInsert?.add(product);
  }

  CameraPage({Key? key, this.itemsToInsert}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? productName = '';
  bool _flashOn = false;

  bool itemAdded = false;

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
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          _buildFlashButton(),
          _buildCameraToggleButton(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(
            flex: 2,
            // child: FittedBox(
            //   fit: BoxFit.contain,
            // child: SingleChildScrollView(

            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                _upcLookup(),
                _buildScannedList(),
              ],
            ),
            // ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _buildManualButton(),
                _buildSubmitButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildManualButton() {
    return ElevatedButton.icon(
      // rounded
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
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
                refreshCameraPage: refresh,
              );
            });
      },
      icon: const Icon(Icons.add),
      label: const Text("Manual"),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      // rounded
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      onPressed: () {
        // insert scanned items into pantry database
        for (ProductWidget product in widget.itemsToInsert!) {
          PantryDatabase.instance.insert(product.pantryItem);
        }
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
      },
      icon: const Icon(Icons.check),
      label: const Text(
        'Submit',
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

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

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
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
  _printScanResult() async {
    if (result != null) {
      String productName = '';
      // make call based on upc
      // store return data as pantry item
      // create product with pantry item

  Future<String> name = Future.value("");
  Function get onError => // print error message
      (error) => printYellow("error = $error");

  Future _getProductName() async {
    return productName = await BackendUtils.getUpcData(result!.code as String);
    // return productName =
    // await BackendUtils.getUpcData("096619295203").catchError(onError);
  }

  _upcLookup() {
    if (result != null) {
      if (result!.format == BarcodeFormat.ean13 ||
          result!.format == BarcodeFormat.ean8 ||
          result!.format == BarcodeFormat.upcA ||
          result!.format == BarcodeFormat.upcE) {}

      _getProductName().then((value) => productName = value);

      // when something returned for product name
      if (productName != '') {
        if (productName == 'UPC not found') {
          return Text("UPC ${result!.code} not found");
        } else {
          if (!itemAdded) {
            // convert upc code to int
            int upc = int.parse(result!.code as String);

            // create new pantry item with values
            Pantry newPantryItem = Pantry(
              name: productName as String,
              dateAdded: DateTime.now(),
              upc: upc,
              isDeleted: 0,
            );

            // create product widget with new pantry item
            ProductWidget newProductWidget = ProductWidget(
                pantryItem: newPantryItem,
                enableCheckbox: false,
                // no need to refresh pantry since we're still on camera page
                refreshPantryList: () {});
            // add to scanned list on camera page
            widget.addItem(newProductWidget);

            itemAdded = true;
          }
          // refresh camera page
          refresh();
          return Container();
        }
      }
      // when nothing returned for product name
      else {
        return const CircularProgressIndicator();
      }
    } else {
      return const Text('Scan a code');
    }
  }

  _buildScannedList() {
    //return Text("product name = $productName");
    return widget.itemsToInsert != null
        ? Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.itemsToInsert?.length,
              itemBuilder: (context, index) {
                return widget.itemsToInsert![index];
              },
            ),
          )
        : Container();
  }
}
