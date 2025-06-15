import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';
import 'package:mojeauto_admin/env_config.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<dynamic> categories = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
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
        "${EnvConfig.baseUrl}/categories",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        hasNextPage = result.length == pageSize + 1;
        categories = hasNextPage ? result.take(pageSize).toList() : result;
        isLoading = false;
      });
    } else {
      setState(() {
        categories = [];
        isLoading = false;
      });
    }
  }

  Future<void> _addCategory() async {
    final response = await httpClient.post(
      Uri.parse("${EnvConfig.baseUrl}/categories"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _clearForm();
      _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategorija uspješno dodana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri dodavanju kategorije.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateCategory(int id) async {
    final response = await httpClient.put(
      Uri.parse("${EnvConfig.baseUrl}/categories/$id"),
      headers: {'Content-Type': 'application/json', 'accept': 'text/plain'},
      body: jsonEncode({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? '\u200B'
            : _descriptionController.text.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      _clearForm();
      _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategorija ažurirana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri ažuriranju kategorije.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteCategoryConfirmed(int id) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/categories/$id"),
    );

    if (response.statusCode == 204) {
      _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kategorija obrisana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage = extractErrorMessage(
        response,
        fallback: "Greška pri brisanju kategorije.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteCategory(BuildContext context, dynamic category) {
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
            "Jeste li sigurni da želite obrisati kategoriju \"${category['name']}\"?",
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
                _deleteCategoryConfirmed(category['categoryId']);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    editingId = null;
    setState(() => showForm = false);
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchCategories();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchCategories();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchCategories();
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
                    editingId != null ? "Uredi kategoriju" : "Dodaj kategoriju",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _nameController,
                    label: "Naziv kategorije",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unesite naziv kategorije';
                      }

                      final trimmed = value.trim();
                      if (trimmed.length < 2 || trimmed.length > 100) {
                        return 'Naziv mora imati između 2 i 100 karaktera';
                      }

                      final lettersOnly = RegExp(r'^[a-zA-ZčćžšđČĆŽŠĐ\s]+$');
                      if (!lettersOnly.hasMatch(trimmed)) {
                        return 'Naziv smije sadržavati samo slova';
                      }

                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _descriptionController,
                    label: "Opis (opcionalno)",
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final trimmed = value.trim();
                        if (trimmed.length > 500) {
                          return 'Opis može imati najviše 500 karaktera';
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
                              _updateCategory(editingId!);
                            } else {
                              _addCategory();
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
                    "Kategorije",
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
                      "Dodaj kategoriju",
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
                  hintText: 'Pretraži po nazivu kategorije..',
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
                    : categories.isEmpty
                    ? const Center(
                        child: Text(
                          "Nema dostupnih kategorija.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cat['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (cat['description'] != null &&
                                          cat['description']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            cat['description'],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
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
                                        editingId = cat['categoryId'];
                                        _nameController.text = cat['name'];
                                        _descriptionController.text =
                                            cat['description'] ?? '';
                                        showForm = true;
                                      });
                                    } else if (value == 'delete') {
                                      _deleteCategory(context, cat);
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
