
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../pages/product_details_page.dart';
import '../providers/cart_provider.dart';
import '../utils/constants.dart';

class ProductItem extends StatefulWidget {
  final ProductModel productModel;

  const ProductItem({Key? key, required this.productModel}) : super(key: key);

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
          context,
          ProductDetailsPage.routeName,
        arguments: widget.productModel.id,
      ),
      child: Card(
        elevation: 5,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Image.network(
                    widget.productModel.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.productModel.name!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  '$currencySymbol${widget.productModel.salesPrice}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Consumer<CartProvider>(builder: (context, provider, child) {
                  final isInCart = provider.isInCart(widget.productModel.id!);
                  return ElevatedButton.icon(
                    icon: Icon(
                      isInCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if(isInCart) {
                        provider.removeFromCart(widget.productModel.id!);
                      } else {
                        final cartModel = CartModel(
                          productId: widget.productModel.id,
                          productName: widget.productModel.name,
                          salePrice: widget.productModel.salesPrice,
                          imageUrl: widget.productModel.imageUrl,
                          stock: widget.productModel.stock,
                          category: widget.productModel.category,
                        );
                        provider.addToCart(cartModel);
                      }
                    },
                    label: Text(isInCart ? 'Remove' : 'Add'),
                  );
                })
              ],
            ),
            if(widget.productModel.stock == 0) Container(
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.5),
              child: const Text('Out of Stock', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
