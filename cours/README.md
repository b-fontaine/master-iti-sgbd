# 📚 Cours de Bases de Données - Master ITI

Bienvenue dans le répertoire des supports de cours pour le module de Systèmes de Gestion de Bases de Données (SGBD).

## 📖 Table des matières

### Module 1 : Fondamentaux des bases de données

#### [1.1 - Fondamentaux](1_1_fondamentaux.md)
- Histoire des bases de données
- Concepts de base
- Types de SGBD
- Architecture des systèmes de bases de données

#### [1.2 - Cheat Sheet Notion](1_2_cheat_sheet_notion.md)
- Aide-mémoire des concepts clés
- Terminologie essentielle
- Références rapides

#### [1.3 - Introduction SQL](1_3_introduction_sql.md)
- Premiers pas avec SQL
- Syntaxe de base
- Commandes essentielles

### Module 2 : Bases de données relationnelles et SQL

#### [2.1 - Rappel des épisodes précédents](2_1_rappel_episodes_precedents.md)
- Révision des concepts du Module 1
- Points clés à retenir
- Préparation pour le Module 2

#### [2.2 - Schéma de la base de données CRM](2_2_shema_base_crm.md) ⭐ **NOUVEAU**
- Documentation complète de la base `exemple_crm`
- Schémas relationnels avec Mermaid
- Diagrammes de flux et d'état
- Description détaillée des 7 tables
- Exemples de requêtes SQL
- Cas d'usage pédagogiques

#### [2.3 - Exercices pratiques CRM](2_3_exercices_crm.md) ⭐ **NOUVEAU**
- 15+ exercices progressifs sur la base CRM
- 3 niveaux de difficulté (débutant, intermédiaire, avancé)
- Solutions détaillées pour chaque exercice
- Exercices de synthèse
- Conseils et bonnes pratiques

#### [2.4 - Cheat Sheet SQL - SELECT](2_4_cheat_sheet_requetes.md) ⭐ **NOUVEAU**
- Aide-mémoire complet des requêtes SQL
- SELECT, WHERE, JOIN, GROUP BY, HAVING
- Fonctions d'agrégation et sous-requêtes
- Fonctions utiles (chaînes, dates, conversion)
- Bonnes pratiques et exemples concrets

#### [2.5 - Cheat Sheet SQL - DML](2_5_cheat_sheet_dml.md) ⭐ **NOUVEAU**
- INSERT, UPDATE, DELETE, UPSERT
- Transactions et sécurité (BEGIN, COMMIT, ROLLBACK)
- Bonnes pratiques pour éviter les erreurs
- Exemples pratiques sur exemple_crm
- ⚠️ Pièges courants à éviter

## 🗄️ Bases de données disponibles

### 1. `exemple_cours` - Base d'apprentissage simple
Base de données d'introduction avec :
- Table `exemple_personnes` (5 enregistrements)
- Table `produits` (5 enregistrements)

**Utilisation** : Premiers exercices SQL, requêtes simples

### 2. `exemple_crm` - Base CRM complète ⭐ **NOUVEAU**
Système complet de gestion de la relation client avec :
- **7 tables** interconnectées
- **20 clients** (préprospects, prospects, clients)
- **44 contacts** répartis sur les clients
- **50 meetings** avec différents statuts
- **100 produits** en 5 catégories
- **40 commandes** avec plusieurs produits
- **15 factures** avec statuts variés

**Utilisation** : Exercices avancés, jointures complexes, agrégations, sous-requêtes

**Documentation** : Voir [2.2 - Schéma de la base CRM](2_2_shema_base_crm.md)

### 3. `metabase` - Base système
Base de données utilisée par Metabase pour stocker ses configurations.

**Utilisation** : Ne pas modifier directement

## 🚀 Accès aux bases de données

### Via pgAdmin (Interface graphique)
1. Ouvrir http://localhost:8080
2. Se connecter avec :
   - **Email** : `admin@example.com`
   - **Mot de passe** : `admin123`
3. Le serveur PostgreSQL est déjà configuré
4. Sélectionner la base de données souhaitée

### Via ligne de commande

```bash
# Accès à la base exemple_cours
docker exec -it postgres_sgbd psql -U postgres -d exemple_cours

# Accès à la base exemple_crm
docker exec -it postgres_sgbd psql -U postgres -d exemple_crm

# Lister toutes les bases de données
docker exec -it postgres_sgbd psql -U postgres -c "\l"
```

### Via Metabase (Visualisation)
1. Ouvrir http://localhost:3000
2. Se connecter avec :
   - **Email** : `admin@example.com`
   - **Mot de passe** : `admin123`
3. La base PostgreSQL est déjà connectée

## 📊 Progression pédagogique recommandée

### Niveau 1 : Débutant (Base `exemple_cours`)
1. Requêtes SELECT simples
2. Filtrage avec WHERE
3. Tri avec ORDER BY
4. Fonctions d'agrégation basiques (COUNT, SUM, AVG)

### Niveau 2 : Intermédiaire (Base `exemple_crm`)
1. Jointures (INNER JOIN, LEFT JOIN)
2. GROUP BY et HAVING
3. Sous-requêtes simples
4. Fonctions de chaînes et dates

