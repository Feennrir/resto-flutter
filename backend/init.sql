-- Créer la table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer la table des plats
CREATE TABLE IF NOT EXISTS dishes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(100) NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS restaurant (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    max_capacity INTEGER NOT NULL DEFAULT 50,
    opening_time TIME NOT NULL DEFAULT '10:00:00',
    closing_time TIME NOT NULL DEFAULT '22:00:00',
    service_duration INTEGER NOT NULL DEFAULT 120, -- durée en minutes
    phone VARCHAR(20),
    address TEXT,
    description TEXT,
    image_url TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    restaurant_id INTEGER REFERENCES restaurant(id),
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO restaurant (name, max_capacity, opening_time, closing_time, service_duration, phone, address, description, image_url, latitude, longitude) VALUES
    (
        'Le Petit Bistrot', 
        40, 
        '11:00:00', 
        '13:30:00', 
        120,
        '+33 1 42 86 87 88',
        '61 Rue Mercière, 69002 Lyon, France',
        'Depuis 1985, Le Petit Bistrot vous accueille dans un cadre élégant et chaleureux. Notre chef, formé dans les plus grandes maisons françaises, vous propose une cuisine raffinée mêlant tradition et modernité.',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        45.761788,
        4.833056
    );

-- Insérer un utilisateur admin par défaut
-- Mot de passe: Admin123! (hashé avec bcrypt)
INSERT INTO users (name, email, password, phone, is_admin) VALUES
    ('Administrateur', 'admin@restaurant.com', '$2a$10$/VLQqnaep1n97Rg.ICsb4u9KhndntUUr9Npiwgs4h9rnqsPG4De12', '+33612345678', TRUE)
ON CONFLICT (email) DO NOTHING;

CREATE INDEX idx_reservations_date_time ON reservations(reservation_date, reservation_time);
CREATE INDEX idx_reservations_restaurant ON reservations(restaurant_id);
CREATE INDEX idx_users_is_admin ON users(is_admin);

-- Insérer des plats de démonstration
INSERT INTO dishes (name, description, price, category, image_url) VALUES
('Burger Classique', 'Pain brioché, steak haché, cheddar, salade, tomate, oignon', 12.90, 'Plats', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd'),
('Burger Bacon', 'Pain brioché, steak haché, bacon croustillant, cheddar, sauce BBQ', 14.90, 'Plats', 'https://images.unsplash.com/photo-1553979459-d2229ba7433b'),
('Burger Végétarien', 'Pain complet, steak végétal, avocat, tomate, oignon rouge', 13.90, 'Plats', 'https://images.unsplash.com/photo-1520072959219-c595dc870360'),

('Pizza Margherita', 'Sauce tomate, mozzarella, basilic frais', 11.90, 'Plats', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002'),
('Pizza 4 Fromages', 'Mozzarella, gorgonzola, parmesan, chèvre', 13.90, 'Plats', 'https://images.unsplash.com/photo-1513104890138-7c749659a591'),
('Pizza Pepperoni', 'Sauce tomate, mozzarella, pepperoni', 12.90, 'Plats', 'https://images.unsplash.com/photo-1628840042765-356cda07504e'),

('Salade César', 'Laitue romaine, poulet grillé, croûtons, parmesan, sauce césar', 10.90, 'Entrees', 'https://images.unsplash.com/photo-1546793665-c74683f339c1'),
('Salade Grecque', 'Tomates, concombre, olives, feta, oignon rouge', 9.90, 'Entrees', 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe'),

('Tiramisu', 'Dessert italien traditionnel au café et mascarpone', 6.90, 'Desserts', 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9'),
('Brownie Chocolat', 'Brownie au chocolat noir, glace vanille', 5.90, 'Desserts', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c'),
('Tarte Citron', 'Tarte au citron meringuée', 6.50, 'Desserts', 'https://images.unsplash.com/photo-1519915028121-7d3463d20b13'),

('Coca-Cola', 'Boisson gazeuse 33cl', 2.90, 'Boissons', 'https://images.unsplash.com/photo-1554866585-cd94860890b7'),
('Jus d''Orange', 'Jus d''orange pressé 25cl', 3.90, 'Boissons', 'https://images.unsplash.com/photo-1600271886742-f049cd451bba'),
('Eau Minérale', 'Eau minérale plate 50cl', 2.50, 'Boissons', 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d');

-- Index pour optimiser les recherches
CREATE INDEX idx_dishes_category ON dishes(category);
CREATE INDEX idx_users_email ON users(email);

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger pour la table users
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();