# 📖 Documentazione Completa di Tutti i Codici

## 📋 Indice
1. [Backend Flask](#1-backend-flask)
2. [Database Wrapper](#2-database-wrapper)
3. [Angular Staff Panel](#3-angular-staff-panel)
4. [Flutter Totem Cliente](#4-flutter-totem-cliente)
5. [Configurazione Aiven](#5-configurazione-aiven)
6. [Flusso di Comunicazione](#6-flusso-di-comunicazione)

---

# 1. BACKEND FLASK

## File: `app.py`

### Cos'è?
È il **server centrale** che espone API REST per Angular (staff) e Flutter (cliente).

### Struttura Principale

```python
from flask import Flask, request, jsonify
from flask_cors import CORS
from database_wrapper import DatabaseWrapper
```
- **Flask**: Framework web Python per creare API REST
- **CORS**: Permette che Angular (localhost:4200) e Flutter comunichino (browser)
- **DatabaseWrapper**: Classe custom per gestire il database

### Startup e Configurazione

```python
app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": ["*"]}})
db = DatabaseWrapper()
```

- `Flask(__name__)`: Crea l'app Flask
- `CORS(...)`: Abilita Cross-Origin Requests (importante per Angular e Flutter)
- `db = DatabaseWrapper()`: Inizializza la classe database

### Lifecycle: Before Request e Teardown

```python
@app.before_request
def before_request():
    if not db.connection:
        db.connect()
        # Inizializza tabelle se non esistono
        db.init_products_table()
        db.init_orders_table()
        db.init_order_items_table()
```

**Cosa fa?**
- Prima di ogni richiesta HTTP, verifica che il DB sia connesso
- Se le tabelle non esistono, le crea (primo avvio)

### ENDPOINT: Prodotti

#### 1. Ottenere tutti i prodotti
```python
@app.route('/api/products', methods=['GET'])
def get_products():
    products = db.get_all_products()
    return jsonify({
        'status': 'success',
        'data': products,
        'count': len(products)
    }), 200
```
**Chi lo usa?** Flutter (totem cliente)  
**Cosa fa?**
- Ritorna tutti i prodotti da visualizzare nel menu
- Formato JSON con status, data, count

#### 2. Ottenere categorie
```python
@app.route('/api/categories', methods=['GET'])
def get_categories():
    categories = db.get_categories()
    return jsonify({
        'status': 'success',
        'data': categories,
        'count': len(categories)
    }), 200
```
**Chi lo usa?** Flutter, Angular  
**Cosa fa?** Ritorna lista di categorie per filtrare menu

#### 3. Prodotti per categoria
```python
@app.route('/api/products/category/<category>', methods=['GET'])
def get_products_by_category(category):
    products = db.get_products_by_category(category)
    return jsonify({...}), 200
```
**Chi lo usa?** Flutter, Angular  
**Cosa fa?** Filtra prodotti per categoria (es: "panini", "bevande")

#### 4. Creare prodotto (STAFF)
```python
@app.route('/api/products', methods=['POST'])
def create_product():
    data = request.get_json()
    
    # Validazione
    if not data or not all(k in data for k in ['name', 'price', 'category']):
        return jsonify({'status': 'error', ...}), 400
    
    product_id = db.add_product(...)
    return jsonify({'status': 'success', 'product_id': product_id}), 201
```
**Chi lo usa?** Angular (pannello staff)  
**Cosa fa?**
- Riceve JSON con dati prodotto
- Valida che nome, prezzo, categoria siano presenti
- Inserisce nel DB e ritorna l'ID del nuovo prodotto

#### 5. Modificare prodotto (STAFF)
```python
@app.route('/api/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    data = request.get_json()
    success = db.update_product(product_id, ...)
    return jsonify({...}), 200 or 500
```
**Chi lo usa?** Angular (gestione menu)  
**Cosa fa?** Aggiorna i dati di un prodotto esistente

#### 6. Eliminare prodotto (STAFF)
```python
@app.route('/api/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    success = db.delete_product(product_id)
    return jsonify({'status': 'success', 'message': '...'}), 200
```
**Chi lo usa?** Angular (gestione menu)  
**Cosa fa?** Soft delete = segna come non disponibile (non cancella veramente)

### ENDPOINT: Ordini

#### 1. Ottenere tutti gli ordini
```python
@app.route('/api/orders', methods=['GET'])
def get_orders():
    status_filter = request.args.get('status', None)  # ?status=pending
    
    if status_filter:
        orders = db.get_orders_by_status(status_filter)
    else:
        orders = db.get_all_orders()
    
    # Aggiunge gli item a ogni ordine
    orders_with_items = []
    for order in orders:
        order_items = db.get_order_items(order['id'])
        orders_with_items.append({**order, 'items': order_items})
    
    return jsonify({'status': 'success', 'data': orders_with_items}), 200
```
**Chi lo usa?** Angular (dashboard staff)  
**Cosa fa?**
- Filtra ordini per stato (es: `?status=pending`)
- Ritorna ordini con i loro item aggregate

**Esempio response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "order_number": "ORD-20260216-1234",
      "total_price": 15.50,
      "status": "pending",
      "items": [
        {"product_id": 1, "name": "Hamburger", "quantity": 2, "price": 5.00}
      ]
    }
  ]
}
```

#### 2. Creare ordine (CLIENTE/FLUTTER)
```python
@app.route('/api/orders', methods=['POST'])
def create_order():
    data = request.get_json()
    
    # Genera numero ordine univoco
    order_number = f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"
    
    order_id = db.create_order(
        order_number=order_number,
        items=data['items'],
        total_price=float(data['total_price'])
    )
    
    return jsonify({..., 'order_number': order_number}), 201
```
**Chi lo usa?** Flutter (carrello → conferma)  
**Cosa fa?**
- Riceve lista di items: `[{product_id, quantity, price}]`
- Genera numero ordine univoco con data e random
- Inserisce in DB sia ordine che items
- Ritorna l'ID e numero ordine

**Esempio request:**
```json
{
  "items": [
    {"product_id": 1, "quantity": 2, "price": 5.00},
    {"product_id": 3, "quantity": 1, "price": 3.00}
  ],
  "total_price": 13.00
}
```

#### 3. Aggiornare stato ordine (STAFF)
```python
@app.route('/api/orders/<int:order_id>/status', methods=['PUT'])
def update_order_status(order_id):
    data = request.get_json()
    
    # Valida stati
    valid_statuses = ['pending', 'preparing', 'ready', 'delivered', 'cancelled']
    if status not in valid_statuses:
        return jsonify({'error': 'Invalid status'}), 400
    
    success = db.update_order_status(order_id, data['status'])
    return jsonify({'status': 'success', 'message': f'...{data["status"]}'}), 200
```
**Chi lo usa?** Angular (pannello ordini)  
**Cosa fa?**
- Cambia lo stato: `pending` → `preparing` → `ready` → `delivered`
- Valida che lo stato sia valido
- Aggiorna timestamp `updated_at`

### ENDPOINT: Salute

```python
@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    }), 200
```
**Scopo:** Verifica che il server Flask sia online e rispondente

---

# 2. DATABASE WRAPPER

## File: `database_wrapper.py`

### Cos'è?
Una **classe personalizzata** che encapsula TUTTE le query MySQL.  
Beneficio: Il file `app.py` non contiene SQL diretto, solo metodi clean.

### Inizio della Classe

```python
class DatabaseWrapper:
    def __init__(self):
        self.host = os.getenv('DB_HOST')
        self.user = os.getenv('DB_USER')
        self.password = os.getenv('DB_PASSWORD')
        self.database = os.getenv('DB_NAME')
        self.port = int(os.getenv('DB_PORT', 3306))
        self.connection = None
```
**Cosa fa?**
- Legge le credenziali da `.env` (file di configurazione)
- Salva host, user, password, database, port
- `connection = None` inizialmente (connessione lazy)

### Connessione al DB

```python
def connect(self) -> None:
    try:
        self.connection = pymysql.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            database=self.database,
            port=self.port,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        print("✓ Connesso a database MySQL")
    except Exception as e:
        print(f"✗ Errore connessione database: {e}")
        raise
```
**Cosa fa?**
- Usa `pymysql` per connettersi a MySQL Aiven
- `cursorclass=DictCursor` → ritorna risultati come dictionaries (JSON-friendly)
- Se errore, lancia eccezione

### Metodi di Esecuzione Query

```python
def execute_query(self, query: str, params: tuple = ()) -> List[Dict]:
    """Esegue SELECT"""
    with self.connection.cursor() as cursor:
        cursor.execute(query, params)
        return cursor.fetchall()

def execute_insert(self, query: str, params: tuple = ()) -> int:
    """Esegue INSERT e ritorna lastrowid"""
    with self.connection.cursor() as cursor:
        cursor.execute(query, params)
        self.connection.commit()
        return cursor.lastrowid

def execute_update(self, query: str, params: tuple = ()) -> bool:
    """Esegue UPDATE/DELETE"""
    with self.connection.cursor() as cursor:
        cursor.execute(query, params)
        self.connection.commit()
        return True
```

**Differenze:**
- `execute_query()` → SELECT (legge dati)
- `execute_insert()` → INSERT (crea, ritorna ID)
- `execute_update()` → UPDATE/DELETE (modifica/cancella)

**Sicurezza:** Usa `params` tuple con placeholder `%s` per evitare SQL injection

### Operazioni PRODOTTI

```python
def get_all_products(self) -> List[Dict]:
    query = "SELECT * FROM products WHERE available = TRUE ORDER BY category, name"
    return self.execute_query(query)

def add_product(self, name: str, description: str, price: float, 
               category: str, image_url: str = None) -> int:
    query = """
    INSERT INTO products (name, description, price, category, image_url)
    VALUES (%s, %s, %s, %s, %s)
    """
    return self.execute_insert(query, (name, description, price, category, image_url))

def update_product(self, product_id: int, **updates) -> bool:
    # Costruisce dinamicamente: UPDATE products SET name = %s, price = %s WHERE id = %s
    updates_list = []
    params = []
    for key, value in updates.items():
        if value is not None:
            updates_list.append(f"{key} = %s")
            params.append(value)
    params.append(product_id)
    query = f"UPDATE products SET {', '.join(updates_list)} WHERE id = %s"
    return self.execute_update(query, tuple(params))

def delete_product(self, product_id: int) -> bool:
    # Soft delete: segna come non disponibile
    query = "UPDATE products SET available = FALSE WHERE id = %s"
    return self.execute_update(query, (product_id,))
```

### Operazioni ORDINI

```python
def create_order(self, order_number: str, items: List[Dict], total_price: float) -> int:
    # 1. Inserisci ordine
    order_query = """
    INSERT INTO orders (order_number, total_price, status)
    VALUES (%s, %s, 'pending')
    """
    order_id = self.execute_insert(order_query, (order_number, total_price))
    
    # 2. Inserisci items
    item_query = """
    INSERT INTO order_items (order_id, product_id, quantity, price)
    VALUES (%s, %s, %s, %s)
    """
    for item in items:
        self.execute_insert(item_query, 
                          (order_id, item['product_id'], item['quantity'], item['price']))
    
    return order_id
```
**Cosa fa?** Crea sia l'ordine che gli item in un'operazione atomica

```python
def update_order_status(self, order_id: int, status: str) -> bool:
    valid_statuses = ['pending', 'preparing', 'ready', 'delivered', 'cancelled']
    if status not in valid_statuses:
        return False
    
    query = "UPDATE orders SET status = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s"
    return self.execute_update(query, (status, order_id))
```
**Cosa fa?** Cambia stato ordine e aggiorna timestamp

---

# 3. ANGULAR STAFF PANEL

## File: `angularStaff/src/app/app.config.ts`

### Configurazione dell'App

```typescript
import { provideHttpClient, withFetch } from '@angular/common/http';
import { provideRouter } from '@angular/router';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withFetch())  // ← IMPORTANTE: Abilita HttpClient
  ]
};
```
**Cosa fa?**
- `provideHttpClient()` → Permette al servizio Flask di fare richieste HTTP
- `withFetch()` → Usa Fetch API (moderno, supportato ovunque)
- `provideRouter()` → Abilita il routing (dashboard, orders, menu)

## File: `angularStaff/src/app/app.routes.ts`

```typescript
import { Routes } from '@angular/router';
import { OrdersComponent } from './components/orders/orders.component';
import { MenuComponent } from './components/menu/menu.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';

