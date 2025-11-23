# Master ITI 1 : SGBD (Système de Gestion de Bases de Données)

| **Table des matières**                                                                               |
|------------------------------------------------------------------------------------------------------|
| [Sunopsis](#sunopsis)                                                                                |
| [Séance 1 - Fondamentaux & découverte des bases](#-séance-1---fondamentaux--découverte-des-bases-4h) |
| [Séance 2 - SQL de base : requêtes et relations](#-séance-2---sql-de-base--requêtes-et-relations-4h) |
| [Séance 3 - SQL avancé & bonnes pratiques](#-séance-3---sql-avancé--bonnes-pratiques-4h)             |
| [Séance 4 - NoSQL par l’exemple](#-séance-4---nosql-par-lexemple-4h)                                 |
| [Séance 5 - Mise en pratique](#-séance-5---mise-en-pratique-4h)                                      |

## 📚Sunopsis

Ce module de 20 heures a pour objectif de rendre les étudiants ingénieurs autonomes dans la compréhension et la
manipulation des systèmes de gestion de bases de données (SGBD). La démarche adoptée suit une progression volontairement
graduelle : partir des fondements théoriques, explorer des outils accessibles pour illustrer les concepts, puis
s’immerger dans des environnements professionnels avec SQL et NoSQL.

La structure retenue repose sur **cinq séances de quatre heures**, chacune construite autour d’un axe d’apprentissage
précis :

* **Séance 1** pose les bases. Les étudiants découvrent l’histoire des SGBD, les notions essentielles (tables, index,
  clés) et expérimentent la modélisation via un outil simple (Notion) avant de manipuler une première base PostgreSQL.
* **Séance 2** est consacrée aux requêtes SQL de base. L’accent est mis sur la pratique : écrire, exécuter et comprendre
  des requêtes simples, jusqu’à la mise en œuvre de jointures et d’agrégations.
* **Séance 3** approfondit les usages. Les étudiants découvrent les contraintes d’intégrité, les transactions et les
  mécanismes d’optimisation (index, analyse de plan d’exécution). Une ouverture sur des concepts avancés (
  partitionnement, vues matérialisées) vient élargir leur horizon.
* **Séance 4** introduit le monde du NoSQL. Après une présentation des différences fondamentales avec les bases
  relationnelles, un atelier pratique avec MongoDB leur permet de manipuler des documents JSON et d’expérimenter
  d’autres paradigmes de stockage.
* **Séance 5** clôture le parcours par un projet de synthèse. Les étudiants mettent en pratique les acquis en modélisant
  un cas d’usage concret, combinant relationnel et non relationnel. Une démonstration avec Firebase vient compléter
  l’expérience et ouvre la réflexion sur les choix technologiques.

L’ensemble du module vise à offrir une **vision équilibrée** : comprendre les principes théoriques, développer une
capacité de manipulation pratique, et surtout acquérir une autonomie suffisante pour choisir et utiliser un SGBD en
fonction des besoins d’un projet.

## 📅 Séance 1 — Fondamentaux & découverte des bases (4h)

🎯 Objectifs : comprendre ce qu’est un SGBD, pourquoi on en a besoin, et manipuler un premier modèle simple.

* **1h30 – Théorie introductive** ([support](./cours/1_1_fondamentaux.md))
    * Histoire des bases de données (fichiers plats → SGBDR → NoSQL).
    * Concepts clés : table, enregistrement, clé primaire, clé étrangère, index.
    * Vulgarisation du B-Tree (métaphore dictionnaire/annuaire).

* **1h – Atelier Notion** ([cheat sheet](./cours/1_2_cheat_sheet_notion.md))
    * Création de tables (étudiants, cours, professeurs).
    * Relations simples (1-n, n-n).

* **1h30 – Introduction au SQL (PostgreSQL via Metabase)** ([support](./cours/1_3_introduction_sql.md))
    * Installation guidée (ou VM/Docker prêt).
    * Création d’une base, d’une table simple, insertion de quelques données.

## 📅 Séance 2 — SQL de base : requêtes et relations (4h)

🎯 Objectifs : manipuler des données avec SQL, comprendre les jointures et les relations.

* **1h – Rappel et setup rapide** ([support](./cours/2_1_rappel_episodes_precedents.md))

    * Vérification environnement
    * Présentation du schéma relationnel de la base CRM ([documentation](./cours/2_2_shema_base_crm.md))

* **2h – Atelier SQL** ([exercices](./cours/2_3_exercices_crm.md))

    * SELECT simple.
    * WHERE, ORDER BY, LIMIT.
    * JOINS (INNER, LEFT, RIGHT).
    * GROUP BY, COUNT, AVG.
    * **Base de données utilisée** : `exemple_crm` (20 clients, 44 contacts, 50 meetings, 100 produits, 40 commandes, 15
      factures)

* **1h – Mini-projet**

    * Construire une petite base (étudiants/cours/notes).
    * Écrire des requêtes pour répondre à des questions métier (ex : “Quel étudiant a la meilleure moyenne ?”).

## 📅 Séance 3 — SQL avancé & bonnes pratiques (4h)

🎯 Objectifs : comprendre la robustesse des SGBDR, introduire les concepts de performance.

* **1h – Contraintes et intégrité**

    * PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL.
    * Transactions (BEGIN, COMMIT, ROLLBACK).

* **2h – Optimisation & performances**

    * Index (création, impact sur SELECT).
    * EXPLAIN et analyse de plan.
    * Cas concret : requête lente sans index → ajout d’index → gain visible.

* **1h – Ouverture “avancé” (en démo)**

    * Partitionnement / sharding (simple vulgarisation).
    * Vues matérialisées.

## 📅 Séance 4 — NoSQL par l’exemple (4h)

🎯 Objectifs : comprendre les différences fondamentales avec SQL, découvrir un outil moderne.

* **1h – Théorie NoSQL**

    * Pourquoi NoSQL ? (scalabilité, schéma flexible, big data).
    * BASE vs ACID.
    * Types : clé/valeur, document, graphe, colonne.

* **2h – Atelier MongoDB Atlas (ou Docker Mongo)**

    * Création d’une base et d’une collection.
    * Insertion de documents JSON.
    * Requêtes simples (find, filtres, agrégation basique).

* **1h – Comparaison avec SQL**

    * Requêter la même donnée en SQL et NoSQL.
    * Avantages / limites.

## 📅 Séance 5 — Mise en pratique (4h)

🎯 Objectifs : consolider les acquis, montrer les cas d’usage et ouvrir sur des problématiques réelles.

* **2025-2026**: [Grande Bibliothèque d'Alexandrie 2.0](./td/2025_2026_iti_1.md)
