## 4. Installation de PostgreSQL en local et connexion avec Metabase

Une fois les concepts assimilés, on passe à un **SGBD réel (PostgreSQL)** pour manipuler des données via SQL. Chaque étudiant installera PostgreSQL en local sur sa machine, puis utilisera **Metabase** (outil open-source de visualisation de données) pour interagir avec la base de façon conviviale.

**Étape 1 – Installer PostgreSQL localement :** PostgreSQL est un SGBDR libre et multi-plateforme. Selon le système d’exploitation des étudiants, les instructions d’installation diffèrent légèrement :

- *Sous Windows*, télécharger l’installateur depuis le site officiel PostgreSQL et suivre le wizard (incluant souvent pgAdmin4, un outil graphique d’administration).
- *Sous macOS*, utiliser l’outil Homebrew (`brew install postgresql`) ou le paquet .dmg proposé.
- *Sous Linux*, utiliser le gestionnaire de paquets (ex : `sudo apt-get install postgresql postgresql-contrib` sur Debian/Ubuntu).

Lors de l’installation, il faudra définir un mot de passe pour l’utilisateur administrateur (souvent l’utilisateur `postgres`). Une fois installé, PostgreSQL tourne en arrière-plan comme un service. On peut tester son fonctionnement en ouvrant un terminal/Invite de commande et en lançant le client `psql` (fourni) : par exemple, exécuter `psql -U postgres -l` pour lister les bases existantes. Par défaut, une base nommée *postgres* est créée. On peut créer une nouvelle base de travail avec `CREATE DATABASE test;` (via `psql` ou via pgAdmin).

