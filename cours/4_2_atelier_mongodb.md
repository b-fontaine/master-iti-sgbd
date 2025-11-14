# Atelier Pratique MongoDB

## Objectifs de l'atelier

À la fin de cet atelier, vous serez capable de :
- ✅ Configurer et démarrer MongoDB avec Docker
- ✅ Créer des bases de données et collections
- ✅ Insérer des documents JSON variés
- ✅ Effectuer des requêtes simples et avancées
- ✅ Utiliser le pipeline d'agrégation MongoDB
- ✅ Manipuler des données avec Mongo Express (interface web)

**Thème de l'atelier** : Gestion d'une boutique en ligne de produits électroniques

---

## 1. Configuration Docker

### 1.1 Ajout des services MongoDB au docker-compose.yaml

Nous allons ajouter deux services au fichier `docker-compose.yaml` existant :
- **MongoDB** : La base de données NoSQL
- **Mongo Express** : Interface web d'administration

Ouvrez le fichier `docker-compose.yaml` à la racine du projet et ajoutez les services suivants **après le service `pgadmin`** (avant la section `volumes`) :

```yaml
  # Base de données MongoDB
  mongodb:
    image: mongo:7.0
    container_name: mongodb_sgbd
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin123
      MONGO_INITDB_DATABASE: boutique_electronique
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
      - mongodb_config:/data/configdb
    networks:
      - sgbd_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Interface d'administration Mongo Express
  mongo-express:
    image: mongo-express:latest
    container_name: mongo_express_sgbd
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: admin123
      ME_CONFIG_MONGODB_URL: mongodb://admin:admin123@mongodb:27017/
      ME_CONFIG_BASICAUTH_USERNAME: admin
      ME_CONFIG_BASICAUTH_PASSWORD: admin
    ports:
      - "8081:8081"
    networks:
      - sgbd_network
    depends_on:
      mongodb:
        condition: service_healthy
    restart: unless-stopped
```

Ajoutez également les volumes MongoDB dans la section `volumes` :

```yaml
volumes:
  postgres_data:
    driver: local
  metabase_data:
    driver: local
  pgadmin_data:
    driver: local
  mongodb_data:        # ← Ajouter
    driver: local
  mongodb_config:      # ← Ajouter
    driver: local
```

### 1.2 Explication de la configuration

| Paramètre | Description |
|-----------|-------------|
| **image: mongo:7.0** | Version 7.0 de MongoDB (dernière version stable) |
| **MONGO_INITDB_ROOT_USERNAME** | Utilisateur administrateur (admin) |
| **MONGO_INITDB_ROOT_PASSWORD** | Mot de passe administrateur (admin123) |
| **MONGO_INITDB_DATABASE** | Base de données créée au démarrage |
| **ports: 27017:27017** | Port MongoDB (27017 par défaut) |
| **mongodb_data** | Volume pour la persistance des données |
| **mongodb_config** | Volume pour la configuration MongoDB |
| **ME_CONFIG_MONGODB_URL** | URL de connexion pour Mongo Express |
| **ports: 8081:8081** | Port Mongo Express (interface web) |

> **💡 Note** : Les identifiants sont simplifiés pour l'atelier. En production, utilisez des mots de passe robustes et des secrets Docker.

---

## 2. Démarrage de l'environnement

### 2.1 Lancement des services MongoDB

Depuis la racine du projet, exécutez :

```bash
# Démarrer uniquement MongoDB et Mongo Express
docker-compose up -d mongodb mongo-express

# Vérifier que les conteneurs sont bien démarrés
docker-compose ps
```

**Résultat attendu** :
```
NAME                  IMAGE                    STATUS         PORTS
mongodb_sgbd          mongo:7.0                Up (healthy)   0.0.0.0:27017->27017/tcp
mongo_express_sgbd    mongo-express:latest     Up             0.0.0.0:8081->8081/tcp
```

### 2.2 Vérification du démarrage

```bash
# Vérifier les logs MongoDB
docker-compose logs mongodb

# Vérifier les logs Mongo Express
docker-compose logs mongo-express
```

Vous devriez voir des messages indiquant que MongoDB est prêt :
```
mongodb_sgbd | {"t":{"$date":"..."},"s":"I",  "c":"NETWORK",  "msg":"Waiting for connections","attr":{"port":27017}}
```

### 2.3 Accès à Mongo Express (Interface Web)

Ouvrez votre navigateur et accédez à : **http://localhost:8081**

- **Utilisateur** : `admin`
- **Mot de passe** : `admin`

Vous verrez l'interface Mongo Express avec la base `boutique_electronique` déjà créée.

