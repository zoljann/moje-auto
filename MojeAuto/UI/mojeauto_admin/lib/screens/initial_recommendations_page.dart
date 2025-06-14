import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:mojeauto_admin/common/pagination_controls.dart';

class InitialRecommendationsPage extends StatefulWidget {
  const InitialRecommendationsPage({super.key});

  @override
  State<InitialRecommendationsPage> createState() =>
      _InitialRecommendationsPageState();
}

class _InitialRecommendationsPageState
    extends State<InitialRecommendationsPage> {
  List<dynamic> _parts = [];
  List<dynamic> _allParts = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 1;
  int pageSize = 7;
  bool hasNextPage = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialRecommendations();
    _fetchAllParts();
  }

  Future<void> _fetchInitialRecommendations() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/initial-recommendations"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() => _parts = jsonDecode(response.body));
    } else {
      setState(() => _parts = []);
    }
  }

  Future<void> _fetchAllParts() async {
    setState(() => _isLoading = true);

    final queryParams = {
      'Page': currentPage.toString(),
      'PageSize': pageSize.toString(),
    };

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      queryParams['Name'] = query;
    }

    final response = await httpClient.get(
      Uri.parse(
        "${EnvConfig.baseUrl}/parts",
      ).replace(queryParameters: queryParams),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        hasNextPage = result.length == pageSize + 1;
        _allParts = hasNextPage ? result.take(pageSize).toList() : result;
        _isLoading = false;
      });
    } else {
      setState(() {
        _allParts = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addToInitial(int partId) async {
    final response = await httpClient.post(
      Uri.parse("${EnvConfig.baseUrl}/initial-recommendations/$partId"),
    );

    if (response.statusCode == 200) {
      _fetchInitialRecommendations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dio dodan u početne preporuke"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _removeFromInitial(int partId) async {
    final response = await httpClient.delete(
      Uri.parse("${EnvConfig.baseUrl}/initial-recommendations/$partId"),
    );

    if (response.statusCode == 204) {
      _fetchInitialRecommendations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Dio uklonjen iz početnih preporuka."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _onSearchChanged() {
    currentPage = 1;
    _fetchAllParts();
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
      _fetchAllParts();
    }
  }

  void _goToNextPage() {
    if (hasNextPage) {
      setState(() => currentPage++);
      _fetchAllParts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Početne preporuke",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Pretraži dijelove...',
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allParts.isEmpty
                ? const Center(
                    child: Text(
                      "Nema dostupnih dijelova.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView(
                    children: _allParts.map((part) {
                      final isInInitial = _parts.any(
                        (p) => p['partId'] == part['partId'],
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    part['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Cijena: ${part['price']} KM",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isInInitial
                                    ? Icons.remove_circle
                                    : Icons.add_circle,
                                color: isInInitial
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                              ),
                              onPressed: () => isInInitial
                                  ? _removeFromInitial(part['partId'])
                                  : _addToInitial(part['partId']),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          PaginationControls(
            currentPage: currentPage,
            hasNextPage: hasNextPage,
            onPrevious: _goToPreviousPage,
            onNext: _goToNextPage,
          ),
        ],
      ),
    );
  }
}
