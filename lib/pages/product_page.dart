
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/main_drawer.dart';
import '../widgets/product_item.dart';
import 'cart_page.dart';

class ProductPage extends StatefulWidget {
  static const String routeName = '/product';

  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late ProductProvider productProvider;
  late CartProvider cartProvider;
  int chipValue = 0;

  @override
  void didChangeDependencies() {
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    productProvider.getAllProducts();
    productProvider.getAllCategories();
    productProvider.getAllFeaturedProducts();
    cartProvider.getAllCartItems();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          InkWell(
            onTap: () => Navigator.pushNamed(context, CartPage.routeName),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                clipBehavior: Clip.none,
                //alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 30,
                  ),
                  Positioned(
                    left: -3,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Consumer<CartProvider>(
                        builder: (context, provider, child) =>
                            FittedBox(
                            child: Text(
                          '${provider.totalItemsInCart}',
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) => Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.categoryNameList.length,
                itemBuilder: (context, index) {
                  final cat = provider.categoryNameList[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ChoiceChip(
                      selectedColor: Colors.green,
                      label: Text(cat),
                      selected: chipValue == index,
                      onSelected: (value) {
                        setState(() {
                          chipValue = value ? index : 0;
                        });
                        if (chipValue == 0) {
                          provider.getAllProducts();
                        } else {
                          provider.getAllProductsByCategory(
                              provider.categoryNameList[chipValue]);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            if (provider.featuredProductList.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const Divider(
                    height: 1.5,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.amber,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 150,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.7,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          scrollDirection: Axis.horizontal,
                        ),
                        itemCount: provider.featuredProductList.length,
                        itemBuilder: (context, index, realIndex) {
                          final product = provider.featuredProductList[index];
                          return Card(
                            elevation: 5,
                            child: Stack(
                              children: [
                                FadeInImage.assetNetwork(
                                  placeholder: 'images/placeholder.jpg',
                                  image: product.imageUrl!,
                                  fadeInCurve: Curves.bounceInOut,
                                  fadeInDuration: const Duration(seconds: 2),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    color: Colors.black54,
                                    child: Text(
                                      product.name!,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            provider.productList.isEmpty
                ? const Center(
                    child: Text('No item found'),
                  )
                : Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.7),
                      itemCount: provider.productList.length,
                      itemBuilder: (context, index) {
                        final product = provider.productList[index];
                        return ProductItem(
                          productModel: product,
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
