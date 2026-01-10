// class KOTReportController extends GetxController {
//
//   /// 🔹 1. Server authoritative data (NEVER modify)
//   List<PendingSoItem> masterSoList = [];
//
//   /// 🔹 2. Item-wise KOT (NEVER modify)
//   List<PendingKotItem> kotItemsList = [];
//
//   /// 🔹 3. Derived stock-reduced list (safe to rebuild)
//   List<PendingSoItem> reducedSoList = [];
//
//   /// 🔹 4. UI-visible filtered list
//   List<PendingSoItem> filteredSoList = [];
//
//   int selectedCount = 0;
//
//   String company = "MVD FASTENERS PRIVATE LIMITED";
//   String warehouse = "All Warehouses - MVDF";
//   String stockStatus = "ALL";
//   String reportType = "MAIN";
//
//   String searchItem = "";
//   String searchItemName = "";
//   String searchSo = "";
//   String searchCustomer = "";
//
//   // --------------------------------------------------
//   // 🔹 FETCH SO ITEMS (ONCE per warehouse/company)
//   // --------------------------------------------------
//   Future<void> getSoItems({
//     required String company,
//     String? filterGroupWarehouse,
//     String? storeName,
//     int binBased = 0,
//   }) async {
//     final items = await Service().getPendingSoItems(
//       company: company,
//       binBasedSo: binBased,
//       storeName: storeName,
//       groupWarehouse: filterGroupWarehouse,
//     );
//
//     masterSoList = items;
//
//     // build reduced list only if KOT already loaded
//     if (kotItemsList.isNotEmpty) {
//       buildReducedList();
//     }
//
//     applyFilters();
//     update();
//   }
//
//   // --------------------------------------------------
//   // 🔹 FETCH ITEM-WISE KOT (SMALL API)
//   // --------------------------------------------------
//   Future<void> getKotItems() async {
//     kotItemsList = await Service().fetchPendingKotItemWise();
//
//     if (masterSoList.isNotEmpty) {
//       buildReducedList();
//       applyFilters();
//     }
//
//     update();
//   }
//
//   // --------------------------------------------------
//   // 🔹 BUILD STOCK-REDUCED LIST (NO BUSINESS LOGIC)
//   // --------------------------------------------------
//   void buildReducedList() {
//     final Map<String, double> kotMap = {
//       for (var k in kotItemsList) k.itemCode: k.pendingKotQty
//     };
//
//     reducedSoList = masterSoList.map((item) {
//       final double itemWiseKot = kotMap[item.itemCode] ?? 0;
//
//       return item.copyWith(
//         availableStockAfterKot:
//         (item.availableStock - itemWiseKot).clamp(0, double.infinity),
//       );
//     }).toList();
//   }
//
//   // --------------------------------------------------
//   // 🔹 APPLY UI FILTERS ONLY
//   // --------------------------------------------------
//   void applyFilters() {
//     filteredSoList = reducedSoList.where((item) {
//       if (searchItem.isNotEmpty &&
//           !item.itemCode.toLowerCase().contains(searchItem.toLowerCase())) {
//         return false;
//       }
//
//       if (searchItemName.isNotEmpty &&
//           !item.itemName.toLowerCase().contains(searchItemName.toLowerCase())) {
//         return false;
//       }
//
//       if (searchSo.isNotEmpty &&
//           !item.salesOrder.toLowerCase().contains(searchSo.toLowerCase())) {
//         return false;
//       }
//
//       if (searchCustomer.isNotEmpty &&
//           !item.customerName
//               .toLowerCase()
//               .contains(searchCustomer.toLowerCase())) {
//         return false;
//       }
//
//       return true;
//     }).toList();
//   }
// }
//
//
//
// class PendingSoItem {
//   final String company;
//   final String salesOrder;
//   final String customer;
//   final String customerName;
//
//   final String soiName;
//   final String itemCode;
//   final String itemName;
//
//   final double qty;
//   final double stockQty;
//   final String? deliveryDate;
//
//   final String? storeName;
//
//   final double pickedStockQty;
//   final double deliveredStockQty;
//   final double kotQty;
//
//   final double availableStock;
//
//   /// 🔹 Derived (client-side only)
//   final double availableStockAfterKot;
//
//   PendingSoItem({
//     required this.company,
//     required this.salesOrder,
//     required this.customer,
//     required this.customerName,
//     required this.soiName,
//     required this.itemCode,
//     required this.itemName,
//     required this.qty,
//     required this.stockQty,
//     this.deliveryDate,
//     this.storeName,
//     required this.pickedStockQty,
//     required this.deliveredStockQty,
//     required this.kotQty,
//     required this.availableStock,
//     double? availableStockAfterKot,
//   }) : availableStockAfterKot =
//       availableStockAfterKot ?? availableStock;
//
//   /// 🔹 copyWith (THIS FIXES YOUR ERROR)
//   PendingSoItem copyWith({
//     double? availableStockAfterKot,
//   }) {
//     return PendingSoItem(
//       company: company,
//       salesOrder: salesOrder,
//       customer: customer,
//       customerName: customerName,
//       soiName: soiName,
//       itemCode: itemCode,
//       itemName: itemName,
//       qty: qty,
//       stockQty: stockQty,
//       deliveryDate: deliveryDate,
//       storeName: storeName,
//       pickedStockQty: pickedStockQty,
//       deliveredStockQty: deliveredStockQty,
//       kotQty: kotQty,
//       availableStock: availableStock,
//       availableStockAfterKot:
//       availableStockAfterKot ?? this.availableStockAfterKot,
//     );
//   }
//
//   factory PendingSoItem.fromJson(Map<String, dynamic> json) {
//     return PendingSoItem(
//       company: json['company'] ?? '',
//       salesOrder: json['sales_order'] ?? '',
//       customer: json['customer'] ?? '',
//       customerName: json['customer_name'] ?? '',
//       soiName: json['soi_name'] ?? '',
//       itemCode: json['item_code'] ?? '',
//       itemName: json['item_name'] ?? '',
//       qty: (json['qty'] ?? 0).toDouble(),
//       stockQty: (json['stock_qty'] ?? 0).toDouble(),
//       deliveryDate: json['delivery_date'],
//       storeName: json['store_name'],
//       pickedStockQty:
//       (json['picked_stock_qty'] ?? 0).toDouble(),
//       deliveredStockQty:
//       (json['delivered_stock_qty'] ?? 0).toDouble(),
//       kotQty: (json['kot_qty'] ?? 0).toDouble(),
//       availableStock:
//       (json['available_stock'] ?? 0).toDouble(),
//     );
//   }
// }