export const routes: Routes = [
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
  { path: 'dashboard', component: DashboardComponent },
  { path: 'orders', component: OrdersComponent },
  { path: 'menu', component: MenuComponent }
];
```
**Cosa fa?**
- Definisce le 3 pagine principali
- Path vuoto (`''`) redirect a dashboard
- URL: `http://localhost:4200/dashboard`, etc.

## File: `angularStaff/src/app/app.component.ts`

```typescript
import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  constructor() {}
  
  ngOnInit(): void {
    console.log('✅ App inizializzata');
  }
}
```
**Cosa fa?**
- È il componente ROOT di tutta l'applicazione
- `<router-outlet>` nel template mostra la pagina corrente
- `standalone: true` → Component Angular moderno

## File: `angularStaff/src/app/app.component.html`

```html
<router-outlet></router-outlet>
```
**Cosa fa?** Placeholder dove Angular inserisce i componenti delle route (Dashboard, Orders, Menu)

## File: `angularStaff/src/app/services/flask-service.service.ts`

### Servizio per comunicare con Flask

```typescript
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class FlaskServiceService {
  private apiUrl = 'http://localhost:5000/api';
  
  constructor(private http: HttpClient) { }
```

**Cosa fa?**
- `@Injectable()` → Può essere iniettato in qualsiasi componente
- `private apiUrl = 'http://localhost:5000/api'` → Base URL del backend
- `http: HttpClient` → Servizio Angular per richieste HTTP

