import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';

class PartPage extends StatefulWidget {
  const PartPage({super.key});

  @override
  State<PartPage> createState() => _PartPageState();
}

class _PartPageState extends State<PartPage> {
  List<dynamic> parts = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingId;
  File? _selectedImage;
  String? _existingImageBase64;

  List<dynamic> manufacturersList = [];
  List<dynamic> categoriesList = [];
  int? _selectedManufacturerId;
  int? _selectedCategoryId;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _catalogController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _priceController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _soldController = TextEditingController();
  final _manufacturerIdController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _arrivalDaysController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchParts();
    _fetchManufacturers();
    _fetchCategories();
  }

  Future<void> _fetchParts() async {
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
        "${EnvConfig.baseUrl}/parts",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        hasNextPage = result.length == pageSize + 1;
        parts = hasNextPage ? result.take(pageSize).toList() : result;
        isLoading = false;
      });
    } else {
      setState(() {
        parts = [];
        isLoading = false;
      });
    }
  }

  Future<void> _fetchManufacturers() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/manufacturers"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        manufacturersList = jsonDecode(response.body);
      });
    }
  }

  Future<void> _fetchCategories() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/categories"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() {
        categoriesList = jsonDecode(response.body);
      });
    }
  }

  Future<void> _addPart() async {
    final uri = Uri.parse("${EnvConfig.baseUrl}/parts");
    final request = http.MultipartRequest('POST', uri);

    request.fields['Name'] = _nameController.text.trim();
    request.fields['CatalogNumber'] = _catalogController.text.trim();
    request.fields['Description'] = _descriptionController.text.trim().isEmpty
        ? ''
        : _descriptionController.text.trim();
    request.fields['Weight'] = _weightController.text.trim().isEmpty
        ? ''
        : "${_weightController.text.replaceAll("kg", "").trim()}kg";
    request.fields['Price'] = (_priceController.text.trim());
    request.fields['WarrantyMonths'] = _warrantyController.text.trim();
    request.fields['Quantity'] = _quantityController.text.trim();
    request.fields['TotalSold'] = _soldController.text.trim();
    request.fields['ManufacturerId'] = _selectedManufacturerId.toString();
    request.fields['CategoryId'] = _selectedCategoryId.toString();
    request.fields['EstimatedArrivalDays'] = _arrivalDaysController.text.trim();

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Image', _selectedImage!.path),
      );
    }

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _clearForm();
      _fetchParts();
      _showSuccess("Dio uspješno dodan.");
    } else {
      _showError(response, "Greška pri dodavanju dijela.");
    }
  }

  Future<void> _updatePart(int id) async {
    final uri = Uri.parse("${EnvConfig.baseUrl}/parts/$id");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['Name'] = _nameController.text.trim();
    request.fields['CatalogNumber'] = _catalogController.text.trim();
    request.fields['Description'] = _descriptionController.text.trim().isEmpty
        ? ''
        : _descriptionController.text.trim();
    request.fields['Weight'] = _weightController.text.trim().isEmpty
        ? ''
        : "${_weightController.text.replaceAll("kg", "").trim()}kg";
    request.fields['Price'] = _priceController.text.trim();
    request.fields['WarrantyMonths'] = _warrantyController.text.trim();
    request.fields['Quantity'] = _quantityController.text.trim();
    request.fields['TotalSold'] = _soldController.text.trim();
    request.fields['ManufacturerId'] = _selectedManufacturerId.toString();
    request.fields['CategoryId'] = _selectedCategoryId.toString();
    request.fields['EstimatedArrivalDays'] = _arrivalDaysController.text.trim();

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('Image', _selectedImage!.path),
      );
    }

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 204) {
      _clearForm();
      _fetchParts();
      _showSuccess("Dio ažuriran.");
    } else {
      _showError(response, "Greška pri ažuriranju dijela.");
    }
  }

  Future<void> _deletePartConfirmed(int id) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/parts/$id"),
    );

    if (response.statusCode == 204) {
      _fetchParts();
      _showSuccess("Dio obrisan.");
    } else {
      _showError(response, "Greška pri brisanju dijela.");
    }
  }

  void _deletePart(BuildContext context, dynamic part) {
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
            "Jeste li sigurni da želite obrisati dio \"${part['name']}\"?",
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
                _deletePartConfirmed(part['partId']);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _catalogController.clear();
    _descriptionController.clear();
    _weightController.clear();
    _priceController.clear();
    _warrantyController.clear();
    _quantityController.clear();
    _soldController.clear();
    _manufacturerIdController.clear();
    _categoryIdController.clear();
    _arrivalDaysController.clear();
    editingId = null;
    _existingImageBase64 = null;
    _selectedImage = null;
    setState(() => showForm = false);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(response, String fallback) {
    final errorMessage = extractErrorMessage(response, fallback: fallback);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchParts();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchParts();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchParts();
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
                    editingId != null ? "Uredi dio" : "Dodaj dio",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _nameController,
                    label: "Naziv dijela",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }
                      if (value.length < 2 || value.length > 100) {
                        return 'Mora imati između 2 i 100 karaktera';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _catalogController,
                    label: "Kataloški broj",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }
                      if (value.length < 2 || value.length > 100) {
                        return 'Mora imati između 2 i 100 karaktera';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _descriptionController,
                    label: "Opis",
                    validator: (value) {
                      if (value != null && value.length > 500) {
                        return 'Opis može imati najviše 500 karaktera';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _weightController,
                    label: "Težina (kg)",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }

                      final trimmed = value.replaceAll('kg', '').trim();

                      if (trimmed == '.' || trimmed.contains('.')) {
                        return 'Koristite zarez (,) kao decimalni separator, npr. 0,3';
                      }

                      final regex = RegExp(r'^\d+(,\d{1,2})?$');
                      if (!regex.hasMatch(trimmed)) {
                        return 'Unesite broj između 0,1 i 100 (npr. 0,3)';
                      }

                      final parsed = double.tryParse(
                        trimmed.replaceAll(',', '.'),
                      );
                      if (parsed == null || parsed < 0.1 || parsed > 100) {
                        return 'Vrijednost mora biti između 0,1 i 100';
                      }

                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _priceController,
                    label: "Cijena",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }

                      final trimmed = value.trim();

                      if (trimmed == '.' || trimmed.contains('.')) {
                        return 'Koristite zarez (,) kao decimalni separator, npr. 19,99';
                      }

                      final regex = RegExp(r'^\d+(,\d{1,2})?$');
                      if (!regex.hasMatch(trimmed)) {
                        return 'Unesite broj s najviše dvije decimale, npr. 19,99';
                      }

                      return null;
                    },
                  ),

                  buildInputField(
                    controller: _warrantyController,
                    label: "Garancija (mj)",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Unesite validan broj';
                      }
                      return null;
                    },
                  ),
                  buildInputField(
                    controller: _quantityController,
                    label: "Količina",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Unesite validan broj';
                      }
                      return null;
                    },
                  ),
                  buildDropdownField<dynamic>(
                    value: manufacturersList.firstWhere(
                      (m) => m['manufacturerId'] == _selectedManufacturerId,
                      orElse: () => null,
                    ),
                    items: manufacturersList,
                    label: "Proizvođač",
                    validator: (value) =>
                        value == null ? 'Odaberite proizvođača' : null,
                    onChanged: (value) => setState(
                      () => _selectedManufacturerId = value?['manufacturerId'],
                    ),
                    itemLabel: (m) => m['name'],
                    itemValue: (m) => m,
                  ),
                  const SizedBox(height: 16),
                  buildDropdownField<dynamic>(
                    value: categoriesList.firstWhere(
                      (c) => c['categoryId'] == _selectedCategoryId,
                      orElse: () => null,
                    ),
                    items: categoriesList,
                    label: "Kategorija",
                    validator: (value) =>
                        value == null ? 'Odaberite kategoriju' : null,
                    onChanged: (value) => setState(
                      () => _selectedCategoryId = value?['categoryId'],
                    ),
                    itemLabel: (c) => c['name'],
                    itemValue: (c) => c,
                  ),

                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _arrivalDaysController,
                    label: "Procijenjeni dani dolaska",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Obavezno polje';
                      }
                      return null;
                    },
                  ),
                  Text(
                    "Slika dijela",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  buildImagePickerPreview(
                    selectedImage: _selectedImage,
                    existingBase64Image: _existingImageBase64,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            editingId != null
                                ? _updatePart(editingId!)
                                : _addPart();
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
                    "Dijelovi",
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
                      "Dodaj dio",
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
                  hintText: 'Pretraži po nazivu dijela ili kataloškom broju..',
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
                    : parts.isEmpty
                    ? const Center(
                        child: Text(
                          "Nema dostupnih dijelova.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: parts.length,
                        itemBuilder: (context, index) {
                          final part = parts[index];
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
                                part['imageData'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(part['imageData']),
                                          width: 70,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Container(
                                        width: 70,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2C2C2C),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.build_circle_outlined,
                                          color: Colors.white38,
                                          size: 36,
                                        ),
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        part['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Kataloški broj: ${part['catalogNumber']}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Cijena: ${part['price']} KM",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "Na stanju: ${part['quantity']} • Prodano: ${part['totalSold']}",
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 13,
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
                                        editingId = part['partId'];
                                        _nameController.text =
                                            part['name'] ?? '';
                                        _catalogController.text =
                                            part['catalogNumber'] ?? '';
                                        _descriptionController.text =
                                            part['description'] ?? '';
                                        _weightController.text =
                                            part['weight'] ?? '';
                                        _priceController.text = NumberFormat(
                                          '#,##0.##',
                                          'de_DE',
                                        ).format(part['price']);

                                        _warrantyController.text =
                                            part['warrantyMonths'].toString();
                                        _quantityController.text =
                                            part['quantity'].toString();
                                        _soldController.text = part['totalSold']
                                            .toString();
                                        _selectedManufacturerId =
                                            part['manufacturerId'];
                                        _selectedCategoryId =
                                            part['categoryId'];
                                        _arrivalDaysController.text =
                                            part['estimatedArrivalDays']
                                                .toString();
                                        _existingImageBase64 =
                                            part['imageData'];
                                        _selectedImage = null;
                                        showForm = true;
                                      });
                                    } else if (value == 'delete') {
                                      _deletePart(context, part);
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
