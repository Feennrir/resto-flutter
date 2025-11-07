const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const ReservationManager = require("../models/reservation_manager");

router.post('/', authenticateToken, async (req, res) => {
    const pool = req.app.get('pool');
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
router.get('/availability', async (req, res) => {
    const pool = req.app.get('pool');
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
router.get('/:restaurantId/:date', authenticateToken, async (req, res) => {
    const pool = req.app.get('pool');
    try {
        const { restaurantId, date } = req.params;
        const reservationManager = new ReservationManager(pool);
        const reservations = await reservationManager.getReservationsByDate(restaurantId, date);
        res.json(reservations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/available-slots/:restaurantId/:date', async (req, res) => {
    const pool = req.app.get('pool');
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

module.exports = router;