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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:edna/screens/all.dart'; // all screens
// import 'package:qr_code_scanner/qr_code_scanner.dart'; // barcode scanner
// import 'package:flutter/services.dart'; // PlatformException
// import 'package:google_fonts/google_fonts.dart'; // fonts

// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});

//   @override
//   CameraPageState createState() => CameraPageState();
// }

// class CameraPageState extends State<CameraPage> {
//   String _scanBarcode = 'Unknown';
//   String _pluCode = "null";

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return MaterialApp(
//   //       debugShowCheckedModeBanner: false,
//   //       title: 'Camera Page',
//   //       theme: ThemeData(
//   //         primarySwatch: Colors.blue,
//   //         textTheme:
//   //             GoogleFonts.notoSerifTextTheme(Theme.of(context).textTheme),
//   //       ),
//   //       home: Scaffold(
//   //         appBar: AppBar(
//   //             title: const Align(
//   //           alignment: Alignment.centerLeft,
//   //           child: Text('Camera'),
//   //         )),
//   //         body: Builder(builder: (BuildContext context) {
//   //           return Padding(
//   //             padding: const EdgeInsets.symmetric(horizontal: 50.0),
//   //             child: Container(
//   //               alignment: Alignment.center,
//   //               child: Flex(
//   //                   direction: Axis.vertical,
//   //                   mainAxisAlignment: MainAxisAlignment.center,
//   //                   children: <Widget>[
//   //                     // barcode button

//   //                     // upc text output
//   //                     Text('UPC Code: $_scanBarcode\n',
//   //                         style: const TextStyle(fontSize: 20)),

//   //                     // plu text entry
//   //                     TextField(
//   //                       onChanged: (text) {
//   //                         // get numbers user entered
//   //                         _pluCode = text;
//   //                       },
//   //                       decoration:
//   //                           const InputDecoration(labelText: "Enter PLU Code"),
//   //                       keyboardType: TextInputType.number,
//   //                       inputFormatters: <TextInputFormatter>[
//   //                         FilteringTextInputFormatter
//   //                             .digitsOnly, // only allow nums
//   //                         LengthLimitingTextInputFormatter(
//   //                             4), // only allow 4 nums
//   //                       ],
//   //                     ),
//   //                   ]),
//   //             ),
//   //           );
//   //         }),
//   //       ));
//   // }
// //}

import 'dart:developer';
import 'dart:io';

import 'package:edna/widgets/product_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:edna/dbs/pantry_db.dart'; // pantry db
import 'package:edna/widgets/product_widget.dart'; // pantry item widget

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 70,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                // align elements to right
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _buildFlashButton(),
                  _buildCameraToggleButton(),
                ],
              ),
            ),
          ),
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _printScanResult(),
                  SizedBox(
                    height: 20,
                    child: ProductWidget(pantryItem: Pantry(name: "test")),
                  ),
                ],
              ),
            ),
          )
        ],
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
    return Container(
      child: // show flash icon
          IconButton(
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
      ),
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

      return Text(
          'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}');
      // return ProductWidget(
      //   pantryItem: Pantry(name: 'test'),
      // );
    } else {
      return const Text('Scan a code');
    }
  }
}
