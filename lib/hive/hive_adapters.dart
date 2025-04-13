import 'package:hive_ce/hive.dart';
import 'package:inventory_app/product.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<Product>(),
  AdapterSpec<Categories>(),
])

class HiveAdapters {}