import 'package:flatten/myPages/KOT%20Repo/kot%20model.dart';
import 'package:flatten/myPages/KOT%20rep%20design/reportController.dart';
import 'package:flutter/material.dart';

class BatchStockDialog extends StatelessWidget {
  final String itemCode;
  final KOTReportController controller;

  const BatchStockDialog({
    super.key,
    required this.itemCode,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).primaryColor,
              width: double.infinity,
              child: const Text(
                "Batch-wise Stock",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            // 🔹 Content
            Expanded(
              child: FutureBuilder<List<BatchStock>>(
                future: controller.viewItemStock(itemCode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const Center(child: Text("No batch stock found"));
                  }

                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = data[index];

                      return ListTile(
                        dense: true,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.warehouse,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              row.batchNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text("Date: ${row.creation.split(" ")[0]}"),
                        trailing: Text(
                          row.balanceQty.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 🔹 Footer
            Padding(
              padding: const EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
