import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:task01/core/config/api_client.dart';
import 'package:task01/core/constants/api_access.dart';
import 'package:task01/data/models/product/product_model.dart';

class ProductRepo {
      final apiclient = ApiClient();

//!_________________________________________________________________________________________get all product
Future<Either<String, List<ProductModel>>> getProductDetails() async {
  final url = ApiAccess.getProdect;

  try {
    final response = await apiclient.apiRequest(url, method: Method.get,);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      log('API Response: $responseData');

      final productList = responseData.map((item) => ProductModel.fromJson(item)).toList();
      log('Parsed Model: ${productList.map((product) => product.toJson())}');

      return Right(productList);
    } else {
      final errorResponse = jsonDecode(response.body);

      return left(errorResponse);
    }
  } catch (e) {
    return left('Exception: $e');
  }
}

}