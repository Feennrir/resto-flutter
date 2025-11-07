-- Créer la table des utilisateurs
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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