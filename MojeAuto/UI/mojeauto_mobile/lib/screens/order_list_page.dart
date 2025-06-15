import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  int? _cancelStatusId;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchOrderStatuses();
  }

  Future<void> _fetchOrders() async {
    final userId = await TokenManager().userId;
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/orders?UserId=$userId'),
        headers: {'accept': 'text/plain'},
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _orders = body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      NotificationHelper.error(context, 'Greška pri dohvaćanju narudžbi');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOrderStatuses() async {
    final res = await http.get(
      Uri.parse('${EnvConfig.baseUrl}/order-statuses'),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _cancelStatusId = data.firstWhere(
          (s) => s['name'].toString().toLowerCase() == 'otkazano',
          orElse: () => {'orderStatusId': 3},
        )['orderStatusId'];
      });
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    if (_cancelStatusId == null) {
      NotificationHelper.error(context, 'Nije moguće otkazati narudžbu.');
      return;
    }

    final response = await http.put(
      Uri.parse('${EnvConfig.baseUrl}/orders/$orderId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderStatusId': _cancelStatusId}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      NotificationHelper.success(context, 'Narudžba je otkazana.');
      _fetchOrders();
    } else {
      NotificationHelper.error(context, 'Greška pri otkazivanju narudžbe.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF181A1C);
    const cardColor = Color(0xFF2A2D31);
    const accent = Color(0xFF7D5EFF);
    const redAccent = Color(0xFFFF5555);
    const greenAccent = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        title: const Text(
          "Moje narudžbe",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(
              child: Text(
                "Nemate nijednu narudžbu",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final orderStatusName = order['orderStatus']['name']
                    .toString()
                    .toLowerCase();

                Color orderStatusColor = accent;
                if (orderStatusName == 'otkazano') {
                  orderStatusColor = const Color.fromARGB(255, 255, 62, 44);
                } else if (orderStatusName == 'dovršeno') {
                  orderStatusColor = const Color(0xFF81C784);
                }

                final deliveryStatus =
                    order['delivery']['deliveryStatus']?['name'] ?? 'Nepoznato';
                final deliveryDate = DateFormat('dd.MM.yyyy').format(
                  DateTime.parse(order['delivery']['deliveryDate']).toLocal(),
                );
                final orderDate = DateFormat(
                  'dd.MM.yyyy',
                ).format(DateTime.parse(order['orderDate']).toLocal());
                final isCancelable = deliveryStatus == 'U pripremi';

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Narudžba #${_orders.length - index}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              orderStatusName == 'otkazano'
                                  ? Icons.cancel
                                  : orderStatusName == 'dovršeno'
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              order['orderStatus']['name'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: orderStatusColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Datum: $orderDate",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.price_change,
                            color: Color(0xFF9D8CFF),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Iznos: ",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${order['totalAmount']} KM",
                            style: const TextStyle(
                              color: Color(
                                0xFF9D8CFF,
                              ),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Način plaćanja: ${order['paymentMethod']['name']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Najkasnija isporuka: $deliveryDate",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "📦 Status dostave: $deliveryStatus",
                        style: TextStyle(
                          color: deliveryStatus == 'U pripremi'
                              ? Colors.orangeAccent
                              : deliveryStatus == 'Poslano'
                              ? Colors.lightBlueAccent
                              : greenAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 20),
                      const Text(
                        "Stavke:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(order['orderItems'].length, (i) {
                        final item = order['orderItems'][i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "• ${item['part']['name']} x${item['quantity']} (${item['unitPrice']} KM)",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }),
                      if (isCancelable &&
                          orderStatusName != 'otkazano' &&
                          orderStatusName != 'dovršeno')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    title: const Text(
                                      "Potvrda otkazivanja",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      "Jeste li sigurni da želite otkazati ovu narudžbu?",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF2A2A2A,
                                          ),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text("Poništi"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF3B82F6,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Text("Da"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _cancelOrder(order['orderId']);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            child: const Text(
                              "Otkaži narudžbu",
                              style: TextStyle(color: redAccent),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
