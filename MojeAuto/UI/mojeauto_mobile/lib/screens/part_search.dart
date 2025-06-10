import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';

class PartSearchPage extends StatefulWidget {
  final String initialQuery;
  const PartSearchPage({super.key, required this.initialQuery});

  @override
  State<PartSearchPage> createState() => _PartSearchPageState();
}

class _PartSearchPageState extends State<PartSearchPage> {
  List<dynamic> parts = [];
  bool isLoading = false;
  bool hasNextPage = true;
  int currentPage = 1;
  final int pageSize = 7;

  @override
  void initState() {
    super.initState();
    _fetchParts();
  }

  Future<void> _fetchParts() async {
    if (isLoading || !hasNextPage) return;

    setState(() => isLoading = true);

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
      'Name': widget.initialQuery,
    };

    final response = await http.get(
      Uri.parse(
        "${EnvConfig.baseUrl}/parts",
      ).replace(queryParameters: queryParams),
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
            leading: const Icon(Icons.arrow_upward, color: Colors.white),
            title: const Text(
              "Cijena: Od niže prema višoj",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                parts.sort((a, b) => a['price'].compareTo(b['price']));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.white),
            title: const Text(
              "Cijena: Od više prema nižoj",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                parts.sort((a, b) => b['price'].compareTo(a['price']));
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _openFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2D31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filteri",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Example filter items
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D5EFF),
              ),
              child: const Text("Proizvođač"),
              onPressed: () {
                print("Filter by manufacturer");
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D5EFF),
              ),
              child: const Text("Kategorija"),
              onPressed: () {
                print("Filter by category");
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7D5EFF),
              ),
              child: const Text("Vozilo"),
              onPressed: () {
                print("Filter by car");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF181A1C);

    return Scaffold(
      appBar: AppBar(
        title: Text("Rezultati za: ${widget.initialQuery}"),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _openFilterMenu(context),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _openSortMenu(context),
        ),
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

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D31),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageData != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.memory(
                          base64Decode(imageData),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
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
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Kategorija: $category",
                                  style: const TextStyle(color: Colors.white70),
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
                              (part['description'] as String).trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                part['description'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7D5EFF),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Dodaj u korpu",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () =>
                                  print("Added to cart: ${part['partId']}"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            if (hasNextPage)
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
