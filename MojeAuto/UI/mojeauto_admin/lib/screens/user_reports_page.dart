import 'dart:ui' as ui;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mojeauto_admin/env_config.dart';
import 'package:intl/intl.dart';
import 'package:mojeauto_admin/common/form_fields.dart';
import 'package:mojeauto_admin/helpers/authenticated_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class UserReportsPage extends StatefulWidget {
  const UserReportsPage({super.key});

  @override
  State<UserReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<UserReportsPage> {
  List<dynamic> _users = [];
  int? _selectedUserId;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/users"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      setState(() => _users = jsonDecode(response.body));
    }
  }

  Future<void> _generateReport() async {
    if (_selectedUserId == null || _fromDate == null || _toDate == null) return;

    setState(() {
      _isLoading = true;
      _reportData = null;
    });

    final response = await httpClient.get(
      Uri.parse("${EnvConfig.baseUrl}/orders"),
      headers: {'accept': 'text/plain'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> orders = jsonDecode(response.body);
      final filteredOrders = orders.where((order) {
        final userId = order['userId'];
        final orderDate = DateTime.parse(order['orderDate']).toLocal();
        return userId == _selectedUserId &&
            orderDate.isAfter(_fromDate!.subtract(const Duration(days: 1))) &&
            orderDate.isBefore(_toDate!.add(const Duration(days: 1)));
      }).toList();

      final totalOrders = filteredOrders.length;
      final totalSpent = filteredOrders.fold<double>(
        0.0,
        (sum, order) => sum + order['totalAmount'],
      );

      final productFrequency = <String, int>{};
      final monthlyRevenue = <String, double>{};

      for (var order in filteredOrders) {
        final orderDate = DateTime.parse(order['orderDate']).toLocal();
        final monthKey = DateFormat('yyyy-MM').format(orderDate);
        monthlyRevenue[monthKey] =
            (monthlyRevenue[monthKey] ?? 0) + order['totalAmount'];

        for (var item in order['orderItems'] ?? []) {
          final name = item['part']['name'];
          productFrequency[name] = (productFrequency[name] ?? 0) + 1;
        }
      }

      final avgOrderValue = totalOrders > 0 ? (totalSpent / totalOrders) : 0;

      final uniqueProducts = productFrequency.length;

      final mostBoughtProduct = productFrequency.entries.isNotEmpty
          ? productFrequency.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
          : 'N/A';

      final top5Products = productFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topProducts = top5Products.take(5).toList();

      setState(() {
        _reportData = {
          'totalOrders': totalOrders,
          'totalSpent': totalSpent,
          'avgOrderValue': avgOrderValue,
          'uniqueProducts': uniqueProducts,
          'mostBoughtProduct': mostBoughtProduct,
          'monthlyRevenue': monthlyRevenue,
          'topProducts': topProducts,
        };
        _isLoading = false;
      });
    }
  }

  List<BarChartGroupData> _buildRevenueBars() {
    final revenue = _reportData!['monthlyRevenue'] as Map<String, dynamic>;
    final sortedKeys = revenue.keys.toList()..sort();
    return List.generate(sortedKeys.length, (index) {
      final amount = revenue[sortedKeys[index]] as double;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: amount, width: 16, color: Colors.blueAccent),
        ],
      );
    });
  }

  Future<void> _exportReportAsPdf() async {
    final pdf = pw.Document();
    final user = _users.firstWhere((u) => u['userId'] == _selectedUserId);
    final formatter = DateFormat('dd.MM.yyyy');

    final fontData = await rootBundle.load('assets/Roboto-Regular.ttf');
    final font = pw.Font.ttf(fontData);
    final chart = await _generateRevenueChartAsImage();

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Izvještaj o potrošnji korisnika',
              style: pw.TextStyle(fontSize: 22),
            ),
          ),
          pw.Text("Korisnik: ${user['firstName']} ${user['lastName']}"),
          pw.Text("Email: ${user['email']}"),
          pw.Text("Telefon: ${user['phoneNumber']}"),
          pw.Text(
            "Period: ${formatter.format(_fromDate!)} - ${formatter.format(_toDate!)}",
          ),
          pw.SizedBox(height: 16),
          pw.Text("Statistika", style: pw.TextStyle(fontSize: 18)),
          pw.Bullet(text: "Ukupno narudžbi: ${_reportData!['totalOrders']}"),
          pw.Bullet(
            text:
                "Ukupna potrošnja: ${_reportData!['totalSpent'].toStringAsFixed(2)} KM",
          ),
          pw.Bullet(
            text:
                "Najčešće kupljen proizvod: ${_reportData!['mostBoughtProduct']}",
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Grafikon mjesečne potrošnje",
            style: pw.TextStyle(fontSize: 16),
          ),
          if (chart != null) pw.Center(child: pw.Image(chart, width: 400)),
          pw.Text(
            "Prosječna vrijednost narudžbe: ${_reportData!['avgOrderValue'].toStringAsFixed(2)} KM",
          ),
          pw.Text(
            "Broj različitih proizvoda: ${_reportData!['uniqueProducts']}",
          ),
          pw.SizedBox(height: 12),
          pw.Text("Top 5 proizvoda:", style: pw.TextStyle(fontSize: 16)),
          ...(_reportData!['topProducts'] as List).map(
            (e) => pw.Bullet(text: "${e.key} (${e.value} puta)"),
          ),
        ],
      ),
    );

    final outputDir = await getDownloadsDirectory();
    final file = File(
      "${outputDir!.path}/${user['firstName']}_${user['lastName']}_izvjestaj.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF spremljen: ${file.path}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<pw.ImageProvider?> _generateRevenueChartAsImage() async {
    try {
      final boundary =
          _chartKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      return pw.MemoryImage(byteData.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Izvještaj po korisniku",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            buildDropdownField<dynamic>(
              value: _users.firstWhere(
                (u) => u['userId'] == _selectedUserId,
                orElse: () => null,
              ),
              items: _users,
              label: "Korisnik",
              onChanged: (value) =>
                  setState(() => _selectedUserId = value?['userId']),
              itemLabel: (u) => "${u['firstName']} ${u['lastName']}",
              itemValue: (u) => u,
              validator: (v) => v == null ? 'Odaberi korisnika' : null,
            ),

            const SizedBox(height: 16),
            buildDatePickerField(
              context: context,
              label: "Od datuma",
              controller: TextEditingController(
                text: _fromDate != null
                    ? DateFormat('dd.MM.yyyy').format(_fromDate!)
                    : '',
              ),
              onPicked: (iso) =>
                  setState(() => _fromDate = DateTime.parse(iso)),
              validator: (v) => v == null ? 'Odaberi početni datum' : null,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ),
            buildDatePickerField(
              context: context,
              label: "Do datuma",
              controller: TextEditingController(
                text: _toDate != null
                    ? DateFormat('dd.MM.yyyy').format(_toDate!)
                    : '',
              ),
              onPicked: (iso) => setState(() => _toDate = DateTime.parse(iso)),
              validator: (v) => v == null ? 'Odaberi krajnji datum' : null,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _generateReport();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text(
                "Kreiraj izvještaj",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_reportData != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ukupno narudžbi: ${_reportData!['totalOrders']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ukupna potrošnja: ${_reportData!['totalSpent'].toStringAsFixed(2)} KM",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Najčešće kupljen proizvod: ${_reportData!['mostBoughtProduct']}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Mjesečna potrošnja korisnika",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RepaintBoundary(
                      key: _chartKey,
                      child: SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: _buildRevenueBars(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final keys =
                                        _reportData!['monthlyRevenue'].keys
                                            .toList()
                                          ..sort();
                                    if (value.toInt() < keys.length) {
                                      final label = keys[value.toInt()]
                                          .substring(5);
                                      return Text(
                                        label,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ),

                    if (_reportData!['topProducts'] != null &&
                        _reportData!['topProducts'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          const Text(
                            "Top 5 kupljenih proizvoda",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: (_reportData!['topProducts'] as List)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final i = entry.key;
                                      final e = entry.value;
                                      return PieChartSectionData(
                                        color:
                                            Colors.primaries[i %
                                                Colors.primaries.length],
                                        value: e.value.toDouble(),
                                        title: '${e.key}',
                                        titleStyle: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_reportData != null)
                      ElevatedButton.icon(
                        onPressed: _exportReportAsPdf,
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                        ),
                        label: const Text("Exportuj PDF"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
