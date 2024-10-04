import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  CustomButton(
      {required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: color,
          padding:
              EdgeInsets.all(70), // Increase the padding for larger buttons
          minimumSize: Size(200, 60), // Set a minimum button size
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 18), // Increase the font size
        ),
      ),
    );
  }
}
