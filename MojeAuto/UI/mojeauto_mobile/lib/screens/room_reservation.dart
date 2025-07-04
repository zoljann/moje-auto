import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mojeauto_mobile/env_config.dart';
import 'package:mojeauto_mobile/screens/nova_rezervacija_page.dart';

class RoomReservationsPage extends StatefulWidget {
  const RoomReservationsPage({super.key});

  @override
  State<RoomReservationsPage> createState() => _RoomReservationsPageState();
}

class _RoomReservationsPageState extends State<RoomReservationsPage> {
  List<dynamic> prostori = [];
  List<dynamic> rezervacije = [];
  List<dynamic> users = [];

  String? selectedUserId;
  String? selectedProstorId;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await http.get(Uri.parse("${EnvConfig.baseUrl}/radni-prostori"));
    final r = await http.get(
      Uri.parse("${EnvConfig.baseUrl}/rezervacija-prostora"),
    );
    final u = await http.get(Uri.parse("${EnvConfig.baseUrl}/users"));
    
    if (p.statusCode == 200 && r.statusCode == 200 && u.statusCode == 200) {
      setState(() {
        prostori = json.decode(p.body);
        rezervacije = json.decode(r.body);
        users = json.decode(u.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = rezervacije.where(
      (x) =>
          (selectedUserId == null ||
              x["userId"].toString() == selectedUserId) &&
          (selectedProstorId == null ||
              x["radniProstorId"].toString() == selectedProstorId) &&
          (selectedStatus == null || x["status"] == selectedStatus),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Rezervacije")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NovaRezervacijaPage(),
                  ),
                );
                load();
              },
              child: const Text("Nova rezervacija"),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedUserId,
              hint: const Text("Korisnik"),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text("Svi")),
                ...users.map(
                  (u) => DropdownMenuItem(
                    value: u["userId"].toString(),
                    child: Text("${u["firstName"]} ${u["lastName"]}"),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => selectedUserId = val),
            ),
            DropdownButton<String>(
              value: selectedProstorId,
              hint: const Text("Radni prostor"),
              isExpanded: true,
              items: [
                const DropdownMenuItem(value: null, child: Text("Svi")),
                ...prostori.map(
                  (p) => DropdownMenuItem(
                    value: p["radniProstorId"].toString(),
                    child: Text(p["oznaka"]),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => selectedProstorId = val),
            ),
            DropdownButton<String>(
              value: selectedStatus,
              hint: const Text("Status"),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: null, child: Text("Svi")),
                DropdownMenuItem(value: "Potvrđena", child: Text("Potvrđena")),
                DropdownMenuItem(
                  value: "Na čekanju",
                  child: Text("Na čekanju"),
                ),
                DropdownMenuItem(value: "Otkazana", child: Text("Otkazana")),
              ],
              onChanged: (val) => setState(() => selectedStatus = val),
            ),
            const SizedBox(height: 20),
            ...filtered.map((x) {
              final prostor = prostori.firstWhere(
                (p) => p['radniProstorId'] == x['radniProstorId'],
              );
              final user = users.firstWhere((u) => u['userId'] == x['userId']);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Korisnik: ${user['firstName']} ${user['lastName']}"),
                  Text("Prostor: ${prostor['oznaka']}"),
                  Text("Datum: ${x["datumPocetka"]}"),
                  Text("Trajanje: ${x["trajanje"]}h"),
                  Text("Status: ${x["status"]}"),
                  Text("Napomena: ${x["napomena"]}"),
                  const Divider(),
                ],
              );
            }),
            Text("Statistika:"),
            Text(
              "Potvrđenih: ${filtered.where((x) => x['status'] == 'Potvrđena').length}",
            ),
            Text(
              "Na čekanju: ${filtered.where((x) => x['status'] == 'Na čekanju').length}",
            ),
            Text(
              "Otkazanih: ${filtered.where((x) => x['status'] == 'Otkazana').length}",
            ),
          ],
        ),
      ),
    );
  }
}
