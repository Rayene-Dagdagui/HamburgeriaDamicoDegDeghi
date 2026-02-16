#!/bin/bash

# 🔍 CHECK SISTEMA COMPLETO - Hamburgheria Damico Deg Deghi
# Verifica che tutti i componenti siano collegati correttamente

echo "🔍 SYSTEM CHECK - Hamburgheria Damico Deg Deghi"
echo "=============================================="
echo ""

STATUS_OK="✅"
STATUS_ERROR="❌"
STATUS_WARN="⚠️"

# Counter errori
ERRORS=0

# ==================== CHECK FLASK ====================
echo "📦 CHECK BACKEND FLASK"
echo "---"

if [ -f "app.py" ]; then
    echo "$STATUS_OK app.py trovato"
    
    # Verifica se ContaineRappresents i metodi principali
    if grep -q "def get_products" app.py; then
        echo "$STATUS_OK Endpoint GET /api/products trovato"
    else
        echo "$STATUS_ERROR Endpoint GET /api/products MANCANTE"
        ((ERRORS++))
    fi
    
    if grep -q "def create_order" app.py; then
        echo "$STATUS_OK Endpoint POST /api/orders trovato"
    else
        echo "$STATUS_ERROR Endpoint POST /api/orders MANCANTE"
        ((ERRORS++))
    fi
else
    echo "$STATUS_ERROR app.py NON TROVATO"
    ((ERRORS++))
fi

if [ -f "database_wrapper.py" ]; then
    echo "$STATUS_OK database_wrapper.py trovato"
else
    echo "$STATUS_ERROR database_wrapper.py NON TROVATO"
    ((ERRORS++))
fi

if [ -f "requirements.txt" ]; then
    echo "$STATUS_OK requirements.txt trovato"
    if grep -q "Flask" requirements.txt; then
        echo "$STATUS_OK Flask in requirements.txt"
    fi
    if grep -q "PyMySQL" requirements.txt; then
        echo "$STATUS_OK PyMySQL in requirements.txt"
    fi
else
    echo "$STATUS_ERROR requirements.txt NON TROVATO"
    ((ERRORS++))
fi

echo ""

# ==================== CHECK ANGULAR ====================
echo "🌐 CHECK ANGULAR STAFF PANEL"
echo "---"

if [ -f "angularStaff/src/app/app.component.ts" ]; then
    echo "$STATUS_OK app.component.ts trovato"
else
    echo "$STATUS_ERROR app.component.ts NON TROVATO"
    ((ERRORS++))
fi

if [ -f "angularStaff/src/app/services/flask-service.service.ts" ]; then
    echo "$STATUS_OK flask-service.service.ts trovato"
    
    # Verifica se ci sono i metodi del servizio
    if grep -q "getAllOrders()" "angularStaff/src/app/services/flask-service.service.ts"; then
        echo "$STATUS_OK Metodo getAllOrders() nel servizio"
    fi
    
    if grep -q "getCategories()" "angularStaff/src/app/services/flask-service.service.ts"; then
        echo "$STATUS_OK Metodo getCategories() nel servizio"
    fi
else
    echo "$STATUS_ERROR flask-service.service.ts NON TROVATO"
    ((ERRORS++))
fi

if [ -f "angularStaff/src/app/components/dashboard/dashboard.component.ts" ]; then
    echo "$STATUS_OK dashboard.component.ts trovato"
else
    echo "$STATUS_WARN dashboard.component.ts - Verifica se compilato"
fi

if [ -f "angularStaff/src/app/components/orders/orders.component.ts" ]; then
    echo "$STATUS_OK orders.component.ts trovato"
else
    echo "$STATUS_WARN orders.component.ts - Verifica se compilato"
fi

if [ -f "angularStaff/src/app/components/menu/menu.component.ts" ]; then
    echo "$STATUS_OK menu.component.ts trovato"
else
    echo "$STATUS_WARN menu.component.ts - Verifica se compilato"
fi

if [ -f "angularStaff/package.json" ]; then
    echo "$STATUS_OK package.json trovato"
    if grep -q "@angular/common" angularStaff/package.json; then
        echo "$STATUS_OK @angular/common in package.json"
    fi
else
    echo "$STATUS_ERROR package.json NON TROVATO"
    ((ERRORS++))
fi

echo ""

# ==================== CHECK FLUTTER ====================
echo "📱 CHECK FLUTTER TOTEM CLIENTE"
echo "---"

if [ -f "fluttertotem/lib/main.dart" ]; then
    echo "$STATUS_OK main.dart trovato"
else
    echo "$STATUS_ERROR main.dart NON TROVATO"
    ((ERRORS++))
