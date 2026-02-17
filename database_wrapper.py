"""
DatabaseWrapper - Gestisce tutte le operazioni con il database MySQL
"""
import pymysql
from typing import List, Dict, Tuple, Optional
import os
from dotenv import load_dotenv

load_dotenv()


class DatabaseWrapper:
    def __init__(self):
        self.host = os.getenv('DB_HOST')
        self.user = os.getenv('DB_USER')
        self.password = os.getenv('DB_PASSWORD')
        self.database = os.getenv('DB_NAME')
        self.port = int(os.getenv('DB_PORT', 3306))
        self.connection = None

    def connect(self) -> None:
        """Stabilisce la connessione al database"""
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

    def disconnect(self) -> None:
        """Chiude la connessione al database"""
        if self.connection:
            self.connection.close()

    def execute_query(self, query: str, params: tuple = ()) -> List[Dict]:
        """Esegue una query SELECT"""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, params)
                return cursor.fetchall()
        except Exception as e:
            print(f"✗ Errore query: {e}")
            return []

    def execute_insert(self, query: str, params: tuple = ()) -> int:
        """Esegue una query INSERT e ritorna l'ID inserito"""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, params)
                self.connection.commit()
                return cursor.lastrowid
        except Exception as e:
            self.connection.rollback()
            print(f"✗ Errore inserimento: {e}")
            return -1

    def execute_update(self, query: str, params: tuple = ()) -> bool:
        """Esegue una query UPDATE/DELETE"""
        try:
            with self.connection.cursor() as cursor:
                cursor.execute(query, params)
                self.connection.commit()
                return True
        except Exception as e:
            self.connection.rollback()
            print(f"✗ Errore aggiornamento: {e}")
            return False

    # ==================== CATEGORIE ====================
    
    def init_categories_table(self) -> None:
        """Crea la tabella categorie se non esiste"""
        query = """
        CREATE TABLE IF NOT EXISTS categories (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(100) NOT NULL UNIQUE,
            description TEXT,
            icon VARCHAR(50),
            order_position INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """
        self.execute_update(query)

    def add_category(self, name: str, description: str = None, icon: str = None, order_position: int = 0) -> int:
        """Aggiunge una nuova categoria"""
        query = """
        INSERT INTO categories (name, description, icon, order_position)
        VALUES (%s, %s, %s, %s)
        """
        return self.execute_insert(query, (name, description, icon, order_position))

    def update_category(self, category_id: int, name: str = None, description: str = None, 
                       icon: str = None, order_position: int = None) -> bool:
        """Aggiorna una categoria"""
        updates = []
        params = []
        
        if name:
            updates.append("name = %s")
            params.append(name)
        if description is not None:
            updates.append("description = %s")
            params.append(description)
        if icon is not None:
            updates.append("icon = %s")
            params.append(icon)
        if order_position is not None:
            updates.append("order_position = %s")
            params.append(order_position)

        if not updates:
            return False

        params.append(category_id)
        query = f"UPDATE categories SET {', '.join(updates)} WHERE id = %s"
        return self.execute_update(query, tuple(params))

    def delete_category(self, category_id: int) -> bool:
        """Elimina una categoria"""
        query = "DELETE FROM categories WHERE id = %s"
        return self.execute_update(query, (category_id,))

    def get_all_categories(self) -> List[Dict]:
        """Ritorna tutte le categorie ordinate per posizione"""
        query = "SELECT * FROM categories ORDER BY order_position, name"
        return self.execute_query(query)

    def get_category_by_id(self, category_id: int) -> Optional[Dict]:
        """Ritorna una categoria per ID"""
        query = "SELECT * FROM categories WHERE id = %s"
        result = self.execute_query(query, (category_id,))
        return result[0] if result else None

    def get_category_by_name(self, name: str) -> Optional[Dict]:
        """Ritorna una categoria per nome"""
        query = "SELECT * FROM categories WHERE name = %s"
        result = self.execute_query(query, (name,))
        return result[0] if result else None

    # ==================== PRODOTTI ====================
    
    def init_products_table(self) -> None:
        """Crea la tabella prodotti se non esiste"""
        query = """
        CREATE TABLE IF NOT EXISTS products (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(100) NOT NULL,
            description TEXT,
            price DECIMAL(10, 2) NOT NULL,
            category_id INT NOT NULL,
            image_url VARCHAR(255),
            available BOOLEAN DEFAULT TRUE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (category_id) REFERENCES categories(id)
        )
        """
        self.execute_update(query)

    def get_all_products(self) -> List[Dict]:
        """Ritorna tutti i prodotti con info categoria"""
        query = """
        SELECT p.*, c.name as category_name, c.icon 
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.available = TRUE 
        ORDER BY c.order_position, c.name, p.name
        """
        return self.execute_query(query)

    def get_products_by_category(self, category_id: int) -> List[Dict]:
        """Ritorna i prodotti di una categoria"""
        query = """
        SELECT p.*, c.name as category_name, c.icon 
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.category_id = %s AND p.available = TRUE 
        ORDER BY p.name
        """
        return self.execute_query(query, (category_id,))

    def get_product_by_id(self, product_id: int) -> Optional[Dict]:
        """Ritorna un prodotto per ID con info categoria"""
        query = """
        SELECT p.*, c.name as category_name, c.icon 
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.id
        WHERE p.id = %s
        """
        result = self.execute_query(query, (product_id,))
        return result[0] if result else None

    def add_product(self, name: str, description: str, price: float, 
                   category_id: int, image_url: str = None) -> int:
        """Aggiunge un nuovo prodotto"""
        query = """
        INSERT INTO products (name, description, price, category_id, image_url)
        VALUES (%s, %s, %s, %s, %s)
        """
        return self.execute_insert(query, (name, description, price, category_id, image_url))

    def update_product(self, product_id: int, name: str = None, description: str = None,
                      price: float = None, category_id: int = None, image_url: str = None) -> bool:
        """Aggiorna un prodotto"""
        updates = []
        params = []
        
        if name:
            updates.append("name = %s")
            params.append(name)
        if description is not None:
            updates.append("description = %s")
            params.append(description)
        if price:
            updates.append("price = %s")
            params.append(price)
        if category_id is not None:
            updates.append("category_id = %s")
            params.append(category_id)
        if image_url is not None:
            updates.append("image_url = %s")
            params.append(image_url)

        if not updates:
            return False

        params.append(product_id)
        query = f"UPDATE products SET {', '.join(updates)} WHERE id = %s"
        return self.execute_update(query, tuple(params))

    def delete_product(self, product_id: int) -> bool:
        """Elimina un prodotto (soft delete)"""
        query = "UPDATE products SET available = FALSE WHERE id = %s"
        return self.execute_update(query, (product_id,))

    # ==================== ORDINI ====================

    def init_orders_table(self) -> None:
        """Crea la tabella ordini"""
        query = """
        CREATE TABLE IF NOT EXISTS orders (
            id INT PRIMARY KEY AUTO_INCREMENT,
            order_number VARCHAR(50) UNIQUE NOT NULL,
            total_price DECIMAL(10, 2) NOT NULL,
            status VARCHAR(50) DEFAULT 'pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
        """
        self.execute_update(query)

    def init_order_items_table(self) -> None:
        """Crea la tabella item degli ordini"""
        query = """
        CREATE TABLE IF NOT EXISTS order_items (
            id INT PRIMARY KEY AUTO_INCREMENT,
            order_id INT NOT NULL,
            product_id INT NOT NULL,
            quantity INT NOT NULL,
            price DECIMAL(10, 2) NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id)
        )
        """
        self.execute_update(query)

    def get_all_orders(self) -> List[Dict]:
        """Ritorna tutti gli ordini"""
        query = """
        SELECT * FROM orders 
        ORDER BY created_at DESC
        """
        return self.execute_query(query)

    def get_orders_by_status(self, status: str) -> List[Dict]:
        """Ritorna ordini filtrati per stato"""
        query = """
        SELECT * FROM orders 
        WHERE status = %s 
        ORDER BY created_at DESC
        """
        return self.execute_query(query, (status,))

    def get_order_by_id(self, order_id: int) -> Optional[Dict]:
        """Ritorna un ordine per ID"""
        query = "SELECT * FROM orders WHERE id = %s"
        result = self.execute_query(query, (order_id,))
        return result[0] if result else None

    def get_order_items(self, order_id: int) -> List[Dict]:
        """Ritorna gli item di un ordine"""
        query = """
        SELECT oi.*, p.name, p.category 
        FROM order_items oi
        JOIN products p ON oi.product_id = p.id
        WHERE oi.order_id = %s
        """
        return self.execute_query(query, (order_id,))

    def create_order(self, order_number: str, items: List[Dict], total_price: float) -> int:
        """Crea un nuovo ordine con i suoi item"""
        # Inserisci ordine
        order_query = """
        INSERT INTO orders (order_number, total_price, status)
        VALUES (%s, %s, 'pending')
        """
        order_id = self.execute_insert(order_query, (order_number, total_price))

        if order_id == -1:
            return -1

        # Inserisci gli item
        item_query = """
        INSERT INTO order_items (order_id, product_id, quantity, price)
        VALUES (%s, %s, %s, %s)
        """
        
        for item in items:
            self.execute_insert(item_query, 
                              (order_id, item['product_id'], item['quantity'], item['price']))

        return order_id

    def update_order_status(self, order_id: int, status: str) -> bool:
        """Aggiorna lo stato di un ordine"""
        valid_statuses = ['pending', 'preparing', 'ready', 'delivered', 'cancelled']
        if status not in valid_statuses:
            return False

        query = "UPDATE orders SET status = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s"
        return self.execute_update(query, (status, order_id))

    def delete_order(self, order_id: int) -> bool:
        """Elimina un ordine e i suoi item"""
        query = "DELETE FROM orders WHERE id = %s"
        return self.execute_update(query, (order_id,))
