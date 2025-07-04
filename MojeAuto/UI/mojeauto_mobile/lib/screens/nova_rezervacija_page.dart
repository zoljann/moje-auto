import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mojeauto_mobile/env_config.dart';

class NovaRezervacijaPage extends StatefulWidget {
  const NovaRezervacijaPage({super.key});

  @override
  State<NovaRezervacijaPage> createState() => _NovaRezervacijaPageState();
}

class _NovaRezervacijaPageState extends State<NovaRezervacijaPage> {
  final _formKey = GlobalKey<FormState>();
  final _datumController = TextEditingController();
  final _trajanjeController = TextEditingController();
  final _napomenaController = TextEditingController();

  List<dynamic> prostori = [];
  List<dynamic> users = [];
  String? selectedUserId;
  String? selectedProstorId;
  String? isoDate;

  @override
  void initState() {
    super.initState();
    loadProstori();
    loadUsers();
  }

  Future<void> loadProstori() async {
    final res = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/radni-prostori"),
    );
    if (res.statusCode == 200) {
      setState(() => prostori = json.decode(res.body));
    }
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    final full = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    isoDate = full.toIso8601String();
    _datumController.text = DateFormat('dd.MM.yyyy HH:mm').format(full);
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      if (isoDate == null ||
          selectedProstorId == null ||
          selectedUserId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Unesite sve podatke.")));
        return;
      }

      final userId = int.tryParse(selectedUserId ?? '');
      final trajanje = int.tryParse(_trajanjeController.text.trim()) ?? 0;
      final status = trajanje > 6 ? "Na čekanju" : "Potvrđena";

      final uri = Uri.parse("${EnvConfig.baseUrl}/rezervacija-prostora");
      final request = http.MultipartRequest('POST', uri);
      request.fields['UserId'] = userId.toString();
      request.fields['RadniProstorId'] = selectedProstorId!;
      request.fields['DatumPocetka'] = isoDate!;
      request.fields['Trajanje'] = trajanje.toString();
      request.fields['Status'] = status;
      request.fields['Napomena'] = _napomenaController.text.trim();

      final res = await request.send();

      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nova rezervacija")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProstorId,
                  items: prostori
                      .map(
                        (p) => DropdownMenuItem(
                          value: p['radniProstorId'].toString(),
                          child: Text(p['oznaka']),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedProstorId = val),
                  decoration: const InputDecoration(labelText: 'Prostor'),
                  validator: (val) => val == null ? 'Odaberite prostor' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedUserId,
                  items: users
                      .map(
                        (u) => DropdownMenuItem(
                          value: u['userId'].toString(),
                          child: Text("${u['firstName']} ${u['lastName']}"),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedUserId = val),
                  decoration: const InputDecoration(labelText: 'Korisnik'),
                  validator: (val) =>
                      val == null ? 'Odaberite korisnika' : null,
                ),

                TextFormField(
                  controller: _datumController,
                  readOnly: true,
                  onTap: pickDateTime,
                  decoration: const InputDecoration(
                    labelText: 'Datum i vrijeme',
                  ),
                ),
                TextFormField(
                  controller: _trajanjeController,
                  decoration: const InputDecoration(labelText: 'Trajanje (h)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => (val == null || int.tryParse(val) == null)
                      ? 'Unesite broj'
                      : null,
                ),
                TextFormField(
                  controller: _napomenaController,
                  decoration: const InputDecoration(labelText: 'Napomena'),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Unesite napomenu'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: submit, child: const Text("Spremi")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
