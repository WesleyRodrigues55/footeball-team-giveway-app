import 'package:flutter/material.dart';
import 'package:footeball_team_giveway_app/pages/HomePage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightGreenAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Footeball Team Giveaway',
      home: HomePage(),
    );
  }
}
