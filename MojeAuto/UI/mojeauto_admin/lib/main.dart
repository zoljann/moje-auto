import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/cars_page.dart';
import 'screens/users_page.dart';
import 'layout/admin_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        Widget content;

        switch (settings.name) {
          case '/admin/users':
            content = const UsersPage();
            break;
          case '/admin/cars':
            content = const CarsPage();
            break;
          case '/admin/profile':
            content = const CarsPage(); // placeholder for profile
            break;
          default:
            content = const CarsPage(); // fallback
            break;
        }

        final page = AdminLayout(
          content: content,
          currentRoute: settings.name ?? '',
        );

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