### 2.4 Connexion au shell MongoDB

Deux méthodes pour accéder au shell MongoDB :

**Méthode 1 : Via Docker exec (recommandé)**
```bash
docker exec -it mongodb_sgbd mongosh -u admin -p admin123 --authenticationDatabase admin
```

**Méthode 2 : Via mongosh installé localement**
```bash
mongosh "mongodb://admin:admin123@localhost:27017/?authSource=admin"
```

**Résultat attendu** :
```
Current Mongosh Log ID:	...
Connecting to:		mongodb://admin:admin123@localhost:27017/?authSource=admin
Using MongoDB:		7.0.x
Using Mongosh:		2.x.x

test>
```

> **💡 Tip** : Pour quitter le shell MongoDB, tapez `exit` ou `Ctrl+D`

---

## 3. Création de base et collection

### 3.1 Concepts MongoDB

| Concept SQL | Équivalent MongoDB | Description |
|-------------|-------------------|-------------|
| **Database** | **Database** | Conteneur de collections |
| **Table** | **Collection** | Groupe de documents |
| **Row** | **Document** | Enregistrement JSON/BSON |
| **Column** | **Field** | Champ d'un document |
| **Index** | **Index** | Même concept |

### 3.2 Sélection de la base de données

```javascript
// Utiliser la base de données boutique_electronique
use boutique_electronique

// Vérifier la base actuelle
db.getName()
```

**Résultat** :
```
switched to db boutique_electronique
boutique_electronique
```

### 3.3 Création de collections

MongoDB crée automatiquement les collections lors de la première insertion, mais on peut les créer explicitement :

```javascript
// Créer la collection "produits"
db.createCollection("produits")

// Créer la collection "clients"
db.createCollection("clients")

// Créer la collection "commandes"
db.createCollection("commandes")

// Lister toutes les collections
show collections
```

**Résultat** :
```
{ ok: 1 }
{ ok: 1 }
{ ok: 1 }
clients
commandes
produits
```

> **💡 Note** : Contrairement aux SGBDR, MongoDB ne nécessite pas de définir un schéma à l'avance. Chaque document peut avoir une structure différente.

---

## 4. Insertion de documents JSON

### 4.1 Insertion d'un document unique (insertOne)

```javascript
// Insérer un produit
db.produits.insertOne({
  nom: "iPhone 15 Pro",
  marque: "Apple",
  categorie: "Smartphones",
  prix: 1199.99,
  stock: 45,
  caracteristiques: {
    ecran: "6.1 pouces OLED",
    processeur: "A17 Pro",
    memoire: "256 GB",
    couleurs: ["Titane naturel", "Titane bleu", "Titane blanc", "Titane noir"]
  },
  disponible: true,
  date_ajout: new Date("2024-09-15")
})
```

**Résultat** :
```javascript
{
  acknowledged: true,
  insertedId: ObjectId('65a1b2c3d4e5f6g7h8i9j0k1')
}
```

> **💡 Note** : MongoDB génère automatiquement un `_id` unique de type ObjectId si non fourni.

### 4.2 Insertion multiple (insertMany)

```javascript
// Insérer plusieurs produits en une seule opération
db.produits.insertMany([
  {
    nom: "Samsung Galaxy S24 Ultra",
    marque: "Samsung",
    categorie: "Smartphones",
    prix: 1299.99,
    stock: 32,
    caracteristiques: {
      ecran: "6.8 pouces Dynamic AMOLED",
      processeur: "Snapdragon 8 Gen 3",
      memoire: "512 GB",
      couleurs: ["Noir", "Gris", "Violet"]
    },
    disponible: true,
    date_ajout: new Date("2024-01-20")
  },
  {
    nom: "MacBook Pro 14",
    marque: "Apple",
    categorie: "Ordinateurs portables",
    prix: 2199.99,
    stock: 18,
    caracteristiques: {
      ecran: "14.2 pouces Liquid Retina XDR",
      processeur: "M3 Pro",
      memoire: "512 GB SSD",
      ram: "18 GB",
      couleurs: ["Gris sidéral", "Argent"]
    },
    disponible: true,
    date_ajout: new Date("2024-11-01")
  },
  {
    nom: "Dell XPS 15",
    marque: "Dell",
    categorie: "Ordinateurs portables",
    prix: 1799.99,
    stock: 12,
    caracteristiques: {
      ecran: "15.6 pouces OLED 4K",
      processeur: "Intel Core i7-13700H",
      memoire: "1 TB SSD",
      ram: "32 GB DDR5",
      couleurs: ["Argent platine"]
    },
    disponible: true,
    date_ajout: new Date("2024-03-10")
  },
  {
    nom: "Sony WH-1000XM5",
    marque: "Sony",
    categorie: "Audio",
    prix: 399.99,
    stock: 67,
    caracteristiques: {
      type: "Casque sans fil",
      reduction_bruit: true,
      autonomie: "30 heures",
      couleurs: ["Noir", "Argent"]
    },
    disponible: true,
    date_ajout: new Date("2024-05-12")
  },
  {
    nom: "AirPods Pro 2",
    marque: "Apple",
    categorie: "Audio",
    prix: 279.99,
    stock: 89,
    caracteristiques: {
      type: "Écouteurs sans fil",
      reduction_bruit: true,
      autonomie: "6 heures",
      couleurs: ["Blanc"]
    },
    disponible: true,
    date_ajout: new Date("2024-09-22")
  }
])
```