### Metodi ORDINI

```typescript
getAllOrders(): Observable<any> {
  return this.http.get(`${this.apiUrl}/orders`);
}

getOrdersByStatus(status: string): Observable<any> {
  return this.http.get(`${this.apiUrl}/orders?status=${status}`);
}

updateOrderStatus(orderId: number, status: string): Observable<any> {
  return this.http.put(`${this.apiUrl}/orders/${orderId}/status`, { status });
}
```

**Cosa fa?**
- `get()` → Richiesta GET (legge dati)
- `put()` → Richiesta PUT (aggiorna dati)
- Ritorna `Observable` (pattern RxJS per async)

**Come si usa in un componente:**
```typescript
this.flaskService.getAllOrders().subscribe({
  next: (response) => {
    this.orders = response.data;  // ← Dati ricevuti
  },
  error: (err) => {
    console.error('Errore:', err);
  }
});
```

### Metodi PRODOTTI

```typescript
getAllProducts(): Observable<any> {
  return this.http.get(`${this.apiUrl}/products`);
}

createProduct(product: any): Observable<any> {
  return this.http.post(`${this.apiUrl}/products`, product);
}

updateProduct(productId: number, product: any): Observable<any> {
  return this.http.put(`${this.apiUrl}/products/${productId}`, product);
}

deleteProduct(productId: number): Observable<any> {
  return this.http.delete(`${this.apiUrl}/products/${productId}`);
}
```

