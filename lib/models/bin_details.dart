class BinDetails {
  final String? bin;
  final String? itemCode;
  final String? salesOrder;
  final String? itemName;
  final String? customerPartCode;
  final String? customerPartDesc;

  BinDetails({
    this.bin,
    this.salesOrder,
    this.itemCode,
    this.itemName,
    this.customerPartCode,
    this.customerPartDesc,
  });

  factory BinDetails.fromJson(Map<String, dynamic> json) {
    return BinDetails(
      bin: json['bin'],
      itemCode: json['item_code'],
      itemName: json['item_name'],
      customerPartCode: json['customer_part_code'],
      salesOrder: json['sales_order'],
    );
  }
}
