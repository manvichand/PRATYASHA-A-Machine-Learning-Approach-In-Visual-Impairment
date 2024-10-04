import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:pratyasaa/screen_one.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    // Request camera permission
    var status = await Permission.camera.request();

    if (status.isGranted) {
      _initializeCameraController();
    } else {
      print("Camera permission denied");
      // Handle denied or restricted permission
    }
  }

  Future<void> _initializeCameraController() async {
    final cameras = await availableCameras();

    // Use the first camera
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    // Initialize the controller
    _initializeControllerFuture = _controller.initialize();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            // Capture image
            final XFile image = await _controller.takePicture();

            // Save the image to local storage
            final Directory appDirectory =
                await getApplicationDocumentsDirectory();
            final String imagePath =
                '${appDirectory.path}/image_${DateTime.now()}.png';

            // Read bytes and write to file
            final Uint8List imageBytes = await File(image.path!).readAsBytes();
            await File(imagePath).writeAsBytes(imageBytes);
            print('Image captured and saved to: $imagePath');
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => MyHomePage()));
          } catch (e) {
            print('Error capturing image: $e');
          }
        },
      ),
    );
  }
}
