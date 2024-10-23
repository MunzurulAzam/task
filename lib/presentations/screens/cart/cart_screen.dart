import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task01/core/utils/size_config.dart';
import 'package:task01/logic/providers/cart/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: cart.cart.items.isEmpty
          ? const Center(
              child: Text('Your cart is empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.cart.items[index];
                      return ListTile(
                        leading: SizedBox(
                          height: getScreenHeight(40),
                          width: getScreenWidth(40),
                          child: Image.network(item.product.image!, errorBuilder: (context, error, stackTrace) {
                            return  Icon(Icons.image, size: getScreenHeight(40));
                          },),
                        ),
                        title: Text(item.product.title!, maxLines: 2, overflow: TextOverflow.ellipsis,),
                        subtitle: Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                ref.read(cartProvider).updateProductQuantity(item.product, item.quantity - 1);
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                ref.read(cartProvider).updateProductQuantity(item.product, item.quantity + 1);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref.read(cartProvider).removeProduct(item.product);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Total Items: ${cart.cart.totalItems}'),
                      Text('Total Cost: \$${cart.cart.totalCost.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
