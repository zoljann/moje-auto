import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';
import 'package:mojeauto_mobile/screens/order_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mojeauto_mobile/screens/part_detail.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await TokenManager().userId;
    if (userId == null) return;

    final cartData = prefs.getString('cart_$userId');
    if (cartData != null) {
      setState(() {
        _cartItems = List<Map<String, dynamic>>.from(json.decode(cartData));
      });
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await TokenManager().userId;
    if (userId == null) return;

    await prefs.setString('cart_$userId', json.encode(_cartItems));
  }

  void _incrementQty(int index) {
    final item = _cartItems[index];
    final inCart = item['quantity'];
    final available = item['quantityAvailable'];

    if (inCart < available) {
      setState(() {
        _cartItems[index]['quantity']++;
      });
      _saveCart();
    } else {
      NotificationHelper.error(
        context,
        "Dostignut je maksimalan broj dostupnih komada.",
      );
    }
  }

  void _decrementQty(int index) {
    setState(() {
      if (_cartItems[index]['quantity'] > 1) {
        _cartItems[index]['quantity']--;
      } else {
        _cartItems.removeAt(index);
      }
    });
    _saveCart();
  }

  double _calculateTotal() {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + item['price'] * item['quantity'],
    );
  }

  int _calculateMaxDeliveryDays() {
    return _cartItems.fold(
      0,
      (max, item) => item['estimatedArrivalDays'] > max
          ? item['estimatedArrivalDays']
          : max,
    );
  }

  Future<void> _goToDetail(int partId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PartDetailPage(partId: partId)),
    );
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    final fieldFillColor = const Color(0xFF2A2D31);

    return Scaffold(
      backgroundColor: const Color(0xFF181A1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A1C),
        centerTitle: true,
        title: const Text(
          "Korpa",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          if (_cartItems.isEmpty)
            const Center(
              child: Text(
                "Vaša korpa je prazna",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.only(bottom: 200, top: 20),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                final imageData = item['imageData'];
                final bool isAtMax =
                    item['quantity'] >= item['quantityAvailable'];

                return GestureDetector(
                  onTap: () => _goToDetail(item['partId']),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fieldFillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageData != null
                              ? Image.memory(
                                  base64Decode(imageData),
                                  width: 64,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 64,
                                  height: 48,
                                  color: const Color(0xFF3A3D41),
                                  child: const Icon(
                                    Icons.settings,
                                    color: Colors.white70,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${item['price']} KM x ${item['quantity']}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white70,
                              ),
                              onPressed: () => _decrementQty(index),
                            ),
                            Text(
                              '${item['quantity']}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            AbsorbPointer(
                              absorbing: isAtMax,
                              child: IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: isAtMax
                                      ? Colors.white24
                                      : Colors.white70,
                                ),
                                onPressed: isAtMax
                                    ? null
                                    : () => _incrementQty(index),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (_cartItems.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2D31),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ukupno:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${_calculateTotal().toStringAsFixed(2)} KM",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Procijenjena isporuka:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${_calculateMaxDeliveryDays()} dana",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D5EFF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderPage(cartItems: _cartItems),
                        ),
                      );

                      if (result == true) {
                        final prefs = await SharedPreferences.getInstance();
                        final userId = await TokenManager().userId;
                        if (userId != null) {
                          await prefs.remove('cart_$userId');
                        }

                        setState(() {
                          _cartItems.clear();
                        });
                      }
                    },

                    child: const Text(
                      "Nastavi",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
