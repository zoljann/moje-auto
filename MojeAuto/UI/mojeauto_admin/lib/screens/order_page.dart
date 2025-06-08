import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<dynamic> orders = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingId;
  List<dynamic> deliveryMethods = [];
  List<dynamic> deliveryStatuses = [];
  List<dynamic> paymentMethods = [];
  List<dynamic> orderStatuses = [];
  int? _selectedDeliveryMethodId;
  int? _selectedDeliveryStatusId;
  int? _selectedPaymentMethodId;
  int? _selectedOrderStatusId;
  String? _deliveryDateIso;
  String? _fromDateIso;
  String? _toDateIso;
  int? _selectedOrderStatusIdFilter;

  final _formKey = GlobalKey<FormState>();
  final _deliveryDateController = TextEditingController();
  final _searchController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchDeliveryMethods();
    _fetchDeliveryStatuses();
    _fetchPaymentMethods();
    _fetchOrderStatuses();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };

    if (_selectedOrderStatusIdFilter != null) {
      queryParams['OrderStatusId'] = _selectedOrderStatusIdFilter.toString();
    }

    if (_fromDateIso != null && _fromDateIso!.isNotEmpty) {
      queryParams['FromDate'] = _fromDateIso!;
    }
    if (_toDateIso != null && _toDateIso!.isNotEmpty) {
      queryParams['ToDate'] = _toDateIso!;
    }

    if (searchQuery.length >= 2) {
      queryParams['User'] = searchQuery;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${dotenv.env['API_BASE_URL']}/orders",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        orders = result;
        hasNextPage = result.length == pageSize;
        isLoading = false;
      });
    } else {
      setState(() {
        orders = [];
        isLoading = false;
      });
    }
  }

  Future<void> _fetchDeliveryMethods() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/delivery-methods"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        deliveryMethods = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchDeliveryStatuses() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/delivery-statuses"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        deliveryStatuses = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchPaymentMethods() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/payment-methods"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        paymentMethods = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchOrderStatuses() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/order-statuses"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        orderStatuses = jsonDecode(response.body);
      });
    }
  }

  Future<void> _updateOrder(int id) async {
    final response = await httpClient.put(
      Uri.parse("${dotenv.env['API_BASE_URL']}/orders/$id"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'orderStatusId': _selectedOrderStatusId,
        'paymentMethodId': _selectedPaymentMethodId,
        'delivery': {
          'deliveryMethodId': _selectedDeliveryMethodId,
          'deliveryStatusId': _selectedDeliveryStatusId,
          'deliveryDate': _deliveryDateIso,
        },
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      _clearForm();
      _fetchOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Narudžba je uspješno ažurirana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri ažuriranju narudžbe.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _clearForm() {
    _selectedDeliveryMethodId = null;
    _selectedDeliveryStatusId = null;
    _selectedPaymentMethodId = null;
    _selectedOrderStatusId = null;
    _deliveryDateController.clear();
    editingId = null;
    setState(() => showForm = false);
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchOrders();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchOrders();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return showForm
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Uredi narudžbu",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField<dynamic>(
                    value: _selectedOrderStatusId,
                    items: orderStatuses,
                    label: "Status narudžbe",
                    validator: (value) =>
                        value == null ? 'Odaberite status narudžbe' : null,
                    onChanged: (value) =>
                        setState(() => _selectedOrderStatusId = value),
                    itemLabel: (s) => s['name'],
                    itemValue: (s) => s['orderStatusId'],
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField<dynamic>(
                    value: _selectedPaymentMethodId,
                    items: paymentMethods,
                    label: "Metoda plaćanja",
                    validator: (_) => null,
                    onChanged: (value) =>
                        setState(() => _selectedPaymentMethodId = value),
                    itemLabel: (p) => p['name'],
                    itemValue: (p) => p['paymentMethodId'],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Detalji dostave",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField<dynamic>(
                    value: _selectedDeliveryMethodId,
                    items: deliveryMethods,
                    label: "Metoda dostave",
                    validator: (value) =>
                        value == null ? 'Odaberite metodu' : null,
                    onChanged: (value) =>
                        setState(() => _selectedDeliveryMethodId = value),
                    itemLabel: (m) => m['name'],
                    itemValue: (m) => m['deliveryMethodId'],
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField<dynamic>(
                    value: _selectedDeliveryStatusId,
                    items: deliveryStatuses,
                    label: "Status dostave",
                    validator: (value) =>
                        value == null ? 'Odaberite status' : null,
                    onChanged: (value) =>
                        setState(() => _selectedDeliveryStatusId = value),
                    itemLabel: (s) => s['name'],
                    itemValue: (s) => s['deliveryStatusId'],
                  ),
                  const SizedBox(height: 16),
                  buildDatePickerField(
                    context: context,
                    controller: _deliveryDateController,
                    label: "Datum najkasnije dostave",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite datum dostave';
                      }
                      return null;
                    },
                    onPicked: (iso) => _deliveryDateIso = iso,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _updateOrder(editingId!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Uredi",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _clearForm,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2A2A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text("Nazad"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Narudžbe",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (_) => _onSearchChanged(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pretraži po imenu ili prezimenu korisnika..',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: buildDatePickerField(
                      context: context,
                      controller: _fromDateController,
                      label: "Datum od",
                      validator: (_) => null,
                      onPicked: (iso) {
                        _fromDateIso = iso;
                        _onSearchChanged();
                      },
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildDatePickerField(
                      context: context,
                      controller: _toDateController,
                      label: "Datum do",
                      validator: (_) => null,
                      onPicked: (iso) {
                        _toDateIso = iso;
                        _onSearchChanged();
                      },
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    ),
                  ),
                ],
              ),
              if (orderStatuses.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<int>(
                    value: _selectedOrderStatusIdFilter,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                      labelText: 'Filtriraj po statusu narudžbe',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color(0xFF1E1E1E),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text(
                          "Svi statusi",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      ...orderStatuses.map<DropdownMenuItem<int>>((status) {
                        return DropdownMenuItem<int>(
                          value: status['orderStatusId'],
                          child: Text(status['name']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedOrderStatusIdFilter = value;
                      });
                      _fetchOrders();
                    },
                  ),
                ),

              const SizedBox(height: 12),

              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : orders.isEmpty
                    ? const Center(
                        child: Text(
                          "Nema dostupnih narudžbi.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${order['user']['firstName']} ${order['user']['lastName']}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.credit_card,
                                            color: Colors.white54,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            order['paymentMethod']['name'],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.receipt_long,
                                            color: Colors.white54,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            order['orderStatus']['name'],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Stavke narudžbe",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      ...order['orderItems'].map<Widget>((
                                        item,
                                      ) {
                                        return Text(
                                          "${item['quantity']}x ${item['part']['name']} (${item['part']['catalogNumber']})",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Ukupno",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "${order['totalAmount'].toStringAsFixed(2)} KM",
                                        style: const TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Datum narudžbe",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd.MM.yyyy').format(
                                          DateTime.parse(
                                            order['orderDate'],
                                          ).toLocal(),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white70,
                                  ),
                                  tooltip: 'Uredi',
                                  onPressed: () {
                                    setState(() {
                                      editingId = order['orderId'];
                                      _selectedDeliveryMethodId =
                                          order['delivery']['deliveryMethodId'];
                                      _selectedDeliveryStatusId =
                                          order['delivery']['deliveryStatusId'];
                                      final deliveryDate =
                                          order['delivery']['deliveryDate'];
                                      _deliveryDateController.text =
                                          DateFormat('dd.MM.yyyy').format(
                                            DateTime.parse(
                                              deliveryDate,
                                            ).toLocal(),
                                          );
                                      _deliveryDateIso = deliveryDate;
                                      _selectedPaymentMethodId =
                                          order['paymentMethodId'];
                                      _selectedOrderStatusId =
                                          order['orderStatusId'];
                                      showForm = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              PaginationControls(
                currentPage: currentPage,
                hasNextPage: hasNextPage,
                onPrevious: _goToPreviousPage,
                onNext: _goToNextPage,
              ),
            ],
          );
  }
}
