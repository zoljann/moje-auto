import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/login_page.dart';
import 'screens/cars_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  bool isValid = false;

  if (token != null) {
    final parts = token.split('.');

    if (parts.length == 3) {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'];
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (exp != null && exp > currentTime) {
        isValid = true;
      }
    }
  }

  runApp(MyApp(isLoggedIn: isValid));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MojeAuto Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
     home: isLoggedIn
    ? const CarsPage()
    : const LoginPage(message: 'Sesija je istekla. Prijavite se ponovo.'),

    );
  }
}
