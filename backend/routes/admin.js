const express = require('express');
const router = express.Router();
const adminAuth = require('../middleware/adminAuth');
const pool = require('../config/database');

// Middleware admin pour toutes les routes
router.use(adminAuth);

// ========== GESTION DES RÉSERVATIONS ==========

// Récupérer toutes les réservations en attente
router.get('/reservations/pending', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT r.*, u.name as user_name, u.email as user_email, u.phone as user_phone,
                   res.name as restaurant_name
            FROM reservations r
            JOIN users u ON r.user_id = u.id
            JOIN restaurant res ON r.restaurant_id = res.id
            WHERE r.status = 'pending'
            ORDER BY r.reservation_date ASC, r.reservation_time ASC
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Erreur get pending reservations:', error);
        res.status(500).json({ error: error.message });
    }
});

// Récupérer toutes les réservations
router.get('/reservations', async (req, res) => {
    try {
        const { status, date, restaurantId } = req.query;
        
        let query = `
            SELECT r.*, u.name as user_name, u.email as user_email, u.phone as user_phone,
                   res.name as restaurant_name
            FROM reservations r
            JOIN users u ON r.user_id = u.id
            JOIN restaurant res ON r.restaurant_id = res.id
            WHERE 1=1
        `;
        const params = [];
        let paramCount = 1;

        if (status) {
            query += ` AND r.status = $${paramCount}`;
            params.push(status);
            paramCount++;
        }

        if (date) {
            query += ` AND r.reservation_date = $${paramCount}`;
            params.push(date);
            paramCount++;
        }

        if (restaurantId) {
            query += ` AND r.restaurant_id = $${paramCount}`;
            params.push(restaurantId);
            paramCount++;
        }

        query += ' ORDER BY r.reservation_date DESC, r.reservation_time DESC';

        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (error) {
        console.error('Erreur get all reservations:', error);
        res.status(500).json({ error: error.message });
    }
});

// Accepter une réservation
router.put('/reservations/:id/accept', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(`
            UPDATE reservations 
            SET status = 'confirmed' 
            WHERE id = $1 
            RETURNING *
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Réservation non trouvée' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Erreur accept reservation:', error);
        res.status(500).json({ error: error.message });
    }
});

// Refuser une réservation
router.put('/reservations/:id/reject', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(`
            UPDATE reservations 
            SET status = 'cancelled' 
            WHERE id = $1 
            RETURNING *
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Réservation non trouvée' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Erreur reject reservation:', error);
        res.status(500).json({ error: error.message });
    }
});

// Modifier le statut d'une réservation
router.put('/reservations/:id/status', async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        const validStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ 
                error: `Statut invalide. Valeurs autorisées: ${validStatuses.join(', ')}` 
            });
        }

        const result = await pool.query(`
            UPDATE reservations 
            SET status = $1 
            WHERE id = $2 
            RETURNING *
        `, [status, id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Réservation non trouvée' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Erreur update reservation status:', error);
        res.status(500).json({ error: error.message });
    }
});

// ========== GESTION DES PLATS ==========

// Récupérer tous les plats (incluant indisponibles)
router.get('/dishes', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT * FROM dishes 
            ORDER BY category, name
        `);
        res.json(result.rows);
    } catch (error) {
        console.error('Erreur get all dishes:', error);
        res.status(500).json({ error: error.message });
    }
});

// Créer un nouveau plat
router.post('/dishes', async (req, res) => {
    try {
        const { name, description, price, category, image_url, is_available } = req.body;

        if (!name || !price || !category) {
            return res.status(400).json({ 
                error: 'Les champs name, price et category sont requis' 
            });
        }

        const result = await pool.query(`
            INSERT INTO dishes (name, description, price, category, image_url, is_available)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
        `, [name, description, price, category, image_url, is_available ?? true]);

        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Erreur create dish:', error);
        res.status(500).json({ error: error.message });
    }
});

// Modifier un plat
router.put('/dishes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, description, price, category, image_url, is_available } = req.body;

        const result = await pool.query(`
            UPDATE dishes 
            SET name = COALESCE($1, name),
                description = COALESCE($2, description),
                price = COALESCE($3, price),
                category = COALESCE($4, category),
                image_url = COALESCE($5, image_url),
                is_available = COALESCE($6, is_available)
            WHERE id = $7
            RETURNING *
        `, [name, description, price, category, image_url, is_available, id]);

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Plat non trouvé' });
        }

        res.json(result.rows[0]);
    } catch (error) {
        console.error('Erreur update dish:', error);
        res.status(500).json({ error: error.message });
    }
});

// Supprimer un plat
router.delete('/dishes/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            'DELETE FROM dishes WHERE id = $1 RETURNING *',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Plat non trouvé' });
        }

        res.json({ message: 'Plat supprimé avec succès', dish: result.rows[0] });
    } catch (error) {
        console.error('Erreur delete dish:', error);
        res.status(500).json({ error: error.message });
    }
});

// ========== STATISTIQUES ==========

// Récupérer les statistiques du restaurant
router.get('/stats', async (req, res) => {
    try {
        console.log('📊 Récupération des statistiques admin...');
        
        // Réservations en attente
        const pendingReservations = await pool.query(`
            SELECT COUNT(*) as total 
            FROM reservations 
            WHERE status = 'pending'
        `);
        
        // Réservations aujourd'hui
        const todayReservations = await pool.query(`
            SELECT COUNT(*) as total 
            FROM reservations 
            WHERE reservation_date = CURRENT_DATE
            AND status IN ('confirmed', 'pending')
        `);
        
        // Nombre total de plats
        const dishesCount = await pool.query('SELECT COUNT(*) as total FROM dishes');
        
        // Plats disponibles
        const availableDishes = await pool.query(`
            SELECT COUNT(*) as total 
            FROM dishes 
            WHERE is_available = true
        `);

        const stats = {
            pendingReservations: parseInt(pendingReservations.rows[0].total),
            todayReservations: parseInt(todayReservations.rows[0].total),
            totalDishes: parseInt(dishesCount.rows[0].total),
            availableDishes: parseInt(availableDishes.rows[0].total)
        };

        console.log('✅ Statistiques récupérées:', stats);
        res.json(stats);
    } catch (error) {
        console.error('❌ Erreur get stats:', error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;