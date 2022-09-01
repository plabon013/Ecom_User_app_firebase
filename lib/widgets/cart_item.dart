

import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../utils/constants.dart';

class CartItem extends StatelessWidget {
  final CartModel cartModel;
  final num priceWithQuantity;
  final VoidCallback onIncrease, onDecrease, onDelete;
  const CartItem({
    Key? key,
    required this.cartModel,
    required this.priceWithQuantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(cartModel.imageUrl!),
              ),
              title: Text(cartModel.productName!),
              subtitle: Text('$currencySymbol${cartModel.salePrice}'),
              trailing: Text(
                '$currencySymbol$priceWithQuantity',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
                    onPressed: onDecrease,
                  ),
                  Text(
                    '${cartModel.quantity}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
                    onPressed: onIncrease,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).errorColor,
                      size: 35,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
