import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopify1_app/providers/cart.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.datetime});
}

class Orders extends ChangeNotifier {
  List<OrderItem> _orders = [];
  String authToken;
  String userId;

  getData(String authTok, String userId, List<OrderItem> orders) {
    authToken = authTok;
    userId = userId;
    _orders = orders;
    notifyListeners();
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shopify1-2f53a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }

      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderdId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderdId,
          amount: orderData['amount'],
          datetime: DateTime.parse(
            orderData['datetime'],
          ),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    quantity: item['quantity'],
                    price: item['price'],
                    title: item['title'],
                  ))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        'https://shopify1-2f53a-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final timestamp = DateTime.now();

      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'datetime': timestamp.toIso8601String(),
            'product': cartProduct
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList(),
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(res.body)['name'],
              amount: total,
              datetime: timestamp,
              products: cartProduct));

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