**Résultat** :
```javascript
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('65a1b2c3d4e5f6g7h8i9j0k2'),
    '1': ObjectId('65a1b2c3d4e5f6g7h8i9j0k3'),
    '2': ObjectId('65a1b2c3d4e5f6g7h8i9j0k4'),
    '3': ObjectId('65a1b2c3d4e5f6g7h8i9j0k5'),
    '4': ObjectId('65a1b2c3d4e5f6g7h8i9j0k6')
  }
}
```

### 4.3 Insertion de clients

```javascript
db.clients.insertMany([
  {
    nom: "Dupont",
    prenom: "Marie",
    email: "marie.dupont@email.fr",
    telephone: "0612345678",
    adresse: {
      rue: "15 rue de la Paix",
      ville: "Paris",
      code_postal: "75002",
      pays: "France"
    },
    date_inscription: new Date("2023-06-15"),
    premium: true
  },
  {
    nom: "Martin",
    prenom: "Pierre",
    email: "pierre.martin@email.fr",
    telephone: "0623456789",
    adresse: {
      rue: "42 avenue des Champs",
      ville: "Lyon",
      code_postal: "69001",
      pays: "France"
    },
    date_inscription: new Date("2024-01-10"),
    premium: false
  },
  {
    nom: "Bernard",
    prenom: "Sophie",
    email: "sophie.bernard@email.fr",
    telephone: "0634567890",
    adresse: {
      rue: "8 boulevard Victor Hugo",
      ville: "Marseille",
      code_postal: "13001",
      pays: "France"
    },
    date_inscription: new Date("2024-08-22"),
    premium: true
  },
  {
    nom: "Dubois",
    prenom: "Luc",
    email: "luc.dubois@email.fr",
    telephone: "0645678901",
    adresse: {
      rue: "23 rue Nationale",
      ville: "Lille",
      code_postal: "59000",
      pays: "France"
    },
    date_inscription: new Date("2023-11-05"),
    premium: false
  }
])
```

### 4.4 Insertion de commandes

```javascript
db.commandes.insertMany([
  {
    numero_commande: "CMD-2024-001",
    client_email: "marie.dupont@email.fr",
    date_commande: new Date("2024-11-01"),
    statut: "livrée",
    articles: [
      {
        produit: "iPhone 15 Pro",
        quantite: 1,
        prix_unitaire: 1199.99
      },
      {
        produit: "AirPods Pro 2",
        quantite: 1,
        prix_unitaire: 279.99
      }
    ],
    montant_total: 1479.98,
    adresse_livraison: {
      rue: "15 rue de la Paix",
      ville: "Paris",
      code_postal: "75002",
      pays: "France"
    }
  },
  {
    numero_commande: "CMD-2024-002",
    client_email: "pierre.martin@email.fr",
    date_commande: new Date("2024-11-05"),
    statut: "en préparation",
    articles: [
      {
        produit: "MacBook Pro 14",
        quantite: 1,
        prix_unitaire: 2199.99
      }
    ],
    montant_total: 2199.99,
    adresse_livraison: {
      rue: "42 avenue des Champs",
      ville: "Lyon",
      code_postal: "69001",
      pays: "France"
    }
  },
  {
    numero_commande: "CMD-2024-003",
    client_email: "sophie.bernard@email.fr",
    date_commande: new Date("2024-11-08"),
    statut: "expédiée",
    articles: [
      {
        produit: "Sony WH-1000XM5",
        quantite: 2,
        prix_unitaire: 399.99
      }
    ],
    montant_total: 799.98,
    adresse_livraison: {
      rue: "8 boulevard Victor Hugo",
      ville: "Marseille",
      code_postal: "13001",
      pays: "France"
    }
  },
  {
    numero_commande: "CMD-2024-004",
    client_email: "luc.dubois@email.fr",
    date_commande: new Date("2024-11-10"),
    statut: "en préparation",
    articles: [
      {
        produit: "Samsung Galaxy S24 Ultra",
        quantite: 1,
        prix_unitaire: 1299.99
      },
      {
        produit: "Sony WH-1000XM5",
        quantite: 1,
        prix_unitaire: 399.99
      }
    ],
    montant_total: 1699.98,
    adresse_livraison: {
      rue: "23 rue Nationale",
      ville: "Lille",
      code_postal: "59000",
      pays: "France"
    }
  }
])
```

