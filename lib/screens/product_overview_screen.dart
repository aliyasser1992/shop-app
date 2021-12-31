import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/providers/cart.dart';
import 'package:shopify1_app/providers/products.dart';
import 'package:shopify1_app/widgets/app_drawer.dart';
import 'package:shopify1_app/widgets/badge.dart';
import 'package:shopify1_app/widgets/product_grid.dart';

import 'cart_screen.dart';

enum filterOption { Favorite, All }

class ProductOverViewScreen extends StatefulWidget {
  @override
  _ProductOverViewScreenState createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _isLoading = false;
  var _showOnlyFavorite = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton(
              onSelected: (filterOption selectedVal) {
                setState(() {
                  if (selectedVal == filterOption.Favorite) {
                    _showOnlyFavorite = true;
                  } else {
                    _showOnlyFavorite = false;
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: ((_) => [
                    const PopupMenuItem(
                      child: Text('only Favorite'),
                      value: filterOption.Favorite,
                    ),
                    const PopupMenuItem(
                      child: Text('show All'),
                      value: filterOption.All,
                    ),
                  ])),
          Consumer<Cart>(
              child: IconButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(CartScreen.routName),
                  icon: const Icon(Icons.shopping_cart_outlined)),
              builder: (_, cart, ch) => Badge(
                    child: ch,
                    value: cart.itemCount.toString(),
                  ))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductGrid(
              _showOnlyFavorite,
            ),
      drawer: AppDrawer(),
    );
  }
}
