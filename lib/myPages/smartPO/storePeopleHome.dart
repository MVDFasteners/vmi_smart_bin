import 'dart:async';
import 'package:flatten/app_constant.dart';
import 'package:flatten/controllers/auth/login_controller.dart';
import 'package:flatten/models/user.dart';
import 'package:flatten/myPages/smartPO/autoPoItemsModel.dart';
import 'package:flatten/myPages/smartPO/listViewReusable.dart';
import 'package:flatten/myPages/smartPO/smartPoController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SmartOrderPoHome extends StatefulWidget {
  const SmartOrderPoHome({super.key});

  @override
  State<SmartOrderPoHome> createState() => _SmartOrderPoHomeState();
}

class _SmartOrderPoHomeState extends State<SmartOrderPoHome>
    with SingleTickerProviderStateMixin {
  final Set<int> selectedRows = {};

  LoginController loginController = Get.put(LoginController());
  SmartPoController smartPoController = Get.put(SmartPoController());
  UserModel? user;
  Timer? _debounce;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  Future<void> _onLoad() async {
    await smartPoController.fetchCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF57C3FF),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            "Items To Buy",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => SupplierNewOrderPage()),
          //     );
          //   },
          //   child: Text("Supplier View"),
          // ),
          InkWell(
            onTap: () async {
              await smartPoController.fetchCartItems();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.refresh, color: Color(0xFF006784)),
            ),
          ),
          // IconButton(
          //   icon: Icon(
          //     Icons.add_shopping_cart_outlined,
          //     color: Colors.redAccent,
          //   ),
          //   onPressed: () async {
          //     await Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => SmartPOCartItemPage()),
          //     );
          //   },
          // ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () async {
          String? value = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QRScannerScreen(controller: smartPoController),
            ),
          );
          if (value != null) {
            AutoPoItem? item = await smartPoController.fetchSingleItem(
              itemCode: value,
            );

            if (item != null) {
              bool? value = await showUpdateConfirmationDialog(context, item);
              if (value) {
                await smartPoController.updateToCart(item: item);
              }
            } else {
              toastMessage(message: "Already In Cart");
            }
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
        init: smartPoController,
        builder: (controller) {
          return SafeArea(
            bottom: true,
            top: true,
            child: Column(
              children: [
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                //   decoration: const BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [Color(0xFF57C3FF), Color(0xFF82D9FF)],
                //       begin: Alignment.topCenter,
                //       end: Alignment.bottomCenter,
                //     ),
                //   ),
                //   child: Container(
                //     height: 48,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(14),
                //     ),
                //     child: Row(
                //       children: [
                //
                //         // Expanded(
                //         //   child: TextFormField(
                //         //     onChanged: (value) async {
                //         //       if (_debounce?.isActive ?? false) {
                //         //         _debounce!.cancel();
                //         //       }
                //         //       _debounce = Timer(
                //         //         const Duration(milliseconds: 400),
                //         //         () async {
                //         //           smartPoController.filterByItemCode(value);
                //         //         },
                //         //       );
                //         //     },
                //         //     textInputAction: TextInputAction.search,
                //         //     onFieldSubmitted: (v) {
                //         //       // controller.onSearchChanged(v, user: user);
                //         //     },
                //         //     controller: controller.searchController,
                //         //     decoration: InputDecoration(
                //         //       prefixIcon: Icon(Icons.search),
                //         //       hintText: "Search item code, name...",
                //         //       border: InputBorder.none,
                //         //       contentPadding: EdgeInsets.only(top: 14),
                //         //       suffixIcon:
                //         //           controller.searchController.text.isEmpty
                //         //           ? null
                //         //           : IconButton(
                //         //               icon: const Icon(Icons.clear, size: 20),
                //         //               onPressed: () async {
                //         //                 controller.clearSearch();
                //         //               },
                //         //             ),
                //         //     ),
                //         //   ),
                //         // ),
                //       ],
                //     ),
                //   ),
                // ),
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
                        ListviewReusable(
                          controller: smartPoController,
                          list: smartPoController.filteredCartItemsList,
                          onTapCart: (item) async {
                            // bool? value = await showUpdateConfirmationDialog(
                            //   context,
                            //   item,
                            // );
                            // if (value) {
                            //   await controller.updateToCart(item: item);
                            // }
                          },
                        ),
                      ],
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

  Future<bool> showUpdateConfirmationDialog(
    BuildContext context,
    AutoPoItem item,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirm Update"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Are you ready to update?",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  _infoRow("Item Code", item.itemCode),
                  _infoRow("Item Name", item.itemName),
                  _infoRow("Qty", "${item.binQty}"),
                  _infoRow("UOM", item.uom),
                  // _infoRow("Supplier", item.supplier),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  final SmartPoController controller;

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
                Navigator.pop(context, code); // 🔥 SAFE NOW
                return;
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