### 4.5 Validation des insertions

```javascript
// Compter le nombre de documents dans chaque collection
db.produits.countDocuments()    // Résultat: 6
db.clients.countDocuments()     // Résultat: 4
db.commandes.countDocuments()   // Résultat: 4

// Afficher un document de chaque collection
db.produits.findOne()
db.clients.findOne()
db.commandes.findOne()
```

---

## 5. Requêtes simples

### 5.1 Requêtes find() basiques

#### Récupérer tous les documents

```javascript
// Tous les produits
db.produits.find()

// Tous les produits (formaté pour la lisibilité)
db.produits.find().pretty()
```

#### Récupérer un seul document

```javascript
// Le premier produit trouvé
db.produits.findOne()

// Un produit spécifique par son nom
db.produits.findOne({ nom: "iPhone 15 Pro" })
```

### 5.2 Filtres par égalité

```javascript
// Tous les produits de la marque Apple
db.produits.find({ marque: "Apple" })

// Tous les produits de la catégorie Smartphones
db.produits.find({ categorie: "Smartphones" })

// Tous les produits disponibles
db.produits.find({ disponible: true })

// Tous les clients premium
db.clients.find({ premium: true })

// Toutes les commandes avec le statut "livrée"
db.commandes.find({ statut: "livrée" })
```

### 5.3 Filtres avec opérateurs de comparaison

```javascript
// Produits avec un prix supérieur à 1000€
db.produits.find({ prix: { $gt: 1000 } })

// Produits avec un prix inférieur ou égal à 500€
db.produits.find({ prix: { $lte: 500 } })

// Produits avec un stock entre 20 et 50 unités
db.produits.find({
  stock: { $gte: 20, $lte: 50 }
})

// Produits avec un prix entre 1000€ et 1500€
db.produits.find({
  prix: { $gte: 1000, $lte: 1500 }
})

// Clients inscrits après le 1er janvier 2024
db.clients.find({
  date_inscription: { $gt: new Date("2024-01-01") }
})
```

**Opérateurs de comparaison** :
| Opérateur | Signification | Exemple |
|-----------|---------------|---------|
| `$eq` | Égal à | `{ prix: { $eq: 1199.99 } }` |
| `$ne` | Différent de | `{ statut: { $ne: "annulée" } }` |
| `$gt` | Supérieur à | `{ prix: { $gt: 1000 } }` |
| `$gte` | Supérieur ou égal | `{ stock: { $gte: 50 } }` |
| `$lt` | Inférieur à | `{ prix: { $lt: 500 } }` |
| `$lte` | Inférieur ou égal | `{ stock: { $lte: 20 } }` |

### 5.4 Filtres avec opérateurs logiques

```javascript
// Produits Apple OU Samsung
db.produits.find({
  $or: [
    { marque: "Apple" },
    { marque: "Samsung" }
  ]
})

// Produits Apple ET prix < 1000€
db.produits.find({
  $and: [
    { marque: "Apple" },
    { prix: { $lt: 1000 } }
  ]
})

// Équivalent (AND implicite)
db.produits.find({
  marque: "Apple",
  prix: { $lt: 1000 }
})

// Produits de catégorie Smartphones OU Audio avec prix < 500€
db.produits.find({
  $or: [
    { categorie: "Smartphones" },
    { categorie: "Audio" }
  ],
  prix: { $lt: 500 }
})

// Produits dont la marque est Apple, Samsung ou Sony
db.produits.find({
  marque: { $in: ["Apple", "Samsung", "Sony"] }
})

// Produits dont la catégorie n'est PAS Smartphones
db.produits.find({
  categorie: { $nin: ["Smartphones"] }
})
```

**Opérateurs logiques** :
| Opérateur | Signification | Exemple |
|-----------|---------------|---------|
| `$and` | ET logique | `{ $and: [{ ... }, { ... }] }` |
| `$or` | OU logique | `{ $or: [{ ... }, { ... }] }` |
| `$not` | NON logique | `{ prix: { $not: { $gt: 1000 } } }` |
| `$nor` | NOR logique | `{ $nor: [{ ... }, { ... }] }` |
| `$in` | Dans la liste | `{ marque: { $in: ["Apple", "Sony"] } }` |
| `$nin` | Pas dans la liste | `{ categorie: { $nin: ["Audio"] } }` |

