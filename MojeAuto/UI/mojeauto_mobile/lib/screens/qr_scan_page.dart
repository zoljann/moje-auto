import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skeniraj QR kod autodijela")),
      body: MobileScanner(
        controller: MobileScannerController(),
        onDetect: (capture) {
          if (isScanned) return;

          final barcode = capture.barcodes.first;
          final code = barcode.rawValue;

          if (code != null && code.trim().isNotEmpty) {
            isScanned = true;
            Navigator.pop(context, code.trim());
          }
        },
      ),
    );
  }
}
