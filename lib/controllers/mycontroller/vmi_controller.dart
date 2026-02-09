import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/models/bin_details.dart';
import 'package:flatten/models/report_list.dart';
import 'package:flatten/models/user.dart';
import 'package:flatten/models/vmi_items.dart';
import 'package:flutter/material.dart';
import 'package:flatten/app_constant.dart';
import 'package:flatten/models/sales_order_items.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class VMIController extends GetxController {
  List<SoPriority> soItemList = [];
  List<BinDetails> binDetails = [];
  List<VmiItems> cartList = [];
  List<ReportListModel> reportList = [];

  List<VmiItems> vmiItems = [];

  bool selectAll = false;
  bool isSubmittingCartItems = false;
  bool reportLoading = false;
  bool itemLoading = false;
  bool onSubmitLoading = false;

  String? selectedYear;
  String? selectedMonth;

  bool isEmail = true;

  final TextEditingController searchController = TextEditingController();

  final TextEditingController soSearchCtrl = TextEditingController();
  final TextEditingController itemSearchCtrl = TextEditingController();
  final TextEditingController itemDescSearchCtrl = TextEditingController();

  String selectedStatus = "ALL";
  List<String> statusList = ["ALL", "PENDING", "DISPATCHED"];

  TextEditingController fromDateCtrl = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  TextEditingController toDateCtrl = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  TextEditingController dateRangeController = TextEditingController();
  DateTimeRange? selectedRange;

  Future<void> clearFilters(UserModel user) async {
    dateRangeController.clear();
    selectedRange = null;

    soSearchCtrl.clear();
    itemSearchCtrl.clear();
    itemDescSearchCtrl.clear();

    selectedStatus = "ALL";

    await fetchDispatchedItemsList(user: user);
  }

  String fmt(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String displayFmt(DateTime d) {
    return "${d.day}-${d.month}-${d.year}";
  }

  bool isReadyToOrder(VmiItems item) {
    bool makeOrderStatus = false;
    double validateHrs = (item.validateHrs ?? 0).toDouble();
    if (item.lastOrderedDate != null && item.lastOrderedTime != null) {
      double value = getWorkingHours(
        item.lastOrderedDate,
        item.lastOrderedTime,
      );

      if (validateHrs > value) {
        makeOrderStatus = true;
      }
    }
    return makeOrderStatus;
  }

  double getWorkingHours(String? date, String? time) {
    if (date == null || time == null || date.isEmpty || time.isEmpty) {
      return 0.0;
    }
    try {
      final DateTime start = DateTime.parse("$date $time");
      final DateTime now = DateTime.now();

      final Duration diff = now.difference(start);

      // Convert duration to hours (with decimals)
      return diff.inMinutes / 60.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> applyFilters(
    UserModel user, {
    String? initFromDate,
    String? initToDate,
  }) async {
    String? fromDate;
    String? toDate;

    if (selectedRange != null) {
      fromDate = fmt(selectedRange!.start);
      toDate = fmt(selectedRange!.end);
      dateRangeController.text =
          "${displayFmt(selectedRange!.start)} → ${displayFmt(selectedRange!.end)}";
    }

    await fetchDispatchedItemsList(
      user: user,
      fromDate: fromDate ?? initFromDate,
      toDate: toDate ?? initToDate,
      salesOrder: soSearchCtrl.text.trim().isNotEmpty
          ? soSearchCtrl.text.trim()
          : null,
      customerCode: itemSearchCtrl.text.trim().isNotEmpty
          ? itemSearchCtrl.text.trim()
          : null,

      customerPartDesc: itemDescSearchCtrl.text.trim().isNotEmpty
          ? itemDescSearchCtrl.text.trim()
          : null,
      status: selectedStatus != "ALL" ? selectedStatus : null,
    );
    update();
  }

  Map<String, String> getMonthDateRange(int year, String month) {
    int monthNum = monthMap[month]!;
    DateTime fromDate = DateTime(year, monthNum, 1);
    DateTime toDate = DateTime(
      year,
      monthNum + 1,
      1,
    ).subtract(const Duration(days: 1));

    return {'fromDate': _formatDate(fromDate), 'toDate': _formatDate(toDate)};
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void onSelectAll(List<VmiItems> vmiItemsList, bool value) {
    if (value) {
      for (VmiItems item in vmiItemsList) {
        final exists = cartList.any(
          (cartItem) =>
              cartItem.itemCode == item.itemCode &&
              cartItem.poNumber == item.poNumber,
        );
        if (!exists) {
          if (!isReadyToOrder(item)) {
            cartList.add(item);
          }
        }
        update();
      }
    } else {
      for (VmiItems item in vmiItemsList) {
        final exists = cartList.any(
          (cartItem) =>
              cartItem.itemCode == item.itemCode &&
              cartItem.poNumber == item.poNumber,
        );
        if (exists) {
          cartList.removeWhere(
            (cartItem) =>
                cartItem.itemCode == item.itemCode &&
                cartItem.poNumber == item.poNumber,
          );
        }
        update();
      }
    }
  }

  void onAddCart(VmiItems item) {
    final exists = cartList.any(
      (cartItem) =>
          cartItem.itemCode == item.itemCode &&
          cartItem.poNumber == item.poNumber,
    );

    if (!exists) {
      if (!isReadyToOrder(item)) {
        cartList.add(item);
      }
    } else {
      cartList.removeWhere(
        (cartItem) =>
            cartItem.itemCode == item.itemCode &&
            cartItem.poNumber == item.poNumber,
      );
    }
    update();
  }

  String fixDateIfAfterToday(String? dateStr) {
    final today = DateTime.now();
    final todayFormatted =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    if (dateStr == null || dateStr.isEmpty) {
      return todayFormatted;
    }

    DateTime date;
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      // Invalid format → also set today
      return todayFormatted;
    }

    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    // If the incoming date is after today → force today
    if (dateOnly.isAfter(todayOnly)) {
      return todayFormatted;
    }

    return dateStr;
  }

  Future<void> clearSearchReport(UserModel user) async {
    await onSearchReportItems('', user: user);
    searchController.clear();
  }

  Future<void> clearSearch(UserModel user) async {
    searchController.clear();
    await onSearchChanged('', user: user);
  }

  Future<void> onSearchChanged(String query, {UserModel? user}) async {
    await Future.delayed(Duration(milliseconds: 400), () async {
      print(query);
      await fetchItemsList(customerCode: query, user: user!);
    });
  }

  Future<void> onSearchReportItems(String query, {UserModel? user}) async {
    await Future.delayed(Duration(milliseconds: 300), () async {
      print(query);
      await fetchDispatchedItemsList(customerCode: query, user: user!);
      update();
    });
  }

  Future<void> fetchItemsList({
    String? itemCode,
    String? customerCode,
    required UserModel user,
  }) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return;
    }

    String? customer = user.customerId;
    String? company = user.company;
    vmiItems = [];
    if (customer == "" || customer == null) {
      toastMessage(message: "Customer Not Linked In Customer Master");
      update();
      return;
    }

    if (company == "" || company == null) {
      toastMessage(message: "User Not Linked With Company");
      update();
      return;
    }

    if (customer != null && company != null) {
      final apiUrl =
          "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry_new_1.get_vmi_items";
      try {
        final uri = Uri.parse(apiUrl).replace(
          queryParameters: {
            if (company != null) 'company': company,
            if (itemCode != null) 'item_code': itemCode,
            if (customerCode != null) 'customer_part_code': customerCode,
            'customer': customer,
          },
        );

        final response = await http.get(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            'Cookie': AuthService.sessionId ?? '',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> list = data['message'] ?? [];
          vmiItems = list.map((e) => VmiItems.fromJson(e)).toList();
          update();

          print("✅ SO Priority items fetched successfully");
        } else {
          print("❌ Error ${response.statusCode}: ${response.body}");
        }
      } catch (e) {
        print("⚠️ Error fetching SO Priority list: $e");
      }
    }
  }

  Future<void> fetchDispatchedItemsList({
    String? itemCode,
    String? itemName,
    String? customerCode,
    String? customerPartDesc,
    String? salesOrder,
    String? fromDate,
    String? toDate,
    String? status,
    required UserModel user,
  }) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return;
    }

    final String? customer = user.customerId;
    final String? company = user.company;
    reportList = [];
    if (customer == "" || customer == null) {
      toastMessage(message: "Customer Not Linked");
      update();
      return;
    }

    if (company == "" || company == null) {
      toastMessage(message: "Company Not Linked");
      update();
      return;
    }

    if (selectedRange != null) {
      fromDate = fmt(selectedRange!.start);
      toDate = fmt(selectedRange!.end);
    }

    final apiUrl =
        "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry_new_1.get_so_ordered";

    try {
      final Map<String, String> params = {
        'company': company,
        'customer': customer,
      };

      if (itemCode?.isNotEmpty == true) params['item_code'] = itemCode!;
      if (itemName?.isNotEmpty == true) params['item_name'] = itemName!;
      if (customerCode?.isNotEmpty == true) {
        params['customer_part_code'] = customerCode!;
      }
      if (customerPartDesc?.isNotEmpty == true) {
        params['customer_part_desc'] = customerPartDesc!;
      }
      if (salesOrder?.isNotEmpty == true) {
        params['sales_order'] = salesOrder!;
      }
      if (fromDate != null) params['from_date'] = fromDate;
      if (toDate != null) params['to_date'] = toDate;
      if (status?.isNotEmpty == true) params['status'] = status!;

      final uri = Uri.parse(apiUrl).replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'Cookie': AuthService.sessionId!,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['message'] ?? [];
        reportList = list.map((e) => ReportListModel.fromJson(e)).toList();
        print("✅ Dispatched items loaded: ${reportList.length}");
        update();
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Fetch failed: $e");
    }
  }

  Future<void> createNewSO(
    UserModel user, {
    required BuildContext context,
  }) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      toastMessage(message: "Just LogOut And LogIN");
      isSubmittingCartItems = false;
      update();
      return;
    }

    final DateTime now = DateTime.now();
    String currentDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    String currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    isSubmittingCartItems = true;
    update();

    List<VmiItems> readyToOrder = [];
    List<VmiItems> updateOnlyVmi = [];

    for (VmiItems item in cartList) {
      if (item.isBulkSubmit == 1) {
        readyToOrder.add(item);
      } else {
        int totalBins = item.totalBins == null ? 1 : item.totalBins!;
        int clearedBins = item.clearedBins == null ? 0 : item.clearedBins! + 1;
        if (totalBins <= clearedBins) {
          readyToOrder.add(item);
        } else {
          item.clearedBins = clearedBins;
          updateOnlyVmi.add(item);
        }
        print(readyToOrder);
      }
    }

    if (readyToOrder.isNotEmpty) {
      String? soName = await createSalesOrder(
        user: user,
        orderItems: readyToOrder,
      );

      if (soName != null) {
        List<Map<String, dynamic>> payload = readyToOrder
            .map(
              (e) => e.toJson(
                0,
                status: "ORDERED",
                date: currentDate,
                time: currentTime,
              ),
            )
            .toList();
        bool? value = await updateVmiItems(payload);
        if (value) {
          // toastMessage(message: "Bin Updated");

          List<String> emailsToSend = [];
          for (EmailModel email in user.emails) {
            emailsToSend.add(email.email);
          }
          isSubmittingCartItems = true;
          update();
          if (user.customerName != null) {
            bool value = await sendBulkEmail(
              message: buildEmailBody(user.customerName!, soName, readyToOrder),
              emails: emailsToSend,
              subject: "Order Confirmation – $soName Successfully Placed",
            );
            if (value) {
              isSubmittingCartItems = false;
              update();
              // toastMessage(message: "Email Sent Success");
              orderSuccessMsg(context);
            }
            // orderSuccessMsg(context);
          }
          vmiItems.clear();
          cartList.clear();
          // update();
          await fetchItemsList(user: user);
          update();
        }
        isSubmittingCartItems = false;
        update();
      } else {
        isSubmittingCartItems = false;
        update();
      }
    }
    isSubmittingCartItems = true;
    update();
    if (updateOnlyVmi.isNotEmpty) {
      List<Map<String, dynamic>> payload = updateOnlyVmi
          .map((e) => e.toJson(e.clearedBins!))
          .toList();

      bool? value = await updateVmiItems(payload);
      if (value) {
        toastMessage(message: "Bin Count Updated");
      }
      isSubmittingCartItems = false;
      update();
    }
    isSubmittingCartItems = false;
    update();
  }

  Future<bool> updateVmiItems(List<Map<String, dynamic>> items) async {
    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry_new_1.update_vmi_items",
    );

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId!, // IMPORTANT
            },
            body: jsonEncode({"items": items}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ VMI update response: $data");
        isSubmittingCartItems = false;
        update();
        return true;
      } else {
        print("❌ Update failed: ${response.statusCode}");
        print(response.body);
        isSubmittingCartItems = false;
        update();
        return false;
      }
    } catch (e) {
      print("❌ Exception while updating VMI items: $e");
      isSubmittingCartItems = false;
      update();
      return false;
    }
  }

  Future<String?> createSalesOrder({
    required UserModel user,
    required List<VmiItems> orderItems,
  }) async {
    if (AuthService.sessionId == null || cartList.isEmpty) return null;

    final response = await http.post(
      Uri.parse(
        "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry_new_1.create_sales_order",
      ),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Cookie': AuthService.sessionId!,
      },
      body: jsonEncode({
        "customer": user.customerId,
        "company": user.company,
        "po_no": orderItems[0].poNumber,
        "contact_person": orderItems[0].contactPerson,
        "selling_price_list": orderItems[0].priceList,
        "currency": orderItems[0].currency,
        "vmi_id": orderItems[0].vmiId,
        "set_warehouse": orderItems[0].customerBackUpWarehouse,
        "cart_items": orderItems
            .map(
              (e) => {
                "item_code": e.itemCode,
                "qty": e.qty,
                "uom": e.uom,
                "rate": e.rate,
                "customer_part_code": e.customerPartCode,
                "customer_part_description": e.customerPartDesc,
              },
            )
            .toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["message"]?["sales_order"];
    }
    return null;
  }

  // Future<void> updateSOItems(UserModel user, BuildContext context) async {
  //   isSubmittingCartItems = true;
  //   update();
  //   List<VmiItems> readyToOrder = [];
  //   List<VmiItems> binUpdateList = [];
  //
  //   if (AuthService.sessionId == null) {
  //     print("❌ No session found. Please login first.");
  //     isSubmittingCartItems = false;
  //     update();
  //     return;
  //   }
  //
  //   for (VmiItems item in cartList) {
  //     // item.deliveryDate = fixDateIfAfterToday(item.deliveryDate);
  //     // item.makeReadyDate = fixDateIfAfterToday(item.makeReadyDate);
  //     // item.status = "MAKE READY";
  //     if (item.isBulkSubmit == 1) {
  //       readyToOrder.add(item);
  //     } else {
  //       int totalBins = item.totalBins == null ? 1 : item.totalBins!;
  //
  //       int clearedBins = item.clearedBins == null ? 0 : item.clearedBins! + 1;
  //
  //       if (totalBins <= clearedBins) {
  //         readyToOrder.add(item);
  //       } else {
  //         item.clearedBins = clearedBins;
  //         binUpdateList.add(item);
  //       }
  //       print(readyToOrder);
  //     }
  //   }
  //
  //   if (binUpdateList.isNotEmpty) {
  //     List<Map<String, dynamic>> toUpdateBins = binUpdateList
  //         .map((e) => e.binUpdateToJson(e.clearedBins!))
  //         .toList();
  //
  //     await updateBinAssignment(toUpdateBins);
  //     isSubmittingCartItems = false;
  //     update();
  //   }
  //
  //   List<Map<String, dynamic>> clearSubmittedBins = readyToOrder
  //       .map((e) => e.binUpdateToJson(0))
  //       .toList();
  //
  //   await updateBinAssignment(clearSubmittedBins);
  //   isSubmittingCartItems = false;
  //   update();
  //
  //   if (readyToOrder.isNotEmpty) {
  //     isSubmittingCartItems = true;
  //     update();
  //     final url = Uri.parse(
  //       "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.update_so_items",
  //     );
  //
  //     final Map<String, dynamic> body = {
  //       "data": {
  //         "sales_order": readyToOrder.first.salesOrder,
  //         "items": readyToOrder.map((e) => e.toJson()).toList(),
  //       },
  //     };
  //
  //     try {
  //       final response = await http
  //           .post(
  //             url,
  //             headers: {
  //               HttpHeaders.contentTypeHeader: 'application/json',
  //               'Cookie':
  //                   AuthService.sessionId!, // 👉 SEND SESSION ID AS COOKIE
  //             },
  //             body: jsonEncode(body),
  //           )
  //           .timeout(const Duration(seconds: 30));
  //
  //       if (response.statusCode == 200) {
  //         isSubmittingCartItems = false;
  //         update();
  //         final json = jsonDecode(response.body);
  //         if (json["message"] != null) {
  //           print("✅ Updated Successfully: ${json['message']}");
  //           orderSuccessMsg(context);
  //           List<String> emailsToSend = [];
  //           for (EmailModel email in user.emails) {
  //             emailsToSend.add(email.email);
  //           }
  //
  //           if (user.customerName != null && soItemList.isNotEmpty) {
  //             bool value = await sendBulkEmail(
  //               message: buildEmailBody(
  //                 user.customerName!,
  //                 cartList[0].salesOrder!,
  //                 cartList,
  //               ),
  //               emails: emailsToSend,
  //               subject:
  //                   "Order Confirmation – ${cartList[0].salesOrder} Successfully Placed",
  //             );
  //             if (value) {
  //               toastMessage(message: "Email Sent Success");
  //             }
  //           }
  //           soItemList.clear();
  //           cartList.clear();
  //           update();
  //           await fetchItemsList(user: user);
  //           update();
  //         } else {
  //           print("⚠️ Unexpected Response: $json");
  //         }
  //       } else {
  //         print("❌ Server Error: ${response.statusCode}");
  //         print("Response: ${response.body}");
  //       }
  //     } catch (e) {
  //       print("❌ Exception in updateSOItems: $e");
  //       isSubmittingCartItems = false;
  //       update();
  //     }
  //   } else {
  //     isSubmittingCartItems = false;
  //     update();
  //     soItemList.clear();
  //     cartList.clear();
  //     update();
  //     await fetchItemsList(user: user);
  //     update();
  //   }
  //   isSubmittingCartItems = false;
  //   update();
  // }

  String buildEmailBody(
    String customerName,
    String salesOrder,
    List<VmiItems> items,
  ) {
    String tableRows = items
        .map(
          (i) =>
              """
    <tr>
      <td style="border:1px solid #ccc;padding:8px;">${i.customerPartCode}</td>
      <td style="border:1px solid #ccc;padding:8px;text-align:right;">${i.customerPartDesc}</td>
      <td style="border:1px solid #ccc;padding:8px;">${i.itemCode}</td>
      <td style="border:1px solid #ccc;padding:8px;">${i.itemName}</td>
      <td style="border:1px solid #ccc;padding:8px;">${i.qty}</td>
      <td style="border:1px solid #ccc;padding:8px;">${i.uom}</td>
      <td style="border:1px solid #ccc;padding:8px;">${i.rate}</td>
      <td style="border:1px solid #ccc;padding:8px;">${i.amount}</td>
    </tr>
  """,
        )
        .join();

    return """
  <html>
  <body style="font-family: Arial, sans-serif; line-height: 1.6;">
    <p>Dear <strong>$customerName</strong>,</p>

    <p>Your order <strong>$salesOrder</strong> has been successfully placed.</p>

    <p><strong>Items Ordered:</strong></p>

    <table style="border-collapse: collapse; width: 100%;">
      <thead>
        <tr>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">Cust Code</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">Cust Desc</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">MVD Code</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">MVD Desc</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:right;">Quantity</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">UOM</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">Price</th>
          <th style="border:1px solid #ccc;padding:8px;text-align:left;">Amount</th>
        </tr>
      </thead>
      <tbody>
        $tableRows
      </tbody>
    </table>

    <p>Thank you for choosing us.</p>

    <p>
      Warm regards,<br>
      <strong>MVD Fasteners Pvt Ltd.</strong>
    </p>
  </body>
  </html>
  """;
  }

  Future<bool> sendBulkEmail({
    required List<String> emails,
    required String subject,
    required String message,
  }) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return false;
    }

    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.send_bulk_email",
    );

    List<String> testMails = ["a.jayasuryamct2019@gmail.com"];

    final Map<String, dynamic> body = {
      "data": jsonEncode({
        "recipients": emails,
        "subject": subject,
        "message": message,
      }),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'Cookie': AuthService.sessionId!, // 👉 session-based auth
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("📧 Email Response: $res");
        return true;
      } else {
        print("❌ Failed: ${response.statusCode}");
        print(response.body);
        return false;
      }
    } catch (e) {
      print("❌ Error sending email: $e");
      return false;
    }
    return false;
  }
}
