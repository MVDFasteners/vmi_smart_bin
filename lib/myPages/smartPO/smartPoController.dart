import 'package:flatten/myPages/KOT%20Repo/service.dart';
import 'package:flatten/myPages/smartPO/autoPoItemsModel.dart';
import 'package:flatten/myPages/smartPO/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SmartPoController extends GetxController {
  List<AutoPoItem> autoPoItems = [];
  List<AutoPoItem> filteredAutoPoItems = [];

  List<AutoPoItem> cartItemsList = [];
  List<AutoPoItem> filteredCartItemsList = [];

  List<AutoPoItem> supplierNewOrderCartList = [];
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cartSearchController = TextEditingController();

  void filterByItemCode(String query) {
    if (query.isEmpty) {
      filteredAutoPoItems = List.from(autoPoItems);
    } else {
      filteredAutoPoItems = autoPoItems.where((item) {
        return item.itemCode.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  void clearSearch() {
    searchController.text = "";
    filterByItemCode("");
  }

  void onAddCart(AutoPoItem item) {
    final exists = supplierNewOrderCartList.any(
      (cartItem) => cartItem.itemCode == item.itemCode,
    );
    if (!exists) {
      supplierNewOrderCartList.add(item);
    } else {
      supplierNewOrderCartList.removeWhere(
        (cartItem) => cartItem.itemCode == item.itemCode,
      );
    }
    update();
  }

  Future<void> fetchItems() async {
    autoPoItems = [];
    filteredAutoPoItems = [];
    autoPoItems = await AutoPoService().getAutoPoItems(
      company: "MVD FASTENERS 1",
    );
    filteredAutoPoItems = List.from(autoPoItems);
    update();
  }

  Future<AutoPoItem?> fetchSingleItem({required String itemCode}) async {
    List<AutoPoItem> itemList = await AutoPoService().getAutoPoItems(
      company: "MVD FASTENERS 1",
      itemCode: itemCode,
    );
    if (itemList.isNotEmpty) {
      return itemList[0];
    }
    return null;
  }

  Future<void> updateToCart({required AutoPoItem item}) async {
    bool? value = await AutoPoService().updateAddedToCart(
      childName: item.rowId,
      addedToCart: true,
    );
    if (value) {
      await fetchCartItems();
      update();
    }
  }

  //////////////////// Cart area //////////////

  Future<void> fetchCartItems() async {
    cartItemsList = [];
    filteredCartItemsList = [];
    cartItemsList = await AutoPoService().getAutoPoItems(
      company: "MVD FASTENERS 1",
      cartItems: 1,
    );
    filteredCartItemsList = List.from(cartItemsList);
    update();
  }

  void filterByItemCodeCartItems(String query) {
    if (query.isEmpty) {
      filteredCartItemsList = List.from(cartItemsList);
    } else {
      filteredCartItemsList = cartItemsList.where((item) {
        return item.itemCode.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  void clearSearchCartItems() {
    cartSearchController.text = "";
    filterByItemCodeCartItems("");
  }

  Future<void> createPo({required List<AutoPoItem> list}) async {
    String? value = await AutoPoService().createPurchaseOrder(orderItems: list);
    if (value != null) {
      for (AutoPoItem itm in list) {
        bool? msg = await AutoPoService().updateAddedToCart(
          childName: itm.rowId,
          addedToCart: false,
          lastPoId: value,
        );
        print(msg);
      }
      await fetchCartItems();
      update();
    }
  }
}
