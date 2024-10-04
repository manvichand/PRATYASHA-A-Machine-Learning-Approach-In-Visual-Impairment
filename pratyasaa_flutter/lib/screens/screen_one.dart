import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OCRScreen(),
    );
  }
}

class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _navigateToPredictOCRPage(XFile imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PredictOCRScreen(imageBytes: bytes),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        await _navigateToPredictOCRPage(XFile(pickedFile.path, bytes: bytes));
      }
    } catch (error) {
      print('Error capturing image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _captureImage(ImageSource.camera),
              child: Text('Capture Image from Camera'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _captureImage(ImageSource.gallery),
              child: Text('Pick Image from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

class PredictOCRScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const PredictOCRScreen({Key? key, required this.imageBytes})
      : super(key: key);

  @override
  _PredictOCRScreenState createState() => _PredictOCRScreenState();
}

class _PredictOCRScreenState extends State<PredictOCRScreen> {
  late Future<String> _prediction;

  @override
  void initState() {
    super.initState();
    _prediction = _predictOCR(widget.imageBytes);
  }

  Future<void> _fetchAndSpeak(String text) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.speak('Predicted Text: $text');
  }

  Future<String> _predictOCR(Uint8List imageBytes) async {
    try {
      final uri = Uri.parse("http://192.168.176.222:6000/ocr");
      final request = http.MultipartRequest("POST", uri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image_captured.jpg',
      ));

      final response = await http.Response.fromStream(await request.send());

      print('OCR API Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('text') && data['text'].isNotEmpty) {
          final String predictedText = data['text'].toString();
          _fetchAndSpeak(predictedText);
          return predictedText;
        } else {
          return 'Invalid OCR API response format';
        }
      } else {
        return 'Error from OCR server: ${response.statusCode}';
      }
    } catch (error) {
      print('Error during OCR HTTP request: $error');
      return 'Error predicting text';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict OCR Text'),
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
                      'Predicted OCR Text: ${snapshot.data}',
                      // 'Predicted OCR Text: System Inceptions\nInsights on\n Simulation and\n Modeling',

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
