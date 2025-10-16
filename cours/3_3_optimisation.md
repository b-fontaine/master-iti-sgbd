# 3.3 Optimisation des Bases de Données

## Introduction

L'optimisation des bases de données est un art qui combine compréhension théorique et expérience pratique. Dans ce chapitre, nous allons explorer les techniques d'optimisation en utilisant notre base de données **Second Brain (PARA+GTD)** comme cas d'étude.

### Objectifs d'apprentissage

À la fin de ce chapitre, vous serez capable de :
1. **Analyser** les performances d'une requête avec EXPLAIN et EXPLAIN ANALYZE
2. **Créer** des index efficaces et comprendre leur impact
3. **Concevoir** des vues optimisées pour simplifier les requêtes complexes
4. **Identifier** les opportunités d'optimisation avancée (partitionnement, vues matérialisées, etc.)

### Prérequis

- Base de données Second Brain créée (voir `3_2_second_brain_db.md`)
- Données d'exemple insérées
- Connaissance des requêtes SQL de base

---

## 1. EXPLAIN et l'analyse du plan d'exécution

### 1.1 Qu'est-ce qu'un plan d'exécution ?

Lorsque vous exécutez une requête SQL, le SGBD ne l'exécute pas directement. Il passe par plusieurs étapes :

1. **Parsing** : Analyse syntaxique de la requête
2. **Optimisation** : Le moteur génère plusieurs plans d'exécution possibles
3. **Sélection** : Choix du plan le plus efficace (basé sur des statistiques)
4. **Exécution** : Exécution du plan choisi

Le **plan d'exécution** est la stratégie choisie par le SGBD pour exécuter votre requête. EXPLAIN vous permet de visualiser ce plan.

### 1.2 Syntaxe de base

```sql
-- MySQL/MariaDB
EXPLAIN SELECT * FROM actions WHERE user_id = 1;

-- PostgreSQL (plus détaillé)
EXPLAIN ANALYZE SELECT * FROM actions WHERE user_id = 1;

-- MySQL 8.0+ (format JSON pour plus de détails)
EXPLAIN FORMAT=JSON SELECT * FROM actions WHERE user_id = 1;
```

### 1.3 Comprendre la sortie de EXPLAIN

#### **Exemple 1 : Requête simple sans index**

```sql
EXPLAIN SELECT * FROM actions WHERE user_id = 1 AND status = 'todo';
```

**Sortie typique (MySQL) :**

| id | select_type | table   | type | possible_keys | key  | key_len | ref  | rows | Extra       |
|----|-------------|---------|------|---------------|------|---------|------|------|-------------|
| 1  | SIMPLE      | actions | ALL  | NULL          | NULL | NULL    | NULL | 1000 | Using where |

**Analyse :**
- **type: ALL** → ⚠️ **Table scan complet** (parcourt toutes les lignes)
- **possible_keys: NULL** → Aucun index disponible
- **rows: 1000** → Estime qu'il faut examiner 1000 lignes
- **Extra: Using where** → Filtre appliqué après lecture

**Verdict : Performance médiocre** 🐌

#### **Exemple 2 : Même requête avec index**

Après avoir créé un index :
```sql
CREATE INDEX idx_actions_user_status ON actions(user_id, status);
```

```sql
EXPLAIN SELECT * FROM actions WHERE user_id = 1 AND status = 'todo';
```

**Sortie avec index :**

| id | select_type | table   | type | possible_keys           | key                     | key_len | ref         | rows | Extra       |
|----|-------------|---------|------|-------------------------|-------------------------|---------|-------------|------|-------------|
| 1  | SIMPLE      | actions | ref  | idx_actions_user_status | idx_actions_user_status | 9       | const,const | 5    | Using index |

**Analyse :**
- **type: ref** → ✅ **Utilise un index** (beaucoup plus rapide)
- **key: idx_actions_user_status** → Index utilisé
- **rows: 5** → Estime seulement 5 lignes à examiner (au lieu de 1000)
- **Extra: Using index** → Toutes les données viennent de l'index (pas besoin de lire la table)

**Verdict : Performance excellente** 🚀

### 1.4 Les types d'accès (colonne "type")

Classés du plus rapide au plus lent :

| Type | Description | Performance |
|------|-------------|-------------|
| **system** | Table avec une seule ligne | ⚡⚡⚡⚡⚡ Excellent |
| **const** | Recherche par clé primaire ou unique | ⚡⚡⚡⚡⚡ Excellent |
| **eq_ref** | Une ligne par jointure (clé unique) | ⚡⚡⚡⚡ Très bon |
| **ref** | Plusieurs lignes via index non-unique | ⚡⚡⚡ Bon |
| **range** | Recherche dans une plage (BETWEEN, >, <) | ⚡⚡ Acceptable |
| **index** | Scan complet de l'index | ⚡ Moyen |
| **ALL** | Scan complet de la table | 🐌 Mauvais |

### 1.5 Cas pratiques avec notre base Second Brain

#### **Cas 1 : Requête de tableau de bord**

```sql
-- Requête : Afficher toutes les actions "todo" de Marie par contexte
EXPLAIN 
SELECT 
    c.name AS contexte,
    a.title AS action,
    a.estimated_minutes AS duree
FROM actions a
JOIN contexts c ON a.context_id = c.id
WHERE a.user_id = 1 
  AND a.status = 'todo'
ORDER BY c.name, a.due_date;
```

**Analyse du plan (sans optimisation) :**

```
+----+-------------+-------+------+---------------+------+---------+------+------+-----------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra                       |
+----+-------------+-------+------+---------------+------+---------+------+------+-----------------------------+
|  1 | SIMPLE      | a     | ALL  | NULL          | NULL | NULL    | NULL | 1000 | Using where; Using filesort |
|  1 | SIMPLE      | c     | ALL  | PRIMARY       | NULL | NULL    | NULL |   10 | Using where; Using join buf |
+----+-------------+-------+------+---------------+------+---------+------+------+-----------------------------+
```

**Problèmes identifiés :**
1. ⚠️ **Table scan** sur `actions` (type: ALL)
2. ⚠️ **Using filesort** → Tri coûteux en mémoire
3. ⚠️ **Using join buffer** → Jointure inefficace

**Solutions :**
```sql
-- Index composite pour filtrer et trier
CREATE INDEX idx_actions_user_status_context ON actions(user_id, status, context_id, due_date);

-- Index sur la clé étrangère (si pas déjà présent)
CREATE INDEX idx_actions_context ON actions(context_id);
```

**Après optimisation :**

```
+----+-------------+-------+------+----------------------------------+----------------------------------+---------+-------+------+-----------------------+
| id | select_type | table | type | possible_keys                    | key                              | key_len | ref   | rows | Extra                 |
+----+-------------+-------+------+----------------------------------+----------------------------------+---------+-------+------+-----------------------+
|  1 | SIMPLE      | a     | ref  | idx_actions_user_status_context  | idx_actions_user_status_context  | 9       | const |    5 | Using index condition |
|  1 | SIMPLE      | c     | eq_ref | PRIMARY                        | PRIMARY                          | 4       | a.ctx |    1 | NULL                  |
+----+-------------+-------+------+----------------------------------+----------------------------------+---------+-------+------+-----------------------+
```