### Niveau 3 : Avancé (Base `exemple_crm`)
1. Jointures multiples
2. Sous-requêtes corrélées
3. Fonctions de fenêtrage (WINDOW functions)
4. Requêtes d'analyse complexes
5. Optimisation avec les index

## 💡 Exemples de requêtes par niveau

### Niveau Débutant

```sql
-- Lister tous les clients
SELECT * FROM clients ORDER BY nom;

-- Compter le nombre de produits par catégorie
SELECT categorie, COUNT(*) as nombre
FROM produits
GROUP BY categorie;
```

### Niveau Intermédiaire

```sql
-- Clients avec leurs contacts
SELECT c.nom as entreprise, co.prenom, co.nom, co.poste
FROM clients c
LEFT JOIN contacts co ON c.id = co.client_id
ORDER BY c.nom, co.nom;

-- Chiffre d'affaires par client
SELECT cl.nom, SUM(cmd.montant_total) as ca_total
FROM clients cl
JOIN commandes cmd ON cl.id = cmd.client_id
GROUP BY cl.id, cl.nom
HAVING SUM(cmd.montant_total) > 3000
ORDER BY ca_total DESC;
```

### Niveau Avancé

```sql
-- Top 10 des produits les plus vendus avec leur CA
SELECT 
    p.nom,
    p.categorie,
    SUM(cp.quantite) as quantite_totale,
    SUM(cp.quantite * cp.prix_unitaire) as ca_produit,
    RANK() OVER (ORDER BY SUM(cp.quantite) DESC) as rang
FROM produits p
JOIN commandes_produits cp ON p.id = cp.produit_id
JOIN commandes cmd ON cp.commande_id = cmd.id
WHERE cmd.statut IN ('validee', 'expediee', 'livree')
GROUP BY p.id, p.nom, p.categorie
ORDER BY quantite_totale DESC
LIMIT 10;

-- Clients avec factures en retard
SELECT 
    cl.nom,
    cl.email,
    COUNT(f.id) as nb_factures_retard,
    SUM(f.montant_ttc) as montant_total_retard
FROM clients cl
JOIN commandes cmd ON cl.id = cmd.client_id
JOIN factures f ON cmd.id = f.commande_id
WHERE f.statut_paiement = 'en_retard'
GROUP BY cl.id, cl.nom, cl.email
ORDER BY montant_total_retard DESC;
```

## 🎯 Exercices suggérés

### Exercices Module 1 (Base `exemple_cours`)
1. Afficher toutes les personnes de plus de 30 ans
2. Calculer le prix moyen des produits
3. Trouver les produits en stock supérieur à 10

### Exercices Module 2 (Base `exemple_crm`)
1. Lister tous les meetings planifiés pour les 30 prochains jours
2. Calculer le taux de conversion prospect → client
3. Identifier les produits jamais commandés
4. Créer un rapport mensuel des ventes par catégorie
5. Analyser la performance commerciale par type de client

## 📁 Structure des fichiers

```
cours/
├── README.md                           # Ce fichier
├── 1_1_fondamentaux.md                # Histoire et concepts
├── 1_2_cheat_sheet_notion.md          # Aide-mémoire Notion
├── 1_3_introduction_sql.md            # Introduction SQL
├── 2_1_rappel_episodes_precedents.md  # Révisions Séance 1
├── 2_2_shema_base_crm.md              # Documentation CRM ⭐
├── 2_3_exercices_crm.md               # Exercices pratiques CRM ⭐
├── 2_4_cheat_sheet_requetes.md        # Cheat Sheet SQL SELECT ⭐
├── 2_5_cheat_sheet_dml.md             # Cheat Sheet SQL DML ⭐
└── img/                                # Images du cours
    ├── as_400.png
    └── ibm_disk_drive.png
```

## 🔧 Commandes utiles

### Gestion des containers Docker

```bash
# Démarrer l'environnement
docker compose -p master up -d

# Arrêter l'environnement
docker compose -p master down

# Voir les logs
docker compose -p master logs -f

# Redémarrer avec réinitialisation complète
docker compose -p master down -v
docker compose -p master up -d
```

### Commandes PostgreSQL utiles

```sql
-- Lister les tables
\dt

-- Décrire une table
\d nom_table

-- Lister les bases de données
\l

-- Se connecter à une autre base
\c nom_base

-- Afficher l'aide
\?

-- Quitter
\q
```

## 📚 Ressources complémentaires

- [Documentation PostgreSQL officielle](https://www.postgresql.org/docs/)
- [SQL Tutorial - W3Schools](https://www.w3schools.com/sql/)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [Metabase Documentation](https://www.metabase.com/docs/latest/)

## 🆘 Support

En cas de problème :
1. Vérifier que tous les containers sont démarrés : `docker compose -p master ps`
2. Consulter les logs : `docker compose -p master logs`
3. Redémarrer l'environnement si nécessaire
4. Consulter le fichier `CONFIGURATION.md` à la racine du projet

---

**Dernière mise à jour** : Octobre 2025  
**Version** : 2.0 - Ajout de la base de données CRM complète
