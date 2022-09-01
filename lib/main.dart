import 'package:ecom_user_app_firebase/providers/order_provider.dart';
import 'package:ecom_user_app_firebase/providers/product_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/order_page.dart';
import 'pages/order_successful_page.dart';
import 'pages/registration_page.dart';
import 'pages/launcher_page.dart';
import 'pages/login_page.dart';
import 'pages/phone_verification_page.dart';
import 'pages/product_details_page.dart';
import 'pages/product_page.dart';
import 'pages/user_address_page.dart';
import 'pages/user_profile_page.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: LauncherPage.routeName,
      builder: EasyLoading.init(),
      routes: {
        LauncherPage.routeName: (_) => LauncherPage(),
        LoginPage.routeName: (_) => LoginPage(),
        ProductPage.routeName: (_) => ProductPage(),
        ProductDetailsPage.routeName: (_) => ProductDetailsPage(),
        PhoneVerificationPage.routeName: (_) => PhoneVerificationPage(),
        RegistrationPage.routeName: (_) => RegistrationPage(),
        UserProfilePage.routeName: (_) => UserProfilePage(),
        CartPage.routeName: (_) => CartPage(),
        CheckoutPage.routeName: (_) => CheckoutPage(),
        UserAddressPage.routeName: (_) => UserAddressPage(),
        OrderSuccessfulPage.routeName: (_) => OrderSuccessfulPage(),
        OrderPage.routeName: (_) => OrderPage(),
      },
    );
  }
}


