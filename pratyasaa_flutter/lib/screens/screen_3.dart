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
      home: CaptionCallScreen(),
    );
  }
}

class CaptionCallScreen extends StatefulWidget {
  @override
  _CaptionCallScreenState createState() => _CaptionCallScreenState();
}

class _CaptionCallScreenState extends State<CaptionCallScreen> {
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

  Future<void> _navigateToPredictCaptionPage(XFile imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictCaptionScreen(imageBytes: bytes),
      ),
    );
  }

  void _captureImage() async {
    if (!_isCameraReady) return;

    final XFile? imageFile = await _cameraController.takePicture();

    if (imageFile != null) {
      _navigateToPredictCaptionPage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera and API Example'),
      ),
      body: GestureDetector(
        onTap: _captureImage,
        onHorizontalDragEnd: (details) {
          // Check if the user swiped right
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
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

class PredictCaptionScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const PredictCaptionScreen({Key? key, required this.imageBytes})
      : super(key: key);

  @override
  _PredictCaptionScreenState createState() => _PredictCaptionScreenState();
}

class _PredictCaptionScreenState extends State<PredictCaptionScreen> {
  late Future<String> _prediction;

  @override
  void initState() {
    super.initState();
    _prediction = _predictCaption(widget.imageBytes);
  }

  Future<String> _fetchAndSpeak(String caption) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.speak('Predicted Caption: $caption');
    return caption;
  }

  Future<String> _predictCaption(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse("http://192.168.176.222:8000/predict/");
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
        if (data.containsKey('caption') && data['caption'].isNotEmpty) {
          final String predictedCaption = data['caption'][0].toString();
          return _fetchAndSpeak(predictedCaption);
        } else {
          return 'Invalid API response format';
        }
      } else {
        return 'Error from server: ${response.statusCode}';
      }
    } catch (error) {
      print('Error during HTTP request: $error');
      return 'Error predicting caption';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Caption'),
      ),
      body: FutureBuilder<String>(
        future: _prediction,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return GestureDetector(
              onHorizontalDragEnd: (details) {
                // Check if the user swiped right
                if (details.primaryVelocity! > 0) {
                  Navigator.pop(context);
                }
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.memory(
                      widget.imageBytes,
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Predicted Caption: ${snapshot.data}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
