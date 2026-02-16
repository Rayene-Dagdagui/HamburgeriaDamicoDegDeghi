# 🔐 Guida Setup MySQL Aiven

## Passo 1: Crea Account Aiven
1. Vai su https://aiven.io
2. Registrati con email
3. Crea nuovo progetto

## Passo 2: Crea Servizio MySQL
1. Nel dashboard Aiven, clicca **"Create Service"**
2. Seleziona **MySQL**
3. Configura:
   - **Cloud Provider:** Cloud di tua scelta (AWS, Google Cloud, Azure)
   - **Region:** Scegli la regione più vicina
   - **Service Plan:** Inizia con il piano gratuito o "Business-4" per test
4. Clicca **"Create service"**

**Attendi 3-5 minuti per la creazione**

## Passo 3: Ottieni le Credenziali
1. Una volta creato il servizio, apri il servizio MySQL
2. Vai nella sezione **"Overview"**
3. Scorri fino a **"Connection Information"**

Troverai:

```
Host: your-instance-name-xxxx.aivencloud.com
Port: 21711 (di solito)
User: avnadmin
Password: [la password viene mostrata qui]
Database: defaultdb
```

## Passo 4: Configura il File .env

```bash
cd /path/to/HamburgeriaDamicoDegDeghi
cp .env.example .env
```

Modifica `.env`:

```env
DB_HOST=your-instance-name-xxxx.aivencloud.com
DB_USER=avnadmin
DB_PASSWORD=PasteYourPasswordHere
DB_NAME=defaultdb
DB_PORT=21711

FLASK_ENV=development
FLASK_PORT=5000
```

## Passo 5: Testa la Connessione

```bash
python app.py
```

Dovresti vedere:
```
✓ Connesso a database MySQL
✓ Database inizializzato
 * Running on http://0.0.0.0:5000
```

## ⚠️ Sicurezza - Non Fare!

❌ **Non committare** il file `.env` nel git:

```bash
# Il file .env è già in .gitignore
# ma verifica con: git check-ignore .env
```

## 🆘 Se non funziona

### Errore: "Can't connect to MySQL"
- Controlla che la password sia corretta
- Verifica il security group di Aiven (allowlist IP)
- Verifica la connessione internet

### Errore: "Unknown database"
- Su Aiven, il database di default è `defaultdb`
- Altrimenti, crea un nuovo DB dai Connection Details

### Errore: "Access denied for user"
- Controlla username (di solito è `avnadmin`)
- Verifica password nel menu Aiven

---

## 📋 Comandi Utili

### Connessione MySQL via CLI
```bash
mysql -h your-host.aivencloud.com -P 21711 -u avnadmin -p
# Inserisci password quando richiesto
```

### Visualizzare i dati
```sql
USE defaultdb;
SHOW TABLES;
SELECT * FROM products;
SELECT * FROM orders;
```

---

## 💡 Bonus: Backup Aiven

Aiven esegue backup automatici. Per verificare:
1. Nel dashboard Aiven
2. Vai su **"Backups"**
3. Potrai vedere i backup automatici

Per ripristinare: Apri il ticket di supporto Aiven.

---

## 🎯 Prossimi Step

1. ✅ Database configurato
2. ✅ Backend Flask funzionante
3. ✅ Poi avvia Angular staff
4. ✅ Poi avvia Flutter totem

Buon sviluppo! 🚀
