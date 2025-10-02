# Cheat Sheet SQL - Requêtes de sélection et d'agrégation

## 📋 Table des matières

1. [Requêtes SELECT de base](#-1-requêtes-select-de-base)
2. [Clauses de filtrage (WHERE)](#-2-clauses-de-filtrage-where)
3. [Tri et limitation](#-3-tri-et-limitation-order-by-limit)
4. [Jointures (JOIN)](#-4-jointures-join)
5. [Fonctions d'agrégation](#-5-fonctions-dagrégation)
6. [Regroupement (GROUP BY)](#-6-regroupement-group-by)
7. [Filtrage sur agrégats (HAVING)](#-7-filtrage-sur-agrégats-having)
8. [Sous-requêtes](#-8-sous-requêtes)
9. [Fonctions utiles](#-9-fonctions-utiles)
10. [Bonnes pratiques](#-10-bonnes-pratiques)

---

## 📋 1. Requêtes SELECT de base

### Syntaxe complète

```sql
SELECT [DISTINCT] colonne1 [AS alias1], colonne2 [AS alias2], ...
FROM table_name [AS alias_table]
WHERE condition
ORDER BY colonne [ASC|DESC]
LIMIT nombre [OFFSET décalage];
```

### Sélection de toutes les colonnes

```sql
-- ⚠️ À éviter en production (performances)
SELECT * FROM clients;
```

### Sélection de colonnes spécifiques

```sql
-- ✅ Bonne pratique : spécifier les colonnes
SELECT nom, email, type_client FROM clients;
```

### Alias de colonnes (AS)

```sql
-- Renommer les colonnes dans le résultat
SELECT 
    nom AS nom_entreprise,
    email AS contact_email,
    type_client AS statut
FROM clients;

-- AS est optionnel mais recommandé pour la lisibilité
SELECT nom nom_entreprise, email contact_email
FROM clients;
```

### DISTINCT - Éliminer les doublons

```sql
-- Lister les villes uniques
SELECT DISTINCT ville FROM clients;

-- Combinaisons uniques
SELECT DISTINCT type_client, ville FROM clients;
```

### Exemples sur exemple_crm

```sql
-- Lister tous les clients avec leurs informations principales
SELECT id, nom, email, type_client, date_creation
FROM clients
ORDER BY nom;

-- Lister les produits avec prix formaté
SELECT 
    nom AS produit,
    categorie,
    prix_unitaire AS prix,
    stock AS quantite_disponible
FROM produits;
```

---

## 🔍 2. Clauses de filtrage (WHERE)

### Opérateurs de comparaison

| Opérateur | Description | Exemple |
|-----------|-------------|---------|
| `=` | Égal | `WHERE type_client = 'client'` |
| `!=` ou `<>` | Différent | `WHERE statut != 'annulee'` |
| `<` | Inférieur | `WHERE prix_unitaire < 100` |
| `>` | Supérieur | `WHERE stock > 0` |
| `<=` | Inférieur ou égal | `WHERE age <= 30` |
| `>=` | Supérieur ou égal | `WHERE montant_total >= 1000` |

### Opérateurs logiques

```sql
-- AND : toutes les conditions doivent être vraies
SELECT * FROM produits
WHERE categorie = 'Informatique' AND prix_unitaire > 500;

-- OR : au moins une condition doit être vraie
SELECT * FROM clients
WHERE ville = 'Paris' OR ville = 'Lyon';

-- NOT : inverse la condition
SELECT * FROM commandes
WHERE NOT statut = 'annulee';
-- Équivalent à : WHERE statut != 'annulee'
```

### Opérateur IN

```sql
-- Vérifier si une valeur est dans une liste
SELECT * FROM clients
WHERE type_client IN ('prospect', 'client');

-- Équivalent à :
SELECT * FROM clients
WHERE type_client = 'prospect' OR type_client = 'client';

-- Avec NOT IN
SELECT * FROM produits
WHERE categorie NOT IN ('Services', 'Logiciel');
```

### Opérateur BETWEEN

```sql
-- Plage de valeurs (inclusif)
SELECT * FROM produits
WHERE prix_unitaire BETWEEN 100 AND 500;

-- Équivalent à :
SELECT * FROM produits
WHERE prix_unitaire >= 100 AND prix_unitaire <= 500;

-- Plage de dates
SELECT * FROM commandes
WHERE date_commande BETWEEN '2024-01-01' AND '2024-12-31';
```

### Opérateur LIKE - Patterns

| Pattern | Description | Exemple |
|---------|-------------|---------|
| `%` | N'importe quelle séquence de caractères | `'A%'` commence par A |
| `_` | Un seul caractère | `'_a%'` deuxième lettre est 'a' |

```sql
-- Commence par 'Tech'
SELECT * FROM clients WHERE nom LIKE 'Tech%';

-- Contient 'Solutions'
SELECT * FROM clients WHERE nom LIKE '%Solutions%';

-- Termine par 'SA'
SELECT * FROM clients WHERE nom LIKE '%SA';

-- Email Gmail
SELECT * FROM contacts WHERE email LIKE '%@gmail.com';

-- Nom de 5 caractères exactement
SELECT * FROM produits WHERE nom LIKE '_____';

-- ILIKE : insensible à la casse (PostgreSQL)
SELECT * FROM clients WHERE nom ILIKE 'tech%';
```

### Opérateurs NULL

```sql
-- Vérifier si NULL
SELECT * FROM contacts WHERE telephone IS NULL;

-- Vérifier si NOT NULL
SELECT * FROM clients WHERE email IS NOT NULL;

-- ⚠️ ERREUR : ne fonctionne pas avec = ou !=
-- SELECT * FROM contacts WHERE telephone = NULL;  -- ❌
```

### Exemples combinés

```sql
-- Clients actifs de Paris ou Lyon avec email
SELECT nom, email, ville
FROM clients
WHERE type_client = 'client'
  AND ville IN ('Paris', 'Lyon')
  AND email IS NOT NULL;

-- Produits informatiques entre 200€ et 1000€ en stock
SELECT nom, prix_unitaire, stock
FROM produits
WHERE categorie = 'Informatique'
  AND prix_unitaire BETWEEN 200 AND 1000
  AND stock > 0;

-- Commandes validées ou expédiées du premier trimestre 2024
SELECT id, date_commande, statut, montant_total
FROM commandes
WHERE statut IN ('validee', 'expediee')
  AND date_commande BETWEEN '2024-01-01' AND '2024-03-31';
```

---

## 📊 3. Tri et limitation (ORDER BY, LIMIT)

### ORDER BY - Tri simple

```sql
-- Tri ascendant (par défaut)
SELECT nom, prix_unitaire FROM produits
ORDER BY prix_unitaire ASC;

-- Tri descendant
SELECT nom, prix_unitaire FROM produits
ORDER BY prix_unitaire DESC;

-- ASC est optionnel (par défaut)
SELECT nom FROM clients ORDER BY nom;
```

### Tri sur plusieurs colonnes

```sql
-- Trier par catégorie puis par prix
SELECT nom, categorie, prix_unitaire
FROM produits
ORDER BY categorie ASC, prix_unitaire DESC;

-- Trier par type de client puis par nom
SELECT nom, type_client, ville
FROM clients
ORDER BY type_client, nom;
```

### LIMIT - Limiter le nombre de résultats

```sql
-- Les 10 premiers résultats
SELECT nom, prix_unitaire FROM produits
ORDER BY prix_unitaire DESC
LIMIT 10;

-- Top 5 des clients par ordre alphabétique
SELECT nom, email FROM clients
ORDER BY nom
LIMIT 5;
```

### OFFSET - Pagination

```sql
-- Résultats 11 à 20 (page 2, 10 par page)
SELECT nom, prix_unitaire FROM produits
ORDER BY prix_unitaire DESC
LIMIT 10 OFFSET 10;

-- Résultats 21 à 30 (page 3)
SELECT nom, prix_unitaire FROM produits
ORDER BY prix_unitaire DESC
LIMIT 10 OFFSET 20;
```

### Exemples pratiques

```sql
-- Top 5 des produits les plus chers
SELECT nom, categorie, prix_unitaire
FROM produits
ORDER BY prix_unitaire DESC
LIMIT 5;

-- 10 clients les plus récents
SELECT nom, email, date_creation
FROM clients
ORDER BY date_creation DESC
LIMIT 10;

-- Produits en rupture de stock
SELECT nom, categorie, stock
FROM produits
WHERE stock = 0
ORDER BY categorie, nom;

-- Commandes récentes avec montant élevé
SELECT id, date_commande, montant_total
FROM commandes
WHERE montant_total > 2000
ORDER BY date_commande DESC
LIMIT 20;
```

> 💡 **Astuce** : Toujours utiliser ORDER BY avec LIMIT pour garantir des résultats cohérents et prévisibles.

---

## 🔗 4. Jointures (JOIN)

### INNER JOIN - Jointure interne

**Syntaxe** :
```sql
SELECT colonnes
FROM table1
INNER JOIN table2 ON table1.cle = table2.cle;
```

**Exemples** :
```sql
-- Commandes avec nom du client
SELECT 
    cmd.id,
    cmd.date_commande,
    cl.nom AS client,
    cmd.montant_total
FROM commandes cmd
INNER JOIN clients cl ON cmd.client_id = cl.id;

-- Contacts avec leur entreprise
SELECT 
    co.prenom,
    co.nom,
    co.email,
    cl.nom AS entreprise
FROM contacts co
INNER JOIN clients cl ON co.client_id = cl.id;

-- Factures avec informations de commande et client
SELECT 
    f.numero_facture,
    f.date_facture,
    f.montant_ttc,
    cl.nom AS client
FROM factures f
INNER JOIN commandes cmd ON f.commande_id = cmd.id
INNER JOIN clients cl ON cmd.client_id = cl.id;
```

### LEFT JOIN - Jointure externe gauche

**Syntaxe** :
```sql
SELECT colonnes
FROM table1
LEFT JOIN table2 ON table1.cle = table2.cle;
```

**Exemples** :
```sql
-- Tous les clients avec leurs commandes (même sans commande)
SELECT 
    cl.nom,
    cl.type_client,
    cmd.id AS commande_id,
    cmd.montant_total
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id;

-- Clients sans commandes
SELECT 
    cl.nom,
    cl.email,
    cl.type_client
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
WHERE cmd.id IS NULL;

-- Produits jamais commandés
SELECT 
    p.nom,
    p.categorie,
    p.prix_unitaire
FROM produits p
LEFT JOIN commandes_produits cp ON p.id = cp.produit_id
WHERE cp.id IS NULL;
```

### RIGHT JOIN - Jointure externe droite

```sql
-- Moins utilisé, équivalent à LEFT JOIN en inversant les tables
SELECT 
    cl.nom,
    cmd.id AS commande_id
FROM commandes cmd
RIGHT JOIN clients cl ON cmd.client_id = cl.id;

-- Équivalent avec LEFT JOIN (préféré)
SELECT 
    cl.nom,
    cmd.id AS commande_id
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id;
```

### Jointures multiples

```sql
-- Détail complet d'une commande
SELECT
    cmd.id AS commande_id,
    cl.nom AS client,
    p.nom AS produit,
    cp.quantite,
    cp.prix_unitaire,
    (cp.quantite * cp.prix_unitaire) AS total_ligne
FROM commandes cmd
INNER JOIN clients cl ON cmd.client_id = cl.id
INNER JOIN commandes_produits cp ON cmd.id = cp.commande_id
INNER JOIN produits p ON cp.produit_id = p.id
WHERE cmd.id = 1;

-- Meetings avec contact et entreprise
SELECT
    m.titre,
    m.date_meeting,
    m.statut,
    co.prenom || ' ' || co.nom AS contact,
    cl.nom AS entreprise
FROM meetings m
INNER JOIN contacts co ON m.contact_id = co.id
INNER JOIN clients cl ON co.client_id = cl.id
ORDER BY m.date_meeting DESC;
```

### Alias de tables

```sql
-- Utiliser des alias courts pour simplifier
SELECT
    c.nom,
    c.email,
    cmd.date_commande,
    cmd.montant_total
FROM clients c
INNER JOIN commandes cmd ON c.id = cmd.client_id;

-- Alias obligatoires pour auto-jointures
SELECT
    c1.nom AS client,
    c2.nom AS autre_client_meme_ville
FROM clients c1
INNER JOIN clients c2 ON c1.ville = c2.ville
WHERE c1.id < c2.id;
```

> 💡 **Astuce** : Utilisez des alias courts mais significatifs (cl, cmd, prod) pour améliorer la lisibilité.

---

## 📈 5. Fonctions d'agrégation

### Fonctions principales

| Fonction | Description | Exemple |
|----------|-------------|---------|
| `COUNT()` | Compte le nombre de lignes | `COUNT(*)` ou `COUNT(colonne)` |
| `SUM()` | Somme des valeurs | `SUM(montant_total)` |
| `AVG()` | Moyenne des valeurs | `AVG(prix_unitaire)` |
| `MIN()` | Valeur minimale | `MIN(date_creation)` |
| `MAX()` | Valeur maximale | `MAX(stock)` |

### COUNT - Compter

```sql
-- Compter toutes les lignes
SELECT COUNT(*) AS total_clients FROM clients;

-- Compter les valeurs non NULL
SELECT COUNT(telephone) AS clients_avec_tel FROM contacts;

-- Compter les valeurs distinctes
SELECT COUNT(DISTINCT ville) AS nombre_villes FROM clients;

-- Différence entre COUNT(*) et COUNT(colonne)
SELECT
    COUNT(*) AS total_contacts,
    COUNT(telephone) AS avec_telephone,
    COUNT(*) - COUNT(telephone) AS sans_telephone
FROM contacts;
```

### SUM - Somme

```sql
-- Chiffre d'affaires total
SELECT SUM(montant_total) AS ca_total FROM commandes;

-- Stock total par catégorie
SELECT
    categorie,
    SUM(stock) AS stock_total
FROM produits
GROUP BY categorie;

-- Montant total des factures payées
SELECT SUM(montant_ttc) AS total_encaisse
FROM factures
WHERE statut_paiement = 'paye';
```

### AVG - Moyenne

```sql
-- Prix moyen des produits
SELECT AVG(prix_unitaire) AS prix_moyen FROM produits;

-- Panier moyen par client
SELECT
    cl.nom,
    AVG(cmd.montant_total) AS panier_moyen
FROM clients cl
INNER JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom;

-- Durée moyenne des meetings
SELECT AVG(duree_minutes) AS duree_moyenne FROM meetings;
```

### MIN et MAX

```sql
-- Produit le moins cher et le plus cher
SELECT
    MIN(prix_unitaire) AS prix_min,
    MAX(prix_unitaire) AS prix_max
FROM produits;

-- Première et dernière commande
SELECT
    MIN(date_commande) AS premiere_commande,
    MAX(date_commande) AS derniere_commande
FROM commandes;

-- Client le plus ancien
SELECT nom, date_creation
FROM clients
WHERE date_creation = (SELECT MIN(date_creation) FROM clients);
```

### Gestion des NULL

```sql
-- Les fonctions d'agrégation ignorent les NULL
SELECT
    COUNT(*) AS total_contacts,
    COUNT(telephone) AS avec_tel,
    AVG(CASE WHEN telephone IS NOT NULL THEN 1 ELSE 0 END) * 100 AS pct_avec_tel
FROM contacts;

-- SUM ignore les NULL (ne les compte pas comme 0)
SELECT SUM(stock) FROM produits;  -- NULL ne sont pas comptés
```

> ⚠️ **Important** : Les fonctions d'agrégation (sauf COUNT(*)) ignorent les valeurs NULL.

---

## 📊 6. Regroupement (GROUP BY)

### Syntaxe et règles

```sql
SELECT
    colonne_groupement,
    fonction_agregation(colonne)
FROM table
GROUP BY colonne_groupement;
```

**Règle importante** : Toute colonne dans SELECT qui n'est pas dans une fonction d'agrégation DOIT être dans GROUP BY.

### Regroupement simple

```sql
-- Nombre de clients par type
SELECT
    type_client,
    COUNT(*) AS nombre
FROM clients
GROUP BY type_client;

-- Nombre de produits par catégorie
SELECT
    categorie,
    COUNT(*) AS nb_produits,
    AVG(prix_unitaire) AS prix_moyen
FROM produits
GROUP BY categorie;

-- Commandes par statut
SELECT
    statut,
    COUNT(*) AS nb_commandes,
    SUM(montant_total) AS montant_total
FROM commandes
GROUP BY statut;
```

### Regroupement sur plusieurs colonnes

```sql
-- Clients par type et ville
SELECT
    type_client,
    ville,
    COUNT(*) AS nombre
FROM clients
GROUP BY type_client, ville
ORDER BY type_client, ville;

-- Ventes par catégorie et mois
SELECT
    p.categorie,
    TO_CHAR(cmd.date_commande, 'YYYY-MM') AS mois,
    SUM(cp.quantite * cp.prix_unitaire) AS ca
FROM commandes cmd
INNER JOIN commandes_produits cp ON cmd.id = cp.commande_id
INNER JOIN produits p ON cp.produit_id = p.id
GROUP BY p.categorie, TO_CHAR(cmd.date_commande, 'YYYY-MM')
ORDER BY mois, p.categorie;
```

### Exemples avec jointures

```sql
-- Nombre de commandes par client
SELECT
    cl.nom,
    COUNT(cmd.id) AS nb_commandes,
    SUM(cmd.montant_total) AS ca_total
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom
ORDER BY ca_total DESC;

-- Nombre de contacts par entreprise
SELECT
    cl.nom AS entreprise,
    COUNT(co.id) AS nb_contacts
FROM clients cl
LEFT JOIN contacts co ON cl.id = co.client_id
GROUP BY cl.id, cl.nom
HAVING COUNT(co.id) > 0
ORDER BY nb_contacts DESC;

-- Produits les plus vendus
SELECT
    p.nom,
    p.categorie,
    SUM(cp.quantite) AS quantite_vendue,
    SUM(cp.quantite * cp.prix_unitaire) AS ca_produit
FROM produits p
INNER JOIN commandes_produits cp ON p.id = cp.produit_id
GROUP BY p.id, p.nom, p.categorie
ORDER BY quantite_vendue DESC
LIMIT 10;
```

---

## 🎯 7. Filtrage sur agrégats (HAVING)

### Différence WHERE vs HAVING

| Clause | Utilisation | Moment d'exécution |
|--------|-------------|-------------------|
| `WHERE` | Filtre les lignes AVANT agrégation | Avant GROUP BY |
| `HAVING` | Filtre les groupes APRÈS agrégation | Après GROUP BY |

### Syntaxe HAVING

```sql
SELECT
    colonne_groupement,
    fonction_agregation(colonne)
FROM table
WHERE condition_sur_lignes
GROUP BY colonne_groupement
HAVING condition_sur_agregat;
```

### Exemples HAVING

```sql
-- Clients avec plus de 2 commandes
SELECT
    cl.nom,
    COUNT(cmd.id) AS nb_commandes
FROM clients cl
INNER JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom
HAVING COUNT(cmd.id) > 2;

-- Catégories avec CA > 10000€
SELECT
    p.categorie,
    SUM(cp.quantite * cp.prix_unitaire) AS ca_total
FROM produits p
INNER JOIN commandes_produits cp ON p.id = cp.produit_id
GROUP BY p.categorie
HAVING SUM(cp.quantite * cp.prix_unitaire) > 10000;

-- Villes avec au moins 3 clients
SELECT
    ville,
    COUNT(*) AS nb_clients
FROM clients
GROUP BY ville
HAVING COUNT(*) >= 3
ORDER BY nb_clients DESC;
```

### Combinaison WHERE + HAVING

```sql
-- Clients actifs avec CA > 5000€
SELECT
    cl.nom,
    COUNT(cmd.id) AS nb_commandes,
    SUM(cmd.montant_total) AS ca_total
FROM clients cl
INNER JOIN commandes cmd ON cl.id = cmd.client_id
WHERE cl.type_client = 'client'  -- Filtre AVANT agrégation
  AND cmd.statut != 'annulee'
GROUP BY cl.id, cl.nom
HAVING SUM(cmd.montant_total) > 5000  -- Filtre APRÈS agrégation
ORDER BY ca_total DESC;

-- Produits informatiques vendus plus de 50 fois
SELECT
    p.nom,
    SUM(cp.quantite) AS quantite_totale
FROM produits p
INNER JOIN commandes_produits cp ON p.id = cp.produit_id
WHERE p.categorie = 'Informatique'  -- Filtre sur les lignes
GROUP BY p.id, p.nom
HAVING SUM(cp.quantite) > 50  -- Filtre sur l'agrégat
ORDER BY quantite_totale DESC;
```

> 💡 **Astuce** : Utilisez WHERE pour filtrer les données avant l'agrégation (plus performant) et HAVING pour filtrer sur les résultats agrégés.

---

## 🔎 8. Sous-requêtes

### Sous-requêtes dans WHERE

```sql
-- Produits plus chers que la moyenne
SELECT nom, prix_unitaire
FROM produits
WHERE prix_unitaire > (SELECT AVG(prix_unitaire) FROM produits);

-- Clients ayant passé au moins une commande
SELECT nom, email
FROM clients
WHERE id IN (SELECT DISTINCT client_id FROM commandes);

-- Clients n'ayant jamais commandé
SELECT nom, email, type_client
FROM clients
WHERE id NOT IN (SELECT DISTINCT client_id FROM commandes WHERE client_id IS NOT NULL);
```

### Sous-requêtes avec EXISTS

```sql
-- Clients avec au moins une commande (plus performant que IN)
SELECT cl.nom, cl.email
FROM clients cl
WHERE EXISTS (
    SELECT 1 FROM commandes cmd
    WHERE cmd.client_id = cl.id
);

-- Produits jamais commandés
SELECT p.nom, p.categorie
FROM produits p
WHERE NOT EXISTS (
    SELECT 1 FROM commandes_produits cp
    WHERE cp.produit_id = p.id
);
```

### Sous-requêtes dans FROM

```sql
-- Top 5 des catégories par CA
SELECT categorie, ca_total
FROM (
    SELECT
        p.categorie,
        SUM(cp.quantite * cp.prix_unitaire) AS ca_total
    FROM produits p
    INNER JOIN commandes_produits cp ON p.id = cp.produit_id
    GROUP BY p.categorie
) AS ventes_par_categorie
ORDER BY ca_total DESC
LIMIT 5;
```

### Opérateurs ANY et ALL

```sql
-- Produits plus chers que n'importe quel produit de la catégorie Services
SELECT nom, prix_unitaire
FROM produits
WHERE prix_unitaire > ANY (
    SELECT prix_unitaire FROM produits WHERE categorie = 'Services'
);

-- Produits plus chers que tous les produits de la catégorie Services
SELECT nom, prix_unitaire
FROM produits
WHERE prix_unitaire > ALL (
    SELECT prix_unitaire FROM produits WHERE categorie = 'Services'
);
```

---

## 🛠️ 9. Fonctions utiles

### Fonctions de chaînes

```sql
-- CONCAT : concaténer des chaînes
SELECT CONCAT(prenom, ' ', nom) AS nom_complet FROM contacts;
-- Ou avec l'opérateur ||
SELECT prenom || ' ' || nom AS nom_complet FROM contacts;

-- UPPER / LOWER : changer la casse
SELECT UPPER(nom) AS nom_majuscule FROM clients;
SELECT LOWER(email) AS email_minuscule FROM contacts;

-- LENGTH : longueur d'une chaîne
SELECT nom, LENGTH(nom) AS longueur FROM clients;

-- SUBSTRING : extraire une partie
SELECT SUBSTRING(email FROM 1 FOR 10) AS debut_email FROM contacts;

-- TRIM : supprimer les espaces
SELECT TRIM(nom) AS nom_nettoye FROM clients;

-- REPLACE : remplacer du texte
SELECT REPLACE(telephone, ' ', '') AS tel_sans_espaces FROM contacts;
```

### Fonctions de dates

```sql
-- NOW() : date et heure actuelles
SELECT NOW() AS maintenant;

-- CURRENT_DATE : date actuelle
SELECT CURRENT_DATE AS aujourd_hui;

-- DATE_TRUNC : tronquer une date
SELECT DATE_TRUNC('month', date_commande) AS mois FROM commandes;

-- EXTRACT : extraire une partie de date
SELECT
    EXTRACT(YEAR FROM date_commande) AS annee,
    EXTRACT(MONTH FROM date_commande) AS mois,
    EXTRACT(DAY FROM date_commande) AS jour
FROM commandes;

-- AGE : calculer un âge ou une durée
SELECT AGE(NOW(), date_creation) AS anciennete FROM clients;

-- Intervalle
SELECT date_commande + INTERVAL '30 days' AS date_livraison_prevue
FROM commandes;
```

### Fonctions de conversion

```sql
-- CAST : convertir un type
SELECT CAST(prix_unitaire AS INTEGER) AS prix_arrondi FROM produits;
-- Syntaxe alternative
SELECT prix_unitaire::INTEGER AS prix_arrondi FROM produits;

-- TO_CHAR : formater en texte
SELECT TO_CHAR(date_commande, 'DD/MM/YYYY') AS date_fr FROM commandes;
SELECT TO_CHAR(montant_total, '999,999.99€') AS montant_formate FROM commandes;

-- TO_DATE : convertir texte en date
SELECT TO_DATE('2024-01-15', 'YYYY-MM-DD') AS ma_date;
```

### COALESCE - Gérer les NULL

```sql
-- Remplacer NULL par une valeur par défaut
SELECT
    nom,
    COALESCE(telephone, 'Non renseigné') AS telephone
FROM contacts;

-- Première valeur non NULL
SELECT
    nom,
    COALESCE(email, telephone, 'Aucun contact') AS contact
FROM contacts;

-- Calculs avec NULL
SELECT
    nom,
    prix_unitaire * COALESCE(stock, 0) AS valeur_stock
FROM produits;
```

### CASE - Conditions

```sql
-- CASE simple
SELECT
    nom,
    CASE type_client
        WHEN 'preprospect' THEN 'À qualifier'
        WHEN 'prospect' THEN 'En négociation'
        WHEN 'client' THEN 'Actif'
        ELSE 'Inconnu'
    END AS statut_fr
FROM clients;

-- CASE avec conditions
SELECT
    nom,
    prix_unitaire,
    CASE
        WHEN prix_unitaire < 100 THEN 'Économique'
        WHEN prix_unitaire < 500 THEN 'Standard'
        WHEN prix_unitaire < 1000 THEN 'Premium'
        ELSE 'Luxe'
    END AS gamme
FROM produits;
```

---

## ✅ 10. Bonnes pratiques

### 1. Spécifier les colonnes

```sql
-- ❌ Éviter
SELECT * FROM clients;

-- ✅ Préférer
SELECT id, nom, email, type_client FROM clients;
```

**Pourquoi ?**
- Meilleures performances
- Code plus maintenable
- Évite les surprises si la structure change

### 2. Utiliser des alias clairs

```sql
-- ❌ Peu lisible
SELECT c.n, c.e, o.d, o.t
FROM clients c
JOIN commandes o ON c.i = o.ci;

-- ✅ Clair et explicite
SELECT
    cl.nom AS nom_client,
    cl.email,
    cmd.date_commande,
    cmd.montant_total
FROM clients cl
INNER JOIN commandes cmd ON cl.id = cmd.client_id;
```

### 3. Indenter correctement

```sql
-- ✅ Bien indenté
SELECT
    cl.nom,
    COUNT(cmd.id) AS nb_commandes,
    SUM(cmd.montant_total) AS ca_total
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
WHERE cl.type_client = 'client'
GROUP BY cl.id, cl.nom
HAVING SUM(cmd.montant_total) > 1000
ORDER BY ca_total DESC;
```

### 4. Commenter les requêtes complexes

```sql
-- Analyse du CA par catégorie de produits
-- pour les commandes validées du Q1 2024
SELECT
    p.categorie,
    SUM(cp.quantite * cp.prix_unitaire) AS ca_total,
    COUNT(DISTINCT cmd.id) AS nb_commandes
FROM commandes cmd
INNER JOIN commandes_produits cp ON cmd.id = cp.commande_id
INNER JOIN produits p ON cp.produit_id = p.id
WHERE cmd.statut IN ('validee', 'expediee', 'livree')
  AND cmd.date_commande BETWEEN '2024-01-01' AND '2024-03-31'
GROUP BY p.categorie
ORDER BY ca_total DESC;
```

### 5. Utiliser les index

```sql
-- Créer des index sur les colonnes fréquemment filtrées
CREATE INDEX idx_commandes_date ON commandes(date_commande);
CREATE INDEX idx_clients_type ON clients(type_client);

-- Vérifier le plan d'exécution
EXPLAIN ANALYZE
SELECT * FROM commandes WHERE date_commande > '2024-01-01';
```

### 6. Attention aux performances

```sql
-- ❌ Éviter les sous-requêtes corrélées si possible
SELECT cl.nom,
    (SELECT COUNT(*) FROM commandes WHERE client_id = cl.id) AS nb_cmd
FROM clients cl;

-- ✅ Préférer les jointures
SELECT cl.nom, COUNT(cmd.id) AS nb_cmd
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom;
```

### 7. Gérer les NULL explicitement

```sql
-- ✅ Toujours vérifier les NULL dans les comparaisons
SELECT * FROM contacts
WHERE telephone IS NOT NULL;

-- ✅ Utiliser COALESCE pour les valeurs par défaut
SELECT nom, COALESCE(email, 'non renseigné') AS email
FROM contacts;
```

### 8. Limiter les résultats en développement

```sql
-- ✅ Ajouter LIMIT pendant les tests
SELECT * FROM commandes
ORDER BY date_commande DESC
LIMIT 100;
```

### 9. Utiliser les transactions pour les modifications

```sql
-- ✅ Encapsuler les modifications critiques
BEGIN;
UPDATE commandes SET statut = 'livree' WHERE id = 123;
UPDATE produits SET stock = stock - 5 WHERE id = 456;
COMMIT;
-- Ou ROLLBACK en cas d'erreur
```

### 10. Tester progressivement

```sql
-- 1. Commencer simple
SELECT * FROM clients LIMIT 5;

-- 2. Ajouter les filtres
SELECT * FROM clients WHERE type_client = 'client' LIMIT 5;

-- 3. Ajouter les jointures
SELECT cl.*, cmd.id
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
WHERE cl.type_client = 'client'
LIMIT 5;

-- 4. Ajouter les agrégations
SELECT cl.nom, COUNT(cmd.id) AS nb_cmd
FROM clients cl
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
WHERE cl.type_client = 'client'
GROUP BY cl.id, cl.nom
LIMIT 5;
```

---

## 📚 Ressources complémentaires

- [Documentation PostgreSQL officielle](https://www.postgresql.org/docs/)
- [Schéma de la base CRM](2_2_shema_base_crm.md)
- [Exercices pratiques](2_3_exercices_crm.md)
- [Rappel des fondamentaux](2_1_rappel_episodes_precedents.md)

---

**Version** : 1.0 - Octobre 2025
**Base de données** : `exemple_crm` (PostgreSQL)
