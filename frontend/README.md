# Restaurant Menu - Le Gourmet

Application Flutter de menu de restaurant avec système de commande et panier.

## Fonctionnalités

### 📱 Interface Utilisateur
- **Design iOS natif** avec composants Cupertino
- **Navigation fluide** entre les écrans
- **Interface responsive** et moderne

### Menu du Restaurant
- **Affichage par catégories** : Entrées, Plats, Desserts, Boissons
- **Liste scrollable** avec images des plats
- **Cartes détaillées** pour chaque plat avec :
    - Image en plein écran
    - Nom et description
    - Prix
    - Catégorie

### Système de Panier
- **Ajout d'articles** avec sélection de quantité (1-10)
- **Gestion du panier** :
    - Modification des quantités (+/-)
    - Suppression d'articles
    - Calcul du total automatique
- **Persistance locale** avec SharedPreferences :
    - Le panier est sauvegardé automatiquement
    - Restauration du panier au redémarrage de l'app
- **Accès rapide** via bouton panier dans la barre de navigation

### Stockage
- **LocalStorage** : Sauvegarde persistante du panier entre les sessions
- **Sérialisation JSON** : Conversion automatique des données

## Technologies Utilisées

- **Flutter** : Framework cross-platform
- **Dart** : Langage de programmation
- **Cupertino** : Design system iOS
- **SharedPreferences** : Stockage local clé-valeur

## Installation

1. Cloner le repository
2. Installer les dépendances :
```bash
flutter pub get
```
1. Lancer l'application :
```bash
flutter run
```
## Contribution