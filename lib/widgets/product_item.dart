import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/providers/auth.dart';
import 'package:shopify1_app/providers/cart.dart';
import 'package:shopify1_app/providers/product.dart';
import 'package:shopify1_app/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: GridTile(
          child: GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(ProductDetailScreen.routName, arguments:product.id),
            child: Hero(
              child: FadeInImage(
                placeholder:
                    const AssetImage('asets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
              tag: product.id,
            ),
          ),
          footer: GridTileBar(
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                // ignore: deprecated_member_use
                Scaffold.of(context).hideCurrentSnackBar();
                // ignore: deprecated_member_use
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: const Text('added to cart'),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                      label: 'UNDO!!!',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      }),
                ));
              },
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.secondary,
            ),
            backgroundColor: Colors.black38,
            leading: Consumer<Product>(
              builder: (ctx, product, _) => IconButton(
                onPressed: () {
                  product.toggleFavoriteStatus(authData.token, authData.userId);
                },
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ));
  }
}
