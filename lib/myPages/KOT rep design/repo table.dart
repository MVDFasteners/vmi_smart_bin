import 'package:flatten/myPages/KOT%20Repo/soPendingReport.dart';
import 'package:flatten/myPages/KOT%20rep%20design/reportController.dart';
import 'package:flatten/myPages/KOT%20rep%20design/stock%20view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportTable extends StatefulWidget {
  final KOTReportController kotReportController;

  const ReportTable({super.key, required this.kotReportController});

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();

  @override
  void dispose() {
    verticalController.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 2500,
          child: Column(
            children: [
              Container(
                height: 44,
                color: Colors.grey.shade300,
                child: Row(children: [..._header()]),
              ),
              widget.kotReportController.isLoading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Expanded(
                      child: Scrollbar(
                        controller: verticalController,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: verticalController,
                          itemCount:
                              widget.kotReportController.filteredSoList.length,
                          itemBuilder: (context, index) {
                            PendingSoItem r = widget
                                .kotReportController
                                .filteredSoList[index];
                            return InkWell(
                              onLongPress: () async {
                                await showBatchStockDialog(
                                  context,
                                  r.itemCode ?? "--",
                                  widget.kotReportController,
                                );
                              },
                              onTap: () => widget.kotReportController
                                  .toggleSelection(r, context),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  height: 44,
                                  color: getRowColor(r.colorCode),
                                  child: Row(children: [..._values(r)]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _header() {
    if (widget.kotReportController.reportType == "Bins To Fill") {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: headerCell("Customer", 200),
        ),
        headerCell("Item", 150),
        headerCell("Description", 200),
        headerCell("UOM", 100),
        headerCell("Pending", 120),
        headerCell("Available Stock", 120),
        headerCell("Backup Warehouse", 140),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: headerCell("Delivery Date", 140),
        ),
        headerCell("Sales Order", 220),
        headerCell("Customer", 200),
        headerCell("Item", 150),
        headerCell("Description", 200),
        headerCell("SO Qty", 100),
        headerCell("UOM", 100),
        headerCell("MOS", 100),
        headerCell("Pending", 120),
        headerCell("Available Stock", 120),
        headerCell("Packet Qty", 120),
        headerCell("Box Qty", 120),
        headerCell("Plating Stock", 120),
        headerCell("Btn", 60),
      ];
    }
  }

  void copyText(String label, String text) {
    if (text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  Widget copyCell(
    String label,
    String value,
    double width, {
    bool selected = false,
  }) {
    return GestureDetector(
      onDoubleTap: () => copyText(label, value),
      child: cell(value.isEmpty ? "--" : value, width, selected: selected),
    );
  }

  List<Widget> _values(PendingSoItem r) {
    if (widget.kotReportController.reportType == "Bins To Fill") {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: copyHoverCell(
            "Customer",
            r.customerName ?? "",
            200,
            selected: r.isSelected,
          ),
        ),
        copyHoverCell(
          "Item Code",
          r.itemCode ?? "",
          150,
          selected: r.isSelected,
        ),
        copyHoverCell(
          "Item Name",
          r.itemName ?? "",
          200,
          selected: r.isSelected,
        ),
        cell(r.uom ?? "", 100, selected: r.isSelected),
        cell("${r.pendingQty}", 120, selected: r.isSelected),
        cell("${r.availableStock}", 120, selected: r.isSelected),
        copyHoverCell(
          "Backup Warehouse",
          r.customerBackupWarehouse ?? "",
          200,
          selected: r.isSelected,
        ),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: copyHoverCell(
            "Delivery Date",
            r.deliveryDate ?? "",
            140,
            selected: r.isSelected,
          ),
        ),
        copyHoverCell(
          "Sales Order",
          r.salesOrder ?? "",
          220,
          selected: r.isSelected,
        ),
        copyHoverCell(
          "Customer",
          r.customerName ?? "",
          200,
          selected: r.isSelected,
        ),
        copyHoverCell(
          "Item Code",
          r.itemCode ?? "",
          150,
          selected: r.isSelected,
        ),
        copyHoverCell(
          "Item Name",
          r.itemName ?? "",
          200,
          selected: r.isSelected,
        ),
        cell("${r.soQty}", 100, selected: r.isSelected),
        cell(r.uom ?? "", 100, selected: r.isSelected),
        cell(r.modeOfShipment ?? "", 100, selected: r.isSelected),
        cell("${r.pendingQty}", 120, selected: r.isSelected),
        cell("${r.availableStock}", 120, selected: r.isSelected),
        textFrmField(r.packetQtyController),
        textFrmField(r.boxQtyController),
        // textFrmField(r.noOfBoxQtyController),
        cell("${r.plattingStockQty}", 120, selected: r.isSelected),
        ElevatedButton(
          onPressed: () async {
            await showBatchStockDialog(
              context,
              r.itemCode ?? "--",
              widget.kotReportController,
            );
          },
          child: Text("View"),
        ),
      ];
    }
  }

  Widget textFrmField(TextEditingController controller) {
    return SizedBox(
      width: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextFormField(controller: controller),
      ),
    );
  }

  Widget copyHoverCell(
    String label,
    String value,
    double width, {
    bool selected = false,
  }) {
    return GestureDetector(
      onDoubleTap: () => copyText(label, value),
      child: Tooltip(
        message: value,
        waitDuration: const Duration(milliseconds: 400),
        child: cell(value.isEmpty ? "--" : value, width, selected: selected),
      ),
    );
  }

  Widget headerCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget cell(String text, double width, {bool selected = false}) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: selected
            ? selectedStyle()
            : TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  TextStyle selectedStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.purple,
    );
  }

  Color getRowColor(int? code) {
    switch (code) {
      case 1:
        return widget.kotReportController.isDarkColor
            ? Colors.green.shade400
            : Colors.green.shade100;
      case 2:
        return widget.kotReportController.isDarkColor
            ? Colors.orange.shade400
            : Colors.orange.shade100;
      case 3:
        return widget.kotReportController.isDarkColor
            ? Colors.blue.shade400
            : Colors.blue.shade100;
      default:
        return widget.kotReportController.isDarkColor
            ? Colors.red.shade400
            : Colors.red.shade100;
    }
  }

  Future<void> showBatchStockDialog(
    BuildContext context,
    String itemCode,
    KOTReportController controller,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          BatchStockDialog(itemCode: itemCode, controller: controller),
    );
  }
}
