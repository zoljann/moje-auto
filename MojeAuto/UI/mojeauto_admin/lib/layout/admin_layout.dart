import 'package:flutter/material.dart';
import 'package:mojeauto_admin/screens/login_page.dart';
import 'package:mojeauto_admin/helpers/token_manager.dart';

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
    await TokenManager().clear();
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _navItem(
                          context,
                          Icons.people,
                          "Korisnici",
                          '/admin/users',
                        ),
                        _navItem(
                          context,
                          Icons.directions_car,
                          "Automobili",
                          '/admin/cars',
                        ),
                        _navItem(
                          context,
                          Icons.build,
                          "Dijelovi",
                          '/admin/parts',
                        ),
                        _navItem(
                          context,
                          Icons.factory,
                          "Proizvođači",
                          '/admin/manufacturers',
                        ),
                        _navItem(
                          context,
                          Icons.receipt_long,
                          "Narudžbe",
                          '/admin/orders',
                        ),
                        _navItem(
                          context,
                          Icons.category,
                          "Kategorije",
                          '/admin/categories',
                        ),
                        _navItem(
                          context,
                          Icons.public,
                          "Države",
                          '/admin/countries',
                        ),
                        _navItem(
                          context,
                          Icons.payment,
                          "Naplatne metode",
                          '/admin/payment-methods',
                        ),
                        _navItem(
                          context,
                          Icons.local_shipping,
                          "Dostavne metode",
                          '/admin/delivery-methods',
                        ),
                        _navItem(
                          context,
                          Icons.track_changes,
                          "Dostavni statusi",
                          '/admin/delivery-statuses',
                        ),
                        _navItem(
                          context,
                          Icons.admin_panel_settings,
                          "Uloge",
                          '/admin/roles',
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
                                  Icon(
                                    Icons.logout,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
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
                ),
                _userProfile(context),
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

  Widget _userProfile(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () => _handleNavigation(context, '/admin/profile'),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF232C39),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.person, size: 18, color: Colors.black),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Nedim",
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromARGB(125, 255, 255, 255),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
