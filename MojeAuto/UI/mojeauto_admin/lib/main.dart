import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/login_page.dart';
import 'screens/cars_page.dart';
import 'screens/users_page.dart';
import 'layout/admin_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');

  bool tokenExists = token != null;
  bool isJwtValid = false;
  bool isAdmin = false;

  if (tokenExists) {
    final parts = token.split('.');
    if (parts.length == 3) {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'];
      final roleClaim =
          "http://schemas.microsoft.com/ws/2008/06/identity/claims/role";
      final role = payload[roleClaim];
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      if (exp != null && exp > currentTime) {
        isJwtValid = true;
        isAdmin = role == "admin";
      }
    }
  }

  runApp(
    MyApp(isJwtValid: isJwtValid, tokenExists: tokenExists, isAdmin: isAdmin),
  );
}

class MyApp extends StatelessWidget {
  final bool isJwtValid;
  final bool tokenExists;
  final bool isAdmin;
  const MyApp({
    super.key,
    required this.isJwtValid,
    required this.tokenExists,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MojeAuto Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: (settings) {
        Widget page;

        if (!isJwtValid) {
          page = LoginPage(
            message: tokenExists
                ? "Sesija je istekla. Prijavite se ponovo."
                : null,
          );
        } else if (!isAdmin) {
          page = const LoginPage(
            message: "Nemate dozvolu za pristup administratorskom panelu.",
          );
        } else {
          switch (settings.name) {
            case '/admin/users':
              page = const UsersPage();
              break;
            case '/admin/cars':
              page = const CarsPage();
            case '/admin/profile':
              page = const CarsPage();
            default:
              page = const CarsPage();
          }

          page = AdminLayout(content: page, currentRoute: settings.name ?? '');
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}
