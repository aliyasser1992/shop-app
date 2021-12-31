import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopify1_app/widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/cart_item.dart' as OrderItem;

import '../providers/orders.dart' show OrderItem, Orders;

class OrderScreen extends StatelessWidget {
  static const routName = '/order_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('your orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.error != null) {
              return const Center(
                child: Text('an error occuard'),
              );
            } else {
              return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (BuildContext context, int index) =>
                            OrderItems(orderData.orders[index]),
                      ));
            }
          }
        },
      ),
    );
  }
}
