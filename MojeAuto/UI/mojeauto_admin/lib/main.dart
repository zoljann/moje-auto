import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojeauto_admin/screens/users_page.dart';
import 'screens/cars_page.dart';
import 'screens/login_page.dart';
import 'layout/admin_layout.dart';
import 'helpers/token_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await TokenManager().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  bool get isLoggedIn => TokenManager().token?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MojeAuto Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/admin/cars' : '/login',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/admin/cars':
            page = AdminLayout(
              content: const CarsPage(),
              currentRoute: '/admin/cars',
            );
            break;
          case '/admin/users':
            page = AdminLayout(
              content: const UsersPage(),
              currentRoute: '/admin/users',
            );
            break;
          case '/login':
            page = const LoginPage();
            break;
          default:
            return null;
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
