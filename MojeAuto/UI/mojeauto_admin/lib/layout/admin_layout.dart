import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mojeauto_admin/screens/login_page.dart';

class AdminLayout extends StatelessWidget {
  final String username;
  final Widget child;

  const AdminLayout({super.key, required this.username, required this.child});

  void _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPage(message: 'Uspješno ste se odjavili'),
        ),
      );
    }
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
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: Text(
                    "Moje Auto",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                navItem(Icons.people, "Korisnici"),
                navItem(Icons.directions_car, "Automobili"),
                navItem(Icons.build, "Dijelovi"),
                navItem(Icons.shopping_cart, "Narudžbe"),
                navItem(Icons.star, "Preporučeno"),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    color: Colors.white12,
                    thickness: 1,
                    height: 32,
                  ),
                ),
                navItem(Icons.insert_chart, "Izvještaji"),
                navItem(
                  Icons.logout,
                  "Odjavi se",
                  onTap: () => _handleLogout(context),
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
                  Text(
                    "Pozdrav, $username 👋",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const Text(
                    "Dobrodošao na administrativni dio aplikacije \"Moje Auto\"",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, thickness: 1, color: Colors.white12),
                  const SizedBox(height: 24),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String title, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