**Amélioration :** ✅ Passage de 1000 lignes examinées à 5 lignes !

#### **Cas 2 : Requête avec agrégation**

```sql
-- Requête : Compter les actions par statut pour chaque projet
EXPLAIN
SELECT 
    p.title,
    COUNT(*) AS total_actions,
    SUM(CASE WHEN a.status = 'done' THEN 1 ELSE 0 END) AS done_count
FROM projects p
LEFT JOIN actions a ON p.id = a.project_id
WHERE p.user_id = 1 AND p.is_archived = FALSE
GROUP BY p.id, p.title;
```

**Optimisations recommandées :**
```sql
-- Index pour le filtre sur projects
CREATE INDEX idx_projects_user_archived ON projects(user_id, is_archived);

-- Index pour la jointure et l'agrégation
CREATE INDEX idx_actions_project_status ON actions(project_id, status);
```

### 1.6 EXPLAIN ANALYZE (PostgreSQL)

PostgreSQL offre `EXPLAIN ANALYZE` qui **exécute réellement** la requête et compare les estimations aux valeurs réelles.

```sql
EXPLAIN ANALYZE
SELECT * FROM actions 
WHERE user_id = 1 AND status = 'todo';
```

**Sortie exemple :**

```
Seq Scan on actions  (cost=0.00..25.50 rows=5 width=200) (actual time=0.015..0.234 rows=5 loops=1)
  Filter: ((user_id = 1) AND (status = 'todo'::text))
  Rows Removed by Filter: 995
Planning Time: 0.123 ms
Execution Time: 0.267 ms
```

**Informations clés :**
- **cost** : Estimation du coût (unités arbitraires)
- **rows** : Nombre de lignes estimé vs **actual rows** (réel)
- **actual time** : Temps réel d'exécution
- **Rows Removed by Filter** : Lignes lues mais rejetées (inefficacité)

### 1.7 Checklist d'analyse avec EXPLAIN

Lorsque vous analysez un plan d'exécution, vérifiez :

✅ **Type d'accès** : Évitez "ALL" (table scan)  
✅ **Nombre de lignes** : Plus c'est bas, mieux c'est  
✅ **Index utilisés** : Les bons index sont-ils utilisés ?  
✅ **Extra** :
   - ⚠️ "Using filesort" → Tri coûteux
   - ⚠️ "Using temporary" → Table temporaire créée
   - ✅ "Using index" → Données lues depuis l'index uniquement
   - ✅ "Using index condition" → Filtre appliqué au niveau de l'index

---

## 2. Les index : création et impact

### 2.1 Qu'est-ce qu'un index ?

Un **index** est une structure de données auxiliaire qui permet de retrouver rapidement des lignes dans une table, similaire à l'index d'un livre.

**Analogie :**
- **Sans index** : Lire un livre page par page pour trouver un mot → O(n)
- **Avec index** : Consulter l'index alphabétique à la fin → O(log n)

### 2.2 Types d'index

#### **2.2.1 Index B-Tree (par défaut)**

Structure arborescente équilibrée, idéale pour :
- Recherches d'égalité (`WHERE id = 5`)
- Recherches de plage (`WHERE age BETWEEN 20 AND 30`)
- Tri (`ORDER BY name`)
- Préfixes (`WHERE name LIKE 'John%'`)

```sql
-- Index simple
CREATE INDEX idx_actions_status ON actions(status);

-- Index composite (multi-colonnes)
CREATE INDEX idx_actions_user_status ON actions(user_id, status);
```

#### **2.2.2 Index UNIQUE**

Garantit l'unicité des valeurs + accélère les recherches.

```sql
-- Empêche les doublons d'email
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

#### **2.2.3 Index FULLTEXT (recherche textuelle)**

Pour les recherches dans du texte long.

```sql
-- Recherche dans les descriptions
CREATE FULLTEXT INDEX idx_resources_content ON resources(content);

-- Utilisation
SELECT * FROM resources 
WHERE MATCH(content) AGAINST('SQL optimization' IN NATURAL LANGUAGE MODE);
```

#### **2.2.4 Index HASH (MySQL/PostgreSQL)**

Très rapide pour l'égalité stricte, mais ne supporte pas les plages.

```sql
-- PostgreSQL
CREATE INDEX idx_contexts_name ON contexts USING HASH (name);
```

### 2.3 Création d'index : bonnes pratiques

#### **Règle 1 : Indexer les colonnes de filtrage (WHERE)**

```sql
-- Requête fréquente
SELECT * FROM actions WHERE user_id = 1 AND status = 'todo';

-- Index recommandé
CREATE INDEX idx_actions_user_status ON actions(user_id, status);
```

#### **Règle 2 : Indexer les colonnes de jointure**

```sql
-- Jointure fréquente
SELECT * FROM actions a
JOIN projects p ON a.project_id = p.id;

-- Index sur la clé étrangère
CREATE INDEX idx_actions_project ON actions(project_id);
```

#### **Règle 3 : Indexer les colonnes de tri (ORDER BY)**

```sql
-- Requête avec tri
SELECT * FROM actions 
WHERE user_id = 1 
ORDER BY due_date DESC;

-- Index incluant la colonne de tri
CREATE INDEX idx_actions_user_duedate ON actions(user_id, due_date);
```

#### **Règle 4 : Ordre des colonnes dans un index composite**

**Principe :** Colonnes les plus sélectives en premier.

```sql
-- ❌ Mauvais ordre (status a peu de valeurs distinctes)
CREATE INDEX idx_bad ON actions(status, user_id);

-- ✅ Bon ordre (user_id est plus sélectif)
CREATE INDEX idx_good ON actions(user_id, status);
```

**Règle du préfixe :** Un index composite `(A, B, C)` peut être utilisé pour :
- `WHERE A = ?`
- `WHERE A = ? AND B = ?`
- `WHERE A = ? AND B = ? AND C = ?`

Mais **PAS** pour :
- `WHERE B = ?` (saute la première colonne)
- `WHERE C = ?`

### 2.4 Impact des index sur les performances

#### **2.4.1 Impact sur les SELECT (positif) ✅**

**Exemple : Recherche d'actions**

```sql
-- Sans index
SELECT * FROM actions WHERE user_id = 1 AND status = 'todo';
-- Temps : 45ms (scan de 10,000 lignes)

-- Avec index
CREATE INDEX idx_actions_user_status ON actions(user_id, status);
SELECT * FROM actions WHERE user_id = 1 AND status = 'todo';
-- Temps : 2ms (lecture directe de 5 lignes)
```

**Gain : 22x plus rapide** 🚀

#### **2.4.2 Impact sur les INSERT (négatif) ⚠️**

Chaque index doit être mis à jour lors d'une insertion.

```sql
-- Table sans index
INSERT INTO actions (...) VALUES (...);
-- Temps : 1ms

-- Table avec 5 index
INSERT INTO actions (...) VALUES (...);
-- Temps : 3ms (chaque index doit être mis à jour)
```

**Coût : ~2-3x plus lent par index**

#### **2.4.3 Impact sur les UPDATE ⚠️**

Si la colonne indexée est modifiée, l'index doit être réorganisé.

```sql
-- Mise à jour d'une colonne indexée
UPDATE actions SET status = 'done' WHERE id = 1;
-- Temps : 2ms (index idx_actions_status doit être mis à jour)

