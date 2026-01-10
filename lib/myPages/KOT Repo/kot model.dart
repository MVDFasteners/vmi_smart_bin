
class KotStockRow {
  final String salesOrder;
  final String soiName;
  final String itemCode;
  final DateTime deliveryDate;

  final double soQty;
  final double availableStock;
  final double kotQty;

  double displayStock = 0; // calculated

  KotStockRow({
    required this.salesOrder,
    required this.soiName,
    required this.itemCode,
    required this.deliveryDate,
    required this.soQty,
    required this.availableStock,
    required this.kotQty,
  });
}

class PendingKotItem {
  final String itemCode;
  final double pendingKotQty;

  PendingKotItem({required this.itemCode, required this.pendingKotQty});

  factory PendingKotItem.fromJson(Map<String, dynamic> json) {
    return PendingKotItem(
      itemCode: json['item_code'],
      pendingKotQty: (json['pending_kot_qty'] as num).toDouble(),
    );
  }
}

class BatchStock {
  final String batchNo;
  final String creation;
  final String warehouse;
  final double balanceQty;

  BatchStock({
    required this.batchNo,
    required this.warehouse,
    required this.creation,
    required this.balanceQty,
  });

  factory BatchStock.fromJson(Map<String, dynamic> json) {
    return BatchStock(
      batchNo: json['batch_no'],
      warehouse: json['warehouse'],
      creation: json['creation'],
      balanceQty: (json['balance_qty'] ?? 0).toDouble(),
    );
  }
}


class BinsFillModel {
  final String itemCode;
  final String vmiName;
  final String poNumber;

  final double binQty;
  final String customer;
  final String customerName;
  final String backupWarehouse;

  final double availableStock;
  final double locationQty;

  BinsFillModel({
    required this.itemCode,
    required this.vmiName,
    required this.poNumber,
    required this.binQty,
    required this.customer,
    required this.customerName,
    required this.backupWarehouse,
    required this.availableStock,
    required this.locationQty,
  });

  factory BinsFillModel.fromJson(Map<String, dynamic> json) {
    return BinsFillModel(
      itemCode: json['item_code'] ?? '',
      vmiName: json['vmi_name'] ?? '',
      poNumber: json['po_number'] ?? '',

      binQty: (json['bin_qty'] ?? 0).toDouble(),
      customer: json['customer'] ?? '',
      customerName: json['customer_name'] ?? '',
      backupWarehouse: json['custom_back_up_warehouse'] ?? '',

      availableStock: (json['available_stock'] ?? 0).toDouble(),
      locationQty: (json['location_qty'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'vmi_name': vmiName,
      'po_number': poNumber,
      'bin_qty': binQty,
      'customer': customer,
      'customer_name': customerName,
      'custom_back_up_warehouse': backupWarehouse,
      'available_stock': availableStock,
      'location_qty': locationQty,
    };
  }
}