**Étape 2 – Installation de Metabase :** Metabase est un outil de BI léger qui permet de se connecter à une base de données et d’exécuter des requêtes ou de générer des tableaux de bord sans programmation. Il s’exécute soit via un fichier JAR Java (exécutable sur n’importe quelle machine avec Java installé), soit via une image Docker. Pour simplifier, on peut utiliser le JAR : télécharger la dernière version de Metabase (fichier `metabase.jar`) et la lancer par `java -jar metabase.jar`. Celui-ci ouvre un service web local (par défaut sur http://localhost:3000).

Au premier lancement, Metabase guide l’utilisateur pour créer un compte admin local (email + mot de passe) puis propose de configurer la première connexion de base de données.

**Étape 3 – Connexion de Metabase à PostgreSQL :** Dans l’interface web Metabase (une fois connecté), cliquer sur **Administration → Bases de données → Ajouter une base de données**[metabase.com](https://www.metabase.com/docs/latest/databases/connections/postgresql#:~:text=To%20add%20a%20database%20connection%2C,Add%20a%20database). Choisir **PostgreSQL** comme type. Renseigner les paramètres de connexion : *nom d’hôte* (ex: `localhost` si PostgreSQL est sur la même machine), *port* (5432 par défaut), *nom de la base* (par ex. `test` ou autre si vous avez créé une base dédiée), *nom d’utilisateur* (`postgres` ou un autre compte si créé) et *mot de passe*. Validez la configuration. Si les infos sont correctes, Metabase établit la connexion et va analyser automatiquement les tables présentes.

À ce stade, les étudiants ont une **stack locale fonctionnelle** : un serveur PostgreSQL qui gère les données, et Metabase comme interface utilisateur pour interagir avec cette base.

**Étape 4 – Premiers pas avec SQL via Metabase :** Metabase permet d’exécuter des **questions** (requêtes) en SQL ou via une interface graphique. Pour commencer, créez une table d’exemple dans PostgreSQL. On peut soit :

- Utiliser Metabase en mode requête SQL directe (onglet *Native query*), soit
- Utiliser pgAdmin ou `psql` pour exécuter la commande SQL de création.

Par exemple, dans Metabase on peut aller dans *Write SQL* et exécuter :

```sql
CREATE TABLE exemple_personnes (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100),
  age INT
);

```

Cela va créer une table *exemple_personnes* avec trois colonnes. Metabase détectera la nouvelle table (on peut rafraîchir le schéma dans l’admin si besoin). On peut ensuite insérer des données soit via SQL (`INSERT INTO exemple_personnes (nom, age) VALUES ('Alice', 30);`), soit directement en utilisant un outil comme pgAdmin pour éditer la table.

L’intérêt de Metabase se révèle lorsqu’on veut **visualiser les données** : on peut créer une *question* en sélectionnant la table et en appliquant des filtres graphiquement, ou en écrivant une requête SQL et en affichant le résultat sous forme de tableau ou de graphique. Par exemple, si la table contient des champs appropriés, Metabase peut automatiquement proposer des graphes (histogramme des âges, etc.).

**Étape 5 – Utilisation de Metabase pour l’analyse :** Demandez aux étudiants de **charger un petit jeu de données** (quelques dizaines de lignes suffisent) dans PostgreSQL – cela peut être un fichier CSV importé via un outil, ou des inserts SQL fournis. Ensuite, via Metabase, ils peuvent formuler des questions : *« Combien de personnes ont moins de 25 ans ? »*, *« Âge moyen par catégorie… »* etc., soit en mode graphique soit en SQL. Metabase offre un bon compromis pour les débutants : ils voient le **résultat des requêtes immédiatement**, peuvent ajuster et corriger facilement. C’est motivant car on obtient aussi des visualisations simples (diagrammes) très rapidement.

**Sécurité de base :** Puisque PostgreSQL est en local, le risque de sécurité est faible, mais c’est l’occasion d’évoquer les notions de **droits utilisateurs** dans un SGBD. On peut montrer comment créer un utilisateur SQL avec des privilèges limités, par exemple un rôle *« etudiant »* qui ne peut que lire certaines tables. Cela introduit les **bonnes pratiques de sécurité** : ne pas donner les droits admin à tout le monde, compartimenter l’accès aux données. De même, on peut discuter de la nécessité de protéger les accès (mots de passe forts, ne pas exposer la base directement sur Internet sans pare-feu, etc.). Enfin, sensibilisez aux attaques comme l’**injection SQL** : comme les étudiants vont bientôt coder des applications, il est crucial de leur faire comprendre qu’il ne faut **jamais** concaténer naïvement des entrées utilisateurs dans des requêtes SQL sous peine de gros risques (mais on approfondira ce point en cours de développement).

## 5. Apprentissage du SQL pas à pas

Nous entrons dans le cœur du sujet : **manipuler et interroger une base de données relationnelle en SQL**. L’objectif est qu’en quelques séances, les étudiants acquièrent une autonomie pour créer des schémas, insérer des données et écrire des requêtes d’exploitation (lecture/analytique). On progressera du simple vers le complexe, en alternant apports théoriques, exemples concrets et exercices pratiques.

### 5.1 Langage de définition de données (DDL) : création et modification du schéma

Le DDL (*Data Definition Language*) regroupe les commandes SQL permettant de créer ou modifier la structure des objets de base de données (tables, index, contraintes, etc.). On couvre ici les commandes principales :

- **CREATE TABLE :** sert à créer une table avec ses colonnes, types et contraintes. Par exemple :

```sql
CREATE TABLE Client (
   client_id SERIAL PRIMARY KEY,
   nom VARCHAR(100) NOT NULL,
   email VARCHAR(255) UNIQUE,
   ville VARCHAR(50)
);

```

Ici on crée une table *Client* avec un id auto-incrémenté (type SERIAL), une contrainte de clé primaire, l’obligation que *nom* ne soit pas NULL, et une contrainte UNIQUE sur l’email (pour éviter les doublons de courriel).

*Points pédagogiques:* expliquer les principaux **types SQL** (INTEGER, VARCHAR, DATE, BOOLEAN, etc.), la différence entre **NULL et NOT NULL** (une valeur manquante vs champ obligatoire), la syntaxe des **contraintes** (PRIMARY KEY, UNIQUE, CHECK, DEFAULT…). Souvent, on introduit aussi la notion d’**auto-incrément** (SERIAL ou `AUTO_INCREMENT` en MySQL) pour les PK numériques. Un exercice possible : *“Écrire la commande CREATE TABLE pour la table Produit d’après le modèle conçu (id, nom, prix, etc.), en choisissant des types appropriés et en définissant la PK.”*

- **ALTER TABLE :** permet de modifier une table existante (ajouter une colonne, changer un type, ajouter une contrainte, etc.). Exemple : `ALTER TABLE Client ADD COLUMN age INT;` ajoute une colonne âge. Utile pour montrer qu’un schéma peut évoluer, mais aussi signaler que toute modification a un impact (p.ex. si on ajoute une contrainte NOT NULL sur une table déjà remplie, il faut s’assurer qu’aucune ligne ne viole la contrainte). On peut faire pratiquer en demandant d’ajouter une colonne, ou de renommer une colonne (`ALTER TABLE ... RENAME COLUMN ...`), etc.
- **DROP TABLE / DROP ... :** supprime un objet (table, index…). **Attention** en prod ! Ces commandes sont destructrices. Pour l’exercice, on peut créer puis dropper une table temporaire pour voir. Mentionner éventuellement `DROP TABLE IF EXISTS` (pour éviter erreur si table absente). Pareil pour `DROP DATABASE` (supprimer une base entière – à manipuler avec précaution).
- **CREATE INDEX :** créer un index sur une ou plusieurs colonnes. Syntaxe par ex : `CREATE INDEX idx_client_ville ON Client(ville);` pour accélérer les recherches par ville. On expliquera que les SGBD créent **automatiquement un index pour chaque clé primaire** (et souvent clé unique)[ovhcloud.com](https://www.ovhcloud.com/fr/learn/sql-vs-nosql/#:~:text=Avantages%20de%20SQL)[ovhcloud.com](https://www.ovhcloud.com/fr/learn/sql-vs-nosql/#:~:text=Lors%20de%20l%27utilisation%20de%20ces,coup%20d%27%C5%93il%20%C3%A0%20ces%20propri%C3%A9t%C3%A9s), ce qui fait qu’en général on n’a pas besoin de créer un index sur l’id puisque c’est la PK. Par contre, sur des colonnes de filtre fréquent (ex: un champ *email* qu’on va chercher souvent), un index peut aider. Faire éventuellement une démo : sans index vs avec index (mais sur de petites tables l’impact sera peu visible). Au moins, conceptualiser que l’index se met à jour en même temps que les données (coût en écriture, bénéfice en lecture).
- **FOREIGN KEY :** en SQL, une contrainte FK se définit soit dans la création de table, soit via ALTER. Exemple dans `CREATE TABLE Commande (... client_id INT REFERENCES Client(client_id) ...)`. On peut aussi écrire `FOREIGN KEY (client_id) REFERENCES Client(client_id)`. Il est important de mentionner les **actions en cas de suppression** (ON DELETE CASCADE, NO ACTION, SET NULL, etc.) – par exemple, `ON DELETE CASCADE` supprime automatiquement les commandes d’un client si le client est supprimé. C’est un aspect du SGBD garantissant l’intégrité référentielle automatiquement. On peut faire manipuler une contrainte FK : créer deux tables liées, tenter de violer la contrainte (insertion d’un enregistrement avec FK pointant vers un parent inexistant, voir le refus du SGBD), puis insérer dans le bon ordre.

**Exercice intégrateur DDL :** reprendre le modèle de données de l’application cible (par ex. Client-Commande-Produit) et écrire les commandes `CREATE TABLE` pour chaque entité, avec clés primaires, étrangères et quelques contraintes (NOT NULL sur les champs obligatoires, UNIQUE si pertinent). Une fois les tables créées, utiliser `\d` (psql) ou l’interface de Metabase/pgAdmin pour vérifier la structure, et éventuellement corriger les erreurs de syntaxe. Cet exercice ancre la compréhension du schéma relationnel *implémenté*.

### 5.2 Langage de manipulation de données (DML) : insérer, mettre à jour, supprimer des données

Le DML (*Data Manipulation Language*) regroupe les commandes permettant de **modifier le contenu** des tables :

- **INSERT INTO :** ajoute de nouvelles lignes. Deux formes : soit en listant les colonnes et les valeurs, soit en s’appuyant sur l’ordre des colonnes. Exemples :

```sql
INSERT INTO Client(nom, email, ville) VALUES ('Alice', 'alice@example.com', 'Paris');
INSERT INTO Client(nom, ville) VALUES ('Bob', 'Lyon');  -- email sera NULL ici

```

On montre que si on ne spécifie pas la colonne PK `client_id` (car SERIAL auto), elle se remplira toute seule. Faire attention aux chaînes de caractères (quotées), aux dates (`'2023-10-01'`), etc. On peut faire insérer plusieurs lignes d’un coup (plusieurs tuples de VALUES) pour aller plus vite. **Erreur fréquente de débutant** : oublier une quote, une parenthèse – profiter pour montrer comment le SGBD réagit (message d’erreur, etc.) afin qu’ils apprennent à déboguer.

- **UPDATE ... SET ... WHERE :** modifie des enregistrements existants. Exemple : `UPDATE Client SET ville='Marseille' WHERE nom='Alice';` changera la ville d’Alice. **Insister sur la clause WHERE :** sans `WHERE`, *toutes* les lignes seront mises à jour (ex : `UPDATE Client SET ville='Paris';` mettrait "Paris" partout). C’est une classique “boulette” SQL, donc bien prévenir qu’un UPDATE/DELETE sans condition affecte toute la table. Astuce : sur un SGBD comme Postgres, on peut faire un `BEGIN` (débuter une transaction), exécuter la requête potentiellement risquée, vérifier avec un SELECT, puis `ROLLBACK` si c’était une erreur, pour annuler.
- **DELETE FROM ... WHERE :** supprime des enregistrements. Même principe : sans WHERE -> vide toute la table (prudence). Exemple : `DELETE FROM Client WHERE client_id=5;` supprime le client d’ID 5. On peut expliquer les retours du SGBD du style “X rows affected”. Mentionner qu’il existe TRUNCATE (pour vider entièrement une table très rapidement, en contournant les verrous et sans journaling complet) – c’est du DDL plus que DML, mais utile de connaître.
- **Transactions (BEGIN, COMMIT, ROLLBACK) :** introduire brièvement la notion de transaction pour regrouper plusieurs modifications atomiquement. Par exemple, si on doit insérer une commande et décrémenter le stock du produit, on voudra que les deux opérations réussissent ou échouent ensemble – on encapsule dans une transaction. Les propriétés **ACID** (Atomicité, Cohérence, Isolation, Durabilité) assurent la fiabilité des transactions[ovhcloud.com](https://www.ovhcloud.com/fr/learn/sql-vs-nosql/#:~:text=Lors%20de%20l%27utilisation%20de%20ces,coup%20d%27%C5%93il%20%C3%A0%20ces%20propri%C3%A9t%C3%A9s)[ovhcloud.com](https://www.ovhcloud.com/fr/learn/sql-vs-nosql/#:~:text=). Sans trop détailler (ça peut être un cours à part entière), donner l’idée : *atomicité* = tout ou rien[ovhcloud.com](https://www.ovhcloud.com/fr/learn/sql-vs-nosql/#:~:text=), *isolation* = une transaction en cours ne voit pas les demi-changements des autres[ovhcloud.com](https://www.ovhcloud.com/fr/learn/sql-vs-nosql/#:~:text=), etc. La plupart du temps, quand on exécute des commandes via un client SQL, chaque commande est en auto-commit (transaction implicite). Mais dans du code applicatif, on gérera les transactions explicitement.

**Exercices DML suggérés :**

- Remplir la base créée précédemment avec des données factices : par ex. insérer 5-10 clients, produits, et quelques commandes. On peut demander aux étudiants d’écrire les inserts eux-mêmes, ou fournir un jeu de tuples à importer. L’important est qu’ils manipulent des valeurs et voient comment les FK imposent l’ordre (d’abord insérer un client avant sa commande, sinon violation).
- Faire quelques **UPDATE** : changer l’adresse d’un client, le statut d’une commande, etc. Vérifier avec un SELECT que la modif a bien eu lieu.
- Faire quelques **DELETE** : supprimer un produit et voir éventuellement l’effet sur les commandes (si la FK a ON DELETE CASCADE, elles partent aussi ; sinon la suppression sera bloquée s’il y a une FK NO ACTION). Tester aussi un DELETE sans WHERE sur une table temporaire pour dramatiser l’importance de la clause WHERE 😉.
- Mettre en évidence la **cohérence référentielle** : que se passe-t-il si on tente de supprimer un client qui a des commandes ? (par défaut, erreur si FK, sauf si cascade). Que se passe-t-il si on insère une commande avec un product_id inconnu ? (erreur FK). Ces expérimentations concrètes aident les étudiants à comprendre le rôle du SGBD comme **gardien de l’intégrité** – une grande différence avec une simple feuille Excel.

### 5.3 Interroger les données : le langage des requêtes SQL (SELECT, JOIN, etc.)

Après avoir peuplé la base, vient l’essentiel : **savoir lire/exploiter les données** avec des requêtes. C’est souvent la partie la plus dense du cours SQL. On la construit progressivement :

- **SELECT * FROM Table :** commencer par l’extraction la plus simple – *« sélectionne toutes les colonnes, toutes les lignes »*. Montrer le résultat sous forme de tableau. Souligner que l’ordre par défaut des résultats n’est pas garanti (sauf si on impose un tri). Encourager à lister les colonnes explicitement plutôt que `SELECT *` (bonne pratique pour ne récupérer que ce dont on a besoin, améliorer lisibilité, etc.).
- **Clauses WHERE (filtres) :** introduire la clause `WHERE` pour filtrer les lignes par condition. Exemples : `SELECT nom, ville FROM Client WHERE ville='Paris';` retourne les clients parisiens. `SELECT * FROM Produit WHERE stock < 5 AND prix > 100;` filtres combinés, avec opérateurs de comparaison (=, <, >, <=, >=, <>, !=) et booléens (AND, OR, NOT). Ne pas oublier l’usage des quotes pour les textes, et la syntaxe spéciale pour les patterns (LIKE, %). Par exemple `WHERE nom LIKE 'A%'` pour les noms commençant par A. On peut mentionner les expressions régulières (Postgres `~`) si curieux, mais pas obligatoire.
- **Projection (choix de colonnes) :** montrer qu’on peut sélectionner certaines colonnes seulement, créer des colonnes calculées (`SELECT prix * 1.2 AS prix_ttc FROM Produit;`). Parler des fonctions *built-in* (CONCAT, SUBSTR, UPPER, etc. pour manipuler les strings, ou DATE_TRUNC, etc. si besoin) – mais garder ça pour plus tard éventuellement. Un point important : la **gestion des NULL** (ex: si un email est NULL, un filtre `email = 'alice@x'` ne le retournera pas car NULL n’est “égal” à rien, il faut utiliser `IS NULL` pour tester). Faire un aparté sur les trois valeurs logiques (TRUE/FALSE/UNKNOWN) introduites par les NULL.
- **ORDER BY (tri) :** `SELECT * FROM Client ORDER BY nom ASC;` tri alphabétique. Descendant : `ORDER BY age DESC`. Souligner que sans ORDER BY, l’ordre est arbitraire (surtout en SQL moderne, on n’a pas la garantie de l’ordre d’insertion). On peut trier sur plusieurs colonnes, etc.
- **LIMIT / OFFSET :** (s’ils utilisent Postgres/MySQL) mentionner la possibilité de limiter le nombre de résultats (utile si table très grande, ou pour pagination). Exemple : `SELECT * FROM Produit ORDER BY prix DESC LIMIT 5;` – top 5 des produits les plus chers.

Jusque-là, ce sont des requêtes simples sur une seule table. **Exercices** : trouver tous les clients d’une certaine ville, lister les produits en rupture (stock=0), lister les 3 produits les moins chers, etc. L’idée est que les étudiants s’habituent à formuler des critères et à lire des résultats.

- **JOINS (jointures) :** Le point central pour exploiter un schéma relationnel multi-table. Expliquer qu’une **jointure** combine des lignes de plusieurs tables selon une condition d’appariement (souvent clé étrangère = clé primaire). Syntaxe la plus courante : *join interne* avec `SELECT ... FROM A JOIN B ON A.clef = B.clef`. On peut commencer par un exemple : *« retrouver la liste des commandes avec le nom du client »*. Supposons table *Commande*(id, date, client_id, total) et table *Client*(client_id, nom,…). La requête :

```sql
SELECT Commande.id, Commande.date, Client.nom, Commande.total
FROM Commande
JOIN Client ON Commande.client_id = Client.client_id;

```

Cette **jointure interne** (INNER JOIN) ne retournera que les commandes qui ont un client correspondant (ce qui est normal si la contrainte FK est respectée). Expliquer le résultat : chaque ligne du résultat est la combinaison d’une ligne de Commande avec la ligne de Client associée, les colonnes demandées sont issues des deux tables. C’est l’équivalent de « pour chaque commande, on va chercher le client correspondant ». On peut écrire des alias pour simplifier (`FROM Commande AS co JOIN Client AS cl ON co.client_id = cl.client_id`).

Ensuite, mentionner les différentes jointures :

- **INNER JOIN** : ne garde que les correspondances (ce qu’on vient de faire).
- **LEFT JOIN** (jointure externe gauche) : garde *toutes* les lignes de la table de gauche, même si pas de correspondant à droite, les colonnes de droite seront NULL. Utile par exemple pour lister *tous* les clients et leurs commandes, y compris les clients sans commande (ils apparaîtront avec NULL pour les infos de commande). On peut faire un exemple : `SELECT cl.nom, co.id FROM Client cl LEFT JOIN Commande co ON co.client_id = cl.client_id;` – les clients sans commandes auront co.id NULL.
- **RIGHT JOIN** (symétrique, moins utilisé souvent car on peut inverser l’ordre des tables).
- **FULL JOIN** (externe complet, combinant les deux, peu fréquent).
- **CROSS JOIN** (produit cartésien, toutes combinaisons – rarement souhaité sauf cas particulier).

Pour débutants, se concentrer sur INNER et LEFT JOIN, qui couvrent 95% des besoins. Illustrer potentiellement avec un schéma ou des petits ensembles de données pour voir la différence.

**Exercices sur les jointures :**

- Lister toutes les commandes avec nom du client et éventuellement d’autres infos liées (ex: ville du client).
- Lister les lignes de commande (si on a une table d’association) en joignant Produits pour voir le nom du produit au lieu de juste l’ID.
- Trouver des clients sans commandes (requête avec LEFT JOIN filtrée `WHERE Commande.id IS NULL`).
- Si on a un domaine différent : par ex. *Étudiants - Inscriptions - Cours*, lister les étudiants avec les cours auxquels ils sont inscrits (et inversement).

L’objectif est de rendre les étudiants à l’aise avec l’idée qu’on peut *combiner plusieurs tables* dans une requête pour obtenir une information complète répondant à un besoin métier.

- **Fonctions d’agrégation et GROUP BY :** Une fois les jointures acquises, on ajoute la couche *agrégation*. Ce sont les requêtes de type *« combien, moyenne, minimum, maximum… »*. Les fonctions classiques : `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`. Par exemple : *« Combien de commandes chaque client a passées ? »* -> on peut écrire:

```sql
SELECT cl.nom, COUNT(co.id) AS nb_commandes
FROM Client cl
LEFT JOIN Commande co ON co.client_id = cl.client_id
GROUP BY cl.client_id, cl.nom;

```

Ici on voit la clause `GROUP BY` : on regroupe les résultats par client. Toute colonne sélectionnée qui n’est pas agrégée doit figurer dans le GROUP BY (ex: on groupe par le nom du client pour pouvoir le sélectionner). Le résultat donnera chaque client et le nombre de commandes associées.

Autres exemples : *« Chiffre d’affaire total par client »* (`SUM(Commande.total) GROUP BY client`), *« Stock moyen des produits par catégorie »* (si on a une catégorie, `AVG(stock) GROUP BY categorie`), etc. Illustrer aussi `HAVING` pour filtrer sur des agrégats (par ex. *« clients ayant plus de 2 commandes »* : on ajouterait `HAVING COUNT(co.id) > 2`).

**Exercices agrégations :**

- Combien de produits différents ont été commandés dans chaque commande (si table LigneCommande, `COUNT(DISTINCT produit_id) GROUP BY commande_id`).
- Trouver la ville qui a le plus de clients (GROUP BY ville, COUNT(*), ORDER BY COUNT DESC, LIMIT 1).
- Calculer le stock total de produits en magasin (simple SUM sans group by).
- Etc.
- **Sous-requêtes et vues :** Si le temps le permet, introduire les sous-requêtes (ex: *requête imbriquée* dans un `WHERE` ou un FROM) pour des cas où une requête doit en filtrer une autre. Par exemple : *« produits dont le prix est supérieur au prix moyen de tous les produits »* – on peut faire `WHERE prix > (SELECT AVG(prix) FROM Produit)`. Expliquer que le SGBD peut traiter ça de différentes manières (parfois optimisation en une passe). Mentionner les vues (`CREATE VIEW`) pour sauvegarder une requête complexe et la réutiliser comme une table virtuelle.
- **EXPLAIN et optimisation de requêtes :** Montrer qu’on peut préfixer une requête par `EXPLAIN` (voire `EXPLAIN ANALYZE` sur Postgres) pour obtenir le *plan d’exécution*. Les débutants ne comprendront pas tous les détails, mais ils verront des mots comme *Seq Scan* (parcours séquentiel de table) ou *Index Scan* (utilisation d’index). Par exemple, faire une requête avec un filtre sur une colonne indexée vs non indexée et voir la différence de plan. Ceci fait le lien avec la partie **index/B-tree** vue en théorie : un index permet au plan d’éviter le *Seq Scan* sur une grosse table, ce qui est bien plus efficace[use-the-index-luke.com](https://use-the-index-luke.com/fr/sql/anatomie-dun-index/le-b-tree#:~:text=L%27arbre%20de%20recherche%20%28B,que%20j%27en%20parle%20comme). C’est une initiation à l’optimisation : écrire une requête c’est bien, comprendre comment le SGBD la réalise c’est mieux pour anticiper les problèmes de perf. Insister qu’on n’écrit pas la boucle de parcours nous-mêmes – on déclare juste quoi chercher en SQL et c’est le *moteur de requête* qui décide comment (c’est là la force mais aussi la subtilité du SGBD).

### 5.4 Concepts avancés : partitionnement, performance et bonnes pratiques SQL

Dans la dernière partie du module SQL, on aborde quelques notions avancées pour élargir la perspective des étudiants au-delà des bases :

- **Partitionnement de tables :** Lorsqu’une table devient très volumineuse (des millions de lignes), il peut être judicieux de la **partitionner**, c’est-à-dire la découper physiquement en plusieurs sous-tables tout en la manipulant logiquement comme une seule. PostgreSQL, par exemple, permet de déclarer une table partitionnée selon un critère (plage de dates, valeur de clé, etc.)[docs.postgresql.fr](https://docs.postgresql.fr/12/ddl-partitioning.html#:~:text=PostgreSQL%20donne%20un%20moyen%20de,La%20d%C3%A9claration%20inclut%20la). Par exemple, on peut partitionner une table *Logs* par année de sorte que les requêtes sur les logs 2023 n’aillent chercher que dans la partition de 2023 et pas dans les données 2021, 2022, etc. Ce mécanisme améliore les performances de requête et facilite l’archivage (on peut détacher ou supprimer d’un coup les partitions anciennes). Pour illustrer, on peut montrer la syntaxe simple :

```sql
CREATE TABLE Ventes (
   id SERIAL, date DATE, montant NUMERIC
) PARTITION BY RANGE(date);

CREATE TABLE Ventes_2022 PARTITION OF Ventes
   FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');

CREATE TABLE Ventes_2023 PARTITION OF Ventes
   FOR VALUES FROM ('2023-01-01') TO ('2024-01-01');

```

Puis insérer des ventes sur 2022/2023 et voir qu’elles vont dans la bonne partition. Sans entrer dans tous les détails (gestion des partitions par la base), l’idée à retenir est : *le partitionnement découpe les données horizontalement, ce qui peut accélérer certaines requêtes et faciliter la maintenance*. C’est particulièrement utile pour les tables de *logs*, *historique*, *données temporelles* très lourdes. On peut mentionner que d’autres SGBD ou solutions utilisent le terme **sharding** lorsque les partitions sont distribuées sur plusieurs serveurs (notion de base de données distribuée).

- **Tuning des index et requêtes :** Discuter de cas concrets d’optimisation :
    - Choix des index : ex. index composite si on cherche souvent sur [colonne A ET colonne B]. Par contre, multiplier les index sur une table de forte volumétrie peut pénaliser les insertions et consommer de l’espace.
    - Requêtes SQL à éviter : SELECT * abusif (ramène trop de données), les sous-requêtes corrélées non nécessaires (préfèrer une jointure), etc.
    - **Plans d’exécution :** évoquer ce qu’on voit dans un EXPLAIN. Par ex., expliquer ce qu’est un *Nested Loop Join*, un *Hash Join*, un *Sort*, un *Sequential Scan*. Pas besoin d’entrer dans les algorithmes en détail, mais au moins que le SGBD choisit la méthode (et qu’en général, on fait confiance à l’optimiseur, mais qu’on peut ajuster via indexes, hints dans certains SGBD, etc.).
    - **Cache et mémoire :** mentionner que les SGBD gardent en mémoire les pages récemment accédées (cache buffer) pour accélérer les lectures répétées. Donc lire 1000 fois la même petite table n’est pas 1000 fois plus long qu’une fois, grâce au cache. Par contre lire séquentiellement un énorme ensemble de données, ça prend du temps (I/O).
    - **Verrous et concurrence :** pour info, dire que le SGBD gère la concurrence via des mécanismes de verrouillage ou versionnement (MVCC dans Postgres). Ceci garantit que deux transactions n’écrasent pas des données l’une de l’autre de manière incohérente. Les niveaux d’isolation (READ COMMITTED, REPEATABLE READ…) peuvent être mentionnés, mais ça peut rester superficiel si le temps manque.
- **Bonnes pratiques de sécurité SQL :** Refaire un point sur l’**injection SQL** côté application – montrer un exemple simple en pseudo-code d’une app vulnérable (`query = "SELECT * FROM Client WHERE email='"+ userInput + "'";` et userInput = `' OR '1'='1` qui déclenche un dump complet). Expliquer qu’utiliser des **requêtes paramétrées** ou ORM évite ce problème. Côté SGBD, rappeler l’importance de la gestion des rôles : ne jamais donner plus de privilèges que nécessaire à un compte applicatif (principe de moindre privilège). Si l’appli n’a besoin que de SELECT, qu’on ne lui donne pas les droits de DROP table ! Mentionner aussi les sauvegardes (dump régulier), la surveillance des performances (log des requêtes lentes), etc., comme parties prenantes de l’administration d’une base de données.

Pour conclure la partie relationnelle, on peut souligner que **SQL reste un langage incontournable** en informatique : il est très présent en entreprise, et même avec l’émergence de NoSQL, SQL a su évoluer et reste pertinent (certaines bases NoSQL modernes réintroduisent d’ailleurs des langages proches du SQL). Le but du cours est que chaque étudiant sache concevoir un schéma simple et écrire des requêtes SQL pour exploiter les données, ce qui est atteint via la pratique régulière sur des cas concrets.
