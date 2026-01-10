class ReportListModel {
  final String? company;
  final double? qty;
  final String? uom;
  final String? salesOrder;
  final String? itemCode;
  final String? itemName;
  final String? customerPartCode;
  final String? customerPartDesc;
  final String? majorItem;
  final String? status;
  final int? idx;
  final String? soiName;
  final String? makeReadyDate;
  final String? preparationDate;
  final String? dispatchedDate;
  final String? deliveryDate;
  final String? customerPo;
  final String? invoiceId;
  final String? soDate;
  final double? deliveredQty;

  ReportListModel({
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
    this.invoiceId,
    this.soDate,
    this.deliveredQty,
  });

  factory ReportListModel.fromJson(Map<String, dynamic> json) {
    return ReportListModel(
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
      invoiceId: json['invoice_id'],
      soDate: json['transaction_date'],
      deliveredQty: json['delivered_qty'],
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
}