fi

if [ -f "fluttertotem/lib/services/api_service.dart" ]; then
    echo "$STATUS_OK api_service.dart trovato"
    
    if grep -q "getProducts()" "fluttertotem/lib/services/api_service.dart"; then
        echo "$STATUS_OK Metodo getProducts() nel servizio Flutter"
    fi
    
    if grep -q "createOrder()" "fluttertotem/lib/services/api_service.dart"; then
        echo "$STATUS_OK Metodo createOrder() nel servizio Flutter"
    fi
else
    echo "$STATUS_ERROR api_service.dart NON TROVATO"
    ((ERRORS++))
fi

if [ -f "fluttertotem/lib/screens/home_screen.dart" ]; then
    echo "$STATUS_OK home_screen.dart trovato"
else
    echo "$STATUS_WARN home_screen.dart - Verifica compilazione"
fi

if [ -f "fluttertotem/lib/screens/menu_screen.dart" ]; then
    echo "$STATUS_OK menu_screen.dart trovato"
else
    echo "$STATUS_WARN menu_screen.dart - Verifica compilazione"
fi

if [ -f "fluttertotem/lib/screens/cart_screen.dart" ]; then
    echo "$STATUS_OK cart_screen.dart trovato"
else
    echo "$STATUS_WARN cart_screen.dart - Verifica compilazione"
fi

if [ -f "fluttertotem/pubspec.yaml" ]; then
    echo "$STATUS_OK pubspec.yaml trovato"
    if grep -q "http:" fluttertotem/pubspec.yaml; then
        echo "$STATUS_OK http package in pubspec.yaml"
    fi
else
    echo "$STATUS_ERROR pubspec.yaml NON TROVATO"
    ((ERRORS++))
fi

echo ""

# ==================== CHECK AIVEN ====================
echo "🗄️  CHECK AIVEN / DATABASE"
echo "---"

if [ -f ".env" ]; then
    echo "$STATUS_OK File .env trovato"
    
    if grep -q "DB_HOST=" .env; then
        echo "$STATUS_OK DB_HOST configurato in .env"
    else
        echo "$STATUS_ERROR DB_HOST NON configurato"
        ((ERRORS++))
    fi
    
    if grep -q "DB_USER=" .env; then
        echo "$STATUS_OK DB_USER configurato in .env"
    else
        echo "$STATUS_ERROR DB_USER NON configurato"
        ((ERRORS++))
    fi
    
    if grep -q "DB_PASSWORD=" .env; then
        echo "$STATUS_OK DB_PASSWORD configurato in .env"
    else
        echo "$STATUS_ERROR DB_PASSWORD NON configurato"
        ((ERRORS++))
    fi
else
    echo "$STATUS_WARN File .env NON trovato"
    echo "   → Esegui: cp .env.example .env"
    echo "   → Poi configura le credenziali Aiven"
    ((ERRORS++))
fi

if [ -f ".env.example" ]; then
    echo "$STATUS_OK .env.example trovato (template)"
else
    echo "$STATUS_WARN .env.example NON trovato"
fi

echo ""

# ==================== CHECK DOCUMENTAZIONE ====================
echo "📚 CHECK DOCUMENTAZIONE"
echo "---"

if [ -f "README.md" ]; then
    echo "$STATUS_OK README.md trovato"
else
    echo "$STATUS_WARN README.md NON trovato"
fi

if [ -f "AIVEN_SETUP.md" ]; then
    echo "$STATUS_OK AIVEN_SETUP.md trovato"
else
    echo "$STATUS_WARN AIVEN_SETUP.md NON trovato"
fi

echo ""

# ==================== RIEPILOGO ====================
echo "=============================================="
echo "📊 RIEPILOGO CHECK"
echo "=============================================="

if [ $ERRORS -eq 0 ]; then
    echo "✅ TUTTI I CHECK PASSATI!"
    echo ""
    echo "✨ Il sistema è correttamente configurato:"
    echo "   ✓ Backend Flask"
    echo "   ✓ Database wrapper"
    echo "   ✓ Angular Staff Panel"
    echo "   ✓ Flutter Totem Cliente"
    echo "   ✓ Aiven configurato"
    echo ""
    echo "🚀 Prossimi passi:"
    echo "   1. Terminal 1: python app.py"
    echo "   2. Terminal 2: cd angularStaff && npm install && npm start"
    echo "   3. Terminal 3: cd fluttertotem && flutter pub get && flutter run"
else
    echo "❌ ERRORI TROVATI: $ERRORS"
    echo ""
    echo "🔧 Correggi gli errori evidenziati sopra"
fi

echo ""
