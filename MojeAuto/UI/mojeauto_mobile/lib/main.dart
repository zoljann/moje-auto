import 'package:flutter/material.dart';
import 'package:mojeauto_mobile/screens/login_register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MojeAuto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111116),
        primaryColor: const Color(0xFF7D5EFF),
      ),
      home: const LoginRegisterPage(),
    );
  }
}
