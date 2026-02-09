import 'dart:convert';
import 'dart:math';

import 'package:flatten/app_constant.dart';
import 'package:flatten/helpers/services/auth_service.dart';
import 'package:flatten/myPages/KOT%20Repo/kot%20model.dart';
import 'package:flatten/myPages/KOT%20Repo/service.dart';
import 'package:flatten/myPages/KOT%20Repo/soPendingReport.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class KOTReportController extends GetxController {
  List<PendingSoItem> masterSoList = [];
  List<PendingKotItem> kotItemsList = [];
  List<PendingSoItem> reducedSoList = [];
  List<PendingSoItem> filteredSoList = [];
  List<BatchStock> stockBatchList = [];

  int binsToFillCount = 0;
  bool isDarkColor = false;

  bool isAllSelected = false;
  bool isLoading = false;
  bool showExtraFilter = false;

  String company = "MVD FASTENERS PRIVATE LIMITED";
  String warehouse = "All Warehouses - MVDF";
  String stockStatus = "ALL";
  String reportType = "Normal";
  String storeName = "KRISHNA";

  String searchItem = "";
  String searchItemName = "";
  String searchSo = "";
  String searchCustomer = "";
  String searchDeliveryDate = "";

  double totalStockValue = 0;
  double totalBilledValue = 0;
  double todayBilledValue = 0;

  int pendingItems = 0;
  int soPending = 0;
  int customers = 0;

  int red = 0;
  int orange = 0;
  int green = 0;
  int blue = 0;

  int get selectedRows => filteredSoList.where((e) => e.isSelected).length;

  TextEditingController soTextEditCtrl = TextEditingController();
  TextEditingController noOfBoxesCtrl = TextEditingController();

  PendingSoItem? lastSelectedItem() {
    return filteredSoList.where((e) => e.isSelected).lastOrNull; // Dart 3+
  }

  void toggleSelection(PendingSoItem item, context) {
    if (item.isSelected) {
      item.isSelected = false;
      update();
      return;
    }

    if (selectedRows >= 100) {
      showCustomToast("Limit Reached, You can select only 10 items", context);
      return;
    }
    // print({
    //   "box: ${item.noOfBox}, pac: ${item.packetQty}, boxqty ${item.boxQty}",
    // });

    // ✅ allowed selection rules
    if (item.colorCode == 1 || item.colorCode == 2) {
      if (reportType == "Normal") {
        if (item.enteredBoxQty != 0 && item.enteredPacketQty != 0) {
          if (selectedRows <= 0) {
            searchSo = item.salesOrder!;
            soTextEditCtrl.text = searchSo;
            applyFilters();
          }

          PendingSoItem? itm = lastSelectedItem();
          if (itm != null) {
            if (itm.salesOrder! == item.salesOrder) {
              item.isSelected = true;
            }
          } else {
            item.isSelected = true;
          }
        }
      } else if (reportType == "Bin Based") {
        if (item.colorCode == 1) {
          item.isSelected = true;
        }
      } else {
        if (item.customerBackupWarehouse != null &&
            item.customerBackupWarehouse != "") {
          item.isSelected = true;
        } else {
          showCustomToast("Backup Warehouse Not Added", context);
        }
      }
    } else {
      showCustomToast("Fill All Fields to Select", context);
    }

    update();
  }

  void toggleSelectAll(bool value) {
    if (!value) {
      // deselect all
      for (var item in filteredSoList) {
        item.isSelected = false;
      }
      isAllSelected = false;
      update();

      return;
    }

    if (searchSo != "" && searchSo != null) {
      int count = selectedRows;

      for (var item in filteredSoList) {
        if (count >= 100) break;

        if (reportType == "Normal") {
          if (item.enteredBoxQty != 0 &&
              // item.enteredNoOfBoxQty != 0 &&
              item.enteredPacketQty != 0) {
            if ((item.colorCode == 1 || item.colorCode == 2) &&
                !item.isSelected) {
              item.isSelected = true;
              count++;
            }
          }
        } else if (reportType == "Bin Based") {
          if (item.colorCode == 1 && !item.isSelected) {
            item.isSelected = true;
            count++;
          }
        } else {
          if (item.customerBackupWarehouse != null &&
              item.customerBackupWarehouse != "") {
            item.isSelected = true;
            count++;
          }
        }
      }

      if (count >= 10) {
        Get.snackbar(
          "Limit Reached",
          "Maximum 10 items can be selected",
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      isAllSelected = count <= 10;
      update();
    }
  }

  Future<bool> updateKotDocType() async {
    final selectedItems = filteredSoList
        .where((e) => e.isSelected == true)
        .toList();

    isLoading = true;
    update();
    String? stkId;
    if (reportType == "Bin Based") {
      stkId = await Service().autoMultiItemStockTransferBinBased(
        company: company,
        targetWarehouse: getTargetWarehouse(),
        items: selectedItems,
      );
    } else if (reportType == "Normal") {
      stkId = await Service().autoMultiItemStockTransfer(
        sourceParentWarehouse: company == "MVD FASTENERS PRIVATE LIMITED"
            ? "Warehouse - MVDF"
            : "All Warehouses - MFPL",
        company: company,
        targetWarehouse: getTargetWarehouse(),
        items: selectedItems,
      );
    } else {
      stkId = await Service().autoMultiItemStockTransferBinsToFill(
        sourceParentWarehouse: company == "MVD FASTENERS PRIVATE LIMITED"
            ? "Warehouse - MVDF"
            : "All Warehouses - MFPL",
        company: company,
        items: selectedItems,
      );
    }

    if (stkId != null) {
      int boxes = int.parse(noOfBoxesCtrl.text);
      double dividedBoxes = boxes / selectedItems.length;
      bool val = await Service().upsertKotReport(
        selectedItems,
        stkId,
        dividedBoxes,
      );
      await loadReport();
      isLoading = false;
      update();
      return val;
    } else {
      isLoading = false;
      update();
      return false;
    }
  }

  String getTargetWarehouse() {
    String targetWarehouse = "";
    if (storeName == "GANGA") {
      company == "MVD FASTENERS PRIVATE LIMITED"
          ? targetWarehouse = "GANGA - MVDF"
          : targetWarehouse = "GANGA - MFPL";
    } else if (storeName == "YAMUNA") {
      company == "MVD FASTENERS PRIVATE LIMITED"
          ? targetWarehouse = "YAMUNA - MVDF"
          : targetWarehouse = "YAMUNA - MFPL";
    } else if (storeName == "GODAVARI") {
      company == "MVD FASTENERS PRIVATE LIMITED"
          ? targetWarehouse = "GODAVARI - MVDF"
          : targetWarehouse = "GODAVARI - MFPL";
    } else if (storeName == "KAVERI") {
      company == "MVD FASTENERS PRIVATE LIMITED"
          ? targetWarehouse = "KAVERI - MVDF"
          : targetWarehouse = "KAVARI - MFPL";
    } else if (storeName == "KRISHNA") {
      company == "MVD FASTENERS PRIVATE LIMITED"
          ? targetWarehouse = "KRISHNA - MVDF"
          : targetWarehouse = "KRISHNA - MFPL";
    }
    return targetWarehouse;
  }

  Future<void> loadReport() async {
    isLoading = true;
    update();
    if (reportType == "Normal") {
      await loadReportNormal();
      totalStockValue = await Service().getTotalStockValue(
        company: company,
        storeName: storeName,
      );
      totalBilledValue = await Service().getMonthlyBilledValue(
        company: company,
        storeName: storeName,
      );
      todayBilledValue = await Service().getTodayBilledValue(
        company: company,
        storeName: storeName,
      );
      isLoading = false;
      String excludeWarehouse = "";
      String parentWarehouse = "";
      excludeWarehouse = company == "MVD FASTENERS 1"
          ? "Picking - MFPL"
          : "Picking - MVDF";
      parentWarehouse = company == "MVD FASTENERS 1"
          ? "All Warehouses - MFPL"
          : "All Warehouses - MVDF";

      List<PendingSoItem> items = await Service().getBinToFillItems(
        company: company,
        excludeWarehouse: excludeWarehouse,
        parentWarehouse: parentWarehouse,
        storeName: storeName,
      );
      binsToFillCount = items.length;
      update();
    } else if (reportType == "Bin Based") {
      await loadReportBinBased();
      isLoading = false;
      update();
    } else {
      await loadBinsToFillItems();
      isLoading = false;
      update();
    }
  }

  Future<void> loadReportNormal() async {
    masterSoList = [];
    kotItemsList = [];
    reducedSoList = [];
    filteredSoList = [];

    String plattingWarehouse = "Non Moving Warehouse - MVDF";
    String? filterGroupWarehouse;
    String? pickingWarehouse = "Picking - MVDF";
    String? soiWarehouseGroup = "Picking - MVDF";

    if (company == "MVD FASTENERS PRIVATE LIMITED") {
      filterGroupWarehouse = "All Warehouses - MVDF";
      plattingWarehouse = "Non Moving Warehouse - MVDF";
      pickingWarehouse = "Picking - MVDF";
      soiWarehouseGroup = "Picking - MVDF";
    } else {
      filterGroupWarehouse = "ALL Warehouses - MFPL";
      plattingWarehouse = "Non Moving Warehouse - MFPL";
      pickingWarehouse = "Picking - MFPL";
      soiWarehouseGroup = "Picking - MFPL";
    }

    List<PendingSoItem> items = await Service().getPendingSoItems(
      company: company,
      storeName: storeName,
      groupWarehouse: filterGroupWarehouse,
      platingWarehouse: plattingWarehouse,
      pickingWarehouse: pickingWarehouse,
      soiWarehouseGroup: soiWarehouseGroup,
    );

    masterSoList = items;
    buildReducedList();
    applyFilters();
    update();
  }

  Future<void> loadBinsToFillItems() async {
    masterSoList = [];
    kotItemsList = [];
    reducedSoList = [];
    filteredSoList = [];

    String excludeWarehouse = "";
    String parentWarehouse = "";
    excludeWarehouse = company == "MVD FASTENERS 1"
        ? "Picking - MFPL"
        : "Picking - MVDF";
    parentWarehouse = company == "MVD FASTENERS 1"
        ? "All Warehouses - MFPL"
        : "All Warehouses - MVDF";
    List<PendingSoItem> items = await Service().getBinToFillItems(
      company: company,
      excludeWarehouse: excludeWarehouse,
      parentWarehouse: parentWarehouse,
      storeName: storeName,
    );
    binsToFillCount = items.length;
    masterSoList = items;

    buildReducedList();
    // filteredSoList = reducedSoList;
    applyFilters();
    update();
  }

  Future<void> loadReportBinBased() async {
    masterSoList = [];
    kotItemsList = [];
    reducedSoList = [];
    filteredSoList = [];

    String plattingWarehouse = "Non Moving Warehouse - MVDF";
    if (company == "MVD FASTENERS PRIVATE LIMITED") {
      plattingWarehouse = "Non Moving Warehouse - MVDF";
    } else {
      plattingWarehouse = "Non Moving Warehouse - MFPL";
    }

    List<PendingSoItem> items = await Service().getPendingSoItemsBinBased(
      company: company,
      storeName: storeName,
      platingWarehouse: plattingWarehouse,
    );
    masterSoList = items;
    buildReducedListBinBased();
    applyFilters();
    update();
  }

  void buildReducedListBinBased() {
    // 🔹 Reset counters
    red = 0;
    orange = 0;
    green = 0;
    blue = 0;

    soPending = 0;
    customers = 0;

    final Set<String> uniqueSalesOrders = {};
    final Set<String> uniqueCustomers = {};

    // 🔹 Running stock per (item + customer)
    final Map<String, double> runningStock = {};

    reducedSoList = masterSoList.map((item) {
      final String itemCode = item.itemCode!;
      final String customer = item.customer!;

      // 🔹 Composite key (bin-based isolation)
      final String stockKey = "$itemCode|$customer";

      // 🔹 Resolve conversion factor
      final double convFactor =
          (item.conversionFactor == null || item.conversionFactor == 0)
          ? 1
          : item.conversionFactor!;

      final double basePending = (item.pendingQty ?? 0) * convFactor;
      final double baseSoQty = (item.soQty ?? 0) * convFactor;

      // 🔹 Initialize stock ONCE per (item + customer)
      runningStock[stockKey] ??= item.availableStock!.clamp(0, double.infinity);

      final double currentStock = runningStock[stockKey]!;

      // 🔹 Stock shown for this row
      final double rowStock = currentStock;

      // 🔹 Reduce stock ONLY using basePending
      runningStock[stockKey] = (currentStock - basePending).clamp(
        0,
        double.infinity,
      );

      // 🔹 COLOR LOGIC WITH PRIORITY OVERRIDE
      int colorCode;

      // 🚨 Highest priority: fresh picked → RED
      if ((item.freshPickedQty ?? 0) > 0) {
        colorCode = 0;
      } else {
        colorCode = calculateColorCode(
          availableStock: rowStock,
          pendingQty: basePending,
          plattingStock: item.plattingStockQty ?? 0,
        );
      }

      // 🔹 Count colors
      switch (colorCode) {
        case 0:
          red++;
          break;
        case 1:
          green++;
          break;
        case 2:
          orange++;
          break;
        case 3:
          blue++;
          break;
      }

      // 🔹 Track unique SO & Customers
      uniqueSalesOrders.add(item.salesOrder!);
      uniqueCustomers.add(item.customer!);

      return item.copyWith(
        availableStock: rowStock,
        colorCode: colorCode,
        basePending: basePending,
        baseSoQty: baseSoQty,
      );
    }).toList();

    // 🔹 Final summary counts
    soPending = uniqueSalesOrders.length;
    customers = uniqueCustomers.length;
  }

  void buildReducedList() {
    red = 0;
    orange = 0;
    green = 0;
    blue = 0;

    soPending = 0;
    customers = 0;

    final Set<String> uniqueSalesOrders = {};
    final Set<String> uniqueCustomers = {};

    final Map<String, double> runningStock = {};

    reducedSoList = masterSoList.map((item) {
      final String itemCode = item.itemCode!;

      final double convFactor =
          (item.conversionFactor == null || item.conversionFactor == 0)
          ? 1
          : item.conversionFactor!;

      final double basePending = (item.pendingQty ?? 0) * convFactor;
      final double baseSoQty = (item.soQty ?? 0) * convFactor;
      print("basePending$basePending");

      runningStock[itemCode] ??= item.availableStock!.clamp(0, double.infinity);

      final double currentStock = runningStock[itemCode]!;

      final double rowStock = currentStock;

      runningStock[itemCode] = (currentStock - basePending).clamp(
        0,
        double.infinity,
      );
      print("runningStock${runningStock[itemCode]}");
      print("currentStock$currentStock");

      int colorCode;
      if ((item.freshPickedQty ?? 0) > 0) {
        colorCode = 0;
      } else {
        colorCode = calculateColorCode(
          availableStock: rowStock,
          pendingQty: basePending,
          plattingStock: item.plattingStockQty ?? 0,
        );
      }

      switch (colorCode) {
        case 0:
          red++;
          break;
        case 1:
          green++;
          break;
        case 2:
          orange++;
          break;
        case 3:
          blue++;
          break;
      }

      uniqueSalesOrders.add(item.salesOrder!);
      uniqueCustomers.add(item.customer!);

      return item.copyWith(
        availableStock: rowStock,
        colorCode: colorCode,
        basePending: basePending,
        baseSoQty: baseSoQty,
      );
    }).toList();

    soPending = uniqueSalesOrders.length;
    customers = uniqueCustomers.length;
  }

  void applyFilters() {
    filteredSoList = reducedSoList.where((item) {
      // 🔹 Item code filter
      if (searchItem.isNotEmpty &&
          !item.itemCode!.toLowerCase().contains(searchItem.toLowerCase())) {
        return false;
      }

      // 🔹 Item name filter
      if (searchItemName.isNotEmpty &&
          !item.itemName!.toLowerCase().contains(
            searchItemName.toLowerCase(),
          )) {
        return false;
      }

      // 🔹 Sales Order filter
      if (searchSo.isNotEmpty &&
          !item.salesOrder!.toLowerCase().contains(searchSo.toLowerCase())) {
        return false;
      }

      // 🔹 Customer filter
      if (searchCustomer.isNotEmpty &&
          !item.customerName!.toLowerCase().contains(
            searchCustomer.toLowerCase(),
          )) {
        return false;
      }

      if (searchDeliveryDate.isNotEmpty &&
          !item.deliveryDate!.toLowerCase().contains(
            searchDeliveryDate.toLowerCase(),
          )) {
        return false;
      }

      if (stockStatus != "ALL") {
        final int? code = item.colorCode;

        switch (stockStatus) {
          case "GREEN":
            if (code != 1) return false;
            break;

          case "RED":
            if (code != 0) return false;
            break;

          case "YELLOW": // ORANGE
            if (code != 2) return false;
            break;

          case "BLUE":
            if (code != 3) return false;
            break;
        }
      }
      return true;
    }).toList();
  }

  int calculateColorCode({
    required double availableStock,
    required double pendingQty,
    required double plattingStock,
  }) {
    if (availableStock == 0 && plattingStock == 0) {
      return 0; // 🔴 Red
    }

    if (availableStock == 0 && plattingStock > 0) {
      return 3; // 🔵 Blue
    }

    if (availableStock > 0 && availableStock < pendingQty) {
      return 2; // 🟠 Orange
    }

    if (availableStock >= pendingQty) {
      return 1;
    }

    return 0;
  }

  Future<List<BatchStock>> viewItemStock(String itemCode) async {
    List<BatchStock> batchList = await Service().fetchBatchStock(
      itemCode: itemCode,
      warehouse: "All Warehouses - MVDF",
    );
    stockBatchList = batchList;
    update();
    return batchList;
  }
}
