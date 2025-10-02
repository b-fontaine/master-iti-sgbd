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
