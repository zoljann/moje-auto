import 'package:flutter/material.dart';
import 'package:mojeauto_admin/screens/admin_profile_edit.dart';
import 'package:mojeauto_admin/screens/category_page.dart';
import 'package:mojeauto_admin/screens/country_page.dart';
import 'package:mojeauto_admin/screens/delivery_methods_page.dart';
import 'package:mojeauto_admin/screens/delivery_statuses_page.dart';
import 'package:mojeauto_admin/screens/manufacturer_page.dart';
import 'package:mojeauto_admin/screens/order_page.dart';
import 'package:mojeauto_admin/screens/order_statuses_page.dart';
import 'package:mojeauto_admin/screens/part_car_page.dart';
import 'package:mojeauto_admin/screens/part_page.dart';
import 'package:mojeauto_admin/screens/payment_methods_page.dart';
import 'package:mojeauto_admin/screens/user_reports_page.dart';
import 'package:mojeauto_admin/screens/users_page.dart';
import 'package:mojeauto_admin/screens/users_role_page.dart';
import 'screens/cars_page.dart';
import 'screens/login_page.dart';
import 'layout/admin_layout.dart';
import 'helpers/token_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          case '/admin/countries':
            page = AdminLayout(
              content: const CountryPage(),
              currentRoute: '/admin/countries',
            );
            break;
          case '/admin/roles':
            page = AdminLayout(
              content: const UsersRolePage(),
              currentRoute: '/admin/roles',
            );
            break;
          case '/admin/payment-methods':
            page = AdminLayout(
              content: const PaymentMethodsPage(),
              currentRoute: '/admin/payment-methods',
            );
            break;
          case '/admin/delivery-methods':
            page = AdminLayout(
              content: const DeliveryMethodsPage(),
              currentRoute: '/admin/delivery-methods',
            );
            break;
          case '/admin/delivery-statuses':
            page = AdminLayout(
              content: const DeliveryStatusesPage(),
              currentRoute: '/admin/delivery-statuses',
            );
            break;
          case '/admin/categories':
            page = AdminLayout(
              content: const CategoryPage(),
              currentRoute: '/admin/categories',
            );
            break;
          case '/admin/manufacturers':
            page = AdminLayout(
              content: const ManufacturerPage(),
              currentRoute: '/admin/manufacturers',
            );
            break;
          case '/admin/order-statuses':
            page = AdminLayout(
              content: const OrderStatusesPage(),
              currentRoute: '/admin/order-statuses',
            );
            break;
          case '/admin/part-cars':
            page = AdminLayout(
              content: const PartCarPage(),
              currentRoute: '/admin/part-cars',
            );
            break;
          case '/admin/parts':
            page = AdminLayout(
              content: const PartPage(),
              currentRoute: '/admin/parts',
            );
          case '/admin/orders':
            page = AdminLayout(
              content: const OrderPage(),
              currentRoute: '/admin/orders',
            );
          case '/admin/profile-edit':
            page = AdminLayout(
              content: const AdminProfileEditPage(),
              currentRoute: '/admin/profile-edit',
            );
            break;
          case '/admin/reports':
            page = AdminLayout(
              content: const UserReportsPage(),
              currentRoute: '/admin/reports',
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
