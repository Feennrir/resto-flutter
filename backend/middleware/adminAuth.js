const jwt = require('jsonwebtoken');
const pool = require('../server');

const adminAuth = async (req, res, next) => {
    try {
        // Vérifier d'abord l'authentification normale
        const token = req.header('Authorization')?.replace('Bearer ', '');
        
        if (!token) {
            return res.status(401).json({ error: 'Authentification requise' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
        
        // Vérifier si l'utilisateur est admin
        const result = await pool.query(
            'SELECT id, email, name, is_admin FROM users WHERE id = $1',
            [decoded.userId]
        );

        if (result.rows.length === 0) {
            return res.status(401).json({ error: 'Utilisateur non trouvé' });
        }

        const user = result.rows[0];

        if (!user.is_admin) {
            return res.status(403).json({ error: 'Accès réservé aux administrateurs' });
        }

        req.user = user;
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token invalide' });
    }
};

module.exports = adminAuth;