-- Mise à jour d'une colonne non-indexée
UPDATE actions SET description = 'New desc' WHERE id = 1;
-- Temps : 1ms (aucun index affecté)
```

#### **2.4.4 Impact sur les DELETE ⚠️**

Tous les index doivent être mis à jour.

```sql
-- Suppression avec 5 index
DELETE FROM actions WHERE id = 1;
-- Temps : 3ms (suppression dans la table + 5 index)
```

### 2.5 Cas pratiques : indexation de la base Second Brain

#### **Index essentiels (déjà créés dans 3_2)**

```sql
-- Clés étrangères (pour les jointures)
CREATE INDEX idx_actions_user ON actions(user_id);
CREATE INDEX idx_actions_project ON actions(project_id);
CREATE INDEX idx_actions_context ON actions(context_id);
CREATE INDEX idx_projects_user ON projects(user_id);
CREATE INDEX idx_projects_area ON projects(area_id);

-- Filtres fréquents
CREATE INDEX idx_actions_status ON actions(status);
CREATE INDEX idx_projects_archived ON projects(is_archived);
CREATE INDEX idx_waiting_for_resolved ON waiting_for(is_resolved);
```

#### **Index composites pour requêtes spécifiques**

```sql
-- Requête : Actions à faire par utilisateur et contexte
CREATE INDEX idx_actions_user_status_context 
ON actions(user_id, status, context_id);

-- Requête : Projets actifs d'un utilisateur
CREATE INDEX idx_projects_user_archived_status 
ON projects(user_id, is_archived, status);

-- Requête : Actions avec échéance
CREATE INDEX idx_actions_user_duedate 
ON actions(user_id, due_date) 
WHERE due_date IS NOT NULL;  -- Index partiel (PostgreSQL)
```

#### **Index pour les recherches textuelles**

```sql
-- Recherche dans les titres et descriptions
CREATE FULLTEXT INDEX idx_resources_search 
ON resources(title, description, content);

-- Utilisation
SELECT * FROM resources 
WHERE MATCH(title, description, content) 
AGAINST('SQL performance optimization' IN NATURAL LANGUAGE MODE);
```

### 2.6 Maintenance des index

#### **Analyser l'utilisation des index**

```sql
-- MySQL : Vérifier les index inutilisés
SELECT 
    s.table_name,
    s.index_name,
    s.rows_read,
    s.rows_inserted,
    s.rows_updated,
    s.rows_deleted
FROM performance_schema.table_io_waits_summary_by_index_usage s
WHERE s.index_name IS NOT NULL
  AND s.table_schema = 'second_brain_db'
ORDER BY s.rows_read ASC;
```

#### **Supprimer les index inutilisés**

```sql
-- Si un index n'est jamais utilisé après plusieurs semaines
DROP INDEX idx_unused ON actions;
```

#### **Reconstruire les index fragmentés**

```sql
-- MySQL
OPTIMIZE TABLE actions;

-- PostgreSQL
REINDEX TABLE actions;
```

### 2.7 Exercice pratique : Optimiser une requête lente

**Problème :** Cette requête est lente (500ms pour 100,000 actions)

```sql
SELECT 
    u.name AS utilisateur,
    COUNT(*) AS actions_en_retard
FROM users u
JOIN actions a ON u.id = a.user_id
WHERE a.status != 'done'
  AND a.due_date < CURDATE()
GROUP BY u.id, u.name
HAVING COUNT(*) > 0;
```

**Étape 1 : Analyser avec EXPLAIN**

```sql
EXPLAIN SELECT ...;
```

**Étape 2 : Identifier les problèmes**
- Table scan sur `actions` (type: ALL)
- Pas d'index sur `due_date`
- Pas d'index sur `status`

**Étape 3 : Créer les index appropriés**

```sql
-- Index composite pour le filtre
CREATE INDEX idx_actions_status_duedate 
ON actions(status, due_date);

-- Ou index partiel (PostgreSQL) pour exclure les actions terminées
CREATE INDEX idx_actions_pending_duedate 
ON actions(due_date) 
WHERE status != 'done';
```

**Étape 4 : Vérifier l'amélioration**

```sql
EXPLAIN SELECT ...;
-- Nouveau temps : 15ms (33x plus rapide !)
```

---

## 3. Les vues : simplification et optimisation

### 3.1 Qu'est-ce qu'une vue ?

Une **vue** est une requête SQL stockée qui se comporte comme une table virtuelle.

**Avantages :**
- ✅ Simplifie les requêtes complexes
- ✅ Encapsule la logique métier
- ✅ Améliore la sécurité (masque certaines colonnes)
- ✅ Facilite la maintenance (un seul endroit à modifier)

**Inconvénient :**
- ⚠️ Performance variable selon le type de vue

### 3.2 Création de vues simples

#### **Exemple 1 : Vue des actions actives**

```sql
-- Créer la vue
CREATE VIEW v_actions_actives AS
SELECT 
    a.id,
    a.title,
    a.status,
    a.due_date,
    u.name AS utilisateur,
    c.name AS contexte,
    p.title AS projet
FROM actions a
JOIN users u ON a.user_id = u.id
JOIN contexts c ON a.context_id = c.id
LEFT JOIN projects p ON a.project_id = p.id
WHERE a.status IN ('todo', 'in_progress');

-- Utiliser la vue (comme une table)
SELECT * FROM v_actions_actives 
WHERE contexte = '@ordinateur'
ORDER BY due_date;
```

**Avantage :** Plus besoin de réécrire les jointures à chaque fois !

#### **Exemple 2 : Vue du tableau de bord utilisateur**

```sql
CREATE VIEW v_dashboard_utilisateur AS
SELECT 
    u.id AS user_id,
    u.name AS utilisateur,
    COUNT(DISTINCT p.id) AS projets_actifs,
    COUNT(DISTINCT CASE WHEN a.status = 'todo' THEN a.id END) AS actions_a_faire,
    COUNT(DISTINCT CASE WHEN a.status = 'in_progress' THEN a.id END) AS actions_en_cours,
    COUNT(DISTINCT CASE WHEN w.is_resolved = FALSE THEN w.id END) AS en_attente,
    COUNT(DISTINCT CASE WHEN s.is_activated = FALSE THEN s.id END) AS idees_someday
FROM users u
LEFT JOIN projects p ON u.id = p.user_id AND p.is_archived = FALSE
LEFT JOIN actions a ON u.id = a.user_id
LEFT JOIN waiting_for w ON u.id = w.user_id
LEFT JOIN someday_maybe s ON u.id = s.user_id
GROUP BY u.id, u.name;

-- Utilisation
SELECT * FROM v_dashboard_utilisateur WHERE user_id = 1;
```

### 3.3 Types de vues et leur performance

#### **3.3.1 Vues simples (MERGE)**

Le SGBD **fusionne** la requête de la vue avec votre requête.

```sql
CREATE VIEW v_projets_actifs AS
SELECT * FROM projects WHERE is_archived = FALSE;

-- Requête
SELECT * FROM v_projets_actifs WHERE user_id = 1;

