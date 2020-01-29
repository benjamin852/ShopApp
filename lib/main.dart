import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';
import 'package:shop_app/screens/auth-screen.dart';

import 'package:shop_app/providers/products.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Provider not listener
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        //1. look for provider which providers auth object
        //1. before the proxyProvider. rebuilds when auth changes
        //2. type of value we're providing here
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (
            ctx,
            auth,
            previousProducts,
          ) =>
              Products(auth.token, auth.userId,
                  previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider.value(value: Cart()),
        // ChangeNotifierProvider.value(value: Orders()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (
            ctx,
            auth,
            previousOrders,
          ) =>
              Orders(auth.token,
                  previousOrders == null ? [] : previousOrders.orders),
        )
      ],
      //build MaterialApp() whenever auth changes
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: authData.isAuthenticated
              ? ProductsOverviewScreen()
              : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrdersScreen.routeName: (context) => OrdersScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
