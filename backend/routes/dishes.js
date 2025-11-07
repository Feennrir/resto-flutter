const express = require('express');
const router = express.Router();

// Récupérer tous les plats
router.get('/', async (req, res) => {
  const pool = req.app.get('pool');

  try {
    const result = await pool.query('SELECT * FROM dishes ORDER BY category, name');
    res.json(result.rows);
  } catch (error) {
    console.error('Erreur lors de la récupération des plats:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer un plat par ID
router.get('/:id', async (req, res) => {
  const pool = req.app.get('pool');
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

module.exports = router;