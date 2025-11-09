const express = require('express');
const router = express.Router();
const pool = require('../config/database');
const authenticateToken = require('../middleware/auth');
const ReservationManager = require('../models/reservation_manager');
const { sendNewReservationNotificationToAdmin } = require('../services/emailService');

// Créer une réservation
router.post('/', authenticateToken, async (req, res) => {
    try {
        const { userId, restaurantId, date, time, partySize, specialRequests } = req.body;

        if (!userId || !restaurantId || !date || !time || !partySize) {
            return res.status(400).json({ error: 'Tous les champs obligatoires doivent être renseignés' });
        }

        if (partySize < 1 || partySize > 20) {
            return res.status(400).json({ error: 'Le nombre de personnes doit être entre 1 et 20' });
        }

        const reservation = await ReservationManager.createReservation(
            userId, restaurantId, date, time, partySize, specialRequests
        );

        // Récupérer les informations complètes pour l'email admin
        try {
            const reservationDetails = await pool.query(`
                SELECT r.*, u.name as user_name, u.email as user_email, u.phone as user_phone,
                       res.name as restaurant_name
                FROM reservations r
                JOIN users u ON r.user_id = u.id
                JOIN restaurant res ON r.restaurant_id = res.id
                WHERE r.id = $1
            `, [reservation.id]);

            if (reservationDetails.rows.length > 0) {
                const details = reservationDetails.rows[0];

                // Récupérer l'email de l'admin
                const adminQuery = await pool.query(`
                    SELECT email FROM users WHERE is_admin = TRUE LIMIT 1
                `);

                if (adminQuery.rows.length > 0) {
                    const adminEmail = adminQuery.rows[0].email;

                    // Envoyer l'email à l'admin
                    await sendNewReservationNotificationToAdmin(
                        adminEmail,
                        {
                            userName: details.user_name,
                            userEmail: details.user_email,
                            userPhone: details.user_phone,
                            restaurantName: details.restaurant_name,
                            date: details.reservation_date,
                            time: details.reservation_time,
                            partySize: details.party_size,
                            specialRequests: details.special_requests,
                            reservationId: details.id
                        }
                    );
                    console.log(`Email de notification envoyé à l'admin ${adminEmail}`);
                }
            }
        } catch (emailError) {
            console.error('Erreur lors de l\'envoi de l\'email à l\'admin:', emailError);
            // On continue même si l'email échoue
        }

        res.status(201).json(reservation);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Vérifier la disponibilité
router.get('/availability', async (req, res) => {
    try {
        const { restaurantId, date, time, partySize } = req.query;

        if (!restaurantId || !date || !time || !partySize) {
            return res.status(400).json({ error: 'Paramètres manquants' });
        }

        const availability = await ReservationManager.checkAvailability(
            restaurantId, date, time, parseInt(partySize)
        );

        res.json(availability);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Récupérer les réservations par date
router.get('/:restaurantId/:date', authenticateToken, async (req, res) => {
    try {
        const { restaurantId, date } = req.params;
        const reservations = await ReservationManager.getReservationsByDate(restaurantId, date);
        res.json(reservations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Annuler une réservation
router.delete('/:reservationId', authenticateToken, async (req, res) => {
    try {
        const { reservationId } = req.params;

        if (!reservationId) {
            return res.status(400).json({ error: 'Paramètres manquants' });
        }

        const result = await ReservationManager.cancelReservation(reservationId);

        res.json({ message: 'Réservation annulée avec succès', reservation: result });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

// Récupérer les créneaux disponibles
router.get('/available-slots/:restaurantId/:date', async (req, res) => {
    try {
        const { restaurantId, date } = req.params;

        // Validation de la date
        const selectedDate = new Date(date);
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        if (selectedDate < today) {
            return res.status(400).json({ error: 'Impossible de réserver dans le passé' });
        }

        const availableSlots = await ReservationManager.getAvailableSlots(restaurantId, date);

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