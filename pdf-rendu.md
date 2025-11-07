# 📋 Document de Rendu - Restaurant Booking App

**Projet** : Application mobile de réservation de tables de restaurant  
**Cours** : Programmation avec Flutter - ESGI  
**Date de rendu** : Vendredi 07 Novembre 2025

---

## 👥 Informations du Groupe

### Membres du Groupe

| Nom | Prénom | Email | Rôle Principal |
|-----|--------|-------|----------------|
| Boileau | Nathan | n.boileau@myskolae.fr | Full-Stack Developer & Chef Projet |
| Lanone | Maxence | m.lanone@myskolae.fr | Full-Stack Developer |

---

## 🎯 Répartition des Tâches

### Nathan Boileau - Chef de Projet & Développeur Full-Stack
**Responsabilités :**
- ✅ Configuration initiale du projet (Flutter + Node.js)
- ✅ Architecture de l'API REST (Express.js)
- ✅ Mise en place de Docker & Docker Compose
- ✅ Endpoints d'authentification (signup, login)
- ✅ Gestion des JWT et sécurité
- ✅ Documentation technique (README.md)
- ✅ Coordination de l'équipe et répartition des tâches

**Temps estimé :** [X heures]

---

### Maxence Lanone - Full-Stack Developer
**Responsabilités :**
- ✅ Architecture Flutter (Repository + ViewModel)
- ✅ Écrans d'authentification (Welcome, Login, Signup)
- ✅ Intégration de l'API avec le service HTTP
- ✅ Gestion de l'état utilisateur (AuthViewModel)
- ✅ Navigation entre les écrans
- ✅ Animations et transitions fluides
- ✅ Widget AuthButton contextuel

**Temps estimé :** [X heures]

---

## 🔑 Identifiants de Test

### Utilisateur Test #1 - Client Standard
```
Email    : john.doe@example.com
Mot de passe : test123456
```
**Description :** Compte utilisateur standard pour tester les fonctionnalités de réservation.

---

### Administrateur - Back-office
```
Email    : admin@restaurant.com
Mot de passe : admin123456
```
**Description :** Compte administrateur pour gérer les réservations (fonctionnalité à venir).

---

## 📱 Captures d'écran de l'Application

### 1. Menu du restaurant
![Menu Restaurant](screenshots/menu_restaurant.png)
**Description :** Écran affichant le menu complet du restaurant avec différentes catégories (Burgers, Pizzas, Salades, Desserts, Boissons). Sous-catégories accessibles via des onglets.

---
### 2. Profile Utilisateur
![Profile Utilisateur](screenshots/profile_utilisateur.png)
**Description :** Écran de profil utilisateur affichant les informations personnelles et les réservations.

---

# AJOUTER DES CAPTURES D'ÉCRAN SUPPLÉMENTAIRES SELON LES FONCTIONNALITÉS IMPLÉMENTÉES


## 📊 Board de Gestion de Projet (Trello/Notion)

### Vue d'ensemble du Board
![Board Overview](screenshots/board_overview.png)

**Description :** Vue globale du board Trello/Notion avec toutes les colonnes de workflow (Backlog, To Do, In Progress, Review, Done).

---

### User Stories - Sprint 1 
![Sprint 1](screenshots/sprint_1_user_stories.png)

**User Stories incluses :**
- US-001 : En tant qu'utilisateur, je veux créer un compte ou me connecter pour réserver une table ou consulter mes réservations
- US-002 : En tant qu'utilisateur, je veux voir le menu sans me connecter
- US-003 : En tant qu'utilisateur, je veux consulter le menu complet
- US-004 : En tant qu'utilisateur, je veux consulter le menu par catégorie
- US-005 : En tant qu'utilisateur, je veux réserver une table en choisissant date et heure
- US-006 : En tant qu'utilisateur, je veux voir le nombre de places disponibles

---

### User Stories - Sprint 2
![Sprint 2](screenshots/sprint_2_user_stories.png)

**User Stories incluses :**
- US-007 : En tant qu'utilisateur, je veux modifier mes réservations existantes
- US-008 : En tant qu'utilisateur, je veux annuler une réservation via l'application
- US-009 : En tant qu'administrateur, je veux valider ou refuser les demandes de réservation
- US-010 : En tant qu'utilisateur et admin, je veux recevoir une confirmation par email après une réservation
- US-011 : En tant qu'utilisateur, je veux localiser le restaurant via une carte interactive
