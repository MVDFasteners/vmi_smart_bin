import 'package:flatten/myPages/KOT%20Repo/soPendingReport.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfPrintViewKot {
  Future<pw.Document> generateInvoicePdf({
    required String companyName,
    required List<PendingSoItem> items,
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
          // pw.Text("PO Number: $poNumber", style: pw.TextStyle(fontSize: 14)),
          pw.Divider(),

          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: [
              "Customer Name",
              "Delivery Date",
              "Item Code",
              "Item Name",
              "Available Stk",
              "Available Stk By Warehouse",
              "Pending Qty",
              "UOM",
              "SO",
            ],
            data: items.map((item) {
              return [
                item.customerName ?? '',
                item.deliveryDate ?? '',
                item.itemCode ?? '',
                item.itemName ?? '',
                item.availableStock?.toString() ?? '',
                item.stockByWarehouse ?? '',
                item.pendingQty?.toString() ?? '',
                item.uom ?? '',
                item.salesOrder ?? '',
              ];
            }).toList(),
            // 🔴 KEY SETTINGS
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: pw.TextStyle(fontSize: 7),
            cellAlignment: pw.Alignment.centerLeft,
          ),
        ],
      ),
    );
    return pdf;
  }
}
