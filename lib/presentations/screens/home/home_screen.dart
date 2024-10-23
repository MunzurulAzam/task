import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task01/core/config/routes/app_routes.dart';
import 'package:task01/core/constants/colors/app_colors.dart';
import 'package:task01/core/utils/size_config.dart';
import 'package:task01/data/models/product/product_model.dart';
import 'package:task01/logic/providers/home/home_provider.dart';
import 'package:task01/logic/providers/cart/cart_provider.dart';
import 'package:task01/presentations/widgets/custom_grid_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _status = 'Checking...';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.read(homeProvider.notifier).fetchAllProductDetails();
    ref.read(cartProvider.notifier).syncCartData();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    String status = 'Checking...';
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty) {
        status = connectivityResult == ConnectivityResult.mobile ? 'Connected to Mobile Network' : 'Connected to WiFi';
      } else {
        status = 'Limited or No Internet Access';
      }
    } on SocketException catch (_) {
      status = 'Limited or No Internet Access';
    } finally {
      setState(() {
        _status = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Product List', style: TextStyle(color: AppColors.kBlackColor)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, RouteName.cartScreen);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _status,
              style: TextStyle(fontSize: getFontSize(14), color: AppColors.kErrorColor),
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.productModel == null
                    ? const Center(child: Text('No products found'))
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: getScreenWidth(15)),
                        child: CustomGridView(
                          padding: EdgeInsets.only(bottom: getScreenHeight(30), top: getScreenHeight(10)),
                          cellHeight: getScreenHeight(110),
                          cellWidth: getScreenWidth(55),
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.productModel!.length,
                          itemBuilder: (context, index) {
                            final product = controller.productModel![index];
                            return ProductCard(
                              imageUrl: product.image ?? '',
                              title: product.title ?? '',
                              price: product.price ?? 0.0,
                              product: product,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

//!_________________________________________________________________________product card

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final ProductModel product;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getBorderRadius(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(getBorderRadius(15))),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Icon(Icons.image, size: getScreenHeight(50)));
                },
              ),
            ),
          ),
          getVerticalSpace(10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getScreenWidth(8.0)),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: getFontSize(16)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          getVerticalSpace(10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getScreenWidth(8.0)),
            child: Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: getFontSize(14), color: AppColors.kgreenColor),
            ),
          ),
          getVerticalSpace(10),
          Consumer(
            builder: (context, ref, _) {
              return Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider).addProduct(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title ?? "Product"} added to cart!'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref.read(cartProvider).removeProduct(product);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              );
            },
          ),
          getVerticalSpace(10)
        ],
      ),
    );
  }
}
