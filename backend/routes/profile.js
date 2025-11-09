const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const authenticateToken = require('../middleware/auth');

// Récupérer le profil de l'utilisateur connecté
router.get('/', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, email, phone, created_at, updated_at FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    const user = result.rows[0];

    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      createdAt: user.created_at,
      updatedAt: user.updated_at
    });
  } catch (error) {
    console.error('Erreur lors de la récupération du profil:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Mettre à jour le profil de l'utilisateur connecté
router.put('/', authenticateToken, async (req, res) => {
  const { name, phone } = req.body;

  try {
    // Vérifier que l'utilisateur existe
    const userCheck = await pool.query('SELECT id FROM users WHERE id = $1', [req.user.id]);
    
    if (userCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    // Mettre à jour les informations
    const result = await pool.query(
      'UPDATE users SET name = COALESCE($1, name), phone = COALESCE($2, phone), updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING id, name, email, phone, created_at, updated_at',
      [name || null, phone || null, req.user.id]
    );

    const user = result.rows[0];

    res.json({
      message: 'Profil mis à jour avec succès',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        createdAt: user.created_at,
        updatedAt: user.updated_at
      }
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

module.exports = router;