#!/bin/bash

# 🚀 GUIDA VELOCE - VAI SUBITO IN PRODUZIONE

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  🍔 HAMBURGHERIA DAMICO DEG DEGHI - QUICK START           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "🎯 TI SERVONO:"
echo "─────────────────────────────────────"
echo "1. Account Aiven (MySQL)"
echo "2. Python 3.11+"
echo "3. Node.js 18+"
echo "4. Flutter SDK"
echo ""

echo "📋 STEP PER STEP:"
echo "─────────────────────────────────────"
echo ""

echo "STEP 1️⃣  PRENDI LE CREDENZIALI DA AIVEN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Vai su https://console.aiven.io"
echo "2. Clicca sul tuo servizio MySQL"
echo "3. Vai su 'Connection Information'"
echo "4. Copia: Host, Port, User, Password, Database"
echo ""
echo "Esempio:"
echo "  Host: my-instance-abc123.aivencloud.com"
echo "  Port: 21711"
echo "  User: avnadmin"
echo "  Pass: MySecurePassword123"
echo "  DB:   defaultdb"
echo ""

echo "STEP 2️⃣  CREA IL FILE .env"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "cd /path/to/HamburgeriaDamicoDegDeghi"
echo "cp .env.example .env"
echo ""
echo "Modifica .env e incolla Le credenziali:"
echo "─────────────────────────────────────────"
cat << 'EOF'
DB_HOST=your-instance-xxxx.aivencloud.com
DB_USER=avnadmin
DB_PASSWORD=your-password-here
DB_NAME=defaultdb
DB_PORT=21711

FLASK_ENV=development
FLASK_PORT=5000
EOF
echo ""

echo "STEP 3️⃣  AVVIA IL BACKEND FLASK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$ pip install -r requirements.txt"
echo "$ python app.py"
echo ""
echo "✓ Dovresti vedere: '✓ Connesso a database MySQL'"
echo "✓ Backend su: http://localhost:5000"
echo ""

echo "STEP 4️⃣  AVVIA ANGULAR STAFF PANEL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$ cd angularStaff"
echo "$ npm install"
echo "$ npm start"
echo ""
echo "✓ Vai su: http://localhost:4200"
echo "✓ Vedi Dashboard con ordini live"
echo ""

echo "STEP 5️⃣  AVVIA FLUTTER TOTEM CLIENTE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$ cd fluttertotem"
echo "$ flutter pub get"
echo "$ flutter run -d chrome"
echo ""
echo "✓ App si apre nel browser"
echo "✓ Prova a fare un ordine"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ FATTO! Sistema completamente operativo                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "🔗 URL UTILI:"
echo "─────────────────────────────────────"
echo "Backend Health:    http://localhost:5000/api/health"
echo "Backend Products:  http://localhost:5000/api/products"
echo "Dashboard Staff:   http://localhost:4200"
echo "Totem Cliente:     http://localhost:XXXXX (vedi terminal Flutter)"
echo ""

echo "📚 LEGGI LA DOCUMENTAZIONE:"
echo "─────────────────────────────────────"
echo "• CODICE_SPIEGATO.md   - Spiega tutto il codice"
echo "• README.md            - Panoramica generale"
echo "• AIVEN_SETUP.md       - Setup MySQL Aiven"
echo "• RESOCONTO_FINALE.txt - Status completo"
echo ""

echo "🆘 PROBLEMI?"
echo "─────────────────────────────────────"
echo "1. Esegui: bash SYSTEM_CHECK.sh"
echo "2. Leggi CODICE_SPIEGATO.md"
echo "3. Verifica che .env sia configurato"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 PRONTO A PARTIRE? Buona fortuna! 🚀"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
