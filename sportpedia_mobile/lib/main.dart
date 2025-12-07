import 'package:flutter/material.dart';
import 'package:sportpedia_mobile/screens/menu.dart'; // ganti sportpedia_mobile kalau nama project lo beda

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SportPedia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: Colors.blueAccent[400],
        ),
        useMaterial3: false,
      ),
      home: MyHomePage(), // tanpa const
    );
  }
}
