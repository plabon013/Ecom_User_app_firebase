

import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../db/db_helper.dart';
import '../models/cart_model.dart';
import '../models/category_model.dart';
import '../models/order_constants_model.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  OrderConstantsModel orderConstantsModel = OrderConstantsModel();
  List<OrderModel> orderList = [];

  Future<void> addOrder(OrderModel orderModel, List<CartModel> cartList) =>
    DbHelper.addNewOrder(orderModel, cartList);

  Future<void> updateProductStock(List<CartModel> cartList) =>
    DbHelper.updateProductStock(cartList);

  Future<void> updateCategoryProductCount(
      List<CartModel> cartList,
      List<CategoryModel> categoryList) =>
    DbHelper.updateCategoryProductCount(cartList, categoryList);

  Future<void> clearUserCartItems(List<CartModel> cartList) =>
    DbHelper.clearUserCartItems(AuthService.user!.uid, cartList);

  Future<void> getOrderConstants() async {
    final snapshot = await DbHelper.getOrderConstants();
    orderConstantsModel = OrderConstantsModel.fromMap(snapshot.data()!);
    notifyListeners();
  }

  Future<bool> canUserRateProduct(String pid) =>
    DbHelper.canUserRateProduct(AuthService.user!.uid, pid);

  num getDiscountAmount(num subtotal) {
    return (subtotal * orderConstantsModel.discount) / 100;
  }

  num getVatAmount(num subtotal) {
    final priceAfterDiscount = subtotal - getDiscountAmount(subtotal);
    return (priceAfterDiscount * orderConstantsModel.vat) / 100;
  }

  num getGrandTotal(num subtotal) {
    return (subtotal - getDiscountAmount(subtotal))
        + getVatAmount(subtotal) + orderConstantsModel.deliveryCharge;
  }

  void getOrdersByUser() {
    DbHelper.getOrdersByUser(AuthService.user!.uid).listen((event) {
      orderList = List.generate(event.docs.length, (index) =>
          OrderModel.fromMap(event.docs[index].data()));
      notifyListeners();
    });
  }

}