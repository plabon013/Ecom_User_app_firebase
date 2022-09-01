

import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../db/db_helper.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartModel> cartList = [];

  Future<void> addToCart(CartModel cartModel) {
    return DbHelper.addToCart(AuthService.user!.uid, cartModel);
  }

  Future<void> removeFromCart(String productId) {
    return DbHelper.removeFromCart(AuthService.user!.uid, productId);
  }


  getAllCartItems() {
    DbHelper.getAllCartItems(AuthService.user!.uid).listen((event) {
      cartList = List.generate(event.docs.length, (index) =>
          CartModel.fromMap(event.docs[index].data()));
      notifyListeners();
    });
  }

  increaseQuantity(CartModel cartModel) async {
    if(cartModel.quantity < cartModel.stock) {
      await DbHelper.updateCartItemQuantity(
          AuthService.user!.uid, cartModel.productId!,
          cartModel.quantity + 1);
    }
  }

  decreaseQuantity(CartModel cartModel) async {
    if(cartModel.quantity > 1) {
      await DbHelper.updateCartItemQuantity(
          AuthService.user!.uid, cartModel.productId!,
          cartModel.quantity - 1);
    }
  }

  int get totalItemsInCart => cartList.length;

  num itemPriceWithQuantity(CartModel cartModel) =>
    cartModel.salePrice * cartModel.quantity;

  num getCartSubtotal() {
    num total = 0;
    for(var cartM in cartList) {
      total += cartM.salePrice * cartM.quantity;
    }
    return total;
  }

  bool isInCart(String productId) {
    bool flag = false;
    for(var cart in cartList) {
      if(cart.productId == productId) {
        flag = true;
        break;
      }
    }
    return flag;
  }
}