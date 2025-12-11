// 📌 File: dispatched_items.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DispatchedItemsPage(),
    );
  }
}

class DispatchedItemsPage extends StatefulWidget {
  @override
  State<DispatchedItemsPage> createState() => _DispatchedItemsPageState();
}

class _DispatchedItemsPageState extends State<DispatchedItemsPage> {
  String selectedYear = "2025";
  String selectedMonth = "Dec";

  final TextEditingController searchController = TextEditingController();

  List<DispatchModel> items = [];
  List<DispatchModel> filteredItems = [];

  @override
  void initState() {
    super.initState();

    // SAMPLE DATA
    items = [
      DispatchModel(
        date: "2025-12-02",
        itemCode: "B00000020 - 1",
        description: "3AXD50000023609",
        qty: "500 Nos",
        soNumber: "SO-MV-25-26-00080",
        ordered: "2025-12-01",
        prepared: "2025-12-02",
        dispatched: "2025-12-02",
      ),
      DispatchModel(
        date: "2025-12-01",
        itemCode: "MVD0410AL/S",
        description: "BLIND RIVET DOME ALU/STL 4X10",
        qty: "250 Nos",
        soNumber: "SO-MV-25-26-00080",
        ordered: "2025-11-28",
        prepared: "2025-11-30",
        dispatched: "2025-12-01",
      ),
    ];

    filteredItems = List.from(items);
  }

  // 🔍 SEARCH FUNCTION
  void filterSearch(String query) {
    setState(() {
      filteredItems = items.where((item) {
        return item.itemCode.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()) ||
            item.soNumber.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // 🖨 PRINT BUTTON ACTION
  void printPage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🖨 Printing not implemented yet!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,

      // --------------------
      // APP BAR
      // --------------------
      appBar: AppBar(
        title: Text("Dispatched Items"),
        backgroundColor: Colors.blue,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.print),
          //   onPressed: printPage,
          //   tooltip: "Print",
          // ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                searchController.clear();
                filteredItems = List.from(items);
              });
            },
          ),
        ],
      ),

      // --------------------
      // BODY
      // --------------------
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // FILTER ROW
            Row(
              children: [
                yearDropdown(),
                SizedBox(width: 10),
                monthDropdown(),
                SizedBox(width: 10),
                Expanded(child: searchBox()),
              ],
            ),

            SizedBox(height: 20),

            // LIST VIEW
            Expanded(
              child: ListView(
                children:
                filteredItems.map((item) => dispatchedCard(item)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // YEAR DROPDOWN
  // ------------------------------
  Widget yearDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: boxStyle(),
      child: DropdownButton<String>(
        value: selectedYear,
        underline: SizedBox(),
        items: ["2024", "2025", "2026"]
            .map((year) => DropdownMenuItem(value: year, child: Text(year)))
            .toList(),
        onChanged: (value) {
          setState(() => selectedYear = value!);
        },
      ),
    );
  }

  // ------------------------------
  // MONTH DROPDOWN
  // ------------------------------
  Widget monthDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: boxStyle(),
      child: DropdownButton<String>(
        value: selectedMonth,
        underline: SizedBox(),
        items: [
          "Jan","Feb","Mar","Apr","May","Jun",
          "Jul","Aug","Sep","Oct","Nov","Dec"
        ]
            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
            .toList(),
        onChanged: (value) {
          setState(() => selectedMonth = value!);
        },
      ),
    );
  }

  // ------------------------------
  // SEARCH FIELD
  // ------------------------------
  Widget searchBox() {
    return TextField(
      controller: searchController,
      onChanged: filterSearch, // 🔍 LIVE SEARCH
      decoration: InputDecoration(
        hintText: "Search Item, Description, SO No...",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.search),
        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget dispatchedCard(DispatchModel m) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.itemCode,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                m.date,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            m.description,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),

          SizedBox(height: 8),

          Text(
            "QTY: ${m.qty}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 4),

          Text(
            "SO No: ${m.soNumber}",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          Divider(height: 20, thickness: 1),

          // ORDERED / PREPARED / DISPATCHED
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Ordered :", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text("Prepared :", style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text("Dispatched :", style: TextStyle(fontWeight: FontWeight.w600)),
                  ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(m.ordered),
                  SizedBox(height: 4),
                  Text(m.prepared),
                  SizedBox(height: 4),
                  Text(m.dispatched),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STYLE
  BoxDecoration boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}

// --------------------------------------------------
// MODEL
// --------------------------------------------------
class DispatchModel {
  final String date;
  final String itemCode;
  final String description;
  final String qty;
  final String soNumber;
  final String ordered;
  final String prepared;
  final String dispatched;

  DispatchModel({
    required this.date,
    required this.itemCode,
    required this.description,
    required this.qty,
    required this.soNumber,
    required this.ordered,
    required this.prepared,
    required this.dispatched,
  });
}