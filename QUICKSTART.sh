#!/bin/bash

# 🍔 Quick Start Script - Hamburgheria Damico Deg Deghi

echo "🍔 Hamburgheria Damico Deg Deghi - Setup"
echo "========================================"
echo ""

# Verifica se .env esiste
if [ ! -f .env ]; then
    echo "⚠️  File .env non trovato!"
    echo "📋 Copia .env.example a .env e configura le credenziali Aiven"
    echo ""
    cp .env.example .env
    echo "✅ Creato .env.example - compila le credenziali!"
    exit 1
fi

echo "✅ File .env trovato"
echo ""

# Backend
echo "🚀 Avvio Backend Flask..."
echo ""
echo "1. Python 3.11+:"
python3 --version
echo ""
echo "2. Installa dipendenze:"
pip install -r requirements.txt
echo ""
echo "3. Avvia server:"
echo "   python app.py"
echo ""
echo "   Backend disponibile su: http://localhost:5000"
echo "   Test: http://localhost:5000/api/health"
echo ""

# Angular
echo "🌐 Pannello Staff (Angular)..."
echo ""
echo "1. Vai nella cartella:"
echo "   cd angularStaff"
echo ""
echo "2. Installa dipendenze:"
echo "   npm install"
echo ""
echo "3. Avvia server di sviluppo:"
echo "   npm start"
echo ""
echo "   Staff disponibile su: http://localhost:4200"
echo ""

# Flutter
echo "📱 Totem Cliente (Flutter)..."
echo ""
echo "1. Vai nella cartella:"
echo "   cd fluttertotem"
echo ""
echo "2. Installa dipendenze:"
echo "   flutter pub get"
echo ""
echo "3. Avvia app:"
echo "   flutter run -d chrome  (Web)"
echo "   flutter run -d android (Android)"
echo ""

echo "========================================"
echo "📚 Leggi i file:"
echo "- README.md - Documentazione completa"
echo "- AIVEN_SETUP.md - Setup MySQL Aiven"
echo "========================================"
