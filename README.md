# 🍽️ Restaurant Booking App

Application mobile de réservation de tables de restaurant développée avec Flutter et Node.js.

## 📱 Description

Cette application permet aux utilisateurs de réserver une table dans un restaurant directement depuis leur smartphone. Les clients peuvent consulter le menu, créer un compte, se connecter et effectuer des réservations en choisissant la date, l'heure et le nombre de personnes.

L'application offre une expérience utilisateur fluide avec un design iOS natif (Cupertino).

## 🚀 Fonctionnalités

### ✅ Fonctionnalités obligatoires

- ✅ **Affichage du menu** : Consultation du menu complet avec catégories (Burgers, Pizzas, Salades, Desserts, Boissons) accessible sans connexion
- ✅ **Inscription utilisateur** : Création de compte avec nom, email et mot de passe (minimum 6 caractères)
- ✅ **Connexion utilisateur** : Authentification sécurisée avec JWT et stockage persistant de la session
- ✅ **Formulaire de réservation** : Sélection de la date, heure et nombre de personnes pour réserver une table

### 🎯 Fonctionnalités avancées

- ❌ **Stockage en base de données** : Toutes les réservations sont enregistrées en PostgreSQL
- ❌ **Vérification de disponibilité** : Affichage du nombre de places restantes par créneau horaire (ex: 14h = 7 places)
- ❌ **Modification de réservation** : Interface permettant à l'utilisateur de modifier ses réservations existantes
- ❌ **Suppression de réservation** : Possibilité d'annuler une réservation via l'application
- ❌ **Back-office hôte** : Écran d'administration pour valider ou refuser les demandes de réservation

### 🌟 Fonctionnalités bonus

- ❌ **Gestion intelligente des tables** : Attribution automatique des tables selon le nombre de personnes (1 personne = table de 2)
- ❌ **Notifications email** : Email de confirmation automatique pour l'utilisateur et l'hôte
- ✅ **Intégration Google Maps** : Carte interactive pour localiser le restaurant

## 🛠️ Stack Technique

### Frontend
- **Framework** : Flutter ^3.35
- **Langage** : Dart
- **HTTP Client** : package `http`
- **Stockage local** : SharedPreferences

### Backend
- **Runtime** : Node.js
- **Framework** : Express.js
- **Base de données** : PostgreSQL
- **Authentication** : JWT (JSON Web Tokens)
- **Hashing** : bcrypt
- **Conteneurisation** : Docker & Docker Compose

## 🔧 Installation

### 1. Cloner le projet

```bash
git clone https://github.com/Feennrir/resto-flutter
cd resto-flutter
```

### 2. Démarrer le Backend (API + Base de données)

```bash
cd backend

# Installer les dépendances Node.js
npm install

# Démarrer les conteneurs Docker (PostgreSQL + API)
docker-compose up -d

# Vérifier que les services sont actifs
docker-compose ps
```

L'API sera accessible sur `http://localhost:3000`

La base de données PostgreSQL sera sur le port `5432`

### 3. Configurer le Frontend Flutter

```bash
cd ../frontend

# Installer les dépendances Flutter
flutter pub get
```

### 4. Configurer l'URL de l'API

Modifiez le fichier `frontend/lib/services/api_service.dart` :

```dart
// Pour iOS Simulator
static const String baseUrl = 'http://localhost:3000/api';

// Pour Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000/api';

// Pour device physique (remplacez par votre IP locale)
static const String baseUrl = 'http://192.168.1.X:3000/api';
```

### 5. Lancer l'application

```bash
# Depuis le dossier frontend/
flutter devices
flutter run -d <device_id>
```

## 📁 Structure du Projet

```

```

## 🔌 API Endpoints

### Authentification

| Méthode | Endpoint | Description | Auth requise |
|---------|----------|-------------|--------------|
| POST | `/api/auth/signup` | Inscription utilisateur | Non |
| POST | `/api/auth/login` | Connexion utilisateur | Non |

### Plats

| Méthode | Endpoint | Description | Auth requise |
|---------|----------|-------------|--------------|
| GET | `/api/dishes` | Liste tous les plats | Non |
| GET | `/api/dishes/:id` | Détails d'un plat | Non |

### Health Check

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/health` | Vérifier l'état de l'API |

## 🗄️ Base de Données

### Tables principales

**users**
```sql
- id (SERIAL PRIMARY KEY)
- name (VARCHAR)
- email (VARCHAR UNIQUE)
- password (VARCHAR) -- hashé avec bcrypt
- created_at (TIMESTAMP)
```

**dishes**
```sql
- id (SERIAL PRIMARY KEY)
- name (VARCHAR)
- description (TEXT)
- price (DECIMAL)
- category (VARCHAR)
- image_url (TEXT)
- is_available (BOOLEAN)
- created_at (TIMESTAMP)
```

## 🧪 Tests

### Tester l'API

```bash
# Health check
curl http://localhost:3000/health

# Récupérer les plats
curl http://localhost:3000/api/dishes

# Inscription
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"test123"}'
```

## 🔐 Sécurité

- Mots de passe hashés avec bcrypt (salt rounds: 10)
- Authentification par JWT avec expiration (7 jours)
- Validation des données côté serveur
- Headers CORS configurés
- Variables d'environnement pour les secrets

## 📝 Licence

Ce projet est un projet éducatif développé dans le cadre d'un cours de programmation mobile.

## 👥 Contribution

Nathan Boileau - [GitHub](https://github.com/Feennrir)
Maxence Lanone - [GitHub](https://github.com/Jaxonce)

---

**Note** : Ce projet est à des fins éducatives. Ne pas utiliser en production sans renforcer la sécurité et implémenter des tests complets.