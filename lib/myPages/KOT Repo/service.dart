import 'dart:convert';

import 'package:flatten/app_constant.dart';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/myPages/KOT%20Repo/kot%20model.dart';
import 'package:flatten/myPages/KOT%20Repo/soPendingReport.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Service {
  Future<String?> getCustomerBackupWarehouse(String customer) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_customer_backup_warehouse";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode({"customer": customer}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body["message"];

        return data?["backUp_warehouse"];
      }

      return null;
    } catch (e) {
      debugPrint("❌ getCustomerBackupWarehouse error: $e");
      return null;
    }
  }

  Future<List<PendingSoItem>> getPendingSoItems({
    String? company,
    String? salesOrder,
    String? customer,
    String? customerName,
    String? itemCode,
    String? storeName,
    String? pickingWarehouse,
    String? groupWarehouse,
    required String platingWarehouse,
  }) async {
    if (groupWarehouse == null) {
      throw Exception("Pass Group Warehouse");
    }

    if (platingWarehouse == null || platingWarehouse == "") {
      throw Exception("Plating Warehouse Group is mandatory");
    }

    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_pending_so_items_get";

    final Map<String, dynamic> args = {
      if (company != null) "company": company,
      if (salesOrder != null) "sales_order": salesOrder,
      if (customer != null) "customer": customer,
      if (customerName != null) "customer_name": customerName,
      if (itemCode != null) "item_code": itemCode,
      if (storeName != null) "store_name": storeName,
      if (groupWarehouse != null) "groupWarehouse": groupWarehouse,
      "plattingWarehouse": platingWarehouse,
      "pickingWarehouse": pickingWarehouse,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode(args),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body["message"] ?? [];
        return list.map((e) => PendingSoItem.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ getPendingSoItems error: $e");
      return [];
    }
  }

  Future<List<PendingSoItem>> getPendingSoItemsBinBased({
    String? company,
    String? salesOrder,
    String? customer,
    String? customerName,
    String? itemCode,
    String? storeName,
    String? pickingWarehouse,
    required String platingWarehouse,
  }) async {
    if (platingWarehouse == null || platingWarehouse == "") {
      throw Exception("Plating Warehouse Group is mandatory");
    }

    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_pending_bin_based_items";

    final Map<String, dynamic> args = {
      if (company != null) "company": company,
      if (salesOrder != null) "sales_order": salesOrder,
      if (customer != null) "customer": customer,
      if (customerName != null) "customer_name": customerName,
      if (itemCode != null) "item_code": itemCode,
      if (storeName != null) "store_name": storeName,
      "plattingWarehouse": platingWarehouse,
      "pickingWarehouse": pickingWarehouse,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode(args),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List list = body["message"]["data"] ?? [];
        return list.map((e) => PendingSoItem.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ getPendingSoItems error: $e");
      return [];
    }
  }

  Future<int> getPendingSoItemsBinBasedOnlyCount({
    String? company,
    String? salesOrder,
    String? customer,
    String? customerName,
    String? itemCode,
    String? storeName,
    String? pickingWarehouse,
    required String platingWarehouse,
  }) async {
    if (platingWarehouse == null || platingWarehouse == "") {
      throw Exception("Plating Warehouse Group is mandatory");
    }

    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_pending_bin_based_items";

    final Map<String, dynamic> args = {
      if (company != null) "company": company,
      if (salesOrder != null) "sales_order": salesOrder,
      if (customer != null) "customer": customer,
      if (customerName != null) "customer_name": customerName,
      if (itemCode != null) "item_code": itemCode,
      if (storeName != null) "store_name": storeName,
      "plattingWarehouse": platingWarehouse,
      "pickingWarehouse": pickingWarehouse,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode(args),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final int value = body["message"]["total"] ?? [];
        return value;
      }

      return 0;
    } catch (e) {
      debugPrint("❌ getPendingSoItems error: $e");
      return 0;
    }
  }

  Future<List<PendingKotItem>> fetchPendingKotItemWise({
    String? itemCode,
    required bool binBased,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_pending_kot_itemwise";

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode({
              if (itemCode != null && itemCode.isNotEmpty)
                "item_code": itemCode,
              "isBinBased": binBased,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body["message"] ?? [];
        return data.map((e) => PendingKotItem.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ fetchPendingKotItemWise error: $e");
      return [];
    }
  }

  ////////////   DISPLAY COUNT FUNCTIONS //////////////////
  Future<double> getTotalStockValue({
    required String company,
    required String storeName,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_total_stock_value";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": AuthService.sessionId ?? "",
        },
        body: jsonEncode({"company": company, "store_name": storeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["message"]["total_stock_value"] ?? 0).toDouble();
      } else {
        throw Exception("Failed to fetch stock value");
      }
    } catch (e) {
      print("Stock Value API Error: $e");
      return 0;
    }
  }

  Future<double> getMonthlyBilledValue({
    required String company,
    required String storeName,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_monthly_billed_value";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": AuthService.sessionId ?? "",
        },
        body: jsonEncode({"company": company, "store_name": storeName}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return (data["message"]["total_billed_value"] ?? 0).toDouble();
      } else {
        throw Exception("Failed to fetch billed value");
      }
    } catch (e) {
      print("Billed Value API Error: $e");
      return 0;
    }
  }

  Future<double> getTodayBilledValue({
    required String company,
    required String storeName,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_today_billed_value";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Cookie": AuthService.sessionId ?? "",
        },
        body: jsonEncode({"company": company, "store_name": storeName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data["message"]["today_billed_value"] ?? 0).toDouble();
      } else {
        throw Exception("Failed to fetch today billed value");
      }
    } catch (e) {
      print("Today Billed Value API Error: $e");
      return 0;
    }
  }

  Future<List<BatchStock>> fetchBatchStock({
    required String warehouse,
    required String itemCode,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_batch_stock";

    List<BatchStock> batchStockList = [];

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.sessionId ?? "",
      },
      body: jsonEncode({"warehouse": warehouse, "item_code": itemCode}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load batch stock");
    }

    final data = jsonDecode(response.body);

    final List list = data["message"] ?? [];

    batchStockList = list.map((e) => BatchStock.fromJson(e)).toList();
    return batchStockList;
  }

  Future<String?> autoMultiItemStockTransfer({
    required String sourceParentWarehouse,
    required String company,
    required String targetWarehouse,
    required List<PendingSoItem> items,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.auto_multi_item_transfer";
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode({
              "source_parent_warehouse": sourceParentWarehouse,
              "company": company,
              "items": items
                  .map((e) {
                    final double qty = getTransferQty(e);
                    if (qty <= 0) return null;
                    return e.toJsonStkTransfer(
                      targetWarehouse: targetWarehouse,
                      qty: qty,
                    );
                  })
                  .whereType<Map<String, dynamic>>() // remove nulls
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["message"] != null &&
          data["message"]["status"] == "success") {
        return data["message"]["stock_entry"];
      } else {
        throw data["exception"] ?? "Stock transfer failed";
      }
    } catch (e) {
      debugPrint("Stock Transfer Error: $e");
      return null;
    }
  }

  Future<String?> autoMultiItemStockTransferBinsToFill({
    required String sourceParentWarehouse,
    required String company,
    required List<PendingSoItem> items,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.auto_multi_item_transfer";
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode({
              "source_parent_warehouse": sourceParentWarehouse,
              "company": company,
              "items": items
                  .map((e) {
                    final double qty = getTransferQtyBinToFill(e);
                    if (qty <= 0) return null;
                    return e.customerBackupWarehouse != null
                        ? e.toJsonStkTransfer(
                            targetWarehouse: e.customerBackupWarehouse!,
                            qty: qty,
                          )
                        : null;
                  })
                  .whereType<Map<String, dynamic>>() // remove nulls
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["message"] != null &&
          data["message"]["status"] == "success") {
        return data["message"]["stock_entry"];
      } else {
        throw data["exception"] ?? "Stock transfer failed";
      }
    } catch (e) {
      debugPrint("Stock Transfer Error: $e");
      return null;
    }
  }

  Future<String?> autoMultiItemStockTransferBinBased({
    required String company,
    required String targetWarehouse,
    required List<PendingSoItem> items,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.auto_multi_item_transfer_bin_based";
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode({
              "company": company,
              "items": items
                  .map((e) {
                    final double qty = getTransferQty(e);
                    if (qty <= 0) return null;
                    return e.toJsonStkTransferBin(
                      targetWarehouse: targetWarehouse,
                      qty: qty,
                    );
                  })
                  .whereType<Map<String, dynamic>>() // remove nulls
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["message"] != null &&
          data["message"]["status"] == "success") {
        return data["message"]["stock_entry"];
      } else {
        throw data["exception"] ?? "Stock transfer failed";
      }
    } catch (e) {
      debugPrint("Stock Transfer Error: $e");
      return null;
    }
  }

  Future<bool> upsertKotReport(
    List<PendingSoItem> selectedItems,
    String stkId,
  ) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.upsert_kot_report";

    try {
      if (selectedItems.isEmpty) {
        return false;
      }
      final List<Map<String, dynamic>> items = selectedItems.map((item) {
        return {
          "soi_name": item.soiName,
          "sales_order": item.salesOrder,
          "item_code": item.itemCode,
          "so_qty": item.baseSoQty,
          "uom": item.uom,
          "pending_qty": item.basePending,
          "base_uom": item.baseUom,
          "conversion_factor": item.conversionFactor ?? 1,
          "available_stock": item.availableStock,
        };
      }).toList();
      print(items);

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId ?? "",
            },
            body: jsonEncode({"items": items, "stkId": stkId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // frappe returns { "message": { "status": "success" } }
        if (body["message"]?["status"] == "success") {
          return true;
        }
      }

      return false;
    } catch (e) {
      print("❌ upsertKotReport error: $e");
      return false;
    }
  }

  double getTransferQty(PendingSoItem item) {
    if (item.basePending == 0 ||
        item.basePending == null ||
        item.availableStock == null ||
        item.availableStock == 0) {
      return 0;
    }
    if (item.basePending! > item.availableStock!) {
      return item.availableStock!;
    } else {
      return item.basePending!;
    }
  }

  double getTransferQtyBinToFill(PendingSoItem item) {
    if (item.pendingQty == 0 ||
        item.pendingQty == null ||
        item.availableStock == null ||
        item.availableStock == 0) {
      return 0;
    }
    if (item.pendingQty! > item.availableStock!) {
      return item.availableStock!;
    } else {
      return item.pendingQty!;
    }
  }

  Future<List<PendingSoItem>> getBinToFillItems({
    required String company,
    required String parentWarehouse,
    required String excludeWarehouse,
    String? itemCode,
    String? storeName,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_bins_to_fill";

    List<PendingSoItem> binsFillItems = [];

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.sessionId ?? "",
      },
      body: jsonEncode({
        "company": company,
        "parentWarehouse": parentWarehouse,
        "excludeWarehouse": excludeWarehouse,
        "item_code": itemCode,
        "store_name": storeName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load batch stock");
    }

    final data = jsonDecode(response.body);

    final List list = data["message"]["data"] ?? [];

    binsFillItems = list.map((e) => PendingSoItem.fromJson(e)).toList();
    return binsFillItems;
  }

  Future<int> getBinToFillItemsCount({
    required String company,
    required String parentWarehouse,
    required String excludeWarehouse,
    String? itemCode,
    String? storeName,
  }) async {
    final String url =
        "$baseUrl/api/method/my_api_app.api_methods.kot_report_api.get_bins_to_fill";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Cookie": AuthService.sessionId ?? "",
      },
      body: jsonEncode({
        "company": company,
        "parentWarehouse": parentWarehouse,
        "excludeWarehouse": excludeWarehouse,
        "item_code": itemCode,
        "store_name": storeName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load batch stock");
    }

    final data = jsonDecode(response.body);
    final int value = data["message"]["total"] ?? [];
    return value;
  }
}
