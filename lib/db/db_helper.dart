
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_user_app_firebase/models/cart_model.dart';
import 'package:ecom_user_app_firebase/models/product_model.dart';

import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/rating_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class DbHelper {
  static const String collectionCategory = 'Categories';
  static const String collectionProduct = 'Products';
  static const String collectionRating = 'Ratings';
  static const String collectionUser = 'User';
  static const String collectionCart = 'Cart';
  static const String collectionCities = 'Cities';
  static const String collectionOrder = 'Order';
  static const String collectionOrderDetails = 'OrderDetails';
  static const String collectionOrderSettings = 'Settings';
  static const String documentOrderConstant = 'OrderConstant';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> addNewOrder(OrderModel orderModel, List<CartModel> cartList) {
    final wb = _db.batch();
    final orderDoc = _db.collection(collectionOrder).doc();
    orderModel.orderId = orderDoc.id;
    wb.set(orderDoc, orderModel.toMap());
    for(var cartM in cartList) {
      final cartDoc = orderDoc.collection(collectionOrderDetails).doc(cartM.productId);
      wb.set(cartDoc, cartM.toMap());
    }
    return wb.commit();
  }

  static Future<void> updateProductStock(List<CartModel> cartList) {
    final wb = _db.batch();
    for(var cartM in cartList) {
      final productDoc = _db.collection(collectionProduct).doc(cartM.productId);
      wb.update(productDoc, {productStock : (cartM.stock - cartM.quantity)});
    }
    return wb.commit();
  }

  static Future<void> updateCategoryProductCount(
      List<CartModel> cartList,
      List<CategoryModel> categoryList) {
    final wb = _db.batch();
    for(var cartM in cartList) {
      final catM = categoryList.firstWhere((element) => element.name == cartM.category);
      final catDoc = _db.collection(collectionCategory).doc(catM.id);
      wb.update(catDoc, {categoryProductCount : catM.productCount - cartM.quantity});
    }
    return wb.commit();
  }

  static Future<void> clearUserCartItems(String uid, List<CartModel> cartList) {
    final wb = _db.batch();
    final userDoc = _db.collection(collectionUser).doc(uid);
    for(var cartM in cartList) {
      final cartDoc = userDoc.collection(collectionCart).doc(cartM.productId);
      wb.delete(cartDoc);
    }
    return wb.commit();
  }

  static Future<void> addToCart(String uid, CartModel cartModel) {
    return _db.collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(cartModel.productId)
        .set(cartModel.toMap());
  }

  static Future<void> updateCartItemQuantity(String uid, String pid, num quantity) {
    return _db.collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(pid)
        .update({cartProductQuantity : quantity});
  }

  static Future<void> removeFromCart(String uid, String pid) {
    return _db.collection(collectionUser)
        .doc(uid)
        .collection(collectionCart)
        .doc(pid)
        .delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCategories() =>
      _db.collection(collectionCategory).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProducts() =>
      _db.collection(collectionProduct)
          .where(productAvailable, isEqualTo: true)
          .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getOrdersByUser(String uid) =>
      _db.collection(collectionOrder)
          .where(userIDKey, isEqualTo: uid)
          .orderBy('$orderDateKey.timestamp', descending: true)
          .snapshots();
  
  static Future<bool> canUserRateProduct(String uid, String pid) async {
    final qSnapshot = await _db.collection(collectionOrder)
        .where(userIDKey, isEqualTo: uid)
        .where(orderStatusKey, isEqualTo: OrderStatus.delivered)
        .get();
    if(qSnapshot.docs.isEmpty) return false;
    bool tag = false;
    for(var snapshot in qSnapshot.docs) {
      final docSnap = await snapshot.reference.collection(collectionOrderDetails).doc(pid).get();
      if(docSnap.exists) {
        tag = true;
        break;
      }
    }
    return tag;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCities() =>
      _db.collection(collectionCities).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllCartItems(String uid) =>
      _db.collection(collectionUser)
          .doc(uid)
          .collection(collectionCart)
          .snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllProductsByCategory(String category) =>
      _db.collection(collectionProduct).where(productCategory, isEqualTo: category).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllFeaturedProducts() =>
      _db.collection(collectionProduct).where(productFeatured, isEqualTo: true).snapshots();

  static Future<DocumentSnapshot<Map<String, dynamic>>> getOrderConstants() =>
      _db.collection(collectionOrderSettings).doc(documentOrderConstant).get();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getProductById(String id) =>
      _db.collection(collectionProduct).doc(id).snapshots();

  static Future<void> addUser(UserModel userModel) {
    return _db.collection(collectionUser)
        .doc(userModel.uid).set(userModel.toMap());
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserByUid(String uid) {
    return _db.collection(collectionUser).doc(uid).snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllRatingsByProduct(String pid) {
    return _db.collection(collectionProduct).doc(pid).collection(collectionRating).get();
  }

  static Future<void> updateProfile(String uid, Map<String, dynamic> map) {
    return _db.collection(collectionUser)
        .doc(uid).update(map);
  }

  static Future<void> addRating(RatingModel ratingM) {
    final proDoc = _db.collection(collectionProduct).doc(ratingM.productId);
    final ratingDoc = proDoc.collection(collectionRating).doc(ratingM.userId);
    return ratingDoc.set(ratingM.toMap());
  }

  static Future<void> updateProduct(String pid, Map<String, dynamic> map) {
    return _db.collection(collectionProduct)
        .doc(pid)
        .update(map);
  }


}