# Cheat Sheet — Bases de données Notion

**URL d'accès** : https://notion.so

---

## 🗃️ BASES DE DONNÉES - CONCEPTS ESSENTIELS

### Qu'est-ce qu'une base de données ?

- **Collection de pages** organisées avec des propriétés communes
- Chaque **ligne = une page** avec du contenu riche
- **Propriétés = colonnes** (texte, nombre, date, sélection, etc.)

### Types de propriétés principales

| Type                | Usage                      | Exemple                  |
|---------------------|----------------------------|--------------------------|
| **Titre**           | Nom principal de l'élément | "Projet Alpha"           |
| **Texte**           | Description courte         | "Description du projet"  |
| **Nombre**          | Valeurs numériques         | Budget: 15000            |
| **Sélection**       | Choix unique               | Statut: "En cours"       |
| **Multi-sélection** | Choix multiples            | Tags: "Urgent", "Client" |
| **Date**            | Dates et heures            | Échéance: 15/12/2024     |
| **Personne**        | Assignation                | @Marie Dupont            |
| **Case à cocher**   | Booléen                    | ☑️ Terminé               |
| **URL**             | Liens web                  | https://example.com      |
| **Email**           | Adresses email             | contact@example.com      |
| **Téléphone**       | Numéros                    | +33 1 23 45 67 89        |

---

## 📊 VUES DE BASE DE DONNÉES

### Types de vues disponibles

- **📋 Table** : Vue classique en lignes/colonnes
- **📌 Tableau** : Kanban par statut/propriété
- **📅 Calendrier** : Planning par dates
- **📜 Liste** : Vue simplifiée verticale
- **🖼️ Galerie** : Cartes visuelles avec images
- **⏳ Chronologie** : Diagramme de Gantt
- **📈 Graphique** : Visualisations de données
- **🔍 Fil d'actualité** : Cartes empilées

### Créer et gérer les vues

```
+ Ajouter une vue → Choisir le type → Nommer
```

