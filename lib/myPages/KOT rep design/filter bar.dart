import 'package:flatten/myPages/KOT%20rep%20design/reportController.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class FilterBar extends StatelessWidget {
  final String company;
  final String stockStatus;
  final String reportType;
  final String storeName;

  final ValueChanged<String> onCompanyChanged;
  final ValueChanged<String> onReportTypeChanged;
  final ValueChanged<String> onStoreNameChanged;
  final ValueChanged<String> onColorChange;
  final List<Widget>? widgetList;

  final ValueChanged<String> onItemCode;
  final ValueChanged<String> onItemName;
  final ValueChanged<String> onSo;
  final ValueChanged<String> onCustomer;
  final ValueChanged<String> onDeliveryDate;
  final KOTReportController controller;

  const FilterBar({
    super.key,
    required this.company,
    required this.reportType,
    required this.storeName,
    required this.stockStatus,
    required this.onCompanyChanged,
    required this.onStoreNameChanged,
    required this.onReportTypeChanged,
    required this.onColorChange,
    this.widgetList,
    required this.onItemCode,
    required this.onItemName,
    required this.onSo,
    required this.onCustomer,
    required this.controller,
    required this.onDeliveryDate,
  });

  Widget drop(
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
    double width,
  ) {
    return SizedBox(
      width: width,
      height: 38,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: Colors.white,
        // ✅ dropdown background
        style: const TextStyle(
          color: Colors.black87, // ✅ selected text color
          fontSize: 14,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
        ),
        items: items.map((e) {
          return DropdownMenuItem<String>(
            value: e,
            child: SizedBox(
              width: width - 40,
              child: Text(
                e,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.black87, // ✅ list item text color
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _field(
    String hint,
    ValueChanged<String> onChanged, {
    TextEditingController? controller,
  }) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 18),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            drop(
              reportType,
              const ["Normal", "Bins To Fill"],
              onReportTypeChanged,
              120,
            ),
            const SizedBox(width: 8),
            drop(
              stockStatus,
              const ["ALL", "GREEN", "YELLOW", "RED", "BLUE"],
              onColorChange,
              100,
            ),
            const SizedBox(width: 8),
            _field("Item Code", onItemCode),
            const SizedBox(width: 8),
            _field("Item Name", onItemName),
            const SizedBox(width: 8),
            _field("Sales Order", onSo, controller: controller.soTextEditCtrl),
            const SizedBox(width: 8),
            _field("Customer", onCustomer),
            const SizedBox(width: 8),
            _field("Delivery Date", onDeliveryDate),
            const SizedBox(width: 8),
            drop(
              storeName,
              const ["GANGA", "YAMUNA", "GODAVARI", "KRISHNA", "KAVERI"],
              onStoreNameChanged,
              200,
            ),
            ...?widgetList,
            if (controller.showExtraFilter)
              drop(
                company,
                const ["MVD FASTENERS PRIVATE LIMITED", "MVD FASTENERS 1"],
                onCompanyChanged,
                200,
              ),
          ],
        ),
      ),
    );
  }
}
