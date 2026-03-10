import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flatten/models/report_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportAndShareExcel(List<ReportListModel> reportList) async {
  var excel = Excel.createExcel();

  // 1. Explicitly rename or use a specific sheet name
  String sheetName = "SO Report";
  excel.rename(excel.getDefaultSheet()!, sheetName);
  Sheet sheet = excel[sheetName];

  // Headers
  sheet.appendRow([
    TextCellValue('Item Code'),
    TextCellValue('Item Name'),
    TextCellValue('Customer Part Code'),
    TextCellValue('Customer Part Desc'),
    TextCellValue('UOM'),
    TextCellValue('Qty'),
    TextCellValue('Delivered Qty'),
    TextCellValue('Sales Order'),
    TextCellValue('Customer PO'),
    TextCellValue('SO Date'),
  ]);

  // Data Rows
  for (var item in reportList) {
    sheet.appendRow([
      TextCellValue(item.itemCode ?? ''),
      TextCellValue(item.itemName ?? ''),
      TextCellValue(item.customerPartCode ?? ''),
      TextCellValue(item.customerPartDesc ?? ''),
      TextCellValue(item.uom ?? ''),
      DoubleCellValue((item.qty ?? 0).toDouble()),
      DoubleCellValue((item.deliveredQty ?? 0).toDouble()),
      TextCellValue(item.salesOrder ?? ''),
      TextCellValue(item.customerPo ?? ''),
      TextCellValue(item.soDate ?? ''),
    ]);
  }

  // 2. The most reliable way to save to a specific file path:
  final dir = await getTemporaryDirectory();
  final filePath = "${dir.path}/SO_Report.xlsx";
  final file = File(filePath);

  // Use encode() to get the bytes and write them manually
  // This is often more reliable than excel.save() in some library versions
  var bytes = excel.encode();
  if (bytes != null) {
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
  }

  await Share.shareXFiles([XFile(file.path)], text: "Sales Order Report");
}
