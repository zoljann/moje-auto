import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:dropdown_search/dropdown_search.dart';

class PartComparePage extends StatefulWidget {
  const PartComparePage({super.key});

  @override
  State<PartComparePage> createState() => _PartComparePageState();
}

class _PartComparePageState extends State<PartComparePage> {
  List<dynamic> allParts = [];
  dynamic selectedPart1;
  dynamic selectedPart2;

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/parts?pageSize=100"),
      headers: {'accept': 'text/plain'},
    );
    if (response.statusCode == 200) {
      setState(() => allParts = jsonDecode(response.body));
    }
  }

  Widget buildPartDetails(dynamic part) {
    if (part == null) return const SizedBox.shrink();
    final imageData = part['imageData'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D31),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
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
                      color: const Color(0xFF2A2D31),
                      child: const Icon(
                        Icons.car_repair,
                        color: Colors.white54,
                        size: 60,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              part['name'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Kataloški broj: ${part['catalogNumber'] ?? '-'}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              "Proizvođač: ${part['manufacturer']?['name'] ?? 'Nepoznato'}",
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Kategorija: ${part['category']?['name'] ?? 'Nepoznato'}",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              "Cijena: ${part['price']} KM",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Garancija: ${part['warrantyMonths']} mjeseci",
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Na stanju: ${part['quantity']}",
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              "Prodano: ${part['totalSold']}",
              style: const TextStyle(color: Colors.white70),
            ),
            if (part['description'] != null &&
                (part['description'] as String).trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  part['description'],
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181A1C),
        title: const Text("Usporedba dijelova"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownSearch<dynamic>(
                    items: allParts,
                    selectedItem: selectedPart1,
                    itemAsString: (p) => p['name'],
                    onChanged: (val) => setState(() => selectedPart1 = val),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Pretraži dio...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      itemBuilder: (context, item, isSelected) => ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Dio 1",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2A2D31),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    filterFn: (item, filter) => item['name']
                        .toString()
                        .toLowerCase()
                        .contains(filter.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownSearch<dynamic>(
                    items: allParts,
                    selectedItem: selectedPart2,
                    itemAsString: (p) => p['name'],
                    onChanged: (val) => setState(() => selectedPart2 = val),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Pretraži dio...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                      itemBuilder: (context, item, isSelected) => ListTile(
                        title: Text(
                          item['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Dio 2",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2A2D31),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    filterFn: (item, filter) => item['name']
                        .toString()
                        .toLowerCase()
                        .contains(filter.toLowerCase()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: (selectedPart1 == null && selectedPart2 == null)
                    ? const Center(
                        child: Text(
                          'Odaberite barem jedan dio da bi se prikazala usporedba.',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox.expand(
                              child: buildPartDetails(selectedPart1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox.expand(
                              child: buildPartDetails(selectedPart2),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
