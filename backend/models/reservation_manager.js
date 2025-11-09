class ReservationManager {
    constructor(db) {
        this.db = db;
    }

    async checkAvailability(restaurantId, date, time, partySize) {
        // Récupérer les infos du restaurant
        const restaurant = await this.db.query(
            'SELECT max_capacity, service_duration FROM restaurant WHERE id = $1',
            [restaurantId]
        );

        if (restaurant.rows.length === 0) {
            throw new Error('Restaurant non trouvé');
        }

        const { max_capacity, service_duration } = restaurant.rows[0];

        // Calculer la plage horaire occupée (durée du service)
        const endTime = this.addMinutes(time, service_duration);
        const startTime = this.subtractMinutes(time, service_duration);

        // Vérifier les réservations qui se chevauchent
        const overlappingReservations = await this.db.query(`
            SELECT SUM(party_size) as total_reserved
            FROM reservations 
            WHERE restaurant_id = $1 
            AND reservation_date = $2 
            AND status = 'pending'
            AND (
                (reservation_time >= $3 AND reservation_time <= $4)
                OR (reservation_time + INTERVAL '${service_duration} minutes' >= $3 
                    AND reservation_time + INTERVAL '${service_duration} minutes' <= $4)
            )
        `, [restaurantId, date, startTime, endTime]);

        const totalReserved = overlappingReservations.rows[0].total_reserved || 0;
        const availableSpaces = max_capacity - totalReserved;

        return {
            available: availableSpaces >= partySize,
            availableSpaces,
            maxCapacity: max_capacity,
            requestedSize: partySize
        };
    }

    addMinutes(time, minutes) {
        const [hours, mins] = time.split(':');
        const totalMinutes = parseInt(hours) * 60 + parseInt(mins) + minutes;
        const newHours = Math.floor(totalMinutes / 60) % 24;
        const newMins = totalMinutes % 60;
        return `${newHours.toString().padStart(2, '0')}:${newMins.toString().padStart(2, '0')}`;
    }

    subtractMinutes(time, minutes) {
        const [hours, mins] = time.split(':');
        const totalMinutes = parseInt(hours) * 60 + parseInt(mins) - minutes;
        const newHours = Math.max(0, Math.floor(totalMinutes / 60));
        const newMins = Math.max(0, totalMinutes % 60);
        return `${newHours.toString().padStart(2, '0')}:${newMins.toString().padStart(2, '0')}`;
    }

    async createReservation(userId, restaurantId, date, time, partySize, specialRequests = '') {
        // Vérifier la disponibilité
        const availability = await this.checkAvailability(restaurantId, date, time, partySize);

        if (!availability.available) {
            throw new Error(`Capacité insuffisante. Places disponibles: ${availability.availableSpaces}`);
        }

        // Créer la réservation
        const result = await this.db.query(`
            INSERT INTO reservations (user_id, restaurant_id, reservation_date, reservation_time, party_size, special_requests)
            VALUES ($1, $2, $3, $4, $5, $6)
            RETURNING *
        `, [userId, restaurantId, date, time, partySize.toString(), specialRequests]);

        return result.rows[0];
    }

    async getReservationsByDate(restaurantId, date) {
        const result = await this.db.query(`
            SELECT r.*, u.name as user_name, u.email as user_email
            FROM reservations r
            JOIN users u ON r.user_id = u.id
            WHERE r.restaurant_id = $1 AND r.reservation_date = $2
            AND r.status = 'confirmed'
            ORDER BY r.reservation_time
        `, [restaurantId, date]);

        return result.rows;
    }

    async getAvailableSlots(restaurantId, date) {
        // Récupérer les infos du restaurant
        const restaurant = await this.db.query(
            'SELECT opening_time, closing_time, service_duration FROM restaurant WHERE id = $1',
            [restaurantId]
        );

        if (restaurant.rows.length === 0) {
            throw new Error('Restaurant non trouvé');
        }

        const { opening_time, closing_time, service_duration } = restaurant.rows[0];

        // Générer les créneaux possibles (toutes les 30 minutes)
        const slots = this.generateTimeSlots(opening_time, closing_time, 30);

        // Vérifier la disponibilité pour chaque créneau
        const availableSlots = [];

        for (const slot of slots) {
            try {
                const availability = await this.checkAvailability(restaurantId, date, slot, 1);
                availableSlots.push({
                    time: slot,
                    availableSpaces: availability.availableSpaces,
                    maxCapacity: availability.maxCapacity
                });
            } catch (error) {
                // Créneau non disponible
            }
        }

        return availableSlots.filter(slot => slot.availableSpaces > 0);
    }

    generateTimeSlots(openTime, closeTime, intervalMinutes) {
        const slots = [];
        const [openHour, openMin] = openTime.split(':').map(Number);
        const [closeHour, closeMin] = closeTime.split(':').map(Number);

        const openTimeMinutes = openHour * 60 + openMin;
        const closeTimeMinutes = closeHour * 60 + closeMin;

        for (let time = openTimeMinutes; time < closeTimeMinutes - 60; time += intervalMinutes) {
            const hour = Math.floor(time / 60);
            const minute = time % 60;
            slots.push(`${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`);
        }

        return slots;
    }

    async cancelReservation(reservationId) {
        // Vérifier que la réservation appartient à l'utilisateur
        const reservationCheck = await this.db.query(
            'SELECT * FROM reservations WHERE id = $1',
            [reservationId]
        );

        if (reservationCheck.rows.length === 0) {
            throw new Error('Réservation non trouvée ou accès refusé');
        }

        // Mettre à jour le statut de la réservation
        const result = await this.db.query(`
            UPDATE reservations 
            SET status = 'canceled' 
            WHERE id = $1 
            RETURNING *
        `, [reservationId]);
        return result.rows[0];
    }
}

module.exports = ReservationManager;