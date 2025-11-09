const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');

// Inscription
router.post('/signup', async (req, res) => {
  try {
    const pool = req.app.get('pool');
    const { name, email, password, phone } = req.body;

    // Validation
    if (!name || !email || !password) {
      return res.status(400).json({ error: 'Tous les champs sont requis' });
    }

    // Vérifier si l'email existe déjà
    const existingUsers = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUsers.rows.length > 0) {
      return res.status(409).json({ error: 'Cet email est déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insérer le nouvel utilisateur
    const result = await pool.query(
      'INSERT INTO users (name, email, password, phone) VALUES ($1, $2, $3, $4) RETURNING id',
      [name, email, hashedPassword, phone || null]
    );

    // Récupérer l'utilisateur créé AVEC is_admin
    const newUsers = await pool.query(
      'SELECT id, email, name, phone, created_at, is_admin FROM users WHERE id = $1',
      [result.rows[0].id]
    );

    const user = newUsers.rows[0];

    // Générer le token JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'votre_secret_jwt_super_securise',
      { expiresIn: '7d' }
    );

    res.status(201).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        created_at: user.created_at,
        is_admin: user.is_admin || false
      }
    });
  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Connexion
router.post('/login', async (req, res) => {
  try {
    const pool = req.app.get('pool');
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ error: 'Email et mot de passe requis' });
    }

    // Rechercher l'utilisateur avec is_admin
    const users = await pool.query(
      'SELECT id, email, password, name, phone, created_at, is_admin FROM users WHERE email = $1',
      [email]
    );

    if (users.rows.length === 0) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const user = users.rows[0];

    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    // Générer le token JWT
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'votre_secret_jwt_super_securise',
      { expiresIn: '7d' }
    );

    // Retourner les données utilisateur AVEC is_admin
    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        phone: user.phone,
        created_at: user.created_at,
        is_admin: user.is_admin || false
      }
    });
  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.get('/users/:userId/reservations', authenticateToken, async (req, res) => {
  const pool = req.app.get('pool');
  const { userId } = req.params;

  try {
    const result = await pool.query(`
      SELECT r.id, r.reservation_date, r.reservation_time, r.party_size, r.status, r.special_requests, r.created_at
      FROM reservations r
      WHERE r.user_id = $1
      ORDER BY r.reservation_date DESC, r.reservation_time DESC
    `, [parseInt(userId)]);

    // Formater les données selon le format demandé
    const reservations = result.rows.map(reservation => {
        const reservationDateTime = new Date(
            `${reservation.reservation_date.toISOString().split('T')[0]}T${reservation.reservation_time}`
        );
      const now = new Date();

      return {
        id: reservation.id,
        date: new Date(reservation.reservation_date).toLocaleDateString('fr-FR'),
        time: reservation.reservation_time.slice(0, 5), // Format HH:MM
        guests: reservation.party_size,
        status: reservation.status,
        isUpcoming: reservationDateTime > now,
        restaurantName: reservation.restaurant_name,
        specialRequests: reservation.special_requests
      };
    });

    res.json(reservations);
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;