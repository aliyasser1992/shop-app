import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;

class OrderItems extends StatelessWidget {
  final ord.OrderItem order;

  OrderItems(this.order);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ExpansionTile(
        title: Text('\$${order.amount}'),
        subtitle: Text(DateFormat('dd/MM/yyyy hh:mm').format(order.datetime)),
        children: order.products
            .map((prod) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prod.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${prod.quantity}* \$${prod.price}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    )
                  ],
                ))
            .toList(),
      ),
    );
  }
}
