import 'package:flutter/material.dart';

class Newpostpage extends StatefulWidget {
  @override
  _NewpostpageState createState() => _NewpostpageState();
}

class _NewpostpageState extends State<Newpostpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        'assets/images/logo.png',
        width: 40.0,
        height: 40.0,
      ),
    );
  }
}