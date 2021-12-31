import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/providers/products.dart';
import 'package:shopify1_app/widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool shoeFavs;

  const ProductGrid(this.shoeFavs);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = shoeFavs ? productData.favoriteItems : productData.items;
    return products.isEmpty
        ? Center(
            child: Text('there is no products yet'),
          )
        : GridView.builder(
            padding: EdgeInsets.all(10),
            itemCount: products.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: ProductItem(),
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 15 / 15,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
          );
  }
}
