const express = require('express');
const router = express.Router();
const pool = require('../config/database');

// Récupérer les informations du restaurant
router.get('/:restaurantId', async (req, res) => {
    try {
        const { restaurantId } = req.params;

        const result = await pool.query(
            'SELECT * FROM restaurant WHERE id = $1',
            [restaurantId]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Restaurant non trouvé' });
        }

        const restaurant = result.rows[0];
        
        // Formater la réponse
        const response = {
            id: restaurant.id,
            name: restaurant.name,
            maxCapacity: restaurant.max_capacity,
            openingTime: restaurant.opening_time,
            closingTime: restaurant.closing_time,
            serviceDuration: restaurant.service_duration,
            phone: restaurant.phone,
            address: restaurant.address,
            description: restaurant.description,
            imageUrl: restaurant.image_url,
            latitude: restaurant.latitude ? parseFloat(restaurant.latitude) : null,
            longitude: restaurant.longitude ? parseFloat(restaurant.longitude) : null,
            createdAt: restaurant.created_at
        };

        res.json(response);
    } catch (error) {
        console.error('Erreur lors de la récupération du restaurant:', error);
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
