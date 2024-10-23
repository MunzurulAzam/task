import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:task01/data/models/cart_model/cart_model.dart';
import 'package:task01/data/models/product/product_model.dart';

class CartProvider extends ChangeNotifier {
  CartModel _cart = CartModel();
  bool _isLoading = false;

  CartModel get cart => _cart;
  bool get isLoading => _isLoading;

  CartProvider() {
    _loadCartFromHive();
  }

  Future<void> _loadCartFromHive() async {
    var box = await Hive.openBox<ProductModel>('cart');
    _cart.items = box.values
        .map((product) => CartItem(product: product, quantity: 1)) 
        .toList();
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();

    final existingItem = _cart.items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product),
    );

    //!_______________________________________________ Add product to local cart
    if (_cart.items.contains(existingItem)) {
      existingItem.quantity++;
    } else {
      _cart.items.add(existingItem);
    }

    var box = await Hive.openBox<ProductModel>('cart');
    await box.put(product.id, product);

    await syncCartData();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeProduct(ProductModel product) async {
    _cart.items.removeWhere((item) => item.product.id == product.id);

    var box = await Hive.openBox<ProductModel>('cart');
    await box.delete(product.id); 

    await syncCartData();

    notifyListeners();
  }

  Future<void> syncCartData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        var box = await Hive.openBox<ProductModel>('cart');

        final cartItemsFromHive = _cart.items;

        final syncedCartItems = await syncCartItemsToServer(cartItemsFromHive);

        await box.clear();
        await box.addAll(syncedCartItems.map((item) => item.product).toList());
      } catch (e) {
        log('Error syncing cart data: $e', name: 'CartProvider Error');

      }
    }
  }

  Future<List<CartItem>> syncCartItemsToServer(List<CartItem> cartItems) async {

    return cartItems;
  }

  void updateProductQuantity(ProductModel product, int quantity) {
    final cartItem = _cart.items.firstWhere((item) => item.product.id == product.id);
    cartItem.quantity = quantity;

    if (quantity == 0) {
      _cart.items.remove(cartItem);
    }

    notifyListeners();
  }

  void clearCart() {
    _cart.items.clear();
    notifyListeners();
  }
}

final cartProvider = ChangeNotifierProvider((ref) => CartProvider());