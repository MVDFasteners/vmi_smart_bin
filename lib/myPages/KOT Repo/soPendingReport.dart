class PendingSoItem {
  String? salesOrder;
  String? soiName;
  double? soQty;
  double? stockQty;
  String? deliveryDate;
  String? storeName;
  double? pickedStockQty;
  double? deliveredStockQty;
  double? kotQty;
  double? freshPickedQty;
  double? availableStock;
  double? plattingStockQty;
  double? pendingQty;
  double? pendingQtyBaseUom;
  double? delivered_stock_qty;
  double? plating_stock_qty;
  String? uom;
  String? modeOfShipment;
  int? colorCode;
  bool isSelected;
  double? conversionFactor;
  String? baseUom;
  double? baseSoQty;

  /// bins to fill items ..........................
  String? company;
  String? customer;
  String? customerName;
  String? itemCode;
  String? itemName;
  double? basePending;
  String? customerBackupWarehouse;
  double? stock_qty;
  String? vmiId;
  String? poNumber;
  double? binQty;
  double? backupStk;

  PendingSoItem({
    this.company,
    this.salesOrder,
    this.customer,
    this.customerName,
    this.soiName,
    this.itemCode,
    this.itemName,
    this.soQty,
    this.stockQty,
    this.deliveryDate,
    this.storeName,
    this.pickedStockQty,
    this.deliveredStockQty,
    this.kotQty,
    this.availableStock,
    this.plattingStockQty,
    this.pendingQty,
    this.stock_qty,
    this.delivered_stock_qty,
    this.uom,
    this.colorCode,
    this.isSelected = false,
    this.baseUom,
    this.conversionFactor,
    this.pendingQtyBaseUom,
    this.basePending,
    this.modeOfShipment,
    this.baseSoQty,
    this.freshPickedQty,
    this.customerBackupWarehouse,
    this.vmiId,
    this.poNumber,
    this.binQty,
    this.backupStk,
  });


  factory PendingSoItem.fromJson(Map<String, dynamic> json) {
    return PendingSoItem(
      salesOrder: json['sales_order'] ?? "",
      freshPickedQty: json['fresh_picked_qty'],
      soiName: json['soi_name'] ?? "",
      soQty: (json['so_qty'] ?? 0).toDouble(),
      stockQty: (json['stock_qty'] ?? 0).toDouble(),
      deliveryDate: json['delivery_date'],
      storeName: json['store_name'],
      baseUom: json['stock_uom'],
      modeOfShipment: json['custom_mode_of_shipment'],

      pickedStockQty: (json['picked_stock_qty'] ?? 0).toDouble(),
      deliveredStockQty: (json['delivered_stock_qty'] ?? 0).toDouble(),
      kotQty: (json['kot_qty'] ?? 0).toDouble(),
      plattingStockQty: (json['platting_stock_qty'] ?? 0).toDouble(),
      pendingQty: (json['pending_qty'] ?? 0).toDouble(),
      pendingQtyBaseUom: (json['pending_qty_base_uom'] ?? 0).toDouble(),

      /// bins to fill items.............................................................
      company: json['company'] ?? "",
      customer: json['customer'] ?? "",
      customerName: json['customer_name'] ?? "",
      itemCode: json['item_code'] ?? "",
      itemName: json['item_name'] ?? "",
      uom: json['uom'] ?? "",
      binQty: (json['bin_qty'] ?? 0).toDouble(),
      customerBackupWarehouse: json['backup_warehouse'] ?? "",
      backupStk: (json['backup_stock'] ?? 0).toDouble(),
      availableStock: (json['available_stock'] ?? 0).toDouble(),
      vmiId: json['vmi_name'] ?? "",
      poNumber: json['po_number'] ?? "",
      conversionFactor: json['conversion_factor'],
    );
  }

  Map<String, dynamic> toJsonStkTransfer({
    required String targetWarehouse,
    required double qty,
  }) => {
    "item_code": itemCode,
    "qty": qty,
    "target_warehouse": targetWarehouse,
  };

  Map<String, dynamic> toJsonStkTransferBin({
    required String targetWarehouse,
    required double qty,
  }) => {
    "item_code": itemCode,
    "qty": qty,
    "source_warehouse": customerBackupWarehouse,
    "target_warehouse": targetWarehouse,
  };

  PendingSoItem copyWith({
    double? availableStock,
    double? pendingQty,
    double? basePending,
    double? baseSoQty,
    int? colorCode,
    bool? isSelected,
  }) {
    return PendingSoItem(
      company: company,
      salesOrder: salesOrder,
      customer: customer,
      customerName: customerName,
      soiName: soiName,
      itemCode: itemCode,
      itemName: itemName,
      soQty: soQty,
      stockQty: stockQty,
      deliveryDate: deliveryDate,
      storeName: storeName,
      pickedStockQty: pickedStockQty,
      deliveredStockQty: deliveredStockQty,
      kotQty: kotQty,
      modeOfShipment: modeOfShipment,
      availableStock: availableStock ?? this.availableStock,
      plattingStockQty: plattingStockQty,
      pendingQty: pendingQty ?? this.pendingQty,
      basePending: basePending ?? this.basePending,
      baseSoQty: baseSoQty ?? this.baseSoQty,
      stock_qty: stock_qty,
      delivered_stock_qty: delivered_stock_qty,
      uom: uom,
      baseUom: baseUom,
      conversionFactor: conversionFactor,
      colorCode: colorCode ?? this.colorCode,
      isSelected: isSelected ?? this.isSelected,
      customerBackupWarehouse: customerBackupWarehouse,
    );
  }
}
