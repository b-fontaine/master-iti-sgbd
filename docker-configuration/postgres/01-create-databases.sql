-- Script d'initialisation pour créer les bases de données nécessaires
-- Ce script s'exécute automatiquement au premier démarrage de PostgreSQL

-- Création de la base de données pour Metabase
CREATE DATABASE metabase;

-- Création d'une base de données d'exemple pour les exercices
CREATE DATABASE exemple_cours;

-- Connexion à la base exemple_cours pour créer des tables d'exemple
\c exemple_cours;

-- Création d'une table d'exemple pour les premiers exercices
CREATE TABLE exemple_personnes (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100),
    age INT CHECK (age >= 0),
    ville VARCHAR(50),
    email VARCHAR(255) UNIQUE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de quelques données d'exemple
INSERT INTO exemple_personnes (nom, prenom, age, ville, email) VALUES
    ('Dupont', 'Jean', 30, 'Paris', 'jean.dupont@email.com'),
    ('Martin', 'Marie', 25, 'Lyon', 'marie.martin@email.com'),
    ('Bernard', 'Pierre', 35, 'Marseille', 'pierre.bernard@email.com'),
    ('Durand', 'Sophie', 28, 'Toulouse', 'sophie.durand@email.com'),
    ('Moreau', 'Luc', 42, 'Nice', 'luc.moreau@email.com');

-- Création d'une table produits pour les exercices plus avancés
CREATE TABLE produits (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prix DECIMAL(10,2) NOT NULL CHECK (prix >= 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categorie VARCHAR(50),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de produits d'exemple
INSERT INTO produits (nom, prix, stock, categorie) VALUES
    ('Ordinateur portable', 899.99, 15, 'Informatique'),
    ('Souris sans fil', 29.99, 50, 'Informatique'),
    ('Livre SQL', 45.00, 25, 'Livre'),
    ('Chaise de bureau', 159.99, 8, 'Mobilier'),
    ('Écran 24 pouces', 199.99, 12, 'Informatique');

-- Affichage d'un message de confirmation
SELECT 'Base de données initialisée avec succès !' as message;
