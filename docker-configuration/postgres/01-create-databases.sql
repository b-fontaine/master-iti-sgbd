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

-- ============================================================================
-- CRÉATION DE LA BASE DE DONNÉES CRM (Customer Relationship Management)
-- ============================================================================

CREATE DATABASE exemple_crm;

\c exemple_crm;

-- ============================================================================
-- CRÉATION DES TABLES
-- ============================================================================

-- Table clients
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    adresse TEXT,
    type_client VARCHAR(20) NOT NULL CHECK (type_client IN ('preprospect', 'prospect', 'client')),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table contacts
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telephone VARCHAR(20),
    poste VARCHAR(100),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);

-- Table meetings (rendez-vous)
CREATE TABLE meetings (
    id SERIAL PRIMARY KEY,
    contact_id INT NOT NULL,
    titre VARCHAR(200) NOT NULL,
    description TEXT,
    date_meeting TIMESTAMP NOT NULL,
    duree_minutes INT DEFAULT 60 CHECK (duree_minutes > 0),
    statut VARCHAR(20) DEFAULT 'planifie' CHECK (statut IN ('planifie', 'termine', 'annule', 'reporte')),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
);

-- Table produits
CREATE TABLE produits (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    description TEXT,
    prix_unitaire DECIMAL(10,2) NOT NULL CHECK (prix_unitaire >= 0),
    stock INT DEFAULT 0 CHECK (stock >= 0),
    categorie VARCHAR(100),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table commandes
CREATE TABLE commandes (
    id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    date_commande TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(20) DEFAULT 'en_cours' CHECK (statut IN ('en_cours', 'validee', 'expediee', 'livree', 'annulee')),
    montant_total DECIMAL(12,2) DEFAULT 0 CHECK (montant_total >= 0),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT
);

-- Table commandes_produits (table de liaison many-to-many)
CREATE TABLE commandes_produits (
    id SERIAL PRIMARY KEY,
    commande_id INT NOT NULL,
    produit_id INT NOT NULL,
    quantite INT NOT NULL CHECK (quantite > 0),
    prix_unitaire DECIMAL(10,2) NOT NULL CHECK (prix_unitaire >= 0),
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE,
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE RESTRICT
);

-- Table factures
CREATE TABLE factures (
    id SERIAL PRIMARY KEY,
    commande_id INT NOT NULL,
    numero_facture VARCHAR(50) UNIQUE NOT NULL,
    date_facture TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_echeance TIMESTAMP NOT NULL,
    montant_ht DECIMAL(12,2) NOT NULL CHECK (montant_ht >= 0),
    montant_ttc DECIMAL(12,2) NOT NULL CHECK (montant_ttc >= 0),
    tva DECIMAL(5,2) DEFAULT 20.00 CHECK (tva >= 0),
    statut_paiement VARCHAR(20) DEFAULT 'en_attente' CHECK (statut_paiement IN ('en_attente', 'paye', 'en_retard', 'annule')),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT
);

-- ============================================================================
-- CRÉATION DES INDEX POUR OPTIMISATION
-- ============================================================================

CREATE INDEX idx_clients_type_client ON clients(type_client);
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_contacts_client_id ON contacts(client_id);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_meetings_contact_id ON meetings(contact_id);
CREATE INDEX idx_meetings_date_meeting ON meetings(date_meeting);
CREATE INDEX idx_commandes_client_id ON commandes(client_id);
CREATE INDEX idx_commandes_date_commande ON commandes(date_commande);
CREATE INDEX idx_commandes_produits_commande_id ON commandes_produits(commande_id);
CREATE INDEX idx_commandes_produits_produit_id ON commandes_produits(produit_id);
CREATE INDEX idx_factures_commande_id ON factures(commande_id);
CREATE INDEX idx_factures_statut_paiement ON factures(statut_paiement);

-- ============================================================================
-- INSERTION DES DONNÉES D'EXEMPLE
-- ============================================================================

-- Insertion de 20 clients (5 préprospects, 8 prospects, 7 clients)
INSERT INTO clients (nom, email, telephone, adresse, type_client) VALUES
    ('TechCorp Solutions', 'contact@techcorp.fr', '0145678901', '15 Rue de la Tech, 75001 Paris', 'client'),
    ('Digital Innovations', 'info@digitalinno.fr', '0234567890', '28 Avenue du Numérique, 69002 Lyon', 'client'),
    ('Green Energy SARL', 'contact@greenenergy.fr', '0345678901', '42 Boulevard Écologique, 13001 Marseille', 'client'),
    ('Consulting Pro', 'hello@consultingpro.fr', '0456789012', '7 Place du Commerce, 31000 Toulouse', 'client'),
    ('MediaPlus Agency', 'contact@mediaplus.fr', '0567890123', '33 Rue des Médias, 06000 Nice', 'client'),
    ('Finance Expert SA', 'info@financeexpert.fr', '0678901234', '12 Avenue Banque, 67000 Strasbourg', 'client'),
    ('Retail Solutions', 'contact@retailsol.fr', '0789012345', '88 Rue du Commerce, 44000 Nantes', 'client'),
    ('StartUp Innovante', 'hello@startupinno.fr', '0890123456', '5 Impasse Innovation, 35000 Rennes', 'prospect'),
    ('Services Plus', 'contact@servicesplus.fr', '0901234567', '19 Boulevard Services, 59000 Lille', 'prospect'),
    ('Tech Avenir', 'info@techavenir.fr', '0123456789', '66 Rue Futur, 33000 Bordeaux', 'prospect'),
    ('Eco Solutions', 'contact@ecosol.fr', '0234567891', '21 Avenue Verte, 34000 Montpellier', 'prospect'),
    ('Digital First', 'hello@digitalfirst.fr', '0345678902', '45 Rue Digitale, 76000 Rouen', 'prospect'),
    ('Innovation Lab', 'contact@innovlab.fr', '0456789013', '8 Place Innovation, 38000 Grenoble', 'prospect'),
    ('Business Growth', 'info@bizgrowth.fr', '0567890124', '77 Boulevard Croissance, 21000 Dijon', 'prospect'),
    ('Smart Tech', 'contact@smarttech.fr', '0678901235', '14 Rue Intelligence, 49000 Angers', 'prospect'),
    ('Future Corp', 'hello@futurecorp.fr', '0789012346', '92 Avenue Avenir, 51100 Reims', 'preprospect'),
    ('New Ventures', 'contact@newventures.fr', '0890123457', '3 Impasse Nouveau, 87000 Limoges', 'preprospect'),
    ('Alpha Solutions', 'info@alphasol.fr', '0901234568', '56 Rue Alpha, 25000 Besançon', 'preprospect'),
    ('Beta Consulting', 'contact@betacons.fr', '0123456780', '11 Boulevard Beta, 80000 Amiens', 'preprospect'),
    ('Gamma Industries', 'hello@gammaindustries.fr', '0234567892', '29 Avenue Gamma, 37000 Tours', 'preprospect');

-- Insertion de contacts (40-50 contacts répartis sur les clients)
INSERT INTO contacts (client_id, prenom, nom, email, telephone, poste) VALUES
    -- TechCorp Solutions (client_id: 1)
    (1, 'Jean', 'Dupont', 'jean.dupont@techcorp.fr', '0145678902', 'Directeur Général'),
    (1, 'Marie', 'Martin', 'marie.martin@techcorp.fr', '0145678903', 'Responsable Achats'),
    (1, 'Pierre', 'Bernard', 'pierre.bernard@techcorp.fr', '0145678904', 'Chef de Projet'),
    -- Digital Innovations (client_id: 2)
    (2, 'Sophie', 'Durand', 'sophie.durand@digitalinno.fr', '0234567891', 'CEO'),
    (2, 'Luc', 'Moreau', 'luc.moreau@digitalinno.fr', '0234567892', 'CTO'),
    (2, 'Claire', 'Petit', 'claire.petit@digitalinno.fr', '0234567893', 'Responsable Marketing'),
    -- Green Energy SARL (client_id: 3)
    (3, 'Thomas', 'Roux', 'thomas.roux@greenenergy.fr', '0345678902', 'Directeur Technique'),
    (3, 'Emma', 'Leroy', 'emma.leroy@greenenergy.fr', '0345678903', 'Responsable Commercial'),
    -- Consulting Pro (client_id: 4)
    (4, 'Nicolas', 'Simon', 'nicolas.simon@consultingpro.fr', '0456789013', 'Partner'),
    (4, 'Julie', 'Laurent', 'julie.laurent@consultingpro.fr', '0456789014', 'Consultante Senior'),
    (4, 'Marc', 'Lefebvre', 'marc.lefebvre@consultingpro.fr', '0456789015', 'Responsable RH'),
    -- MediaPlus Agency (client_id: 5)
    (5, 'Isabelle', 'Michel', 'isabelle.michel@mediaplus.fr', '0567890124', 'Directrice Créative'),
    (5, 'Alexandre', 'Garcia', 'alexandre.garcia@mediaplus.fr', '0567890125', 'Account Manager'),
    -- Finance Expert SA (client_id: 6)
    (6, 'Céline', 'David', 'celine.david@financeexpert.fr', '0678901235', 'Directrice Financière'),
    (6, 'François', 'Bertrand', 'francois.bertrand@financeexpert.fr', '0678901236', 'Analyste'),
    (6, 'Nathalie', 'Robert', 'nathalie.robert@financeexpert.fr', '0678901237', 'Comptable'),
    -- Retail Solutions (client_id: 7)
    (7, 'Vincent', 'Richard', 'vincent.richard@retailsol.fr', '0789012346', 'Directeur des Opérations'),
    (7, 'Sandrine', 'Dubois', 'sandrine.dubois@retailsol.fr', '0789012347', 'Responsable Logistique'),
    -- StartUp Innovante (client_id: 8)
    (8, 'Julien', 'Moreau', 'julien.moreau@startupinno.fr', '0890123457', 'Fondateur'),
    (8, 'Laura', 'Fontaine', 'laura.fontaine@startupinno.fr', '0890123458', 'Co-fondatrice'),
    (8, 'Maxime', 'Girard', 'maxime.girard@startupinno.fr', '0890123459', 'Développeur Lead'),
    -- Services Plus (client_id: 9)
    (9, 'Olivier', 'Bonnet', 'olivier.bonnet@servicesplus.fr', '0901234568', 'Directeur Commercial'),
    (9, 'Valérie', 'Rousseau', 'valerie.rousseau@servicesplus.fr', '0901234569', 'Responsable Qualité'),
    -- Tech Avenir (client_id: 10)
    (10, 'Stéphane', 'Vincent', 'stephane.vincent@techavenir.fr', '0123456780', 'CEO'),
    (10, 'Caroline', 'Muller', 'caroline.muller@techavenir.fr', '0123456781', 'CFO'),
    (10, 'Damien', 'Lefevre', 'damien.lefevre@techavenir.fr', '0123456782', 'Responsable Produit'),
    -- Eco Solutions (client_id: 11)
    (11, 'Aurélie', 'Chevalier', 'aurelie.chevalier@ecosol.fr', '0234567893', 'Directrice'),
    (11, 'Benoît', 'Garnier', 'benoit.garnier@ecosol.fr', '0234567894', 'Ingénieur'),
    -- Digital First (client_id: 12)
    (12, 'Camille', 'Faure', 'camille.faure@digitalfirst.fr', '0345678903', 'Product Owner'),
    (12, 'Romain', 'Andre', 'romain.andre@digitalfirst.fr', '0345678904', 'Scrum Master'),
    -- Innovation Lab (client_id: 13)
    (13, 'Élodie', 'Mercier', 'elodie.mercier@innovlab.fr', '0456789014', 'Directrice Innovation'),
    (13, 'Fabien', 'Blanc', 'fabien.blanc@innovlab.fr', '0456789015', 'Chercheur'),
    -- Business Growth (client_id: 14)
    (14, 'Hélène', 'Guerin', 'helene.guerin@bizgrowth.fr', '0567890125', 'Consultante'),
    (14, 'Grégory', 'Joly', 'gregory.joly@bizgrowth.fr', '0567890126', 'Analyste Business'),
    -- Smart Tech (client_id: 15)
    (15, 'Amélie', 'Gauthier', 'amelie.gauthier@smarttech.fr', '0678901236', 'CTO'),
    (15, 'Sébastien', 'Perrin', 'sebastien.perrin@smarttech.fr', '0678901237', 'Lead Developer'),
    -- Future Corp (client_id: 16)
    (16, 'Pauline', 'Morel', 'pauline.morel@futurecorp.fr', '0789012347', 'Responsable Développement'),
    -- New Ventures (client_id: 17)
    (17, 'Antoine', 'Giraud', 'antoine.giraud@newventures.fr', '0890123458', 'Entrepreneur'),
    (17, 'Lucie', 'Dumas', 'lucie.dumas@newventures.fr', '0890123459', 'Associée'),
    -- Alpha Solutions (client_id: 18)
    (18, 'Mathieu', 'Brun', 'mathieu.brun@alphasol.fr', '0901234569', 'Directeur'),
    (18, 'Charlotte', 'Lemoine', 'charlotte.lemoine@alphasol.fr', '0901234570', 'Assistante'),
    -- Beta Consulting (client_id: 19)
    (19, 'Raphaël', 'Roy', 'raphael.roy@betacons.fr', '0123456781', 'Consultant'),
    -- Gamma Industries (client_id: 20)
    (20, 'Manon', 'Clement', 'manon.clement@gammaindustries.fr', '0234567894', 'Responsable Projet'),
    (20, 'Hugo', 'Francois', 'hugo.francois@gammaindustries.fr', '0234567895', 'Ingénieur Commercial');

-- Insertion de 50 meetings répartis sur différents contacts
INSERT INTO meetings (contact_id, titre, description, date_meeting, duree_minutes, statut) VALUES
    (1, 'Présentation solution CRM', 'Démonstration de notre nouvelle solution CRM', '2024-01-15 10:00:00', 90, 'termine'),
    (2, 'Négociation contrat annuel', 'Discussion sur le renouvellement du contrat', '2024-01-20 14:00:00', 60, 'termine'),
    (3, 'Suivi projet migration', 'Point d''avancement sur la migration des données', '2024-02-05 09:00:00', 120, 'termine'),
    (4, 'Kick-off projet digital', 'Lancement du projet de transformation digitale', '2024-02-10 10:30:00', 90, 'termine'),
    (5, 'Revue technique', 'Revue de l''architecture technique proposée', '2024-02-15 15:00:00', 120, 'termine'),
    (6, 'Stratégie marketing 2024', 'Définition de la stratégie marketing pour l''année', '2024-02-20 11:00:00', 90, 'termine'),
    (7, 'Audit énergétique', 'Présentation des résultats de l''audit', '2024-03-01 09:30:00', 60, 'termine'),
    (8, 'Proposition commerciale', 'Présentation de notre offre de services', '2024-03-05 14:30:00', 75, 'termine'),
    (9, 'Formation équipe', 'Session de formation sur les nouveaux outils', '2024-03-10 10:00:00', 180, 'termine'),
    (10, 'Bilan trimestriel', 'Revue des résultats du premier trimestre', '2024-03-15 16:00:00', 60, 'termine'),
    (11, 'Recrutement consultant', 'Entretien pour un poste de consultant senior', '2024-03-20 11:00:00', 45, 'termine'),
    (12, 'Brief campagne publicitaire', 'Définition des objectifs de la campagne', '2024-03-25 14:00:00', 90, 'termine'),
    (13, 'Présentation portfolio', 'Revue des réalisations créatives', '2024-04-01 10:30:00', 60, 'termine'),
    (14, 'Audit financier', 'Présentation des conclusions de l''audit', '2024-04-05 09:00:00', 120, 'termine'),
    (15, 'Optimisation fiscale', 'Conseil sur l''optimisation fiscale', '2024-04-10 15:30:00', 90, 'termine'),
    (16, 'Clôture comptable', 'Préparation de la clôture annuelle', '2024-04-15 14:00:00', 60, 'termine'),
    (17, 'Stratégie omnicanal', 'Définition de la stratégie de distribution', '2024-04-20 10:00:00', 90, 'termine'),
    (18, 'Optimisation supply chain', 'Amélioration des processus logistiques', '2024-04-25 11:30:00', 120, 'termine'),
    (19, 'Pitch investisseurs', 'Présentation du projet aux investisseurs', '2024-05-01 14:00:00', 45, 'termine'),
    (20, 'Roadmap produit', 'Définition de la feuille de route produit', '2024-05-05 10:00:00', 90, 'termine'),
    (21, 'Revue code', 'Revue de l''architecture logicielle', '2024-05-10 15:00:00', 120, 'termine'),
    (22, 'Prospection commerciale', 'Premier contact commercial', '2024-05-15 09:30:00', 45, 'termine'),
    (23, 'Audit qualité', 'Évaluation des processus qualité', '2024-05-20 14:30:00', 90, 'termine'),
    (24, 'Présentation entreprise', 'Découverte de l''entreprise et des besoins', '2024-06-01 10:00:00', 60, 'termine'),
    (25, 'Analyse financière', 'Revue de la situation financière', '2024-06-05 11:00:00', 75, 'termine'),
    (26, 'Stratégie produit', 'Définition de la stratégie produit 2024-2025', '2024-06-10 14:00:00', 120, 'termine'),
    (27, 'Présentation solution', 'Démonstration de nos solutions écologiques', '2024-06-15 10:30:00', 90, 'planifie'),
    (28, 'Atelier innovation', 'Workshop sur l''innovation technologique', '2024-06-20 09:00:00', 180, 'planifie'),
    (29, 'Sprint planning', 'Planification du prochain sprint', '2024-06-25 15:00:00', 60, 'planifie'),
    (30, 'Retrospective', 'Rétrospective du sprint précédent', '2024-07-01 14:00:00', 90, 'planifie'),
    (31, 'Présentation recherche', 'Résultats des dernières recherches', '2024-07-05 10:00:00', 120, 'planifie'),
    (32, 'Brainstorming innovation', 'Session créative sur les nouveaux projets', '2024-07-10 11:00:00', 90, 'planifie'),
    (33, 'Diagnostic entreprise', 'Analyse des besoins de l''entreprise', '2024-07-15 09:30:00', 75, 'planifie'),
    (34, 'Étude de marché', 'Présentation de l''étude de marché réalisée', '2024-07-20 14:30:00', 60, 'planifie'),
    (35, 'Architecture cloud', 'Discussion sur la migration cloud', '2024-07-25 10:00:00', 120, 'planifie'),
    (36, 'Code review', 'Revue du code de la nouvelle fonctionnalité', '2024-08-01 15:00:00', 90, 'planifie'),
    (37, 'Premier contact', 'Prise de contact initiale', '2024-08-05 11:00:00', 30, 'planifie'),
    (38, 'Découverte besoins', 'Analyse des besoins du prospect', '2024-08-10 14:00:00', 60, 'planifie'),
    (39, 'Présentation offre', 'Présentation détaillée de notre offre', '2024-08-15 10:30:00', 75, 'planifie'),
    (40, 'Négociation', 'Discussion sur les conditions commerciales', '2024-08-20 15:30:00', 60, 'planifie'),
    (41, 'Signature contrat', 'Finalisation et signature du contrat', '2024-08-25 11:00:00', 45, 'planifie'),
    (42, 'Qualification prospect', 'Évaluation du potentiel du prospect', '2024-09-01 09:00:00', 45, 'planifie'),
    (43, 'Démo produit', 'Démonstration de notre produit phare', '2024-09-05 14:00:00', 90, 'planifie'),
    (1, 'Comité de pilotage', 'Revue mensuelle du projet en cours', '2024-09-10 10:00:00', 120, 'planifie'),
    (5, 'Point technique', 'Discussion sur les aspects techniques', '2024-09-15 15:00:00', 60, 'planifie'),
    (10, 'Revue budget', 'Analyse du budget et des dépenses', '2024-09-20 11:00:00', 75, 'planifie'),
    (15, 'Conseil fiscal', 'Consultation sur la fiscalité', '2024-09-25 14:30:00', 60, 'planifie'),
    (20, 'Suivi développement', 'Point d''avancement sur le développement', '2024-10-01 10:00:00', 90, 'planifie'),
    (25, 'Analyse performance', 'Revue des KPIs et de la performance', '2024-10-05 15:00:00', 60, 'planifie'),
    (30, 'Planning Q4', 'Planification du dernier trimestre', '2024-10-10 09:30:00', 90, 'planifie');

-- Insertion de 100 produits avec catégories variées
INSERT INTO produits (nom, description, prix_unitaire, stock, categorie) VALUES
    -- Catégorie Informatique (30 produits)
    ('Ordinateur portable Dell XPS 15', 'PC portable haute performance 15 pouces', 1499.99, 25, 'Informatique'),
    ('MacBook Pro 14"', 'Ordinateur portable Apple M3 Pro', 2299.99, 15, 'Informatique'),
    ('PC Gamer ASUS ROG', 'PC gaming avec RTX 4070', 1899.99, 12, 'Informatique'),
    ('Écran Dell 27" 4K', 'Moniteur professionnel UHD', 449.99, 40, 'Informatique'),
    ('Clavier mécanique Logitech', 'Clavier gaming RGB', 129.99, 60, 'Informatique'),
    ('Souris sans fil MX Master 3', 'Souris ergonomique professionnelle', 99.99, 80, 'Informatique'),
    ('Webcam Logitech 4K', 'Caméra pour visioconférence', 149.99, 35, 'Informatique'),
    ('Casque audio Sony WH-1000XM5', 'Casque à réduction de bruit', 379.99, 45, 'Informatique'),
    ('Disque dur externe 2To', 'Stockage externe USB 3.0', 79.99, 100, 'Informatique'),
    ('SSD Samsung 1To', 'Disque SSD NVMe haute vitesse', 119.99, 70, 'Informatique'),
    ('Hub USB-C 7 ports', 'Adaptateur multiport', 49.99, 90, 'Informatique'),
    ('Câble HDMI 2.1', 'Câble 4K 120Hz 2 mètres', 19.99, 150, 'Informatique'),
    ('Tapis de souris XXL', 'Tapis gaming 90x40cm', 29.99, 120, 'Informatique'),
    ('Support laptop réglable', 'Support ergonomique en aluminium', 39.99, 55, 'Informatique'),
    ('Lampe LED bureau', 'Lampe avec chargeur sans fil', 59.99, 65, 'Informatique'),
    ('Onduleur APC 900VA', 'Protection électrique', 129.99, 30, 'Informatique'),
    ('Switch réseau 8 ports', 'Switch Gigabit non managé', 34.99, 45, 'Informatique'),
    ('Routeur WiFi 6 TP-Link', 'Routeur tri-bande', 199.99, 28, 'Informatique'),
    ('Imprimante laser HP', 'Imprimante monochrome réseau', 249.99, 20, 'Informatique'),
    ('Scanner Epson', 'Scanner de documents A4', 189.99, 18, 'Informatique'),
    ('Tablette graphique Wacom', 'Tablette pour designers', 349.99, 22, 'Informatique'),
    ('Microphone Blue Yeti', 'Micro USB professionnel', 129.99, 40, 'Informatique'),
    ('Bras articulé écran', 'Support VESA pour moniteur', 79.99, 35, 'Informatique'),
    ('Docking station USB-C', 'Station d''accueil complète', 199.99, 25, 'Informatique'),
    ('Clé USB 128Go', 'Clé USB 3.1 haute vitesse', 24.99, 200, 'Informatique'),
    ('Carte SD 256Go', 'Carte mémoire UHS-II', 49.99, 85, 'Informatique'),
    ('Batterie externe 20000mAh', 'Power bank USB-C PD', 39.99, 95, 'Informatique'),
    ('Chargeur USB-C 65W', 'Chargeur GaN compact', 44.99, 110, 'Informatique'),
    ('Adaptateur DisplayPort HDMI', 'Convertisseur 4K', 14.99, 130, 'Informatique'),
    ('Nettoyant écran kit', 'Kit de nettoyage professionnel', 12.99, 140, 'Informatique'),

    -- Catégorie Mobilier (20 produits)
    ('Chaise de bureau ergonomique', 'Chaise avec support lombaire', 299.99, 35, 'Mobilier'),
    ('Bureau réglable en hauteur', 'Bureau assis-debout électrique', 599.99, 18, 'Mobilier'),
    ('Fauteuil gaming DXRacer', 'Siège gaming professionnel', 399.99, 22, 'Mobilier'),
    ('Caisson de bureau 3 tiroirs', 'Rangement mobile avec serrure', 129.99, 40, 'Mobilier'),
    ('Étagère murale', 'Étagère en bois 120cm', 79.99, 50, 'Mobilier'),
    ('Armoire de bureau', 'Armoire métallique 2 portes', 349.99, 15, 'Mobilier'),
    ('Table de réunion 8 places', 'Table ovale professionnelle', 899.99, 8, 'Mobilier'),
    ('Tableau blanc 120x90', 'Tableau magnétique effaçable', 89.99, 30, 'Mobilier'),
    ('Porte-manteau sur pied', 'Porte-manteau design métal', 49.99, 45, 'Mobilier'),
    ('Lampadaire LED', 'Lampadaire moderne réglable', 119.99, 25, 'Mobilier'),
    ('Poubelle de bureau design', 'Corbeille 30L avec couvercle', 34.99, 60, 'Mobilier'),
    ('Repose-pieds ergonomique', 'Repose-pieds réglable', 39.99, 55, 'Mobilier'),
    ('Séparateur de bureau', 'Panneau acoustique 160cm', 199.99, 20, 'Mobilier'),
    ('Casier de rangement', 'Meuble à casiers 12 compartiments', 249.99, 12, 'Mobilier'),
    ('Banquette d''accueil', 'Canapé 3 places professionnel', 699.99, 10, 'Mobilier'),
    ('Table basse design', 'Table basse verre et métal', 179.99, 18, 'Mobilier'),
    ('Porte-revues mural', 'Présentoir 6 compartiments', 59.99, 35, 'Mobilier'),
    ('Horloge murale', 'Horloge silencieuse 40cm', 29.99, 70, 'Mobilier'),
    ('Plante artificielle', 'Plante décorative 120cm', 49.99, 40, 'Mobilier'),
    ('Tapis de sol', 'Tapis protection sol 120x90', 44.99, 50, 'Mobilier'),

    -- Catégorie Logiciel (15 produits)
    ('Licence Microsoft 365 Business', 'Suite bureautique annuelle', 149.99, 500, 'Logiciel'),
    ('Adobe Creative Cloud', 'Suite créative complète 1 an', 599.99, 300, 'Logiciel'),
    ('Antivirus Kaspersky Pro', 'Protection 5 appareils 1 an', 79.99, 400, 'Logiciel'),
    ('Windows 11 Pro', 'Système d''exploitation', 199.99, 250, 'Logiciel'),
    ('AutoCAD LT', 'Logiciel CAO 2D licence annuelle', 449.99, 100, 'Logiciel'),
    ('Zoom Pro', 'Visioconférence professionnelle 1 an', 149.99, 600, 'Logiciel'),
    ('Slack Business+', 'Collaboration équipe 1 an', 129.99, 450, 'Logiciel'),
    ('Salesforce CRM', 'Solution CRM licence mensuelle', 99.99, 800, 'Logiciel'),
    ('QuickBooks Online', 'Comptabilité en ligne 1 an', 299.99, 350, 'Logiciel'),
    ('Photoshop seul', 'Licence annuelle Photoshop', 239.99, 400, 'Logiciel'),
    ('Illustrator seul', 'Licence annuelle Illustrator', 239.99, 350, 'Logiciel'),
    ('InDesign seul', 'Licence annuelle InDesign', 239.99, 300, 'Logiciel'),
    ('Premiere Pro seul', 'Licence annuelle Premiere Pro', 239.99, 280, 'Logiciel'),
    ('Acrobat Pro DC', 'PDF professionnel 1 an', 179.99, 450, 'Logiciel'),
    ('Norton 360 Deluxe', 'Sécurité complète 5 appareils', 89.99, 500, 'Logiciel'),

    -- Catégorie Fournitures (20 produits)
    ('Ramette papier A4 500 feuilles', 'Papier blanc 80g', 5.99, 500, 'Fournitures'),
    ('Stylos bille bleu x50', 'Lot de 50 stylos', 12.99, 200, 'Fournitures'),
    ('Surligneurs couleurs x6', 'Set de 6 surligneurs', 4.99, 300, 'Fournitures'),
    ('Classeurs A4 x10', 'Lot de 10 classeurs dos 8cm', 19.99, 150, 'Fournitures'),
    ('Post-it couleurs x12', 'Pack de 12 blocs notes', 14.99, 250, 'Fournitures'),
    ('Agrafeuse professionnelle', 'Agrafeuse métal 50 feuilles', 24.99, 80, 'Fournitures'),
    ('Perforatrice 4 trous', 'Perforatrice métal robuste', 29.99, 70, 'Fournitures'),
    ('Ciseaux bureau', 'Ciseaux ergonomiques 21cm', 6.99, 120, 'Fournitures'),
    ('Cutter professionnel', 'Cutter métal avec lames', 8.99, 100, 'Fournitures'),
    ('Règle métallique 30cm', 'Règle aluminium graduée', 3.99, 180, 'Fournitures'),
    ('Calculatrice scientifique', 'Calculatrice Casio FX-92', 24.99, 90, 'Fournitures'),
    ('Calendrier mural 2024', 'Calendrier annuel grand format', 9.99, 60, 'Fournitures'),
    ('Agenda professionnel', 'Agenda semainier cuir', 29.99, 85, 'Fournitures'),
    ('Chemises cartonnées x100', 'Lot de 100 chemises couleurs', 24.99, 120, 'Fournitures'),
    ('Élastiques x500g', 'Boîte d''élastiques assortis', 7.99, 140, 'Fournitures'),
    ('Trombones x1000', 'Boîte de trombones 33mm', 4.99, 200, 'Fournitures'),
    ('Punaises couleurs x200', 'Boîte de punaises assorties', 5.99, 160, 'Fournitures'),
    ('Colle stick x12', 'Lot de 12 bâtons de colle', 9.99, 180, 'Fournitures'),
    ('Ruban adhésif x6', 'Pack de 6 rouleaux scotch', 8.99, 150, 'Fournitures'),
    ('Enveloppes C4 x250', 'Enveloppes blanches 229x324mm', 19.99, 100, 'Fournitures'),

    -- Catégorie Services (15 produits)
    ('Formation Excel avancé', 'Formation 2 jours en présentiel', 899.99, 50, 'Services'),
    ('Consulting stratégique', 'Journée de consulting', 1499.99, 100, 'Services'),
    ('Audit sécurité informatique', 'Audit complet infrastructure', 2499.99, 30, 'Services'),
    ('Développement site web', 'Site vitrine responsive', 3999.99, 20, 'Services'),
    ('Maintenance informatique', 'Contrat maintenance mensuel', 299.99, 150, 'Services'),
    ('Support technique premium', 'Support 24/7 mensuel', 499.99, 200, 'Services'),
    ('Sauvegarde cloud 1To', 'Stockage cloud sécurisé mensuel', 49.99, 500, 'Services'),
    ('Hébergement web Pro', 'Hébergement annuel', 199.99, 300, 'Services'),
    ('Nom de domaine .com', 'Enregistrement domaine 1 an', 14.99, 1000, 'Services'),
    ('Certificat SSL', 'Certificat SSL 1 an', 79.99, 400, 'Services'),
    ('SEO optimisation', 'Optimisation référencement', 799.99, 60, 'Services'),
    ('Campagne Google Ads', 'Gestion campagne mensuelle', 599.99, 80, 'Services'),
    ('Design logo professionnel', 'Création identité visuelle', 499.99, 40, 'Services'),
    ('Rédaction contenu web', 'Pack 10 articles SEO', 399.99, 70, 'Services'),
    ('Traduction professionnelle', 'Traduction 5000 mots', 249.99, 90, 'Services');

-- Insertion de 40 commandes
INSERT INTO commandes (client_id, date_commande, statut, montant_total) VALUES
    (1, '2024-01-20 10:30:00', 'livree', 4599.95),
    (1, '2024-03-15 14:20:00', 'livree', 2899.96),
    (2, '2024-01-25 09:15:00', 'livree', 3499.97),
    (2, '2024-04-10 11:45:00', 'expediee', 1799.98),
    (3, '2024-02-05 16:30:00', 'livree', 5299.94),
    (3, '2024-05-20 10:00:00', 'validee', 2499.95),
    (4, '2024-02-12 13:25:00', 'livree', 6899.93),
    (4, '2024-06-01 15:10:00', 'en_cours', 3299.96),
    (5, '2024-02-18 10:50:00', 'livree', 2199.97),
    (5, '2024-05-25 14:35:00', 'expediee', 1599.98),
    (6, '2024-03-01 09:20:00', 'livree', 4799.95),
    (6, '2024-06-10 11:15:00', 'validee', 2899.96),
    (7, '2024-03-08 15:40:00', 'livree', 8999.92),
    (7, '2024-06-15 10:25:00', 'en_cours', 3799.95),
    (1, '2024-03-22 13:55:00', 'livree', 1899.98),
    (2, '2024-04-05 10:10:00', 'livree', 5499.94),
    (3, '2024-04-18 14:45:00', 'expediee', 3299.96),
    (4, '2024-04-25 09:30:00', 'livree', 2699.97),
    (5, '2024-05-02 16:20:00', 'livree', 4199.95),
    (6, '2024-05-10 11:50:00', 'expediee', 1999.98),
    (7, '2024-05-18 13:15:00', 'validee', 6299.93),
    (1, '2024-05-28 10:40:00', 'livree', 3599.96),
    (2, '2024-06-05 15:25:00', 'expediee', 2799.97),
    (3, '2024-06-12 09:55:00', 'en_cours', 4899.94),
    (4, '2024-06-20 14:10:00', 'validee', 3199.96),
    (8, '2024-02-28 10:30:00', 'livree', 2499.97),
    (8, '2024-05-15 14:20:00', 'expediee', 1799.98),
    (9, '2024-03-10 11:45:00', 'livree', 3899.95),
    (9, '2024-06-08 10:15:00', 'validee', 2299.97),
    (10, '2024-03-18 15:30:00', 'livree', 5699.93),
    (10, '2024-06-18 13:40:00', 'en_cours', 3499.96),
    (11, '2024-04-02 09:20:00', 'livree', 2899.96),
    (12, '2024-04-15 14:50:00', 'expediee', 4199.95),
    (13, '2024-04-28 10:35:00', 'livree', 3299.96),
    (14, '2024-05-08 16:10:00', 'livree', 2599.97),
    (15, '2024-05-22 11:25:00', 'expediee', 4799.94),
    (8, '2024-06-02 13:45:00', 'validee', 1999.98),
    (9, '2024-06-14 10:55:00', 'en_cours', 3799.95),
    (10, '2024-06-22 15:20:00', 'validee', 2899.96),
    (11, '2024-06-28 09:40:00', 'en_cours', 5299.93);

-- Insertion des produits pour chaque commande (table de liaison)
INSERT INTO commandes_produits (commande_id, produit_id, quantite, prix_unitaire) VALUES
    -- Commande 1 (client 1)
    (1, 1, 2, 1499.99), (1, 4, 3, 449.99), (1, 5, 2, 129.99),
    -- Commande 2 (client 1)
    (2, 7, 4, 149.99), (2, 8, 2, 379.99), (2, 10, 5, 119.99),
    -- Commande 3 (client 2)
    (3, 2, 1, 2299.99), (3, 6, 5, 99.99), (3, 9, 3, 79.99),
    -- Commande 4 (client 2)
    (4, 11, 10, 49.99), (4, 12, 20, 19.99), (4, 13, 15, 29.99),
    -- Commande 5 (client 3)
    (5, 3, 2, 1899.99), (5, 14, 8, 39.99), (5, 15, 6, 59.99),
    -- Commande 6 (client 3)
    (6, 16, 5, 129.99), (6, 17, 10, 34.99), (6, 18, 3, 199.99),
    -- Commande 7 (client 4)
    (7, 19, 6, 249.99), (7, 20, 8, 189.99), (7, 21, 4, 349.99),
    -- Commande 8 (client 4)
    (8, 22, 10, 129.99), (8, 23, 12, 79.99), (8, 24, 5, 199.99),
    -- Commande 9 (client 5)
    (9, 25, 30, 24.99), (9, 26, 20, 49.99), (9, 27, 15, 39.99),
    -- Commande 10 (client 5)
    (10, 28, 25, 44.99), (10, 29, 18, 14.99), (10, 30, 10, 12.99),
    -- Commande 11 (client 6)
    (11, 31, 8, 299.99), (11, 32, 4, 599.99), (11, 33, 6, 399.99),
    -- Commande 12 (client 6)
    (12, 34, 10, 129.99), (12, 35, 15, 79.99), (12, 36, 5, 349.99),
    -- Commande 13 (client 7)
    (13, 37, 5, 899.99), (13, 38, 20, 89.99), (13, 39, 12, 49.99),
    -- Commande 14 (client 7)
    (14, 40, 15, 119.99), (14, 41, 8, 34.99), (14, 42, 10, 39.99),
    -- Commande 15 (client 1)
    (15, 43, 6, 199.99), (15, 44, 4, 249.99), (15, 45, 3, 179.99),
    -- Commande 16 (client 2)
    (16, 46, 8, 299.99), (16, 47, 5, 599.99), (16, 48, 10, 79.99),
    -- Commande 17 (client 3)
    (17, 49, 12, 199.99), (17, 50, 6, 149.99), (17, 51, 15, 129.99),
    -- Commande 18 (client 4)
    (18, 52, 10, 99.99), (18, 53, 8, 239.99), (18, 54, 5, 239.99),
    -- Commande 19 (client 5)
    (19, 55, 7, 239.99), (19, 56, 9, 239.99), (19, 57, 6, 179.99),
    -- Commande 20 (client 6)
    (20, 58, 20, 5.99), (20, 59, 50, 12.99), (20, 60, 30, 4.99),
    -- Commande 21 (client 7)
    (21, 61, 10, 19.99), (21, 62, 12, 14.99), (21, 63, 8, 24.99),
    -- Commande 22 (client 1)
    (22, 64, 15, 29.99), (22, 65, 10, 6.99), (22, 66, 12, 8.99),
    -- Commande 23 (client 2)
    (23, 67, 18, 3.99), (23, 68, 20, 24.99), (23, 69, 15, 9.99),
    -- Commande 24 (client 3)
    (24, 70, 25, 29.99), (24, 71, 30, 24.99), (24, 72, 20, 7.99),
    -- Commande 25 (client 4)
    (25, 73, 40, 4.99), (25, 74, 35, 5.99), (25, 75, 25, 9.99),
    -- Commande 26 (client 8)
    (26, 76, 2, 899.99), (26, 77, 1, 1499.99), (26, 78, 1, 2499.99),
    -- Commande 27 (client 8)
    (27, 79, 1, 3999.99), (27, 80, 3, 299.99), (27, 81, 2, 499.99),
    -- Commande 28 (client 9)
    (28, 82, 5, 49.99), (28, 83, 3, 199.99), (28, 84, 10, 14.99),
    -- Commande 29 (client 9)
    (29, 85, 8, 79.99), (29, 86, 4, 799.99), (29, 87, 3, 599.99),
    -- Commande 30 (client 10)
    (30, 88, 5, 499.99), (30, 89, 6, 399.99), (30, 90, 8, 249.99),
    -- Commande 31 (client 10)
    (31, 1, 1, 1499.99), (31, 4, 2, 449.99), (31, 7, 3, 149.99),
    -- Commande 32 (client 11)
    (32, 31, 5, 299.99), (32, 32, 2, 599.99), (32, 46, 3, 299.99),
    -- Commande 33 (client 12)
    (33, 2, 1, 2299.99), (33, 8, 2, 379.99), (33, 22, 5, 129.99),
    -- Commande 34 (client 13)
    (34, 21, 3, 349.99), (34, 24, 4, 199.99), (34, 27, 10, 39.99),
    -- Commande 35 (client 14)
    (35, 76, 2, 899.99), (35, 77, 1, 1499.99), (35, 86, 2, 799.99),
    -- Commande 36 (client 15)
    (36, 3, 1, 1899.99), (36, 10, 5, 119.99), (36, 15, 8, 59.99),
    -- Commande 37 (client 8)
    (37, 58, 100, 5.99), (37, 59, 80, 12.99), (37, 60, 60, 4.99),
    -- Commande 38 (client 9)
    (38, 31, 6, 299.99), (38, 33, 4, 399.99), (38, 40, 8, 119.99),
    -- Commande 39 (client 10)
    (39, 46, 5, 299.99), (39, 47, 2, 599.99), (39, 48, 8, 79.99),
    -- Commande 40 (client 11)
    (40, 1, 2, 1499.99), (40, 2, 1, 2299.99), (40, 4, 3, 449.99);

-- Insertion de 15 factures liées aux commandes
INSERT INTO factures (commande_id, numero_facture, date_facture, date_echeance, montant_ht, montant_ttc, tva, statut_paiement) VALUES
    (1, 'FAC-2024-0001', '2024-01-21 10:00:00', '2024-02-20 23:59:59', 3833.29, 4599.95, 20.00, 'paye'),
    (2, 'FAC-2024-0002', '2024-03-16 09:00:00', '2024-04-15 23:59:59', 2416.63, 2899.96, 20.00, 'paye'),
    (3, 'FAC-2024-0003', '2024-01-26 11:00:00', '2024-02-25 23:59:59', 2916.64, 3499.97, 20.00, 'paye'),
    (5, 'FAC-2024-0004', '2024-02-06 14:00:00', '2024-03-07 23:59:59', 4416.62, 5299.94, 20.00, 'paye'),
    (7, 'FAC-2024-0005', '2024-02-13 10:30:00', '2024-03-14 23:59:59', 5749.94, 6899.93, 20.00, 'paye'),
    (9, 'FAC-2024-0006', '2024-02-19 11:15:00', '2024-03-20 23:59:59', 1833.31, 2199.97, 20.00, 'paye'),
    (11, 'FAC-2024-0007', '2024-03-02 09:45:00', '2024-04-01 23:59:59', 3999.96, 4799.95, 20.00, 'paye'),
    (13, 'FAC-2024-0008', '2024-03-09 13:20:00', '2024-04-08 23:59:59', 7499.93, 8999.92, 20.00, 'paye'),
    (15, 'FAC-2024-0009', '2024-03-23 10:50:00', '2024-04-22 23:59:59', 1583.32, 1899.98, 20.00, 'paye'),
    (16, 'FAC-2024-0010', '2024-04-06 14:30:00', '2024-05-06 23:59:59', 4583.28, 5499.94, 20.00, 'paye'),
    (18, 'FAC-2024-0011', '2024-04-26 11:00:00', '2024-05-26 23:59:59', 2249.98, 2699.97, 20.00, 'paye'),
    (19, 'FAC-2024-0012', '2024-05-03 15:10:00', '2024-06-02 23:59:59', 3499.96, 4199.95, 20.00, 'en_attente'),
    (22, 'FAC-2024-0013', '2024-05-29 09:30:00', '2024-06-28 23:59:59', 2999.97, 3599.96, 20.00, 'en_attente'),
    (26, 'FAC-2024-0014', '2024-03-01 10:00:00', '2024-03-31 23:59:59', 2083.31, 2499.97, 20.00, 'en_retard'),
    (30, 'FAC-2024-0015', '2024-03-19 14:00:00', '2024-04-18 23:59:59', 4749.94, 5699.93, 20.00, 'en_retard');

-- Message de confirmation
SELECT 'Base de données CRM initialisée avec succès !' as message;
SELECT 'Statistiques :' as info;
SELECT COUNT(*) as nombre_clients FROM clients;
SELECT COUNT(*) as nombre_contacts FROM contacts;
SELECT COUNT(*) as nombre_meetings FROM meetings;
SELECT COUNT(*) as nombre_produits FROM produits;
SELECT COUNT(*) as nombre_commandes FROM commandes;
SELECT COUNT(*) as nombre_factures FROM factures;

-- ============================================================================
-- CRÉATION DE LA BASE DE DONNÉES PRODUCTION ÉLECTRONIQUE
-- ============================================================================

CREATE DATABASE exemple_production_electronique;

\c exemple_production_electronique;

-- ============================================================================
-- CRÉATION DES TABLES
-- ============================================================================

-- Table cartes_electroniques (8 types de cartes différentes)
CREATE TABLE cartes_electroniques (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(200) NOT NULL,
    description TEXT,
    version VARCHAR(20) NOT NULL,
    type_carte VARCHAR(50) NOT NULL CHECK (type_carte IN ('controle', 'alimentation', 'communication', 'interface', 'capteur', 'processeur', 'memoire', 'affichage')),
    temps_assemblage_minutes INT NOT NULL CHECK (temps_assemblage_minutes > 0),
    prix_unitaire DECIMAL(10,2) NOT NULL CHECK (prix_unitaire >= 0),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table composants (composants électroniques)
CREATE TABLE composants (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(200) NOT NULL,
    description TEXT,
    type_composant VARCHAR(50) NOT NULL CHECK (type_composant IN ('resistance', 'condensateur', 'transistor', 'circuit_integre', 'connecteur', 'led', 'diode', 'inductance', 'cristal', 'relais')),
    fabricant VARCHAR(100),
    stock_actuel INT DEFAULT 0 CHECK (stock_actuel >= 0),
    stock_minimum INT DEFAULT 0 CHECK (stock_minimum >= 0),
    prix_unitaire DECIMAL(10,4) NOT NULL CHECK (prix_unitaire >= 0),
    delai_approvisionnement_jours INT DEFAULT 7 CHECK (delai_approvisionnement_jours >= 0),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table nomenclature (BOM - Bill of Materials)
CREATE TABLE nomenclature (
    id SERIAL PRIMARY KEY,
    carte_id INT NOT NULL,
    composant_id INT NOT NULL,
    quantite INT NOT NULL CHECK (quantite > 0),
    reference_designator VARCHAR(50),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carte_id) REFERENCES cartes_electroniques(id) ON DELETE CASCADE,
    FOREIGN KEY (composant_id) REFERENCES composants(id) ON DELETE RESTRICT,
    UNIQUE(carte_id, composant_id, reference_designator)
);

-- Table operations_fabrication (opérations de fabrication)
CREATE TABLE operations_fabrication (
    id SERIAL PRIMARY KEY,
    code_operation VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(200) NOT NULL,
    description TEXT,
    type_operation VARCHAR(50) NOT NULL CHECK (type_operation IN ('automatique', 'manuelle')),
    categorie VARCHAR(50) NOT NULL CHECK (categorie IN ('assemblage_cms', 'assemblage_traversant', 'soudure_vague', 'soudure_refusion', 'test_electrique', 'test_fonctionnel', 'inspection_visuelle', 'inspection_aoi', 'decoupe', 'nettoyage', 'conditionnement', 'manutention')),
    duree_standard_minutes DECIMAL(10,2) NOT NULL CHECK (duree_standard_minutes > 0),
    cout_horaire DECIMAL(10,2) DEFAULT 0 CHECK (cout_horaire >= 0),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table gammes_fabrication (séquence d'opérations pour chaque carte)
CREATE TABLE gammes_fabrication (
    id SERIAL PRIMARY KEY,
    carte_id INT NOT NULL,
    operation_id INT NOT NULL,
    ordre_operation INT NOT NULL CHECK (ordre_operation > 0),
    duree_minutes DECIMAL(10,2) NOT NULL CHECK (duree_minutes > 0),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carte_id) REFERENCES cartes_electroniques(id) ON DELETE CASCADE,
    FOREIGN KEY (operation_id) REFERENCES operations_fabrication(id) ON DELETE RESTRICT,
    UNIQUE(carte_id, ordre_operation)
);

-- Table ordres_fabrication (ordres de production)
CREATE TABLE ordres_fabrication (
    id SERIAL PRIMARY KEY,
    numero_of VARCHAR(50) UNIQUE NOT NULL,
    carte_id INT NOT NULL,
    quantite_prevue INT NOT NULL CHECK (quantite_prevue > 0),
    quantite_produite INT DEFAULT 0 CHECK (quantite_produite >= 0),
    quantite_conforme INT DEFAULT 0 CHECK (quantite_conforme >= 0),
    quantite_rebut INT DEFAULT 0 CHECK (quantite_rebut >= 0),
    date_lancement DATE NOT NULL,
    date_fin_prevue DATE NOT NULL,
    date_fin_reelle DATE,
    statut VARCHAR(20) DEFAULT 'planifie' CHECK (statut IN ('planifie', 'en_cours', 'termine', 'suspendu', 'annule')),
    priorite VARCHAR(20) DEFAULT 'normale' CHECK (priorite IN ('basse', 'normale', 'haute', 'urgente')),
    commentaire TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carte_id) REFERENCES cartes_electroniques(id) ON DELETE RESTRICT
);

-- Table suivi_production (suivi détaillé de la production par opération)
CREATE TABLE suivi_production (
    id SERIAL PRIMARY KEY,
    ordre_fabrication_id INT NOT NULL,
    operation_id INT NOT NULL,
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP,
    quantite_traitee INT DEFAULT 0 CHECK (quantite_traitee >= 0),
    quantite_conforme INT DEFAULT 0 CHECK (quantite_conforme >= 0),
    quantite_defaut INT DEFAULT 0 CHECK (quantite_defaut >= 0),
    operateur VARCHAR(100),
    machine VARCHAR(100),
    statut VARCHAR(20) DEFAULT 'en_cours' CHECK (statut IN ('en_cours', 'termine', 'suspendu')),
    commentaire TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ordre_fabrication_id) REFERENCES ordres_fabrication(id) ON DELETE CASCADE,
    FOREIGN KEY (operation_id) REFERENCES operations_fabrication(id) ON DELETE RESTRICT
);

-- Table defauts_qualite (défauts détectés)
CREATE TABLE defauts_qualite (
    id SERIAL PRIMARY KEY,
    suivi_production_id INT NOT NULL,
    type_defaut VARCHAR(100) NOT NULL,
    description TEXT,
    quantite INT DEFAULT 1 CHECK (quantite > 0),
    gravite VARCHAR(20) DEFAULT 'moyenne' CHECK (gravite IN ('mineure', 'moyenne', 'majeure', 'critique')),
    action_corrective TEXT,
    date_detection TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (suivi_production_id) REFERENCES suivi_production(id) ON DELETE CASCADE
);

-- ============================================================================
-- CRÉATION DES INDEX POUR OPTIMISATION
-- ============================================================================

CREATE INDEX idx_cartes_reference ON cartes_electroniques(reference);
CREATE INDEX idx_cartes_type ON cartes_electroniques(type_carte);
CREATE INDEX idx_composants_reference ON composants(reference);
CREATE INDEX idx_composants_type ON composants(type_composant);
CREATE INDEX idx_composants_stock ON composants(stock_actuel);
CREATE INDEX idx_nomenclature_carte_id ON nomenclature(carte_id);
CREATE INDEX idx_nomenclature_composant_id ON nomenclature(composant_id);
CREATE INDEX idx_operations_type ON operations_fabrication(type_operation);
CREATE INDEX idx_operations_categorie ON operations_fabrication(categorie);
CREATE INDEX idx_gammes_carte_id ON gammes_fabrication(carte_id);
CREATE INDEX idx_gammes_operation_id ON gammes_fabrication(operation_id);
CREATE INDEX idx_ordres_numero ON ordres_fabrication(numero_of);
CREATE INDEX idx_ordres_carte_id ON ordres_fabrication(carte_id);
CREATE INDEX idx_ordres_statut ON ordres_fabrication(statut);
CREATE INDEX idx_ordres_date_lancement ON ordres_fabrication(date_lancement);
CREATE INDEX idx_suivi_ordre_id ON suivi_production(ordre_fabrication_id);
CREATE INDEX idx_suivi_operation_id ON suivi_production(operation_id);
CREATE INDEX idx_suivi_date_debut ON suivi_production(date_debut);
CREATE INDEX idx_defauts_suivi_id ON defauts_qualite(suivi_production_id);
CREATE INDEX idx_defauts_type ON defauts_qualite(type_defaut);

-- ============================================================================
-- INSERTION DES DONNÉES D'EXEMPLE
-- ============================================================================

-- Insertion des 8 cartes électroniques
INSERT INTO cartes_electroniques (reference, nom, description, version, type_carte, temps_assemblage_minutes, prix_unitaire) VALUES
    ('PCB-CTRL-001', 'Carte Contrôleur Principal', 'Carte de contrôle principale avec microcontrôleur ARM Cortex-M4', 'v2.3', 'controle', 45, 125.50),
    ('PCB-PWR-002', 'Carte Alimentation 24V', 'Module d''alimentation régulée 24V/5A avec protection', 'v1.5', 'alimentation', 30, 85.00),
    ('PCB-COM-003', 'Carte Communication RS485/Ethernet', 'Interface de communication industrielle multi-protocole', 'v3.1', 'communication', 40, 145.75),
    ('PCB-HMI-004', 'Carte Interface Utilisateur', 'Interface tactile avec écran LCD 7 pouces', 'v2.0', 'interface', 50, 195.00),
    ('PCB-SENS-005', 'Carte Acquisition Capteurs', 'Module d''acquisition 16 voies analogiques/numériques', 'v1.8', 'capteur', 35, 98.50),
    ('PCB-CPU-006', 'Carte Processeur Industriel', 'Carte processeur haute performance pour traitement temps réel', 'v4.2', 'processeur', 55, 285.00),
    ('PCB-MEM-007', 'Carte Extension Mémoire', 'Module mémoire flash 256GB avec interface SATA', 'v1.2', 'memoire', 25, 165.00),
    ('PCB-DISP-008', 'Carte Affichage LED Matrix', 'Contrôleur d''affichage LED matriciel 64x32', 'v2.5', 'affichage', 38, 112.00);

-- Insertion des composants électroniques (50 composants variés)
INSERT INTO composants (reference, nom, description, type_composant, fabricant, stock_actuel, stock_minimum, prix_unitaire, delai_approvisionnement_jours) VALUES
    -- Résistances (8 composants)
    ('RES-0805-10K', 'Résistance 10kΩ 0805', 'Résistance CMS 10kΩ ±1% 0.125W', 'resistance', 'Yageo', 15000, 5000, 0.0025, 7),
    ('RES-0805-1K', 'Résistance 1kΩ 0805', 'Résistance CMS 1kΩ ±1% 0.125W', 'resistance', 'Yageo', 12000, 5000, 0.0025, 7),
    ('RES-0805-100R', 'Résistance 100Ω 0805', 'Résistance CMS 100Ω ±1% 0.125W', 'resistance', 'Yageo', 10000, 4000, 0.0025, 7),
    ('RES-1206-47K', 'Résistance 47kΩ 1206', 'Résistance CMS 47kΩ ±5% 0.25W', 'resistance', 'Vishay', 8000, 3000, 0.0035, 7),
    ('RES-0603-220R', 'Résistance 220Ω 0603', 'Résistance CMS 220Ω ±1% 0.1W', 'resistance', 'Panasonic', 9000, 3500, 0.0020, 7),
    ('RES-2512-0R1', 'Résistance 0.1Ω 2512', 'Résistance de puissance 0.1Ω 1W', 'resistance', 'Vishay', 2000, 500, 0.1250, 14),
    ('RES-0805-4K7', 'Résistance 4.7kΩ 0805', 'Résistance CMS 4.7kΩ ±1% 0.125W', 'resistance', 'Yageo', 11000, 4000, 0.0025, 7),
    ('RES-1206-10R', 'Résistance 10Ω 1206', 'Résistance CMS 10Ω ±5% 0.25W', 'resistance', 'KOA', 7000, 2500, 0.0040, 7),

    -- Condensateurs (10 composants)
    ('CAP-0805-100N', 'Condensateur 100nF 0805', 'Condensateur céramique X7R 50V', 'condensateur', 'Murata', 18000, 6000, 0.0150, 7),
    ('CAP-0805-10U', 'Condensateur 10µF 0805', 'Condensateur céramique X5R 16V', 'condensateur', 'Samsung', 8000, 3000, 0.0450, 7),
    ('CAP-1206-22U', 'Condensateur 22µF 1206', 'Condensateur céramique X5R 25V', 'condensateur', 'TDK', 6000, 2000, 0.0850, 7),
    ('CAP-ELEC-470U', 'Condensateur électrolytique 470µF', 'Condensateur électrolytique 35V radial', 'condensateur', 'Nichicon', 3000, 1000, 0.2500, 14),
    ('CAP-0603-1U', 'Condensateur 1µF 0603', 'Condensateur céramique X5R 10V', 'condensateur', 'Murata', 12000, 4000, 0.0250, 7),
    ('CAP-1210-47U', 'Condensateur 47µF 1210', 'Condensateur céramique X5R 16V', 'condensateur', 'Samsung', 4000, 1500, 0.1500, 7),
    ('CAP-0805-1N', 'Condensateur 1nF 0805', 'Condensateur céramique C0G 50V', 'condensateur', 'Kemet', 10000, 3500, 0.0180, 7),
    ('CAP-TANT-100U', 'Condensateur tantale 100µF', 'Condensateur tantale 16V CMS', 'condensateur', 'AVX', 2500, 800, 0.4500, 14),
    ('CAP-0805-4U7', 'Condensateur 4.7µF 0805', 'Condensateur céramique X5R 10V', 'condensateur', 'TDK', 9000, 3000, 0.0350, 7),
    ('CAP-1206-100U', 'Condensateur 100µF 1206', 'Condensateur céramique X5R 6.3V', 'condensateur', 'Murata', 5000, 1800, 0.1200, 7),

    -- Circuits intégrés (12 composants)
    ('IC-MCU-STM32F4', 'Microcontrôleur STM32F407', 'MCU ARM Cortex-M4 168MHz LQFP100', 'circuit_integre', 'STMicroelectronics', 500, 200, 8.5000, 21),
    ('IC-REG-LM7805', 'Régulateur 7805', 'Régulateur linéaire 5V 1A TO-220', 'circuit_integre', 'Texas Instruments', 1200, 400, 0.4500, 14),
    ('IC-REG-LM317', 'Régulateur LM317', 'Régulateur ajustable 1.2-37V TO-220', 'circuit_integre', 'Texas Instruments', 800, 300, 0.5500, 14),
    ('IC-OPAMP-LM358', 'Ampli-op LM358', 'Amplificateur opérationnel double DIP8', 'circuit_integre', 'Texas Instruments', 2000, 600, 0.2800, 14),
    ('IC-RS485-MAX485', 'Transceiver RS485 MAX485', 'Circuit interface RS485 DIP8', 'circuit_integre', 'Maxim', 1500, 500, 1.2500, 14),
    ('IC-ETH-W5500', 'Contrôleur Ethernet W5500', 'Circuit Ethernet TCP/IP LQFP48', 'circuit_integre', 'WIZnet', 300, 100, 4.5000, 21),
    ('IC-MEM-24C256', 'EEPROM 24C256', 'Mémoire EEPROM I2C 256Kbit DIP8', 'circuit_integre', 'Microchip', 1800, 600, 0.6500, 14),
    ('IC-ADC-ADS1115', 'Convertisseur ADC ADS1115', 'ADC 16-bit 4 canaux I2C MSOP10', 'circuit_integre', 'Texas Instruments', 600, 200, 3.2500, 14),
    ('IC-DRIVER-L293D', 'Driver moteur L293D', 'Driver pont H double DIP16', 'circuit_integre', 'STMicroelectronics', 900, 300, 1.8500, 14),
    ('IC-RTC-DS3231', 'Horloge temps réel DS3231', 'RTC haute précision I2C SO16', 'circuit_integre', 'Maxim', 400, 150, 2.7500, 14),
    ('IC-FLASH-W25Q128', 'Mémoire Flash W25Q128', 'Flash SPI 128Mbit SOIC8', 'circuit_integre', 'Winbond', 800, 250, 1.9500, 14),
    ('IC-DCDC-LM2596', 'Convertisseur DC-DC LM2596', 'Buck converter 3A TO-263', 'circuit_integre', 'Texas Instruments', 1000, 350, 1.4500, 14),

    -- Transistors (5 composants)
    ('TRANS-2N2222', 'Transistor 2N2222', 'Transistor NPN 40V 800mA TO-92', 'transistor', 'ON Semiconductor', 5000, 1500, 0.0850, 7),
    ('TRANS-BC547', 'Transistor BC547', 'Transistor NPN 45V 100mA TO-92', 'transistor', 'Fairchild', 6000, 2000, 0.0450, 7),
    ('TRANS-IRF540', 'MOSFET IRF540', 'MOSFET N-channel 100V 28A TO-220', 'transistor', 'Infineon', 1200, 400, 0.8500, 14),
    ('TRANS-BSS138', 'MOSFET BSS138', 'MOSFET N-channel 50V 220mA SOT-23', 'transistor', 'NXP', 3000, 1000, 0.1250, 7),
    ('TRANS-2N3906', 'Transistor 2N3906', 'Transistor PNP 40V 200mA TO-92', 'transistor', 'ON Semiconductor', 4500, 1500, 0.0650, 7),

    -- Diodes et LEDs (6 composants)
    ('DIODE-1N4148', 'Diode 1N4148', 'Diode signal 100V 200mA DO-35', 'diode', 'Vishay', 8000, 2500, 0.0350, 7),
    ('DIODE-1N4007', 'Diode 1N4007', 'Diode redressement 1000V 1A DO-41', 'diode', 'ON Semiconductor', 6000, 2000, 0.0450, 7),
    ('LED-RED-0805', 'LED Rouge 0805', 'LED rouge 2V 20mA CMS 0805', 'led', 'Kingbright', 10000, 3000, 0.0450, 7),
    ('LED-GREEN-0805', 'LED Verte 0805', 'LED verte 2.1V 20mA CMS 0805', 'led', 'Kingbright', 9000, 3000, 0.0450, 7),
    ('LED-BLUE-0805', 'LED Bleue 0805', 'LED bleue 3.2V 20mA CMS 0805', 'led', 'Kingbright', 8000, 2500, 0.0550, 7),
    ('DIODE-SCHOTTKY', 'Diode Schottky SS34', 'Diode Schottky 40V 3A DO-214', 'diode', 'Vishay', 3000, 1000, 0.1850, 7),

    -- Connecteurs (5 composants)
    ('CONN-RJ45', 'Connecteur RJ45', 'Connecteur Ethernet RJ45 avec LED', 'connecteur', 'Amphenol', 2000, 500, 0.8500, 14),
    ('CONN-USB-B', 'Connecteur USB-B', 'Connecteur USB type B traversant', 'connecteur', 'Molex', 1500, 400, 0.6500, 14),
    ('CONN-HEADER-40', 'Barrette 40 pins', 'Connecteur header mâle 2x20 2.54mm', 'connecteur', 'Harwin', 3000, 800, 0.4500, 7),
    ('CONN-TERMINAL-2P', 'Bornier 2 pôles', 'Bornier à vis 2 pôles 5.08mm', 'connecteur', 'Phoenix', 2500, 700, 0.3500, 14),
    ('CONN-JST-4P', 'Connecteur JST 4 pins', 'Connecteur JST-XH 4 positions', 'connecteur', 'JST', 4000, 1200, 0.2500, 7),

    -- Autres composants (4 composants)
    ('CRYSTAL-16MHZ', 'Quartz 16MHz', 'Cristal 16MHz HC-49S', 'cristal', 'ECS', 2000, 600, 0.3500, 14),
    ('CRYSTAL-32KHZ', 'Quartz 32.768kHz', 'Cristal horloger 32.768kHz cylindrique', 'cristal', 'Abracon', 1500, 500, 0.4500, 14),
    ('RELAY-5V', 'Relais 5V', 'Relais électromécanique 5V 10A SPDT', 'relais', 'Omron', 800, 250, 1.2500, 14),
    ('INDUCTOR-100U', 'Inductance 100µH', 'Inductance de puissance 100µH 3A', 'inductance', 'Würth', 1200, 400, 0.6500, 14);

-- Insertion de la nomenclature (BOM) - Liaison cartes/composants
-- Carte 1: PCB-CTRL-001 (Contrôleur Principal) - 28 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (1, 21, 1, 'U1'), -- MCU STM32F4
    (1, 1, 8, 'R1-R8'), -- Résistances 10kΩ
    (1, 2, 6, 'R9-R14'), -- Résistances 1kΩ
    (1, 7, 4, 'R15-R18'), -- Résistances 4.7kΩ
    (1, 9, 12, 'C1-C12'), -- Condensateurs 100nF
    (1, 10, 4, 'C13-C16'), -- Condensateurs 10µF
    (1, 13, 2, 'C17-C18'), -- Condensateurs 1µF
    (1, 28, 2, 'U2-U3'), -- ADC ADS1115
    (1, 31, 1, 'U4'), -- RTC DS3231
    (1, 47, 1, 'Y1'), -- Quartz 16MHz
    (1, 48, 1, 'Y2'), -- Quartz 32.768kHz
    (1, 38, 2, 'D1-D2'), -- Diodes 1N4148
    (1, 40, 1, 'LED1'), -- LED Rouge
    (1, 41, 1, 'LED2'), -- LED Verte
    (1, 42, 1, 'LED3'), -- LED Bleue
    (1, 45, 1, 'J1'), -- Connecteur Header 40
    (1, 47, 2, 'J2-J3'); -- Connecteur JST 4P

-- Carte 2: PCB-PWR-002 (Alimentation 24V) - 22 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (2, 22, 2, 'U1-U2'), -- Régulateur 7805
    (2, 23, 1, 'U3'), -- Régulateur LM317
    (2, 33, 1, 'U4'), -- Convertisseur DC-DC LM2596
    (2, 6, 2, 'R1-R2'), -- Résistances 0.1Ω puissance
    (2, 4, 4, 'R3-R6'), -- Résistances 47kΩ
    (2, 12, 4, 'C1-C4'), -- Condensateurs électrolytiques 470µF
    (2, 11, 3, 'C5-C7'), -- Condensateurs 22µF
    (2, 14, 2, 'C8-C9'), -- Condensateurs 47µF
    (2, 39, 4, 'D1-D4'), -- Diodes 1N4007
    (2, 43, 2, 'D5-D6'), -- Diodes Schottky
    (2, 50, 1, 'L1'), -- Inductance 100µH
    (2, 40, 1, 'LED1'), -- LED Rouge
    (2, 41, 1, 'LED2'), -- LED Verte
    (2, 46, 2, 'J1-J2'); -- Bornier 2 pôles

-- Carte 3: PCB-COM-003 (Communication RS485/Ethernet) - 25 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (3, 25, 2, 'U1-U2'), -- Transceiver RS485
    (3, 26, 1, 'U3'), -- Contrôleur Ethernet W5500
    (3, 27, 1, 'U4'), -- EEPROM 24C256
    (3, 32, 1, 'U5'), -- Flash W25Q128
    (3, 1, 10, 'R1-R10'), -- Résistances 10kΩ
    (3, 3, 6, 'R11-R16'), -- Résistances 100Ω
    (3, 9, 15, 'C1-C15'), -- Condensateurs 100nF
    (3, 10, 3, 'C16-C18'), -- Condensateurs 10µF
    (3, 38, 4, 'D1-D4'), -- Diodes 1N4148
    (3, 40, 2, 'LED1-LED2'), -- LED Rouge
    (3, 41, 2, 'LED3-LED4'), -- LED Verte
    (3, 44, 1, 'J1'), -- Connecteur RJ45
    (3, 47, 2, 'J2-J3'); -- Connecteur JST 4P

-- Carte 4: PCB-HMI-004 (Interface Utilisateur) - 18 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (4, 21, 1, 'U1'), -- MCU STM32F4
    (4, 24, 2, 'U2-U3'), -- Ampli-op LM358
    (4, 1, 6, 'R1-R6'), -- Résistances 10kΩ
    (4, 2, 8, 'R7-R14'), -- Résistances 1kΩ
    (4, 5, 4, 'R15-R18'), -- Résistances 220Ω
    (4, 9, 10, 'C1-C10'), -- Condensateurs 100nF
    (4, 10, 4, 'C11-C14'), -- Condensateurs 10µF
    (4, 47, 1, 'Y1'), -- Quartz 16MHz
    (4, 40, 3, 'LED1-LED3'), -- LED Rouge
    (4, 41, 3, 'LED4-LED6'), -- LED Verte
    (4, 42, 2, 'LED7-LED8'), -- LED Bleue
    (4, 45, 1, 'J1'), -- Connecteur Header 40
    (4, 45, 1, 'J2'); -- Connecteur USB-B

-- Carte 5: PCB-SENS-005 (Acquisition Capteurs) - 30 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (5, 28, 4, 'U1-U4'), -- ADC ADS1115
    (5, 24, 4, 'U5-U8'), -- Ampli-op LM358
    (5, 1, 16, 'R1-R16'), -- Résistances 10kΩ
    (5, 2, 8, 'R17-R24'), -- Résistances 1kΩ
    (5, 7, 6, 'R25-R30'), -- Résistances 4.7kΩ
    (5, 9, 20, 'C1-C20'), -- Condensateurs 100nF
    (5, 10, 8, 'C21-C28'), -- Condensateurs 10µF
    (5, 13, 4, 'C29-C32'), -- Condensateurs 1µF
    (5, 38, 8, 'D1-D8'), -- Diodes 1N4148
    (5, 34, 4, 'Q1-Q4'), -- Transistors 2N2222
    (5, 40, 2, 'LED1-LED2'), -- LED Rouge
    (5, 41, 2, 'LED3-LED4'), -- LED Verte
    (5, 46, 4, 'J1-J4'), -- Bornier 2 pôles
    (5, 47, 4, 'J5-J8'); -- Connecteur JST 4P

-- Carte 6: PCB-CPU-006 (Processeur Industriel) - 24 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (6, 21, 2, 'U1-U2'), -- MCU STM32F4
    (6, 32, 2, 'U3-U4'), -- Flash W25Q128
    (6, 27, 1, 'U5'), -- EEPROM 24C256
    (6, 31, 1, 'U6'), -- RTC DS3231
    (6, 1, 12, 'R1-R12'), -- Résistances 10kΩ
    (6, 2, 8, 'R13-R20'), -- Résistances 1kΩ
    (6, 9, 18, 'C1-C18'), -- Condensateurs 100nF
    (6, 10, 6, 'C19-C24'), -- Condensateurs 10µF
    (6, 11, 4, 'C25-C28'), -- Condensateurs 22µF
    (6, 47, 2, 'Y1-Y2'), -- Quartz 16MHz
    (6, 48, 1, 'Y3'), -- Quartz 32.768kHz
    (6, 40, 2, 'LED1-LED2'), -- LED Rouge
    (6, 41, 2, 'LED3-LED4'), -- LED Verte
    (6, 42, 2, 'LED5-LED6'), -- LED Bleue
    (6, 45, 2, 'J1-J2'); -- Connecteur Header 40

-- Carte 7: PCB-MEM-007 (Extension Mémoire) - 15 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (7, 32, 4, 'U1-U4'), -- Flash W25Q128
    (7, 27, 2, 'U5-U6'), -- EEPROM 24C256
    (7, 1, 8, 'R1-R8'), -- Résistances 10kΩ
    (7, 3, 4, 'R9-R12'), -- Résistances 100Ω
    (7, 9, 12, 'C1-C12'), -- Condensateurs 100nF
    (7, 10, 4, 'C13-C16'), -- Condensateurs 10µF
    (7, 40, 2, 'LED1-LED2'), -- LED Rouge
    (7, 41, 2, 'LED3-LED4'), -- LED Verte
    (7, 45, 1, 'J1'); -- Connecteur Header 40

-- Carte 8: PCB-DISP-008 (Affichage LED Matrix) - 20 composants
INSERT INTO nomenclature (carte_id, composant_id, quantite, reference_designator) VALUES
    (8, 21, 1, 'U1'), -- MCU STM32F4
    (8, 29, 4, 'U2-U5'), -- Driver moteur L293D (utilisé pour LED)
    (8, 3, 16, 'R1-R16'), -- Résistances 100Ω
    (8, 5, 8, 'R17-R24'), -- Résistances 220Ω
    (8, 9, 10, 'C1-C10'), -- Condensateurs 100nF
    (8, 10, 4, 'C11-C14'), -- Condensateurs 10µF
    (8, 47, 1, 'Y1'), -- Quartz 16MHz
    (8, 40, 8, 'LED1-LED8'), -- LED Rouge
    (8, 41, 8, 'LED9-LED16'), -- LED Verte
    (8, 42, 8, 'LED17-LED24'), -- LED Bleue
    (8, 36, 4, 'Q1-Q4'), -- MOSFET BSS138
    (8, 45, 1, 'J1'), -- Connecteur Header 40
    (8, 46, 2, 'J2-J3'); -- Bornier 2 pôles

-- Insertion des opérations de fabrication
INSERT INTO operations_fabrication (code_operation, nom, description, type_operation, categorie, duree_standard_minutes, cout_horaire) VALUES
    ('OP-010', 'Sérigraphie pâte à souder', 'Application de pâte à souder par sérigraphie', 'automatique', 'assemblage_cms', 3.5, 45.00),
    ('OP-020', 'Placement composants CMS', 'Placement automatique des composants CMS', 'automatique', 'assemblage_cms', 8.0, 65.00),
    ('OP-030', 'Four de refusion', 'Soudure par refusion en four', 'automatique', 'soudure_refusion', 12.0, 35.00),
    ('OP-040', 'Inspection AOI', 'Inspection optique automatique post-refusion', 'automatique', 'inspection_aoi', 4.0, 55.00),
    ('OP-050', 'Insertion composants traversants', 'Insertion manuelle des composants traversants', 'manuelle', 'assemblage_traversant', 15.0, 28.00),
    ('OP-060', 'Soudure vague', 'Soudure à la vague des composants traversants', 'automatique', 'soudure_vague', 6.0, 42.00),
    ('OP-070', 'Nettoyage carte', 'Nettoyage des résidus de flux', 'automatique', 'nettoyage', 5.0, 30.00),
    ('OP-080', 'Inspection visuelle', 'Contrôle visuel de la qualité de soudure', 'manuelle', 'inspection_visuelle', 8.0, 32.00),
    ('OP-090', 'Test électrique', 'Test électrique en circuit (ICT)', 'automatique', 'test_electrique', 6.0, 50.00),
    ('OP-100', 'Programmation firmware', 'Programmation du microcontrôleur', 'automatique', 'test_electrique', 4.0, 45.00),
    ('OP-110', 'Test fonctionnel', 'Test fonctionnel complet de la carte', 'automatique', 'test_fonctionnel', 10.0, 55.00),
    ('OP-120', 'Découpe panneaux', 'Découpe des cartes du panneau', 'automatique', 'decoupe', 3.0, 38.00),
    ('OP-130', 'Retouche manuelle', 'Retouche et réparation manuelle', 'manuelle', 'manutention', 20.0, 35.00),
    ('OP-140', 'Conditionnement', 'Emballage et conditionnement final', 'manuelle', 'conditionnement', 5.0, 25.00),
    ('OP-150', 'Contrôle final', 'Contrôle qualité final avant expédition', 'manuelle', 'inspection_visuelle', 6.0, 30.00);

-- Insertion des gammes de fabrication (séquence d'opérations pour chaque carte)
-- Gamme pour Carte 1: PCB-CTRL-001 (Contrôleur Principal)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (1, 1, 1, 3.5),   -- Sérigraphie
    (1, 2, 2, 10.0),  -- Placement CMS
    (1, 3, 3, 12.0),  -- Refusion
    (1, 4, 4, 4.5),   -- AOI
    (1, 5, 5, 12.0),  -- Insertion traversants
    (1, 6, 6, 6.0),   -- Soudure vague
    (1, 7, 7, 5.0),   -- Nettoyage
    (1, 8, 8, 8.0),   -- Inspection visuelle
    (1, 9, 9, 6.0),   -- Test électrique
    (1, 10, 10, 4.0), -- Programmation
    (1, 11, 11, 10.0), -- Test fonctionnel
    (1, 12, 12, 3.0), -- Découpe
    (1, 14, 13, 5.0), -- Conditionnement
    (1, 15, 14, 6.0); -- Contrôle final

-- Gamme pour Carte 2: PCB-PWR-002 (Alimentation)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (2, 1, 1, 3.0),
    (2, 2, 2, 6.0),
    (2, 3, 3, 12.0),
    (2, 4, 4, 4.0),
    (2, 5, 5, 10.0),
    (2, 6, 6, 6.0),
    (2, 7, 7, 5.0),
    (2, 8, 8, 7.0),
    (2, 9, 9, 8.0),
    (2, 11, 10, 12.0),
    (2, 12, 11, 3.0),
    (2, 14, 12, 5.0),
    (2, 15, 13, 6.0);

-- Gamme pour Carte 3: PCB-COM-003 (Communication)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (3, 1, 1, 3.5),
    (3, 2, 2, 9.0),
    (3, 3, 3, 12.0),
    (3, 4, 4, 4.5),
    (3, 5, 5, 8.0),
    (3, 6, 6, 6.0),
    (3, 7, 7, 5.0),
    (3, 8, 8, 8.0),
    (3, 9, 9, 7.0),
    (3, 10, 10, 5.0),
    (3, 11, 11, 12.0),
    (3, 12, 12, 3.0),
    (3, 14, 13, 5.0),
    (3, 15, 14, 6.0);

-- Gamme pour Carte 4: PCB-HMI-004 (Interface Utilisateur)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (4, 1, 1, 4.0),
    (4, 2, 2, 8.0),
    (4, 3, 3, 12.0),
    (4, 4, 4, 5.0),
    (4, 5, 5, 15.0),
    (4, 6, 6, 6.0),
    (4, 7, 7, 5.0),
    (4, 8, 8, 10.0),
    (4, 9, 9, 7.0),
    (4, 10, 10, 4.0),
    (4, 11, 11, 15.0),
    (4, 12, 12, 3.0),
    (4, 14, 13, 5.0),
    (4, 15, 14, 7.0);

-- Gamme pour Carte 5: PCB-SENS-005 (Acquisition Capteurs)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (5, 1, 1, 3.5),
    (5, 2, 2, 7.0),
    (5, 3, 3, 12.0),
    (5, 4, 4, 4.0),
    (5, 5, 5, 12.0),
    (5, 6, 6, 6.0),
    (5, 7, 7, 5.0),
    (5, 8, 8, 8.0),
    (5, 9, 9, 8.0),
    (5, 11, 10, 12.0),
    (5, 12, 11, 3.0),
    (5, 14, 12, 5.0),
    (5, 15, 13, 6.0);

-- Gamme pour Carte 6: PCB-CPU-006 (Processeur Industriel)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (6, 1, 1, 4.0),
    (6, 2, 2, 12.0),
    (6, 3, 3, 12.0),
    (6, 4, 4, 5.0),
    (6, 5, 5, 10.0),
    (6, 6, 6, 6.0),
    (6, 7, 7, 5.0),
    (6, 8, 8, 10.0),
    (6, 9, 9, 8.0),
    (6, 10, 10, 6.0),
    (6, 11, 11, 15.0),
    (6, 12, 12, 3.0),
    (6, 14, 13, 5.0),
    (6, 15, 14, 7.0);

-- Gamme pour Carte 7: PCB-MEM-007 (Extension Mémoire)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (7, 1, 1, 3.0),
    (7, 2, 2, 5.0),
    (7, 3, 3, 12.0),
    (7, 4, 4, 3.5),
    (7, 7, 5, 5.0),
    (7, 8, 6, 6.0),
    (7, 9, 7, 6.0),
    (7, 10, 8, 5.0),
    (7, 11, 9, 10.0),
    (7, 12, 10, 3.0),
    (7, 14, 11, 5.0),
    (7, 15, 12, 5.0);

-- Gamme pour Carte 8: PCB-DISP-008 (Affichage LED)
INSERT INTO gammes_fabrication (carte_id, operation_id, ordre_operation, duree_minutes) VALUES
    (8, 1, 1, 3.5),
    (8, 2, 2, 8.0),
    (8, 3, 3, 12.0),
    (8, 4, 4, 4.5),
    (8, 5, 5, 10.0),
    (8, 6, 6, 6.0),
    (8, 7, 7, 5.0),
    (8, 8, 8, 9.0),
    (8, 9, 9, 7.0),
    (8, 10, 10, 4.0),
    (8, 11, 11, 12.0),
    (8, 12, 12, 3.0),
    (8, 14, 13, 5.0),
    (8, 15, 14, 6.0);

-- Insertion des ordres de fabrication (3 mois d'historique: Avril, Mai, Juin 2024)
INSERT INTO ordres_fabrication (numero_of, carte_id, quantite_prevue, quantite_produite, quantite_conforme, quantite_rebut, date_lancement, date_fin_prevue, date_fin_reelle, statut, priorite, commentaire) VALUES
    -- Avril 2024
    ('OF-2024-0401', 1, 500, 500, 495, 5, '2024-04-01', '2024-04-03', '2024-04-03', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0402', 2, 300, 300, 298, 2, '2024-04-01', '2024-04-02', '2024-04-02', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0403', 3, 200, 200, 197, 3, '2024-04-02', '2024-04-04', '2024-04-04', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0404', 4, 150, 150, 148, 2, '2024-04-03', '2024-04-05', '2024-04-05', 'termine', 'haute', 'Commande client prioritaire'),
    ('OF-2024-0405', 5, 400, 400, 392, 8, '2024-04-04', '2024-04-06', '2024-04-06', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0406', 6, 100, 100, 98, 2, '2024-04-05', '2024-04-08', '2024-04-08', 'termine', 'urgente', 'Commande urgente'),
    ('OF-2024-0407', 7, 250, 250, 248, 2, '2024-04-08', '2024-04-10', '2024-04-10', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0408', 8, 350, 350, 343, 7, '2024-04-09', '2024-04-11', '2024-04-11', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0409', 1, 600, 600, 591, 9, '2024-04-10', '2024-04-12', '2024-04-12', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0410', 2, 400, 400, 396, 4, '2024-04-11', '2024-04-13', '2024-04-13', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0411', 3, 250, 250, 245, 5, '2024-04-12', '2024-04-15', '2024-04-15', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0412', 4, 200, 200, 198, 2, '2024-04-15', '2024-04-17', '2024-04-17', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0413', 5, 450, 450, 441, 9, '2024-04-16', '2024-04-18', '2024-04-18', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0414', 6, 120, 120, 117, 3, '2024-04-17', '2024-04-20', '2024-04-20', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0415', 7, 300, 300, 295, 5, '2024-04-18', '2024-04-20', '2024-04-20', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0416', 8, 380, 380, 374, 6, '2024-04-19', '2024-04-22', '2024-04-22', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0417', 1, 550, 550, 543, 7, '2024-04-22', '2024-04-24', '2024-04-24', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0418', 2, 350, 350, 347, 3, '2024-04-23', '2024-04-25', '2024-04-25', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0419', 3, 280, 280, 275, 5, '2024-04-24', '2024-04-26', '2024-04-26', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0420', 4, 180, 180, 177, 3, '2024-04-25', '2024-04-27', '2024-04-27', 'termine', 'normale', 'Production standard'),

    -- Mai 2024
    ('OF-2024-0501', 5, 500, 500, 490, 10, '2024-05-02', '2024-05-04', '2024-05-04', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0502', 6, 150, 150, 147, 3, '2024-05-03', '2024-05-06', '2024-05-06', 'termine', 'urgente', 'Commande urgente'),
    ('OF-2024-0503', 7, 320, 320, 315, 5, '2024-05-06', '2024-05-08', '2024-05-08', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0504', 8, 400, 400, 392, 8, '2024-05-07', '2024-05-09', '2024-05-09', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0505', 1, 650, 650, 640, 10, '2024-05-08', '2024-05-10', '2024-05-10', 'termine', 'haute', 'Grosse commande'),
    ('OF-2024-0506', 2, 380, 380, 376, 4, '2024-05-09', '2024-05-11', '2024-05-11', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0507', 3, 300, 300, 294, 6, '2024-05-10', '2024-05-13', '2024-05-13', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0508', 4, 220, 220, 217, 3, '2024-05-13', '2024-05-15', '2024-05-15', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0509', 5, 480, 480, 471, 9, '2024-05-14', '2024-05-16', '2024-05-16', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0510', 6, 130, 130, 128, 2, '2024-05-15', '2024-05-18', '2024-05-18', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0511', 7, 350, 350, 343, 7, '2024-05-16', '2024-05-18', '2024-05-18', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0512', 8, 420, 420, 412, 8, '2024-05-17', '2024-05-20', '2024-05-20', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0513', 1, 580, 580, 572, 8, '2024-05-20', '2024-05-22', '2024-05-22', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0514', 2, 360, 360, 356, 4, '2024-05-21', '2024-05-23', '2024-05-23', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0515', 3, 270, 270, 265, 5, '2024-05-22', '2024-05-24', '2024-05-24', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0516', 4, 190, 190, 188, 2, '2024-05-23', '2024-05-25', '2024-05-25', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0517', 5, 510, 510, 500, 10, '2024-05-24', '2024-05-27', '2024-05-27', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0518', 6, 140, 140, 137, 3, '2024-05-27', '2024-05-30', '2024-05-30', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0519', 7, 330, 330, 325, 5, '2024-05-28', '2024-05-30', '2024-05-30', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0520', 8, 390, 390, 383, 7, '2024-05-29', '2024-05-31', '2024-05-31', 'termine', 'normale', 'Production standard'),

    -- Juin 2024
    ('OF-2024-0601', 1, 620, 620, 611, 9, '2024-06-03', '2024-06-05', '2024-06-05', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0602', 2, 390, 390, 386, 4, '2024-06-04', '2024-06-06', '2024-06-06', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0603', 3, 310, 310, 304, 6, '2024-06-05', '2024-06-07', '2024-06-07', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0604', 4, 210, 210, 207, 3, '2024-06-06', '2024-06-08', '2024-06-08', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0605', 5, 530, 530, 520, 10, '2024-06-07', '2024-06-10', '2024-06-10', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0606', 6, 160, 160, 157, 3, '2024-06-10', '2024-06-13', '2024-06-13', 'termine', 'urgente', 'Commande urgente'),
    ('OF-2024-0607', 7, 360, 360, 354, 6, '2024-06-11', '2024-06-13', '2024-06-13', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0608', 8, 440, 440, 432, 8, '2024-06-12', '2024-06-14', '2024-06-14', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0609', 1, 590, 590, 582, 8, '2024-06-13', '2024-06-15', '2024-06-15', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0610', 2, 370, 370, 366, 4, '2024-06-14', '2024-06-17', '2024-06-17', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0611', 3, 290, 290, 285, 5, '2024-06-17', '2024-06-19', '2024-06-19', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0612', 4, 200, 200, 197, 3, '2024-06-18', '2024-06-20', '2024-06-20', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0613', 5, 490, 490, 481, 9, '2024-06-19', '2024-06-21', '2024-06-21', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0614', 6, 145, 145, 142, 3, '2024-06-20', '2024-06-23', '2024-06-23', 'termine', 'haute', 'Production standard'),
    ('OF-2024-0615', 7, 340, 340, 335, 5, '2024-06-21', '2024-06-24', '2024-06-24', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0616', 8, 410, 410, 403, 7, '2024-06-24', '2024-06-26', '2024-06-26', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0617', 1, 560, 560, 552, 8, '2024-06-25', '2024-06-27', '2024-06-27', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0618', 2, 340, 340, 337, 3, '2024-06-26', '2024-06-28', '2024-06-28', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0619', 3, 260, 260, 256, 4, '2024-06-27', '2024-06-29', '2024-06-29', 'termine', 'normale', 'Production standard'),
    ('OF-2024-0620', 4, 170, 170, 168, 2, '2024-06-28', '2024-07-01', '2024-07-01', 'termine', 'normale', 'Production standard'),

    -- Ordres en cours et planifiés (fin juin / début juillet)
    ('OF-2024-0621', 5, 520, 480, 472, 8, '2024-06-29', '2024-07-02', NULL, 'en_cours', 'normale', 'Production en cours'),
    ('OF-2024-0622', 6, 155, 120, 118, 2, '2024-07-01', '2024-07-04', NULL, 'en_cours', 'haute', 'Production en cours'),
    ('OF-2024-0623', 7, 370, 0, 0, 0, '2024-07-02', '2024-07-05', NULL, 'planifie', 'normale', 'Production planifiée'),
    ('OF-2024-0624', 8, 450, 0, 0, 0, '2024-07-03', '2024-07-06', NULL, 'planifie', 'normale', 'Production planifiée'),
    ('OF-2024-0625', 1, 600, 0, 0, 0, '2024-07-04', '2024-07-07', NULL, 'planifie', 'haute', 'Grosse commande planifiée');

-- Insertion du suivi de production (exemples pour quelques ordres)
-- Suivi pour OF-2024-0401 (Carte 1 - 500 pièces)
INSERT INTO suivi_production (ordre_fabrication_id, operation_id, date_debut, date_fin, quantite_traitee, quantite_conforme, quantite_defaut, operateur, machine, statut) VALUES
    (1, 1, '2024-04-01 08:00:00', '2024-04-01 08:30:00', 500, 500, 0, 'Marie Dubois', 'SERIGRAPHE-01', 'termine'),
    (1, 2, '2024-04-01 08:45:00', '2024-04-01 10:15:00', 500, 500, 0, 'AUTO', 'PICK-PLACE-01', 'termine'),
    (1, 3, '2024-04-01 10:30:00', '2024-04-01 12:30:00', 500, 500, 0, 'AUTO', 'FOUR-REFUSION-01', 'termine'),
    (1, 4, '2024-04-01 13:00:00', '2024-04-01 13:45:00', 500, 498, 2, 'AUTO', 'AOI-01', 'termine'),
    (1, 5, '2024-04-01 14:00:00', '2024-04-01 16:00:00', 498, 498, 0, 'Jean Martin', NULL, 'termine'),
    (1, 6, '2024-04-01 16:15:00', '2024-04-01 17:15:00', 498, 497, 1, 'AUTO', 'VAGUE-01', 'termine'),
    (1, 7, '2024-04-02 08:00:00', '2024-04-02 08:50:00', 497, 497, 0, 'AUTO', 'NETTOYAGE-01', 'termine'),
    (1, 8, '2024-04-02 09:00:00', '2024-04-02 10:20:00', 497, 496, 1, 'Sophie Laurent', NULL, 'termine'),
    (1, 9, '2024-04-02 10:30:00', '2024-04-02 11:30:00', 496, 496, 0, 'AUTO', 'ICT-01', 'termine'),
    (1, 10, '2024-04-02 11:45:00', '2024-04-02 12:30:00', 496, 496, 0, 'AUTO', 'PROG-01', 'termine'),
    (1, 11, '2024-04-02 13:30:00', '2024-04-02 15:10:00', 496, 495, 1, 'AUTO', 'TEST-FUNC-01', 'termine'),
    (1, 12, '2024-04-02 15:30:00', '2024-04-02 16:00:00', 495, 495, 0, 'AUTO', 'DECOUPE-01', 'termine'),
    (1, 14, '2024-04-03 08:00:00', '2024-04-03 09:30:00', 495, 495, 0, 'Luc Petit', NULL, 'termine'),
    (1, 15, '2024-04-03 09:45:00', '2024-04-03 11:00:00', 495, 495, 0, 'Claire Moreau', NULL, 'termine');

-- Suivi pour OF-2024-0505 (Carte 1 - 650 pièces - grosse commande)
INSERT INTO suivi_production (ordre_fabrication_id, operation_id, date_debut, date_fin, quantite_traitee, quantite_conforme, quantite_defaut, operateur, machine, statut) VALUES
    (25, 1, '2024-05-08 08:00:00', '2024-05-08 08:40:00', 650, 650, 0, 'Marie Dubois', 'SERIGRAPHE-01', 'termine'),
    (25, 2, '2024-05-08 09:00:00', '2024-05-08 11:00:00', 650, 650, 0, 'AUTO', 'PICK-PLACE-01', 'termine'),
    (25, 3, '2024-05-08 11:15:00', '2024-05-08 13:30:00', 650, 650, 0, 'AUTO', 'FOUR-REFUSION-01', 'termine'),
    (25, 4, '2024-05-08 14:00:00', '2024-05-08 15:00:00', 650, 646, 4, 'AUTO', 'AOI-01', 'termine'),
    (25, 5, '2024-05-08 15:15:00', '2024-05-08 17:30:00', 646, 646, 0, 'Jean Martin', NULL, 'termine'),
    (25, 6, '2024-05-09 08:00:00', '2024-05-09 09:15:00', 646, 644, 2, 'AUTO', 'VAGUE-01', 'termine'),
    (25, 7, '2024-05-09 09:30:00', '2024-05-09 10:30:00', 644, 644, 0, 'AUTO', 'NETTOYAGE-01', 'termine'),
    (25, 8, '2024-05-09 10:45:00', '2024-05-09 12:15:00', 644, 642, 2, 'Sophie Laurent', NULL, 'termine'),
    (25, 9, '2024-05-09 13:00:00', '2024-05-09 14:15:00', 642, 642, 0, 'AUTO', 'ICT-01', 'termine'),
    (25, 10, '2024-05-09 14:30:00', '2024-05-09 15:20:00', 642, 642, 0, 'AUTO', 'PROG-01', 'termine'),
    (25, 11, '2024-05-09 15:45:00', '2024-05-09 17:30:00', 642, 640, 2, 'AUTO', 'TEST-FUNC-01', 'termine'),
    (25, 12, '2024-05-10 08:00:00', '2024-05-10 08:35:00', 640, 640, 0, 'AUTO', 'DECOUPE-01', 'termine'),
    (25, 14, '2024-05-10 09:00:00', '2024-05-10 10:45:00', 640, 640, 0, 'Luc Petit', NULL, 'termine'),
    (25, 15, '2024-05-10 11:00:00', '2024-05-10 12:30:00', 640, 640, 0, 'Claire Moreau', NULL, 'termine');

-- Suivi pour OF-2024-0606 (Carte 6 - 160 pièces - commande urgente)
INSERT INTO suivi_production (ordre_fabrication_id, operation_id, date_debut, date_fin, quantite_traitee, quantite_conforme, quantite_defaut, operateur, machine, statut) VALUES
    (46, 1, '2024-06-10 08:00:00', '2024-06-10 08:45:00', 160, 160, 0, 'Marie Dubois', 'SERIGRAPHE-02', 'termine'),
    (46, 2, '2024-06-10 09:00:00', '2024-06-10 11:30:00', 160, 160, 0, 'AUTO', 'PICK-PLACE-02', 'termine'),
    (46, 3, '2024-06-10 11:45:00', '2024-06-10 13:45:00', 160, 160, 0, 'AUTO', 'FOUR-REFUSION-02', 'termine'),
    (46, 4, '2024-06-10 14:00:00', '2024-06-10 14:50:00', 160, 159, 1, 'AUTO', 'AOI-02', 'termine'),
    (46, 5, '2024-06-10 15:00:00', '2024-06-10 16:40:00', 159, 159, 0, 'Thomas Roux', NULL, 'termine'),
    (46, 6, '2024-06-11 08:00:00', '2024-06-11 09:00:00', 159, 159, 0, 'AUTO', 'VAGUE-02', 'termine'),
    (46, 7, '2024-06-11 09:15:00', '2024-06-11 10:05:00', 159, 159, 0, 'AUTO', 'NETTOYAGE-02', 'termine'),
    (46, 8, '2024-06-11 10:15:00', '2024-06-11 12:00:00', 159, 158, 1, 'Sophie Laurent', NULL, 'termine'),
    (46, 9, '2024-06-11 13:00:00', '2024-06-11 14:20:00', 158, 158, 0, 'AUTO', 'ICT-02', 'termine'),
    (46, 10, '2024-06-11 14:30:00', '2024-06-11 15:30:00', 158, 158, 0, 'AUTO', 'PROG-02', 'termine'),
    (46, 11, '2024-06-12 08:00:00', '2024-06-12 10:30:00', 158, 157, 1, 'AUTO', 'TEST-FUNC-02', 'termine'),
    (46, 12, '2024-06-12 10:45:00', '2024-06-12 11:15:00', 157, 157, 0, 'AUTO', 'DECOUPE-02', 'termine'),
    (46, 14, '2024-06-12 13:00:00', '2024-06-12 14:20:00', 157, 157, 0, 'Luc Petit', NULL, 'termine'),
    (46, 15, '2024-06-13 08:00:00', '2024-06-13 09:30:00', 157, 157, 0, 'Claire Moreau', NULL, 'termine');

-- Suivi pour OF-2024-0621 (Carte 5 - 520 pièces - en cours)
INSERT INTO suivi_production (ordre_fabrication_id, operation_id, date_debut, date_fin, quantite_traitee, quantite_conforme, quantite_defaut, operateur, machine, statut) VALUES
    (61, 1, '2024-06-29 08:00:00', '2024-06-29 08:40:00', 520, 520, 0, 'Marie Dubois', 'SERIGRAPHE-01', 'termine'),
    (61, 2, '2024-06-29 09:00:00', '2024-06-29 10:50:00', 520, 520, 0, 'AUTO', 'PICK-PLACE-01', 'termine'),
    (61, 3, '2024-06-29 11:00:00', '2024-06-29 13:00:00', 520, 520, 0, 'AUTO', 'FOUR-REFUSION-01', 'termine'),
    (61, 4, '2024-06-29 13:30:00', '2024-06-29 14:20:00', 520, 518, 2, 'AUTO', 'AOI-01', 'termine'),
    (61, 5, '2024-06-29 14:30:00', '2024-06-29 16:45:00', 518, 518, 0, 'Jean Martin', NULL, 'termine'),
    (61, 6, '2024-07-01 08:00:00', '2024-07-01 09:10:00', 518, 516, 2, 'AUTO', 'VAGUE-01', 'termine'),
    (61, 7, '2024-07-01 09:30:00', '2024-07-01 10:25:00', 516, 516, 0, 'AUTO', 'NETTOYAGE-01', 'termine'),
    (61, 8, '2024-07-01 10:45:00', '2024-07-01 12:30:00', 516, 514, 2, 'Sophie Laurent', NULL, 'termine'),
    (61, 9, '2024-07-01 13:30:00', '2024-07-01 14:50:00', 514, 514, 0, 'AUTO', 'ICT-01', 'termine'),
    (61, 11, '2024-07-01 15:00:00', '2024-07-01 17:15:00', 514, 512, 2, 'AUTO', 'TEST-FUNC-01', 'termine'),
    (61, 12, '2024-07-02 08:00:00', '2024-07-02 08:30:00', 512, 512, 0, 'AUTO', 'DECOUPE-01', 'termine'),
    (61, 14, '2024-07-02 09:00:00', '2024-07-02 10:30:00', 512, 512, 0, 'Luc Petit', NULL, 'termine'),
    (61, 15, '2024-07-02 10:45:00', NULL, 480, 472, 8, 'Claire Moreau', NULL, 'en_cours');

-- Suivi pour OF-2024-0622 (Carte 6 - 155 pièces - en cours)
INSERT INTO suivi_production (ordre_fabrication_id, operation_id, date_debut, date_fin, quantite_traitee, quantite_conforme, quantite_defaut, operateur, machine, statut) VALUES
    (62, 1, '2024-07-01 08:00:00', '2024-07-01 08:45:00', 155, 155, 0, 'Marie Dubois', 'SERIGRAPHE-02', 'termine'),
    (62, 2, '2024-07-01 09:00:00', '2024-07-01 11:30:00', 155, 155, 0, 'AUTO', 'PICK-PLACE-02', 'termine'),
    (62, 3, '2024-07-01 11:45:00', '2024-07-01 13:45:00', 155, 155, 0, 'AUTO', 'FOUR-REFUSION-02', 'termine'),
    (62, 4, '2024-07-01 14:00:00', '2024-07-01 14:50:00', 155, 154, 1, 'AUTO', 'AOI-02', 'termine'),
    (62, 5, '2024-07-01 15:00:00', '2024-07-01 16:40:00', 154, 154, 0, 'Thomas Roux', NULL, 'termine'),
    (62, 6, '2024-07-02 08:00:00', '2024-07-02 09:00:00', 154, 154, 0, 'AUTO', 'VAGUE-02', 'termine'),
    (62, 7, '2024-07-02 09:15:00', '2024-07-02 10:05:00', 154, 154, 0, 'AUTO', 'NETTOYAGE-02', 'termine'),
    (62, 8, '2024-07-02 10:15:00', '2024-07-02 12:00:00', 154, 153, 1, 'Sophie Laurent', NULL, 'termine'),
    (62, 9, '2024-07-02 13:00:00', '2024-07-02 14:20:00', 153, 153, 0, 'AUTO', 'ICT-02', 'termine'),
    (62, 10, '2024-07-02 14:30:00', '2024-07-02 15:30:00', 153, 153, 0, 'AUTO', 'PROG-02', 'termine'),
    (62, 11, '2024-07-03 08:00:00', NULL, 120, 118, 2, 'AUTO', 'TEST-FUNC-02', 'en_cours');

-- Insertion des défauts qualité détectés
INSERT INTO defauts_qualite (suivi_production_id, type_defaut, description, quantite, gravite, action_corrective, date_detection) VALUES
    -- Défauts OF-2024-0401
    (4, 'Soudure insuffisante', 'Manque de pâte à souder sur composants U2', 2, 'majeure', 'Ajustement paramètres sérigraphie', '2024-04-01 13:30:00'),
    (6, 'Court-circuit', 'Pont de soudure entre pins', 1, 'critique', 'Retouche manuelle effectuée', '2024-04-01 16:45:00'),
    (8, 'Composant mal orienté', 'LED montée à l''envers', 1, 'moyenne', 'Remplacement composant', '2024-04-02 09:45:00'),
    (11, 'Test fonctionnel échoué', 'Communication I2C défaillante', 1, 'majeure', 'Remplacement circuit U4', '2024-04-02 14:30:00'),

    -- Défauts OF-2024-0505
    (18, 'Soudure froide', 'Soudures froides détectées sur connecteurs', 4, 'majeure', 'Augmentation température four', '2024-05-08 14:45:00'),
    (22, 'Pont de soudure', 'Ponts détectés sur composants CMS', 2, 'critique', 'Retouche manuelle', '2024-05-09 11:30:00'),
    (24, 'Composant manquant', 'Condensateur C12 absent', 2, 'critique', 'Ajout composant et re-test', '2024-05-09 12:00:00'),
    (27, 'Test fonctionnel échoué', 'Sortie analogique hors tolérance', 2, 'majeure', 'Calibration et re-test', '2024-05-09 16:45:00'),

    -- Défauts OF-2024-0606
    (32, 'Défaut AOI', 'Composant légèrement décalé', 1, 'mineure', 'Accepté après inspection visuelle', '2024-06-10 14:30:00'),
    (36, 'Soudure insuffisante', 'Manque de soudure sur J2', 1, 'majeure', 'Retouche manuelle', '2024-06-11 11:30:00'),
    (39, 'Test fonctionnel échoué', 'Problème mémoire Flash', 1, 'critique', 'Remplacement U3', '2024-06-12 09:15:00'),

    -- Défauts OF-2024-0621
    (44, 'Soudure froide', 'Soudures froides sur bornier', 2, 'majeure', 'Retouche manuelle', '2024-06-29 14:00:00'),
    (46, 'Pont de soudure', 'Court-circuit détecté', 2, 'critique', 'Nettoyage et retouche', '2024-07-01 09:00:00'),
    (48, 'Composant endommagé', 'Condensateur fissuré', 2, 'majeure', 'Remplacement composant', '2024-07-01 12:00:00'),
    (50, 'Test fonctionnel échoué', 'Lecture ADC incorrecte', 2, 'majeure', 'Remplacement U2', '2024-07-01 16:30:00'),
    (53, 'Défaut cosmétique', 'Traces de flux visibles', 8, 'mineure', 'Nettoyage supplémentaire', '2024-07-02 11:00:00'),

    -- Défauts OF-2024-0622
    (58, 'Défaut AOI', 'Composant mal positionné', 1, 'moyenne', 'Retouche manuelle', '2024-07-01 14:40:00'),
    (62, 'Soudure insuffisante', 'Manque de soudure sur pins MCU', 1, 'critique', 'Retouche et re-test', '2024-07-02 11:45:00'),
    (67, 'Test fonctionnel échoué', 'Problème horloge RTC', 2, 'majeure', 'Remplacement U6 et re-test', '2024-07-03 09:30:00');

-- ============================================================================
-- MESSAGES DE CONFIRMATION ET STATISTIQUES
-- ============================================================================

SELECT 'Base de données Production Électronique initialisée avec succès !' as message;
SELECT 'Statistiques de la base de données :' as info;
SELECT COUNT(*) as nombre_cartes FROM cartes_electroniques;
SELECT COUNT(*) as nombre_composants FROM composants;
SELECT COUNT(*) as nombre_lignes_nomenclature FROM nomenclature;
SELECT COUNT(*) as nombre_operations FROM operations_fabrication;
SELECT COUNT(*) as nombre_gammes FROM gammes_fabrication;
SELECT COUNT(*) as nombre_ordres_fabrication FROM ordres_fabrication;
SELECT COUNT(*) as nombre_suivis_production FROM suivi_production;
SELECT COUNT(*) as nombre_defauts_qualite FROM defauts_qualite;

-- Statistiques par carte
SELECT
    ce.reference,
    ce.nom,
    COUNT(DISTINCT n.composant_id) as nb_composants_differents,
    SUM(n.quantite) as nb_composants_total
FROM cartes_electroniques ce
LEFT JOIN nomenclature n ON ce.id = n.carte_id
GROUP BY ce.id, ce.reference, ce.nom
ORDER BY ce.reference;

-- Statistiques de production par carte (3 derniers mois)
SELECT
    ce.reference,
    ce.nom,
    COUNT(of.id) as nb_ordres,
    SUM(of.quantite_prevue) as quantite_prevue_totale,
    SUM(of.quantite_produite) as quantite_produite_totale,
    SUM(of.quantite_conforme) as quantite_conforme_totale,
    SUM(of.quantite_rebut) as quantite_rebut_totale,
    ROUND(100.0 * SUM(of.quantite_conforme) / NULLIF(SUM(of.quantite_produite), 0), 2) as taux_conformite_pct
FROM cartes_electroniques ce
LEFT JOIN ordres_fabrication of ON ce.id = of.carte_id
WHERE of.date_lancement >= '2024-04-01'
GROUP BY ce.id, ce.reference, ce.nom
ORDER BY ce.reference;
