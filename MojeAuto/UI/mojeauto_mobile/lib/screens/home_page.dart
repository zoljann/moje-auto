import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/screens/part_compare.dart';
import 'package:mojeauto_mobile/screens/part_search.dart';
import 'package:mojeauto_mobile/screens/car_choose.dart';
import 'package:mojeauto_mobile/screens/profile_page.dart';
import 'package:mojeauto_mobile/screens/part_detail.dart';
import 'package:mojeauto_mobile/helpers/token_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _categories = [];
  List<dynamic> _filteredCategories = [];
  List<dynamic> _recommendedParts = [];
  bool isLoading = false;
  bool _showAllCategories = false;
  final _scrollController = ScrollController();
  String? _userImageBase64;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
    _fetchUserImage();
    _fetchCategories();
    _fetchRecommendations();
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

  Future<void> _fetchUserImage() async {
    final userId = await TokenManager().userId;
    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/users?id=$userId"),
    );
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      setState(() {
        _userImageBase64 = user['imageData'];
      });
    }
  }

  Future<void> _fetchRecommendations() async {
    final userId = await TokenManager().userId;
    if (userId == null) return;

    final response = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/recommender/personalized/$userId"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        _recommendedParts = result;
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
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        title: const Text(
          "MojeAuto",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[800],
                backgroundImage: _userImageBase64 != null
                    ? MemoryImage(base64Decode(_userImageBase64!))
                    : null,
                child: _userImageBase64 == null
                    ? const Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ],
      ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PartComparePage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Usporedi dijelove",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              if (_recommendedParts.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  "Preporučeni dijelovi za vas",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommendedParts.length,
                    itemBuilder: (context, index) {
                      final part = _recommendedParts[index];
                      final imageData = part['imageData'];
                      final manufacturer =
                          part['manufacturer']?['name'] ?? 'Nepoznato';
                      final category = part['category']?['name'] ?? 'Nepoznato';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PartDetailPage(partId: part['partId']),
                            ),
                          );
                        },
                        child: Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: fieldFillColor,
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
                                        width: 180,
                                        height: 110,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 180,
                                        height: 110,
                                        color: Colors.black38,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.white38,
                                          size: 40,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      part['name'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Cijena: ${part['price']} KM",
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                    Text(
                                      "Proizvođač: $manufacturer",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "Kategorija: $category",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
