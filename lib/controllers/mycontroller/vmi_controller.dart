import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/models/bin_details.dart';
import 'package:flatten/models/report_list.dart';
import 'package:flatten/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flatten/app_constant.dart';
import 'package:flatten/models/sales_order_items.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class VMIController extends GetxController {
  List<SoPriority> soItemList = [];
  List<BinDetails> binDetails = [];
  List<SoPriority> cartList = [];
  List<ReportListModel> reportList = [];
  bool selectAll = false;
  bool isSubmittingCartItems = false;
  bool reportLoading = false;
  bool itemLoading = false;
  bool onSubmitLoading = false;

  String? selectedYear;
  String? selectedMonth;

  bool isEmail = true;

  final TextEditingController searchController = TextEditingController();
  TextEditingController dateController = TextEditingController(
    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  );

  Future<void> onSelectYear(String value, UserModel user) async {
    selectedYear = value;
    Map<String, String> dateFilter = {};
    if (selectedYear != null && selectedMonth != null) {
      dateFilter = getMonthDateRange(int.parse(selectedYear!), selectedMonth!);
      print("From: ${dateFilter['fromDate']}");
      print("To: ${dateFilter['toDate']}");

      await fetchDispatchedItemsList(
        user: user,
        fromDate: dateFilter['fromDate'],
        toDate: dateFilter['toDate'],
      );
      // await onSelectStatus();
    }
    update();
  }

  Future<void> onSelectMonth(String value, UserModel user) async {
    selectedMonth = value;
    Map<String, String> dateFilter = {};
    if (selectedYear != null && selectedMonth != null) {
      dateFilter = getMonthDateRange(int.parse(selectedYear!), selectedMonth!);
      print("From: ${dateFilter['fromDate']}");
      print("To: ${dateFilter['toDate']}");
    }
    await fetchDispatchedItemsList(
      user: user,
      fromDate: dateFilter['fromDate'],
      toDate: dateFilter['toDate'],
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

  void onSelectAll(List<SoPriority> soItemList, bool value) {
    if (value) {
      for (SoPriority item in soItemList) {
        final exists = cartList.any(
          (cartItem) =>
              cartItem.itemCode == item.itemCode &&
              cartItem.salesOrder == item.salesOrder,
        );
        if (!exists) {
          if (item.status == "NOT YET USED") {
            cartList.add(item);
          }
        }
        update();
      }
    } else {
      for (SoPriority item in soItemList) {
        final exists = cartList.any(
          (cartItem) =>
              cartItem.itemCode == item.itemCode &&
              cartItem.salesOrder == item.salesOrder,
        );
        if (exists) {
          cartList.removeWhere(
            (cartItem) =>
                cartItem.itemCode == item.itemCode &&
                cartItem.salesOrder == item.salesOrder,
          );
        }
        update();
      }
    }
  }

  void onAddCart(SoPriority item) {
    final exists = cartList.any(
      (cartItem) =>
          cartItem.itemCode == item.itemCode &&
          cartItem.salesOrder == item.salesOrder,
    );

    if (!exists) {
      if (item.status == "NOT YET USED") {
        cartList.add(item);
      }
    } else {
      cartList.removeWhere(
        (cartItem) =>
            cartItem.itemCode == item.itemCode &&
            cartItem.salesOrder == item.salesOrder,
      );
    }
    update();
  }

  String fixDateIfAfterToday(String? dateStr) {
    final today = DateTime.now();
    final todayFormatted =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    // If null or empty → set today
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
    await Future.delayed(Duration(milliseconds: 400), () async {
      print(query);
      await fetchDispatchedItemsList(customerCode: query, user: user!);
    });
  }

  Future<Uint8List?> fetchInvoicePdf({required String invoiceId}) async {
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return null;
    }

    // Ensure this URL is correct for your custom method path
    final apiUrl =
        "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.get_sales_invoice_pdf";

    try {
      final uri = Uri.parse(apiUrl);

      final response = await http.post(
        uri,
        headers: {
          // Frappe accepts JSON body for POST requests
          HttpHeaders.contentTypeHeader: 'application/json',
          // Send the session cookie for authentication
          'Cookie': AuthService.sessionId ?? '',
        },
        body: jsonEncode({
          // CRITICAL: The parameter name MUST match the Python function argument
          "sales_invoice_id": invoiceId,
        }),
      );

      if (response.statusCode == 200) {
        // SUCCESS: The server is sending the raw PDF binary data in the body.
        print("✅ Successfully fetched PDF binary data.");
        return response.bodyBytes;
      } else {
        // Handle server-side errors (like "not found" or internal errors)
        String errorBody = response.body;
        try {
          // Attempt to extract the friendly error message from the JSON response
          final jsonError = jsonDecode(response.body);
          errorBody = jsonError["_server_messages"] ?? response.body;
        } catch (_) {
          // If not JSON, use raw body
        }
        print("❌ Error ${response.statusCode}: $errorBody");
        return null;
      }
    } catch (e) {
      print("⚠️ Network or general error fetching invoice PDF: $e");
      return null;
    }
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

    if (customer != null && company != null) {
      soItemList = [];
      final apiUrl =
          "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.get_so_priority";
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
          soItemList = list.map((e) => SoPriority.fromJson(e)).toList();
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

  void updateLoadingReport(bool value) {
    reportLoading = value;
    update();
  }

  Future<void> fetchDispatchedItemsList({
    String? itemCode,
    String? customerCode,
    String? fromDate,
    String? toDate,
    required UserModel user,
  }) async {
    // reportLoading = true;
    // update();
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      // updateLoadingReport(false);
      // reportLoading = false;
      // update();
      return;
    }

    if (fromDate == null || toDate == null) {
      Map<String, String> dateFilter = {};
      if (selectedYear != null && selectedMonth != null) {
        dateFilter = getMonthDateRange(
          int.parse(selectedYear!),
          selectedMonth!,
        );
        print("From: ${dateFilter['fromDate']}");
        print("To: ${dateFilter['toDate']}");
      }
      fromDate = dateFilter['fromDate'];
      toDate = dateFilter['toDate'];
    }

    String? customer = user.customerId;
    String? company = user.company;

    if (customer != null && company != null) {
      reportList = [];
      final apiUrl =
          "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.get_so_dispatched";

      try {
        final uri = Uri.parse(apiUrl).replace(
          queryParameters: {
            'company': company,
            if (itemCode != null) 'item_code': itemCode,
            if (customerCode != null) 'customer_part_code': customerCode,
            if (fromDate != null) 'from_date': fromDate,
            if (toDate != null) 'to_date': toDate,
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

          reportList = list.map((e) => ReportListModel.fromJson(e)).toList();
          // reportLoading = false;
          // update();
          print("✅ Dispatched items loaded successfully");
        } else {
          // reportLoading = false;
          // update();
          print("❌ Error ${response.statusCode}: ${response.body}");
        }
      } catch (e) {
        // reportLoading = false;
        // update();
        print("⚠️ Error fetching dispatched list: $e");
      }
    }
    // reportLoading = false;
    // update();
  }

  Future<List<BinDetails>?> fetchBinDetails({
    String? binNo,
    String? itemCode,
    String? customerCode,
  }) async {
    binDetails = [];
    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      return null;
    }

    final apiUrl =
        "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.get_bin_items";
    try {
      final uri = Uri.parse(apiUrl).replace(
        queryParameters: {
          if (binNo != null) 'bin_no': binNo,
          if (itemCode != null) 'item_code': itemCode,
          if (customerCode != null) 'customer_part_code': customerCode,
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
        binDetails = list.map((e) => BinDetails.fromJson(e)).toList();
        update();
        print("✅fetched successfully");
        return binDetails;
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error fetching : $e");
    }
  }

  Future<void> updateSOItems(UserModel user, BuildContext context) async {
    isSubmittingCartItems = true;
    update();
    List<SoPriority> readyToOrder = [];
    List<SoPriority> binUpdateList = [];

    if (AuthService.sessionId == null) {
      print("❌ No session found. Please login first.");
      isSubmittingCartItems = false;
      update();
      return;
    }

    for (SoPriority item in cartList) {
      item.deliveryDate = fixDateIfAfterToday(item.deliveryDate);
      item.makeReadyDate = fixDateIfAfterToday(item.makeReadyDate);
      item.status = "MAKE READY";

      if (item.isBulkSubmit == 1) {
        readyToOrder.add(item);
      } else {
        int totalBins = int.parse(
          item.totalBins == "" || item.totalBins == null
              ? "1"
              : item.totalBins!,
        );
        int clearedBins =
            int.parse(
              item.clearedBins == "" || item.clearedBins == null
                  ? "0"
                  : item.clearedBins!,
            ) +
            1;

        if (totalBins <= clearedBins) {
          readyToOrder.add(item);
        } else {
          item.clearedBins = clearedBins.toString();
          binUpdateList.add(item);
        }

        print(readyToOrder);
      }
    }

    if (binUpdateList.isNotEmpty) {
      List<Map<String, dynamic>> toUpdateBins = binUpdateList
          .map((e) => e.binUpdateToJson(int.parse(e.clearedBins!)))
          .toList();

      await updateBinAssignment(toUpdateBins);
      isSubmittingCartItems = false;
      update();
    }

    List<Map<String, dynamic>> clearSubmittedBins = readyToOrder
        .map((e) => e.binUpdateToJson(0))
        .toList();

    await updateBinAssignment(clearSubmittedBins);
    isSubmittingCartItems = false;
    update();

    if (readyToOrder.isNotEmpty) {
      isSubmittingCartItems = true;
      update();
      final url = Uri.parse(
        "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.update_so_items",
      );

      final Map<String, dynamic> body = {
        "data": {
          "sales_order": readyToOrder.first.salesOrder,
          "items": readyToOrder.map((e) => e.toJson()).toList(),
        },
      };

      try {
        final response = await http
            .post(
              url,
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                'Cookie':
                    AuthService.sessionId!, // 👉 SEND SESSION ID AS COOKIE
              },
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          isSubmittingCartItems = false;
          update();
          final json = jsonDecode(response.body);
          if (json["message"] != null) {
            print("✅ Updated Successfully: ${json['message']}");
            orderSuccessMsg(context);
            // List<String> emailsToSend = [];
            // for (EmailModel email in user.emails) {
            //   emailsToSend.add(email.email);
            // }
            //
            // if (user.customerName != null && soItemList.isNotEmpty) {
            //   bool value = await sendBulkEmail(
            //     message: buildEmailBody(
            //       user.customerName!,
            //       cartList[0].salesOrder!,
            //       cartList,
            //     ),
            //     emails: emailsToSend,
            //     subject:
            //         "Order Confirmation – ${cartList[0].salesOrder} Successfully Placed",
            //   );
            //   if (value) {
            //     toastMessage(message: "Email Sent Success");
            //
            //   }
            // }
            soItemList.clear();
            cartList.clear();
            update();
            await fetchItemsList(user: user);
            update();
          } else {
            print("⚠️ Unexpected Response: $json");
          }
        } else {
          print("❌ Server Error: ${response.statusCode}");
          print("Response: ${response.body}");
        }
      } catch (e) {
        print("❌ Exception in updateSOItems: $e");
        isSubmittingCartItems = false;
        update();
      }
    } else {
      isSubmittingCartItems = false;
      update();
      soItemList.clear();
      cartList.clear();
      update();
      await fetchItemsList(user: user);
      update();
    }
    isSubmittingCartItems = false;
    update();
  }

  Future<bool> updateBinAssignment(
    List<Map<String, dynamic>> binUpdateList,
  ) async {
    if (AuthService.sessionId == null) {
      print("❌ No session session found.");
      return false;
    }

    final url = Uri.parse(
      "$baseUrl/api/method/my_api_app.api_methods.vendor_managed_inventry.update_bin_item_assignment",
    );

    final body = {
      "data": {"records": binUpdateList},
    };

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
              "Cookie": AuthService.sessionId!,
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);

        if (res["message"]?["status"] == "success") {
          print("✅ Updated: ${res['message']['updated_rows']}");
          toastMessage(message: "Bin Updated Successfully");
          return true;
        } else {
          print("⚠ Response: $res");
          return false;
        }
      } else {
        print("❌ Server Error: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("❌ ERROR updateBinAssignment: $e");
    }
    return false;
  }

  String buildEmailBody(
    String customerName,
    String salesOrder,
    List<SoPriority> items,
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
