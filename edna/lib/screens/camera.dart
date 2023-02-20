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

import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // product widget
import 'package:edna/widgets/edit_widget.dart'; // edit dialog widget

class CameraPage extends StatefulWidget {
  List<ProductWidget>? scannedProducts;
  void addScannedProduct(ProductWidget product) {
    scannedProducts ??= []; // initialize if null
    scannedProducts?.add(product);
  }

  CameraPage({Key? key, this.scannedProducts}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool _flashOn = false;

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
                //_printScanResult(), // deprecated
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
        for (ProductWidget product in widget.scannedProducts!) {
          PantryDatabase.instance.insert(product.pantryItem);
        }
        showDialog(
            context: context,
            builder: (context) {
              // wait 0.5 sec
              Future.delayed(Duration(milliseconds: 500), () {
                // clear scanned list
                widget.scannedProducts!.clear();
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

  Widget _printScanResult() {
    if (result != null) {
      // make call based on upc
      // store return data as pantry item
      // create product with pantry item

      //return Text(
      //   'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}');
      String upcCode = result!.code.toString();
      return ProductWidget(pantryItem: Pantry(id: 500, name: upcCode));

      // something is pushing this down?
    } else {
      return const Text('Scan a code');
    }
  }

  _buildScannedList() {
    return widget.scannedProducts != null
        ? Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.scannedProducts?.length,
              itemBuilder: (context, index) {
                return widget.scannedProducts![index];
              },
            ),
          )
        : Container();
  }
}