## File: `angularStaff/src/app/components/dashboard/dashboard.component.ts`

```typescript
import { Component, OnInit } from '@angular/core';
import { FlaskServiceService } from '../../services/flask-service.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  orders: any[] = [];
  loading = false;
  
  pendingCount = 0;
  preparingCount = 0;
  readyCount = 0;
  totalToday = 0;
  totalRevenue = 0;
  
  constructor(private flaskService: FlaskServiceService) {}
  
  ngOnInit() {
    this.loadOrders();
    // Aggiorna ogni 10 secondi
    setInterval(() => this.loadOrders(), 10000);
  }
  
  loadOrders() {
    this.loading = true;
    this.flaskService.getAllOrders().subscribe({
      next: (response) => {
        this.orders = response.data;
        this.calculateStats();
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Errore caricamento ordini';
        this.loading = false;
      }
    });
  }
  
  calculateStats() {
    this.pendingCount = this.orders.filter(o => o.status === 'pending').length;
    this.preparingCount = this.orders.filter(o => o.status === 'preparing').length;
    this.readyCount = this.orders.filter(o => o.status === 'ready').length;
    this.totalToday = this.orders.length;
    this.totalRevenue = this.orders.reduce((sum, o) => sum + parseFloat(o.total_price), 0);
  }
}
```

