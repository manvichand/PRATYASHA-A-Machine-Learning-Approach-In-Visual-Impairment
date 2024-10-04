import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
// import 'package:mime/mime.dart' as mime;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> upload(File imageFile) async {
    print(imageFile.path);
    try {
      print('sdaf');
      var uri = Uri.parse("http://192.168.254.35:5000/predict");

      var request = http.MultipartRequest("POST", uri);
      request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path.toString()));

      var response = await request.send();
      print(request);

      if (response.statusCode == 200) {
        // Handle success
        print('Image uploaded successfully!');
      } else {
        // Handle other status codes
        print('Image upload failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle any errors that occurred during the HTTP request
      print('Error during HTTP request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image!),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _image != null
                  ? () {
                      upload(_image!);
                    }
                  : null,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