-- Exécutée comme :
SELECT * FROM projects WHERE is_archived = FALSE AND user_id = 1;
```

**Performance :** ✅ Excellente (pas de surcoût)

#### **3.3.2 Vues complexes (TEMPTABLE)**

Le SGBD crée une **table temporaire** avec les résultats de la vue.

```sql
CREATE VIEW v_stats_projets AS
SELECT 
    p.id,
    p.title,
    COUNT(a.id) AS nb_actions,
    AVG(a.estimated_minutes) AS duree_moyenne
FROM projects p
LEFT JOIN actions a ON p.id = a.project_id
GROUP BY p.id, p.title;

-- Requête
SELECT * FROM v_stats_projets WHERE nb_actions > 5;
```

**Performance :** ⚠️ Moyenne (table temporaire créée à chaque appel)

### 3.4 Optimisation des vues

#### **Technique 1 : Utiliser des index sur les tables sous-jacentes**

```sql
-- Vue
CREATE VIEW v_actions_par_contexte AS
SELECT c.name, a.title, a.status
FROM actions a
JOIN contexts c ON a.context_id = c.id;

-- Optimisation : Index sur la clé de jointure
CREATE INDEX idx_actions_context ON actions(context_id);
```

#### **Technique 2 : Limiter les colonnes dans la vue**

```sql
-- ❌ Mauvais : Sélectionne toutes les colonnes
CREATE VIEW v_actions_bad AS
SELECT a.*, u.*, c.*, p.*
FROM actions a
JOIN users u ON a.user_id = u.id
JOIN contexts c ON a.context_id = c.id
LEFT JOIN projects p ON a.project_id = p.id;

-- ✅ Bon : Sélectionne uniquement les colonnes nécessaires
CREATE VIEW v_actions_good AS
SELECT 
    a.id,
    a.title,
    a.status,
    u.name AS user_name,
    c.name AS context_name,
    p.title AS project_title
FROM actions a
JOIN users u ON a.user_id = u.id
JOIN contexts c ON a.context_id = c.id
LEFT JOIN projects p ON a.project_id = p.id;
```

#### **Technique 3 : Éviter les agrégations dans les vues si possible**

```sql
-- ❌ Vue avec agrégation (recalculée à chaque appel)
CREATE VIEW v_stats_users AS
SELECT 
    user_id,
    COUNT(*) AS total_actions,
    SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END) AS done_count
FROM actions
GROUP BY user_id;

-- ✅ Meilleure approche : Vue matérialisée (voir section suivante)
```

### 3.5 Vues avec options (MySQL)

```sql
-- Vue avec algorithme spécifié
CREATE ALGORITHM=MERGE VIEW v_projets_actifs AS
SELECT * FROM projects WHERE is_archived = FALSE;

-- Vue avec vérification de sécurité
CREATE VIEW v_actions_publiques AS
SELECT id, title, status FROM actions
WHERE user_id = CURRENT_USER_ID()
WITH CHECK OPTION;  -- Empêche les INSERT/UPDATE qui violent la condition WHERE
```

### 3.6 Cas pratiques : Vues pour Second Brain

#### **Vue 1 : Actions du jour**

```sql
CREATE VIEW v_actions_aujourdhui AS
SELECT 
    a.id,
    a.title,
    a.estimated_minutes,
    a.energy_level,
    c.name AS contexte,
    c.icon,
    p.title AS projet,
    ar.title AS domaine,
    CASE 
        WHEN a.due_date = CURDATE() THEN 'Échéance aujourd''hui'
        WHEN a.due_date < CURDATE() THEN 'En retard'
        ELSE 'À faire'
    END AS urgence
FROM actions a
JOIN users u ON a.user_id = u.id
JOIN contexts c ON a.context_id = c.id
LEFT JOIN projects p ON a.project_id = p.id
LEFT JOIN areas ar ON a.area_id = ar.id
WHERE a.status IN ('todo', 'in_progress')
  AND (a.due_date <= CURDATE() OR a.due_date IS NULL);

-- Utilisation
SELECT * FROM v_actions_aujourdhui 
WHERE contexte = '@ordinateur' 
  AND energy_level = 'low'
ORDER BY urgence, estimated_minutes;
```

#### **Vue 2 : Progression des projets**

```sql
CREATE VIEW v_progression_projets AS
SELECT 
    p.id,
    p.title AS projet,
    p.deadline,
    p.status,
    ar.title AS domaine,
    COUNT(a.id) AS total_actions,
    SUM(CASE WHEN a.status = 'done' THEN 1 ELSE 0 END) AS actions_terminees,
    SUM(CASE WHEN a.status IN ('todo', 'in_progress') THEN 1 ELSE 0 END) AS actions_restantes,
    ROUND(
        COALESCE(
            SUM(CASE WHEN a.status = 'done' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(a.id), 0),
            0
        ),
        1
    ) AS pourcentage_completion,
    DATEDIFF(p.deadline, CURDATE()) AS jours_restants
FROM projects p
LEFT JOIN areas ar ON p.area_id = ar.id
LEFT JOIN actions a ON p.id = a.project_id
WHERE p.is_archived = FALSE
GROUP BY p.id, p.title, p.deadline, p.status, ar.title;

-- Utilisation
SELECT * FROM v_progression_projets 
WHERE jours_restants < 30 
  AND pourcentage_completion < 50
ORDER BY jours_restants;
```

#### **Vue 3 : Revue hebdomadaire GTD**

```sql
CREATE VIEW v_revue_hebdomadaire AS
SELECT 
    'Projets sans prochaine action' AS alerte,
    p.title AS element,
    NULL AS details
FROM projects p
LEFT JOIN actions a ON p.id = a.project_id AND a.status IN ('todo', 'in_progress')
WHERE p.is_archived = FALSE 
  AND p.status IN ('not_started', 'in_progress')
  AND a.id IS NULL

UNION ALL

SELECT 
    'En attente depuis > 7 jours',
    w.title,
    CONCAT('Personne: ', w.waiting_on_person, ' - ', DATEDIFF(CURDATE(), w.created_at), ' jours')
FROM waiting_for w
WHERE w.is_resolved = FALSE 
  AND DATEDIFF(CURDATE(), w.created_at) > 7

UNION ALL

SELECT 
    'Actions en retard',
    a.title,
    CONCAT('Retard: ', DATEDIFF(CURDATE(), a.due_date), ' jours')
FROM actions a
WHERE a.status != 'done' 
  AND a.due_date < CURDATE();

-- Utilisation (pour la revue hebdomadaire)
SELECT * FROM v_revue_hebdomadaire 
WHERE element LIKE '%user_id = 1%'  -- Filtrer par utilisateur
ORDER BY alerte;
```

### 3.7 Modifier et supprimer des vues

```sql
-- Modifier une vue
CREATE OR REPLACE VIEW v_actions_actives AS
SELECT 
    a.id,
    a.title,
    a.status,
    -- Nouvelles colonnes ajoutées
    a.energy_level,
    a.estimated_minutes
FROM actions a
WHERE a.status IN ('todo', 'in_progress');

