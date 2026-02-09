import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flatten/myPages/KOT%20Repo/soPendingReport.dart';
import 'package:path_provider/path_provider.dart';

class ExcelPrintViewKot {
  Future<File> generateInvoiceExcel({
    required String companyName,
    required List<PendingSoItem> items,
  }) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['KOT'];

    sheet.setColumnWidth(0, 18);
    sheet.setColumnWidth(1, 32);
    sheet.setColumnWidth(2, 10);
    sheet.setColumnWidth(3, 10);

    // 4️⃣ Company row
    sheet.appendRow([TextCellValue('Company'), TextCellValue(companyName)]);

    sheet.appendRow([]);

    // 5️⃣ Header row
    sheet.appendRow([
      TextCellValue('Customer'),
      TextCellValue('MOS'),
      TextCellValue('Delivery Date'),
      TextCellValue('Item Code'),
      TextCellValue('Item Name'),
      TextCellValue('Available Stock'),
      TextCellValue('Available Stock By Warehouses'),
      TextCellValue('Pending Qty'),
      TextCellValue('UOM'),
      TextCellValue('Sales Order'),
    ]);

    // 6️⃣ Data rows
    for (final item in items) {
      sheet.appendRow([
        TextCellValue(item.customerName ?? ''),
        TextCellValue(item.modeOfShipment ?? ''),
        TextCellValue(item.deliveryDate ?? ''),
        TextCellValue(item.itemCode ?? ''),
        TextCellValue(item.itemName ?? ''),
        TextCellValue((item.availableStock ?? 0).toString()),
        TextCellValue(item.stockByWarehouse ?? ""),
        DoubleCellValue(item.pendingQty ?? 0),
        TextCellValue(item.uom ?? ''),
        TextCellValue(item.salesOrder ?? ''),
      ]);
    }

    // 7️⃣ VERY IMPORTANT – open this sheet by default
    excel.setDefaultSheet(sheet.sheetName);

    // 8️⃣ (Optional) remove auto Sheet1
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }
    final List<int>? bytes = excel.save();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/KOT_Report.xlsx');

    await file.writeAsBytes(bytes!);

    return file;
  }
}
