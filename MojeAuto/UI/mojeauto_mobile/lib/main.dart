import 'package:flutter/material.dart';
import 'package:mojeauto_mobile/screens/login_register_page.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';
import 'package:mojeauto_mobile/layout/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenManager().initialize();
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
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return snapshot.data! ? const MainPage() : const LoginRegisterPage();
        },
      ),
    );
  }

  Future<bool> _isLoggedIn() async {
    final token = TokenManager().token;
    return token != null;
  }
}
