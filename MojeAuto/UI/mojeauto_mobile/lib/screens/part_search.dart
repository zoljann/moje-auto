import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/screens/qr_scan_page.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:mojeauto_mobile/screens/part_detail.dart';

class PartSearchPage extends StatefulWidget {
  final String initialQuery;
  final List<int>? initialCategoryIds;
  final List<int>? initialCarIds;
  final bool focusSearchField;

  const PartSearchPage({
    super.key,
    required this.initialQuery,
    this.initialCategoryIds,
    this.initialCarIds,
    this.focusSearchField = false,
  });

  @override
  State<PartSearchPage> createState() => _PartSearchPageState();
}

class _PartSearchPageState extends State<PartSearchPage> {
  List<dynamic> parts = [];
  bool isLoading = false;
  bool hasNextPage = true;
  int currentPage = 1;
  final int pageSize = 7;
  List<int> selectedCategoryIds = [];
  List<int> selectedManufacturerIds = [];
  bool sortByPriceEnabled = false;
  bool sortDescending = false;
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> allCars = [];
  List<int> selectedCarIds = [];

  List<dynamic> allCategories = [];
  List<dynamic> allManufacturers = [];
  Key _searchFieldKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);

    if (widget.initialCategoryIds != null) {
      selectedCategoryIds = List<int>.from(widget.initialCategoryIds!);
    }

    if (widget.initialCarIds != null) {
      selectedCarIds = List<int>.from(widget.initialCarIds!);
    }

    if (widget.focusSearchField) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }

    _loadFilters();
    _fetchParts();
  }

  Future<void> _loadFilters() async {
    final catRes = await http.get(Uri.parse("${EnvConfig.baseUrl}/categories"));
    final manRes = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/manufacturers"),
    );
    final carRes = await http.get(Uri.parse("${EnvConfig.baseUrl}/cars"));

    if (catRes.statusCode == 200 &&
        manRes.statusCode == 200 &&
        carRes.statusCode == 200) {
      setState(() {
        allCategories = jsonDecode(catRes.body);
        allManufacturers = jsonDecode(manRes.body);
        allCars = jsonDecode(carRes.body);
      });
    }
  }

  Future<void> _fetchParts({bool reset = false}) async {
    if (isLoading || (!hasNextPage && !reset)) return;

    if (reset) {
      setState(() {
        currentPage = 1;
        parts.clear();
        hasNextPage = true;
      });
    }

    setState(() => isLoading = true);

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };

    final searchTerm = _searchController.text.trim();
    if (searchTerm.length >= 2) {
      queryParams['Name'] = searchTerm;
    }

    final buffer = StringBuffer(Uri(queryParameters: queryParams).query);

    if (sortByPriceEnabled) {
      buffer.write('&SortByPriceEnabled=true');
      buffer.write('&SortByPriceDescending=$sortDescending');
    }

    for (final id in selectedCategoryIds) {
      buffer.write('&CategoryIds=$id');
    }

    for (final id in selectedManufacturerIds) {
      buffer.write('&ManufacturerIds=$id');
    }

    if (selectedCarIds.isNotEmpty) {
      buffer.write('&CarId=${selectedCarIds.first}');
    }

    final url = "${EnvConfig.baseUrl}/parts?$buffer";

    final response = await http.get(
      Uri.parse(url),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final trimmed = result.length > pageSize
          ? result.take(pageSize).toList()
          : result;

      setState(() {
        parts.addAll(trimmed);
        hasNextPage = result.length > pageSize;
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() {
        hasNextPage = false;
        isLoading = false;
      });
    }
  }

  void _openSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: Icon(
              Icons.arrow_upward,
              color: sortByPriceEnabled && !sortDescending
                  ? Colors.greenAccent
                  : Colors.white,
            ),
            title: Text(
              "Cijena: Od niže prema višoj",
              style: TextStyle(
                color: sortByPriceEnabled && !sortDescending
                    ? Colors.greenAccent
                    : Colors.white,
              ),
            ),
            onTap: () {
              setState(() {
                sortByPriceEnabled = true;
                sortDescending = false;
              });
              Navigator.pop(context);
              _fetchParts(reset: true);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.arrow_downward,
              color: sortByPriceEnabled && sortDescending
                  ? Colors.greenAccent
                  : Colors.white,
            ),
            title: Text(
              "Cijena: Od više prema nižoj",
              style: TextStyle(
                color: sortByPriceEnabled && sortDescending
                    ? Colors.greenAccent
                    : Colors.white,
              ),
            ),
            onTap: () {
              setState(() {
                sortByPriceEnabled = true;
                sortDescending = true;
              });
              Navigator.pop(context);
              _fetchParts(reset: true);
            },
          ),

          if (sortByPriceEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      sortByPriceEnabled = false;
                      sortDescending = false;
                      Navigator.pop(context);
                      _fetchParts(reset: true);
                    });
                  },
                  icon: const Icon(Icons.swap_vert, color: Colors.white),
                  label: const Text(
                    "Poništi sortiranje",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2A2D31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filteri",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                MultiSelectDialogField<int>(
                  items: allManufacturers
                      .map(
                        (m) => MultiSelectItem<int>(
                          m['manufacturerId'],
                          m['name'],
                        ),
                      )
                      .toList(),
                  initialValue: selectedManufacturerIds,
                  searchable: true,
                  title: const Text(
                    "Proizvođači",
                    style: TextStyle(color: Colors.white),
                  ),
                  selectedItemsTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  itemsTextStyle: const TextStyle(color: Colors.white),
                  checkColor: Colors.white,
                  buttonIcon: const Icon(Icons.factory, color: Colors.white),
                  buttonText: const Text(
                    "Odaberi proizvođače",
                    style: TextStyle(
                      color: Color(0xFFDCD5FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: const Color(0xFF3A3D41),
                    textStyle: const TextStyle(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white70),
                    ),
                  ),
                  confirmText: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                  cancelText: const Text(
                    "Poništi",
                    style: TextStyle(color: Colors.white70),
                  ),
                  onConfirm: (values) {
                    selectedManufacturerIds = List<int>.from(values);
                    Navigator.pop(context);
                    _fetchParts(reset: true);
                  },
                ),

                const SizedBox(height: 20),

                MultiSelectDialogField<int>(
                  items: allCategories
                      .map(
                        (c) => MultiSelectItem<int>(c['categoryId'], c['name']),
                      )
                      .toList(),
                  initialValue: selectedCategoryIds,
                  searchable: true,
                  title: const Text(
                    "Kategorije",
                    style: TextStyle(color: Colors.white),
                  ),
                  selectedItemsTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  itemsTextStyle: const TextStyle(color: Colors.white),
                  checkColor: Colors.white,
                  buttonIcon: const Icon(Icons.category, color: Colors.white),
                  buttonText: const Text(
                    "Odaberi kategorije",
                    style: TextStyle(
                      color: Color(0xFFDCD5FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  chipDisplay: MultiSelectChipDisplay(
                    chipColor: const Color(0xFF3A3D41),
                    textStyle: const TextStyle(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.white70),
                    ),
                  ),
                  confirmText: const Text(
                    "OK",
                    style: TextStyle(color: Colors.white),
                  ),
                  cancelText: const Text(
                    "Poništi",
                    style: TextStyle(color: Colors.white70),
                  ),
                  onConfirm: (values) {
                    selectedCategoryIds = List<int>.from(values);
                    Navigator.pop(context);
                    _fetchParts(reset: true);
                  },
                ),

                const SizedBox(height: 20),

                DropdownSearch<int>(
                  items: allCars.map<int>((c) => c['carId'] as int).toList(),
                  selectedItem: selectedCarIds.isNotEmpty
                      ? selectedCarIds.first
                      : null,
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Pretraži automobile..',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    itemBuilder: (context, item, isSelected) {
                      final car = allCars.firstWhere((c) => c['carId'] == item);
                      final label =
                          "${car['brand']} ${car['model']} ${car['year']}";
                      return ListTile(
                        title: Text(
                          label,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelStyle: const TextStyle(
                        color: Color(0xFFDCD5FF),
                        fontWeight: FontWeight.w500,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2A2D31),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  dropdownBuilder: (context, selectedItem) {
                    if (selectedItem == null) {
                      return const Text(
                        "Odaberi automobil",
                        style: TextStyle(
                          color: Color(0xFFDCD5FF),
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    final car = allCars.firstWhere(
                      (c) => c['carId'] == selectedItem,
                    );
                    final label =
                        "${car['brand']} ${car['model']} ${car['year']}";
                    return Text(
                      label,
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                  filterFn: (item, filter) {
                    final car = allCars.firstWhere((c) => c['carId'] == item);
                    final label =
                        "${car['brand']} ${car['model']} ${car['year']}"
                            .toLowerCase();
                    return label.contains(filter.toLowerCase());
                  },
                  onChanged: (val) {
                    setState(() {
                      selectedCarIds = val != null ? [val] : [];
                    });
                    _fetchParts(reset: true);
                  },
                ),

                const SizedBox(height: 10),
                if (selectedCategoryIds.isNotEmpty ||
                    selectedManufacturerIds.isNotEmpty)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedCategoryIds.clear();
                          selectedManufacturerIds.clear();
                          selectedCarIds.clear();
                          Navigator.pop(context);
                          _fetchParts(reset: true);
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.white),
                      label: const Text(
                        "Poništi filtere",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF181A1C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D31),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            key: _searchFieldKey,
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (val) {
              setState(() {
                parts.clear();
                currentPage = 1;
              });
              _fetchParts(reset: true);
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Pretraži dijelove...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.grey),
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScanPage()),
              );

              if (result != null &&
                  result is String &&
                  result.trim().isNotEmpty) {
                setState(() {
                  _searchController.text = result.trim();
                });
                _fetchParts(reset: true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _openSortMenu(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _openFilterMenu(context),
          ),
        ],
      ),

      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ...parts.map((part) {
              final imageData = part['imageData'];
              final manufacturer = part['manufacturer']?['name'] ?? 'Nepoznato';
              final category = part['category']?['name'] ?? 'Nepoznato';

              return GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PartDetailPage(partId: part['partId']),
                    ),
                  );

                  setState(() {
                    _searchFieldKey = UniqueKey();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D31),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: imageData != null
                            ? Image.memory(
                                base64Decode(imageData),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: double.infinity,
                                height: 180,
                                color: const Color(0xFF3A3D41),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 60,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              part['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Kataloški broj: ${part['catalogNumber'] ?? '-'}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Proizvođač: $manufacturer",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    "Kategorija: $category",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Cijena: ${part['price']} KM",
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Garancija: ${part['warrantyMonths']} mj.",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            if (part['description'] != null &&
                                (part['description'] as String)
                                    .trim()
                                    .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  part['description'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (isLoading && parts.isEmpty)
              const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (!isLoading && parts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Text(
                    "Nema pronađenih dijelova.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

            if (hasNextPage && parts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: GestureDetector(
                  onTap: isLoading ? null : _fetchParts,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          "Učitaj još dijelova",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
