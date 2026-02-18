import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // The URL is injected at compile time.  This lets us build the app with a
  // relative base path (which works with a proxy) but also override it when
  // running on a device/emulator where `localhost` refers to the host machine.
  //
  // Example runs:
  //   flutter run -d chrome --dart-define=API_URL=https://...-5000.app.github.dev/api
  //   flutter run -d emulator --dart-define=API_URL=http://10.0.2.2:5000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://ideal-computing-machine-4jq7jjrj7jxg2q4w7-5000.app.github.dev/api',
  );

  // ============ PRODOTTI ============

  static Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Errore caricamento prodotti: $e');
      return [];
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      print('Errore caricamento categorie: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getProductsByCategory(String category) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/category/$category'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Errore caricamento prodotti categoria: $e');
      return [];
    }
  }

  // ============ ORDINI ============

  static Future<bool> createOrder(
      List<Map<String, dynamic>> items, double totalPrice) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'items': items,
          'total_price': totalPrice,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Ordine creato: ${data['order_number']}');
        return true;
      }
      return false;
    } catch (e) {
      print('Errore creazione ordine: $e');
      return false;
    }
  }
}