- Chaque vue peut avoir ses **filtres**, **tris** et **groupes**
- Les vues sont **indépendantes** (modifier une vue n'affecte pas les autres)

---

## 🔍 FILTRES, TRIS ET GROUPES

### Filtres (équivalent WHERE en SQL)

- **Texte** : contient, ne contient pas, est vide
- **Nombre** : =, ≠, >, <, ≥, ≤
- **Date** : avant, après, cette semaine, ce mois
- **Sélection** : est, n'est pas, est vide
- **Personne** : est, contient, est vide
- **Case à cocher** : cochée, non cochée

### Tris (équivalent ORDER BY)

- **Croissant** (A→Z, 1→9, ancien→récent)
- **Décroissant** (Z→A, 9→1, récent→ancien)
- **Tris multiples** possibles (priorité par ordre)

### Groupes (équivalent GROUP BY)

- Regrouper par **Sélection**, **Multi-sélection**, **Personne**, **Date**
- Affichage en **sections** avec compteurs

---

## 🔗 RELATIONS ET ROLLUPS

### Relations (jointures entre bases)

1. **Créer une relation** : Propriété → Relation → Choisir la base cible
2. **Bidirectionnelle** : apparaît automatiquement dans les deux bases
3. **Plusieurs éléments** possibles par relation

### Rollups (agrégations)

1. **Prérequis** : avoir une relation existante
2. **Configuration** :
    - Source : propriété relation
    - Propriété : champ à agréger
    - Fonction : Count, Sum, Average, Min, Max, etc.

**Exemple pratique** :

```
Base "Projets" ← Relation → Base "Tâches"
Rollup dans Projets : 
- Source: Tâches (relation)
- Propriété: Statut
- Fonction: Percent complete
```

---

## 📐 FORMULES UTILES

### Syntaxe de base

```javascript
// Texte
prop("Nom") + " - " + prop("Statut")

// Nombres
prop("Prix") * 1.20  // TVA 20%

// Dates
dateBetween(prop("Fin"), prop("Début"), "days")

// Conditions
if (prop("Urgent"), "🔥", "📝")
```

### Fonctions courantes

| Fonction                     | Usage                    | Exemple                            |
|------------------------------|--------------------------|------------------------------------|
| `prop("Nom")`                | Référencer une propriété | `prop("Prix")`                     |
| `if(test, vrai, faux)`       | Condition                | `if(prop("Fini"), "✅", "⏳")`       |
| `concat(a, b, c)`            | Concaténer               | `concat("Projet ", prop("Nom"))`   |
| `format(date)`               | Formater date            | `format(prop("Échéance"))`         |
| `length(texte)`              | Longueur                 | `length(prop("Description"))`      |
| `contains(texte, recherche)` | Contient                 | `contains(prop("Tags"), "Urgent")` |

---

## 🎨 MISES EN PAGE PERSONNALISÉES

### Structure des pages

- **Titre** : toujours visible, jusqu'à 4 propriétés épinglées
- **Page principale** : contenu et modules de propriétés
- **Menu d'informations** : panneau latéral droit

### Personnalisation

1. **Ouvrir une page** de base de données
2. **Cliquer sur "Personnaliser la mise en page"**
3. **Épingler des propriétés** au titre (max 4)
4. **Ajouter des modules** sur la page principale
5. **Organiser le menu** d'informations
6. **Appliquer à toutes les pages**

---

## 🔧 MODÈLES DE PAGES

### Créer un modèle

1. Dans la base de données : **⚙️ → Modèles**
2. **+ Nouveau modèle**
3. **Configurer** la structure type
4. **Définir les propriétés** par défaut

### Utiliser un modèle

- **Nouvelle page** → Choisir le modèle
- **Bouton de modèle** : dupliquer la structure

---

## 📋 BASES DE DONNÉES LIÉES

### Principe

- **Même source**, **vue différente** ailleurs
- Filtres et tris **indépendants**
- Modifications **synchronisées**

### Créer une base liée

```
/linked → Choisir la base source → Configurer les filtres
```

**Cas d'usage** : tableaux de bord, vues spécialisées par équipe

---

## ⚡ RACCOURCIS CLAVIER ESSENTIELS

### Navigation et recherche

| Raccourci      | Action                  |
|----------------|-------------------------|
| `Cmd/Ctrl + P` | Recherche rapide        |
| `Cmd/Ctrl + K` | Aller à une page        |
| `Cmd/Ctrl + [` | Page précédente         |
| `Cmd/Ctrl + ]` | Page suivante           |
| `Cmd/Ctrl + F` | Rechercher dans la page |

### Création rapide

| Raccourci   | Action                   |
|-------------|--------------------------|
| `/database` | Nouvelle base de données |
| `/table`    | Nouvelle table           |
| `/board`    | Nouveau tableau Kanban   |
| `/calendar` | Nouveau calendrier       |
| `/timeline` | Nouvelle chronologie     |

### Édition et mise en forme

| Raccourci      | Action          |
|----------------|-----------------|
| `Cmd/Ctrl + B` | **Gras**        |
| `Cmd/Ctrl + I` | *Italique*      |
| `Cmd/Ctrl + U` | Souligné        |
| `Cmd/Ctrl + K` | Ajouter un lien |
| `Cmd/Ctrl + E` | Code inline     |

### Manipulation de blocs

| Raccourci      | Action               |
|----------------|----------------------|
| `Cmd/Ctrl + D` | Dupliquer le bloc    |
| `Cmd/Ctrl + /` | Menu d'actions       |
| `Échap`        | Sélectionner le bloc |
| `Entrée`       | Éditer le bloc       |
| `Tab`          | Indenter             |
| `Maj + Tab`    | Désindenter          |

### Interface et affichage

| Raccourci            | Action                   |
|----------------------|--------------------------|
| `Cmd/Ctrl + Maj + L` | Mode sombre/clair        |
| `Cmd/Ctrl + \`       | Masquer/afficher sidebar |
| `Cmd/Ctrl + +`       | Zoomer                   |
| `Cmd/Ctrl + -`       | Dézoomer                 |
| `Cmd/Ctrl + 0`       | Zoom par défaut          |

---

## 💡 BONNES PRATIQUES

### Organisation

- **Nommer clairement** les propriétés (ex: "Date d'échéance" vs "Date")
- **Commencer simple** : 3-5 propriétés maximum au début
- **Documenter** chaque base (description en haut de page)

### Performance

- **Limiter les relations** complexes
- **Éviter trop de rollups** sur de grandes bases
- **Utiliser les vues filtrées** plutôt que de grandes tables

### Collaboration

- **Définir des conventions** de nommage
- **Former les utilisateurs** aux bases essentielles
- **Centraliser les données** sources, multiplier les vues

---

*Cheat sheet basé sur la documentation officielle Notion - Version 2025*
