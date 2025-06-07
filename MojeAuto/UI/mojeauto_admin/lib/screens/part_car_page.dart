import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';

class PartCarPage extends StatefulWidget {
  const PartCarPage({super.key});

  @override
  State<PartCarPage> createState() => _PartCarPageState();
}

class _PartCarPageState extends State<PartCarPage> {
  List<dynamic> cars = [];
  List<dynamic> parts = [];
  List<dynamic> compatibilities = [];
  Map<int, bool> expandedCars = {};
  Map<int, String> partSearchQueries = {};

  bool isLoading = true;
  bool showForm = false;
  int? selectedCarId;
  Set<int> selectedPartIds = {};
  String carSearchQuery = "";
  int currentPage = 1;
  int pageSize = 7;
  bool hasNextPage = false;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => isLoading = true);
    await Future.wait([_fetchCars(), _fetchParts(), _fetchCompatibilities()]);
    setState(() => isLoading = false);
  }

  Future<void> _fetchCars() async {
    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };
    if (carSearchQuery.length >= 2) {
      queryParams['Brand'] = carSearchQuery;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${dotenv.env['API_BASE_URL']}/cars",
      ).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      cars = jsonDecode(response.body);
      hasNextPage = cars.length == pageSize;
    }
  }

  Future<void> _fetchParts() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/parts"),
    );
    if (response.statusCode == 200) parts = jsonDecode(response.body);
  }

  Future<void> _fetchCompatibilities() async {
    final response = await httpClient.get(
      Uri.parse("${dotenv.env['API_BASE_URL']}/part-cars"),
    );
    if (response.statusCode == 200) compatibilities = jsonDecode(response.body);
  }

  Future<void> _addCompatibilities() async {
    final payload = selectedPartIds
        .map((id) => {'carId': selectedCarId, 'partId': id})
        .toList();
    final response = await httpClient.post(
      Uri.parse("${dotenv.env['API_BASE_URL']}/part-cars/batch"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _clearForm();
      await _fetchCompatibilities();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kompatibilnosti dodane."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = extractErrorMessage(
        response,
        fallback: "Greška pri dodavanju.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteCompatibilityConfirmed(dynamic pc) async {
    final response = await httpClient.delete(
      Uri.parse("${dotenv.env['API_BASE_URL']}/part-cars/${pc['partCarId']}"),
    );
    if (response.statusCode == 204) {
      await _fetchCompatibilities();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kompatibilnost obrisana."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final error = extractErrorMessage(
        response,
        fallback: "Greška pri brisanju.",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteCompatibility(
    BuildContext context,
    dynamic pc,
    dynamic partName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Potvrda brisanja",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Obrisati kompatibilnost za \"$partName\"?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A2A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Poništi"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCompatibilityConfirmed(pc);
            },
            child: const Text("Da"),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    selectedCarId = null;
    selectedPartIds.clear();
    setState(() => showForm = false);
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchAll();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return showForm ? _buildAddForm() : _buildList();
  }

  Widget _buildAddForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dodaj kompatibilnosti",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: selectedCarId,
            items: cars.map<DropdownMenuItem<int>>((car) {
              return DropdownMenuItem<int>(
                value: car['carId'],
                child: Text("${car['brand']} ${car['model']} (${car['year']})"),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCarId = value;
                selectedPartIds.clear();
              });
            },
            decoration: const InputDecoration(
              labelText: "Automobil",
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
            dropdownColor: const Color(0xFF1E1E1E),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: parts
                .where(
                  (p) =>
                      selectedCarId == null ||
                      !compatibilities.any(
                        (c) =>
                            c['carId'] == selectedCarId &&
                            c['partId'] == p['partId'],
                      ),
                )
                .map(
                  (part) => FilterChip(
                    label: Text(
                      part['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    selected: selectedPartIds.contains(part['partId']),
                    onSelected: (bool selected) {
                      setState(() {
                        selected
                            ? selectedPartIds.add(part['partId'])
                            : selectedPartIds.remove(part['partId']);
                      });
                    },
                    backgroundColor: const Color(0xFF2A2A2A),
                    selectedColor: const Color(0xFF3B82F6),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: selectedCarId != null && selectedPartIds.isNotEmpty
                    ? _addCompatibilities
                    : null,
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
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Kompatibilnosti",
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
                "Dodaj kompatibilnosti",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              currentPage = 1;
              carSearchQuery = value.trim();
            });
            _fetchAll();
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Pretraži automobil..',
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
              : ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final carId = car['carId'];
                    final carCompatibilities = compatibilities
                        .where((c) => c['carId'] == carId)
                        .toList();
                    expandedCars.putIfAbsent(carId, () => false);
                    partSearchQueries.putIfAbsent(carId, () => '');

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          expandedCars[carId] = !expandedCars[carId]!;
                        }),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${car['brand']} ${car['model']} (${car['year']})",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(
                                    expandedCars[carId]!
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Kompatibilnih dijelova: ${carCompatibilities.length}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                              if (expandedCars[carId]!) ...[
                                const SizedBox(height: 10),
                                if (carCompatibilities.isNotEmpty) ...[
                                  TextField(
                                    onChanged: (value) => setState(() {
                                      partSearchQueries[carId] = value
                                          .toLowerCase();
                                    }),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Pretraži dio..',
                                      hintStyle: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF121212),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: carCompatibilities
                                        .where((pc) {
                                          final part = parts.firstWhere(
                                            (p) => p['partId'] == pc['partId'],
                                            orElse: () => null,
                                          );
                                          return part?['name']
                                                  ?.toLowerCase()
                                                  .contains(
                                                    partSearchQueries[carId]!,
                                                  ) ??
                                              false;
                                        })
                                        .map((pc) {
                                          final part = parts.firstWhere(
                                            (p) => p['partId'] == pc['partId'],
                                            orElse: () => null,
                                          );
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2A2A2A),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  part?['name'] ??
                                                      'Nepoznat dio',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                GestureDetector(
                                                  onTap: () =>
                                                      _deleteCompatibility(
                                                        context,
                                                        pc,
                                                        part?['name'],
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.redAccent,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ] else
                                  const Text(
                                    "Nema kompatibilnih dijelova.",
                                    style: TextStyle(color: Colors.white60),
                                  ),
                              ],
                            ],
                          ),
                        ),
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