### 5.5 Requêtes sur des champs imbriqués

```javascript
// Produits avec écran OLED
db.produits.find({ "caracteristiques.ecran": /OLED/ })

// Produits avec 512 GB de mémoire
db.produits.find({ "caracteristiques.memoire": "512 GB" })

// Clients habitant à Paris
db.clients.find({ "adresse.ville": "Paris" })

// Commandes livrées à Lyon
db.commandes.find({ "adresse_livraison.ville": "Lyon" })
```

### 5.6 Projection (sélection de champs)

```javascript
// Afficher uniquement le nom et le prix des produits
db.produits.find({}, { nom: 1, prix: 1 })

// Afficher tous les champs sauf les caractéristiques
db.produits.find({}, { caracteristiques: 0 })

// Nom, prix et marque des produits Apple
db.produits.find(
  { marque: "Apple" },
  { nom: 1, prix: 1, marque: 1, _id: 0 }
)

// Email et ville des clients premium
db.clients.find(
  { premium: true },
  { email: 1, "adresse.ville": 1, _id: 0 }
)
```

> **💡 Note** : Par défaut, `_id` est toujours inclus. Utilisez `_id: 0` pour l'exclure.

### 5.7 Tri (sort) et limitation (limit)

```javascript
// Produits triés par prix croissant
db.produits.find().sort({ prix: 1 })

// Produits triés par prix décroissant
db.produits.find().sort({ prix: -1 })

// Les 3 produits les plus chers
db.produits.find().sort({ prix: -1 }).limit(3)

// Les 2 produits les moins chers de la catégorie Audio
db.produits.find({ categorie: "Audio" }).sort({ prix: 1 }).limit(2)

// Clients triés par date d'inscription (plus récents d'abord)
db.clients.find().sort({ date_inscription: -1 })

// Sauter les 2 premiers résultats et afficher les 3 suivants (pagination)
db.produits.find().sort({ prix: -1 }).skip(2).limit(3)
```

**Paramètres de tri** :
- `1` : Ordre croissant (A→Z, 0→9, ancien→récent)
- `-1` : Ordre décroissant (Z→A, 9→0, récent→ancien)

### 5.8 Comptage et existence

```javascript
// Compter tous les produits
db.produits.countDocuments()

// Compter les produits Apple
db.produits.countDocuments({ marque: "Apple" })

// Compter les produits avec prix > 1000€
db.produits.countDocuments({ prix: { $gt: 1000 } })

// Vérifier si un produit existe
db.produits.findOne({ nom: "iPhone 15 Pro" }) !== null
```

---

## 6. Agrégation basique

### 6.1 Introduction au pipeline d'agrégation

Le **pipeline d'agrégation** permet de transformer et analyser les données en plusieurs étapes séquentielles.

**Étapes principales** :
- `$match` : Filtrer les documents (comme find)
- `$group` : Regrouper et calculer des agrégats
- `$project` : Sélectionner/transformer les champs
- `$sort` : Trier les résultats
- `$limit` : Limiter le nombre de résultats
- `$count` : Compter les documents

### 6.2 Exemple 1 : Nombre de produits par catégorie

```javascript
db.produits.aggregate([
  {
    $group: {
      _id: "$categorie",
      nombre_produits: { $sum: 1 }
    }
  },
  {
    $sort: { nombre_produits: -1 }
  }
])
```

**Résultat** :
```javascript
[
  { _id: 'Smartphones', nombre_produits: 2 },
  { _id: 'Audio', nombre_produits: 2 },
  { _id: 'Ordinateurs portables', nombre_produits: 2 }
]
```

**Explication** :
1. `$group` : Regroupe par catégorie et compte (`$sum: 1`)
2. `$sort` : Trie par nombre décroissant

### 6.3 Exemple 2 : Prix moyen par marque

```javascript
db.produits.aggregate([
  {
    $group: {
      _id: "$marque",
      prix_moyen: { $avg: "$prix" },
      prix_min: { $min: "$prix" },
      prix_max: { $max: "$prix" },
      nombre_produits: { $sum: 1 }
    }
  },
  {
    $sort: { prix_moyen: -1 }
  }
])
```

**Résultat** :
```javascript
[
  {
    _id: 'Apple',
    prix_moyen: 959.99,
    prix_min: 279.99,
    prix_max: 2199.99,
    nombre_produits: 3
  },
  {
    _id: 'Dell',
    prix_moyen: 1799.99,
    prix_min: 1799.99,
    prix_max: 1799.99,
    nombre_produits: 1
  },
  ...
]
```

