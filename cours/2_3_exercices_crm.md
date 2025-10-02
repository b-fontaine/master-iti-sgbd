# Exercices pratiques - Base de données CRM

## 🎯 Objectifs

Ces exercices vous permettront de pratiquer SQL sur une base de données réaliste représentant un système CRM complet. Vous allez apprendre à :
- Interroger des données avec des requêtes simples et complexes
- Utiliser les jointures pour combiner des données de plusieurs tables
- Agréger et analyser des données
- Créer des rapports métier

## 📋 Prérequis

- Base de données `exemple_crm` initialisée
- Accès à pgAdmin (http://localhost:8080) ou ligne de commande
- Avoir lu la documentation : [2.2 - Schéma de la base CRM](2_2_shema_base_crm.md)

## 🟢 Niveau 1 : Requêtes simples (SELECT, WHERE, ORDER BY)

### Exercice 1.1 : Lister les clients
**Objectif** : Afficher tous les clients par ordre alphabétique

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT * FROM clients ORDER BY nom;
```
</details>

### Exercice 1.2 : Filtrer par type de client
**Objectif** : Afficher uniquement les clients de type "client" (pas les prospects)

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT nom, email, telephone 
FROM clients 
WHERE type_client = 'client'
ORDER BY nom;
```
</details>

### Exercice 1.3 : Compter les produits par catégorie
**Objectif** : Afficher le nombre de produits dans chaque catégorie

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT categorie, COUNT(*) as nombre_produits
FROM produits
GROUP BY categorie
ORDER BY nombre_produits DESC;
```
</details>

### Exercice 1.4 : Produits les plus chers
**Objectif** : Afficher les 10 produits les plus chers

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT nom, categorie, prix_unitaire
FROM produits
ORDER BY prix_unitaire DESC
LIMIT 10;
```
</details>

### Exercice 1.5 : Meetings à venir
**Objectif** : Lister tous les meetings planifiés (statut = 'planifie')

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT titre, date_meeting, duree_minutes
FROM meetings
WHERE statut = 'planifie'
ORDER BY date_meeting;
```
</details>

## 🟡 Niveau 2 : Jointures et agrégations (JOIN, GROUP BY, HAVING)

### Exercice 2.1 : Clients avec leurs contacts
**Objectif** : Afficher chaque client avec le nombre de contacts associés

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    c.nom as entreprise,
    c.type_client,
    COUNT(co.id) as nb_contacts
FROM clients c
LEFT JOIN contacts co ON c.id = co.client_id
GROUP BY c.id, c.nom, c.type_client
ORDER BY nb_contacts DESC;
```
</details>

### Exercice 2.2 : Meetings par contact
**Objectif** : Afficher chaque contact avec le nombre de meetings associés

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    co.prenom,
    co.nom,
    co.email,
    COUNT(m.id) as nb_meetings
FROM contacts co
LEFT JOIN meetings m ON co.id = m.contact_id
GROUP BY co.id, co.prenom, co.nom, co.email
ORDER BY nb_meetings DESC;
```
</details>

### Exercice 2.3 : Chiffre d'affaires par client
**Objectif** : Calculer le CA total de chaque client ayant passé au moins une commande

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    cl.nom,
    cl.type_client,
    COUNT(cmd.id) as nb_commandes,
    SUM(cmd.montant_total) as ca_total
FROM clients cl
JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom, cl.type_client
ORDER BY ca_total DESC;
```
</details>

### Exercice 2.4 : Produits jamais commandés
**Objectif** : Trouver tous les produits qui n'ont jamais été commandés

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT p.nom, p.categorie, p.prix_unitaire
FROM produits p
LEFT JOIN commandes_produits cp ON p.id = cp.produit_id
WHERE cp.id IS NULL
ORDER BY p.categorie, p.nom;
```
</details>

### Exercice 2.5 : Commandes avec leur montant détaillé
**Objectif** : Afficher les commandes avec le nombre de produits et le montant total

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    cmd.id,
    cl.nom as client,
    cmd.date_commande,
    COUNT(cp.id) as nb_produits,
    SUM(cp.quantite * cp.prix_unitaire) as montant_calcule,
    cmd.montant_total
FROM commandes cmd
JOIN clients cl ON cmd.client_id = cl.id
JOIN commandes_produits cp ON cmd.id = cp.commande_id
GROUP BY cmd.id, cl.nom, cmd.date_commande, cmd.montant_total
ORDER BY cmd.date_commande DESC;
```
</details>

## 🔴 Niveau 3 : Requêtes avancées (Sous-requêtes, WINDOW functions)

### Exercice 3.1 : Top 10 des produits les plus vendus
**Objectif** : Afficher les 10 produits les plus vendus avec leur quantité totale et CA

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    p.nom,
    p.categorie,
    SUM(cp.quantite) as quantite_totale,
    SUM(cp.quantite * cp.prix_unitaire) as ca_produit
FROM produits p
JOIN commandes_produits cp ON p.id = cp.produit_id
GROUP BY p.id, p.nom, p.categorie
ORDER BY quantite_totale DESC
LIMIT 10;
```
</details>

### Exercice 3.2 : Analyse des ventes par catégorie
**Objectif** : Pour chaque catégorie, afficher le CA total et le pourcentage du CA global

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
WITH ca_par_categorie AS (
    SELECT 
        p.categorie,
        SUM(cp.quantite * cp.prix_unitaire) as ca_categorie
    FROM produits p
    JOIN commandes_produits cp ON p.id = cp.produit_id
    GROUP BY p.categorie
),
ca_total AS (
    SELECT SUM(ca_categorie) as ca_global
    FROM ca_par_categorie
)
SELECT 
    cpc.categorie,
    ROUND(cpc.ca_categorie::numeric, 2) as ca_categorie,
    ROUND((cpc.ca_categorie / ct.ca_global * 100)::numeric, 2) as pourcentage
FROM ca_par_categorie cpc, ca_total ct
ORDER BY ca_categorie DESC;
```
</details>

### Exercice 3.3 : Clients avec factures en retard
**Objectif** : Lister les clients ayant des factures en retard avec le montant total dû

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    cl.nom,
    cl.email,
    cl.telephone,
    COUNT(f.id) as nb_factures_retard,
    SUM(f.montant_ttc) as montant_total_retard
FROM clients cl
JOIN commandes cmd ON cl.id = cmd.client_id
JOIN factures f ON cmd.id = f.commande_id
WHERE f.statut_paiement = 'en_retard'
GROUP BY cl.id, cl.nom, cl.email, cl.telephone
ORDER BY montant_total_retard DESC;
```
</details>

### Exercice 3.4 : Taux de conversion prospect → client
**Objectif** : Calculer le taux de conversion des prospects en clients

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
WITH stats AS (
    SELECT 
        COUNT(*) FILTER (WHERE type_client = 'prospect') as nb_prospects,
        COUNT(*) FILTER (WHERE type_client = 'client') as nb_clients,
        COUNT(*) FILTER (WHERE type_client IN ('prospect', 'client')) as total
    FROM clients
)
SELECT 
    nb_prospects,
    nb_clients,
    ROUND((nb_clients::numeric / (nb_prospects + nb_clients) * 100), 2) as taux_conversion
FROM stats;
```
</details>

### Exercice 3.5 : Classement des clients par CA avec rang
**Objectif** : Classer les clients par CA en utilisant une fonction de fenêtrage

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    cl.nom,
    cl.type_client,
    SUM(cmd.montant_total) as ca_total,
    RANK() OVER (ORDER BY SUM(cmd.montant_total) DESC) as rang,
    ROUND((SUM(cmd.montant_total) / SUM(SUM(cmd.montant_total)) OVER () * 100)::numeric, 2) as part_ca
FROM clients cl
JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom, cl.type_client
ORDER BY ca_total DESC;
```
</details>

## 🎓 Exercices de synthèse

### Exercice S1 : Rapport mensuel des ventes
**Objectif** : Créer un rapport des ventes par mois avec le nombre de commandes et le CA

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    TO_CHAR(date_commande, 'YYYY-MM') as mois,
    COUNT(*) as nb_commandes,
    SUM(montant_total) as ca_mensuel,
    ROUND(AVG(montant_total)::numeric, 2) as panier_moyen
FROM commandes
WHERE statut != 'annulee'
GROUP BY TO_CHAR(date_commande, 'YYYY-MM')
ORDER BY mois;
```
</details>

### Exercice S2 : Analyse de la performance commerciale
**Objectif** : Pour chaque commercial (contact), calculer le nombre de meetings et le CA généré

**Note** : Cet exercice nécessite de faire le lien entre meetings → contacts → clients → commandes

```sql
-- Votre requête ici
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    co.prenom || ' ' || co.nom as commercial,
    cl.nom as entreprise,
    COUNT(DISTINCT m.id) as nb_meetings,
    COUNT(DISTINCT cmd.id) as nb_commandes,
    COALESCE(SUM(cmd.montant_total), 0) as ca_genere
FROM contacts co
JOIN clients cl ON co.client_id = cl.id
LEFT JOIN meetings m ON co.id = m.contact_id
LEFT JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY co.id, co.prenom, co.nom, cl.nom
HAVING COUNT(DISTINCT m.id) > 0
ORDER BY ca_genere DESC;
```
</details>

### Exercice S3 : Détail complet d'une commande
**Objectif** : Afficher tous les détails d'une commande (client, produits, facture)

```sql
-- Votre requête ici (pour la commande id = 1)
```

<details>
<summary>💡 Solution</summary>

```sql
SELECT 
    cmd.id as commande_id,
    cmd.date_commande,
    cmd.statut as statut_commande,
    cl.nom as client,
    cl.email as email_client,
    p.nom as produit,
    p.categorie,
    cp.quantite,
    cp.prix_unitaire,
    (cp.quantite * cp.prix_unitaire) as total_ligne,
    f.numero_facture,
    f.statut_paiement,
    f.montant_ttc
FROM commandes cmd
JOIN clients cl ON cmd.client_id = cl.id
JOIN commandes_produits cp ON cmd.id = cp.commande_id
JOIN produits p ON cp.produit_id = p.id
LEFT JOIN factures f ON cmd.id = f.commande_id
WHERE cmd.id = 1
ORDER BY p.nom;
```
</details>

## 💡 Conseils pour réussir

1. **Commencez simple** : Testez d'abord une requête simple avant de la complexifier
2. **Utilisez EXPLAIN** : Pour comprendre comment PostgreSQL exécute votre requête
   ```sql
   EXPLAIN ANALYZE SELECT ...
   ```
3. **Vérifiez les NULL** : Utilisez LEFT JOIN quand une relation peut ne pas exister
4. **Nommez vos colonnes** : Utilisez des alias clairs (AS)
5. **Testez progressivement** : Ajoutez les jointures une par une
6. **Utilisez les index** : Les index sont déjà créés sur les clés étrangères

## 🔍 Commandes utiles pour explorer

```sql
-- Voir la structure d'une table
\d clients

-- Compter les enregistrements
SELECT COUNT(*) FROM clients;

-- Voir un échantillon de données
SELECT * FROM clients LIMIT 5;

-- Lister toutes les tables
\dt

-- Voir les index d'une table
\di clients
```

## 📚 Pour aller plus loin

Une fois ces exercices maîtrisés, vous pouvez :
1. Créer vos propres requêtes d'analyse
2. Créer des vues pour simplifier les requêtes complexes
3. Écrire des fonctions PL/pgSQL
4. Optimiser les requêtes lentes
5. Créer des triggers pour automatiser des actions

## 🆘 Besoin d'aide ?

- Consultez la documentation : [2.2 - Schéma de la base CRM](2_2_shema_base_crm.md)
- Utilisez `\?` dans psql pour l'aide
- Consultez la [documentation PostgreSQL](https://www.postgresql.org/docs/)

---

**Bon courage et bon apprentissage ! 🚀**

