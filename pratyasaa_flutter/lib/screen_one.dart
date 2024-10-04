import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterTts flutterTts = FlutterTts();

  Future _speak() async {
    var result = await flutterTts.speak("Hello World");
    if (result == 1) setState(() {});
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _speak();
  }

  void init() {
    _speak();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text-to-Speech Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello World',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speak,
              child: Text('Speak'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stop,
              child: Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
