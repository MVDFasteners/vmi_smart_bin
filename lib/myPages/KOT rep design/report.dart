import 'package:flatten/myPages/KOT%20Repo/kot%20model.dart';
import 'package:flatten/myPages/KOT%20Repo/service.dart';
import 'package:flatten/myPages/KOT%20rep%20design/dashboard%20selection.dart';
import 'package:flatten/myPages/KOT%20rep%20design/filter%20bar.dart';
import 'package:flatten/myPages/KOT%20rep%20design/repo%20table.dart';
import 'package:flatten/myPages/KOT%20rep%20design/reportController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<Map<String, dynamic>> rows = List.generate(25, (i) {
    return {
      "checked": false,
      "date": "2025-11-${i + 1}",
      "rol": "YES",
      "so": "SO/MV/25-26-${13500 + i}",
      "customer": "Customer $i",
      "item": "ITEM-$i",
      "so_qty": 1000,
      "total": 12,
      "dispatched": 8,
      "available": i % 4 == 0 ? 0 : 500,
      "pending": 500,
      "uom": "Nos",
      "kot": 10,
      "platting": i % 3 == 0 ? 5 : 0,
    };
  });

  KOTReportController kotReportController = Get.put(KOTReportController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder(
          init: kotReportController,
          builder: (controller) {
            return Column(
              children: [
                FilterBar(
                  storeName: controller.storeName,
                  onStoreNameChanged: (v) async {
                    controller.storeName = v;
                    await controller.loadReport();
                    controller.update();
                  },
                  reportType: controller.reportType,
                  onReportTypeChanged: (v) async {
                    controller.reportType = v;
                    await controller.loadReport();
                    controller.update();
                  },
                  company: controller.company,
                  stockStatus: controller.stockStatus,
                  onCompanyChanged: (v) async {
                    controller.company = v;
                    await controller.loadReport();
                    controller.update();
                  },
                  onColorChange: (v) {
                    controller.stockStatus = v;
                    controller.applyFilters();
                    controller.update();
                  },
                  onItemCode: (v) {
                    print(v);
                    controller.searchItem = v;
                    controller.applyFilters();
                    controller.update();
                  },
                  onItemName: (v) {
                    controller.searchItemName = v;
                    controller.applyFilters();
                    controller.update();
                  },
                  onSo: (v) {
                    controller.searchSo = v;
                    controller.applyFilters();
                    controller.update();
                  },
                  onCustomer: (v) {
                    controller.searchCustomer = v;
                    controller.applyFilters();
                    controller.update();
                  },
                  onDeliveryDate: (v) {
                    controller.searchDeliveryDate = v;
                    controller.applyFilters();
                    controller.update();
                  },

                  widgetList: [
                    IconButton(
                      onPressed: () {
                        if (controller.showExtraFilter) {
                          controller.showExtraFilter = false;
                        } else {
                          controller.showExtraFilter = true;
                        }
                        controller.update();
                      },
                      icon: Icon(Icons.chevron_right),
                    ),
                  ],
                  controller: controller,
                ),
                DashboardSection(
                  controller: kotReportController,
                  onSubmit: () async {
                    await confirmAndSubmit(context, controller);
                  },
                ),
                Text(
                  kotReportController.storeName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                ),
                Expanded(child: ReportTable(kotReportController: controller)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> confirmAndSubmit(
    BuildContext context,
    KOTReportController controller,
  ) async {
    final selectedItems = controller.filteredSoList
        .where((e) => e.isSelected)
        .toList();

    if (selectedItems.isEmpty) {
      // optional: show toast/snackbar
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm KOT"),
          content: Text(
            "You have selected ${selectedItems.length} items.\n\nDo you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      bool val = await controller.updateKotDocType();
      if (val) {
        print("success updatedd");
      }
    }
  }
}
