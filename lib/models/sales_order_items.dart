class SoPriority {
  final String? company;
  final double? qty;
  final String? uom;
  final String? salesOrder;
  final String? itemCode;
  final String? itemName;
  final String? customerPartCode;
  final String? customerPartDesc;
  final String? majorItem;
  String? status;
  final int? idx;
  final String? soiName;
  String? makeReadyDate;
  final String? preparationDate;
  final String? dispatchedDate;
  String? deliveryDate;
  final String? customerPo;
  final String? customerBackUpStock;
  final String? totalBins;
  String? clearedBins;

  SoPriority({
    this.company,
    this.qty,
    this.uom,
    this.salesOrder,
    this.itemCode,
    this.itemName,
    this.customerPartCode,
    this.majorItem,
    this.status,
    this.idx,
    this.soiName,
    this.makeReadyDate,
    this.preparationDate,
    this.dispatchedDate,
    this.deliveryDate,
    this.customerPartDesc,
    this.customerPo,
    this.customerBackUpStock,
    this.totalBins,
    this.clearedBins,
  });

  factory SoPriority.fromJson(Map<String, dynamic> json) {
    return SoPriority(
      company: json['company'],
      qty: json['qty'],
      uom: json['uom'],
      salesOrder: json['sales_order'],
      deliveryDate: json['delivery_date'],
      itemCode: json['item_code'],
      customerPartCode: json['customer_part_code'],
      customerPartDesc: json['customer_part_desc'],
      majorItem: json['major'],
      status: json['bin_status'],
      idx: json['idx'],
      soiName: json['name'],
      makeReadyDate: json['make_ready_date'],
      preparationDate: json['preparation_date'],
      dispatchedDate: json['dispatched_date'],
      itemName: json['item_name'],
      customerPo: json['customer_po'],
      customerBackUpStock: json['customer_backup_stock'],
      totalBins: json['number_of_bins'],
      clearedBins: json['number_of_times_submit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sales_order': salesOrder,
      'soi_name': soiName,
      'delivery_date': deliveryDate,
      'item_code': itemCode,
      'bin_status': status,
      'make_ready_date': makeReadyDate,
      'idx': idx,
    };
  }

  Map<String, dynamic> binUpdateToJson(int value) {
    return {
      'item_code': itemCode,
      'customer_part_code': customerPartCode,
      'sales_order': salesOrder,
      'number_of_times_submit': value,
    };
  }
}
