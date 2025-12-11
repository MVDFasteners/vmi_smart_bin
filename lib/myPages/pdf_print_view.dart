import 'package:flatten/models/sales_order_items.dart';
import 'package:pdf/pdf.dart'; // <-- required for PageFormat.a4
import 'package:pdf/widgets.dart' as pw;

class PdfPrintView {
  Future<pw.Document> generateInvoicePdf({
    required String companyName,
    required String poNumber,
    required List<SoPriority> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // <-- NOTE: PdfPageFormat, not pw.PageFormat
        build: (context) => [
          pw.Text(
            companyName,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text("PO Number: $poNumber", style: pw.TextStyle(fontSize: 14)),
          pw.Divider(),

          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: ["Item Code", "Item Name", "Qty", "UOM"],
            data: items.map((item) {
              return [
                item.itemCode,
                item.itemName,
                item.qty.toString(),
                item.uom,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          pw.Divider(),

          pw.Text(
            "Items ordered successfully from $companyName to MVD Fasteners Pvt Ltd.,",
            style: pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );

    return pdf;
  }
}
