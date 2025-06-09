import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/helpers/error_extractor.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:mojeauto_admin/common/form_fields.dart';

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
  final Map<int, List<dynamic>> _groupedByCar = {};
  List<dynamic> allCars = [];

  bool isLoading = true;
  bool showForm = false;
  int? selectedCarId;
  Set<int> selectedPartIds = {};
  String carSearchQuery = "";
  int currentPage = 1;
  int pageSize = 7;
  bool hasNextPage = false;
  bool _showPartValidationError = false;

  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchCars(),
      _fetchParts(),
      _fetchCompatibilities(),
      _fetchAllCarsForDropdown(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> _fetchAllCarsForDropdown() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/cars"),
    );

    if (response.statusCode == 200) {
      allCars = jsonDecode(response.body);
    }
  }

  Future<void> _fetchCars() async {
    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': (pageSize + 1).toString(),
    };
    if (carSearchQuery.length >= 2) {
      queryParams['Brand'] = carSearchQuery;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${EnvConfig.baseUrl}/cars",
      ).replace(queryParameters: queryParams),
    );

    if (response.statusCode == 200) {
      cars = jsonDecode(response.body);
      hasNextPage = cars.length >= pageSize;
    }
  }

  Future<void> _fetchParts() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/parts"),
    );
    if (response.statusCode == 200) parts = jsonDecode(response.body);
  }

  Future<void> _fetchCompatibilities() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/part-cars"),
    );
    if (response.statusCode == 200) {
      compatibilities = jsonDecode(response.body);

      _groupedByCar.clear();
      for (var pc in compatibilities) {
        final car = pc['car'];
        if (car == null) continue;
        final carId = car['carId'];

        _groupedByCar.putIfAbsent(carId, () => []).add(pc);
      }
    }
  }

  Future<void> _addCompatibilities() async {
    bool anyFailed = false;

    for (var partId in selectedPartIds) {
      final payload = {'carId': selectedCarId, 'partId': partId};

      final response = await httpClient.post(
        Uri.parse("${EnvConfig.baseUrl}/part-cars"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        anyFailed = true;
        final error = extractErrorMessage(
          response,
          fallback: "Greška pri dodavanju dijela s ID $partId.",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }

    await _fetchCompatibilities();
    _clearForm();

    if (!anyFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Svi dijelovi uspješno dodani."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteCompatibilityConfirmed(dynamic pc) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/part-cars/${pc['partCarId']}"),
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
      child: Form(
        key: _formKey,
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
            buildDropdownField<Map<String, dynamic>>(
              value: selectedCarId != null
                  ? allCars.firstWhere(
                          (c) => c['carId'] == selectedCarId,
                          orElse: () => null,
                        )
                        as Map<String, dynamic>?
                  : null,
              items: allCars.cast<Map<String, dynamic>>(),
              label: "Automobil",
              validator: (value) =>
                  value == null ? 'Odaberite automobil' : null,
              onChanged: (value) {
                setState(() {
                  selectedCarId = value?['carId'];
                  selectedPartIds.clear();
                });
              },
              itemLabel: (car) =>
                  "${car['brand']} ${car['model']} (${car['year']})",
              itemValue: (car) => car,
            ),
            const SizedBox(height: 12),
            MultiSelectDialogField<int>(
              items: parts
                  .where(
                    (p) =>
                        selectedCarId == null ||
                        !compatibilities.any(
                          (c) =>
                              c['carId'] == selectedCarId &&
                              c['partId'] == p['partId'],
                        ),
                  )
                  .map((p) => MultiSelectItem<int>(p['partId'], p['name']))
                  .toList(),
              initialValue: selectedPartIds.toList(),
              searchable: true,
              title: const Text(
                "Odabir dijelova",
                style: TextStyle(color: Colors.white),
              ),
              buttonText: Text(
                selectedPartIds.isEmpty
                    ? "Odaberi dijelove"
                    : "Odabrano (${selectedPartIds.length})",
                style: const TextStyle(color: Colors.white70),
              ),
              selectedColor: const Color(0xFF3B82F6),
              selectedItemsTextStyle: const TextStyle(color: Colors.white),
              checkColor: Colors.white,
              chipDisplay: MultiSelectChipDisplay.none(),
              searchTextStyle: const TextStyle(color: Colors.white),
              onConfirm: (values) {
                setState(() {
                  selectedPartIds = values.toSet().cast<int>();
                  _showPartValidationError = false;
                });
              },
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              confirmText: const Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              cancelText: const Text(
                "Poništi",
                style: TextStyle(color: Colors.white70),
              ),
              dialogWidth: MediaQuery.of(context).size.width * 0.8,
              dialogHeight: 400,
              backgroundColor: const Color(0xFF1E1E1E),
              itemsTextStyle: const TextStyle(color: Colors.white),
              searchHint: "Pretraži dijelove..",
              searchHintStyle: const TextStyle(color: Colors.white70),
              searchIcon: const Icon(Icons.search, color: Colors.white70),
              closeSearchIcon: const Icon(Icons.close, color: Colors.white70),
            ),
            if (_showPartValidationError)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Odaberite najmanje jedan dio.",
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedPartIds.isEmpty) {
                        setState(() => _showPartValidationError = true);
                        return;
                      } else {
                        _addCompatibilities();
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
                    final carCompatibilities = _groupedByCar[carId] ?? [];

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
                                TextField(
                                  onChanged: (value) => setState(() {
                                    partSearchQueries[carId] = value
                                        .toLowerCase();
                                  }),
                                  style: const TextStyle(color: Colors.white70),
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
                                        final part = pc['part'];
                                        return part?['name']
                                                ?.toLowerCase()
                                                .contains(
                                                  partSearchQueries[carId]!,
                                                ) ??
                                            false;
                                      })
                                      .map((pc) {
                                        final part = pc['part'];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2A2A2A),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                part?['name'] ?? 'Nepoznat dio',
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
