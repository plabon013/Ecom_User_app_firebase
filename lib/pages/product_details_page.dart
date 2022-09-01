

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class ProductDetailsPage extends StatelessWidget {
  static const String routeName = '/product_details';

  const ProductDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pid = ModalRoute.of(context)!.settings.arguments as String;
    final provider = Provider.of<ProductProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: provider.getProductById(pid),
        builder: (context, snapshot) {
          print('new snapshot');
          if (snapshot.hasData) {
            final product = ProductModel.fromMap(snapshot.data!.data()!);
            return ListView(
              children: [
                FadeInImage.assetNetwork(
                  placeholder: 'images/placeholder.jpg',
                  image: product.imageUrl!,
                  fadeInCurve: Curves.bounceInOut,
                  fadeInDuration: const Duration(seconds: 3),
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                ListTile(
                  title: Text(product.name!),
                  subtitle: Text('Rating: ${product.rating}'),
                ),
                ListTile(
                  title: Text('$currencySymbol${product.salesPrice}'),
                ),
                ListTile(
                  title: const Text('Product Description'),
                  subtitle: Text(product.description ?? 'Not Available'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add a comment'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        EasyLoading.show(status: 'Please wait');
                        final canRate = await Provider.of<OrderProvider>(context, listen: false)
                            .canUserRateProduct(pid);
                        EasyLoading.dismiss();
                        if(canRate) {
                          //showMsg(context, 'You can rate');
                          _showRatingBarDialog(context, product, (value) async {
                            await provider.addNewRating(value, pid);
                          });
                        } else {
                          showMsg(context, 'You cannot rate');

                        }
                      },
                      child: const Text('Rate this product'),
                    ),
                  ],
                )
              ],
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

    );
  }

  void _showRatingBarDialog(BuildContext context, ProductModel product, Function(double) onRate) {
    double userRating = 0.0;
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text('Rate ${product.name!}'),
      content: RatingBar.builder(
        initialRating: 3,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          //print(rating);
          userRating = rating;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            onRate(userRating);
            Navigator.pop(context);
          },
          child: const Text('RATE'),
        ),
      ],
    ),);
  }
}