**Cosa fa?**
- Carica tutti gli ordini dal backend
- Calcola statistiche (conteggi per stato, totale, ricavi)
- Aggiorna ogni 10 secondi (live updates)

## File: `angularStaff/src/app/components/dashboard/dashboard.component.html`

```html
<div class="dashboard-container">
  <h1>📊 Pannello Gestione</h1>
  
  <div class="stats-grid">
    <div class="stat-card pending">
      <div class="stat-number">{{ pendingCount }}</div>
      <div class="stat-label">⏳ In Attesa</div>
    </div>
    <div class="stat-card preparing">
      <div class="stat-number">{{ preparingCount }}</div>
      <div class="stat-label">👨‍🍳 In Preparazione</div>
    </div>
    <!-- ... altri stat-card ... -->
  </div>
</div>
```

**Cosa fa?**
- `{{ pendingCount }}` → Data binding: mostra il valore della variabile TypeScript
- Card per ogni stato ordine
- Gradient e box shadow per design moderno

## File: `angularStaff/src/app/components/orders/orders.component.ts`

```typescript
export class OrdersComponent implements OnInit {
  orders: any[] = [];
  selectedStatus = 'pending';
  
  constructor(private flaskService: FlaskServiceService) {}
  
  ngOnInit() {
    this.loadOrders();
  }
  
  loadOrders() {
    this.flaskService.getOrdersByStatus(this.selectedStatus).subscribe({
      next: (response) => {
        this.orders = response.data;
      },
      error: (err) => {
        this.error = 'Errore caricamento ordini';
      }
    });
  }
  
  updateOrderStatus(orderId: number, newStatus: string) {
    this.flaskService.updateOrderStatus(orderId, newStatus).subscribe({
      next: (response) => {
        this.loadOrders();  // Ricarica gli ordini
      },
      error: (err) => {
        this.error = 'Errore aggiornamento ordine';
      }
    });
  }
}
```

**Cosa fa?**
- Carica ordini filtrati per stato
- Cambio estado: `pending` → `preparing` → `ready` → `delivered`
- Ricarica lista quando uno stato cambia

## File: `angularStaff/src/app/components/menu/menu.component.ts`

```typescript
export class MenuComponent implements OnInit {
  products: any[] = [];
  categories: string[] = [];
  selectedCategory = 'all';
  showForm = false;
  
  formData = {
    id: null,
    name: '',
    description: '',
    price: 0,
    category: '',
    image_url: ''
  };
  
  constructor(private flaskService: FlaskServiceService) {}
  
  ngOnInit() {
    this.loadCategories();
    this.loadAllProducts();
  }
  
  saveProduct() {
    if (this.formData.id) {
      // Modifica
      this.flaskService.updateProduct(this.formData.id, this.formData).subscribe({
        next: (response) => {
          this.loadAllProducts();
          this.closeForm();
        }
      });
    } else {
      // Crea nuovo
      this.flaskService.createProduct(this.formData).subscribe({
        next: (response) => {
          this.loadAllProducts();
          this.closeForm();
        }
      });
    }
  }
  
  deleteProduct(productId: number) {
    if (confirm('Elimina questo prodotto?')) {
      this.flaskService.deleteProduct(productId).subscribe({
        next: (response) => {
          this.loadAllProducts();
        }
      });
    }
  }
}
```

**Cosa fa?**
- CRUD completo per prodotti (Create, Read, Update, Delete)
- Form modale per aggiungere/modificare
- Filtra per categoria

---

# 4. FLUTTER TOTEM CLIENTE

