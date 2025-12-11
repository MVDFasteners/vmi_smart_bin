import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InvoicePdfView extends StatelessWidget {
  final Uint8List pdfBytes;

  const InvoicePdfView({super.key, required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice PDF")),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}
