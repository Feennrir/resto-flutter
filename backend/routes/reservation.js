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

// Modifier une réservation
router.put('/:reservationId', authenticateToken, async (req, res) => {
    try {
        const { reservationId } = req.params;
        const { date, time, guests, specialRequests } = req.body;
        const userId = req.user.id;

        if (!reservationId) {
            return res.status(400).json({ error: 'ID de réservation manquant' });
        }

        // Vérifier que la réservation existe et appartient à l'utilisateur
        const existingReservation = await pool.query(`
            SELECT * FROM reservations 
            WHERE id = $1 AND user_id = $2
        `, [reservationId, userId]);

        if (existingReservation.rows.length === 0) {
            return res.status(404).json({ error: 'Réservation non trouvée ou non autorisée' });
        }

        const reservation = existingReservation.rows[0];

        // Vérifier que la réservation peut encore être modifiée (pas annulée ou terminée)
        if (reservation.status === 'cancelled' || reservation.status === 'completed') {
            return res.status(400).json({ error: 'Cette réservation ne peut plus être modifiée' });
        }

        // Validation des données
        if (date && new Date(date) < new Date()) {
            return res.status(400).json({ error: 'Impossible de réserver dans le passé' });
        }

        if (guests && (guests < 1 || guests > 20)) {
            return res.status(400).json({ error: 'Le nombre de personnes doit être entre 1 et 20' });
        }

        // Si la date ou l'heure change, vérifier la disponibilité
        if ((date && date !== reservation.reservation_date.toISOString().split('T')[0]) || 
            (time && time !== reservation.reservation_time) ||
            (guests && guests !== reservation.party_size)) {
            
            const newDate = date || reservation.reservation_date.toISOString().split('T')[0];
            const newTime = time || reservation.reservation_time;
            const newGuests = guests || reservation.party_size;

            const availability = await ReservationManager.checkAvailability(
                reservation.restaurant_id, newDate, newTime, newGuests
            );

            if (!availability.available) {
                return res.status(400).json({ error: 'Créneau non disponible pour ce nombre de personnes' });
            }
        }

        // Mettre à jour la réservation
        const updateQuery = `
            UPDATE reservations 
            SET reservation_date = COALESCE($1, reservation_date),
                reservation_time = COALESCE($2, reservation_time),
                party_size = COALESCE($3, party_size),
                special_requests = COALESCE($4, special_requests),
                status = CASE 
                    WHEN status = 'confirmed' AND ($1 IS NOT NULL OR $2 IS NOT NULL OR $3 IS NOT NULL) 
                    THEN 'pending'
                    ELSE status
                END
            WHERE id = $5 AND user_id = $6
            RETURNING *
        `;

        const result = await pool.query(updateQuery, [
            date || null,
            time || null,
            guests || null,
            specialRequests || null,
            reservationId,
            userId
        ]);

        const updatedReservation = result.rows[0];

        // Si des modifications importantes ont été faites à une réservation confirmée, notifier l'admin
        if (reservation.status === 'confirmed' && 
            (date || time || guests) && 
            updatedReservation.status === 'pending') {
            
            try {
                // Récupérer les informations pour l'email admin
                const reservationDetails = await pool.query(`
                    SELECT r.*, u.name as user_name, u.email as user_email, u.phone as user_phone,
                           res.name as restaurant_name
                    FROM reservations r
                    JOIN users u ON r.user_id = u.id
                    JOIN restaurant res ON r.restaurant_id = res.id
                    WHERE r.id = $1
                `, [reservationId]);

                if (reservationDetails.rows.length > 0) {
                    const details = reservationDetails.rows[0];

                    // Récupérer l'email de l'admin
                    const adminQuery = await pool.query(`
                        SELECT email FROM users WHERE is_admin = TRUE LIMIT 1
                    `);

                    if (adminQuery.rows.length > 0) {
                        const adminEmail = adminQuery.rows[0].email;

                        // Envoyer notification de modification à l'admin
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
                                reservationId: details.id,
                                isModification: true
                            }
                        );
                        console.log(`Email de notification de modification envoyé à l'admin ${adminEmail}`);
                    }
                }
            } catch (emailError) {
                console.error('Erreur lors de l\'envoi de l\'email à l\'admin:', emailError);
                // On continue même si l'email échoue
            }
        }

        res.json({ 
            message: 'Réservation mise à jour avec succès', 
            reservation: updatedReservation 
        });
    } catch (error) {
        console.error('Erreur update reservation:', error);
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