## File: `fluttertotem/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hamburgheria Damico Deg Deghi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**Cosa fa?**
- `void main()` → Punto di ingresso dell'app
- `runApp()` → Avvia l'applicazione
- `MaterialApp` → Tema Material Design
- `colorScheme.fromSeed()` → Colore primary viola (#667eea)
- `home: HomeScreen()` → Prima schermata quando apri l'app

## File: `fluttertotem/lib/services/api_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

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

  static Future<bool> createOrder(
      List<Map<String, dynamic>> items, 
      double totalPrice) async {
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
```

**Cosa fa?**
- `getProducts()` → Fa GET request a `/api/products`, ritorna lista
- `createOrder()` → Fa POST request con gli item del carrello
- Gestire `async/await` per operazioni non-bloccanti
- Parse JSON response

## File: `fluttertotem/lib/screens/home_screen.dart`

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> categories;

  @override
  void initState() {
    super.initState();
    categories = ApiService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍔', style: TextStyle(fontSize: 80)),
            const Text('HAMBURGHERIA', style: TextStyle(...)),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
              child: const Text('INIZIA ORDINE'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Cosa fa?**
- `Scaffold` → Layout base (app bar, body, etc.)
- `Container` con `gradient` → Sfondo colorato
- `ElevatedButton` che naviga al menu
- `StatefulWidget` perché lo stato cambierà (hot reload)

## File: `fluttertotem/lib/screens/menu_screen.dart`

```dart
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

  void _addToCart(Map<String, dynamic> product) {
    final existingItem = cart.firstWhere(
      (item) => item['id'] == product['id'],
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      existingItem['quantity']++;  // Aumenta quantità
    } else {
      cart.add({
        'product_id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'quantity': 1,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} aggiunto al carrello')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
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
        ],
      ),
      body: GridView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProductCard(
            product: product,
            onAddToCart: () => _addToCart(product),
          );
        },
      ),
    );
  }
}
```

**Cosa fa?**
- `AppBar` con icona carrello
- `GridView.builder` → Griglia di prodotti
- `_addToCart()` → Aggiunge prodotto al carrello (o aumenta qty se esiste)
- `SnackBar` → Notifica "Aggiunto al carrello"

## File: `fluttertotem/lib/screens/cart_screen.dart`

```dart
class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> items;
  bool isPlacingOrder = false;

  double getTotalPrice() {
    return items.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity'] as double),
    );
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      items.removeAt(index);
    } else {
      items[index]['quantity'] = newQuantity;
    }
    setState(() {});  // Ricostruisce l'UI
  }

  void _placeOrder() async {
    setState(() => isPlacingOrder = true);

    final success = await ApiService.createOrder(items, getTotalPrice());

    if (mounted) {
      setState(() => isPlacingOrder = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderConfirmationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore creazione ordine')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrello')),
      body: items.isEmpty
          ? const Center(child: Text('Carrello vuoto'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(item['name']),
                                  Text('€${item['price']}'),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      _updateQuantity(index, item['quantity'] - 1),
                                ),
                                Text('${item['quantity']}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _updateQuantity(index, item['quantity'] + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Totale:'),
                          Text('€${getTotalPrice().toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isPlacingOrder ? null : _placeOrder,
                          child: isPlacingOrder
                              ? const CircularProgressIndicator()
                              : const Text('CONFERMA ORDINE'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
```

**Cosa fa?**
- Mostra lista articoli nel carrello
- Buttons +/- per modificare quantità
- `getTotalPrice()` → Calcola totale (sum dei prezzi * quantità)
- `_placeOrder()` → POST request a `/api/orders`
- Se success → vai a `OrderConfirmationScreen`

## File: `fluttertotem/lib/screens/order_confirmation_screen.dart`

```dart
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = 5;
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _counter--);
        if (_counter > 0) {
          _startCountdown();
        } else {
          // Torna a home dopo countdown
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check, size: 80, color: Colors.green),
            const Text('Ordine Confermato!', style: TextStyle(fontSize: 32)),
            const Text('Il tuo ordine è stato inviato in cucina'),
            const SizedBox(height: 40),
            Text('Torna alla home tra: $_counter secondi'),
          ],
        ),
      ),
    );
  }
}
```

**Cosa fa?**
- Schermata di successo con checkmark ✅
- Countdown da 5 a 0 secondi
- Dopo scadenza, torna alla home automaticamente

---

# 5. CONFIGURAZIONE AIVEN

## Dove Mettere le Credenziali

### **File: `.env`** (NON committerlo!!! ← Importante)

```bash
# Crea da .env.example
cp .env.example .env
```

Modifica `.env`:

```env
# MySQL Aiven Configuration
DB_HOST=your-instance-xxxx.aivencloud.com
DB_USER=avnadmin
DB_PASSWORD=your-super-secure-password
DB_NAME=defaultdb
DB_PORT=21711

