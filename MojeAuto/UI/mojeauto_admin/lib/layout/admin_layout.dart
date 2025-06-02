import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mojeauto_admin/screens/login_page.dart';

class AdminLayout extends StatelessWidget {
  final Widget content;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.content,
    required this.currentRoute,
  });

  void _handleNavigation(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(message: 'Uspješno ste se odjavili'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 230,
            color: const Color(0xFF0F131A),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 35),
                  child: Text(
                    "Moje Auto",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _navItem(context, Icons.people, "Korisnici", '/admin/users'),
                _navItem(
                  context,
                  Icons.directions_car,
                  "Automobili",
                  '/admin/cars',
                ),
                _navItem(context, Icons.build, "Dijelovi", '/admin/parts'),
                _navItem(
                  context,
                  Icons.shopping_cart,
                  "Narudžbe",
                  '/admin/orders',
                ),
                _navItem(
                  context,
                  Icons.star,
                  "Preporučeno",
                  '/admin/recommended',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: Colors.white12,
                    thickness: 1,
                    height: 32,
                  ),
                ),
                _navItem(
                  context,
                  Icons.insert_chart,
                  "Izvještaji",
                  '/admin/reports',
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _logout(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 24,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.white70, size: 20),
                          SizedBox(width: 12),
                          Text(
                            "Odjavi se",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF0F131A),
            child: const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.white12,
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF0F131A),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pozdrav, Admin 👋",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const Text(
                    "Dobrodošao na administrativni dio aplikacije \"Moje Auto\"",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, thickness: 1, color: Colors.white12),
                  const SizedBox(height: 24),
                  Expanded(child: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    final isActive = currentRoute == route;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () => _handleNavigation(context, route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
