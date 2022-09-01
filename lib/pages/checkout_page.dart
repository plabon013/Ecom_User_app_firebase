

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_user_app_firebase/pages/product_page.dart';
import 'package:ecom_user_app_firebase/pages/user_address_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../auth/auth_service.dart';
import '../models/date_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';
import 'order_successful_page.dart';

class CheckoutPage extends StatefulWidget {
  static const String routeName = '/checkout';

  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late CartProvider cartProvider;
  late OrderProvider orderProvider;
  late UserProvider userProvider;
  String paymentMethodGroupValue = PaymentMethod.cod;
  bool isFirst = true;

  @override
  void didChangeDependencies() {
    if(isFirst) {
      cartProvider = Provider.of<CartProvider>(context);
      orderProvider = Provider.of<OrderProvider>(context);
      userProvider = Provider.of<UserProvider>(context, listen: false);
      orderProvider.getOrderConstants();
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Text(
                  'Product Info',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  elevation: 5,
                  child: Column(
                    children: cartProvider.cartList
                        .map((cartM) => ListTile(
                              dense: true,
                              title: Text(cartM.productName!),
                              trailing: Text(
                                  '${cartM.quantity}x$currencySymbol${cartM.salePrice}'),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Payment Info',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Subtotal'),
                        trailing: Text(
                            '$currencySymbol${cartProvider.getCartSubtotal()}'),
                      ),
                      ListTile(
                        title: Text(
                            'Discount(${orderProvider.orderConstantsModel.discount})%'),
                        trailing: Text(
                            '$currencySymbol${orderProvider.getDiscountAmount(cartProvider.getCartSubtotal())}'),
                      ),
                      ListTile(
                        title: Text(
                            'VAT(${orderProvider.orderConstantsModel.vat})%'),
                        trailing: Text(
                            '$currencySymbol${orderProvider.getVatAmount(cartProvider.getCartSubtotal())}'),
                      ),
                      ListTile(
                        title: const Text('Delivery Charge'),
                        trailing: Text(
                            '$currencySymbol${orderProvider.orderConstantsModel.deliveryCharge}'),
                      ),
                      const Divider(
                        height: 1.5,
                        color: Colors.black,
                      ),
                      ListTile(
                        title: const Text('Grand Total'),
                        trailing: Text(
                          '$currencySymbol${orderProvider.getGrandTotal(cartProvider.getCartSubtotal())}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Delivery Address',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  elevation: 5,
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: userProvider.getUserByUid(AuthService.user!.uid),
                    builder: (context, snapshot) {
                      if(snapshot.hasData) {
                        final userM = UserModel.fromMap(snapshot.data!.data()!);
                        userProvider.userModel = userM;
                        final addressM = userM.address;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(addressM == null ? 'No address found' :
                              '${addressM.streetAddress}\n'
                                  '${addressM.area}, ${addressM.city}\n'
                                  '${addressM.zipCode}'),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, UserAddressPage.routeName),
                                child: const Text('Change'),
                              )
                            ],
                          ),
                        );
                      }
                      if(snapshot.hasError) {
                        return Center(child: const Text('Failed to fetch data'),);
                      }

                      return Center(child: const Text('Fetching address...'),);
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: PaymentMethod.cod,
                          groupValue: paymentMethodGroupValue,
                          onChanged: (value) {
                            setState(() {
                              paymentMethodGroupValue = value!;
                            });
                          },
                        ),
                        const Text(PaymentMethod.cod),
                        const SizedBox(width: 10,),
                        Radio<String>(
                          value: PaymentMethod.online,
                          groupValue: paymentMethodGroupValue,
                          onChanged: (value) {
                            setState(() {
                              paymentMethodGroupValue = value!;
                            });
                          },
                        ),
                        const Text(PaymentMethod.online),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _saveOrder,
            child: const Text('Proceed to Order'),
          )
        ],
      ),
    );
  }

  void _saveOrder() {
    if(userProvider.userModel?.address == null) {
      showMsg(context, 'Please provide a delivery address');
      return;
    }
    EasyLoading.show(status: 'Please wait');
    final orderM = OrderModel(
      userId: AuthService.user!.uid,
      deliveryAddress: userProvider.userModel!.address!,
      paymentMethod: paymentMethodGroupValue,
      orderStatus: OrderStatus.pending,
      orderDate: DateModel(
        timestamp: Timestamp.fromDate(DateTime.now()),
        day: DateTime.now().day,
        month: DateTime.now().month,
        year: DateTime.now().year,
      ),
      grandTotal: orderProvider.getGrandTotal(cartProvider.getCartSubtotal()),
      discount: orderProvider.orderConstantsModel.discount,
      vat: orderProvider.orderConstantsModel.vat,
      deliveryCharge: orderProvider.orderConstantsModel.deliveryCharge,
    );

    orderProvider.addOrder(orderM, cartProvider.cartList)
      .then((_) {
        orderProvider.updateProductStock(cartProvider.cartList)
            .then((_) {
                orderProvider.updateCategoryProductCount(
                    cartProvider.cartList,
                    context.read<ProductProvider>().categoryList)
                    .then((_) {
                        orderProvider.clearUserCartItems(cartProvider.cartList)
                            .then((_) {
                              EasyLoading.dismiss();
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    OrderSuccessfulPage.routeName,
                                        ModalRoute.withName(ProductPage.routeName));
                        });
                });
        });
    });


  }
}
