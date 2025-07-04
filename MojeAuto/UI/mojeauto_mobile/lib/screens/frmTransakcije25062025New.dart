import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mojeauto_mobile/env_config.dart';

class NovaTransakcijaPage extends StatefulWidget {
  const NovaTransakcijaPage({super.key});

  @override
  State<NovaTransakcijaPage> createState() => _NovaTransakcijaPageState();
}

class _NovaTransakcijaPageState extends State<NovaTransakcijaPage> {
  final _formKey = GlobalKey<FormState>();
  final _datumController = TextEditingController();
  final _amountController = TextEditingController();
  final _opisController = TextEditingController();

  List<dynamic> users = [];
  String? selectedUserId;
  int? selectedKategorijaId;
  String? selectedStatus;
  String? isoDate;

  final List<String> statusi = ["Na čekanju", "Potvrđena", "Odbijena"];

  final kategorije = [
    {'id': 1, 'naziv': 'Hrana', 'tip': 'prihod'},
    {'id': 2, 'naziv': 'Prevoz', 'tip': 'rashod'},
    {'id': 3, 'naziv': 'Stanarina', 'tip': 'prihod'},
  ];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final res = await http.get(Uri.parse("${EnvConfig.baseUrl}/users"));
    if (res.statusCode == 200) {
      setState(() => users = json.decode(res.body));
    }
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null) return;

    final full = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    isoDate = full.toIso8601String();
    _datumController.text = DateFormat('dd.MM.yyyy HH:mm').format(full);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() ||
        selectedUserId == null ||
        selectedKategorijaId == null ||
        isoDate == null ||
        selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Popunite sva polja.")),
      );
      return;
    }

    final uri = Uri.parse("${EnvConfig.baseUrl}/transakcija");
    final request = http.MultipartRequest('POST', uri);

    request.fields['UserId'] = selectedUserId!;
    request.fields['Amount'] = _amountController.text.trim();
    request.fields['Datum'] = isoDate!;
    request.fields['Opis'] = _opisController.text.trim();
    request.fields['KategorijaTransakcije25062025Id'] = selectedKategorijaId.toString();
    request.fields['Status'] = selectedStatus!;

    final res = await request.send();

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Greška prilikom slanja.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova transakcija")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedUserId,
                  items: users
                      .map((u) => DropdownMenuItem(
                            value: u['userId'].toString(),
                            child: Text("${u['firstName']} ${u['lastName']}"),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedUserId = val),
                  decoration: const InputDecoration(labelText: 'Korisnik'),
                  validator: (val) => val == null ? 'Odaberite korisnika' : null,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Iznos'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) => (val == null || double.tryParse(val) == null)
                      ? 'Unesite validan iznos'
                      : null,
                ),
                TextFormField(
                  controller: _datumController,
                  readOnly: true,
                  onTap: pickDateTime,
                  decoration: const InputDecoration(labelText: 'Datum i vrijeme'),
                  validator: (val) => val == null || val.isEmpty ? 'Odaberite datum' : null,
                ),
                TextFormField(
                  controller: _opisController,
                  decoration: const InputDecoration(labelText: 'Opis'),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Unesite opis' : null,
                ),
                DropdownButtonFormField<int>(
                  value: selectedKategorijaId,
                  items: kategorije
                      .map((k) => DropdownMenuItem(
                            value: k['id'] as int,
                            child: Text("${k['naziv']} (${k['tip']})"),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedKategorijaId = val),
                  decoration: const InputDecoration(labelText: 'Kategorija'),
                  validator: (val) => val == null ? 'Odaberite kategoriju' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: statusi
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedStatus = val),
                  decoration: const InputDecoration(labelText: 'Status'),
                  validator: (val) => val == null ? 'Odaberite status' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submit,
                  child: const Text("Spremi"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
