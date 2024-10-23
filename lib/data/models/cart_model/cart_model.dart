import 'package:task01/data/models/product/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price! * quantity;
}

class CartModel {
  List<CartItem> items = [];

  double get totalCost => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