-- Supprimer une vue
DROP VIEW IF EXISTS v_actions_actives;
```

### 3.8 Vues vs Requêtes : Quand utiliser quoi ?

| Critère | Vue | Requête directe |
|---------|-----|-----------------|
| **Réutilisation** | ✅ Excellente | ❌ Duplication de code |
| **Maintenance** | ✅ Centralisée | ❌ Modifications multiples |
| **Performance** | ⚠️ Variable | ✅ Contrôle total |
| **Flexibilité** | ⚠️ Limitée | ✅ Totale |
| **Sécurité** | ✅ Masquage de colonnes | ❌ Accès direct |

**Recommandation :**
- Utilisez des **vues** pour les requêtes fréquentes et complexes
- Utilisez des **requêtes directes** pour les cas spécifiques et les performances critiques

---

## 4. Aller plus loin : Optimisations avancées

Cette section présente des techniques d'optimisation avancées pour les bases de données à grande échelle. Ces concepts sont présentés de manière vulgarisée pour faciliter la compréhension.

### 4.1 Vues matérialisées (Materialized Views)

#### **Qu'est-ce qu'une vue matérialisée ?**

Une **vue matérialisée** est une vue dont les résultats sont **physiquement stockés** sur le disque, comme une table réelle.

**Différence avec une vue normale :**

| Vue normale | Vue matérialisée |
|-------------|------------------|
| Recalculée à chaque requête | Calculée une fois, stockée |
| Toujours à jour | Mise à jour manuelle ou planifiée |
| Lente pour agrégations complexes | Très rapide (lecture directe) |
| Pas d'espace disque | Consomme de l'espace disque |

#### **Quand utiliser une vue matérialisée ?**

✅ **Cas d'usage idéaux :**
- Rapports et tableaux de bord (données agrégées)
- Statistiques calculées rarement modifiées
- Requêtes complexes exécutées fréquemment
- Données historiques (snapshots)

❌ **À éviter si :**
- Les données changent constamment
- Vous avez besoin de données en temps réel
- L'espace disque est limité

#### **Exemple : Statistiques de productivité**

```sql
-- PostgreSQL : Créer une vue matérialisée
CREATE MATERIALIZED VIEW mv_stats_productivite AS
SELECT
    u.id AS user_id,
    u.name AS utilisateur,
    COUNT(DISTINCT p.id) AS total_projets,
    COUNT(DISTINCT a.id) AS total_actions,
    SUM(CASE WHEN a.status = 'done' THEN 1 ELSE 0 END) AS actions_terminees,
    SUM(CASE WHEN a.status = 'done' THEN a.estimated_minutes ELSE 0 END) AS minutes_productives,
    ROUND(
        SUM(CASE WHEN a.status = 'done' THEN 1 ELSE 0 END) * 100.0 /
        NULLIF(COUNT(a.id), 0),
        1
    ) AS taux_completion,
    MAX(a.completed_at) AS derniere_action_terminee
FROM users u
LEFT JOIN projects p ON u.id = p.user_id
LEFT JOIN actions a ON u.id = a.user_id
GROUP BY u.id, u.name;

-- Créer un index sur la vue matérialisée
CREATE INDEX idx_mv_stats_user ON mv_stats_productivite(user_id);

-- Utilisation (très rapide !)
SELECT * FROM mv_stats_productivite WHERE user_id = 1;
-- Temps : 0.5ms (vs 150ms pour la vue normale)
```

#### **Rafraîchissement des vues matérialisées**

```sql
-- PostgreSQL : Rafraîchir manuellement
REFRESH MATERIALIZED VIEW mv_stats_productivite;

-- Rafraîchir sans bloquer les lectures (PostgreSQL 9.4+)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_stats_productivite;

-- MySQL : Pas de support natif, mais on peut simuler avec une table
-- 1. Créer une table
CREATE TABLE mv_stats_productivite AS
SELECT ... (même requête);

-- 2. Rafraîchir via un script ou un événement planifié
TRUNCATE TABLE mv_stats_productivite;
INSERT INTO mv_stats_productivite SELECT ...;
```

#### **Automatisation du rafraîchissement**

```sql
-- PostgreSQL : Utiliser pg_cron (extension)
SELECT cron.schedule('refresh-stats', '0 2 * * *',
    'REFRESH MATERIALIZED VIEW CONCURRENTLY mv_stats_productivite');
-- Rafraîchit tous les jours à 2h du matin

-- MySQL : Utiliser un événement planifié
CREATE EVENT refresh_stats
ON SCHEDULE EVERY 1 DAY
STARTS '2025-01-01 02:00:00'
DO
BEGIN
    TRUNCATE TABLE mv_stats_productivite;
    INSERT INTO mv_stats_productivite SELECT ...;
END;
```

#### **Cas pratique : Dashboard temps réel vs historique**

```sql
-- Vue matérialisée pour l'historique (rafraîchie quotidiennement)
CREATE MATERIALIZED VIEW mv_historique_quotidien AS
SELECT
    DATE(a.completed_at) AS date,
    u.id AS user_id,
    COUNT(*) AS actions_terminees,
    SUM(a.estimated_minutes) AS minutes_travaillees
FROM actions a
JOIN users u ON a.user_id = u.id
WHERE a.status = 'done'
GROUP BY DATE(a.completed_at), u.id;

-- Vue normale pour les données du jour (temps réel)
CREATE VIEW v_stats_aujourdhui AS
SELECT
    u.id AS user_id,
    COUNT(*) AS actions_terminees,
    SUM(a.estimated_minutes) AS minutes_travaillees
FROM actions a
JOIN users u ON a.user_id = u.id
WHERE a.status = 'done'
  AND DATE(a.completed_at) = CURDATE()
GROUP BY u.id;

-- Requête combinée : historique + aujourd'hui
SELECT * FROM mv_historique_quotidien WHERE date < CURDATE()
UNION ALL
SELECT CURDATE(), * FROM v_stats_aujourdhui;
```

### 4.2 Partitionnement (Partitioning)

#### **Qu'est-ce que le partitionnement ?**

Le **partitionnement** consiste à diviser une grande table en plusieurs sous-tables (partitions) plus petites, tout en conservant une interface unique.

**Analogie :** Comme ranger des documents dans plusieurs classeurs par année, au lieu d'un seul énorme classeur.

#### **Types de partitionnement**

**1. Partitionnement par plage (RANGE)**

Divise les données selon une plage de valeurs (dates, IDs).

```sql
-- PostgreSQL : Partitionner les actions par année
CREATE TABLE actions (
    id SERIAL,
    user_id INT,
    title VARCHAR(255),
    created_at TIMESTAMP,
    ...
) PARTITION BY RANGE (created_at);

-- Créer les partitions
CREATE TABLE actions_2023 PARTITION OF actions
    FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

CREATE TABLE actions_2024 PARTITION OF actions
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE actions_2025 PARTITION OF actions
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
```

**2. Partitionnement par liste (LIST)**

Divise selon des valeurs discrètes.

```sql
-- Partitionner par statut
CREATE TABLE actions (
    ...
) PARTITION BY LIST (status);

CREATE TABLE actions_todo PARTITION OF actions
    FOR VALUES IN ('todo');

CREATE TABLE actions_done PARTITION OF actions
    FOR VALUES IN ('done');

CREATE TABLE actions_other PARTITION OF actions
    FOR VALUES IN ('in_progress', 'cancelled');
```

**3. Partitionnement par hachage (HASH)**

Distribue uniformément les données.

```sql
-- Partitionner par user_id (4 partitions)
CREATE TABLE actions (
    ...
) PARTITION BY HASH (user_id);

