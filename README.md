# inventory_app
Ranto Bastara Hamonangan Sitorus - 5025221228
Pemrograman Perangkat Bergerak B

## Deskripsi Tugas
Tugas ini kita diminta untuk mengeksplorasi teknologi **Mobile Database**, dimana saya mendapat teknologi **Hive**, namun pada tugas ini saya menggunakan Hive Community Edition.

## Deskripsi Aplikasi
Pada Tugas ini saya membuat aplikasi management inventori, dimana aplikasi ini mengambil data produk dari API yang telah diberikan, dan kita bisa menambah produk tersebut ke inventori kita, selain itu kita bisa menambah jumlah produk, mengurangi jumlah produk, dan bisa menghapus produk itu dari inventory kita.

## Tahapan Pengerjaan
### 1. Persiapan
### 1.1 Membuat projek flutter
Disini saya membuat project flutter dengan command line, command yang saya masukkan:
```
flutter create inventory_app
```

### 1.2 Menginstall Hive Community Edition
pada terminal di root folder project yang sudah dibuat, kita bisa mengeksekusi command:
```
flutter pub add hive_ce hive_ce_flutter dev:hive_ce_generator dev:build_runner
```
Setelah command dijalankan pada file `pubspec.yaml`, akan ada tambahan dependencies sebagai berikut:
```yaml
dependencies:
  hive_ce: ^2.10.1
  hive_ce_flutter: ^2.2.0
  
dev_dependencies:
  hive_ce_generator: ^1.8.2
  build_runner: ^2.4.15
```

### 1.3 Menginstall Http
Pada tugas ini saya mengambil data produk dari API [dummyjson](https://dummyjson.com/). Untuk bisa berkomunikasi dengan API nya, kita harus menginstall package http dengan menjalankan command:
```
flutter pub add http
```
dan `pubspec.yaml` kita akan menjadi seperti ini:
```yaml
dependencies:
  hive_ce: ^2.10.1
  hive_ce_flutter: ^2.2.0
  http: ^1.3.0    
  
dev_dependencies:
  hive_ce_generator: ^1.8.2
  build_runner: ^2.4.15
```

### 2. Membuat Aplikasi tanpa menggunakan DB
Pada aplikasi ini, kita berfokus pada 2 pages, order dan inventory.

Order page akan melakukan fecth data dari API yang telah ditentukan dan user dapat menambahkan produk ke inventory.

Pada Inventory page, user dapat mengupdate stok dan menghapus produk.

disini kita membuat 5 file dart:
1. product.dart:
    Kita mendeklarasikan kelas `Product` dimana untuk men-desiralisasi data JSON yang kita terima dari API.
2. product_list.dart:
    Untuk menampilkan produk pada page order, kita menggunakan widget `ProductList`. Widget ini akan me-return `ListView` yang menampilkan semua produk.
3. order_page.dart:
    Order Page akan menjadi start page untuk aplikasi ini. pada page ini kita akan melakukan fetch 10 produk dari API yang telah kita tentukan dan menampilkannya menggunakan widget `ProductList`.
4. inventory_page.dart:
    Inventory page akan melakukan fetch data dari database local (Hive).
5. main.dart:
    Pada file `main.dart`, kita me-return widget `OrderPage` dan membuat skema warnanya menjadi biru.

### 3. Implementasi database Hive pada aplikasi
### 3.1 Membuat Hive box
Sebuah box pada Hive simplenya adalah tabel pada database, setiap box harus memiliki nama yang unik.

`hive_boxes.dart`
```dart
const productBox = 'product_box'
```
Setelah membuat box nya kita harus menambahkan kode berikut di main.dart:
```dart
Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox<Product>(productBox);

  runApp(const MyApp());
}
```

### 3.2 Generate Type Adapters secara otomatis menggunakan GenerateAdapters (Hive CE)
untuk melakukan generate type adapters secara otomatis, bisa mulai dari membuat file `hive` dibawah `lib` direktori pada project, lalu buat file `hive_adapters.dart`.

`hive_adapters.dart`
```dart
import 'package:hive_ce/hive.dart';
import 'package:hive_database_demo/product.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<Product>(),
  AdapterSpec<Categories>(),
])

class HiveAdapters {}
```

setelah itu kita harus menyesuaikan kelas Produk untuk di extend dengan `HiveObject`
```dart
class Product extends Hive Project {}
```

setelah itu kita lakukan eksekusi command:
```
dart run build_runner build --delete-conflicting-outputs
```

setelah command berhasil akan ada beberapa file baru pada folder `hive/`

### 3.3 Register Hive Type Adapters
Register adapters harus dilakukan setelah fungsi `initFlutter` dan sebelum operasi Hive, seperti `openBox`.

`main.dart`
```dart
Future<void> main() async {
  await Hive.initFlutter();
  
  Hive.registerAdapters(); //hanya bisa di Hive CE
  
  await Hive.openBox<Product>(productBox);

  runApp(const MyApp());
}
```
### 4. Membuat Fitur CRUD
### 4.1 menyimpan 'records' pada database local Hive
untuk menyimpan data pada database kita tinggal menjalankan function `box.add(product)`

ini kita implementasikan pada kode
`product_list.dart`
```dart
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_database_demo/hive_boxes.dart';
import 'package:hive_database_demo/product.dart';

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
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('(${product.stock}) \$${product.price.toString()}'),
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
```

### 4.2 Update 'records' pada database Hive
Pada Database Hive, kita bisa menyimpan perubahan pada data dengan fungsi `productBox.put(product.key, product)` atau kita bisa gunakan `product.save()`

ini kita implementasikan pada kode
`inventory_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hive_database_demo/hive_boxes.dart';
import 'package:hive_database_demo/product.dart';

class InventoryPage extends StatefulWidget {
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
    product.stock--;
    productBox.put(product.key, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: ValueListenableBuilder<Box<Product>>(
        valueListenable: Hive.box<Product>(productBox).listenable(),
        builder: (BuildContext context, Box<Product> box, Widget? _) {
          final products = box.values.toList();

          if (products.isEmpty) {
            return const Center(
              child: Text('The inventory is currently empty.'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              final product = products.toList()[index];

              return ListTile(
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
                            : () => _decrement(box, product),
                        icon: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```
### 4.3 Menghapus 'records' pada database Hive
Pada Database Hive, kita bisa menghapus data dengan fungsi `box.delete(product.key)`, atau kalau menggunakan ekstension `HiveObject`, kita bisa menggunakan `product.delete()`.

ini kita implementasikan pada kode
`inventory_page.dart`
```dart
floatingActionButton: FloatingActionButton(
        onPressed: Hive.box<Product>(productBox).clear,
        child: const Icon(
          Icons.delete,
          size: 35,
        ),
      ),

  return Dismissible(
                key: ValueKey(product.id),
                onDismissed: (DismissDirection direction) =>
                    box.delete(product.key),
                background: const ColoredBox(color: Colors.red),
                child: ListTile(
```

## Referensi
[onlyflutter.com](https://onlyflutter.com/how-to-add-a-local-database-using-hive-in-flutter/)