**Opérateurs d'agrégation** :
| Opérateur | Description | Exemple |
|-----------|-------------|---------|
| `$sum` | Somme | `{ total: { $sum: "$prix" } }` |
| `$avg` | Moyenne | `{ moyenne: { $avg: "$prix" } }` |
| `$min` | Minimum | `{ min: { $min: "$prix" } }` |
| `$max` | Maximum | `{ max: { $max: "$prix" } }` |
| `$count` | Comptage | `{ $count: "total" }` |
| `$push` | Ajouter à un tableau | `{ produits: { $push: "$nom" } }` |

### 6.4 Exemple 3 : Montant total des commandes par statut

```javascript
db.commandes.aggregate([
  {
    $group: {
      _id: "$statut",
      nombre_commandes: { $sum: 1 },
      montant_total: { $sum: "$montant_total" },
      montant_moyen: { $avg: "$montant_total" }
    }
  },
  {
    $sort: { montant_total: -1 }
  }
])
```

**Résultat** :
```javascript
[
  {
    _id: 'en préparation',
    nombre_commandes: 2,
    montant_total: 3899.97,
    montant_moyen: 1949.985
  },
  {
    _id: 'livrée',
    nombre_commandes: 1,
    montant_total: 1479.98,
    montant_moyen: 1479.98
  },
  {
    _id: 'expédiée',
    nombre_commandes: 1,
    montant_total: 799.98,
    montant_moyen: 799.98
  }
]
```

### 6.5 Exemple 4 : Produits les plus commandés

```javascript
db.commandes.aggregate([
  // Étape 1 : Décomposer le tableau articles
  {
    $unwind: "$articles"
  },
  // Étape 2 : Regrouper par produit
  {
    $group: {
      _id: "$articles.produit",
      quantite_totale: { $sum: "$articles.quantite" },
      nombre_commandes: { $sum: 1 },
      revenu_total: {
        $sum: {
          $multiply: ["$articles.quantite", "$articles.prix_unitaire"]
        }
      }
    }
  },
  // Étape 3 : Trier par quantité décroissante
  {
    $sort: { quantite_totale: -1 }
  },
  // Étape 4 : Limiter aux 5 premiers
  {
    $limit: 5
  }
])
```

**Résultat** :
```javascript
[
  {
    _id: 'Sony WH-1000XM5',
    quantite_totale: 3,
    nombre_commandes: 2,
    revenu_total: 1199.97
  },
  {
    _id: 'iPhone 15 Pro',
    quantite_totale: 1,
    nombre_commandes: 1,
    revenu_total: 1199.99
  },
  ...
]
```

**Explication** :
1. `$unwind` : Transforme chaque article d'une commande en document séparé
2. `$group` : Regroupe par nom de produit et calcule les totaux
3. `$sort` : Trie par quantité décroissante
4. `$limit` : Garde seulement les 5 premiers

### 6.6 Exemple 5 : Statistiques clients par ville

```javascript
db.clients.aggregate([
  {
    $group: {
      _id: "$adresse.ville",
      nombre_clients: { $sum: 1 },
      clients_premium: {
        $sum: { $cond: ["$premium", 1, 0] }
      },
      clients_standard: {
        $sum: { $cond: ["$premium", 0, 1] }
      }
    }
  },
  {
    $project: {
      ville: "$_id",
      nombre_clients: 1,
      clients_premium: 1,
      clients_standard: 1,
      pourcentage_premium: {
        $multiply: [
          { $divide: ["$clients_premium", "$nombre_clients"] },
          100
        ]
      },
      _id: 0
    }
  },
  {
    $sort: { nombre_clients: -1 }
  }
])
```

**Résultat** :
```javascript
[
  {
    ville: 'Paris',
    nombre_clients: 1,
    clients_premium: 1,
    clients_standard: 0,
    pourcentage_premium: 100
  },
  {
    ville: 'Lyon',
    nombre_clients: 1,
    clients_premium: 0,
    clients_standard: 1,
    pourcentage_premium: 0
  },
  ...
]
```

**Explication** :
1. `$group` : Regroupe par ville et compte les clients premium/standard avec `$cond`
2. `$project` : Renomme les champs et calcule le pourcentage
3. `$sort` : Trie par nombre de clients

---

## 7. Opérations de mise à jour et suppression

### 7.1 Mise à jour d'un document (updateOne)