CREATE TABLE actions_p0 PARTITION OF actions
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE actions_p1 PARTITION OF actions
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE actions_p2 PARTITION OF actions
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE actions_p3 PARTITION OF actions
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

#### **Avantages du partitionnement**

✅ **Performance :** Requêtes plus rapides (scan de partitions spécifiques)
✅ **Maintenance :** Archivage facile (supprimer une partition entière)
✅ **Scalabilité :** Gestion de tables massives (milliards de lignes)
✅ **Parallélisme :** Requêtes parallèles sur plusieurs partitions

#### **Exemple : Archivage automatique avec partitionnement**

```sql
-- Supprimer les actions de 2022 (instantané)
DROP TABLE actions_2022;

-- Sans partitionnement, il faudrait :
DELETE FROM actions WHERE YEAR(created_at) = 2022;
-- Très lent sur une grande table !
```

#### **Cas pratique : Partitionner les notes par utilisateur**

```sql
-- Utile si certains utilisateurs ont des milliers de notes
CREATE TABLE notes (
    id SERIAL,
    user_id INT,
    content TEXT,
    created_at TIMESTAMP
) PARTITION BY HASH (user_id);

-- Créer 8 partitions pour distribuer la charge
CREATE TABLE notes_p0 PARTITION OF notes FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE notes_p1 PARTITION OF notes FOR VALUES WITH (MODULUS 8, REMAINDER 1);
-- ... jusqu'à notes_p7

-- Les requêtes restent identiques
SELECT * FROM notes WHERE user_id = 1;
-- PostgreSQL scanne automatiquement la bonne partition
```

### 4.3 Sharding (Partitionnement horizontal distribué)

#### **Qu'est-ce que le sharding ?**

Le **sharding** est une technique de partitionnement où les données sont réparties sur **plusieurs serveurs** (shards).

**Différence avec le partitionnement :**
- **Partitionnement** : Plusieurs tables sur un seul serveur
- **Sharding** : Plusieurs serveurs, chacun avec une partie des données

**Analogie :** Au lieu d'un seul entrepôt avec plusieurs rayons, vous avez plusieurs entrepôts dans différentes villes.

#### **Architecture de sharding**

```
                    ┌─────────────────┐
                    │  Application    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Shard Router   │ ← Dirige les requêtes
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐          ┌────▼────┐         ┌────▼────┐
   │ Shard 1 │          │ Shard 2 │         │ Shard 3 │
   │ Users   │          │ Users   │         │ Users   │
   │ 1-1000  │          │1001-2000│         │2001-3000│
   └─────────┘          └─────────┘         └─────────┘
```

#### **Stratégies de sharding**

**1. Sharding par clé (Key-based)**

```sql
-- Fonction de hachage : user_id % 3
-- User 1 → Shard 1
-- User 2 → Shard 2
-- User 3 → Shard 3
-- User 4 → Shard 1
-- ...
```

**2. Sharding par plage (Range-based)**

```sql
-- Shard 1 : user_id 1-1000
-- Shard 2 : user_id 1001-2000
-- Shard 3 : user_id 2001-3000
```

**3. Sharding géographique**

```sql
-- Shard EU : Utilisateurs européens
-- Shard US : Utilisateurs américains
-- Shard ASIA : Utilisateurs asiatiques
```

#### **Avantages et inconvénients**

✅ **Avantages :**
- Scalabilité horizontale illimitée
- Isolation des pannes (un shard down ≠ tout le système down)
- Performance (charge distribuée)

❌ **Inconvénients :**
- Complexité accrue (gestion de plusieurs bases)
- Jointures cross-shard difficiles
- Transactions distribuées complexes
- Rééquilibrage coûteux (ajout/suppression de shards)

#### **Quand utiliser le sharding ?**

✅ **Utilisez le sharding si :**
- Vous avez des millions d'utilisateurs
- Une seule base ne suffit plus (> 1 To de données)
- Vous avez besoin de haute disponibilité

❌ **Évitez le sharding si :**
- Vous avez < 100,000 utilisateurs
- Le partitionnement simple suffit
- Votre équipe n'a pas l'expertise

#### **Exemple simplifié : Sharding de Second Brain**

```sql
-- Shard 1 (serveur db1.example.com)
CREATE DATABASE second_brain_shard1;
-- Contient les données des users 1-1000

-- Shard 2 (serveur db2.example.com)
CREATE DATABASE second_brain_shard2;
-- Contient les données des users 1001-2000

-- Application : Router les requêtes
function getShardForUser(userId) {
    if (userId <= 1000) return 'db1.example.com';
    if (userId <= 2000) return 'db2.example.com';
    // ...
}

// Requête
const shard = getShardForUser(userId);
const connection = connectToDatabase(shard);
const actions = connection.query('SELECT * FROM actions WHERE user_id = ?', [userId]);
```

### 4.4 Procédures stockées (Stored Procedures)

#### **Qu'est-ce qu'une procédure stockée ?**

Une **procédure stockée** est un ensemble d'instructions SQL précompilées et stockées dans la base de données.

**Avantages :**
✅ Performance (précompilée, pas de parsing répété)
✅ Sécurité (encapsulation de la logique)
✅ Réduction du trafic réseau (logique côté serveur)
✅ Réutilisabilité (appelée depuis plusieurs applications)

#### **Exemple 1 : Procédure pour archiver un projet**

```sql
-- MySQL
DELIMITER //

CREATE PROCEDURE sp_archiver_projet(
    IN p_project_id INT,
    IN p_user_id INT
)
BEGIN
    -- Vérifier que le projet appartient à l'utilisateur
    DECLARE v_count INT;

    SELECT COUNT(*) INTO v_count
    FROM projects
    WHERE id = p_project_id AND user_id = p_user_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Projet non trouvé ou accès refusé';
    END IF;

    -- Archiver le projet
    UPDATE projects
    SET is_archived = TRUE, status = 'completed', updated_at = NOW()
    WHERE id = p_project_id;

    -- Marquer toutes les actions comme terminées
    UPDATE actions
    SET status = 'done', updated_at = NOW()
    WHERE project_id = p_project_id AND status != 'done';

    -- Retourner un message de succès
    SELECT CONCAT('Projet ', p_project_id, ' archivé avec succès') AS message;
END //

DELIMITER ;

-- Utilisation
CALL sp_archiver_projet(5, 1);
```

#### **Exemple 2 : Procédure pour la revue hebdomadaire**

```sql
DELIMITER //

CREATE PROCEDURE sp_revue_hebdomadaire(IN p_user_id INT)
BEGIN
    -- 1. Projets sans prochaine action
    SELECT
        'ALERTE: Projet sans action' AS type,
        p.title AS element,
        p.deadline AS info
    FROM projects p
    LEFT JOIN actions a ON p.id = a.project_id AND a.status IN ('todo', 'in_progress')
    WHERE p.user_id = p_user_id
      AND p.is_archived = FALSE
      AND a.id IS NULL

    UNION ALL

    -- 2. Actions en retard
    SELECT
        'ALERTE: Action en retard',
        a.title,
        CONCAT(DATEDIFF(CURDATE(), a.due_date), ' jours de retard')
    FROM actions a
    WHERE a.user_id = p_user_id
      AND a.status != 'done'
      AND a.due_date < CURDATE()

    UNION ALL

    -- 3. Éléments en attente depuis longtemps
    SELECT
        'ALERTE: En attente > 7 jours',
        w.title,
        CONCAT('Personne: ', w.waiting_on_person)
    FROM waiting_for w
    WHERE w.user_id = p_user_id
      AND w.is_resolved = FALSE
      AND DATEDIFF(CURDATE(), w.created_at) > 7;
END //

DELIMITER ;

-- Utilisation
CALL sp_revue_hebdomadaire(1);
```

