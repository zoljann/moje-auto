import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _formKey = GlobalKey<FormState>();

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
    _fetchCars();
  }

  Future<void> _addCar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final uri = Uri.parse("${dotenv.env['API_BASE_URL']}/cars");

    final response = await http.post(
      uri,
      headers: {
        'accept': 'text/plain',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "vin": _vinController.text.trim(),
        "brand": _brandController.text.trim(),
        "model": _modelController.text.trim(),
        "engine": double.tryParse(_engineController.text.trim()),
        "fuel": _fuelController.text.trim(),
        "year": int.tryParse(_yearController.text.trim()),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Automobil uspješno dodan."),
          backgroundColor: Colors.green,
        ),
      );
      _vinController.clear();
      _brandController.clear();
      _modelController.clear();
      _engineController.clear();
      _fuelController.clear();
      _yearController.clear();

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

    final uri = Uri.parse(
      "${dotenv.env['API_BASE_URL']}/cars",
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {'accept': 'text/plain'});

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.delete(
      Uri.parse("${dotenv.env['API_BASE_URL']}/cars/$carId"),
      headers: {'accept': 'text/plain', 'Authorization': 'Bearer $token'},
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
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Unesite VIN' : null,
            ),
            _buildInputField(
              controller: _brandController,
              label: "Brend",
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Unesite brend, npr. BMW'
                  : null,
            ),
            _buildInputField(
              controller: _modelController,
              label: "Model",
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Unesite model, npr. E90'
                  : null,
            ),
            _buildInputField(
              controller: _engineController,
              label: "Kubikaža",
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                return parsed == null || parsed <= 0
                    ? 'Unesite ispravnu kubikažu, npr. 2.0'
                    : null;
              },
            ),
            _buildInputField(
              controller: _fuelController,
              label: "Gorivo",
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Unesite gorivo' : null,
            ),
            _buildInputField(
              controller: _yearController,
              label: "Godina proizvodnje",
              validator: (value) {
                final year = int.tryParse(value ?? '');
                return year == null || year < 1900
                    ? 'Unesite ispravnu godinu'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _addCar();
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
                    "Dodaj",
                    style: TextStyle(color: Colors.white),
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
                    setState(() => showForm = false);
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
                setState(() => showForm = true);
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
                          const Icon(
                            Icons.directions_car,
                            color: Colors.white70,
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
                                // TODO: Edit logic
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
