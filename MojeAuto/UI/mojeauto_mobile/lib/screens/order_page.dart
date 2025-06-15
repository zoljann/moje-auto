import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/helpers/error_extractor.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';
import 'package:mojeauto_mobile/helpers/notification_helper.dart';
import 'package:mojeauto_mobile/common/form_fields.dart';

class OrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const OrderPage({super.key, required this.cartItems});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  List<dynamic> _paymentMethods = [];
  List<dynamic> _deliveryMethods = [];
  List<dynamic> _countries = [];

  String? _selectedPaymentMethodId;
  String? _selectedDeliveryMethodId;
  String? _selectedCountryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
    _fetchDeliveryMethods();
    _fetchCountries();
    _fetchUserData();
  }

  Future<void> _fetchPaymentMethods() async {
    final res = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/payment-methods"),
    );
    if (res.statusCode == 200) {
      setState(() => _paymentMethods = jsonDecode(res.body));
    }
  }

  Future<void> _fetchDeliveryMethods() async {
    final res = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/delivery-methods"),
    );
    if (res.statusCode == 200) {
      setState(() => _deliveryMethods = jsonDecode(res.body));
    }
  }

  Future<void> _fetchCountries() async {
    final res = await http.get(Uri.parse("${EnvConfig.baseUrl}/countries"));
    if (res.statusCode == 200) {
      setState(() => _countries = jsonDecode(res.body));
    }
  }

  Future<void> _fetchUserData() async {
    final userId = await TokenManager().userId;
    final res = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/users?id=$userId"),
    );
    if (res.statusCode == 200) {
      final user = jsonDecode(res.body);
      setState(() {
        _addressController.text = user['address'] ?? '';
        _phoneController.text = user['phoneNumber'] ?? '';
        _selectedCountryId = user['countryId']?.toString();
      });
    }
  }

  double _calculateTotal() {
    return widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item['price'] * item['quantity'],
    );
  }

  Future<void> _updateUser() async {
    final userId = await TokenManager().userId;
    final uri = Uri.parse("${EnvConfig.baseUrl}/users/$userId");
    final req = http.MultipartRequest('PUT', uri);
    req.fields['address'] = _addressController.text.trim();
    req.fields['phoneNumber'] = _phoneController.text.trim();
    req.fields['countryId'] = _selectedCountryId!;
    await req.send();
  }

  Future<void> _placeOrder({String? paymentIntentId}) async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await TokenManager().userId;
    if (userId == null) return;

    await _updateUser();

    final orderItems = widget.cartItems
        .map(
          (item) => {
            "partId": item['partId'],
            "quantity": item['quantity'],
            "unitPrice": item['price'],
          },
        )
        .toList();

    final body = jsonEncode({
      "userId": userId,
      "paymentMethodId": int.parse(_selectedPaymentMethodId!),
      "delivery": {
        "deliveryMethodId": int.parse(_selectedDeliveryMethodId!),
        "deliveryStatusId": 1,
      },
      "orderItems": orderItems,
      if (paymentIntentId != null) "paymentReference": paymentIntentId,
    });

    setState(() => _isLoading = true);
    final response = await http.post(
      Uri.parse("${EnvConfig.baseUrl}/orders"),
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    setState(() => _isLoading = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      final error = extractErrorMessage(
        response,
        fallback: "Greška pri kreiranju narudžbe.",
      );
      NotificationHelper.error(context, error);
    }
  }

  Future<void> _createPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = await TokenManager().userId;
    if (userId == null) return;

    await _updateUser();

    final totalAmount = _calculateTotal();
    final convertedAmount = double.parse(
      (totalAmount / 1.95583).toStringAsFixed(2),
    );

    final res = await http.post(
      Uri.parse('${EnvConfig.baseUrl}/orders/stripe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': convertedAmount}),
    );

    if (res.statusCode != 200) {
      NotificationHelper.error(context, 'Greška pri kreiranju plaćanja.');
      return;
    }

    final data = jsonDecode(res.body);
    final clientSecret = data['clientSecret'];
    final paymentIntentId = data['paymentIntentId'];

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
          merchantDisplayName: 'MojeAuto',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      await _placeOrder(paymentIntentId: paymentIntentId);

      if (!mounted) return;
    } on StripeException {
      if (!mounted) return;
      NotificationHelper.error(context, "Plaćanje otkazano");
    } catch (e) {
      if (!mounted) return;
      NotificationHelper.error(context, "Plaćanje otkazano ili neuspješno.");
    }
  }

  String _getPaymentButtonText() {
    if (_selectedPaymentMethodId == null) return "Potvrdi narudžbu";
    final selected = _paymentMethods.firstWhere(
      (p) => p['paymentMethodId'].toString() == _selectedPaymentMethodId,
      orElse: () => null,
    );
    if (selected == null) return "Potvrdi narudžbu";
    final name = selected['name'].toString().toLowerCase();
    return name == 'stripe' ? "Plaćanje" : "Potvrdi narudžbu";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A1C),
        centerTitle: true,
        title: const Text("Završi narudžbu"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDropdownField<String>(
                          value: _selectedPaymentMethodId,
                          items: _paymentMethods
                              .map((p) => p['paymentMethodId'].toString())
                              .toList(),
                          label: 'Način plaćanja',
                          validator: (val) =>
                              val == null ? 'Odaberite plaćanje' : null,
                          onChanged: (val) =>
                              setState(() => _selectedPaymentMethodId = val),
                          itemLabel: (val) => _paymentMethods.firstWhere(
                            (p) => p['paymentMethodId'].toString() == val,
                          )['name'],
                          itemValue: (val) => val,
                        ),
                        const SizedBox(height: 16),
                        buildDropdownField<String>(
                          value: _selectedDeliveryMethodId,
                          items: _deliveryMethods
                              .map((d) => d['deliveryMethodId'].toString())
                              .toList(),
                          label: 'Način dostave',
                          validator: (val) =>
                              val == null ? 'Odaberite dostavu' : null,
                          onChanged: (val) =>
                              setState(() => _selectedDeliveryMethodId = val),
                          itemLabel: (val) => _deliveryMethods.firstWhere(
                            (d) => d['deliveryMethodId'].toString() == val,
                          )['name'],
                          itemValue: (val) => val,
                        ),
                        const SizedBox(height: 24),
                        buildDropdownField<String>(
                          value: _selectedCountryId,
                          items: _countries
                              .map((c) => c['countryId'].toString())
                              .toList(),
                          label: 'Država',
                          validator: (val) =>
                              val == null ? 'Odaberite državu' : null,
                          onChanged: (val) =>
                              setState(() => _selectedCountryId = val),
                          itemLabel: (val) => _countries.firstWhere(
                            (c) => c['countryId'].toString() == val,
                          )['name'],
                          itemValue: (val) => val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          style: const TextStyle(color: Colors.white),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Unesite adresu';
                            }
                            if (val.length < 3 || val.length > 100) {
                              return 'Adresa mora imati između 3 i 100 karaktera';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Adresa',
                            filled: true,
                            fillColor: const Color(0xFF2A2D31),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            final regex = RegExp(r'^\d{3,20}$');
                            if (val == null || val.isEmpty) {
                              return 'Unesite broj telefona';
                            }
                            if (!regex.hasMatch(val)) {
                              return 'Broj mora sadržavati 3-20 cifara';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Broj telefona',
                            filled: true,
                            fillColor: const Color(0xFF2A2D31),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Ukupno:",
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "${_calculateTotal().toStringAsFixed(2)} KM",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7D5EFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () {
                            final selected = _paymentMethods.firstWhere(
                              (p) =>
                                  p['paymentMethodId'].toString() ==
                                  _selectedPaymentMethodId,
                              orElse: () => null,
                            );

                            if (selected != null &&
                                selected['name'].toString().toLowerCase() ==
                                    'stripe') {
                              _createPayment();
                            } else {
                              _placeOrder();
                            }
                          },

                          child: Text(
                            _getPaymentButtonText(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
