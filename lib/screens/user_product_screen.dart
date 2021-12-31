import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/widgets/app_drawer.dart';
import 'package:shopify1_app/widgets/user_product_item.dart';
import '../providers/products.dart';
import './edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routName = '/user_productscreen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routName),
          )
        ],
      ),
      body: FutureBuilder(
          future: _refreshProducts(context),
          builder: (ctx, AsyncSnapshot snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      child: Consumer<Products>(
                          builder: (ctx, productsData, _) => Padding(
                                padding: const EdgeInsets.all(8),
                                child: ListView.builder(
                                  itemCount: productsData.items.length,
                                  itemBuilder: (_, int index) => Column(
                                    children: [
                                      UserProductItem(
                                        productsData.items[index].id,
                                        productsData.items[index].title,
                                        productsData.items[index].imageUrl,
                                      ),
                                      const Divider()
                                    ],
                                  ),
                                ),
                              )),
                      onRefresh: () => _refreshProducts(context))),
    );
  }
}