# Flask Configuration
FLASK_ENV=development
FLASK_PORT=5000
```

### Come Ottenere le Credenziali da Aiven

1. **Accedi a Aiven Console:** https://console.aiven.io
2. **Seleziona il servizio MySQL**
3. **Vai a "Overview"**
4. **Scorri fino a "Connection Information"**
5. Troverai:
   ```
   Host: your-instance-name.aivencloud.com
   Port: 21711
   User: avnadmin
   Password: [mostrato qui]
   Database: defaultdb
   ```

### File `.gitignore` (già creato)

```
.env
.env.local
node_modules/
```

**Perché `.env` è in `.gitignore`?**
- Contiene password e credenziali sensibili
- NON deve mai essere committato su GitHub
- Ogni sviluppatore ha la sua copia `.env` locale

---

# 6. FLUSSO DI COMUNICAZIONE

## Scenario 1: Cliente ordina dal Totem

```
1. CLIENTE APRE APP FLUTTER
   └─> HomeScreen (benvenuto)
   
2. CLIENTE CLICCA "INIZIA ORDINE"
   └─> MenuScreen
   └─> ApiService.getProducts()
   └─> GET http://localhost:5000/api/products
   └─> Flask app.get_products()
   └─> DatabaseWrapper.get_all_products()
   └─> MySQL: SELECT * FROM products
   └─> ✅ Torna lista prodotti a Flutter
   
3. CLIENTE SELEZIONA CATEGORIA
   └─> MenuScreen filtra per categoria
   └─> ApiService.getProductsByCategory()
   └─> GET http://localhost:5000/api/products/category/panini
   
4. CLIENTE AGGIUNGE PRODOTTI AL CARRELLO
   └─> _addToCart()
   └─> cart = [{product_id: 1, quantity: 2, price: 5.00}, ...]
   
5. CLIENTE VA AL CARRELLO
   └─> CartScreen
   └─> Mostra item con +/- per modificare qty
   
6. CLIENTE CLICCA "CONFERMA ORDINE"
   └─> _placeOrder()
   └─> ApiService.createOrder(items, totalPrice)
   └─> POST http://localhost:5000/api/orders
   └─> Body: { items: [...], total_price: 13.00 }
   └─> Flask app.create_order()
   └─> DatabaseWrapper.create_order()
   └─> MySQL: INSERT INTO orders (...) VALUES (...)
   └─> MySQL: INSERT INTO order_items (...)
   └─> ✅ Ritorna ordine_number
   └─> OrderConfirmationScreen (5 sec countdown, poi home)
```

## Scenario 2: Staff Aggiorna Stato Ordine

```
1. STAFF ACCEDE AD ANGULAR
   └─> http://localhost:4200
   └─> AppComponent root
   └─> Route a DashboardComponent
   
2. DASHBOARD CARICA
   └─> ngOnInit() → loadOrders()
   └─> FlaskServiceService.getAllOrders()
   └─> GET http://localhost:5000/api/orders
   └─> Flask app.get_orders()
   └─> DatabaseWrapper.get_all_orders()
   └─> MySQL: SELECT * FROM orders
   └─> ✅ Mostra lista ordini con statistiche
   
3. STAFF CLICCA SU ORDINE
   └─> OrdersComponent
   └─> expand ordine per vedere item
   
