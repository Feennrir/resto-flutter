const pool = require('../config/database');

class ReservationManager {
    constructor(db) {
        this.db = db;
    }

    async checkAvailability(restaurantId, date, time, partySize) {
        const restaurant = await this.db.query(
            'SELECT max_capacity, service_duration FROM restaurant WHERE id = $1',
            [restaurantId]
        );

        if (restaurant.rows.length === 0) {
            throw new Error('Restaurant non trouvé');
        }

        const { max_capacity, service_duration } = restaurant.rows[0];
        const endTime = this.addMinutes(time, service_duration);
        const startTime = this.subtractMinutes(time, service_duration);

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
        const availability = await this.checkAvailability(restaurantId, date, time, partySize);

        if (!availability.available) {
            throw new Error(`Capacité insuffisante. Places disponibles: ${availability.availableSpaces}`);
        }

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
        const restaurant = await this.db.query(
            'SELECT opening_time, closing_time, service_duration FROM restaurant WHERE id = $1',
            [restaurantId]
        );

        if (restaurant.rows.length === 0) {
            throw new Error('Restaurant non trouvé');
        }

        const { opening_time, closing_time, service_duration } = restaurant.rows[0];
        const slots = this.generateTimeSlots(opening_time, closing_time, 30);
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
        const reservationCheck = await this.db.query(
            'SELECT * FROM reservations WHERE id = $1',
            [reservationId]
        );

        if (reservationCheck.rows.length === 0) {
            throw new Error('Réservation non trouvée ou accès refusé');
        }

        const result = await this.db.query(`
            UPDATE reservations 
            SET status = 'canceled' 
            WHERE id = $1 
            RETURNING *
        `, [reservationId]);
        
        return result.rows[0];
    }

    async getPendingReservations() {
        const query = `
            SELECT r.*, u.name as user_name, u.email as user_email
            FROM reservations r
            JOIN users u ON r.user_id = u.id
            WHERE r.status = 'pending'
            ORDER BY r.reservation_date ASC, r.reservation_time ASC
        `;
        const result = await this.db.query(query);
        return result.rows;
    }

    async acceptReservation(reservationId) {
        const query = `
            UPDATE reservations
            SET status = 'confirmed', updated_at = NOW()
            WHERE id = $1
            RETURNING *
        `;
        const result = await this.db.query(query, [reservationId]);
        return result.rows[0];
    }

    async rejectReservation(reservationId, reason = '') {
        const query = `
            UPDATE reservations
            SET status = 'rejected', rejection_reason = $2, updated_at = NOW()
            WHERE id = $1
            RETURNING *
        `;
        const result = await this.db.query(query, [reservationId, reason]);
        return result.rows[0];
    }

    async getStats() {
        const queries = await Promise.all([
            this.db.query('SELECT COUNT(*) FROM reservations WHERE status = $1', ['pending']),
            this.db.query('SELECT COUNT(*) FROM dishes'),
            this.db.query('SELECT COUNT(*) FROM reservations WHERE status = $1', ['confirmed']),
        ]);

        return {
            pendingReservations: parseInt(queries[0].rows[0].count),
            totalDishes: parseInt(queries[1].rows[0].count),
            confirmedReservations: parseInt(queries[2].rows[0].count),
        };
    }
}

// Instance singleton
const reservationManager = new ReservationManager(pool);

module.exports = reservationManager;