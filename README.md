# 🍔 Hamburgheria Damico Deg Deghi - Sistema Informatico Completo

Sistema informatico end-to-end per una hamburgheria con **totem digitale cliente**, **pannello staff** e **backend REST API**.

## 📋 Componenti del Sistema

### 1. **Totem Cliente (Flutter)**
App mobile/touch per clienti in hamburgheria:
- 📱 Consultare il menu con categorie
- 🛒 Aggiungere prodotti al carrello
- ✅ Confermare l'ordine
- 🎉 Visualizzare conferma ordine

**Ubicazione:** `/fluttertotem/`

### 2. **Pannello Staff (Angular)**
Web app moderna per gestione interna:
- 📊 Dashboard con statistiche ordini in tempo reale
- 📋 Gestione ordini (cambio stato: pending → preparing → ready → delivered)
- 🍔 Gestione menu (CRUD prodotti e categorie)
- 💰 Visualizzazione ricavi e ordini totali

**Ubicazione:** `/angularStaff/`

### 3. **Backend Flask**
API REST che collega tutto il sistema:
- ✅ Endpoints per prodotti (GET, CREATE, UPDATE, DELETE)
- ✅ Endpoints per ordini (GET, CREATE, UPDATE STATUS)
- ✅ Database MySQL con struttura relazionale
- ✅ CORS abilitato per Flutter e Angular

**Ubicazione:** `app.py` + `database_wrapper.py`

---

## 🚀 Quick Start - Configurazione

### 1. Database MySQL (Aiven)

#### Dove mettere le credenziali:

Crea un file `.env` nella cartella principale del progetto:

```bash
cp .env.example .env
```

Poi modifica `.env` con le tue credenziali Aiven:

```env
# MySQL Aiven Configuration
DB_HOST=your-instance-xxxx.aivencloud.com
DB_USER=avnadmin
DB_PASSWORD=your-super-secure-password-here
DB_NAME=hamburgeriadb
DB_PORT=21711

# Flask Configuration
FLASK_ENV=development
FLASK_PORT=5000
```

**Come ottenerle da Aiven:**
1. Vai su https://console.aiven.io
2. Seleziona il tuo servizio MySQL
3. Clicca su "Connection Information"
4. Copia i valori: host, utente, password, porta, database name

### 2. Backend Flask

```bash
# Installa dipendenze
pip install -r requirements.txt

# Esegui il server
python app.py
```

Il backend sarà disponibile su: `http://localhost:5000`

### 3. Pannello Angular Staff

```bash
cd angularStaff

# Installa dipendenze
npm install

# Esegui in sviluppo
npm start
```

Accedi da: `http://localhost:4200`

Pagine disponibili:
- Dashboard: `http://localhost:4200/dashboard`
- Ordini: `http://localhost:4200/orders`
- Menu: `http://localhost:4200/menu`

### 4. Totem Cliente Flutter

```bash
cd fluttertotem

# Installa dipendenze
flutter pub get

# Esegui su piattaforma desiderata
flutter run -d chrome        # Web
flutter run -d linux         # Linux
flutter run -d android       # Android
```

---

## 📁 Struttura Progetto

```
HamburgeriaDamicoDegDeghi/
├── app.py                    # Backend Flask principale
├── database_wrapper.py       # Class per gestire il DB
├── requirements.txt          # Dipendenze Python
├── .env.example             # Template configurazione
│
├── angularStaff/            # Pannello staff Angular
│   ├── src/
│   │   ├── app/
│   │   │   ├── components/
│   │   │   │   ├── dashboard/    # Dashboard statistiche
│   │   │   │   ├── orders/       # Gestione ordini
│   │   │   │   └── menu/         # Gestione menu
│   │   │   ├── services/
│   │   │   │   └── flask-service.service.ts
│   │   │   └── app.routes.ts
│   │   └── styles.css
│   └── package.json
│
└── fluttertotem/            # Totem cliente Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── services/
    │   │   └── api_service.dart
    │   └── screens/
    │       ├── home_screen.dart
    │       ├── menu_screen.dart
    │       ├── cart_screen.dart
    │       └── order_confirmation_screen.dart
    └── pubspec.yaml
```

---

## 🔌 API Endpoints

### Prodotti
- `GET /api/products` - Tutti i prodotti
- `GET /api/categories` - Tutte le categorie
- `GET /api/products/category/<category>` - Prodotti per categoria
- `POST /api/products` - Crea prodotto (staff)
- `PUT /api/products/<id>` - Aggiorna prodotto (staff)
- `DELETE /api/products/<id>` - Elimina prodotto (staff)

### Ordini
- `GET /api/orders` - Tutti gli ordini
- `GET /api/orders?status=pending` - Ordini per stato
- `POST /api/orders` - Crea nuovo ordine (dal totem)
- `PUT /api/orders/<id>/status` - Aggiorna stato ordine

### Salute
- `GET /api/health` - Verifica stato server

---

## 🎨 Design e UX

- **Colore primario:** `#667eea` (Viola)
- **Colore secondario:** `#764ba2`
- **Design moderno:** Gradient, card elevation, smooth transitions
- **Responsive:** Adatto a mobile, tablet, desktop
- **Emojis:** UI intuitiva con emoji per migliore UX

---

## 💾 Database Schema

### Tabella: `products`
```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50) NOT NULL,
    image_url VARCHAR(255),
    available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabella: `orders`
```sql
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Tabella: `order_items`
```sql
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
```

---

## 🔒 Sicurezza

- ✅ CORS abilitato per frontend development
- ✅ Credenziali DB in `.env` (non versionato)
- ⚠️ **TODO:** Implementare autenticazione staff
- ⚠️ **TODO:** Rate limiting su API
- ⚠️ **TODO:** Input validation sui dati

---

## 🐛 Troubleshooting

### Database non si connette
- Verifica che le credenziali in `.env` siano corrette
- Controlla che il DB sia online su Aiven
- Verifica la connessione di rete

### CORS error su Angular/Flutter
- Assicurati che `http://localhost:5000` sia raggiungibile
- Verifica che il backend Flask sia in esecuzione
- Controlla la rete (firewall, proxy)

### Flutter non si connette
- Usa `http://localhost:5000` su Chrome/desktop
- Su Android fisico/emulatore, usa l'IP della macchina invece di localhost
- Modifica `api_service.dart` con l'IP: `http://YOUR_COMPUTER_IP:5000`

---

## 📝 Note di Sviluppo

- **Backend:** Python 3.11+ con Flask, PyMySQL
- **Frontend Staff:** Angular 19 standalone components
- **Frontend Totem:** Flutter 3.11+ Dart
- **Database:** MySQL 8.0+ via Aiven
- **API Style:** RESTful JSON

---

## 🚀 Deploy Suggerimenti

### Backend
- Usa **Heroku** o **Railway** per Flask
- Configura env vars in produzione
- Usa Gunicorn come WSGI server

### Angular
- Build: `npm run build`
- Deploy su **Vercel** o **Firebase Hosting**

### Flutter
- Build web: `flutter build web`
- Build Android: `flutter build apk`
- Build iOS: `flutter build ipa`

---

## 📞 Contatti / Supporto

Per domande o problemi, contatta il team di sviluppo.

**Versione:** 1.0.0  
**Data:** Febbraio 2026  
**Autore:** Team Sviluppo
