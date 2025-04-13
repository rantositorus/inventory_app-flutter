import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:inventory_app/hive_boxes.dart';
import 'package:inventory_app/product.dart';

class InventoryPage extends StatefulWidget{
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  void _increment(Box<Product> productBox, Product product) {
    product.stock++;
    productBox.put(product.key, product);
  }

  void _decrement(Box<Product> productBox, Product product) {
    if (product.stock > 0) {
      product.stock--;
      productBox.put(product.key, product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: Hive.box<Product>(productBox).clear,
        child: const Icon(
          Icons.delete,
          size: 35,
        ),
      ),
      body: ValueListenableBuilder<Box<Product>>(
        valueListenable: Hive.box<Product>(productBox).listenable(),
        builder: (BuildContext context, Box<Product> box, Widget? _) {
          final products = box.values.toList();

          if(products.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products.toList()[index];

                return Dismissible(
                  key: ValueKey(product.id),
                  onDismissed: (DismissDirection direction) =>
                    box.delete(product.key),
                  background: const ColoredBox(color: Colors.red),
                  child: ListTile(
                    leading: Text(
                      product.stock.toString(),
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(product.title),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _increment(box, product),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: product.stock == 0
                              ? null
                              : () => _decrement(box, product) ,
                            icon: const Icon(Icons.remove),
                          )
                      ],
                    ),
                  ),
                  )  
                );
              },
          );
        }
      )
    );
  }
}