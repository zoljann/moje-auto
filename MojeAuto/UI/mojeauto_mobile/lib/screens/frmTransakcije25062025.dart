import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mojeauto_mobile/env_config.dart';
import 'package:intl/intl.dart';
import 'package:mojeauto_mobile/screens/frmTransakcije25062025New.dart';

class FrmTransakcije25062025Page extends StatefulWidget {
  const FrmTransakcije25062025Page({super.key});

  @override
  State<FrmTransakcije25062025Page> createState() =>
      _FrmTransakcije25062025PageState();
}

class _FrmTransakcije25062025PageState
    extends State<FrmTransakcije25062025Page> {
  List<dynamic> transakcije = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response =
        await http.get(Uri.parse("${EnvConfig.baseUrl}/transakcija"));

    if (response.statusCode == 200) {
      setState(() {
        transakcije = json.decode(response.body);
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transakcije")),
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
                    builder: (_) => const NovaTransakcijaPage(),
                  ),
                );
                load();
              },
              child: const Text("Nova transakcija"),
            ),
            const SizedBox(height: 20),
            ...transakcije.map((x) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${x["transakcija25062025Id"]}"),
                      Text("Korisnik ID: ${x["userId"]}"),
                      Text("Iznos: ${x["amount"]}"),
                      Text("Datum: ${formatDate(x["datum"])}"),
                      Text("Opis: ${x["opis"]}"),
                      Text("Kategorija ID: ${x["kategorijaTransakcije25062025Id"]}"),
                      Text("Status: ${x["status"]}"),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
