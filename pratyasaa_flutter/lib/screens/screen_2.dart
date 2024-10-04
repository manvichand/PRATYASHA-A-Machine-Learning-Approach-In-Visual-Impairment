import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ApiCallScreen(),
    );
  }
}

class ApiCallScreen extends StatefulWidget {
  @override
  _ApiCallScreenState createState() => _ApiCallScreenState();
}

class _ApiCallScreenState extends State<ApiCallScreen> {
  late CameraController _cameraController;
  FlutterTts flutterTts = FlutterTts();
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraReady = true;
    });
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _navigateToPredictCurrencyPage(XFile imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictCurrencyScreen(imageBytes: bytes),
      ),
    );
  }

  void _captureImage() async {
    if (!_isCameraReady) return;

    final XFile? imageFile = await _cameraController.takePicture();

    if (imageFile != null) {
      _navigateToPredictCurrencyPage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera and API Example'),
      ),
      body: GestureDetector(
        onTap: () {
          _captureImage();
        },
        behavior: HitTestBehavior.opaque,
        onDoubleTap: () {
          _captureImage();
        },
        child: Center(
          child: _isCameraReady
              ? CameraPreview(_cameraController)
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}

class PredictCurrencyScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const PredictCurrencyScreen({Key? key, required this.imageBytes})
      : super(key: key);

  Future<void> _fetchAndSpeak(String currency) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.speak('Predicted Currency: $currency');
  }

  Future<void> _predictCurrency(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse("http://192.168.176.222:5000/predict");
      final request = http.MultipartRequest("POST", uri);
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'image.jpg',
      ));

      final response = await http.Response.fromStream(await request.send());

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('predicted_currency')) {
          final String predictedCurrency =
              data['predicted_currency'].toString();
          await _fetchAndSpeak(predictedCurrency);
        } else {
          handleApiError('Invalid API response format');
        }
      } else {
        handleApiError('Error from server: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during HTTP request: $error');
      handleApiError('Error predicting currency');
    }
  }

  void handleApiError(String errorMessage) {
    FlutterTts flutterTts = FlutterTts();
    flutterTts.speak('Error predicting currency: $errorMessage');
  }

  @override
  Widget build(BuildContext context) {
    _predictCurrency(imageBytes);
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Currency'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(
              imageBytes,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Text(
              'Predicted Currency:loading....', // Placeholder for predicted currency
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'dart:typed_data';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ApiCallScreen(),
//     );
//   }
// }
//
// class ApiCallScreen extends StatefulWidget {
//   @override
//   _ApiCallScreenState createState() => _ApiCallScreenState();
// }
//
// class _ApiCallScreenState extends State<ApiCallScreen> {
//   late CameraController _cameraController;
//   FlutterTts flutterTts = FlutterTts();
//   bool _isCameraReady = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;
//
//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.medium,
//     );
//
//     await _cameraController.initialize();
//
//     if (!mounted) return;
//
//     setState(() {
//       _isCameraReady = true;
//     });
//   }
//
//   Future<void> _speak(String text) async {
//     await flutterTts.speak(text);
//   }
//
//   Future<void> _navigateToPredictCurrencyPage(XFile imageFile) async {
//     final Uint8List bytes = await imageFile.readAsBytes();
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PredictCurrencyScreen(imageBytes: bytes),
//       ),
//     );
//   }
//
//   void _captureImage() async {
//     if (!_isCameraReady) return;
//
//     final XFile? imageFile = await _cameraController.takePicture();
//
//     if (imageFile != null) {
//       _navigateToPredictCurrencyPage(imageFile);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Camera and API Example'),
//       ),
//       body: GestureDetector(
//         onTap: () {
//           _captureImage();
//         },
//         behavior: HitTestBehavior.opaque,
//         onDoubleTap: () {
//           _captureImage();
//         },
//         child: Center(
//           child: _isCameraReady
//               ? CameraPreview(_cameraController)
//               : CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }
// }
//
// class PredictCurrencyScreen extends StatelessWidget {
//   final Uint8List imageBytes;
//
//   const PredictCurrencyScreen({Key? key, required this.imageBytes})
//       : super(key: key);
//
//   Future<void> _fetchAndSpeak(String currency) async {
//     FlutterTts flutterTts = FlutterTts();
//     await flutterTts.speak('Predicted Currency: $currency');
//   }
//
//   Future<void> _predictCurrency(Uint8List imageBytes) async {
//     try {
//       final uri = Uri.parse("http://192.168.254.35:5000/predict");
//       final request = http.MultipartRequest("POST", uri);
//       request.files.add(http.MultipartFile.fromBytes(
//         'file',
//         imageBytes,
//         filename: 'image.jpg',
//       ));
//
//       final response = await http.Response.fromStream(await request.send());
//
//       print('API Request: ${request}');
//       print('API Response: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data.containsKey('predicted_currency')) {
//           final String predictedCurrency =
//           data['predicted_currency'].toString();
//           await _fetchAndSpeak(predictedCurrency);
//         } else {
//           handleApiError('Invalid API response format');
//         }
//       } else {
//         handleApiError('Error from server: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error during HTTP request: $error');
//       handleApiError('Error predicting currency');
//     }
//   }
//
//   void handleApiError(String errorMessage) {
//     FlutterTts flutterTts = FlutterTts();
//     flutterTts.speak('Error predicting currency: $errorMessage');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Predict Currency'),
//       ),
//       body: Dismissible(
//         key: Key('predictCurrency'),
//         direction: DismissDirection.endToStart,
//         onDismissed: (direction) {
//           Navigator.pop(context);
//         },
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.memory(
//                 imageBytes,
//                 width: 300,
//                 height: 300,
//                 fit: BoxFit.cover,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Predicted Currency:500', // Placeholder for predicted currency
//                 style: TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
