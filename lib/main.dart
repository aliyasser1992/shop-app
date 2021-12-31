import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/providers/orders.dart';
import 'package:shopify1_app/providers/products.dart';
import 'package:shopify1_app/screens/splash_screen.dart';

import 'providers/auth.dart';
import 'providers/cart.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';

import 'screens/edit_product_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_overview_screen.dart';
import 'screens/user_product_screen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (ctx, authValue, previousProduct) => previousProduct
            ..getData(authValue.token, authValue.userId,
                previousProduct == null ? null : previousProduct.items),
        ),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (ctx, authValue, previousOrders) => previousOrders
            ..getData(authValue.token, authValue.userId,
                previousOrders == null ? null : previousOrders.orders),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange)
                .copyWith(secondary: Colors.orangeAccent),
          ),
          home: auth.isAuth
              ? ProductOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, AsyncSnapshot authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routName: (_) => ProductDetailScreen(),
            CartScreen.routName: (_) => CartScreen(),
            OrderScreen.routName: (_) => OrderScreen(),
            UserProductScreen.routName: (_) => UserProductScreen(),
            EditProductScreen.routName: (_) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
