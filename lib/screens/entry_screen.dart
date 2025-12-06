import 'package:flutter/material.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
