import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ShopApp(title: 'Shop'),
    );
  }
}

class ShopApp extends StatefulWidget {
  ShopApp({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _ShopAppState createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
