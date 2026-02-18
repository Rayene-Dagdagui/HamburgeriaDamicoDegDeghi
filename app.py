"""
Hamburgheria Damico Deg Deghi - Backend Flask
API REST per gestire menu, ordini e comunicazione tra totem cliente e pannello staff
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
from database_wrapper import DatabaseWrapper
from datetime import datetime
import os
from dotenv import load_dotenv

# Carica variabili d'ambiente
load_dotenv()

# Inizializza Flask
app = Flask(__name__)
CORS(app, resources={r"/api/*": {"origins": ["*"]}})

# Inizializza Database
db = DatabaseWrapper()


# ==================== STARTUP ====================

@app.before_request
def before_request():
    """Connette al database per ogni richiesta"""
    if not db.connection:
        db.connect()
        # Inizializza tabelle se non esistono
        db.init_categories_table()
        db.init_products_table()
        db.init_orders_table()
        db.init_order_items_table()


@app.teardown_appcontext
def teardown_db(exception=None):
    """Chiude la connessione al database"""
    pass  # PyMySQL gestisce le connessioni automaticamente


# ==================== PRODOTTI ====================

@app.route('/api/products', methods=['GET'])
def get_products():
    """Ritorna tutti i prodotti disponibili (per il totem cliente)"""
    try:
        products = db.get_all_products()
        return jsonify({
            'status': 'success',
            'data': products,
            'count': len(products)
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/products/category/<int:category_id>', methods=['GET'])
def get_products_by_category(category_id):
    """Ritorna i prodotti di una categoria specifica"""
    try:
        products = db.get_products_by_category(category_id)
        return jsonify({
            'status': 'success',
            'data': products,
            'count': len(products)
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


# ==================== CATEGORIE ====================

@app.route('/api/categories', methods=['GET'])
def get_categories():
    """Ritorna tutte le categorie disponibili"""
    try:
        categories = db.get_all_categories()
        return jsonify({
            'status': 'success',
            'data': categories,
            'count': len(categories)
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/categories/<int:category_id>', methods=['GET'])
def get_category(category_id):
    """Ritorna una categoria per ID"""
    try:
        category = db.get_category_by_id(category_id)
        if not category:
            return jsonify({'status': 'error', 'message': 'Categoria non trovata'}), 404
        return jsonify({
            'status': 'success',
            'data': category
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/categories', methods=['POST'])
def create_category():
    """Crea una nuova categoria (Solo staff).

    Nota: l'interfaccia grafica non espone più il pulsante di creazione, la rotta
    rimane disponibile per script o popolazioni iniziali automatiche.
    """
    try:
        data = request.get_json()
        
        # Validazione
        if not data or 'name' not in data:
            return jsonify({
                'status': 'error',
                'message': 'Campo obbligatorio: name'
            }), 400

        category_id = db.add_category(
            name=data['name'],
            description=data.get('description', None),
            icon=data.get('icon', None),
            order_position=data.get('order_position', 0)
        )

        if category_id == -1:
            return jsonify({'status': 'error', 'message': 'Errore creazione categoria'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Categoria creata con successo',
            'category_id': category_id
        }), 201
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/categories/<int:category_id>', methods=['PUT'])
def update_category(category_id):
    """Aggiorna una categoria (Solo staff)"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'status': 'error', 'message': 'Nessun dato fornito'}), 400

        success = db.update_category(
            category_id=category_id,
            name=data.get('name'),
            description=data.get('description'),
            icon=data.get('icon'),
            order_position=data.get('order_position')
        )

        if not success:
            return jsonify({'status': 'error', 'message': 'Errore aggiornamento categoria'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Categoria aggiornata con successo'
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/categories/<int:category_id>', methods=['DELETE'])
def delete_category(category_id):
    """Elimina una categoria (Solo staff)"""
    try:
        success = db.delete_category(category_id)
        if not success:
            return jsonify({'status': 'error', 'message': 'Errore eliminazione categoria'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Categoria eliminata con successo'
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


# ==================== PRODOTTI ====================


@app.route('/api/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Ritorna un prodotto specifico per ID"""
    try:
        product = db.get_product_by_id(product_id)
        if not product:
            return jsonify({'status': 'error', 'message': 'Prodotto non trovato'}), 404
        return jsonify({
            'status': 'success',
            'data': product
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/products', methods=['POST'])
def create_product():
    """Crea un nuovo prodotto (Solo staff)"""
    try:
        data = request.get_json()
        
        # Validazione
        if not data or not all(k in data for k in ['name', 'price', 'category_id']):
            return jsonify({
                'status': 'error',
                'message': 'Campi obbligatori: name, price, category_id'
            }), 400

        product_id = db.add_product(
            name=data['name'],
            description=data.get('description', ''),
            price=float(data['price']),
            category_id=int(data['category_id']),
            image_url=data.get('image_url', None)
        )

        if product_id == -1:
            return jsonify({'status': 'error', 'message': 'Errore creazione prodotto'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Prodotto creato con successo',
            'product_id': product_id
        }), 201
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Aggiorna un prodotto (Solo staff)"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'status': 'error', 'message': 'Nessun dato fornito'}), 400

        success = db.update_product(
            product_id=product_id,
            name=data.get('name'),
            description=data.get('description'),
            price=data.get('price'),
            category_id=int(data.get('category_id')) if data.get('category_id') else None,
            image_url=data.get('image_url')
        )

        if not success:
            return jsonify({'status': 'error', 'message': 'Errore aggiornamento prodotto'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Prodotto aggiornato con successo'
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Elimina un prodotto (Solo staff)"""
    try:
        success = db.delete_product(product_id)
        if not success:
            return jsonify({'status': 'error', 'message': 'Errore eliminazione prodotto'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Prodotto eliminato con successo'
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


# ==================== ORDINI ====================

@app.route('/api/orders', methods=['GET'])
def get_orders():
    """Ritorna tutti gli ordini (per il pannello staff)"""
    try:
        status_filter = request.args.get('status', None)
        
        if status_filter:
            orders = db.get_orders_by_status(status_filter)
        else:
            orders = db.get_all_orders()

        # Organizza gli ordini con i loro item
        orders_with_items = []
        for order in orders:
            order_items = db.get_order_items(order['id'])
            orders_with_items.append({
                **order,
                'items': order_items
            })

        return jsonify({
            'status': 'success',
            'data': orders_with_items,
            'count': len(orders_with_items)
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/orders/<int:order_id>', methods=['GET'])
def get_order(order_id):
    """Ritorna un ordine specifico con i suoi item"""
    try:
        order = db.get_order_by_id(order_id)
        if not order:
            return jsonify({'status': 'error', 'message': 'Ordine non trovato'}), 404

        order_items = db.get_order_items(order_id)
        order['items'] = order_items

        return jsonify({
            'status': 'success',
            'data': order
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/orders', methods=['POST'])
def create_order():
    """Crea un nuovo ordine (dal totem cliente)"""
    try:
        data = request.get_json()

        # Validazione
        if not data or not all(k in data for k in ['items', 'total_price']):
            return jsonify({
                'status': 'error',
                'message': 'Campi obbligatori: items, total_price'
            }), 400

        # Genera numero ordine univoco
        import random
        order_number = f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000, 9999)}"

        order_id = db.create_order(
            order_number=order_number,
            items=data['items'],
            total_price=float(data['total_price'])
        )

        if order_id == -1:
            return jsonify({'status': 'error', 'message': 'Errore creazione ordine'}), 500

        return jsonify({
            'status': 'success',
            'message': 'Ordine creato con successo',
            'order_id': order_id,
            'order_number': order_number
        }), 201
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/api/orders/<int:order_id>/status', methods=['PUT'])
def update_order_status(order_id):
    """Aggiorna lo stato di un ordine (dal pannello staff)"""
    try:
        data = request.get_json()

        if not data or 'status' not in data:
            return jsonify({'status': 'error', 'message': 'Campo obbligatorio: status'}), 400

        success = db.update_order_status(order_id, data['status'])

        if not success:
            return jsonify({'status': 'error', 'message': 'Stato ordine non valido'}), 400

        return jsonify({
            'status': 'success',
            'message': f"Ordine aggiornato a: {data['status']}"
        }), 200
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


# ==================== SALUTE ====================

@app.route('/api/health', methods=['GET'])
def health():
    """Endpoint per verificare lo stato del server"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat()
    }), 200


# ==================== ERRORI ====================

@app.errorhandler(404)
def not_found(e):
    return jsonify({
        'status': 'error',
        'message': 'Endpoint non trovato'
    }), 404


@app.errorhandler(500)
def internal_error(e):
    return jsonify({
        'status': 'error',
        'message': 'Errore interno del server'
    }), 500


if __name__ == '__main__':
    try:
        db.connect()
        db.init_categories_table()
        db.init_products_table()
        db.init_orders_table()
        db.init_order_items_table()
        print("✓ Database inizializzato")

        # inserisce categorie e prodotti d'esempio se il DB è vuoto
        def seed_initial_data():
            # list of default categories we want present in the system
            defaults = [
                {'name':'Hamburger', 'description':'Panini classici', 'icon':'🍔'},
                {'name':'Bevande', 'description':'Bibite e altro', 'icon':'🥤'},
                {'name':'Contorni', 'description':'Patatine, etc.', 'icon':'🍟'},
                {'name':'Panini speciali', 'description':'Creazioni uniche', 'icon':'🥪'},
                {'name':'Dessert', 'description':'Dolci e gelati', 'icon':'🍨'}
            ]

            existing = {c['name'] for c in db.get_all_categories()}
            added = 0
            for idx, cat in enumerate(defaults, start=1):
                if cat['name'] not in existing:
                    db.add_category(name=cat['name'], description=cat['description'], icon=cat['icon'], order_position=idx)
                    added += 1
            if added:
                print(f"→ Aggiunte {added} categorie di default")
            else:
                print("→ Tutte le categorie di default sono già presenti, salto seed")

            prods = db.get_all_products()
            if not prods:
                print("→ Aggiungo alcuni prodotti di esempio")
                # recupera id categorie appena create
                hamburgers = db.get_category_by_name('Hamburger')
                drinks = db.get_category_by_name('Bevande')
                sides = db.get_category_by_name('Contorni')
                if hamburgers:
                    db.add_product(name='Classic Burger', description='Carne, lattuga, pomodoro', price=5.99, category_id=hamburgers['id'])
                    db.add_product(name='Cheese Burger', description='Con formaggio extra', price=6.99, category_id=hamburgers['id'])
                if drinks:
                    db.add_product(name='Coca Cola', description='Lattina 33cl', price=2.50, category_id=drinks['id'])
                if sides:
                    db.add_product(name='Patatine fritte', description='Porzione media', price=3.00, category_id=sides['id'])
            else:
                print(f"→ {len(prods)} prodotti già presenti, salto seed")

        seed_initial_data()

        app.run(
            host='0.0.0.0',
            port=os.getenv('FLASK_PORT', 5000),
            debug=os.getenv('FLASK_ENV') == 'development'
        )
    except Exception as e:
        print(f"✗ Errore avvio: {e}")
    finally:
        db.disconnect()
