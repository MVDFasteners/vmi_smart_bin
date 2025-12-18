class VmiItems {
  final String? vmiId;
  final String? vmiItemId;
  final String? poNumber;
  final String? company;
  final double? qty;
  final double? rate;
  final String? uom;
  final double? amount;
  final String? itemCode;
  final String? itemName;
  final String? customerPartCode;
  final String? customerPartDesc;
  final double? customerBackUpStock;
  final int? totalBins;
  int? clearedBins;
  final int? isBulkSubmit;
  final double? binWeight;
  final String? binName;

  final String? priceList;
  final String? currency;
  final String? contactPerson;

  VmiItems({
    this.vmiId,
    this.vmiItemId,
    this.poNumber,
    this.company,
    this.isBulkSubmit,
    this.qty,
    this.rate,
    this.uom,
    this.amount,
    this.itemCode,
    this.itemName,
    this.customerPartCode,
    this.customerPartDesc,
    this.customerBackUpStock,
    this.totalBins,
    this.clearedBins,
    this.binWeight,
    this.binName,
    this.priceList,
    this.contactPerson,
    this.currency,
  });

  factory VmiItems.fromJson(Map<String, dynamic> json) {
    return VmiItems(
      company: json['company'],
      vmiId: json['vmi_id'],
      vmiItemId: json['vmi_item_id'],
      poNumber: json['po_number'],
      qty: json['bin_qty'],
      uom: json['uom'],
      rate: json['price'],
      amount: json['amount'],
      itemCode: json['item_code'],
      itemName: json['item_name'],
      customerPartCode: json['customer_part_code'],
      customerPartDesc: json['customer_part_description'],
      customerBackUpStock: json['stock_qty'],
      totalBins: json['number_of_bins'],
      clearedBins: json['number_of_times_submit'],
      binWeight: json['bin_weight'],
      isBulkSubmit: json['bulk_submit'],
      binName: json['bin_name'],
      priceList: json['price_list'],
      currency: json['currency'],
      contactPerson: json['contact_person'],
    );
  }
}
