import 'package:flatten/myPages/KOT%20Repo/kot%20model.dart';
import 'package:flatten/myPages/KOT%20Repo/service.dart';
import 'package:flutter/material.dart';

List<KotStockRow> getDummyData() {
  return [
    KotStockRow(
      salesOrder: "SO-001",
      soiName: "SOI-1",
      itemCode: "ITEM-1",
      deliveryDate: DateTime(2025, 1, 10),
      soQty: 8,
      availableStock: 100,
      kotQty: 10,
    ),
    KotStockRow(
      salesOrder: "SO-002",
      soiName: "SOI-2",
      itemCode: "ITEM-1",
      deliveryDate: DateTime(2025, 1, 12),
      soQty: 5,
      availableStock: 100,
      kotQty: 10,
    ),
    KotStockRow(
      salesOrder: "SO-003",
      soiName: "SOI-3",
      itemCode: "ITEM-2",
      deliveryDate: DateTime(2025, 1, 11),
      soQty: 6,
      availableStock: 4,
      kotQty: 4,
    ),
    KotStockRow(
      salesOrder: "SO-002",
      soiName: "SOI-2",
      itemCode: "ITEM-1",
      deliveryDate: DateTime(2025, 1, 12),
      soQty: 30,
      availableStock: 100,
      kotQty: 5,
    ),
  ];
}

List<PendingKotItem> getAnotherKotDummyData() {
  return [
    PendingKotItem(itemCode: "ITEM-1", pendingKotQty: 5),
    PendingKotItem(itemCode: "ITEM-3", pendingKotQty: 12),
  ];
}

class KotStockScreen extends StatefulWidget {
  const KotStockScreen({super.key});

  @override
  State<KotStockScreen> createState() => _KotStockScreenState();
}

class _KotStockScreenState extends State<KotStockScreen> {
  late List<KotStockRow> rows;

  @override
  void initState() {
    super.initState();

    rows = getDummyData()
      ..sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));

    final pendingKotList = getAnotherKotDummyData();

    applyStockReductionWithPendingKot(rows, pendingKotList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KOT Stock Allocation"),
        actions: [
          TextButton(
            onPressed: () async {
              await Service().getPendingSoItems(
                company: "MVD FASTENERS 1",
                // itemCode: "Testing Code 1",
                platingWarehouse: ""
              );
              // await Service().fetchPendingKotItemWise();
            },
            child: Text("Press"),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final r = rows[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("${r.itemCode}  |  ${r.salesOrder}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SO Qty: ${r.soQty}"),
                  Text("Available Stock (Running): ${r.displayStock}"),
                  Text("KOT Qty: ${r.kotQty}"),
                  Text(
                    "Delivery: ${r.deliveryDate.toString().split(' ').first}",
                  ),
                ],
              ),

              trailing: ElevatedButton(
                onPressed: r.displayStock < r.soQty
                    ? null // 🔒 disable if insufficient stock
                    : () {
                        // save KOT later
                      },
                child: const Text("KOT"),
              ),
            ),
          );
        },
      ),
    );
  }

  void applyStockReductionWithPendingKot(
    List<KotStockRow> rows,
    List<PendingKotItem> pendingKotList,
  ) {
    final Map<String, double> pendingKotMap = {
      for (var k in pendingKotList) k.itemCode: k.pendingKotQty,
    };

    final Map<String, double> runningStock = {};
    final Set<String> seenItems = {};

    for (var row in rows) {
      final item = row.itemCode;
      double stock;

      if (!seenItems.contains(item)) {
        final baseStock = row.availableStock;
        final pendingKot = pendingKotMap[item] ?? 0;
        stock = baseStock - pendingKot;
        seenItems.add(item);
      } else {
        stock = runningStock[item] ?? 0;
      }

      row.displayStock = stock > 0 ? stock : 0;
      runningStock[item] = stock - row.soQty;
    }
  }
}
