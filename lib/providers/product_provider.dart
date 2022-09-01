import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth_service.dart';
import '../db/db_helper.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../models/rating_model.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> productList = [];
  List<ProductModel> featuredProductList = [];
  List<PurchaseModel> purchaseListOfSpecificProduct = [];
  List<CategoryModel> categoryList = [];
  List<String> categoryNameList = [];

  getAllCategories() {
    DbHelper.getAllCategories().listen((event) {
      categoryList = List.generate(event.docs.length, (index) =>
          CategoryModel.fromMap(event.docs[index].data()));
      categoryNameList =
          List.generate(categoryList.length, (index) =>
          categoryList[index].name!);
      categoryNameList.insert(0, 'All');
      notifyListeners();
    });
  }

  getAllProducts() {
    DbHelper.getAllProducts().listen((event) {
      productList = List.generate(event.docs.length, (index) =>
          ProductModel.fromMap(event.docs[index].data()));
      notifyListeners();
    });
  }

  getAllFeaturedProducts() {
    DbHelper.getAllFeaturedProducts().listen((event) {
      featuredProductList = List.generate(event.docs.length, (index) =>
          ProductModel.fromMap(event.docs[index].data()));
      notifyListeners();
    });
  }

  getAllProductsByCategory(String category) {
    DbHelper.getAllProductsByCategory(category).listen((event) {
      productList = List.generate(event.docs.length, (index) =>
          ProductModel.fromMap(event.docs[index].data()));
      notifyListeners();
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getProductById(String id) =>
    DbHelper.getProductById(id);


  Future<String> updateImage(XFile xFile) async {
    final imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final photoRef = FirebaseStorage.instance.ref().child('UseImages/$imageName');
    final uploadTask = photoRef.putFile(File(xFile.path));
    final snapshot = await uploadTask.whenComplete(() => null);
    return snapshot.ref.getDownloadURL();
  }

  Future<void> addNewRating(double value, String pid) async {
    final ratingM = RatingModel(
      userId: AuthService.user!.uid,
      productId: pid,
      rating: value
    );
    await DbHelper.addRating(ratingM);
    final qSnapshot = await DbHelper.getAllRatingsByProduct(pid);
    final List<RatingModel> ratingList =
      List.generate(qSnapshot.docs.length, (index) =>
      RatingModel.fromMap(qSnapshot.docs[index].data()));
    double ratingValue = 0.0;
    for(var ratingM in ratingList) {
      ratingValue += ratingM.rating;
    }
    final avgRating = ratingValue / ratingList.length;
    return DbHelper.updateProduct(pid, {productRating : avgRating});
  }

}