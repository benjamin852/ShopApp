import 'package:flutter/foundation.dart';
import 'package:shop_app/providers/cart.dart';

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
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    //copy move to new orders
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    //add at beginning of list
    _orders.insert(
      0,
      OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
