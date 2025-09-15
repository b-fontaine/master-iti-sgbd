# 2. Fondations techniques des SGBD relationnels

Avant de pratiquer, il est crucial de comprendre les concepts techniques de base d’une base de données relationnelle,
ainsi que les structures de données sous le capot :

* **Tables, lignes et colonnes :** Une base relationnelle organise les données en tables (appelées aussi relations). Une
  table est un tableau à deux dimensions composé de lignes (enregistrements) et de colonnes (champs).
  Chaque table représente une entité (par ex. Clients, Produits, Commandes), chaque ligne correspond à une occurrence (
  un client donné, un produit donné, etc.) et chaque colonne représente un attribut élémentaire de l’entité (nom, date,
  prix, etc.). L’ensemble des tables et de leurs relations forme la base de données. Ce modèle tabulaire simple est
  l’héritier direct du travail de Codd en 1970.


* **Clés primaires et étrangères :** Pour identifier de manière unique chaque enregistrement, on définit une **clé
  primaire (PK)** sur chaque table (souvent un ID numérique auto-incrémenté ou un identifiant unique).
  Cette clé primaire sert de référence stable pour chaque ligne. Une **clé étrangère (FK)** est un champ dans une table
  qui fait référence à la PK d’une autre table.
  C’est ainsi que l’on crée des liens entre tables : par exemple, la table Commandes peut avoir une colonne client_id
  qui est une FK pointant vers le id du client dans la table Clients. Les clés étrangères garantissent **l’intégrité
  référentielle** : un enregistrement lié ne peut exister que si la référence existe dans la table cible (on ne peut pas
  avoir une commande assignée à un client inexistant). Elles permettent aussi d’exploiter la puissance des jointures
  SQL (voir partie SQL).

```mermaid
erDiagram
    CLIENT ||--o{ COMMANDE : passe
    COMMANDE }o--o{ LIGNE_COMMANDE : contient
    PRODUIT ||--o{ LIGNE_COMMANDE : concerne

    CLIENT {
      int id PK
      string nom
      string email UK
      string ville
    }
    COMMANDE {
      int id PK
      date date
      int client_id FK
      numeric total
    }
    LIGNE_COMMANDE {
      int commande_id FK
      int produit_id FK
      int quantite
    }
    PRODUIT {
      int id PK
      string libelle
      numeric prix
      int stock
    }

```

* **Index et B-arbres :** Pour accélérer la recherche des données, les SGBD utilisent des **index**, structures de
  données
  additionnelles qui fonctionnent comme des annuaires. Un index classique est implémenté sous forme d’**arbre B (B-Tree)**
  équilibré. Un arbre B est une structure arborescente multi-étages où chaque nœud peut contenir plusieurs clés triées
  et des pointeurs vers des nœuds enfants.Le « B » signifie généralement balanced (équilibré) : la hauteur de l’arbre est
  maintenue minimale grâce à un
  rééquilibrage automatique lors des insertions/suppressions, de sorte que les opérations de recherche s’exécutent en
  temps logarithmique. En pratique, cela signifie qu’avec un index B-Tree, trouver une ligne via sa clé (indexée) sera
  très rapide même
  dans une table contenant des millions de lignes, car le SGBD n’a pas à parcourir toute la table (recherche
  séquentielle) mais descend dans l’arbre en suivant les pointeurs.

```mermaid
flowchart TB
  subgraph "Index B-Tree (vue logique)"
    R(("Racine\n[17, 42]"))
    I1(("Intermédiaire\n[5, 11, 14]"))
    I2(("Intermédiaire\n[24, 29, 35]"))
    L1[["Feuille\n... 5 7 9 ..."]]
    L2[["Feuille\n... 11 13 ..."]]
    L3[["Feuille\n... 14 15 16 ..."]]
    L4[["Feuille\n... 24 26 ..."]]
    L5[["Feuille\n... 29 33 ..."]]
    L6[["Feuille\n... 35 40 ..."]]

    R -->|<17| I1
    R -->|>=17 & <42| I2
    I1 --> L1
    I1 --> L2
    I1 --> L3
    I2 --> L4
    I2 --> L5
    I2 --> L6
  end

```

