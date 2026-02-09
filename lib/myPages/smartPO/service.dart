import 'dart:convert';
import 'dart:io';
import 'package:flatten/app_constant.dart';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/myPages/smartPO/autoPoItemsModel.dart';
import 'package:http/http.dart' as http;

class AutoPoService {
  Future<List<AutoPoItem>> getAutoPoItems({
    String? company,
    String? supplier,
    String? itemCode,
    int cartItems = 0,
  }) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return [];
    }

    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.smart_order_po.get_auto_po_items",
    );

    final Map<String, dynamic> body = {};

    if (company != null) body["company"] = company;
    if (supplier != null) body["supplier"] = supplier;
    if (itemCode != null) body["item_code"] = itemCode;
    body["added_to_cart"] = cartItems;

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.sessionId!,
      },
      body: jsonEncode(body),
    );
    response.body;
    if (response.statusCode != 200) {
      throw Exception("Failed to fetch Auto PO items");
    }

    final decoded = jsonDecode(response.body);

    if (decoded["message"] == null) return [];

    return List<AutoPoItem>.from(
      decoded["message"].map((e) => AutoPoItem.fromJson(e)),
    );
  }

  Future<bool> updateAddedToCart({
    required String childName,
    required bool addedToCart,
    String? lastPoId,
  }) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return false;
    }

    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.smart_order_po.update_added_to_cart",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.sessionId!,
      },
      body: jsonEncode({
        "child_name": childName,
        "added_to_cart": addedToCart ? 1 : 0,
        "last_purchase_order": lastPoId,
      }),
    );
    if (response.statusCode != 200) {

      throw Exception("Failed to update cart status");
    }
    final decoded = jsonDecode(response.body);
    return decoded["message"] != null;
  }

  Future<String?> createPurchaseOrder({
    required List<AutoPoItem> orderItems,
  }) async {
    if (AuthService.sessionId == null || orderItems.isEmpty) return null;
    final response = await http.post(
      Uri.parse(
        "$baseUrl/api/method/my_api_app.api_methods.smart_order_po.create_purchase_order",
      ),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Cookie': AuthService.sessionId!, // consider token auth later
      },
      body: jsonEncode({
        "supplier": orderItems[0].supplier,
        "company": orderItems[0].company,
        "buying_price_list": orderItems[0].priceList,
        "currency": orderItems[0].currency,
        "set_warehouse": orderItems[0].setWarehouse,
        "schedule_date": DateTime.now().toIso8601String().split('T')[0],
        "cart_items": orderItems
            .map(
              (e) => {
                "item_code": e.itemCode,
                "qty": e.binQty, // ✅ correct purchase qty
                "uom": e.uom,
                "rate": e.rate,
                "custom_unit_rate": e.rate,
                "child_name": e.rowId, // ✅ for added_to_cart update
              },
            )
            .toList(),
      }),
    );
    response.body;

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"]?["purchase_order"];
    }

    return null;
  }
}