```javascript
// Augmenter le stock d'un produit
db.produits.updateOne(
  { nom: "iPhone 15 Pro" },
  { $set: { stock: 50 } }
)

// Augmenter le prix de 10%
db.produits.updateOne(
  { nom: "iPhone 15 Pro" },
  { $mul: { prix: 1.10 } }
)

// Ajouter une couleur
db.produits.updateOne(
  { nom: "iPhone 15 Pro" },
  { $push: { "caracteristiques.couleurs": "Titane rouge" } }
)
```

### 7.2 Mise à jour multiple (updateMany)

```javascript
// Marquer tous les produits Apple comme premium
db.produits.updateMany(
  { marque: "Apple" },
  { $set: { premium: true } }
)

// Réduire le prix de tous les produits Audio de 5%
db.produits.updateMany(
  { categorie: "Audio" },
  { $mul: { prix: 0.95 } }
)
```

### 7.3 Suppression de documents

```javascript
// Supprimer un produit spécifique
db.produits.deleteOne({ nom: "Dell XPS 15" })

// Supprimer tous les produits en rupture de stock
db.produits.deleteMany({ stock: 0 })

// Supprimer toutes les commandes annulées
db.commandes.deleteMany({ statut: "annulée" })
```

> **⚠️ Attention** : Les opérations de suppression sont irréversibles. Utilisez-les avec précaution !

---

## 8. Exercices pratiques

### Exercice 1 : Requêtes simples (Débutant)

1. Trouvez tous les produits de la marque "Sony"
2. Trouvez tous les clients habitant à "Marseille"
3. Trouvez toutes les commandes avec le statut "expédiée"
4. Comptez le nombre de produits disponibles
5. Affichez uniquement le nom et le prix des produits, triés par prix croissant

<details>
<summary>💡 Solutions</summary>

```javascript
// 1.
db.produits.find({ marque: "Sony" })

// 2.
db.clients.find({ "adresse.ville": "Marseille" })

// 3.
db.commandes.find({ statut: "expédiée" })

// 4.
db.produits.countDocuments({ disponible: true })

// 5.
db.produits.find({}, { nom: 1, prix: 1, _id: 0 }).sort({ prix: 1 })
```
</details>

### Exercice 2 : Filtres avancés (Intermédiaire)

1. Trouvez tous les produits avec un prix entre 500€ et 1500€
2. Trouvez tous les produits Apple OU Samsung avec un stock > 30
3. Trouvez tous les clients premium inscrits après le 1er janvier 2024
4. Trouvez les 3 produits les plus chers de la catégorie "Ordinateurs portables"
5. Trouvez tous les produits dont le nom contient "Pro" (utilisez une regex)

<details>
<summary>💡 Solutions</summary>

```javascript
// 1.
db.produits.find({ prix: { $gte: 500, $lte: 1500 } })

// 2.
db.produits.find({
  marque: { $in: ["Apple", "Samsung"] },
  stock: { $gt: 30 }
})

// 3.
db.clients.find({
  premium: true,
  date_inscription: { $gt: new Date("2024-01-01") }
})

// 4.
db.produits.find({ categorie: "Ordinateurs portables" })
  .sort({ prix: -1 })
  .limit(3)

// 5.
db.produits.find({ nom: /Pro/ })
```
</details>

### Exercice 3 : Agrégations (Avancé)

1. Calculez le stock total de tous les produits
2. Trouvez le prix moyen des produits par catégorie
3. Comptez le nombre de commandes par client (utilisez `client_email`)
4. Calculez le chiffre d'affaires total de la boutique
5. Trouvez les 3 villes avec le plus de clients

<details>
<summary>💡 Solutions</summary>

```javascript
// 1.
db.produits.aggregate([
  {
    $group: {
      _id: null,
      stock_total: { $sum: "$stock" }
    }
  }
])

// 2.
db.produits.aggregate([
  {
    $group: {
      _id: "$categorie",
      prix_moyen: { $avg: "$prix" }
    }
  },
  {
    $sort: { prix_moyen: -1 }
  }
])

// 3.
db.commandes.aggregate([
  {
    $group: {
      _id: "$client_email",
      nombre_commandes: { $sum: 1 }
    }
  },
  {
    $sort: { nombre_commandes: -1 }
  }
])

// 4.
db.commandes.aggregate([
  {
    $group: {
      _id: null,
      chiffre_affaires: { $sum: "$montant_total" }
    }
  }
])

// 5.
db.clients.aggregate([
  {
    $group: {
      _id: "$adresse.ville",
      nombre_clients: { $sum: 1 }
    }
  },
  {
    $sort: { nombre_clients: -1 }
  },
  {
    $limit: 3
  }
])
```
</details>

