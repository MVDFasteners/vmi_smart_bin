import 'package:flatten/app_constant.dart';
import 'package:flatten/controllers/mycontroller/vmi_controller.dart';
import 'package:flatten/models/sales_order_items.dart';
import 'package:flatten/models/user.dart';
import 'package:flatten/myPages/pdf_print_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:printing/printing.dart';

class CustomerCartView extends StatelessWidget {
  final UserModel user;

  const CustomerCartView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    VMIController vmiController = Get.put(VMIController());
    return GetBuilder(
      init: vmiController,
      builder: (controller) {
        return SafeArea(
          bottom: true,
          top: false,
          child: Scaffold(
            bottomNavigationBar: Container(
              color: const Color(0xFFE8F4F8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await showEmailListDialog(context, user);
                      },
                      icon: Icon(Icons.email_sharp),
                    ),
                    SizedBox(width: 10),
                    TextButton.icon(
                      onPressed: () {
                        if (controller.cartList.isNotEmpty) {
                          controller.cartList.clear();
                          controller.update();
                        }
                      },
                      label: Text(
                        "Clear Cart",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          // foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF006784).withOpacity(0.4),
                        ),
                        onPressed: () async {
                          if (controller.cartList.isEmpty) {
                            toastMessage(message: "Cart is Empty");
                          } else {
                            await controller.updateSOItems(user, context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            controller.isSubmittingCartItems
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Submit",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              backgroundColor: const Color(0xFF57C3FF),
              title: Text(
                " Selected Items",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Total : ${controller.cartList.length}",
                    style: TextStyle(fontSize: 26, color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await openInvoicePdf(
                      user: user,
                      itemList: controller.cartList,
                    );
                  },
                  icon: Icon(Icons.print, color: Colors.white),
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE8F4F8), Color(0xFFB5DDF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: controller.cartList.isEmpty
                  ? Center(
                      child: Text("Empty Cart", style: TextStyle(fontSize: 20)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: controller.cartList.length,
                      itemBuilder: (context, index) {
                        final item =
                            controller.cartList[index]; // your model data
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          margin: const EdgeInsets.only(bottom: 14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.blue.shade50.withOpacity(0.5),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.inventory,
                                    color: Color(0xFF006784),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemCode ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF003C4F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.itemCode ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Qty: ${item.qty}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    controller.onAddCart(item);
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showEmailListDialog(BuildContext context, UserModel user) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Emails to Send Notification Alerts",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: user.emails.isEmpty
                ? const Text("No emails found")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: user.emails.length,
                    itemBuilder: (context, index) {
                      final emailItem = user.emails[index];
                      return ListTile(
                        leading: const Icon(Icons.email, color: Colors.blue),
                        title: Text(emailItem.email),
                        subtitle: Text(emailItem.name1),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> openInvoicePdf({
    required UserModel user,
    required List<SoPriority> itemList,
  }) async {
    final pdf = await PdfPrintView().generateInvoicePdf(
      companyName: user.customerName ?? "",
      poNumber: itemList.isNotEmpty ? itemList[0].customerPo ?? "" : "",
      items: itemList,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
