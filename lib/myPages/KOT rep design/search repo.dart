// import 'package:flutter/material.dart';
//
// class ReportSearchFields extends StatelessWidget {
//   final ValueChanged<String> onItemCode;
//   final ValueChanged<String> onItemName;
//   final ValueChanged<String> onSo;
//   final ValueChanged<String> onCustomer;
//   final VoidCallback? onSubmit;
//
//   const ReportSearchFields({
//     super.key,
//     required this.onItemCode,
//     required this.onItemName,
//     required this.onSo,
//     required this.onCustomer,
//     this.onSubmit,
//   });
//
//   Widget _field(String hint, ValueChanged<String> onChanged) {
//     return SizedBox(
//       width: 220,
//       child: TextField(
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           hintText: hint,
//           prefixIcon: const Icon(Icons.search, size: 18),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 10,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _field("Item Code", onItemCode),
//         const SizedBox(width: 8),
//         _field("Item Name", onItemName),
//         const SizedBox(width: 8),
//         _field("Sales Order", onSo),
//         const SizedBox(width: 8),
//         _field("Customer", onCustomer),
//         const SizedBox(width: 8),
//         TextButton(onPressed: onSubmit, child: Text("Update")),
//       ],
//     );
//   }
// }
