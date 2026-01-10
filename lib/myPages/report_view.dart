import 'dart:async';
import 'dart:typed_data';

import 'package:flatten/app_constant.dart';
import 'package:flatten/controllers/auth/login_controller.dart';
import 'package:flatten/controllers/mycontroller/vmi_controller.dart';
import 'package:flatten/helpers/theme/app_style.dart';
import 'package:flatten/helpers/widgets/my_container.dart';
import 'package:flatten/helpers/widgets/my_spacing.dart';
import 'package:flatten/helpers/widgets/my_text.dart';
import 'package:flatten/models/bin_details.dart';
import 'package:flatten/models/user.dart';
import 'package:flatten/myPages/customerCart.dart';
import 'package:flatten/myPages/invoice_pdf.dart';
import 'package:flatten/myPages/login_new_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ReportViewScreen extends StatefulWidget {
  final UserModel user;

  const ReportViewScreen({super.key, required this.user});

  @override
  State<ReportViewScreen> createState() => _ReportViewScreenState();
}

class _ReportViewScreenState extends State<ReportViewScreen>
    with SingleTickerProviderStateMixin {
  VMIController vmiController = Get.put(VMIController());
  LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  Future<void> _onLoad() async {
    final DateTime now = DateTime.now();

    final DateTime from = DateTime(now.year, now.month, 1);
    final DateTime to = DateTime(now.year, now.month, now.day);

    vmiController.selectedRange = DateTimeRange(start: from, end: to);

    vmiController.dateRangeController.text =
        "${vmiController.displayFmt(from)} → ${vmiController.displayFmt(to)}";

    await vmiController.fetchDispatchedItemsList(
      user: widget.user,
      fromDate: _apiFmt(from),
      toDate: _apiFmt(to),
      status: "ALL",
    );
    vmiController.update();
  }

  String _apiFmt(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder(
          init: vmiController,
          builder: (controller) {
            return Row(
              children: [
                Text("Report"),
                SizedBox(width: 3),
                Text(
                  " / ${vmiController.dateRangeController.text}",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.blue,
        actions: [
          InkWell(
            onTap: () async {
              await _onLoad();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          GetBuilder(
            init: vmiController,
            builder: (controller) {
              return InkWell(
                onTap: () => _openFilterSheet(context, controller),
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.filter_alt_sharp, color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder(
        init: vmiController,
        builder: (controller) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F4F8), Color(0xFFB5DDF0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: controller.reportList.isEmpty
                        ? Center(
                            child: Text(
                              "No Data",
                              style: TextStyle(fontSize: 24),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: controller.reportList.length,
                            itemBuilder: (context, index) {
                              final item = controller.reportList[index];
                              String previousSO = "";
                              String currentSO = "";
                              double orderedQty = item.qty ?? 0;
                              double deliveredQty = item.deliveredQty ?? 0;
                              String status = "PENDING";

                              if (orderedQty <= deliveredQty) {
                                status = "DELIVERED";
                              }

                              if (index != 0) {
                                previousSO =
                                    controller
                                        .reportList[index - 1]
                                        .salesOrder ??
                                    "";
                                currentSO = item.salesOrder ?? "";
                              }

                              return Column(
                                children: [
                                  if (index == 0 || currentSO != previousSO)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            item.salesOrder ?? "--",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            item.soDate ?? "--",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ],
                                    ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: 220,
                                              child: Text(
                                                item.customerPartCode ??
                                                    item.itemCode ??
                                                    "--",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          width: 220,
                                          child: Text(
                                            item.customerPartDesc ??
                                                item.itemName ??
                                                "--",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "QTY: ${(item.qty ?? 0)}  ${item.uom}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Delivered Qty: ${(item.deliveredQty ?? 0)} ${item.uom}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFilterSheet(BuildContext context, VMIController controller) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 Title
                const Center(
                  child: Text(
                    "Filter Dispatched Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _dateRangeField(context, controller),
                _textField("Sales Order", controller.soSearchCtrl),
                const SizedBox(height: 12),
                _textField("Item Code", controller.itemSearchCtrl),
                _textField("Item Description", controller.itemDescSearchCtrl),
                const SizedBox(height: 20),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white, // ⭐ dropdown list background
                  ),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Status",
                      border: OutlineInputBorder(),
                    ),
                    items: controller.statusList
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => controller.selectedStatus = v!,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          controller.dateRangeController.clear();
                          controller.selectedRange = null;
                          controller.soSearchCtrl.clear();
                          controller.itemSearchCtrl.clear();
                          controller.itemDescSearchCtrl.clear();
                          controller.selectedStatus = "ALL";
                          await _onLoad();
                          Navigator.pop(context);
                        },
                        child: const Text("Clear"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.applyFilters(widget.user);
                          Navigator.pop(context);
                        },
                        child: const Text("Apply"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dateRangeField(BuildContext context, VMIController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller.dateRangeController,
        readOnly: true,
        onTap: () async {
          DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDateRange: controller.selectedRange,
            helpText: "Select Date Range",
          );

          if (picked != null) {
            controller.selectedRange = picked;
            controller.dateRangeController.text =
                "${controller.fmt(picked.start)}  →  ${controller.fmt(picked.end)}";
          }
        },
        decoration: const InputDecoration(
          labelText: "From Date - To Date",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.date_range),
        ),
      ),
    );
  }

  BoxDecoration boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}
