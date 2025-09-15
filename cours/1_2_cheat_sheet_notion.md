# 3. Cheat Sheet — Bases de données dans Notion

## Installation & première connexion

* **Web (le plus simple)** : va sur `notion.so`, crée un compte et démarre directement dans le navigateur.
* **App desktop (recommandée)** :

    * **macOS** ou **Windows** → télécharge depuis la page officielle Notion Desktop, installe puis connecte-toi avec
      ton compte.
    * Guide pas à pas (Help Center) pour **Mac** et **Windows**.
* **Mobile (optionnel)** : iOS/Android dispo sur l’App Store/Play Store (synchro automatique).

## Vocabulaire minimal

* **Base de données** = une **collection de pages** (chaque ligne = une page avec propriétés).
* **Propriété** = colonne (texte, nombre, date, select, multi-select, relation, rollup, formule, etc.).
* **Vue** = table / board (Kanban) / calendrier / liste / galerie / **timeline** (Gantt).

## Créer ta première base

1. Tape **/database – full page** (ou **/table** pour une table inline).
2. Ajoute des **propriétés** :

    * *Title* (nom de l’item), *Select* (statut), *Person*, *Date*, *Number*, etc.
3. Remplis quelques lignes : chaque ligne est *ouvrable* (une page avec ses propriétés).

> Astuce : commence simple (3–6 propriétés). Tu spécialiseras ensuite.

**Importer** rapidement un CSV (données de démarrage) : depuis une base, *… → Merge with CSV* (ou *Import* dans la barre
latérale). *(Interface sujette à évoluer)*

## Vues & “pseudo-requêtes”

* **Changer de vue** : *Add a view* → choisis **Table / Board / Calendar / Timeline / List / Gallery**.
* **Filtrer / Trier / Grouper** (équivalents des clauses WHERE/ORDER BY/GROUP BY) via l’icône **filtres/tri** de la
  base.
* **Linked database** : recrée une **vue filtrée** de la *même* base dans une autre page (dashboard). Les filtrages
  d’une vue liée **n’altèrent pas** la base source.
* **Timeline** (planification) : timeline + “table à gauche”, bouton **Today**, etc.

## Relations & Rollups (les “jointures” de Notion)

* **Relation** : relie des items entre **deux bases** (ex. *Tâches → Projets*). La relation est **bidirectionnelle**.
* **Rollup** : remonte un ou plusieurs **champs** de la base liée (ex. *Nb de tâches par projet*, *Somme des points*).
  **Comment faire (recette express)**

1. Dans *Tâches*, ajoute une propriété **Relation** vers *Projets*.
2. Dans *Projets*, ajoute un **Rollup** : source = relation *Tâches*, propriété = *Status*, fonction = *Count* (ou
   *Percent complete*, *Sum*, etc.).

## Formules utiles

* La propriété **Formula** permet calculs & transformations (dates, textes, booléens, maths…).
* Référentiel des **fonctions** & **syntaxes** (Help Center) : https://www.notion.com/help/formulas

## Mapping **SQL ↔ Notion**

| Concept SQL           | Équivalent Notion     | Remarques                                  |
|-----------------------|-----------------------|--------------------------------------------|
| Table                 | Base de données       | Pas de schéma strict ; types souples.      |
| Ligne                 | Page (item)           | Ouvrable, peut contenir du contenu riche.  |
| Colonne               | Propriété             | Types variés (Select, Date, Number, etc.). |
| PK                    | Titre (implicite)     | **Aucune contrainte d’unicité** garantie.  |
| FK                    | Relation              | Lien bidirectionnel configurable.          |
| JOIN                  | Relation + Rollup     | “Jointures” matérialisées par UI.          |
| WHERE / ORDER / GROUP | Filtres / Tri / Group | Par vue (sauvegardables).                  |
| Vue matérialisée      | Linked DB             | Vue filtrée d’une source unique.           |

> **Limites à connaître** : pas de transactions ACID, pas de contraintes fortes (UNIQUE/NOT NULL), pas d’index au sens
> SGBD ; tout est piloté par l’UI et les propriétés.

## Bonnes pratiques rapides

* **Nomme tes propriétés** sans ambiguïté (ex. `Échéance` plutôt que `Date`).
* **Centralise** les données sources (1 base maîtresse), puis **multiplie les “linked DB”** pour les vues ciblées (
  tableaux de bord).
* **Commence simple**, puis ajoute Relations/Rollups **quand un besoin clair** apparaît (sinon complexité inutile).
* **Documente** chaque base (section “About” en haut de page) : finalité, propriétaire, règles de saisie.

## Raccourcis de survie

* **/database**, **/table**, **/board**, **/calendar**, **/timeline** pour créer vite.
* **Cmd/Ctrl + P** : recherche universelle.
* **Cmd/Ctrl + Shift + L** : mode sombre 🌙.
