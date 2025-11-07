const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
require('dotenv').config();
const ReservationManager = require('./models/reservation_manager');

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

// ============================================
// ROUTES D'AUTHENTIFICATION
// ============================================

// Inscription
app.post('/api/auth/signup', async (req, res) => {
  const { name, email, password } = req.body;

  // Validation
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Tous les champs sont requis' });
  }

  if (password.length < 6) {
    return res.status(400).json({ error: 'Le mot de passe doit contenir au moins 6 caractères' });
  }

  try {
    // Vérifier si l'utilisateur existe déjà
    const userExists = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (userExists.rows.length > 0) {
      return res.status(409).json({ error: 'Cet email est déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Créer l'utilisateur
    const result = await pool.query(
      'INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email, created_at',
      [name, email, hashedPassword]
    );

    const user = result.rows[0];

    // Générer un token JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'secret_key_change_in_production',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      message: 'Inscription réussie',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.created_at
      },
      token
    });
  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Connexion
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;

  // Validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email et mot de passe requis' });
  }

  try {
    // Récupérer l'utilisateur
    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const user = result.rows[0];

    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(password, user.password);

    if (!validPassword) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    // Générer un token JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'secret_key_change_in_production',
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Connexion réussie',
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token
    });
  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ============================================
// ROUTES DES PLATS
// ============================================

// Récupérer tous les plats
app.get('/api/dishes', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM dishes ORDER BY category, name');
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des plats:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer un plat par ID
app.get('/api/dishes/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('SELECT * FROM dishes WHERE id = $1', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Plat non trouvé' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Erreur lors de la récupération du plat:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ============================================
// ROUTE DE SANTÉ
// ============================================

app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'API fonctionnelle' });
});

// Démarrage du serveur
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`);
});

// Créer une réservation
app.post('/api/reservations', async (req, res) => {
    try {
        const { userId, restaurantId, date, time, partySize, specialRequests } = req.body;

        if (!userId || !restaurantId || !date || !time || !partySize) {
            return res.status(400).json({ error: 'Tous les champs obligatoires doivent être renseignés' });
        }

        if (partySize < 1 || partySize > 20) {
            return res.status(400).json({ error: 'Le nombre de personnes doit être entre 1 et 20' });
        }

        const reservationManager = new ReservationManager(pool);

        const reservation = await reservationManager.createReservation(
            userId, restaurantId, date, time, partySize, specialRequests
        );

        res.status(201).json(reservation);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Vérifier la disponibilité
app.get('/api/reservations/availability', async (req, res) => {
    try {
        const { restaurantId, date, time, partySize } = req.query;

        if (!restaurantId || !date || !time || !partySize) {
            return res.status(400).json({ error: 'Paramètres manquants' });
        }
        const reservationManager = new ReservationManager(pool);

        const availability = await reservationManager.checkAvailability(
            restaurantId, date, time, parseInt(partySize)
        );

        res.json(availability);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Récupérer les réservations par date
app.get('/api/reservations/:restaurantId/:date', async (req, res) => {
    try {
        const { restaurantId, date } = req.params;
        const reservationManager = new ReservationManager(pool);
        const reservations = await reservationManager.getReservationsByDate(restaurantId, date);
        res.json(reservations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/reservations/available-slots/:restaurantId/:date', async (req, res) => {
    try {
        const { restaurantId, date } = req.params;

        // Validation de la date
        const selectedDate = new Date(date);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (selectedDate < today) {
            return res.status(400).json({ error: 'Impossible de réserver dans le passé' });
        }

        const reservationManager = new ReservationManager(pool);
        const availableSlots = await reservationManager.getAvailableSlots(restaurantId, date);

        return res.json({
            date,
            restaurantId: parseInt(restaurantId),
            availableSlots
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});