import 'package:flatten/myPages/KOT%20rep%20design/reportController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class DashboardSection extends StatelessWidget {
  final KOTReportController controller;
  final VoidCallback? onSubmit;

  const DashboardSection({super.key, required this.controller, this.onSubmit});

  Widget card({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          Stack(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Checkbox(
                  value: controller.isAllSelected,
                  onChanged: (v) {
                    controller.toggleSelectAll(v!);
                  },
                ),
              ),
              Positioned(
                top: 7,
                left: 7,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 20,
                  width: 20,
                  child: Center(
                    child: Text(
                      controller.selectedRows.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 270,
            child: card(
              title: "Total Stock Value",
              value: "₹${(controller.totalStockValue).toString()}",
              icon: Icons.inventory_2_outlined,
              bgColor: Colors.grey.shade200,
              iconColor: Colors.black87,
            ),
          ),
          SizedBox(
            width: 270,
            child: card(
              title: "Month Billed",
              value: "₹${(controller.totalBilledValue).toString()}",
              icon: Icons.calendar_month,
              bgColor: Colors.blue.shade50,
              iconColor: Colors.blue.shade800,
            ),
          ),
          SizedBox(
            width: 200,
            child: card(
              title: "Today Billed",
              value: "₹${(controller.todayBilledValue).toString()}",
              icon: Icons.today,
              bgColor: Colors.orange.shade50,
              iconColor: Colors.orange.shade800,
            ),
          ),

          // ================= ROW 2 (4) =================
          SizedBox(
            width: 200,
            child: card(
              title: "Items Pending",
              value: controller.reducedSoList.length.toString(),
              icon: Icons.list_alt,
              bgColor: Colors.grey.shade200,
              iconColor: Colors.black87,
            ),
          ),
          SizedBox(
            width: 200,
            child: card(
              title: "SO Pending",
              value: controller.soPending.toString(),
              icon: Icons.receipt_long,
              bgColor: Colors.grey.shade200,
              iconColor: Colors.black87,
            ),
          ),

          SizedBox(
            width: 140,
            child: card(
              title: "Bin So",
              value: controller.binBasedSoCount.toString(),
              icon: Icons.list_alt,
              bgColor: Colors.red.shade50,
              iconColor: Colors.red.shade800,
            ),
          ),
          SizedBox(
            width: 140,
            child: card(
              title: "Bins To Fill",
              value: controller.binsToFillCount.toString(),
              icon: Icons.list_alt,
              bgColor: Colors.red.shade50,
              iconColor: Colors.red.shade800,
            ),
          ),

          SizedBox(
            width: 140,
            child: card(
              title: "Customer",
              value: controller.customers.toString(),
              icon: Icons.people_outline,
              bgColor: Colors.grey.shade200,
              iconColor: Colors.black87,
            ),
          ),
          SizedBox(
            width: 150,
            child: card(
              title: "Stock",
              value: controller.green.toString(),
              icon: Icons.check_circle_outline,
              bgColor: Colors.green.shade50,
              iconColor: Colors.green.shade800,
            ),
          ),

          // ================= ROW 3 (3) =================
          SizedBox(
            width: 150,
            child: card(
              title: "Stock",
              value: controller.orange.toString(),
              icon: Icons.warning_amber_rounded,
              bgColor: Colors.orange.shade50,
              iconColor: Colors.orange.shade800,
            ),
          ),
          SizedBox(
            width: 170,
            child: card(
              title: "No Stock",
              value: controller.red.toString(),
              icon: Icons.cancel_outlined,
              bgColor: Colors.red.shade50,
              iconColor: Colors.red.shade800,
            ),
          ),
          SizedBox(
            width: 170,
            child: card(
              title: "Platting Stock",
              value: controller.blue.toString(),
              icon: Icons.settings,
              bgColor: Colors.blue.shade50,
              iconColor: Colors.blue.shade800,
            ),
          ),
          SizedBox(
            height: 60,
            width: 100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: onSubmit, child: Text("Submit")),
            ),
          ),
        ],
      ),
    );
  }
}