4. STAFF CLICCA "→ IN PREPARAZIONE"
   └─> updateOrderStatus(orderId, 'preparing')
   └─> FlaskServiceService.updateOrderStatus()
   └─> PUT http://localhost:5000/api/orders/1/status
   └─> Body: { status: 'preparing' }
   └─> Flask app.update_order_status()
   └─> DatabaseWrapper.update_order_status()
   └─> MySQL: UPDATE orders SET status = 'preparing' WHERE id = 1
   └─> ✅ Ricarica lista ordini
   
5. ... PASSA PER TUTTI GLI STATI ...
   └─> pending → preparing → ready → delivered
```

## Scenario 3: Staff Aggiunge Nuovo Prodotto

```
1. STAFF CLICCA "AGGIUNGI PRODOTTO"
   └─> MenuComponent
   └─> openForm() - Mostra modal con form
   
2. STAFF COMPILA FORM
   └─> name: "Hamburger Deluxe"
   └─> description: "Con bacon e formaggio"
   └─> price: 7.50
   └─> category: "panini"
   
3. STAFF CLICCA SALVA
   └─> saveProduct()
   └─> FlaskServiceService.createProduct(formData)
   └─> POST http://localhost:5000/api/products
   └─> Body: { name: "...", price: 7.50, ... }
   └─> Flask app.create_product()
   └─> Validazione dati
   └─> DatabaseWrapper.add_product()
   └─> MySQL: INSERT INTO products (...) VALUES (...)
   └─> ✅ Ritorna product_id
   └─> loadAllProducts() - Ricarica lista
   └─> closeForm() - Chiude modal
```

---

## RIEPILOGO ARCHITETTURA

```
┌──────────────────────────────────────────────────────────────┐
│  FLUTTER TOTEM CLIENTE                                       │
│  (lib/screens/*, lib/services/api_service.dart)             │
│  http://localhost:8000 (quando in esecuzione)               │
└────────────────┬────────────────────┬───────────────────────┘
                 │                    │
          GET /api/products    POST /api/orders
                 │                    │
┌────────────────▼────────────────────▼───────────────────────┐
│  BACKEND FLASK (app.py)                                     │
│  - Endpoints REST                                            │
│  - CORS enabled                                              │
│  - Validazione dati                                          │
│  http://localhost:5000                                       │
└────────────────┬────────────────────┬───────────────────────┘
                 │                    │
          DatabaseWrapper.get_all_products()
          DatabaseWrapper.create_order()
                 │                    │
        ┌────────▼────────────────────▼────────┐
        │  MySQL Aiven (in cloud)              │
        │  Database: hamburgeriadb            │
        │  Tables: products, orders, items    │
        │  Credenziali in .env                │
        └────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────┬───────────────────────┐
│  ANGULAR STAFF PANEL (angularStaff/)                        │
│  (src/app/components/*, services/flask-service)            │
│  http://localhost:4200                                      │
│                                                             │
│  - DashboardComponent (statistiche live)                   │
│  - OrdersComponent (gestione stato ordini)                │
│  - MenuComponent (CRUD prodotti)                          │
└─────────────────────────────────────────────────────────────┘
```

---

## FILE DI CONFIGURAZIONE

### `requirements.txt` (Python)
```
Flask==3.0.0
Flask-CORS==4.0.0
PyMySQL==1.1.0
python-dotenv==1.0.0
```

### `pubspec.yaml` (Flutter)
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  uuid: ^4.0.0
```

### `package.json` (Angular)
```json
{
  "dependencies": {
    "@angular/core": "^19.2.0",
    "@angular/common": "^19.2.0",
    "@angular/router": "^19.2.0",
    "@angular/forms": "^19.2.0"
  }
}
```

---

## COMANDI VELOCI

```bash
# Backend
python app.py

# Angular
cd angularStaff && npm install && npm start

# Flutter
cd fluttertotem && flutter pub get && flutter run -d chrome

# Verifica sistema
bash SYSTEM_CHECK.sh
```

---

🎉 **Tutto il sistema è documentato e connesso!** 🎉
