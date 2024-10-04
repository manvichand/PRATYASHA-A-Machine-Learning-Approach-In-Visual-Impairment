
import 'package:flutter/material.dart';
import 'package:pratyasaa/my_homepage.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('click'),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyHomePage()));


          } ),
      ),
    );
  }
}