> Exemple d’un index B-Tree équilibré (ici un arbre B d’ordre 5) : les clés sont stockées de manière triée dans les
> nœuds, ce qui permet de trouver rapidement la plage de valeurs recherchée en navigant de la racine vers les feuilles.

Un index agit comme une table des matières : il est redondant par rapport aux données brutes mais accélère grandement
les requêtes sur les colonnes indexées (en particulier pour les clauses WHERE et les jointures). **Attention toutefois :
**
indexer tout et n’importe quoi peut dégrader les performances en écriture (chaque insertion doit mettre à jour l’index).
On choisit donc prudemment les colonnes à indexer, en se concentrant sur les clés et les champs fréquemment filtrés.

* **Stockage physique et pages :** Sous le capot, un SGBD stocke les tables sur disque sous forme de fichiers de **pages
  ** (
  blocs). Les lignes d’une table sont enregistrées séquentiellement dans des pages. Les index, eux, occupent d’autres
  pages organisées en arbre. La notion de page est importante car les SGBD chargent et écrivent des données par pages
  entières pour optimiser les entrées/sorties (I/O). Des structures comme les B-arbres sont conçues pour minimiser le
  nombre de pages à parcourir. Concrètement, lorsqu’on exécute une requête, le moteur du SGBD charge en mémoire les
  pages nécessaires (mécanisme de buffer), utilise éventuellement un index pour cibler les bonnes pages, puis parcourt
  les données. Comprendre ceci aide à appréhender pourquoi la taille des données, la présence d’index ou la répartition
  en partitions influencent tant les performances.

```mermaid
sequenceDiagram
  participant App as Application / Client
  participant PG as PostgreSQL
  participant SB as Shared Buffers (PG)
  participant OS as Cache du système
  participant Disk as Fichiers (tables/index)

  App->>PG: SELECT ... WHERE ...
  PG->>SB: Chercher les pages demandées
  alt Hit en mémoire
    SB-->>PG: Retourne les tuples
  else Miss
    PG->>OS: Demande la page disque
    alt Page en cache OS
      OS-->>PG: Page
    else Miss OS
      OS->>Disk: Lecture bloc
      Disk-->>OS: Bloc
      OS-->>PG: Page
    end
    PG->>SB: Met en cache la page
  end
  PG-->>App: Résultats

```

* **Schéma conceptuel et normalisation :** Avant de créer physiquement des tables, on réalise souvent un **schéma
  conceptuel** (modèle entité-association) pour structurer les données de manière logique. Cela consiste à identifier
  les
  entités (typiquement une entité = une table) et leurs **attributs**, puis les **relations** entre entités (1-à-N,
  N-à-N…). Un
  bon schéma évite les doublons inutiles en suivant les principes de **normalisation** (formes normales). Par exemple,
  on
  évitera de stocker une information redondante dans deux tables différentes ; on la stockera dans une seule table et
  les autres y feront référence via des clés étrangères. La normalisation (jusqu’à la 3e forme normale en général)
  garantit l’intégrité et la cohérence des données, en évitant les anomalies d’insertion, de suppression ou de mise à
  jour. À l’inverse, dénormaliser (dupliquer volontairement de l’information) peut parfois se justifier pour des raisons
  de performance, mais c’est une optimisation à réserver aux cas nécessaires et en comprenant les conséquences.

> **Exemple d’entités et de relations :** imaginons un mini-système de gestion de commandes. On peut identifier trois
> entités principales : **Client, Produit, Commande**. Un client peut passer plusieurs commandes (relation 1-N entre
> Client et
> Commande), et chaque commande peut contenir plusieurs produits (relation N-N entre Commande et Produit, qu’on
> implémentera via une table d’association LigneCommande par exemple). Chaque entité a ses attributs : Client(id, nom,
> email, adresse,…), Produit(id, libellé, prix, stock,…), Commande(id, date, client_id, total,…), LigneCommande(
> commande_id, produit_id, quantité,…). Ce modèle bien pensé servira de base pour créer les tables et écrire les
> requêtes
> SQL correspondantes.
