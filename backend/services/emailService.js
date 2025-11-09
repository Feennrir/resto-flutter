const nodemailer = require('nodemailer');

// Configuration du transporteur SMTP
const createTransporter = () => {
    return nodemailer.createTransport({
        host: process.env.SMTP_HOST || 'localhost',
        port: parseInt(process.env.SMTP_PORT || '1025'),
        secure: false, // true pour le port 465, false pour les autres ports
        auth: process.env.SMTP_USER ? {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASSWORD
        } : undefined,
        // Ignorer les erreurs de certificat en développement
        tls: {
            rejectUnauthorized: false
        }
    });
};

/**
 * Envoie un email de confirmation de réservation
 */
const sendReservationConfirmationEmail = async (userEmail, userName, reservationDetails) => {
    try {
        const transporter = createTransporter();

        const { restaurantName, date, time, partySize, specialRequests } = reservationDetails;

        const mailOptions = {
            from: process.env.EMAIL_FROM || 'noreply@restaurant.com',
            to: userEmail,
            subject: '✅ Réservation confirmée - ' + restaurantName,
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background-color: #4CAF50; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
                        .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
                        .detail-box { background-color: white; padding: 20px; margin: 20px 0; border-left: 4px solid #4CAF50; }
                        .detail-row { margin: 10px 0; }
                        .label { font-weight: bold; color: #555; }
                        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #777; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>✅ Réservation Confirmée</h1>
                        </div>
                        <div class="content">
                            <p>Bonjour <strong>${userName}</strong>,</p>
                            <p>Nous avons le plaisir de vous confirmer votre réservation !</p>
                            
                            <div class="detail-box">
                                <div class="detail-row">
                                    <span class="label">🏠 Restaurant :</span> ${restaurantName}
                                </div>
                                <div class="detail-row">
                                    <span class="label">📅 Date :</span> ${formatDate(date)}
                                </div>
                                <div class="detail-row">
                                    <span class="label">🕐 Heure :</span> ${time}
                                </div>
                                <div class="detail-row">
                                    <span class="label">👥 Nombre de personnes :</span> ${partySize}
                                </div>
                                ${specialRequests ? `
                                <div class="detail-row">
                                    <span class="label">📝 Demandes spéciales :</span> ${specialRequests}
                                </div>
                                ` : ''}
                            </div>
                            
                            <p>Nous avons hâte de vous accueillir !</p>
                            <p>À très bientôt,<br><strong>L'équipe ${restaurantName}</strong></p>
                        </div>
                        <div class="footer">
                            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
                        </div>
                    </div>
                </body>
                </html>
            `,
            text: `
Bonjour ${userName},

Nous avons le plaisir de vous confirmer votre réservation !

Restaurant: ${restaurantName}
Date: ${formatDate(date)}
Heure: ${time}
Nombre de personnes: ${partySize}
${specialRequests ? 'Demandes spéciales: ' + specialRequests : ''}

Nous avons hâte de vous accueillir !

À très bientôt,
L'équipe ${restaurantName}
            `
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Email de confirmation envoyé:', info.messageId);
        return { success: true, messageId: info.messageId };
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email de confirmation:', error);
        throw error;
    }
};

/**
 * Envoie un email de refus de réservation
 */
const sendReservationRejectionEmail = async (userEmail, userName, reservationDetails) => {
    try {
        const transporter = createTransporter();

        const { restaurantName, date, time, partySize } = reservationDetails;

        const mailOptions = {
            from: process.env.EMAIL_FROM || 'noreply@restaurant.com',
            to: userEmail,
            subject: '❌ Réservation refusée - ' + restaurantName,
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background-color: #f44336; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
                        .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
                        .detail-box { background-color: white; padding: 20px; margin: 20px 0; border-left: 4px solid #f44336; }
                        .detail-row { margin: 10px 0; }
                        .label { font-weight: bold; color: #555; }
                        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #777; }
                        .suggestion { background-color: #fff3cd; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #ffc107; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>❌ Réservation Refusée</h1>
                        </div>
                        <div class="content">
                            <p>Bonjour <strong>${userName}</strong>,</p>
                            <p>Nous sommes désolés de vous informer que nous ne pouvons pas accepter votre demande de réservation.</p>
                            
                            <div class="detail-box">
                                <div class="detail-row">
                                    <span class="label">🏠 Restaurant :</span> ${restaurantName}
                                </div>
                                <div class="detail-row">
                                    <span class="label">📅 Date :</span> ${formatDate(date)}
                                </div>
                                <div class="detail-row">
                                    <span class="label">🕐 Heure :</span> ${time}
                                </div>
                                <div class="detail-row">
                                    <span class="label">👥 Nombre de personnes :</span> ${partySize}
                                </div>
                            </div>
                            
                            <div class="suggestion">
                                <strong>💡 Suggestion :</strong> Nous vous invitons à consulter nos autres créneaux disponibles ou à nous contacter directement pour trouver une alternative.
                            </div>
                            
                            <p>Nous espérons pouvoir vous accueillir prochainement !</p>
                            <p>Cordialement,<br><strong>L'équipe ${restaurantName}</strong></p>
                        </div>
                        <div class="footer">
                            <p>Cet email a été envoyé automatiquement, merci de ne pas y répondre.</p>
                        </div>
                    </div>
                </body>
                </html>
            `,
            text: `
Bonjour ${userName},

Nous sommes désolés de vous informer que nous ne pouvons pas accepter votre demande de réservation.

Restaurant: ${restaurantName}
Date: ${formatDate(date)}
Heure: ${time}
Nombre de personnes: ${partySize}

Suggestion : Nous vous invitons à consulter nos autres créneaux disponibles ou à nous contacter directement pour trouver une alternative.

Nous espérons pouvoir vous accueillir prochainement !

Cordialement,
L'équipe ${restaurantName}
            `
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Email de refus envoyé:', info.messageId);
        return { success: true, messageId: info.messageId };
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email de refus:', error);
        throw error;
    }
};

/**
 * Envoie un email à l'admin pour notifier d'une nouvelle réservation
 */
const sendNewReservationNotificationToAdmin = async (adminEmail, reservationDetails) => {
    try {
        const transporter = createTransporter();

        const { userName, userEmail, userPhone, restaurantName, date, time, partySize, specialRequests, reservationId } = reservationDetails;

        const mailOptions = {
            from: process.env.EMAIL_FROM || 'noreply@restaurant.com',
            to: adminEmail,
            subject: '🔔 Nouvelle demande de réservation - ' + restaurantName,
            html: `
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                        .header { background-color: #2196F3; color: white; padding: 20px; text-align: center; border-radius: 5px 5px 0 0; }
                        .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 5px 5px; }
                        .detail-box { background-color: white; padding: 20px; margin: 20px 0; border-left: 4px solid #2196F3; }
                        .detail-row { margin: 10px 0; }
                        .label { font-weight: bold; color: #555; }
                        .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #777; }
                        .alert-box { background-color: #fff3cd; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #ffc107; }
                        .customer-info { background-color: #e8f4f8; padding: 15px; margin: 20px 0; border-radius: 5px; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="header">
                            <h1>🔔 Nouvelle Demande de Réservation</h1>
                        </div>
                        <div class="content">
                            <p><strong>Bonjour Administrateur,</strong></p>
                            <p>Une nouvelle demande de réservation vient d'être effectuée et nécessite votre validation.</p>
                            
                            <div class="alert-box">
                                <strong>⚠️ Action requise :</strong> Cette réservation est en attente de validation. Veuillez accepter ou refuser cette demande dans le panneau d'administration.
                            </div>

                            <div class="detail-box">
                                <h3>📋 Détails de la réservation</h3>
                                <div class="detail-row">
                                    <span class="label">🆔 ID Réservation :</span> #${reservationId}
                                </div>
                                <div class="detail-row">
                                    <span class="label">🏠 Restaurant :</span> ${restaurantName}
                                </div>
                                <div class="detail-row">
                                    <span class="label">📅 Date :</span> ${formatDate(date)}
                                </div>
                                <div class="detail-row">
                                    <span class="label">🕐 Heure :</span> ${time}
                                </div>
                                <div class="detail-row">
                                    <span class="label">👥 Nombre de personnes :</span> ${partySize}
                                </div>
                                ${specialRequests ? `
                                <div class="detail-row">
                                    <span class="label">📝 Demandes spéciales :</span> ${specialRequests}
                                </div>
                                ` : ''}
                            </div>

                            <div class="customer-info">
                                <h3>👤 Informations du client</h3>
                                <div class="detail-row">
                                    <span class="label">Nom :</span> ${userName}
                                </div>
                                <div class="detail-row">
                                    <span class="label">Email :</span> <a href="mailto:${userEmail}">${userEmail}</a>
                                </div>
                                ${userPhone ? `
                                <div class="detail-row">
                                    <span class="label">Téléphone :</span> <a href="tel:${userPhone}">${userPhone}</a>
                                </div>
                                ` : ''}
                            </div>
                            
                            <p style="margin-top: 30px;">Merci de traiter cette demande dans les plus brefs délais.</p>
                            <p><strong>Le système de gestion des réservations</strong></p>
                        </div>
                        <div class="footer">
                            <p>Cet email a été envoyé automatiquement par le système de réservation.</p>
                        </div>
                    </div>
                </body>
                </html>
            `,
            text: `
Nouvelle Demande de Réservation

Une nouvelle demande de réservation vient d'être effectuée et nécessite votre validation.

⚠️ Action requise : Cette réservation est en attente de validation.

DÉTAILS DE LA RÉSERVATION
--------------------------
ID Réservation: #${reservationId}
Restaurant: ${restaurantName}
Date: ${formatDate(date)}
Heure: ${time}
Nombre de personnes: ${partySize}
${specialRequests ? 'Demandes spéciales: ' + specialRequests : ''}

INFORMATIONS DU CLIENT
-----------------------
Nom: ${userName}
Email: ${userEmail}
${userPhone ? 'Téléphone: ' + userPhone : ''}

Merci de traiter cette demande dans les plus brefs délais.

Le système de gestion des réservations
            `
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('Email de notification envoyé à l\'admin:', info.messageId);
        return { success: true, messageId: info.messageId };
    } catch (error) {
        console.error('Erreur lors de l\'envoi de l\'email à l\'admin:', error);
        throw error;
    }
};

/**
 * Formate une date au format français
 */
const formatDate = (dateString) => {
    const date = new Date(dateString);
    const options = { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    };
    return date.toLocaleDateString('fr-FR', options);
};

module.exports = {
    sendReservationConfirmationEmail,
    sendReservationRejectionEmail,
    sendNewReservationNotificationToAdmin
};
