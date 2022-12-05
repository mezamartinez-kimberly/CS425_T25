import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'homepage.dart';
import 'camera.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  MyApp({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return const MaterialApp(
      home: HomePage(),
=======
    return MaterialApp(
      home: Scaffold(
        body: Camera(cameras: cameras),
      ),
>>>>>>> Stashed changes
    );
  }
}
