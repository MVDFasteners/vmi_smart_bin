import 'package:flatten/myPages/smartPO/autoPoItemsModel.dart';
import 'package:flatten/myPages/smartPO/smartPoController.dart';
import 'package:flutter/material.dart';

class ListviewReusable extends StatelessWidget {
  final SmartPoController controller;
  final List<AutoPoItem> list;
  final void Function(AutoPoItem item)? onTapCart;
  final bool? isSelected;

  const ListviewReusable({
    super.key,
    required this.controller,
    required this.list,
    this.onTapCart,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: list.isEmpty
          ? Center(child: Text("No Data", style: TextStyle(fontSize: 24)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];

                bool va = controller.supplierNewOrderCartList.contains(item);

                return InkWell(
                  onTap: () {
                    if (onTapCart != null) {
                      onTapCart!(item);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      height: 100,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSelected ?? false
                          ? _containerWithCheck(item, va)
                          : _containerOnly(item),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _containerWithCheck(AutoPoItem item, bool value) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: (v) {}),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 230,
                child: Text(
                  item.itemCode ?? "---",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 230,
                child: Text(
                  item.itemName ?? "---",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Qty: ${item.binQty} ${item.uom}",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _containerOnly(AutoPoItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 230,
          child: Text(
            item.itemCode ?? "---",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 230,
          child: Text(
            item.itemName ?? "---",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Qty: ${item.binQty} ${item.uom}",
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}
