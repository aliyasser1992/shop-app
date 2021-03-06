import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/providers/products.dart';
import 'package:shopify1_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.of(context)
                    .pushNamed(EditProductScreen.routName, arguments: id),
                icon: const Icon(Icons.edit)),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProd(id);
                } catch (e) {
                  scaffold.showSnackBar(const SnackBar(
                      content: Text(
                    'Deleting Failed',
                    textAlign: TextAlign.center,
                  )));
                }
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
