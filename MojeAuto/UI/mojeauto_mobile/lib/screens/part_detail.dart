import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';

class PartDetailPage extends StatefulWidget {
  final int partId;

  const PartDetailPage({super.key, required this.partId});

  @override
  State<PartDetailPage> createState() => _PartDetailPageState();
}

class _PartDetailPageState extends State<PartDetailPage> {
  bool _showAllCars = false;
  Map<String, dynamic>? _part;
  bool _isLoading = true;
  bool _isCooldown = false;

  @override
  void initState() {
    super.initState();
    _fetchPart();
  }

  Future<void> _fetchPart() async {
    final response = await http.get(
      Uri.parse('${EnvConfig.baseUrl}/parts?id=${widget.partId}'),
      headers: {'accept': 'text/plain'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _part = jsonDecode(response.body);
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_isCooldown) return;

    setState(() => _isCooldown = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCooldown = false);
    });
    final prefs = await SharedPreferences.getInstance();
    final userId = await TokenManager().userId;
    if (userId == null) return;

    final cartKey = 'cart_$userId';
    final existing = prefs.getString(cartKey);
    List<Map<String, dynamic>> cartItems = [];

    if (existing != null) {
      cartItems = List<Map<String, dynamic>>.from(json.decode(existing));
    }

    final partId = _part!['partId'];
    final index = cartItems.indexWhere((item) => item['partId'] == partId);

    if (index >= 0) {
      final currentQty = cartItems[index]['quantity'];
      final maxQty = _part!['quantity'];

      if (currentQty >= maxQty) {
        if (mounted) {
          NotificationHelper.error(context, 'Nema više dostupnih komada.');
        }
        return;
      }

      cartItems[index]['quantity'] += 1;
    } else {
      cartItems.add({
        'partId': partId,
        'name': _part!['name'],
        'price': _part!['price'],
        'quantity': 1,
        'quantityAvailable': _part!['quantity'],
        'estimatedArrivalDays': _part!['estimatedArrivalDays'] ?? 0,
        'imageData': _part!['imageData'],
      });
    }

    await prefs.setString(cartKey, json.encode(cartItems));

    if (mounted) {
      NotificationHelper.success(context, 'Dio dodan u korpu');
    }
  }

  Future<void> _notifyWhenAvailable() async {
    final userId = await TokenManager().userId;
    if (userId == null) return;

    NotificationHelper.success(
      context,
      'Email će vam biti poslan kad artikal bude dostupan',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _part == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF181A1C),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final part = _part!;
    final bool isOutOfStock = (part['quantity'] ?? 0) == 0;
    final imageData = part['imageData'];
    final compatibleCars = part['compatibleCars'] ?? [];
    final displayedCars = _showAllCars
        ? compatibleCars
        : compatibleCars.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalji dijela"),
        backgroundColor: const Color(0xFF181A1C),
      ),
      backgroundColor: const Color(0xFF181A1C),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageData != null
                      ? Image.memory(
                          base64Decode(imageData),
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: 220,
                          color: const Color(0xFF2A2D31),
                          child: const Center(
                            child: Icon(
                              Icons.car_repair,
                              size: 80,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Text(
                  part['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Kataloški broj: ${part['catalogNumber'] ?? '-'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.local_offer, color: Colors.greenAccent),
                    const SizedBox(width: 8),
                    Text(
                      "${part['price']} KM",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Specifikacije:",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                _specRow(
                  Icons.precision_manufacturing,
                  "Proizvođač",
                  part['manufacturer']?['name'] ?? 'Nepoznato',
                ),
                _specRow(
                  Icons.category,
                  "Kategorija",
                  part['category']?['name'] ?? 'Nepoznato',
                ),
                _specRow(
                  Icons.security,
                  "Garancija",
                  "${part['warrantyMonths']} mj",
                ),
                _specRow(
                  Icons.line_weight,
                  "Težina",
                  "${part['weight'] ?? '-'} kg",
                ),
                _specRow(Icons.inventory, "Količina", "${part['quantity']}"),
                _specRow(
                  Icons.shopping_cart_checkout,
                  "Prodano",
                  "${part['totalSold']}",
                ),
                _specRow(
                  Icons.local_shipping,
                  "Isporuka",
                  "${part['estimatedArrivalDays']} dana",
                ),
                if ((part['description'] ?? '').toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      part['description'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  "Kompatibilni automobili:",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                if (compatibleCars.isEmpty)
                  const Text(
                    "Nema unesenih automobila.",
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...displayedCars.map((pc) {
                        final car = pc['car'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${car['brand']} ${car['model']} (${car['year']})",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (compatibleCars.length > 3)
                        TextButton(
                          onPressed: () =>
                              setState(() => _showAllCars = !_showAllCars),
                          child: Text(
                            _showAllCars ? "Sakrij" : "Prikaži sve",
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 80), // spacing for floating button
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: isOutOfStock
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.redAccent,
                    onPressed: _notifyWhenAvailable,
                    icon: const Icon(Icons.notifications_active),
                    label: const Text("Obavijesti me kada bude dostupno"),
                  )
                : FloatingActionButton.extended(
                    backgroundColor: const Color(0xFF7D5EFF),
                    onPressed: _addToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text("Dodaj u korpu"),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _specRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
