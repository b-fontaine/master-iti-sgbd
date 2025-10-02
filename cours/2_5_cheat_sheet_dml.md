# Cheat Sheet SQL - DML (Data Manipulation Language)

## 📋 Table des matières

1. [INSERT - Insertion de données](#-1-insert---insertion-de-données)
2. [UPDATE - Mise à jour de données](#-2-update---mise-à-jour-de-données)
3. [DELETE - Suppression de données](#-3-delete---suppression-de-données)
4. [UPSERT - INSERT ... ON CONFLICT](#-4-upsert---insert--on-conflict)
5. [Transactions et sécurité](#-5-transactions-et-sécurité)
6. [Bonnes pratiques](#-6-bonnes-pratiques)
7. [Exemples pratiques sur exemple_crm](#-7-exemples-pratiques-sur-exemple_crm)
8. [Pièges courants à éviter](#-8-pièges-courants-à-éviter)

---

## 📝 1. INSERT - Insertion de données

### Syntaxe complète

```sql
INSERT INTO table_name (colonne1, colonne2, ...)
VALUES (valeur1, valeur2, ...);
```

### INSERT simple - Une ligne

```sql
-- Insérer un nouveau client
INSERT INTO clients (nom, email, telephone, ville, type_client)
VALUES ('Nouvelle Entreprise SA', 'contact@nouvelle-entreprise.fr', '01 23 45 67 89', 'Paris', 'prospect');

-- Avec colonnes auto-incrémentées (SERIAL)
-- L'id sera généré automatiquement
INSERT INTO produits (nom, description, prix_unitaire, stock, categorie)
VALUES ('Nouveau Produit', 'Description du produit', 299.99, 50, 'Informatique');

-- Avec valeurs NULL explicites
INSERT INTO contacts (client_id, prenom, nom, email, telephone, poste)
VALUES (1, 'Marie', 'Dupont', 'marie.dupont@example.com', NULL, 'Directrice');
```

### INSERT multiple - Plusieurs lignes

```sql
-- Insérer plusieurs produits en une seule requête
INSERT INTO produits (nom, description, prix_unitaire, stock, categorie)
VALUES 
    ('Clavier mécanique', 'Clavier gaming RGB', 89.99, 30, 'Informatique'),
    ('Souris sans fil', 'Souris ergonomique', 45.50, 50, 'Informatique'),
    ('Webcam HD', 'Webcam 1080p', 79.99, 20, 'Informatique');

-- Insérer plusieurs contacts
INSERT INTO contacts (client_id, prenom, nom, email, poste)
VALUES 
    (5, 'Jean', 'Martin', 'jean.martin@example.com', 'Responsable IT'),
    (5, 'Sophie', 'Bernard', 'sophie.bernard@example.com', 'Chef de projet'),
    (5, 'Luc', 'Petit', 'luc.petit@example.com', 'Développeur');
```

### INSERT avec sélection de colonnes

```sql
-- Colonnes avec valeurs par défaut peuvent être omises
INSERT INTO clients (nom, email, type_client)
VALUES ('Quick Start SARL', 'contact@quickstart.fr', 'preprospect');
-- Les colonnes telephone, adresse, date_creation, date_modification 
-- prendront leurs valeurs par défaut (NULL ou DEFAULT)

-- Utiliser DEFAULT explicitement
INSERT INTO produits (nom, prix_unitaire, stock, categorie, date_creation)
VALUES ('Produit Test', 99.99, 10, 'Services', DEFAULT);
```

### INSERT ... SELECT - Copier depuis une autre table

```sql
-- Copier des produits d'une catégorie vers une table d'archive
INSERT INTO produits_archive (nom, categorie, prix_unitaire, date_archivage)
SELECT nom, categorie, prix_unitaire, CURRENT_TIMESTAMP
FROM produits
WHERE categorie = 'Obsolete';

-- Créer des commandes de test basées sur des clients existants
INSERT INTO commandes (client_id, date_commande, statut, montant_total)
SELECT id, CURRENT_DATE, 'en_cours', 0
FROM clients
WHERE type_client = 'client'
LIMIT 5;
```

### INSERT ... RETURNING (PostgreSQL)

```sql
-- Récupérer l'ID généré après insertion
INSERT INTO clients (nom, email, type_client)
VALUES ('Tech Innovations', 'contact@techinno.fr', 'prospect')
RETURNING id, nom, date_creation;

-- Récupérer plusieurs colonnes
INSERT INTO produits (nom, prix_unitaire, stock, categorie)
VALUES ('Nouveau Gadget', 149.99, 100, 'Informatique')
RETURNING id, nom, prix_unitaire, date_creation;

-- Utile pour insérer et récupérer immédiatement
INSERT INTO commandes (client_id, date_commande, statut, montant_total)
VALUES (10, CURRENT_TIMESTAMP, 'en_cours', 0)
RETURNING id AS commande_id, date_commande;
```

### Gestion des clés auto-incrémentées

```sql
-- SERIAL génère automatiquement l'ID
-- Ne pas spécifier la colonne id dans l'INSERT
INSERT INTO clients (nom, email, type_client)
VALUES ('Auto ID Client', 'auto@example.com', 'client');

-- Pour forcer une valeur spécifique (déconseillé)
INSERT INTO clients (id, nom, email, type_client)
VALUES (9999, 'ID Forcé', 'force@example.com', 'client');

-- Réinitialiser la séquence après insertion manuelle
SELECT setval('clients_id_seq', (SELECT MAX(id) FROM clients));
```

### Exemples concrets sur exemple_crm

```sql
-- Ajouter un nouveau client complet
INSERT INTO clients (nom, email, telephone, adresse, type_client)
VALUES (
    'Digital Solutions SARL',
    'contact@digitalsolutions.fr',
    '01 42 68 90 12',
    '15 rue de la Paix, 75002 Paris',
    'prospect'
)
RETURNING id, nom, date_creation;

-- Ajouter un contact pour ce client
INSERT INTO contacts (client_id, prenom, nom, email, telephone, poste)
VALUES (
    (SELECT id FROM clients WHERE email = 'contact@digitalsolutions.fr'),
    'Pierre',
    'Durand',
    'pierre.durand@digitalsolutions.fr',
    '06 12 34 56 78',
    'Directeur Technique'
);

-- Ajouter un meeting pour ce contact
INSERT INTO meetings (
    contact_id, 
    titre, 
    description, 
    date_meeting, 
    duree_minutes, 
    statut
)
VALUES (
    (SELECT id FROM contacts WHERE email = 'pierre.durand@digitalsolutions.fr'),
    'Présentation produits',
    'Démonstration de nos solutions informatiques',
    '2024-12-15 14:00:00',
    60,
    'planifie'
);
```

> 💡 **Astuce** : Utilisez RETURNING pour récupérer immédiatement les valeurs générées (ID, timestamps) sans faire de SELECT supplémentaire.

---

## ✏️ 2. UPDATE - Mise à jour de données

### Syntaxe complète

```sql
UPDATE table_name
SET colonne1 = valeur1, colonne2 = valeur2, ...
WHERE condition;
```

> ⚠️ **ATTENTION** : Sans WHERE, TOUTES les lignes seront modifiées !

### UPDATE simple - Une colonne

```sql
-- Mettre à jour le statut d'une commande
UPDATE commandes
SET statut = 'livree'
WHERE id = 15;

-- Mettre à jour l'email d'un client
UPDATE clients
SET email = 'nouveau.email@example.com'
WHERE id = 5;

-- Mettre à jour le stock d'un produit
UPDATE produits
SET stock = 75
WHERE nom = 'Ordinateur portable Dell';
```

### UPDATE multiple - Plusieurs colonnes

```sql
-- Mettre à jour plusieurs informations d'un client
UPDATE clients
SET 
    telephone = '01 23 45 67 89',
    adresse = '10 Avenue des Champs-Élysées, 75008 Paris',
    date_modification = CURRENT_TIMESTAMP
WHERE id = 3;

-- Mettre à jour produit avec nouveau prix et stock
UPDATE produits
SET 
    prix_unitaire = 899.99,
    stock = stock + 50,
    date_modification = CURRENT_TIMESTAMP
WHERE id = 42;
```

### UPDATE avec calculs et expressions

```sql
-- Augmenter tous les prix de 10%
UPDATE produits
SET prix_unitaire = prix_unitaire * 1.10
WHERE categorie = 'Informatique';

-- Décrémenter le stock après une vente
UPDATE produits
SET stock = stock - 5
WHERE id = 10;

-- Mettre à jour le montant total d'une commande
UPDATE commandes
SET montant_total = (
    SELECT SUM(quantite * prix_unitaire)
    FROM commandes_produits
    WHERE commande_id = commandes.id
)
WHERE id = 20;

-- Appliquer une remise conditionnelle
UPDATE produits
SET prix_unitaire = CASE
    WHEN stock > 100 THEN prix_unitaire * 0.90  -- -10% si stock élevé
    WHEN stock < 10 THEN prix_unitaire * 1.05   -- +5% si stock faible
    ELSE prix_unitaire
END;
```

### UPDATE avec sous-requêtes

```sql
-- Passer les prospects en clients s'ils ont commandé
UPDATE clients
SET type_client = 'client'
WHERE type_client = 'prospect'
  AND id IN (SELECT DISTINCT client_id FROM commandes);

-- Mettre à jour le prix d'un produit basé sur la moyenne de sa catégorie
UPDATE produits
SET prix_unitaire = (
    SELECT AVG(prix_unitaire)
    FROM produits p2
    WHERE p2.categorie = produits.categorie
)
WHERE nom = 'Produit Spécial';
```

### UPDATE avec jointures (PostgreSQL)

```sql
-- Mettre à jour les commandes avec le nom du client
UPDATE commandes cmd
SET statut = 'prioritaire'
FROM clients cl
WHERE cmd.client_id = cl.id
  AND cl.type_client = 'client'
  AND cmd.montant_total > 5000;

-- Mettre à jour les produits selon leurs ventes
UPDATE produits p
SET stock = stock - ventes.total_vendu
FROM (
    SELECT produit_id, SUM(quantite) as total_vendu
    FROM commandes_produits
    WHERE commande_id IN (SELECT id FROM commandes WHERE statut = 'validee')
    GROUP BY produit_id
) ventes
WHERE p.id = ventes.produit_id;
```

### UPDATE ... RETURNING

```sql
-- Mettre à jour et récupérer les valeurs modifiées
UPDATE clients
SET type_client = 'client', date_modification = CURRENT_TIMESTAMP
WHERE id = 8
RETURNING id, nom, type_client, date_modification;

-- Mettre à jour plusieurs lignes et voir les changements
UPDATE produits
SET prix_unitaire = prix_unitaire * 1.05
WHERE categorie = 'Mobilier'
RETURNING id, nom, prix_unitaire AS nouveau_prix;
```

### Exemples de cas d'usage métier

```sql
-- Valider une commande et mettre à jour le stock
BEGIN;

UPDATE commandes
SET statut = 'validee', date_modification = CURRENT_TIMESTAMP
WHERE id = 25;

UPDATE produits p
SET stock = stock - cp.quantite
FROM commandes_produits cp
WHERE p.id = cp.produit_id
  AND cp.commande_id = 25;

COMMIT;

-- Marquer les factures en retard
UPDATE factures
SET statut_paiement = 'en_retard'
WHERE statut_paiement = 'en_attente'
  AND date_echeance < CURRENT_DATE;

-- Promouvoir les prospects actifs en clients
UPDATE clients
SET type_client = 'client', date_modification = CURRENT_TIMESTAMP
WHERE type_client = 'prospect'
  AND id IN (
      SELECT DISTINCT client_id 
      FROM commandes 
      WHERE statut IN ('validee', 'livree')
  );
```

> 💡 **Astuce** : Testez toujours votre UPDATE avec un SELECT avant de l'exécuter :
> ```sql
> -- 1. Tester avec SELECT
> SELECT * FROM clients WHERE type_client = 'prospect';
> 
> -- 2. Si OK, remplacer SELECT par UPDATE
> UPDATE clients SET type_client = 'client' WHERE type_client = 'prospect';
> ```

---

## 🗑️ 3. DELETE - Suppression de données

### Syntaxe complète

```sql
DELETE FROM table_name
WHERE condition;
```

> ⚠️ **DANGER** : Sans WHERE, TOUTES les lignes seront supprimées !

### DELETE avec WHERE

```sql
-- Supprimer un client spécifique
DELETE FROM clients WHERE id = 99;

-- Supprimer les produits en rupture de stock
DELETE FROM produits WHERE stock = 0;

-- Supprimer les commandes annulées anciennes
DELETE FROM commandes 
WHERE statut = 'annulee' 
  AND date_commande < '2023-01-01';
```

### DELETE avec sous-requêtes

```sql
-- Supprimer les contacts sans téléphone ni email
DELETE FROM contacts
WHERE telephone IS NULL AND email IS NULL;

-- Supprimer les clients sans commandes (prospects inactifs)
DELETE FROM clients
WHERE type_client = 'preprospect'
  AND id NOT IN (SELECT DISTINCT client_id FROM commandes WHERE client_id IS NOT NULL);

-- Supprimer les produits jamais commandés
DELETE FROM produits
WHERE id NOT IN (
    SELECT DISTINCT produit_id 
    FROM commandes_produits 
    WHERE produit_id IS NOT NULL
);
```

### DELETE avec jointures (PostgreSQL)

```sql
-- Supprimer les meetings des clients inactifs
DELETE FROM meetings m
USING contacts co, clients cl
WHERE m.contact_id = co.id
  AND co.client_id = cl.id
  AND cl.type_client = 'preprospect'
  AND cl.date_creation < CURRENT_DATE - INTERVAL '1 year';
```

### DELETE ... RETURNING

```sql
-- Supprimer et voir ce qui a été supprimé
DELETE FROM produits
WHERE stock = 0 AND categorie = 'Obsolete'
RETURNING id, nom, categorie;

-- Archiver avant suppression
INSERT INTO clients_archives
SELECT * FROM clients WHERE type_client = 'preprospect' AND date_creation < '2023-01-01'
RETURNING *;

DELETE FROM clients
WHERE type_client = 'preprospect' AND date_creation < '2023-01-01'
RETURNING id, nom, date_creation;
```

### TRUNCATE vs DELETE

| Aspect | DELETE | TRUNCATE |
|--------|--------|----------|
| **Syntaxe** | `DELETE FROM table WHERE ...` | `TRUNCATE TABLE table` |
| **WHERE** | ✅ Peut filtrer | ❌ Supprime tout |
| **Vitesse** | 🐌 Lent (ligne par ligne) | ⚡ Très rapide |
| **Rollback** | ✅ Peut annuler | ✅ Peut annuler (dans transaction) |
| **Triggers** | ✅ Déclenche les triggers | ❌ Ne déclenche pas |
| **Auto-increment** | ❌ Ne réinitialise pas | ✅ Réinitialise |
| **Espace disque** | ❌ Libère progressivement | ✅ Libère immédiatement |

```sql
-- DELETE : suppression sélective
DELETE FROM commandes WHERE statut = 'annulee';

-- TRUNCATE : vider complètement une table
TRUNCATE TABLE commandes_test;

-- TRUNCATE avec CASCADE (supprime aussi les tables liées)
TRUNCATE TABLE clients CASCADE;  -- ⚠️ TRÈS DANGEREUX !

-- TRUNCATE avec RESTART IDENTITY (réinitialise les séquences)
TRUNCATE TABLE produits_test RESTART IDENTITY;
```

> ⚠️ **ATTENTION** : TRUNCATE est BEAUCOUP plus rapide mais supprime TOUT sans condition !

### Gestion des contraintes de clés étrangères

```sql
-- Tentative de suppression avec FK (échoue si données liées)
DELETE FROM clients WHERE id = 5;
-- ERROR: update or delete on table "clients" violates foreign key constraint

-- Option 1 : Supprimer d'abord les données liées
DELETE FROM commandes WHERE client_id = 5;
DELETE FROM contacts WHERE client_id = 5;
DELETE FROM clients WHERE id = 5;

-- Option 2 : Utiliser CASCADE (si défini dans la contrainte FK)
-- La contrainte doit avoir été créée avec ON DELETE CASCADE
DELETE FROM clients WHERE id = 5;  -- Supprime aussi commandes et contacts

-- Option 3 : Désactiver temporairement les contraintes (DANGEREUX !)
SET CONSTRAINTS ALL DEFERRED;
DELETE FROM clients WHERE id = 5;
-- Réactiver
SET CONSTRAINTS ALL IMMEDIATE;
```

### Exemples de suppressions sécurisées

```sql
-- Supprimer un client et toutes ses données (transaction)
BEGIN;

-- 1. Sauvegarder dans une table d'archive
INSERT INTO clients_supprimes SELECT * FROM clients WHERE id = 10;

-- 2. Supprimer les données liées
DELETE FROM meetings WHERE contact_id IN (SELECT id FROM contacts WHERE client_id = 10);
DELETE FROM contacts WHERE client_id = 10;
DELETE FROM factures WHERE commande_id IN (SELECT id FROM commandes WHERE client_id = 10);
DELETE FROM commandes_produits WHERE commande_id IN (SELECT id FROM commandes WHERE client_id = 10);
DELETE FROM commandes WHERE client_id = 10;

-- 3. Supprimer le client
DELETE FROM clients WHERE id = 10;

COMMIT;

-- Nettoyage des données obsolètes (avec limite de sécurité)
DELETE FROM commandes
WHERE id IN (
    SELECT id FROM commandes
    WHERE statut = 'annulee' 
      AND date_commande < CURRENT_DATE - INTERVAL '2 years'
    LIMIT 100  -- Limiter le nombre de suppressions
);
```

> 💡 **Astuce** : Toujours faire un SELECT avant un DELETE pour vérifier ce qui sera supprimé :
> ```sql
> -- 1. Vérifier
> SELECT * FROM produits WHERE stock = 0;
> 
> -- 2. Si OK, supprimer
> DELETE FROM produits WHERE stock = 0;
> ```

---

## 🔄 4. UPSERT - INSERT ... ON CONFLICT

### Syntaxe ON CONFLICT DO NOTHING

```sql
-- Insérer seulement si l'email n'existe pas déjà
INSERT INTO clients (nom, email, type_client)
VALUES ('Nouvelle Entreprise', 'contact@example.com', 'prospect')
ON CONFLICT (email) DO NOTHING;

-- Insérer plusieurs lignes, ignorer les doublons
INSERT INTO produits (nom, categorie, prix_unitaire, stock)
VALUES 
    ('Produit A', 'Informatique', 99.99, 10),
    ('Produit B', 'Mobilier', 199.99, 5),
    ('Produit C', 'Informatique', 149.99, 20)
ON CONFLICT (nom) DO NOTHING;
```

### Syntaxe ON CONFLICT DO UPDATE

```sql
-- Mettre à jour si existe, insérer sinon
INSERT INTO produits (nom, categorie, prix_unitaire, stock)
VALUES ('Clavier Gaming', 'Informatique', 89.99, 50)
ON CONFLICT (nom) 
DO UPDATE SET 
    prix_unitaire = EXCLUDED.prix_unitaire,
    stock = produits.stock + EXCLUDED.stock,
    date_modification = CURRENT_TIMESTAMP;

-- EXCLUDED fait référence aux valeurs de l'INSERT
```

### Cas d'usage : éviter les doublons

```sql
-- Synchroniser des produits depuis une source externe
INSERT INTO produits (nom, categorie, prix_unitaire, stock, date_creation)
VALUES 
    ('Souris Logitech', 'Informatique', 45.99, 30, CURRENT_TIMESTAMP),
    ('Clavier Corsair', 'Informatique', 129.99, 15, CURRENT_TIMESTAMP)
ON CONFLICT (nom)
DO UPDATE SET
    prix_unitaire = EXCLUDED.prix_unitaire,
    stock = EXCLUDED.stock,
    date_modification = CURRENT_TIMESTAMP;

-- Importer des clients sans créer de doublons
INSERT INTO clients (nom, email, type_client)
SELECT nom, email, 'prospect'
FROM clients_import
ON CONFLICT (email) DO NOTHING;
```

### Exemples avec contraintes UNIQUE

```sql
-- Table avec contrainte UNIQUE sur email
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(200),
    email VARCHAR(255) UNIQUE NOT NULL,
    type_client VARCHAR(20)
);

-- UPSERT basé sur l'email
INSERT INTO clients (nom, email, type_client)
VALUES ('Tech Corp', 'contact@techcorp.fr', 'client')
ON CONFLICT (email)
DO UPDATE SET
    nom = EXCLUDED.nom,
    type_client = EXCLUDED.type_client,
    date_modification = CURRENT_TIMESTAMP
RETURNING id, nom, email;

-- UPSERT avec condition
INSERT INTO produits (nom, prix_unitaire, stock, categorie)
VALUES ('Produit Premium', 999.99, 10, 'Informatique')
ON CONFLICT (nom)
DO UPDATE SET
    prix_unitaire = EXCLUDED.prix_unitaire,
    stock = produits.stock + EXCLUDED.stock
WHERE produits.categorie = EXCLUDED.categorie;  -- Mise à jour conditionnelle
```

> 💡 **Astuce** : ON CONFLICT nécessite une contrainte UNIQUE ou PRIMARY KEY sur la colonne spécifiée.

---

## 🔒 5. Transactions et sécurité

### BEGIN, COMMIT, ROLLBACK

```sql
-- Transaction simple
BEGIN;
    UPDATE produits SET stock = stock - 5 WHERE id = 10;
    INSERT INTO commandes (client_id, montant_total) VALUES (5, 499.99);
COMMIT;

-- Transaction avec ROLLBACK en cas d'erreur
BEGIN;
    UPDATE clients SET type_client = 'client' WHERE id = 15;
    -- Oups, erreur détectée !
ROLLBACK;  -- Annule tous les changements
```

### Importance des transactions

```sql
-- ❌ MAUVAIS : Sans transaction
UPDATE produits SET stock = stock - 10 WHERE id = 5;
-- Si erreur ici, le stock est déjà modifié !
INSERT INTO commandes_produits (commande_id, produit_id, quantite) 
VALUES (100, 5, 10);

-- ✅ BON : Avec transaction
BEGIN;
    UPDATE produits SET stock = stock - 10 WHERE id = 5;
    INSERT INTO commandes_produits (commande_id, produit_id, quantite) 
    VALUES (100, 5, 10);
COMMIT;  -- Les deux opérations réussissent ou échouent ensemble
```

### SAVEPOINT pour transactions complexes

```sql
BEGIN;
    -- Opération 1
    INSERT INTO clients (nom, email, type_client)
    VALUES ('Client A', 'clienta@example.com', 'prospect');
    
    SAVEPOINT after_client;
    
    -- Opération 2
    INSERT INTO contacts (client_id, prenom, nom, email)
    VALUES (CURRVAL('clients_id_seq'), 'Jean', 'Dupont', 'jean@example.com');
    
    SAVEPOINT after_contact;
    
    -- Opération 3 (erreur possible)
    INSERT INTO meetings (contact_id, titre, date_meeting)
    VALUES (999, 'Meeting', '2024-12-01');  -- Erreur : contact_id invalide
    
    -- Revenir au savepoint précédent
    ROLLBACK TO SAVEPOINT after_contact;
    
    -- Continuer avec d'autres opérations
    INSERT INTO meetings (contact_id, titre, date_meeting)
    VALUES (CURRVAL('contacts_id_seq'), 'Meeting', '2024-12-01');
    
COMMIT;
```

### Exemples de transactions complexes

```sql
-- Créer une commande complète avec ses lignes
BEGIN;
    -- 1. Créer la commande
    INSERT INTO commandes (client_id, date_commande, statut, montant_total)
    VALUES (10, CURRENT_TIMESTAMP, 'en_cours', 0)
    RETURNING id INTO @commande_id;
    
    -- 2. Ajouter les lignes de commande
    INSERT INTO commandes_produits (commande_id, produit_id, quantite, prix_unitaire)
    VALUES 
        (@commande_id, 5, 2, 299.99),
        (@commande_id, 12, 1, 149.99),
        (@commande_id, 8, 3, 49.99);
    
    -- 3. Mettre à jour le montant total
    UPDATE commandes
    SET montant_total = (
        SELECT SUM(quantite * prix_unitaire)
        FROM commandes_produits
        WHERE commande_id = @commande_id
    )
    WHERE id = @commande_id;
    
    -- 4. Décrémenter les stocks
    UPDATE produits p
    SET stock = stock - cp.quantite
    FROM commandes_produits cp
    WHERE p.id = cp.produit_id
      AND cp.commande_id = @commande_id;
    
COMMIT;

-- Transférer un contact d'un client à un autre
BEGIN;
    -- Vérifier que les deux clients existent
    SELECT id FROM clients WHERE id IN (5, 10);
    
    -- Transférer le contact
    UPDATE contacts
    SET client_id = 10, date_modification = CURRENT_TIMESTAMP
    WHERE id = 25 AND client_id = 5;
    
    -- Logger le transfert
    INSERT INTO audit_log (table_name, action, details)
    VALUES ('contacts', 'transfer', 'Contact 25: client 5 -> 10');
    
COMMIT;
```

> ⚠️ **Important** : Utilisez TOUJOURS des transactions pour les opérations qui modifient plusieurs tables liées.

---

## ✅ 6. Bonnes pratiques

### 1. Toujours utiliser WHERE avec UPDATE et DELETE

```sql
-- ❌ DANGER : Modifie TOUTES les lignes
UPDATE clients SET type_client = 'client';

-- ✅ BON : Modifie seulement les lignes ciblées
UPDATE clients SET type_client = 'client' WHERE id = 5;

-- ❌ CATASTROPHE : Supprime TOUT
DELETE FROM produits;

-- ✅ BON : Supprime seulement ce qui est nécessaire
DELETE FROM produits WHERE stock = 0 AND categorie = 'Obsolete';
```

### 2. Tester avec SELECT avant UPDATE/DELETE

```sql
-- Étape 1 : SELECT pour vérifier
SELECT * FROM clients WHERE type_client = 'preprospect' AND date_creation < '2023-01-01';
-- Résultat : 15 lignes

-- Étape 2 : Si OK, UPDATE
UPDATE clients 
SET type_client = 'prospect' 
WHERE type_client = 'preprospect' AND date_creation < '2023-01-01';
-- UPDATE 15

-- Étape 3 : Vérifier le résultat
SELECT * FROM clients WHERE type_client = 'prospect' AND date_modification > CURRENT_DATE;
```

### 3. Utiliser BEGIN/ROLLBACK pour tester

```sql
-- Tester sans risque
BEGIN;
    UPDATE produits SET prix_unitaire = prix_unitaire * 1.20;
    SELECT * FROM produits LIMIT 10;  -- Vérifier les changements
ROLLBACK;  -- Annuler si pas satisfait

-- Si satisfait, refaire avec COMMIT
BEGIN;
    UPDATE produits SET prix_unitaire = prix_unitaire * 1.20;
COMMIT;
```

### 4. Sauvegarder avant modifications massives

```sql
-- Créer une table de sauvegarde
CREATE TABLE clients_backup AS SELECT * FROM clients;

-- Faire les modifications
UPDATE clients SET type_client = 'client' WHERE ...;

-- Si problème, restaurer
TRUNCATE clients;
INSERT INTO clients SELECT * FROM clients_backup;

-- Si OK, supprimer la sauvegarde
DROP TABLE clients_backup;
```

### 5. Vérifier les contraintes FK

```sql
-- Vérifier les dépendances avant suppression
SELECT 
    'commandes' as table_name, COUNT(*) as count
FROM commandes WHERE client_id = 5
UNION ALL
SELECT 'contacts', COUNT(*) FROM contacts WHERE client_id = 5;

-- Si des dépendances existent, les gérer d'abord
BEGIN;
    DELETE FROM commandes WHERE client_id = 5;
    DELETE FROM contacts WHERE client_id = 5;
    DELETE FROM clients WHERE id = 5;
COMMIT;
```

### 6. Utiliser RETURNING

```sql
-- Confirmer les modifications
UPDATE clients
SET type_client = 'client', date_modification = CURRENT_TIMESTAMP
WHERE type_client = 'prospect' AND id IN (5, 10, 15)
RETURNING id, nom, type_client;

-- Récupérer les IDs générés
INSERT INTO produits (nom, prix_unitaire, stock, categorie)
VALUES ('Nouveau Produit', 99.99, 50, 'Informatique')
RETURNING id, nom, date_creation;
```

### 7. Limiter les modifications en production

```sql
-- ❌ Risqué : Modifier potentiellement des milliers de lignes
UPDATE produits SET prix_unitaire = prix_unitaire * 1.10;

-- ✅ Mieux : Limiter avec une sous-requête
UPDATE produits
SET prix_unitaire = prix_unitaire * 1.10
WHERE id IN (
    SELECT id FROM produits 
    WHERE categorie = 'Informatique'
    LIMIT 100
);

-- Faire en plusieurs fois si nécessaire
```

### 8. Logger les modifications importantes

```sql
-- Créer une table d'audit
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(50),
    action VARCHAR(20),
    user_name VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

-- Logger avant modification
BEGIN;
    INSERT INTO audit_log (table_name, action, user_name, details)
    VALUES ('clients', 'UPDATE', CURRENT_USER, 'Promotion prospects -> clients');
    
    UPDATE clients SET type_client = 'client' WHERE type_client = 'prospect';
COMMIT;
```

### 9. Utiliser des transactions pour les opérations critiques

```sql
-- ✅ BON : Transaction atomique
BEGIN;
    -- Créer facture
    INSERT INTO factures (commande_id, numero_facture, montant_ht, montant_ttc)
    VALUES (50, 'FAC-2024-0100', 1000, 1200);
    
    -- Mettre à jour statut commande
    UPDATE commandes SET statut = 'facturee' WHERE id = 50;
    
    -- Enregistrer dans comptabilité
    INSERT INTO comptabilite (type, montant, reference)
    VALUES ('vente', 1200, 'FAC-2024-0100');
COMMIT;
```

### 10. Documenter les modifications complexes

```sql
-- Modification massive : augmentation des prix 2024
-- Date : 2024-01-01
-- Auteur : Admin
-- Raison : Inflation + nouveaux coûts fournisseurs

BEGIN;
    -- Sauvegarder les anciens prix
    CREATE TEMP TABLE old_prices AS 
    SELECT id, nom, prix_unitaire FROM produits;
    
    -- Appliquer les augmentations
    UPDATE produits
    SET prix_unitaire = CASE
        WHEN categorie = 'Informatique' THEN prix_unitaire * 1.08  -- +8%
        WHEN categorie = 'Mobilier' THEN prix_unitaire * 1.05      -- +5%
        ELSE prix_unitaire * 1.03                                   -- +3%
    END,
    date_modification = CURRENT_TIMESTAMP;
    
    -- Logger les changements
    INSERT INTO audit_log (table_name, action, details)
    SELECT 
        'produits',
        'price_update',
        'ID: ' || p.id || ', Old: ' || op.prix_unitaire || ', New: ' || p.prix_unitaire
    FROM produits p
    JOIN old_prices op ON p.id = op.id
    WHERE p.prix_unitaire != op.prix_unitaire;
    
COMMIT;
```

---

## 💼 7. Exemples pratiques sur exemple_crm

### Ajouter un nouveau client complet

```sql
BEGIN;
    -- 1. Créer le client
    INSERT INTO clients (nom, email, telephone, adresse, type_client)
    VALUES (
        'Startup Innovante SAS',
        'contact@startup-innovante.fr',
        '01 23 45 67 89',
        '42 rue du Faubourg Saint-Antoine, 75012 Paris',
        'prospect'
    )
    RETURNING id AS client_id;
    -- Supposons que l'ID retourné est 21
    
    -- 2. Ajouter des contacts
    INSERT INTO contacts (client_id, prenom, nom, email, telephone, poste)
    VALUES 
        (21, 'Alice', 'Dubois', 'alice.dubois@startup-innovante.fr', '06 11 22 33 44', 'CEO'),
        (21, 'Bob', 'Martin', 'bob.martin@startup-innovante.fr', '06 55 66 77 88', 'CTO');
    
    -- 3. Planifier un premier meeting
    INSERT INTO meetings (contact_id, titre, description, date_meeting, duree_minutes, statut)
    VALUES (
        (SELECT id FROM contacts WHERE email = 'alice.dubois@startup-innovante.fr'),
        'Rendez-vous découverte',
        'Présentation de nos besoins et de vos solutions',
        '2024-12-20 10:00:00',
        90,
        'planifie'
    );
COMMIT;
```

### Ajouter plusieurs produits en une fois

```sql
INSERT INTO produits (nom, description, prix_unitaire, stock, categorie)
VALUES 
    ('MacBook Pro 16"', 'Ordinateur portable haute performance', 2799.00, 15, 'Informatique'),
    ('Dell XPS 15', 'Laptop professionnel', 1899.00, 20, 'Informatique'),
    ('HP EliteBook', 'Ordinateur portable entreprise', 1499.00, 25, 'Informatique'),
    ('Écran 4K 32"', 'Moniteur professionnel', 599.00, 30, 'Informatique'),
    ('Station d\'accueil USB-C', 'Hub multiport', 149.00, 50, 'Informatique')
RETURNING id, nom, prix_unitaire;
```

### Mettre à jour le statut d'une commande

```sql
-- Passer une commande de "en_cours" à "validee"
BEGIN;
    -- 1. Mettre à jour le statut
    UPDATE commandes
    SET statut = 'validee', date_modification = CURRENT_TIMESTAMP
    WHERE id = 25 AND statut = 'en_cours'
    RETURNING id, client_id, statut, montant_total;
    
    -- 2. Créer la facture
    INSERT INTO factures (
        commande_id, 
        numero_facture, 
        date_facture, 
        date_echeance,
        montant_ht,
        montant_ttc,
        tva,
        statut_paiement
    )
    SELECT 
        id,
        'FAC-2024-' || LPAD(NEXTVAL('factures_seq')::TEXT, 4, '0'),
        CURRENT_DATE,
        CURRENT_DATE + INTERVAL '30 days',
        montant_total / 1.20,
        montant_total,
        20.00,
        'en_attente'
    FROM commandes
    WHERE id = 25;
    
    -- 3. Décrémenter les stocks
    UPDATE produits p
    SET stock = stock - cp.quantite
    FROM commandes_produits cp
    WHERE p.id = cp.produit_id
      AND cp.commande_id = 25
      AND p.stock >= cp.quantite;  -- Vérifier stock suffisant
    
COMMIT;
```

### Mettre à jour les prix avec augmentation

```sql
-- Augmentation de 10% pour une catégorie
UPDATE produits
SET 
    prix_unitaire = ROUND(prix_unitaire * 1.10, 2),
    date_modification = CURRENT_TIMESTAMP
WHERE categorie = 'Informatique'
RETURNING id, nom, prix_unitaire AS nouveau_prix;

-- Augmentation différenciée par stock
UPDATE produits
SET prix_unitaire = CASE
    WHEN stock < 10 THEN prix_unitaire * 1.15  -- +15% si stock faible
    WHEN stock > 100 THEN prix_unitaire * 0.95 -- -5% si surstock
    ELSE prix_unitaire * 1.05                   -- +5% sinon
END,
date_modification = CURRENT_TIMESTAMP
WHERE categorie = 'Mobilier';
```

### Supprimer les contacts sans téléphone

```sql
-- Vérifier d'abord
SELECT id, prenom, nom, email, client_id
FROM contacts
WHERE telephone IS NULL;

-- Si OK, supprimer
DELETE FROM contacts
WHERE telephone IS NULL
  AND date_creation < CURRENT_DATE - INTERVAL '6 months'  -- Seulement les anciens
RETURNING id, prenom, nom, email;
```

### Supprimer un client et ses données liées

```sql
BEGIN;
    -- Sauvegarder dans une table d'archive
    INSERT INTO clients_archives 
    SELECT *, CURRENT_TIMESTAMP as date_archivage 
    FROM clients WHERE id = 15;
    
    -- Supprimer dans l'ordre (du plus dépendant au moins dépendant)
    DELETE FROM meetings 
    WHERE contact_id IN (SELECT id FROM contacts WHERE client_id = 15);
    
    DELETE FROM contacts WHERE client_id = 15;
    
    DELETE FROM factures 
    WHERE commande_id IN (SELECT id FROM commandes WHERE client_id = 15);
    
    DELETE FROM commandes_produits 
    WHERE commande_id IN (SELECT id FROM commandes WHERE client_id = 15);
    
    DELETE FROM commandes WHERE client_id = 15;
    
    DELETE FROM clients WHERE id = 15;
    
COMMIT;
```

### Transaction : créer une commande complète

```sql
BEGIN;
    -- 1. Créer la commande
    WITH nouvelle_commande AS (
        INSERT INTO commandes (client_id, date_commande, statut, montant_total)
        VALUES (10, CURRENT_TIMESTAMP, 'en_cours', 0)
        RETURNING id
    )
    -- 2. Ajouter les produits
    INSERT INTO commandes_produits (commande_id, produit_id, quantite, prix_unitaire)
    SELECT 
        nc.id,
        p.id,
        CASE 
            WHEN p.id = 5 THEN 2
            WHEN p.id = 12 THEN 1
            WHEN p.id = 18 THEN 3
        END as quantite,
        p.prix_unitaire
    FROM nouvelle_commande nc
    CROSS JOIN produits p
    WHERE p.id IN (5, 12, 18);
    
    -- 3. Calculer et mettre à jour le montant total
    UPDATE commandes c
    SET montant_total = (
        SELECT SUM(cp.quantite * cp.prix_unitaire)
        FROM commandes_produits cp
        WHERE cp.commande_id = c.id
    )
    WHERE id = (SELECT id FROM nouvelle_commande);
    
    -- 4. Vérifier et décrémenter les stocks
    UPDATE produits p
    SET stock = stock - cp.quantite
    FROM commandes_produits cp
    WHERE p.id = cp.produit_id
      AND cp.commande_id = (SELECT id FROM nouvelle_commande)
      AND p.stock >= cp.quantite;
    
    -- Vérifier que tous les stocks étaient suffisants
    IF (SELECT COUNT(*) FROM produits WHERE stock < 0) > 0 THEN
        RAISE EXCEPTION 'Stock insuffisant pour certains produits';
    END IF;
    
COMMIT;
```

### UPSERT : mettre à jour ou créer un produit

```sql
-- Synchroniser un produit depuis un système externe
INSERT INTO produits (nom, description, prix_unitaire, stock, categorie)
VALUES (
    'iPhone 15 Pro',
    'Smartphone Apple dernière génération',
    1229.00,
    50,
    'Informatique'
)
ON CONFLICT (nom)
DO UPDATE SET
    description = EXCLUDED.description,
    prix_unitaire = EXCLUDED.prix_unitaire,
    stock = produits.stock + EXCLUDED.stock,  -- Ajouter au stock existant
    date_modification = CURRENT_TIMESTAMP
RETURNING id, nom, prix_unitaire, stock;
```

---

## ⚠️ 8. Pièges courants à éviter

### 1. UPDATE/DELETE sans WHERE

```sql
-- ❌ CATASTROPHE : Modifie TOUS les clients
UPDATE clients SET type_client = 'client';
-- Résultat : 1000 lignes modifiées au lieu de 1 !

-- ✅ CORRECT : Spécifier la condition
UPDATE clients SET type_client = 'client' WHERE id = 5;
```

**Solution** : TOUJOURS vérifier avec SELECT avant :
```sql
SELECT * FROM clients WHERE id = 5;  -- Vérifier
UPDATE clients SET type_client = 'client' WHERE id = 5;  -- Modifier
```

### 2. Oublier les transactions

```sql
-- ❌ MAUVAIS : Sans transaction
UPDATE produits SET stock = stock - 10 WHERE id = 5;
-- Si erreur ici, le stock est déjà modifié !
INSERT INTO commandes_produits VALUES (100, 5, 10);

-- ✅ BON : Avec transaction
BEGIN;
    UPDATE produits SET stock = stock - 10 WHERE id = 5;
    INSERT INTO commandes_produits VALUES (100, 5, 10);
COMMIT;
```

### 3. Ne pas vérifier les contraintes FK

```sql
-- ❌ Erreur : Suppression bloquée par FK
DELETE FROM clients WHERE id = 5;
-- ERROR: violates foreign key constraint

-- ✅ Vérifier d'abord les dépendances
SELECT 
    (SELECT COUNT(*) FROM commandes WHERE client_id = 5) as commandes,
    (SELECT COUNT(*) FROM contacts WHERE client_id = 5) as contacts;

-- Puis supprimer dans le bon ordre
BEGIN;
    DELETE FROM commandes WHERE client_id = 5;
    DELETE FROM contacts WHERE client_id = 5;
    DELETE FROM clients WHERE id = 5;
COMMIT;
```

### 4. DELETE au lieu de TRUNCATE

```sql
-- ❌ LENT : Pour vider une grande table
DELETE FROM logs_temp;  -- Peut prendre des heures !

-- ✅ RAPIDE : Utiliser TRUNCATE
TRUNCATE TABLE logs_temp;  -- Instantané
```

### 5. Ne pas utiliser RETURNING

```sql
-- ❌ Nécessite deux requêtes
INSERT INTO clients (nom, email, type_client)
VALUES ('Nouveau Client', 'new@example.com', 'prospect');
SELECT id FROM clients WHERE email = 'new@example.com';

-- ✅ Une seule requête avec RETURNING
INSERT INTO clients (nom, email, type_client)
VALUES ('Nouveau Client', 'new@example.com', 'prospect')
RETURNING id, nom, date_creation;
```

### 6. Modifications massives sans limite

```sql
-- ❌ RISQUÉ : Peut modifier des millions de lignes
UPDATE produits SET prix_unitaire = prix_unitaire * 1.10;

-- ✅ SÉCURISÉ : Limiter et faire en plusieurs fois
UPDATE produits
SET prix_unitaire = prix_unitaire * 1.10
WHERE id IN (
    SELECT id FROM produits 
    WHERE categorie = 'Informatique'
    LIMIT 1000
);
```

### 7. Ignorer les valeurs NULL

```sql
-- ❌ ERREUR : NULL n'est pas égal à NULL
DELETE FROM contacts WHERE telephone = NULL;  -- Ne supprime rien !

-- ✅ CORRECT : Utiliser IS NULL
DELETE FROM contacts WHERE telephone IS NULL;
```

### 8. Ne pas tester avant de modifier

```sql
-- ❌ Modifier directement
UPDATE clients SET type_client = 'client' WHERE ville = 'Paris';

-- ✅ Tester d'abord
SELECT COUNT(*) FROM clients WHERE ville = 'Paris';  -- 150 lignes !
-- Oups, trop de lignes, affiner la condition
SELECT COUNT(*) FROM clients WHERE ville = 'Paris' AND type_client = 'prospect';  -- 15 lignes
-- OK, maintenant modifier
UPDATE clients SET type_client = 'client' WHERE ville = 'Paris' AND type_client = 'prospect';
```

### 9. Oublier de sauvegarder

```sql
-- ❌ Modifier sans sauvegarde
UPDATE produits SET prix_unitaire = prix_unitaire * 2;  -- Oups, erreur !

-- ✅ Sauvegarder d'abord
CREATE TABLE produits_backup AS SELECT * FROM produits;
UPDATE produits SET prix_unitaire = prix_unitaire * 1.10;  -- Correct cette fois
-- Si OK :
DROP TABLE produits_backup;
-- Si erreur :
TRUNCATE produits;
INSERT INTO produits SELECT * FROM produits_backup;
```

### 10. Utiliser des sous-requêtes non corrélées

```sql
-- ❌ ERREUR : Sous-requête retourne plusieurs lignes
UPDATE commandes
SET client_id = (SELECT id FROM clients WHERE ville = 'Paris')
WHERE id = 10;
-- ERROR: more than one row returned

-- ✅ CORRECT : S'assurer qu'une seule ligne est retournée
UPDATE commandes
SET client_id = (SELECT id FROM clients WHERE email = 'unique@example.com')
WHERE id = 10;
```

---

## 📚 Ressources complémentaires

- [Cheat Sheet SQL - Requêtes SELECT](2_4_cheat_sheet_requetes.md)
- [Schéma de la base CRM](2_2_shema_base_crm.md)
- [Exercices pratiques](2_3_exercices_crm.md)
- [Rappel des fondamentaux](2_1_rappel_episodes_precedents.md)
- [Documentation PostgreSQL - DML](https://www.postgresql.org/docs/current/dml.html)

---

## 🎯 Résumé des commandes essentielles

| Commande | Usage | Danger | Transaction recommandée |
|----------|-------|--------|------------------------|
| `INSERT` | Ajouter des données | 🟢 Faible | Non (sauf multiples) |
| `UPDATE` | Modifier des données | 🔴 Élevé | ✅ Oui |
| `DELETE` | Supprimer des données | 🔴 Très élevé | ✅ Oui |
| `TRUNCATE` | Vider une table | 🔴 Extrême | ✅ Oui |
| `UPSERT` | Insérer ou mettre à jour | 🟡 Moyen | Non (atomique) |

---

**Version** : 1.0 - Octobre 2025  
**Base de données** : `exemple_crm` (PostgreSQL)  
**⚠️ Rappel** : Toujours tester avec SELECT et utiliser des transactions pour les modifications critiques !

