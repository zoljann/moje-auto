import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  List<dynamic> cars = [];
  bool isLoading = true;
  int currentPage = 1;
  int pageSize = 7;
  String searchQuery = "";
  bool hasNextPage = false;
  bool showForm = false;
  int? editingCarId;
  final _formKey = GlobalKey<FormState>();
  final List<String> fuelTypes = ['Dizel', 'Benzin', 'Električni'];
  File? _selectedImage;
  String? _existingImageBase64;

  final TextEditingController _searchController = TextEditingController();

  final _vinController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _engineController = TextEditingController();
  final _fuelController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fuelController.text = fuelTypes.first;
    _fetchCars();
  }

  Future<void> _addCar() async {
    final uri = Uri.parse("${dotenv.env['API_BASE_URL']}/cars");
    final request = http.MultipartRequest('POST', uri);

    request.fields['vin'] = _vinController.text.trim();
    request.fields['brand'] = _brandController.text.trim();
    request.fields['model'] = _modelController.text.trim();
    request.fields['engine'] = _engineController.text.trim();
    request.fields['fuel'] = _fuelController.text.trim();
    request.fields['year'] = _yearController.text.trim();

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Automobil uspješno dodan."),
          backgroundColor: Colors.green,
        ),
      );
      _clearForm();
      _fetchCars();
      setState(() => showForm = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Greška pri dodavanju automobila: ${response.statusCode}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchCars() async {
    setState(() {
      isLoading = true;
      cars = [];
    });

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };

    if (searchQuery.length >= 2) {
      queryParams['Brand'] = searchQuery;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${dotenv.env['API_BASE_URL']}/cars",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      setState(() {
        cars = result;
        hasNextPage = result.length == pageSize;
        isLoading = false;
      });
    } else {
      setState(() {
        cars = [];
        isLoading = false;
      });
    }
  }

  Future<void> _deleteCar(BuildContext context, int carId) async {
    final response = await httpClient.delete(
      Uri.parse("${dotenv.env['API_BASE_URL']}/cars/$carId"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Automobil je uspješno obrisan."),
          backgroundColor: Colors.green,
        ),
      );
      _fetchCars();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Greška prilikom brisanja automobila. (${response.statusCode})",
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  Future<void> _updateCar(int id) async {
    final uri = Uri.parse("${dotenv.env['API_BASE_URL']}/cars/$id");
    final request = http.MultipartRequest('PUT', uri);

    request.fields['vin'] = _vinController.text.trim();
    request.fields['brand'] = _brandController.text.trim();
    request.fields['model'] = _modelController.text.trim();
    request.fields['engine'] = _engineController.text.trim();
    request.fields['fuel'] = _fuelController.text.trim();
    request.fields['year'] = _yearController.text.trim();

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );
    }

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Automobil je uspješno ažuriran."),
          backgroundColor: Colors.green,
        ),
      );
      editingCarId = null;
      _clearForm();
      _fetchCars();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Greška pri ažuriranju: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
    _vinController.clear();
    _brandController.clear();
    _modelController.clear();
    _engineController.clear();
    _fuelController.clear();
    _yearController.clear();
    _existingImageBase64 = null;
    _selectedImage = null;
    showForm = false;
  }

  void _onSearchChanged() {
    currentPage = 1;
    searchQuery = _searchController.text.trim();
    _fetchCars();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchCars();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchCars();
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showForm) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dodavanje automobila",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _vinController,
              label: "VIN",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite VIN';
                }
                if (value.length < 5 || value.length > 50) {
                  return 'VIN mora imati između 5 i 50 znakova';
                }
                return null;
              },
            ),
            _buildInputField(
              controller: _brandController,
              label: "Brend",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite brend, npr. BMW';
                }
                if (value.length < 2 || value.length > 50) {
                  return 'Brend mora imati između 2 i 50 znakova';
                }
                return null;
              },
            ),
            _buildInputField(
              controller: _modelController,
              label: "Model",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Unesite model, npr. E90';
                }
                return null;
              },
            ),
            _buildInputField(
              controller: _engineController,
              label: "Kubikaža",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Unesite kubikažu';
                }

                final cleaned = value.trim();
                final regex = RegExp(r'^\d+(\.\d)?$');
                if (!regex.hasMatch(cleaned)) {
                  return 'Format mora biti npr. 2.5, koristite tačku';
                }

                final parsed = double.tryParse(cleaned);
                if (parsed == null || parsed <= 0 || parsed > 9.9) {
                  return 'Kubikaža mora biti veća od 0 i najviše 9.9';
                }
                return null;
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _fuelController.text.isNotEmpty
                      ? _fuelController.text
                      : null,
                  onChanged: (value) {
                    setState(() {
                      _fuelController.text = value ?? '';
                    });
                  },
                  items: fuelTypes
                      .map(
                        (fuel) =>
                            DropdownMenuItem(value: fuel, child: Text(fuel)),
                      )
                      .toList(),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Odaberite gorivo'
                      : null,
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Gorivo",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorStyle: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

            _buildInputField(
              controller: _yearController,
              label: "Godina proizvodnje",
              validator: (value) {
                final year = int.tryParse(value ?? '');
                final currentYear = DateTime.now().year;
                return (year == null || year < 1900 || year > currentYear)
                    ? 'Godina mora biti između 1900 i $currentYear'
                    : null;
              },
            ),
            Text(
              "Slika automobila",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _existingImageBase64 != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          base64Decode(_existingImageBase64!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.image_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Dodirnite za odabir slike",
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (editingCarId != null) {
                        _updateCar(editingCarId!);
                      } else {
                        _addCar();
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
                    editingCarId != null ? "Uredi" : "Dodaj",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    _vinController.clear();
                    _brandController.clear();
                    _modelController.clear();
                    _engineController.clear();
                    _fuelController.clear();
                    _yearController.clear();
                    setState(() {
                      editingCarId = null;
                      showForm = false;
                    });
                  },

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
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Automobili",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _existingImageBase64 = null;
                  _selectedImage = null;
                  showForm = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Dodaj automobil",
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
            hintText: 'Pretraži po brendu, modelu ili broju šasije..',
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
              : cars.isEmpty
              ? Center(
                  child: Text(
                    searchQuery.isNotEmpty
                        ? "Nijedan automobil ne odgovara unesenom pojmu."
                        : "Nema dostupnih automobila.",
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          car['imageData'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(car['imageData']),
                                    width: 70,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.directions_car,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${car['brand']} ${car['model']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${car['year']}. godina proizvodnje • Kubikaža: ${car['engine']} • Gorivo: ${car['fuel']} • VIN: ${car['vin']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: const Color(0xFF0F131A),
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color.fromARGB(141, 255, 255, 255),
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                setState(() {
                                  editingCarId = car['carId'];
                                  _vinController.text = car['vin'];
                                  _brandController.text = car['brand'];
                                  _modelController.text = car['model'];
                                  _engineController.text = car['engine'];
                                  _fuelController.text = car['fuel'];
                                  _yearController.text = car['year'].toString();
                                  _existingImageBase64 = car['imageData'];
                                  _selectedImage = null;
                                  showForm = true;
                                });
                              } else if (value == 'delete') {
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
                                        "Jeste li sigurni da želite obrisati automobil \"${car['brand']} ${car['model']}\"?",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
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
                                            _deleteCar(context, car['carId']);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  'Uredi',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Obriši',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w600,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              cursor: currentPage > 1
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Opacity(
                opacity: currentPage > 1 ? 1.0 : 0.3,
                child: ElevatedButton(
                  onPressed: currentPage > 1 ? _goToPreviousPage : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Prethodna"),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Stranica $currentPage",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            MouseRegion(
              cursor: hasNextPage
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Opacity(
                opacity: hasNextPage ? 1.0 : 0.3,
                child: ElevatedButton(
                  onPressed: hasNextPage ? _goToNextPage : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Sljedeća"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
