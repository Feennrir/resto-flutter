# 📋 Document de Rendu - Restaurant Booking App

**Projet** : Application mobile de réservation de tables de restaurant  
**Cours** : Programmation avec Flutter - ESGI  
**Date de rendu** : Dimanche 09 Novembre 2025

---

## 👥 Informations du Groupe

### Membres du Groupe

| Nom | Prénom | Email | Rôle Principal |
|-----|--------|-------|----------------|
| Boileau | Nathan | n.boileau@myskolae.fr | Full-Stack Developer & Chef Projet |
| Lanone | Maxence | m.lanone@myskolae.fr | Full-Stack Developer |

---

## 🎯 Répartition des Tâches

Voir le Kanban sur le repo GitHub : 
![Kanban Board](screenshots/board_overview1.png)
![Kanban Board](screenshots/board_overview2.png)
![Kanban Board](screenshots/board_overview3.png)


- Maxence Lanone :
  - Reservation table avec choix date/heure
  - Ecran d'accueil
  - Page visualisation des menus
  - Valider ou refuser les demandes de réservation
  - localiser le restaurant via une carte interactive
  - Endpoint menu get all (avec param entrée plat desserts)
  - Page profil utilisateur
  - back-office pour gérer les réservations
  - Click sur la map amene sur le gps du tel avec l'adresse prérempli
  - Modifier mes réservations existantes

- Nathan Boileau :
  - Endpoint création reservation
  - Voir le nombre de places disponibles avant reservation
  - Endpoint connexion / inscription
  - Ecran de connexion/inscription
  - Page reservation
  - Menu par categorie
  - Endpoint reservation getAll
  - Annuler une réservation
  - Confirmation par email après reservation
  - Relier API et Profil

---

## 🔑 Identifiants de Test

### Administrateur - Back-office
```
Email : admin@restaurant.com
Mot de passe : admin
```

---

## 📱 Captures d'écran de l'Application

### 1. Menu du restaurant
![Menu Restaurant](screenshots/menu_restaurant.png)
**Description :** Écran affichant le menu complet du restaurant avec différentes catégories (Burgers, Pizzas, Salades, Desserts, Boissons). Sous-catégories accessibles via des onglets.

---
### 2. Restaurant Main Screen
![Restaurant Main Screen](screenshots/restaurant_page.png)
**Description :** Écran principal du restaurant

---
### 3. Reservation Table
![Reservation Table](screenshots/reservation_page.png)
**Description :** Écran de réservation de table avec sélection de la date, de l'heure et du nombre de personnes.

---
### 4. Admin Back-office
![Admin Back-office](screenshots/admin_page.png)
**Description :** Écran d'administration avec divers actions.

---
### 5. Admin validation Reservation
![Admin validation Reservation](screenshots/validate_reservation.png)
**Description :** Écran d'administration pour valider ou refuser les demandes de réservation.

---
### 6. Profile User
![Profile User](screenshots/profile_page.png)
**Description :** Écran de profil utilisateur affichant les informations personnelles et les réservations effectuées.

---
### 7. Profile User Edit
![Profile User Edit](screenshots/profile_edit_user.png)
**Description :** Écran de modification des informations personnelles de l'utilisateur.

---
### 8. Profile edit Reservation
![Profile edit Reservation](screenshots/profile_edit_reservation.png)
**Description :** Écran de modification des réservations existantes par l'utilisateur.


## 📊 Board de Gestion de Projet

### Vue d'ensemble du Board
![Board Overview](screenshots/board_overview.png)

**Description :** Vue globale du board avec toutes les colonnes de workflow.

---

### User Stories - Sprint 1 

**User Stories incluses :**
- ✅ US-001 : En tant qu'utilisateur, je veux créer un compte ou me connecter pour réserver une table ou consulter mes réservations
- ✅ US-002 : En tant qu'utilisateur, je veux voir le menu sans me connecter
- ✅ US-003 : En tant qu'utilisateur, je veux consulter le menu complet
- ✅ US-004 : En tant qu'utilisateur, je veux consulter le menu par catégorie
- ✅ US-005 : En tant qu'utilisateur, je veux réserver une table en choisissant date et heure
- ✅ US-006 : En tant qu'utilisateur, je veux voir le nombre de places disponibles


### User Stories - Sprint 2

**User Stories incluses :**
- ❌ US-007 : En tant qu'utilisateur, je veux modifier mes réservations existantes
- ✅ US-008 : En tant qu'utilisateur, je veux annuler une réservation via l'application
- ✅ US-009 : En tant qu'administrateur, je veux valider ou refuser les demandes de réservation
- ✅ US-010 : En tant qu'utilisateur et admin, je veux recevoir une confirmation par email après une réservation
- ✅ US-011 : En tant qu'utilisateur, je veux localiser le restaurant via une carte interactive
- ✅ US-012 : En tant qu'administrateur, je veux accéder à un back-office pour gérer les réservations et le menu

### User Stories - Sprint 3 (Bonus)

**User Stories bonus incluses :**
- ✅ US-013 : En tant qu'utilisateur, je veux cliquer sur la carte pour ouvrir Apple Maps/Google Maps avec l'adresse
- ✅ US-014 : En tant qu'utilisateur, je veux cliquer sur le numéro de téléphone pour appeler directement
- ✅ US-015 : En tant qu'administrateur, je veux recevoir une notification email à chaque nouvelle réservation
- ✅ US-016 : En tant qu'utilisateur, je veux recevoir un email de confirmation/refus de ma réservation
- ✅ US-017 : En tant qu'utilisateur, je veux profiter d'une interface native iOS (Cupertino)