### Exercice 4 : Défi final (Expert)

Créez une agrégation qui :
1. Trouve toutes les commandes "livrées"
2. Décompose les articles de chaque commande
3. Regroupe par produit pour calculer :
   - Le nombre total d'unités vendues
   - Le revenu total généré
   - Le nombre de commandes contenant ce produit
4. Trie par revenu décroissant
5. Affiche uniquement les 3 produits les plus rentables

<details>
<summary>💡 Solution</summary>

```javascript
db.commandes.aggregate([
  {
    $match: { statut: "livrée" }
  },
  {
    $unwind: "$articles"
  },
  {
    $group: {
      _id: "$articles.produit",
      unites_vendues: { $sum: "$articles.quantite" },
      revenu_total: {
        $sum: {
          $multiply: ["$articles.quantite", "$articles.prix_unitaire"]
        }
      },
      nombre_commandes: { $sum: 1 }
    }
  },
  {
    $sort: { revenu_total: -1 }
  },
  {
    $limit: 3
  },
  {
    $project: {
      produit: "$_id",
      unites_vendues: 1,
      revenu_total: 1,
      nombre_commandes: 1,
      _id: 0
    }
  }
])
```
</details>

---

## 9. Nettoyage et arrêt

### 9.1 Supprimer les données de test

```javascript
// Supprimer toutes les collections
db.produits.drop()
db.clients.drop()
db.commandes.drop()

// Ou supprimer toute la base de données
use boutique_electronique
db.dropDatabase()
```

### 9.2 Arrêter les services Docker

```bash
# Arrêter MongoDB et Mongo Express
docker-compose stop mongodb mongo-express

# Ou arrêter et supprimer les conteneurs
docker-compose down

# Supprimer également les volumes (⚠️ supprime les données)
docker-compose down -v
```

---

## 10. Erreurs courantes et solutions

| Erreur | Cause | Solution |
|--------|-------|----------|
| `MongoServerError: Authentication failed` | Mauvais identifiants | Vérifiez `MONGO_INITDB_ROOT_USERNAME` et `PASSWORD` |
| `Connection refused` | MongoDB pas démarré | `docker-compose up -d mongodb` |
| `Database not found` | Base non créée | Utilisez `use nom_base` pour la créer |
| `E11000 duplicate key error` | Clé `_id` en double | MongoDB génère automatiquement `_id`, ne le spécifiez pas |
| `$group requires field name` | Syntaxe incorrecte | Utilisez `"$champ"` avec le `$` pour référencer un champ |
| `Cannot read property of undefined` | Champ inexistant | Vérifiez l'orthographe et la structure du document |

---

## 11. Ressources complémentaires

### Documentation officielle
- [MongoDB Manual](https://www.mongodb.com/docs/manual/)
- [MongoDB University](https://university.mongodb.com/) - Cours gratuits
- [Aggregation Pipeline](https://www.mongodb.com/docs/manual/core/aggregation-pipeline/)

### Outils utiles
- **Mongo Express** : Interface web (http://localhost:8081)
- **MongoDB Compass** : Client GUI officiel
- **Studio 3T** : IDE avancé pour MongoDB
- **NoSQLBooster** : Client avec autocomplétion

### Commandes de référence rapide

```javascript
// Connexion
mongosh "mongodb://admin:admin123@localhost:27017/?authSource=admin"

// Bases de données
show dbs
use nom_base
db.dropDatabase()

// Collections
show collections
db.createCollection("nom")
db.nom_collection.drop()

// CRUD
db.collection.insertOne({...})
db.collection.insertMany([...])
db.collection.find({...})
db.collection.updateOne({...}, {...})
db.collection.deleteOne({...})

// Agrégation
db.collection.aggregate([...])
db.collection.countDocuments({...})

// Index
db.collection.createIndex({ champ: 1 })
db.collection.getIndexes()
```

---

## Conclusion

Félicitations ! 🎉 Vous avez terminé l'atelier MongoDB. Vous savez maintenant :

✅ Configurer MongoDB avec Docker
✅ Créer des bases et collections
✅ Insérer et requêter des documents JSON
✅ Utiliser les opérateurs de filtrage et de comparaison
✅ Effectuer des agrégations complexes
✅ Manipuler les données avec Mongo Express

**Prochaines étapes** :
1. Explorez les index pour optimiser les performances
2. Apprenez la réplication et le sharding pour la scalabilité
3. Découvrez les transactions multi-documents (MongoDB 4.0+)
4. Intégrez MongoDB dans une application (Node.js, Python, Java...)

**Bon courage pour la suite ! 🚀**
