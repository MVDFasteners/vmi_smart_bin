import 'dart:async';

import 'package:flatten/app_constant.dart';
import 'package:flatten/controllers/auth/login_controller.dart';
import 'package:flatten/controllers/mycontroller/vmi_controller.dart';
import 'package:flatten/models/bin_details.dart';
import 'package:flatten/models/user.dart';
import 'package:flatten/myPages/customerCart.dart';
import 'package:flatten/myPages/login_new_screen.dart';
import 'package:flatten/myPages/report_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  final Set<int> selectedRows = {};

  VMIController vmiController = Get.put(VMIController());
  LoginController loginController = Get.put(LoginController());
  UserModel? user;
  Timer? _debounce;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  Future<void> _onLoad() async {
    user = await loginController.fetchUser();
    if (user != null) {
      await vmiController.fetchItemsList(user: user!);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: user != null ? ReportViewScreen(user: user!) : null,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF57C3FF),
        titleSpacing: 0,
        title: InkWell(
          onTap: () async {
            if (user != null) {
              await _showProfile(context, user!);
            }
          },
          child: Text(
            user?.fullName ?? "",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              if (user != null) {
                await vmiController.fetchItemsList(user: user!);
              }
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.refresh, color: Color(0xFF006784)),
            ),
          ),
          GetBuilder(
            init: vmiController,
            builder: (controller) {
              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CustomerCartView(user: user ?? UserModel()),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 45,
                    ),
                    Positioned(
                      right: -3,
                      top: -10,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            controller.cartList.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          List<BinDetails>? value = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QRScannerScreen(controller: vmiController),
            ),
          );
          if (value != null &&
              value.isNotEmpty &&
              value[0].customerPartCode != null) {
            vmiController.searchController.text = value[0].customerPartCode!;
            await vmiController.onSearchChanged(
              vmiController.searchController.text,
              user: user,
            );
          }
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,

          width: _pressed ? 68 : 78,
          height: _pressed ? 68 : 78,

          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00E0FF), Color(0xFF007AFF), Color(0xFF00FFCB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.6),
                blurRadius: 25,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 12,
              ),
            ],
          ),

          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: _pressed ? 0.90 : 1.00,

            child: const Icon(
              Icons.qr_code_scanner,
              size: 36,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: GetBuilder(
        init: vmiController,
        builder: (controller) {
          return SafeArea(
            bottom: true,
            top: true,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF57C3FF), Color(0xFF82D9FF)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: controller.selectAll,
                          onChanged: (v) {
                            if (controller.selectAll) {
                              controller.selectAll = false;
                            } else {
                              controller.selectAll = true;
                            }
                            // controller.update();
                            controller.onSelectAll(controller.soItemList, v!);
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) async {
                              if (_debounce?.isActive ?? false) {
                                _debounce!.cancel();
                              }
                              _debounce = Timer(
                                const Duration(milliseconds: 400),
                                () async {
                                  await controller.onSearchChanged(
                                    value,
                                    user: user,
                                  );
                                },
                              );
                            },
                            textInputAction: TextInputAction.search,
                            onFieldSubmitted: (v) {
                              controller.onSearchChanged(v, user: user);
                            },
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: "Search item code, name...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 14),
                              suffixIcon:
                                  controller.searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () async {
                                        if (user != null) {
                                          await controller.clearSearch(user!);
                                        }
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: controller.soItemList.isEmpty
                              ? Center(
                                  child: Text(
                                    "No Data",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: controller.soItemList.length,
                                  itemBuilder: (context, index) {
                                    final item = controller.soItemList[index];
                                    final isSelected = controller.cartList.any(
                                      (cartItem) =>
                                          cartItem.itemCode == item.itemCode &&
                                          cartItem.salesOrder ==
                                              item.salesOrder,
                                    );

                                    // final isSelected = controller.cartList.any(
                                    //   (cartItem) =>
                                    //       cartItem.itemCode == item.itemCode,
                                    // );
                                    return InkWell(
                                      onTap: () {
                                        controller.onAddCart(item);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Container(
                                          height: 120,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value: isSelected,
                                                activeColor: Colors.blue,
                                                onChanged: (v) {},
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 230,
                                                      child: Text(
                                                        item.customerPartCode ??
                                                            item.customerPartDesc ??
                                                            "---",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    SizedBox(
                                                      width: 250,
                                                      child: Text(
                                                        item.customerPartDesc ??
                                                            item.itemName ??
                                                            "",
                                                        style: const TextStyle(
                                                          fontSize: 13.5,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      "Qty: ${item.qty}",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    Text(
                                                      "SO: ${item.salesOrder}",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Due Date: ${item.deliveryDate}",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    item.status == "MAKE READY"
                                                        ? "ORDERED"
                                                        : item.status ==
                                                              "PREPARATION STARTED"
                                                        ? "PROCESSING"
                                                        : "NEW",
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  if (item.status !=
                                                      "NOT YET USED")
                                                    const SizedBox(height: 4),
                                                  if (item.status !=
                                                      "NOT YET USED")
                                                    Text(
                                                      item.status ==
                                                              "MAKE READY"
                                                          ? item.makeReadyDate ??
                                                                "--"
                                                          : item.preparationDate ??
                                                                "--",
                                                      style: const TextStyle(
                                                        fontSize: 12.5,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item.totalBins ?? "1",
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item.clearedBins == "" ||
                                                            item.clearedBins ==
                                                                null
                                                        ? "0"
                                                        : item.clearedBins!,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerCartView(user: user ?? UserModel()),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 130,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showProfile(context, UserModel user) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Profile View"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName ?? "No Name"),
                const SizedBox(height: 4),
                Text(user.company ?? "No Company"),
                const SizedBox(height: 4),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await loginController.userLogOut();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPageNew()),
                (Route<dynamic> route) => false, // removes all previous routes
              );
            },
            label: Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
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
