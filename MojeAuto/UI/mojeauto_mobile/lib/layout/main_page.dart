import 'package:flutter/material.dart';
import 'package:mojeauto_mobile/screens/about_us.dart';
import 'package:mojeauto_mobile/screens/home_page.dart';
import 'package:mojeauto_mobile/screens/cart_page.dart';
import 'package:mojeauto_mobile/screens/order_list_page.dart';
import 'package:mojeauto_mobile/screens/profile_page.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';
import 'package:mojeauto_mobile/screens/login_register_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CartPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            children: [
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.local_offer),
                title: const Text('Moje narudžbe'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderListPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('O nama'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutUsPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Odjavi se',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  await TokenManager().clear();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginRegisterPage(),
                      ),
                      (route) => false,
                    );
                    NotificationHelper.success(
                      context,
                      'Uspješno ste se odjavili.',
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          _pages[_selectedIndex],
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  iconSize: 32,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white60,
        backgroundColor: const Color(0xFF1C1C1E),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Početna'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Korpa',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
