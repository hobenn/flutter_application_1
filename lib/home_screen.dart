import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("홈")),
      body: Center(
        child: Text("환영합니다, $email 님!", style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