#### **Exemple 3 : Fonction pour calculer la productivité**

```sql
DELIMITER //

CREATE FUNCTION fn_taux_completion_projet(p_project_id INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;
    DECLARE v_done INT;
    DECLARE v_taux DECIMAL(5,2);

    SELECT
        COUNT(*),
        SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END)
    INTO v_total, v_done
    FROM actions
    WHERE project_id = p_project_id;

    IF v_total = 0 THEN
        RETURN 0;
    END IF;

    SET v_taux = (v_done * 100.0) / v_total;
    RETURN v_taux;
END //

DELIMITER ;

-- Utilisation
SELECT
    title,
    fn_taux_completion_projet(id) AS completion
FROM projects
WHERE user_id = 1;
```

### 4.5 Triggers (Déclencheurs)

#### **Qu'est-ce qu'un trigger ?**

Un **trigger** est une procédure qui s'exécute **automatiquement** en réponse à un événement (INSERT, UPDATE, DELETE).

**Cas d'usage :**
- Audit et traçabilité
- Validation de données complexes
- Mise à jour automatique de champs calculés
- Synchronisation entre tables

#### **Exemple 1 : Audit automatique des modifications**

```sql
-- Table d'audit
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50),
    action VARCHAR(10),
    record_id INT,
    user_id INT,
    old_values JSON,
    new_values JSON,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger sur UPDATE de projects
DELIMITER //

CREATE TRIGGER trg_audit_projects_update
AFTER UPDATE ON projects
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, record_id, user_id, old_values, new_values)
    VALUES (
        'projects',
        'UPDATE',
        NEW.id,
        NEW.user_id,
        JSON_OBJECT(
            'title', OLD.title,
            'status', OLD.status,
            'deadline', OLD.deadline
        ),
        JSON_OBJECT(
            'title', NEW.title,
            'status', NEW.status,
            'deadline', NEW.deadline
        )
    );
END //

DELIMITER ;
```

#### **Exemple 2 : Mise à jour automatique de timestamps**

```sql
-- Trigger pour updated_at
DELIMITER //

CREATE TRIGGER trg_actions_before_update
BEFORE UPDATE ON actions
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;

    -- Si l'action passe à "done", enregistrer la date de complétion
    IF NEW.status = 'done' AND OLD.status != 'done' THEN
        SET NEW.completed_at = CURRENT_TIMESTAMP;
    END IF;
END //

DELIMITER ;
```

#### **Exemple 3 : Validation métier avec trigger**

```sql
-- Empêcher l'archivage d'un projet avec des actions actives
DELIMITER //

CREATE TRIGGER trg_projects_before_update
BEFORE UPDATE ON projects
FOR EACH ROW
BEGIN
    DECLARE v_active_actions INT;

    -- Si on essaie d'archiver le projet
    IF NEW.is_archived = TRUE AND OLD.is_archived = FALSE THEN
        -- Compter les actions actives
        SELECT COUNT(*) INTO v_active_actions
        FROM actions
        WHERE project_id = NEW.id
          AND status IN ('todo', 'in_progress');

        -- Bloquer si des actions sont actives
        IF v_active_actions > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Impossible d''archiver : le projet a des actions actives';
        END IF;
    END IF;
END //

DELIMITER ;
```

### 4.6 Réplication et haute disponibilité

#### **Qu'est-ce que la réplication ?**

La **réplication** consiste à maintenir des copies synchronisées de la base de données sur plusieurs serveurs.

**Architecture Master-Slave :**

```
                    ┌──────────────┐
                    │   Master     │ ← Écritures (INSERT, UPDATE, DELETE)
                    │  (Primary)   │
                    └──────┬───────┘
                           │
                    Réplication
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐        ┌────▼────┐       ┌────▼────┐
   │ Slave 1 │        │ Slave 2 │       │ Slave 3 │
   │(Replica)│        │(Replica)│       │(Replica)│
   └─────────┘        └─────────┘       └─────────┘
        ↑                  ↑                  ↑
     Lectures          Lectures           Lectures
```

**Avantages :**
✅ **Haute disponibilité** : Si le master tombe, un slave peut prendre le relais
✅ **Scalabilité en lecture** : Distribuer les SELECT sur plusieurs slaves
✅ **Backup** : Sauvegardes sans impacter le master
✅ **Analyse** : Requêtes lourdes sur un slave dédié

#### **Configuration simple (MySQL)**

```sql
-- Sur le Master
-- 1. Activer le binlog dans my.cnf
[mysqld]
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = second_brain_db

-- 2. Créer un utilisateur de réplication
CREATE USER 'replicator'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';

-- 3. Obtenir la position du binlog
SHOW MASTER STATUS;
-- Notez File et Position

-- Sur le Slave
-- 1. Configurer my.cnf
[mysqld]
server-id = 2
relay-log = /var/log/mysql/mysql-relay-bin
log_bin = /var/log/mysql/mysql-bin.log
read_only = 1

-- 2. Configurer la réplication
CHANGE MASTER TO
    MASTER_HOST='master-ip',
    MASTER_USER='replicator',
    MASTER_PASSWORD='password',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=12345;

-- 3. Démarrer la réplication
START SLAVE;

-- 4. Vérifier le statut
SHOW SLAVE STATUS\G
```

#### **Utilisation dans l'application**

```javascript
// Connexion au master pour les écritures
const masterConnection = mysql.createConnection({
    host: 'master.db.example.com',
    user: 'app',
    password: 'password',
    database: 'second_brain_db'
});

// Connexion aux slaves pour les lectures
const slaveConnections = [
    mysql.createConnection({ host: 'slave1.db.example.com', ... }),
    mysql.createConnection({ host: 'slave2.db.example.com', ... })
];

// Fonction pour obtenir un slave aléatoire (load balancing)
function getSlaveConnection() {
    return slaveConnections[Math.floor(Math.random() * slaveConnections.length)];
}

// Écriture → Master
masterConnection.query('INSERT INTO actions (...) VALUES (...)', callback);

// Lecture → Slave
getSlaveConnection().query('SELECT * FROM actions WHERE user_id = ?', [1], callback);
```

### 4.7 Cache et optimisation applicative

#### **Mise en cache des requêtes fréquentes**

```javascript
// Exemple avec Redis
const redis = require('redis');
const client = redis.createClient();

async function getActionsUtilisateur(userId) {
    const cacheKey = `actions:user:${userId}`;

    // 1. Vérifier le cache
    const cached = await client.get(cacheKey);
    if (cached) {
        console.log('Cache HIT');
        return JSON.parse(cached);
    }

    // 2. Si pas en cache, requête DB
    console.log('Cache MISS');
    const actions = await db.query(
        'SELECT * FROM actions WHERE user_id = ? AND status = "todo"',
        [userId]
    );

    // 3. Mettre en cache (expire après 5 minutes)
    await client.setex(cacheKey, 300, JSON.stringify(actions));

    return actions;
}
```

