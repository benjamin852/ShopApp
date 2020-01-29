import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';

import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime time;

  OrderItem({
    this.id,
    this.amount,
    this.products,
    this.time,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  List<OrderItem> _orders = [];
  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    //copy move to new orders
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-app-a0242.firebaseio.com/orders.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
            id: orderId,
            amount: orderData['amount'],
            time: DateTime.parse(orderData['time']),
            products: (orderData['products'] as List<dynamic>)
                .map((product) => CartItem(
                      id: product['id'],
                      price: product['price'],
                      quantity: product['quantity'],
                      title: product['title'],
                    ))
                .toList()),
      );
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    });
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://shop-app-a0242.firebaseio.com/orders.json?auth=$authToken';
    final timeStamp = DateTime.now();
    //firebase id is generated by response
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'time': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cartProduct) => {
                  'id': cartProduct.id,
                  'title': cartProduct.title,
                  'quantity': cartProduct.quantity,
                  'price': cartProduct.price,
                })
            .toList()
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        //firebase id
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
