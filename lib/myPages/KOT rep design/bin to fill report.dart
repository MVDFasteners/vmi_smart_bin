// import 'package:flatten/myPages/KOT%20rep%20design/reportController.dart';
// import 'package:flatten/myPages/KOT%20rep%20design/stock%20view.dart';
// import 'package:flutter/material.dart';
//
// class BinsToFillReportTable extends StatefulWidget {
//   final KOTReportController kotReportController;
//
//   const BinsToFillReportTable({super.key, required this.kotReportController});
//
//   @override
//   State<BinsToFillReportTable> createState() => _BinsToFillReportTableState();
// }
//
// class _BinsToFillReportTableState extends State<BinsToFillReportTable> {
//   final ScrollController verticalController = ScrollController();
//   final ScrollController horizontalController = ScrollController();
//
//   @override
//   void dispose() {
//     verticalController.dispose();
//     horizontalController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scrollbar(
//       controller: horizontalController,
//       thumbVisibility: true,
//       child: SingleChildScrollView(
//         controller: horizontalController,
//         scrollDirection: Axis.horizontal,
//         child: SizedBox(
//           width: 1700,
//           child: Column(
//             children: [
//               Container(
//                 height: 44,
//                 color: Colors.grey.shade300,
//                 child: Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16),
//                       child: headerCell("Customer", 180),
//                     ),
//                     headerCell("Item", 140),
//                     headerCell("Description", 200),
//                     headerCell("Backup Location", 200),
//                     headerCell("Backup Qty", 100),
//                     headerCell("UOM", 100),
//                     headerCell("Available Qty", 100),
//                     headerCell("Pending", 120),
//                     headerCell("Btn", 60),
//                   ],
//                 ),
//               ),
//               widget.kotReportController.isLoading
//                   ? Padding(
//                       padding: const EdgeInsets.only(top: 30),
//                       child: SizedBox(
//                         height: 50,
//                         width: 50,
//                         child: CircularProgressIndicator(),
//                       ),
//                     )
//                   : Expanded(
//                       child: Scrollbar(
//                         controller: verticalController,
//                         thumbVisibility: true,
//                         child: ListView.builder(
//                           controller: verticalController,
//                           itemCount:
//                               widget.kotReportController.binsFillItemsList.length,
//                           itemBuilder: (context, index) {
//                             final r = widget
//                                 .kotReportController
//                                 .binsFillItemsList[index];
//                             return InkWell(
//                               onLongPress: () async {
//                                 await showBatchStockDialog(
//                                   context,
//                                   r.itemCode,
//                                   widget.kotReportController,
//                                 );
//                               },
//                               onTap: () => widget.kotReportController
//                                   .toggleSelection(r, context),
//                               child: Container(
//                                 height: 44,
//                                 color: getRowColor(r.colorCode),
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 16),
//                                       child: cell(
//                                         r.deliveryDate ?? "",
//                                         140,
//                                         selected: r.isSelected,
//                                       ),
//                                     ),
//                                     cell(
//                                       r.salesOrder,
//                                       220,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       r.customerName,
//                                       180,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       r.itemCode,
//                                       140,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       r.itemName,
//                                       200,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       "${r.soQty}",
//                                       100,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       r.uom ?? "",
//                                       100,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       r.modeOfShipment ?? "",
//                                       100,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       "${r.pendingQty}",
//                                       120,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       "${r.availableStock}",
//                                       120,
//                                       selected: r.isSelected,
//                                     ),
//                                     cell(
//                                       "${r.plattingStockQty}",
//                                       120,
//                                       selected: r.isSelected,
//                                     ),
//                                     ElevatedButton(
//                                       onPressed: () async {
//                                         await showBatchStockDialog(
//                                           context,
//                                           r.itemCode,
//                                           widget.kotReportController,
//                                         );
//                                       },
//                                       child: Text("View"),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget headerCell(String text, double width) {
//     return SizedBox(
//       width: width,
//       child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//     );
//   }
//
//   Widget cell(String text, double width, {bool selected = false}) {
//     return SizedBox(
//       width: width,
//       child: Text(
//         text,
//         overflow: TextOverflow.ellipsis,
//         style: selected
//             ? selectedStyle()
//             : TextStyle(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   TextStyle selectedStyle() {
//     return TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 20,
//       color: Colors.purple,
//     );
//   }
//
//   Color getRowColor(int? code) {
//     switch (code) {
//       case 1:
//         return Colors.green.shade100;
//       case 2:
//         return Colors.orange.shade100;
//       case 3:
//         return Colors.blue.shade100;
//       default:
//         return Colors.red.shade100;
//     }
//   }
//
//   Future<void> showBatchStockDialog(
//     BuildContext context,
//     String itemCode,
//     KOTReportController controller,
//   ) async {
//     await showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (_) =>
//           BatchStockDialog(itemCode: itemCode, controller: controller),
//     );
//   }
// }
