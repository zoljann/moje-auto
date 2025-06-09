import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<dynamic> methods = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMethods();
  }

  Future<void> _fetchMethods() async {
    setState(() => isLoading = true);

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };

    if (searchQuery.length >= 2) {
      queryParams['Name'] = searchQuery;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${EnvConfig.baseUrl}/payment-methods",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        hasNextPage = result.length == pageSize + 1;
        methods = hasNextPage ? result.take(pageSize).toList() : result;
        isLoading = false;
      });
    } else {
      setState(() {
        methods = [];
        isLoading = false;
      });
    }
  }

  Future<void> _addMethod() async {
    final response = await httpClient.post(
      Uri.parse("${EnvConfig.baseUrl}/payment-methods"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({'name': _nameController.text.trim()}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _clearForm();
      _fetchMethods();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Metoda plaćanja uspješno dodana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri dodavanju metode plaćanja.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateMethod(int id) async {
    final response = await httpClient.put(
      Uri.parse("${EnvConfig.baseUrl}/payment-methods/$id"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({'name': _nameController.text.trim()}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      _clearForm();
      _fetchMethods();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Metoda plaćanja ažurirana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri ažuriranju metode.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteMethodConfirmed(int id) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/payment-methods/$id"),
    );

    if (response.statusCode == 204) {
      _fetchMethods();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Metoda plaćanja obrisana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri brisanju metode.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteMethod(BuildContext context, dynamic method) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Potvrda brisanja",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Jeste li sigurni da želite obrisati metodu \"${method['name']}\"?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF2A2A2A),
                foregroundColor: Colors.white,
              ),
              child: const Text("Poništi"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text("Da"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMethodConfirmed(method['paymentMethodId']);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    editingId = null;
    setState(() {
      showForm = false;
    });
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchMethods();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchMethods();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchMethods();
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
                    editingId != null
                        ? "Uredi metodu plaćanja"
                        : "Dodaj metodu plaćanja",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _nameController,
                    label: "Naziv metode",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite naziv metode';
                      }
                      if (value.length < 2 || value.length > 50) {
                        return 'Naziv mora imati između 2 i 50 karaktera';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (editingId != null) {
                              _updateMethod(editingId!);
                            } else {
                              _addMethod();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          editingId != null ? "Uredi" : "Dodaj",
                          style: const TextStyle(color: Colors.white),
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
                    "Metode plaćanja",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => showForm = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Dodaj metodu",
                      style: TextStyle(color: Colors.white),
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
                  hintText: 'Pretraži po nazivu metode..',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : methods.isEmpty
                    ? const Center(
                        child: Text(
                          "Nema dostupnih metoda plaćanja.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: methods.length,
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  method['name'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                PopupMenuButton<String>(
                                  color: const Color(0xFF0F131A),
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white54,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      setState(() {
                                        editingId = method['paymentMethodId'];
                                        _nameController.text = method['name'];
                                        showForm = true;
                                      });
                                    } else if (value == 'delete') {
                                      _deleteMethod(context, method);
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Uredi',
                                        style: TextStyle(
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Obriši',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
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
