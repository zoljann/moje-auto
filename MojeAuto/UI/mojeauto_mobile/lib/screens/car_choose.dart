import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/screens/part_search.dart';

class CarChoose extends StatefulWidget {
  const CarChoose({super.key});

  @override
  State<CarChoose> createState() => _CarChooseState();
}

class _CarChooseState extends State<CarChoose> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allCars = [];
  List<dynamic> _filteredCars = [];
  List<dynamic> _categories = [];
  List<dynamic> _filteredCategories = [];
  bool isLoadingCars = false;
  bool isLoadingCategories = false;
  Map<String, dynamic>? _selectedCar;
  int _carsToShow = 6;
  bool _isSearching = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
    _fetchCars();
    _fetchCategories();
  }

  Future<void> _fetchCars() async {
    setState(() => isLoadingCars = true);
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/cars"),
      headers: {'accept': 'text/plain'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _allCars = jsonDecode(response.body);
        isLoadingCars = false;
      });
    }
  }

  Future<void> _fetchCarById(int carId) async {
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/cars?id=$carId"),

      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final carData = jsonDecode(response.body);
      setState(() => _selectedCar = carData);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(0);
      });
    }
  }

  Future<void> _fetchCategories() async {
    setState(() => isLoadingCategories = true);
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/categories"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        _categories = result;
        _filteredCategories = result;
        isLoadingCategories = false;
      });
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _categories
          .where(
            (cat) => cat['name'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  void _searchCars(String query) {
    final lower = query.toLowerCase().trim();

    setState(() {
      _isSearching = lower.isNotEmpty;

      if (_isSearching) {
        _filteredCars = _allCars.where((car) {
          return car['brand'].toString().toLowerCase().contains(lower) ||
              car['model'].toString().toLowerCase().contains(lower) ||
              car['vin'].toString().toLowerCase().contains(lower);
        }).toList();
      } else {
        _filteredCars = [];
      }
    });
  }

  Widget _buildSelectedCarHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedCar!['imageData'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              base64Decode(_selectedCar!['imageData']),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3D41),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_filled,
                color: Colors.white70,
                size: 60,
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          "${_selectedCar!['brand']} ${_selectedCar!['model']} (${_selectedCar!['year']})",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.engineering, color: Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text(
              _selectedCar!['engine'],
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.local_gas_station, color: Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text(
              _selectedCar!['fuel'],
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.grey, size: 20),
            const SizedBox(width: 6),
            Text(
              "VIN: ${_selectedCar!['vin']}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySearch(InputBorder border, Color fieldFillColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kategorije",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: _filterCategories,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Pretraži kategorije...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: fieldFillColor,
            border: border,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCarTile(dynamic car, Color fieldFillColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fieldFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          final carId = int.parse(car['carId'].toString());
          _fetchCarById(carId);
          setState(() => _filteredCars = []);
        },
        leading: car['imageData'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(car['imageData']),
                  width: 64,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 64,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3D41),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  color: Colors.white70,
                  size: 28,
                ),
              ),
        title: Text(
          '${car['brand']} ${car['model']}',
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              car['engine'] ?? '',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              car['vin'] ?? '',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF181A1C);
    final fieldFillColor = const Color(0xFF2A2D31);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    final carsToDisplay = _isSearching ? _filteredCars : _allCars;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
          _selectedCar != null
              ? "${_selectedCar!['brand']} ${_selectedCar!['model']}"
              : "Odaberi automobil",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_selectedCar != null) {
              setState(() {
                _selectedCar = null;
                _filteredCategories = _categories;
                _searchController.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),

      body: Column(
        children: [
          if (_selectedCar == null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: _searchCars,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pretraži po imenu ili VIN-u',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: fieldFillColor,
                  border: border,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedCar != null) ...[
                    _buildSelectedCarHeader(),
                    const SizedBox(height: 30),
                    _buildCategorySearch(border, fieldFillColor),
                  ] else
                    ...carsToDisplay
                        .take(_carsToShow)
                        .map((car) => _buildCarTile(car, fieldFillColor)),
                  if (_isSearching && _filteredCars.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          "Nema rezultata.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),

                  if (_selectedCar == null &&
                      _carsToShow < carsToDisplay.length)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _carsToShow += 6;
                          });
                        },
                        child: const Text(
                          "Učitaj više automobila..",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (_selectedCar != null && !isLoadingCategories)
                    _filteredCategories.isNotEmpty
                        ? Column(
                            children: _filteredCategories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PartSearchPage(
                                                initialQuery: '',
                                                initialCategoryIds: [
                                                  category['categoryId'],
                                                ],
                                                initialCarIds: [
                                                  _selectedCar!['carId'],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: fieldFillColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            category['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(
                              child: Text(
                                "Nema pronađenih kategorija.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
