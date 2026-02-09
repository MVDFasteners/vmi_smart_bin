import 'dart:async';

import 'package:flatten/app_constant.dart';
import 'package:flatten/controllers/auth/login_controller.dart';
import 'package:flatten/controllers/mycontroller/vmi_controller.dart';
import 'package:flatten/models/bin_details.dart';
import 'package:flatten/models/user.dart';
import 'package:flatten/myPages/customerCart.dart';
import 'package:flatten/myPages/login_new_screen.dart';
import 'package:flatten/myPages/report_view.dart';
import 'package:flatten/myPages/smartPO/autoPoItemsModel.dart';
import 'package:flatten/myPages/smartPO/listViewReusable.dart';
import 'package:flatten/myPages/smartPO/smartPoController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class SupplierNewOrderPage extends StatefulWidget {
  const SupplierNewOrderPage({super.key});

  @override
  State<SupplierNewOrderPage> createState() => _SupplierNewOrderPageState();
}

class _SupplierNewOrderPageState extends State<SupplierNewOrderPage>
    with SingleTickerProviderStateMixin {
  final Set<int> selectedRows = {};

  LoginController loginController = Get.put(LoginController());
  SmartPoController smartPoController = Get.put(SmartPoController());

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
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Smart PO",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text("Make ASN"),
                onTap: () {},
              ),

              ListTile(
                leading: const Icon(Icons.shopping_cart),
                title: const Text("Cart Page"),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder(
        init: smartPoController,
        builder: (controller) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: SizedBox(
                  height: 60,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      bool? value = await showUpdateConfirmationDialog(
                        context,
                        controller.supplierNewOrderCartList.length,
                      );
                      if (value) {
                        await smartPoController.createPo(
                          list: controller.supplierNewOrderCartList,
                        );
                      }
                    },
                    child: Text("Accept"),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF57C3FF),
        titleSpacing: 0,
        title: InkWell(
          child: Text(
            "New Orders",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              await smartPoController.fetchCartItems();
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.refresh, color: Color(0xFF006784)),
            ),
          ),
          GetBuilder(
            init: smartPoController,
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle, // ✅ makes it round
                  ),
                  child: Center(
                    child: Text(
                      controller.supplierNewOrderCartList.length.toString(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: GetBuilder(
        init: smartPoController,
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
                    child: TextFormField(
                      onChanged: (value) async {
                        smartPoController.filterByItemCodeCartItems(value);
                      },
                      textInputAction: TextInputAction.search,
                      controller: controller.cartSearchController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search item code, name...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14),
                        suffixIcon: controller.cartSearchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () async {
                                  controller.clearSearchCartItems();
                                },
                              ),
                      ),
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
                        ListviewReusable(
                          isSelected: true,
                          onTapCart: (item) {
                            controller.onAddCart(item);
                          },
                          controller: smartPoController,
                          list: smartPoController.filteredCartItemsList,
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
    int totalLength,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirm Update"),
              content: Text("Are you ready to make Accept $totalLength Items?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes, Update"),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
