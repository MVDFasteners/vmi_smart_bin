// import 'package:flutter/material.dart';
//
// class Work extends StatelessWidget {
//   const Work({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(
//           14,
//         ),
//       ),
//       margin: const EdgeInsets.only(
//         bottom: 14,
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(
//             14,
//           ),
//           gradient: LinearGradient(
//             colors: [
//               Colors.white,
//               Colors.blue.shade50.withOpacity(
//                 0.5,
//               ),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment:
//           CrossAxisAlignment.center,
//           children: [
//             Checkbox(
//               value: isSelected,
//               onChanged: (value) {},
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.customerPartCode ??
//                         item.itemCode ??
//                         "",
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight:
//                       FontWeight.bold,
//                       color: Color(
//                         0xFF003C4F,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     item.customerPartDesc ??
//                         item.itemName ??
//                         '',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors
//                           .grey
//                           .shade700,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     "Qty: ${item.qty} ${item.uom}",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors
//                           .grey
//                           .shade800,
//                       fontWeight:
//                       FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     "so: ${item.salesOrder}",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors
//                           .grey
//                           .shade800,
//                       fontWeight:
//                       FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Spacer(),
//             Column(
//               children: [
//                 Text(
//                   item.status == "MAKE READY"
//                       ? "ORDERED"
//                       : item.status ==
//                       "PREPARATION STARTED"
//                       ? "PREPARATION STARTED"
//                       : "FRESH",
//                 ),
//                 Text(
//                   item.status == "MAKE READY"
//                       ? item.makeReadyDate ??
//                       "--"
//                       : item.preparationDate ??
//                       "--",
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
