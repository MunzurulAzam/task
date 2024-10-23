import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:task01/data/models/product/product_model.dart';
import 'package:task01/data/repository/product/product_repo.dart';

class HomeProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  HomeProvider(this.productRepo);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<ProductModel>? _productModel;
  List<ProductModel>? get productModel => _productModel;



  //!_________________________________________________________________________________________get all product

Future<void> fetchAllProductDetails({String? token, String? slag}) async {
  _isLoading = true;


  var box = await Hive.openBox<ProductModel>('products');
  _productModel = box.values.toList();

  final connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult != ConnectivityResult.none && _productModel!.isEmpty) {

    final result = await productRepo.getProductDetails();
    result.fold(
      (err) {
        _error = err;
        _productModel = null;
        log('Error: $err');
      },
      (data) async {
        _error = null;
        _productModel = data;


        await box.clear();
        await box.addAll(data);

        log('Successfully added products to Hive: ${data.map((product) => product.toJson()).toList()}');

        var storedProducts = box.values.toList();
        log('Stored Products in Hive: ${storedProducts.map((product) => product.toJson()).toList()}');
      },
    );
  } else {
    log('Loading data from Hive: ${_productModel!.map((product) => product.toJson()).toList()}');
  }

  _isLoading = false;
  notifyListeners();
}

}


final homeProvider = ChangeNotifierProvider<HomeProvider>((ref) => HomeProvider(ProductRepo()));
