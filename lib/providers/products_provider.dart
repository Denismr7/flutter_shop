import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products({this.authToken = "", items, this.userId = ""});

  List<Product> get items {
    return [..._items];
  }

  set items(List<Product>? newItems) {
    _items = newItems ?? [];
  }

  List<Product> get getFavorites {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterQuery =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : "";
    var url = Uri.parse(
        'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken$filterQuery');
    try {
      final response = await http.get(url);
      if (response.body == 'null') {
        return;
      }
      url = Uri.parse(
          'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');
      final favoritesResponse = await http.get(url);
      final favoriteData = json.decode(favoritesResponse.body);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, productData) {
        loadedProducts.add(Product(
          id: key,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: favoriteData == null ? false : favoriteData[key] ?? false,
        ));
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'creatorId': userId
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == product.id);
    if (prodIndex < 0) {
      return;
    }
    final url = Uri.parse(
        'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/products/${product.id}.json?auth=$authToken');
    try {
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));
      _items[prodIndex] = product;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/products/$id.json');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    return http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Error deleting product');
      }
      existingProduct = null;
    }).catchError((_) {
      if (existingProduct != null) {
        _items.insert(existingProductIndex, existingProduct as Product);
        notifyListeners();
      }
    });
  }
}
