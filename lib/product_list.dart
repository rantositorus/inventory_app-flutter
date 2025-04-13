import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:inventory_app/hive_boxes.dart';
import 'package:inventory_app/product.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    required this.products,
    super.key,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Product>>(
      valueListenable: Hive.box<Product>(productBox).listenable(),
      builder: (BuildContext context, Box<Product> box, Widget? _) =>
          ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          final product = Product.fromJson(products[index].toJson());

          final matchingProduct = box.values.where((Product existingProduct) {
            return existingProduct.id == product.id;
          }).firstOrNull;

          final isReceived = matchingProduct != null;

          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul produk dan kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(product.category.name),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  // Stok, harga, dan tombol Add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock: ${products[index].stock} | \$${products[index].price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: isReceived ? null : () => box.add(product),
                        child: isReceived
                            ? const Text('Received')
                            : const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
