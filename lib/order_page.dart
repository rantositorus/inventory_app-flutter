import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:inventory_app/product.dart';
import 'package:inventory_app/product_list.dart';
import 'package:inventory_app/inventory_page.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget{
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Product> products = <Product>[];

  @override
  void initState() {
    super.initState();
    _getOrder();
  }

  Future<void> _getOrder() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products?limit=10'));

    if (response.statusCode == 200) {
      final bodyJson = (jsonDecode(response.body) as Map).cast<String, dynamic>();
      final productsJson = bodyJson['products'] as List;

      setState(() => products = productsJson
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const InventoryPage(),
              ),
            ),
            icon: const Icon(Icons.inventory_2_outlined),
          )
        ]
      ),
      backgroundColor: Colors.white,
      body: ProductList(products: products),
    );
  }
}