#### **Invalidation du cache**

```javascript
// Invalider le cache lors d'une modification
async function updateAction(actionId, newStatus) {
    // 1. Mettre à jour la DB
    const result = await db.query(
        'UPDATE actions SET status = ? WHERE id = ?',
        [newStatus, actionId]
    );

    // 2. Récupérer le user_id de l'action
    const action = await db.query('SELECT user_id FROM actions WHERE id = ?', [actionId]);

    // 3. Invalider le cache de cet utilisateur
    await client.del(`actions:user:${action.user_id}`);

    return result;
}
```

### 4.8 Monitoring et alertes

#### **Métriques à surveiller**

```sql
-- 1. Requêtes lentes (MySQL)
-- Activer le slow query log dans my.cnf
[mysqld]
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2  -- Requêtes > 2 secondes

-- Analyser les requêtes lentes
SELECT
    query_time,
    lock_time,
    rows_examined,
    sql_text
FROM mysql.slow_log
ORDER BY query_time DESC
LIMIT 10;

-- 2. Utilisation des index
SELECT
    table_name,
    index_name,
    cardinality,
    seq_in_index
FROM information_schema.statistics
WHERE table_schema = 'second_brain_db'
ORDER BY table_name, index_name;

-- 3. Taille des tables
SELECT
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS size_mb,
    table_rows
FROM information_schema.tables
WHERE table_schema = 'second_brain_db'
ORDER BY (data_length + index_length) DESC;
```

#### **Alertes automatiques**

```sql
-- Créer une procédure de monitoring
DELIMITER //

CREATE PROCEDURE sp_check_health()
BEGIN
    DECLARE v_slow_queries INT;
    DECLARE v_large_tables INT;

    -- Compter les requêtes lentes (dernière heure)
    SELECT COUNT(*) INTO v_slow_queries
    FROM mysql.slow_log
    WHERE start_time > DATE_SUB(NOW(), INTERVAL 1 HOUR);

    -- Compter les tables > 1 GB
    SELECT COUNT(*) INTO v_large_tables
    FROM information_schema.tables
    WHERE table_schema = 'second_brain_db'
      AND (data_length + index_length) > 1073741824;

    -- Alertes
    IF v_slow_queries > 100 THEN
        SELECT 'ALERTE: Plus de 100 requêtes lentes dans la dernière heure' AS message;
    END IF;

    IF v_large_tables > 0 THEN
        SELECT CONCAT('ALERTE: ', v_large_tables, ' table(s) > 1 GB') AS message;
    END IF;
END //

DELIMITER ;

-- Planifier l'exécution toutes les heures
CREATE EVENT evt_check_health
ON SCHEDULE EVERY 1 HOUR
DO CALL sp_check_health();
```

---

## 5. Récapitulatif et bonnes pratiques

### 5.1 Checklist d'optimisation

Lorsque vous optimisez une base de données, suivez cette checklist :

#### **Phase 1 : Analyse**
- [ ] Identifier les requêtes lentes avec EXPLAIN
- [ ] Analyser les logs de requêtes lentes
- [ ] Mesurer les temps de réponse actuels

#### **Phase 2 : Index**
- [ ] Créer des index sur les colonnes de filtrage (WHERE)
- [ ] Créer des index sur les colonnes de jointure (JOIN)
- [ ] Créer des index sur les colonnes de tri (ORDER BY)
- [ ] Vérifier l'utilisation des index avec EXPLAIN
- [ ] Supprimer les index inutilisés

#### **Phase 3 : Requêtes**
- [ ] Éviter SELECT * (sélectionner uniquement les colonnes nécessaires)
- [ ] Utiliser LIMIT pour les grandes tables
- [ ] Optimiser les jointures (ordre des tables)
- [ ] Éviter les sous-requêtes corrélées si possible

#### **Phase 4 : Structure**
- [ ] Normaliser les tables (éviter la redondance)
- [ ] Dénormaliser si nécessaire (pour la performance)
- [ ] Utiliser les bons types de données (INT vs BIGINT, VARCHAR vs TEXT)
- [ ] Partitionner les grandes tables (> 10 millions de lignes)

#### **Phase 5 : Avancé**
- [ ] Créer des vues matérialisées pour les agrégations
- [ ] Implémenter un cache applicatif (Redis, Memcached)
- [ ] Configurer la réplication pour la scalabilité
- [ ] Monitorer les performances en continu

### 5.2 Règles d'or de l'optimisation

1. **Mesurez avant d'optimiser** : "Premature optimization is the root of all evil"
2. **Optimisez les 20% qui comptent** : Principe de Pareto (80/20)
3. **Indexez intelligemment** : Trop d'index = ralentissement des écritures
4. **Pensez scalabilité** : Concevez pour la croissance future
5. **Documentez vos choix** : Expliquez pourquoi vous avez créé tel index
6. **Testez en production** : Les données de test ne reflètent pas la réalité
7. **Automatisez le monitoring** : Détectez les problèmes avant les utilisateurs

### 5.3 Outils recommandés

| Outil | Usage | Lien |
|-------|-------|------|
| **EXPLAIN** | Analyse de requêtes | Natif SQL |
| **pt-query-digest** | Analyse des slow logs | Percona Toolkit |
| **MySQLTuner** | Recommandations de configuration | GitHub |
| **pgBadger** | Analyse de logs PostgreSQL | pgBadger.darold.net |
| **Redis** | Cache applicatif | redis.io |
| **Grafana + Prometheus** | Monitoring visuel | grafana.com |
| **New Relic / Datadog** | APM (Application Performance Monitoring) | Commercial |

### 5.4 Ressources pour aller plus loin

**Livres :**
- "High Performance MySQL" par Baron Schwartz
- "PostgreSQL: Up and Running" par Regina Obe
- "Database Internals" par Alex Petrov

**Sites web :**
- Use The Index, Luke : https://use-the-index-luke.com/
- PostgreSQL Performance : https://wiki.postgresql.org/wiki/Performance_Optimization
- MySQL Performance Blog : https://www.percona.com/blog/

**Cours en ligne :**
- "Database Systems" (CMU) : https://15445.courses.cs.cmu.edu/
- "SQL Performance Explained" : https://sql-performance-explained.com/

---

## Conclusion

L'optimisation des bases de données est un processus **itératif** et **continu**. Les techniques présentées dans ce chapitre vous donnent les outils pour :

1. **Diagnostiquer** les problèmes de performance avec EXPLAIN
2. **Résoudre** les problèmes avec des index appropriés
3. **Simplifier** les requêtes complexes avec des vues
4. **Anticiper** la croissance avec des techniques avancées

**Rappelez-vous :** Une base de données bien optimisée est la clé d'une application rapide et scalable. Investissez du temps dans l'optimisation dès le début, et votre application vous remerciera ! 🚀

---

**Exercice final :** Prenez la base de données Second Brain que vous avez créée, exécutez EXPLAIN sur vos requêtes les plus fréquentes, et identifiez 3 optimisations possibles. Implémentez-les et mesurez l'amélioration !

**Bon courage dans vos optimisations ! 💪**
