import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/screens/part_search.dart';
import 'package:mojeauto_mobile/screens/car_choose.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _categories = [];
  List<dynamic> _filteredCategories = [];
  bool isLoading = false;
  bool _showAllCategories = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/categories"),
      headers: {'accept': 'text/plain'},
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        _categories = result;
        _filteredCategories = result;
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF181A1C);
    final fieldFillColor = const Color(0xFF2A2D31);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: bgColor),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PartSearchPage(initialQuery: ''),
                          ),
                        );
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: 'Pretraži dijelove..',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: fieldFillColor,
                            border: border,
                            suffixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7D5EFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CarChoose()),
                        );
                      },
                      child: const Text(
                        "Odaberi automobil",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7D5EFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => print("usporedi dijelove"),
                      child: const Text(
                        "Usporedi dijelove",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category section
              Row(
                children: const [
                  Text(
                    "Kategorije",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    " (Odaberite kategoriju za pretragu)",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category search
              TextField(
                onChanged: _filterCategories,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Pretraži kategorije..',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: fieldFillColor,
                  border: border,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // Category list
              if (isLoading)
                const CircularProgressIndicator()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _showAllCategories
                      ? _filteredCategories.length
                      : (_filteredCategories.length > 5
                            ? 5
                            : _filteredCategories.length),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartSearchPage(
                              initialQuery: '',
                              initialCategoryIds: [category['categoryId']],
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              if (!_showAllCategories && _filteredCategories.length > 5)
                TextButton(
                  onPressed: () => setState(() => _showAllCategories = true),
                  child: const Text(
                    "Učitaj više kategorija..",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
