enum Categories {
  beauty,
  fragrance
}

class Product {
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.stock,
  });

  final int id;
  final String title;
  final double price;
  final Categories category;
  int stock;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      category: Categories.values.byName(json['category']),
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'category': category.name,
      'stock': stock,
    };
  }
}