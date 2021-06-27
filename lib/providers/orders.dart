import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import './cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders({this.authToken = "", orders, this.userId = ""});

  List<OrderItem> get orders {
    return [..._orders];
  }

  set orders(List<OrderItem>? newOrders) {
    _orders = newOrders ?? [];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((key, order) {
      loadedOrders.add(
        OrderItem(
          id: key,
          amount: order['amount'],
          products: (order['products'] as List<dynamic>)
              .map(
                (product) => CartItem(
                    id: product['id'],
                    title: product['title'],
                    quantity: product['quantity'],
                    price: product['price']),
              )
              .toList(),
          dateTime: DateTime.parse(order['dateTime']),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-course-shop-c8bf6-default-rtdb.europe-west1.firebasedatabase.app/orders/$userId.json?auth=$authToken');
    try {
      final dateTime = DateTime.now();
      final response = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((product) => {
                    'id': product.id,
                    'title': product.title,
                    'quantity': product.quantity,
                    'price': product.price
                  })
              .toList(),
          'dateTime': dateTime.toIso8601String(),
        }),
      );
      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: dateTime,
          ));
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
