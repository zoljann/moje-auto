import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';

class ManufacturerPage extends StatefulWidget {
  const ManufacturerPage({super.key});

  @override
  State<ManufacturerPage> createState() => _ManufacturerPageState();
}

class _ManufacturerPageState extends State<ManufacturerPage> {
  List<dynamic> manufacturers = [];
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
  int? _selectedCountryId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _fetchManufacturers();
  }

  Future<void> _fetchCountries() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/countries"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        countries = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchManufacturers() async {
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
        "${dotenv.env['API_BASE_URL']}/manufacturers",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        manufacturers = result;
        hasNextPage = result.length == pageSize;
        isLoading = false;
      });
    } else {
      setState(() {
        manufacturers = [];
        isLoading = false;
      });
    }
  }

  Future<void> _addManufacturer() async {
    final response = await httpClient.post(
      Uri.parse("${dotenv.env['API_BASE_URL']}/manufacturers"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'countryId': _selectedCountryId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _clearForm();
      _fetchManufacturers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Proizvođač uspješno dodan."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri dodavanju proizvođača.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateManufacturer(int id) async {
    final response = await httpClient.put(
      Uri.parse("${dotenv.env['API_BASE_URL']}/manufacturers/$id"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'countryId': _selectedCountryId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      _clearForm();
      _fetchManufacturers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Proizvođač ažuriran."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri ažuriranju proizvođača.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteManufacturerConfirmed(int id) async {
    final response = await httpClient.delete(
      Uri.parse("${dotenv.env['API_BASE_URL']}/manufacturers/$id"),
    );

    if (response.statusCode == 204) {
      _fetchManufacturers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Proizvođač obrisan."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri brisanju proizvođača.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteManufacturer(BuildContext context, dynamic manufacturer) {
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
            "Jeste li sigurni da želite obrisati proizvođača \"${manufacturer['name']}\"?",
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
                _deleteManufacturerConfirmed(manufacturer['manufacturerId']);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _selectedCountryId = null;
    editingId = null;
    setState(() => showForm = false);
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchManufacturers();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchManufacturers();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchManufacturers();
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
                        ? "Uredi proizvođača"
                        : "Dodaj proizvođača",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _nameController,
                    label: "Naziv proizvođača",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Unesite naziv proizvođača';
                      }
                      if (value.length < 2 || value.length > 100) {
                        return 'Naziv mora imati između 2 i 100 karaktera';
                      }
                      return null;
                    },
                  ),
                  buildDropdownField<dynamic>(
                    value: _selectedCountryId,
                    items: countries,
                    label: "Država",
                    validator: (value) =>
                        value == null ? 'Odaberite državu' : null,
                    onChanged: (value) =>
                        setState(() => _selectedCountryId = value),
                    itemLabel: (c) => c['name'],
                    itemValue: (c) => c['countryId'],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (editingId != null) {
                              _updateManufacturer(editingId!);
                            } else {
                              _addManufacturer();
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
                    "Proizvođači",
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
                      "Dodaj proizvođača",
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
                  hintText: 'Pretraži po nazivu proizvođača..',
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
                    : manufacturers.isEmpty
                    ? const Center(
                        child: Text(
                          "Nema dostupnih proizvođača.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: manufacturers.length,
                        itemBuilder: (context, index) {
                          final item = manufacturers[index];
                          final countryName = countries.firstWhere(
                            (c) => c['countryId'] == item['countryId'],
                            orElse: () => null,
                          )?['name'];

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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (countryName != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          "Država: $countryName",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                  ],
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
                                        editingId = item['manufacturerId'];
                                        _nameController.text = item['name'];
                                        _selectedCountryId = item['countryId'];
                                        showForm = true;
                                      });
                                    } else if (value == 'delete') {
                                      _deleteManufacturer(context, item);
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
