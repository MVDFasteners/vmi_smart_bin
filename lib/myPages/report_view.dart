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

  Timer? _debounce;

  Future<void> _onLoad() async {
    vmiController.selectedYear =
        vmiController.selectedYear ?? (DateTime.now().year).toString();
    vmiController.selectedMonth =
        vmiController.selectedMonth ??
        monthMap.keys.elementAt(DateTime.now().month - 1);
    await vmiController.fetchDispatchedItemsList(user: widget.user);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dispatched Items"),
        backgroundColor: Colors.blue,
        actions: [
          InkWell(
            onTap: () async {
              await vmiController.fetchDispatchedItemsList(user: widget.user);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.refresh, color: Color(0xFF006784)),
            ),
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
                  Row(
                    children: [
                      _popUpMenuBuilderForYearlySummary(
                        controller,
                        widget.user,
                      ),
                      const SizedBox(width: 4),
                      _popUpMenuBuilderForMonthlySummary(
                        controller,
                        widget.user,
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.searchController,
                                  onChanged: (value) async {
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }
                                    _debounce = Timer(
                                      const Duration(milliseconds: 800),
                                      () async {
                                        await controller.onSearchReportItems(
                                          value,
                                          user: widget.user,
                                        );
                                      },
                                    );
                                  },
                                  textInputAction: TextInputAction.search,
                                  onFieldSubmitted: (v) async {
                                    await controller.onSearchReportItems(
                                      v,
                                      user: widget.user,
                                    );
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search item code, name...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    suffixIcon:
                                        controller.searchController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              await controller
                                                  .clearSearchReport(
                                                    widget.user,
                                                  );
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              String previousData = "";
                              String currentData = "";

                              if (index != 0) {
                                previousData =
                                    controller
                                        .reportList[index - 1]
                                        .dispatchedDate ??
                                    "";
                                currentData = item.dispatchedDate ?? "";
                              }

                              return Column(
                                children: [
                                  if (index == 0 || currentData != previousData)
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Text(
                                        item.dispatchedDate ?? "--",
                                        style: TextStyle(fontSize: 18),
                                      ),
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
                                              item.dispatchedDate ?? "--",
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
                                          "QTY: ${item.qty}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        SizedBox(height: 4),

                                        Text(
                                          "SO No: ${item.salesOrder}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),

                                        Divider(height: 20, thickness: 1),

                                        // ORDERED / PREPARED / DISPATCHED
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: const [
                                                Text(
                                                  "Ordered :",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "Prepared :",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "Dispatched :",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  item.makeReadyDate ?? "--",
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  item.preparationDate ?? "--",
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  item.dispatchedDate ?? "--",
                                                ),
                                              ],
                                            ),
                                          ],
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

  Widget _popUpMenuBuilderForMonthlySummary(
    VMIController controller,
    UserModel user,
  ) {
    String currentMonthName = monthMap.keys.elementAt(DateTime.now().month - 1);
    controller.selectedMonth ??= currentMonthName;
    return PopupMenuButton<String>(
      onSelected: (value) async {
        await controller.onSelectMonth(value, user);
      },
      itemBuilder: (BuildContext context) {
        return monthMap.keys.map((month) {
          return PopupMenuItem<String>(
            value: month,
            height: 36,
            child: MyText.bodySmall(
              month,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: 600,
            ),
          );
        }).toList();
      },
      color: theme.cardTheme.color,
      child: Container(
        decoration: boxStyle(),
        padding: MySpacing.xy(12, 4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MyText.labelMedium(
              controller.selectedMonth ?? monthMap.keys.first,
              // color: contentTheme.onBackground,
            ),
            MySpacing.width(4),
            Icon(Icons.arrow_drop_down, size: 30),
          ],
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

  Widget _popUpMenuBuilderForYearlySummary(
    VMIController controller,
    UserModel user,
  ) {
    final currentYear = DateTime.now().year;
    final startYear = 2024;

    final List<String> yearList = [
      for (int y = startYear; y <= currentYear; y++) "$y",
    ];

    controller.selectedYear ??= currentYear.toString();

    return PopupMenuButton<String>(
      onSelected: (value) async {
        await controller.onSelectYear(value, user);
      },
      itemBuilder: (BuildContext context) {
        return yearList.map((yrs) {
          return PopupMenuItem<String>(
            value: yrs,
            height: 32,
            child: MyText.bodySmall(
              yrs,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: 600,
            ),
          );
        }).toList();
      },
      color: theme.cardTheme.color,
      child: Container(
        decoration: boxStyle(),
        padding: MySpacing.xy(12, 4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MyText.labelMedium(
              controller.selectedYear ?? yearList.first,
              // color: contentTheme.onBackground,
            ),
            MySpacing.width(4),
            Icon(Icons.arrow_drop_down, size: 30),
          ],
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final VMIController controller;

  const QRScannerScreen({super.key, required this.controller});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () async {
            await controller.stop();
            if (mounted) Navigator.pop(context);
          },
        ),
        title: const Text("Scan QR Code"),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (_isProcessing) return;
              _isProcessing = true;

              controller.stop();

              var code = capture.barcodes.first.rawValue;

              if (code != null) {
                final regex = RegExp(r'BIN:\s*(.+)');
                final match = regex.firstMatch(code);

                if (match != null) {
                  String binValue = match.group(1)!.trim();

                  if (binValue.isEmpty) {
                    toastMessage(message: "NO Bin Value Found");
                    Navigator.pop(context);
                    return;
                  }

                  List<BinDetails>? binDetailList = await widget.controller
                      .fetchBinDetails(binNo: binValue);

                  Navigator.pop(context, binDetailList); // 🔥 SAFE NOW
                  return;
                }
              }

              _isProcessing = false;
            },
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF006784).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF006784), width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // instruction pill
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Position QR code within the frame",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }
}

// *********************************************************************
//                      FULL BIN MODULE PLACEHOLDER
// *********************************************************************

class FullBinModuleScreen extends StatelessWidget {
  const FullBinModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF006784),
        elevation: 0,
        title: const Text(
          "Full Bin Module",
          style: TextStyle(
            color: Color(0xFF006784),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.view_module_rounded,
              size: 72,
              color: Color(0xFF006784),
            ),
            const SizedBox(height: 12),
            const Text(
              "Full Bin workflow goes here",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back"),
            ),
          ],
        ),
      ),
    );
  }
}
