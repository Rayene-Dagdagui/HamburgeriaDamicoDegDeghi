import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<String>> categories;
  late Future<List<dynamic>> products;
  String selectedCategory = '';
  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    categories = ApiService.getCategories();
    products = ApiService.getProducts();
  }

  void _addToCart(Map<String, dynamic> product) {
    final existingItem = cart.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      existingItem['quantity'] = (existingItem['quantity'] ?? 1) + 1;
    } else {
      cart.add({
        'product_id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} aggiunto al carrello'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: () {
                  if (cart.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(cartItems: cart),
                      ),
                    );
                  }
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorie
          FutureBuilder<List<String>>(
            future: categories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Errore caricamento categorie'),
                );
              }

              final cats = snapshot.data!;
              if (selectedCategory.isEmpty && cats.isNotEmpty) {
                selectedCategory = cats[0];
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: cats
                      .map((cat) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: FilterChip(
                              label: Text(cat),
                              selected: selectedCategory == cat,
                              onSelected: (selected) {
                                setState(() {
                                  selectedCategory = cat;
                                });
                              },
                              backgroundColor: Colors.grey[200],
                              selectedColor: const Color(0xFF667eea),
                              labelStyle: TextStyle(
                                color: selectedCategory == cat
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              );
            },
          ),

          // Prodotti
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Errore caricamento prodotti'));
                }

                final allProducts = snapshot.data!;
                final filteredProducts = selectedCategory.isEmpty
                    ? allProducts
                    : allProducts
                        .where((p) => p['category'] == selectedCategory)
                        .toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('Nessun prodotto in questa categoria'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onAddToCart: () => _addToCart(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Immagine o placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: product['image_url'] != null
                ? Image.network(
                    product['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Center(child: Text('🖼️', style: TextStyle(fontSize: 30))),
                  )
                : const Center(child: Text('🍔', style: TextStyle(fontSize: 40))),
          ),

          // Info prodotto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product['description'] != null && product['description'].isNotEmpty)
                    Text(
                      product['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '€${product['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF667eea),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pulsante
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Aggiungi'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
