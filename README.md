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

- ✅ **Stockage en base de données** : Toutes les réservations sont enregistrées en PostgreSQL
- ✅ **Vérification de disponibilité** : Affichage du nombre de places restantes par créneau horaire (ex: 14h = 7 places)
- ✅ **Modification de réservation** : Interface permettant à l'utilisateur de modifier ses réservations existantes
- ✅ **Suppression de réservation** : Possibilité d'annuler une réservation via l'application
- ✅ **Back-office hôte** : Écran d'administration pour valider ou refuser les demandes de réservation

### 🌟 Fonctionnalités bonus

- ❌ **Gestion intelligente des tables** : Attribution automatique des tables selon le nombre de personnes (1 personne = table de 2)
- ✅ **Notifications email** : Email de confirmation/refus automatique pour l'utilisateur et notification à l'hôte
- ✅ **Intégration Carte** : Carte interactive pour localiser le restaurant avec ouverture Apple Maps/Google Maps
- ✅ **Appel téléphonique** : Clic sur le numéro de téléphone pour appeler directement le restaurant
- ✅ **Interface native iOS** : Design Cupertino pour une expérience utilisateur optimale sur iOS

## 🛠️ Stack Technique

### Frontend
- **Framework** : Flutter ^3.35.0
- **Langage** : Dart
- **HTTP Client** : package `http` ^1.1.0
- **Stockage local** : SharedPreferences ^2.2.2
- **Cartographie** : flutter_map ^7.0.2 + latlong2 ^0.9.1
- **Navigation** : modal_bottom_sheet ^3.0.0
- **URL Launcher** : url_launcher ^6.2.1 (pour cartes et téléphone)
- **Interface** : Cupertino (iOS native)

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

### 2. Démarrer le Backend (API + Base de données + Serveur SMTP)

```bash
cd backend

# Démarrer les conteneurs Docker (PostgreSQL + API + Serveur SMTP)
docker-compose up -d

# Vérifier que les services sont actifs
docker-compose ps
```

L'API sera accessible sur `http://localhost:3000`

La base de données PostgreSQL sera sur le port `5432`

Le serveur SMTP (MailHog) sera sur le port `1025` (SMTP) et l'interface web sur `http://localhost:8025`

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

### Réservations

| Méthode | Endpoint | Description | Auth requise |
|---------|----------|-------------|--------------|
| POST | `/api/reservation` | Créer une réservation | Oui |
| GET | `/api/reservation/availability` | Vérifier disponibilité | Non |
| GET | `/api/reservation/:restaurantId/:date` | Réservations par date | Oui |
| DELETE | `/api/reservation/:reservationId` | Annuler une réservation | Oui |
| GET | `/api/reservation/available-slots/:restaurantId/:date` | Créneaux disponibles | Non |

### Profil utilisateur

| Méthode | Endpoint | Description | Auth requise |
|---------|----------|-------------|--------------|
| GET | `/api/profile/reservations` | Réservations de l'utilisateur | Oui |
| PUT | `/api/profile/reservations/:id` | Modifier une réservation | Oui |

### Restaurant

| Méthode | Endpoint | Description | Auth requise |
|---------|----------|-------------|--------------|
| GET | `/api/restaurant/:id` | Informations du restaurant | Non |

### Administration (Back-office)

| Méthode | Endpoint | Description | Auth requise |
|---------|----------|-------------|--------------|
| GET | `/api/admin/reservations/pending` | Réservations en attente | Admin |
| GET | `/api/admin/reservations` | Toutes les réservations | Admin |
| PUT | `/api/admin/reservations/:id/accept` | Accepter une réservation | Admin |
| PUT | `/api/admin/reservations/:id/reject` | Refuser une réservation | Admin |
| PUT | `/api/admin/reservations/:id/status` | Changer le statut | Admin |
| GET | `/api/admin/dishes` | Gérer les plats | Admin |
| POST | `/api/admin/dishes` | Créer un plat | Admin |
| PUT | `/api/admin/dishes/:id` | Modifier un plat | Admin |
| DELETE | `/api/admin/dishes/:id` | Supprimer un plat | Admin |
| GET | `/api/admin/stats` | Statistiques du restaurant | Admin |

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
- phone (VARCHAR)
- is_admin (BOOLEAN DEFAULT FALSE)
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

**reservations**
```sql
- id (SERIAL PRIMARY KEY)
- user_id (INTEGER REFERENCES users(id))
- restaurant_id (INTEGER)
- reservation_date (DATE)
- reservation_time (VARCHAR)
- party_size (INTEGER)
- status (VARCHAR) -- 'pending', 'confirmed', 'cancelled', 'completed'
- special_requests (TEXT)
- created_at (TIMESTAMP)
```

**restaurant**
```sql
- id (SERIAL PRIMARY KEY)
- name (VARCHAR)
- description (TEXT)
- address (TEXT)
- phone (VARCHAR)
- email (VARCHAR)
- latitude (DECIMAL)
- longitude (DECIMAL)
- max_capacity (INTEGER)
- opening_hours (JSONB)
- image_url (TEXT)
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

# Connexion
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Créer une réservation (avec token)
curl -X POST http://localhost:3000/api/reservation \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"userId":1,"restaurantId":1,"date":"2025-11-15","time":"19:00","partySize":2,"specialRequests":"Table près de la fenêtre"}'
```

## 🔐 Sécurité

- Mots de passe hashés avec bcrypt (salt rounds: 10)
- Authentification par JWT avec expiration (7 jours)
- Middleware d'authentification pour les routes protégées
- Middleware d'autorisation admin pour le back-office
- Validation des données côté serveur
- Headers CORS configurés
- Variables d'environnement pour les secrets
- Protection contre les injections SQL avec des requêtes paramétrées

## 📝 Licence

Ce projet est un projet éducatif développé dans le cadre d'un cours de programmation mobile.

## 👥 Contribution

Nathan Boileau - [GitHub](https://github.com/Feennrir)
Maxence Lanone - [GitHub](https://github.com/Jaxonce)

---

**Note** : Ce projet est à des fins éducatives. Ne pas utiliser en production sans renforcer la sécurité et implémenter des tests complets.