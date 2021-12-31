import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopify1_app/models/http_exeptions.dart';
import 'dart:convert';

import 'package:shopify1_app/providers/product.dart';

class Products extends ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];
  String authToken;
  String userId;
  getData(String authTok, String userId, List<Product> products) {
    authToken = authTok;
    userId = userId;
    _items = products;
    notifyListeners();
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite);
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filteredString =
        filterByUser ? 'orderBy="creatorId"&equalTo"$userId"' : '';
    var url =
        'https://shopify1-2f53a-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filteredString';
    try {
      final res = await http.get(url);
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://shopify1-2f53a-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authToken';
      final favRes = await http.get(url);
      final favData = json.decode(favRes.body);

      final List<Product> loadedProductes = [];

      extractedData.forEach((prodId, prodData) {
        loadedProductes.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: favData == null ? false : favData[prodId] ?? false,
          imageUrl: prodData['imaUrl'],
        ));
      });
      _items = loadedProductes;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https:shopify1-2f53a-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final res = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imgUrl': product.imageUrl,
            'price': product.price,
            'creatId': userId
          }));
      final newProduct = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https:shopify1-2f53a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imgUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProd(String id) async {
    final url =
        'https:shopify1-2f53a-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProduct);
      notifyListeners();
      throw HttpExeption("could not delete this item");
    }
    existingProduct = null;
  }
}
/*
 Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https:cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),*/