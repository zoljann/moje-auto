import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  List<dynamic> countries = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _isoCodeController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
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
        "${EnvConfig.baseUrl}/countries",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        hasNextPage = result.length == pageSize + 1;
        countries = hasNextPage ? result.take(pageSize).toList() : result;
        isLoading = false;
      });
    } else {
      setState(() {
        countries = [];
        isLoading = false;
      });
    }
  }

  Future<void> _addCountry() async {
    final response = await httpClient.post(
      Uri.parse("${EnvConfig.baseUrl}/countries"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'isoCode': _isoCodeController.text.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _clearForm();
      _fetchCountries();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Država uspješno dodana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri dodavanju države.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateCountry(int id) async {
    final response = await httpClient.put(
      Uri.parse("${EnvConfig.baseUrl}/countries/$id"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'isoCode': _isoCodeController.text.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      _clearForm();
      _fetchCountries();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Država ažurirana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri ažuriranju države.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteCountryConfirmed(int id) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/countries/$id"),
    );

    if (response.statusCode == 204) {
      _fetchCountries();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Država obrisana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri brisanju države.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteCountry(BuildContext context, dynamic country) {
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
            "Jeste li sigurni da želite obrisati državu \"${country['name']}\"?",
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
                _deleteCountryConfirmed(country['countryId']);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _isoCodeController.clear();
    editingId = null;
    setState(() {
      showForm = false;
    });
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchCountries();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchCountries();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchCountries();
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
                    editingId != null ? "Uredi državu" : "Dodaj državu",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _nameController,
                    label: "Naziv države",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite naziv države';
                      }
                      if (value.length < 2 || value.length > 100) {
                        return 'Naziv mora imati između 2 i 100 karaktera';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _isoCodeController,
                    label: "ISO kod (opcionalno)",
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (value.length < 2 || value.length > 3) {
                          return 'ISO kod mora imati između 2 i 3 karaktera';
                        }
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
                              _updateCountry(editingId!);
                            } else {
                              _addCountry();
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
                    "Države",
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
                      "Dodaj državu",
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
                  hintText: 'Pretraži po nazivu države..',
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
                    : countries.isEmpty
                    ? const Center(
                        child: Text(
                          "Nema dostupnih država.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final country = countries[index];
                          final iso = country['isoCode'] ?? "";
                          final label = iso.isNotEmpty
                              ? "${country['name']} ($iso)"
                              : country['name'];
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
                                  label,
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
                                        editingId = country['countryId'];
                                        _nameController.text = country['name'];
                                        _isoCodeController.text =
                                            country['isoCode'] ?? '';
                                        showForm = true;
                                      });
                                    } else if (value == 'delete') {
                                      _deleteCountry(context, country);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Uredi',
                                        style: TextStyle(
                                          color: Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
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
