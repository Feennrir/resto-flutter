const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Configuration PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'postgres',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'restaurant_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

// Rendre la connexion pool disponible pour les routes
app.set('pool', pool);

// Middleware
app.use(cors());
app.use(express.json());

// Test de connexion à la base de données
pool.connect((err, client, release) => {
  if (err) {
    console.error('Erreur de connexion à la base de données:', err);
  } else {
    console.log('✅ Connexion à PostgreSQL réussie');
    release();
  }
});

// Import des routes
const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const dishesRoutes = require('./routes/dishes');

// Routes API
app.use('/api/auth', authRoutes);
app.use('/api/auth/profile', profileRoutes);
app.use('/api/dishes', dishesRoutes);

// Route de santé
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'API fonctionnelle' });
});

// Gestion des routes non trouvées
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Gestion des erreurs globales
app.use((err, req, res, next) => {
  console.error('Erreur serveur:', err);
  res.status(500).json({ error: 'Erreur serveur interne' });
});

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
});