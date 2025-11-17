# MongoDB Avancé : Indexes, Sharding, Réplication et Transactions

## Objectifs pédagogiques

À la fin de ce cours, vous serez capable de :
- ✅ Créer et gérer différents types d'index MongoDB
- ✅ Comprendre le sharding et la distribution horizontale
- ✅ Configurer et utiliser les replica sets
- ✅ Implémenter des transactions multi-documents
- ✅ Intégrer ces fonctionnalités avancées avec PyMongo
- ✅ Optimiser les performances de vos requêtes MongoDB

---

## 1. Les Index MongoDB

### 1.1 Pourquoi les index ?

Les index améliorent drastiquement les performances des requêtes en évitant le **scan complet de collection** (collection scan). Sans index, MongoDB doit examiner chaque document pour trouver les résultats.

**Analogie** : Un index est comme l'index d'un livre - au lieu de lire toutes les pages, vous consultez l'index pour trouver directement la page recherchée.

#### Impact sur les performances

```javascript
// Sans index : O(n) - scan complet
db.produits.find({ prix: { $gt: 1000 } })  // Examine TOUS les documents

// Avec index sur "prix" : O(log n) - recherche optimisée
db.produits.createIndex({ prix: 1 })
db.produits.find({ prix: { $gt: 1000 } })  // Utilise l'index
```

**Métriques de performance** :
- **Collection scan** : 100 000 documents → ~500ms
- **Avec index** : 100 000 documents → ~5ms (100x plus rapide)

### 1.2 Types d'index MongoDB

#### 1.2.1 Index sur un seul champ (Single Field Index)

L'index le plus simple, créé sur un seul champ.

```javascript
// Créer un index ascendant sur le champ "email"
db.clients.createIndex({ email: 1 })

// Créer un index descendant sur le champ "date_inscription"
db.clients.createIndex({ date_inscription: -1 })

// Index unique (empêche les doublons)
db.clients.createIndex({ email: 1 }, { unique: true })
```

**Ordre de l'index** :
- `1` : Ordre ascendant (A→Z, 0→9, dates anciennes→récentes)
- `-1` : Ordre descendant (Z→A, 9→0, dates récentes→anciennes)

> **💡 Note** : Pour les index sur un seul champ, l'ordre (1 ou -1) importe peu pour les requêtes simples. Il devient important pour les tris et les index composés.

#### 1.2.2 Index composé (Compound Index)

Index sur plusieurs champs, utile pour les requêtes multi-critères.

```javascript
// Index composé sur marque (ascendant) et prix (descendant)
db.produits.createIndex({ marque: 1, prix: -1 })

// Optimise ces requêtes :
db.produits.find({ marque: "Apple" }).sort({ prix: -1 })
db.produits.find({ marque: "Samsung", prix: { $lt: 1000 } })
```

**Règle ESR (Equality, Sort, Range)** :
1. **E**quality : Champs avec égalité exacte en premier
2. **S**ort : Champs de tri ensuite
3. **R**ange : Champs avec plages ($gt, $lt) en dernier

```javascript
// Requête : marque = "Apple", prix < 2000, tri par stock
// Index optimal selon ESR :
db.produits.createIndex({ marque: 1, stock: 1, prix: 1 })
```

**Préfixe d'index** : Un index composé `{ a: 1, b: 1, c: 1 }` peut servir pour :
- `{ a: 1 }`
- `{ a: 1, b: 1 }`
- `{ a: 1, b: 1, c: 1 }`

Mais **PAS** pour `{ b: 1 }` ou `{ c: 1 }` seuls.

#### 1.2.3 Index multikey (Multikey Index)

Automatiquement créé quand on indexe un champ de type tableau.

```javascript
// Document avec tableau
db.produits.insertOne({
  nom: "iPhone 15 Pro",
  caracteristiques: {
    couleurs: ["Titane naturel", "Titane bleu", "Titane blanc", "Titane noir"]
  }
})

// Index multikey sur le tableau
db.produits.createIndex({ "caracteristiques.couleurs": 1 })

// Recherche efficace dans le tableau
db.produits.find({ "caracteristiques.couleurs": "Titane bleu" })
```

> **⚠️ Limitation** : On ne peut pas créer un index composé avec deux champs de type tableau.

#### 1.2.4 Index texte (Text Index)

Permet la recherche full-text dans les champs textuels.

```javascript
// Créer un index texte sur le champ "nom"
db.produits.createIndex({ nom: "text" })

// Recherche textuelle
db.produits.find({ $text: { $search: "iPhone Pro" } })

// Index texte sur plusieurs champs
db.produits.createIndex({ 
  nom: "text", 
  description: "text" 
}, {
  weights: {
    nom: 10,        // Nom a plus de poids
    description: 5
  }
})

// Recherche avec score de pertinence
db.produits.find(
  { $text: { $search: "smartphone Apple" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })
```

**Fonctionnalités** :
- Recherche de mots-clés (tokenization)
- Support des langues (stemming, stop words)
- Score de pertinence
- Recherche de phrases exactes avec guillemets : `"iPhone Pro"`

#### 1.2.5 Index géospatial (Geospatial Index)

Pour les requêtes de proximité géographique.

```javascript
// Document avec coordonnées GPS
db.magasins.insertOne({
  nom: "Apple Store Champs-Élysées",
  localisation: {
    type: "Point",
    coordinates: [2.3074, 48.8698]  // [longitude, latitude]
  }
})

// Index géospatial 2dsphere (pour coordonnées GPS)
db.magasins.createIndex({ localisation: "2dsphere" })

// Trouver les magasins dans un rayon de 5 km
db.magasins.find({
  localisation: {
    $near: {
      $geometry: {
        type: "Point",
        coordinates: [2.3522, 48.8566]  // Tour Eiffel
      },
      $maxDistance: 5000  // 5 km en mètres
    }
  }
})
```

**Types d'index géospatiaux** :
- `2dsphere` : Coordonnées GPS (longitude, latitude) sur une sphère
- `2d` : Coordonnées planes (x, y) - rarement utilisé

### 1.3 Gestion des index

#### Lister les index existants

```javascript
// Lister tous les index d'une collection
db.produits.getIndexes()

// Résultat exemple :
[
  { v: 2, key: { _id: 1 }, name: "_id_" },  // Index par défaut
  { v: 2, key: { marque: 1, prix: -1 }, name: "marque_1_prix_-1" },
  { v: 2, key: { email: 1 }, name: "email_1", unique: true }
]
```

#### Supprimer un index

```javascript
// Supprimer par nom
db.produits.dropIndex("marque_1_prix_-1")

// Supprimer par définition
db.produits.dropIndex({ marque: 1, prix: -1 })

// Supprimer tous les index (sauf _id)
db.produits.dropIndexes()
```

#### Analyser l'utilisation d'un index

```javascript
// Utiliser explain() pour voir le plan d'exécution
db.produits.find({ marque: "Apple", prix: { $lt: 1500 } }).explain("executionStats")

// Informations importantes dans le résultat :
// - winningPlan.stage : "IXSCAN" (utilise index) ou "COLLSCAN" (scan complet)
// - executionStats.totalDocsExamined : nombre de documents examinés
// - executionStats.executionTimeMillis : temps d'exécution
```

**Exemple de résultat** :
```javascript
{
  executionStats: {
    executionTimeMillis: 5,
    totalDocsExamined: 150,      // Avec index
    totalKeysExamined: 150,
    nReturned: 45
  },
  winningPlan: {
    stage: "FETCH",
    inputStage: {
      stage: "IXSCAN",             // Utilise l'index
      indexName: "marque_1_prix_-1"
    }
  }
}
```

### 1.4 Bonnes pratiques pour les index

✅ **À faire** :
- Créer des index sur les champs fréquemment utilisés dans les requêtes
- Utiliser des index composés pour les requêtes multi-critères
- Appliquer la règle ESR (Equality, Sort, Range)
- Analyser les requêtes lentes avec `explain()`
- Créer des index uniques pour garantir l'unicité

❌ **À éviter** :
- Trop d'index (ralentit les écritures et consomme de la mémoire)
- Index sur des champs rarement utilisés
- Index sur des champs avec peu de valeurs distinctes (ex: booléens)
- Dupliquer des index (ex: `{a: 1}` et `{a: 1, b: 1}`)

**Règle générale** : Un index améliore les lectures mais ralentit les écritures. Trouvez le bon équilibre selon votre charge de travail (read-heavy vs write-heavy).

---

## 2. Le Sharding (Distribution Horizontale)

### 2.1 Qu'est-ce que le sharding ?

Le **sharding** est la méthode de MongoDB pour distribuer les données sur plusieurs serveurs (shards), permettant une **scalabilité horizontale** illimitée.

```mermaid
graph TB
    APP[Application] --> ROUTER[mongos<br/>Query Router]
    ROUTER --> CONFIG[Config Servers<br/>Métadonnées]
    ROUTER --> SHARD1[Shard 1<br/>Replica Set<br/>Données A-M]
    ROUTER --> SHARD2[Shard 2<br/>Replica Set<br/>Données N-Z]
    ROUTER --> SHARD3[Shard 3<br/>Replica Set<br/>Données 0-9]

    style ROUTER fill:#e6f3ff
    style CONFIG fill:#fff0e6
    style SHARD1 fill:#e6ffe6
    style SHARD2 fill:#e6ffe6
    style SHARD3 fill:#e6ffe6
```

**Composants d'un cluster shardé** :
- **Shards** : Serveurs qui stockent les données (chacun est un replica set)
- **mongos** : Routeur de requêtes (query router) - point d'entrée pour les applications
- **Config Servers** : Stockent les métadonnées du cluster (mapping des données)

### 2.2 Clé de sharding (Shard Key)

La **shard key** détermine comment les données sont distribuées entre les shards.

#### Choix de la shard key

**Critères importants** :
1. **Cardinalité** : Beaucoup de valeurs distinctes (éviter les booléens)
2. **Distribution** : Répartition uniforme des données
3. **Localité** : Requêtes ciblant un seul shard si possible

**Exemples de bonnes shard keys** :
```javascript
// E-commerce : ID utilisateur (bonne cardinalité)
sh.shardCollection("boutique.commandes", { user_id: 1 })

// IoT : Combinaison timestamp + device_id
sh.shardCollection("iot.mesures", { device_id: 1, timestamp: 1 })

// Logs : Hash de l'ID (distribution uniforme)
sh.shardCollection("logs.events", { _id: "hashed" })
```

**Exemples de mauvaises shard keys** :
```javascript
// ❌ Booléen (seulement 2 valeurs)
sh.shardCollection("boutique.produits", { disponible: 1 })

// ❌ Timestamp seul (hotspot sur le shard le plus récent)
sh.shardCollection("logs.events", { timestamp: 1 })

// ❌ Pays (distribution inégale si beaucoup d'utilisateurs d'un pays)
sh.shardCollection("users.profiles", { pays: 1 })
```

### 2.3 Distribution des chunks

MongoDB divise les données en **chunks** (blocs de 64 MB par défaut) et les distribue entre les shards.

```javascript
// Exemple de distribution
Shard 1: chunks [minKey → "M"]
Shard 2: chunks ["M" → "Z"]
Shard 3: chunks ["Z" → maxKey]
```

**Balancer** : Processus automatique qui redistribue les chunks pour équilibrer la charge.

### 2.4 Quand utiliser le sharding ?

✅ **Utiliser le sharding quand** :
- Volume de données > 2-5 TB
- Débit de requêtes > 100 000 ops/sec
- Croissance rapide des données
- Besoin de scalabilité horizontale

❌ **Ne PAS utiliser le sharding quand** :
- Volume de données < 1 TB
- Replica set unique suffit
- Complexité opérationnelle non justifiée
- Budget limité (coût de plusieurs serveurs)

> **💡 Conseil** : Commencez avec un replica set. Passez au sharding uniquement quand nécessaire. Le sharding ajoute de la complexité opérationnelle.

---

## 3. La Réplication (Replica Sets)

### 3.1 Qu'est-ce qu'un replica set ?

Un **replica set** est un groupe de serveurs MongoDB qui maintiennent les mêmes données, assurant **haute disponibilité** et **redondance**.

```mermaid
graph LR
    APP[Application] --> PRIMARY[Primary<br/>Lectures & Écritures]
    PRIMARY -->|Réplication<br/>asynchrone| SECONDARY1[Secondary 1<br/>Lectures optionnelles]
    PRIMARY -->|Réplication<br/>asynchrone| SECONDARY2[Secondary 2<br/>Lectures optionnelles]
    PRIMARY -.->|Heartbeat| SECONDARY1
    PRIMARY -.->|Heartbeat| SECONDARY2
    SECONDARY1 -.->|Heartbeat| SECONDARY2

    style PRIMARY fill:#ffcccc
    style SECONDARY1 fill:#ccffcc
    style SECONDARY2 fill:#ccffcc
```

**Rôles des nœuds** :
- **Primary** : Reçoit toutes les écritures et lectures par défaut
- **Secondary** : Réplique les données du primary, peut servir les lectures
- **Arbiter** : Participe aux élections mais ne stocke pas de données (optionnel)

### 3.2 Failover automatique (Automatic Failover)

Si le primary tombe en panne, un secondary est **automatiquement élu** comme nouveau primary.

```mermaid
sequenceDiagram
    participant App as Application
    participant P as Primary
    participant S1 as Secondary 1
    participant S2 as Secondary 2

    App->>P: Écriture
    P->>S1: Réplication
    P->>S2: Réplication

    Note over P: ❌ Panne du Primary

    S1->>S2: Élection
    S2->>S1: Vote

    Note over S1: ✅ S1 devient Primary

    App->>S1: Écriture (nouveau primary)
    S1->>S2: Réplication
```

**Processus d'élection** :
1. Les secondaries détectent la panne du primary (heartbeat manquant)
2. Un secondary lance une élection
3. Les nœuds votent (majorité requise)
4. Le nœud avec le plus de votes devient primary
5. L'application se reconnecte automatiquement au nouveau primary

**Temps de failover** : Généralement 10-30 secondes

### 3.3 Read Preferences (Préférences de lecture)

Contrôle où les lectures sont dirigées dans un replica set.

```javascript
// Modes de read preference :

// 1. primary (défaut) - Toutes les lectures sur le primary
db.produits.find().readPref("primary")

// 2. primaryPreferred - Primary si disponible, sinon secondary
db.produits.find().readPref("primaryPreferred")

// 3. secondary - Toujours lire depuis un secondary
db.produits.find().readPref("secondary")

// 4. secondaryPreferred - Secondary si disponible, sinon primary
db.produits.find().readPref("secondaryPreferred")

// 5. nearest - Nœud avec la latence la plus faible
db.produits.find().readPref("nearest")
```

**Cas d'usage** :
- `primary` : Cohérence stricte requise (données financières)
- `secondary` : Rapports, analytics (tolérance à un léger délai)
- `nearest` : Applications géo-distribuées (minimiser la latence)

> **⚠️ Attention** : Lire depuis un secondary peut retourner des données légèrement obsolètes (réplication asynchrone).

### 3.4 Write Concerns (Garanties d'écriture)

Contrôle le niveau de confirmation requis pour une écriture.

```javascript
// w: 1 (défaut) - Confirmation du primary uniquement
db.commandes.insertOne(
  { client: "Alice", montant: 150 },
  { writeConcern: { w: 1 } }
)

// w: "majority" - Confirmation de la majorité des nœuds
db.commandes.insertOne(
  { client: "Bob", montant: 500 },
  { writeConcern: { w: "majority", wtimeout: 5000 } }
)

// w: 3 - Confirmation de 3 nœuds spécifiques
db.commandes.insertOne(
  { client: "Charlie", montant: 1000 },
  { writeConcern: { w: 3 } }
)

// j: true - Confirmation après écriture dans le journal (journal)
db.commandes.insertOne(
  { client: "David", montant: 2000 },
  { writeConcern: { w: "majority", j: true } }
)
```

**Paramètres** :
- `w` : Nombre de nœuds devant confirmer (1, 2, 3, "majority")
- `j` : Attendre l'écriture dans le journal (true/false)
- `wtimeout` : Timeout en millisecondes

**Trade-off** :
- `w: 1` → Rapide mais moins durable
- `w: "majority"` → Plus lent mais plus durable (recommandé pour données critiques)

---

## 4. Transactions Multi-Documents

### 4.1 Introduction aux transactions ACID

Depuis MongoDB 4.0, les **transactions multi-documents** permettent d'effectuer plusieurs opérations de manière atomique.

**Propriétés ACID** :
- **Atomicité** : Tout ou rien (commit ou rollback)
- **Cohérence** : Les données respectent les règles
- **Isolation** : Les transactions concurrentes ne s'interfèrent pas
- **Durabilité** : Les changements validés sont permanents

### 4.2 Utilisation des transactions en MongoDB Shell

```javascript
// Démarrer une session
const session = db.getMongo().startSession()

// Démarrer une transaction
session.startTransaction()

try {
  const commandesDB = session.getDatabase("boutique").commandes
  const produitsDB = session.getDatabase("boutique").produits

  // Opération 1 : Créer une commande
  commandesDB.insertOne({
    client_email: "alice@email.fr",
    produit_id: ObjectId("654000000000000000000021"),
    quantite: 2,
    montant_total: 2399.98,
    date_commande: new Date()
  })

  // Opération 2 : Décrémenter le stock
  const result = produitsDB.updateOne(
    { _id: ObjectId("654000000000000000000021"), stock: { $gte: 2 } },
    { $inc: { stock: -2 } }
  )

  // Vérifier que le stock était suffisant
  if (result.matchedCount === 0) {
    throw new Error("Stock insuffisant")
  }

  // Valider la transaction
  session.commitTransaction()
  print("Transaction réussie !")

} catch (error) {
  // Annuler la transaction en cas d'erreur
  session.abortTransaction()
  print("Transaction annulée :", error)

} finally {
  session.endSession()
}
```

### 4.3 Bonnes pratiques pour les transactions

✅ **À faire** :
- Garder les transactions courtes (< 60 secondes)
- Limiter le nombre d'opérations par transaction
- Utiliser `w: "majority"` pour les write concerns
- Gérer les erreurs et les retry (tentatives multiples)

❌ **À éviter** :
- Transactions longues (risque de timeout)
- Trop d'opérations dans une transaction
- Transactions sur des collections non shardées et shardées mélangées
- Utiliser les transactions quand ce n'est pas nécessaire (overhead de performance)

**Limitations** :
- Transactions limitées à 16 MB de données modifiées
- Timeout par défaut : 60 secondes
- Performance réduite par rapport aux opérations simples

---

## 5. Intégration Python avec PyMongo

### 5.1 Installation et connexion

```bash
# Installer PyMongo
pip install pymongo
```

```python
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

# Connexion simple
client = MongoClient("mongodb://admin:admin123@localhost:27017/")

# Vérifier la connexion
try:
    client.admin.command('ping')
    print("✅ Connexion réussie à MongoDB")
except ConnectionFailure:
    print("❌ Échec de connexion")

# Sélectionner la base de données
db = client.boutique_electronique

# Sélectionner une collection
produits = db.produits
```

### 5.2 Gestion des index avec PyMongo

```python
from pymongo import ASCENDING, DESCENDING, TEXT, GEOSPHERE

# Créer un index simple
produits.create_index([("marque", ASCENDING)])

# Créer un index composé
produits.create_index([
    ("marque", ASCENDING),
    ("prix", DESCENDING)
])

# Créer un index unique
clients = db.clients
clients.create_index([("email", ASCENDING)], unique=True)

# Créer un index texte
produits.create_index([("nom", TEXT), ("description", TEXT)])

# Créer un index géospatial
magasins = db.magasins
magasins.create_index([("localisation", GEOSPHERE)])

# Lister tous les index
for index in produits.list_indexes():
    print(index)

# Supprimer un index
produits.drop_index("marque_1_prix_-1")

# Analyser une requête avec explain()
resultat = produits.find({"marque": "Apple"}).explain()
print(f"Stage: {resultat['executionStats']['executionStages']['stage']}")
print(f"Temps: {resultat['executionStats']['executionTimeMillis']} ms")
```

### 5.3 Connexion à un Replica Set avec PyMongo

```python
from pymongo import MongoClient, ReadPreference

# Connexion à un replica set
client = MongoClient(
    "mongodb://admin:admin123@localhost:27017,localhost:27018,localhost:27019/",
    replicaSet="rs0",
    authSource="admin"
)

db = client.boutique_electronique
produits = db.produits

# Utiliser différentes read preferences
# Lire depuis le primary (défaut)
produits_primary = produits.with_options(
    read_preference=ReadPreference.PRIMARY
)

# Lire depuis un secondary
produits_secondary = produits.with_options(
    read_preference=ReadPreference.SECONDARY
)

# Lire depuis le nœud le plus proche
produits_nearest = produits.with_options(
    read_preference=ReadPreference.NEAREST
)

# Exemple : Rapports depuis secondary pour ne pas surcharger le primary
rapports = produits_secondary.aggregate([
    {"$group": {"_id": "$categorie", "total": {"$sum": 1}}}
])

for rapport in rapports:
    print(rapport)
```

### 5.4 Transactions multi-documents avec PyMongo

```python
from pymongo import MongoClient
from pymongo.errors import PyMongoError

client = MongoClient("mongodb://admin:admin123@localhost:27017/")
db = client.boutique_electronique

def passer_commande(client_email, produit_id, quantite):
    """
    Passe une commande en utilisant une transaction pour garantir l'atomicité.
    """
    # Démarrer une session
    with client.start_session() as session:
        # Démarrer une transaction
        with session.start_transaction():
            try:
                # Collection commandes
                commandes = db.commandes
                # Collection produits
                produits = db.produits

                # 1. Vérifier le stock disponible
                produit = produits.find_one(
                    {"_id": produit_id},
                    session=session
                )

                if not produit:
                    raise ValueError("Produit introuvable")

                if produit["stock"] < quantite:
                    raise ValueError(f"Stock insuffisant. Disponible: {produit['stock']}")

                # 2. Créer la commande
                montant_total = produit["prix"] * quantite
                commande = {
                    "client_email": client_email,
                    "produit_id": produit_id,
                    "produit_nom": produit["nom"],
                    "quantite": quantite,
                    "prix_unitaire": produit["prix"],
                    "montant_total": montant_total,
                    "statut": "confirmée",
                    "date_commande": datetime.now()
                }

                result_commande = commandes.insert_one(commande, session=session)

                # 3. Décrémenter le stock
                result_stock = produits.update_one(
                    {"_id": produit_id},
                    {"$inc": {"stock": -quantite}},
                    session=session
                )

                # 4. Vérifier que la mise à jour a réussi
                if result_stock.modified_count == 0:
                    raise ValueError("Échec de la mise à jour du stock")

                print(f"✅ Commande {result_commande.inserted_id} créée avec succès")
                print(f"   Montant total: {montant_total}€")
                print(f"   Stock restant: {produit['stock'] - quantite}")

                # La transaction est automatiquement validée à la fin du bloc with
                return result_commande.inserted_id

            except Exception as e:
                # La transaction est automatiquement annulée en cas d'exception
                print(f"❌ Erreur lors de la commande: {e}")
                raise

# Exemple d'utilisation
from bson import ObjectId
from datetime import datetime

try:
    commande_id = passer_commande(
        client_email="alice@email.fr",
        produit_id=ObjectId("654000000000000000000021"),
        quantite=2
    )
except Exception as e:
    print(f"La commande a échoué: {e}")
```

### 5.5 Optimisation et monitoring avec PyMongo

```python
from pymongo import MongoClient
import time

client = MongoClient("mongodb://admin:admin123@localhost:27017/")
db = client.boutique_electronique
produits = db.produits

# 1. Profiling des requêtes lentes
# Activer le profiler (niveau 1 = requêtes lentes uniquement)
db.set_profiling_level(1, slow_ms=100)  # Requêtes > 100ms

# Exécuter des requêtes
produits.find({"prix": {"$gt": 1000}}).limit(10).to_list()

# Consulter les requêtes lentes
requetes_lentes = db.system.profile.find().sort("ts", -1).limit(5)
for requete in requetes_lentes:
    print(f"Durée: {requete['millis']}ms")
    print(f"Opération: {requete['op']}")
    print(f"Namespace: {requete['ns']}")
    print("---")

# 2. Mesurer les performances d'une requête
def mesurer_performance(requete_func, nom="Requête"):
    """Mesure le temps d'exécution d'une requête."""
    start = time.time()
    resultat = list(requete_func())
    duree = (time.time() - start) * 1000  # en ms
    print(f"{nom}: {duree:.2f}ms - {len(resultat)} résultats")
    return resultat

# Sans index
mesurer_performance(
    lambda: produits.find({"marque": "Apple", "prix": {"$lt": 1500}}),
    "Sans index"
)

# Créer un index
produits.create_index([("marque", 1), ("prix", 1)])

# Avec index
mesurer_performance(
    lambda: produits.find({"marque": "Apple", "prix": {"$lt": 1500}}),
    "Avec index"
)

# 3. Statistiques de collection
stats = db.command("collStats", "produits")
print(f"Nombre de documents: {stats['count']}")
print(f"Taille des données: {stats['size'] / 1024 / 1024:.2f} MB")
print(f"Taille des index: {stats['totalIndexSize'] / 1024 / 1024:.2f} MB")
print(f"Nombre d'index: {len(stats['indexSizes'])}")

# 4. Utiliser les hints pour forcer un index
# Forcer l'utilisation d'un index spécifique
resultats = produits.find(
    {"marque": "Apple", "prix": {"$lt": 1500}}
).hint([("marque", 1), ("prix", 1)])

# 5. Batch processing pour les grandes collections
def traiter_par_batch(collection, filtre, batch_size=1000):
    """Traite les documents par lots pour économiser la mémoire."""
    cursor = collection.find(filtre).batch_size(batch_size)

    for document in cursor:
        # Traiter chaque document
        # Par exemple : mise à jour, export, etc.
        pass

# Exemple : Mettre à jour tous les produits Apple
traiter_par_batch(
    produits,
    {"marque": "Apple"},
    batch_size=500
)
```

---

## 6. Exercices Pratiques

### Exercice 1 : Optimisation avec index

En utilisant la base de données `boutique_electronique` de l'atelier 4.2 :

1. Créez un index composé sur `marque` et `prix` pour optimiser les recherches de produits par marque avec tri par prix
2. Créez un index texte sur les champs `nom` et `description` pour permettre la recherche full-text
3. Analysez avec `explain()` la différence de performance avant et après la création des index
4. Créez un index unique sur `email` dans la collection `clients`

<details>
<summary>💡 Solution</summary>

```python
from pymongo import MongoClient, ASCENDING, DESCENDING, TEXT

client = MongoClient("mongodb://admin:admin123@localhost:27017/")
db = client.boutique_electronique

# 1. Index composé
db.produits.create_index([("marque", ASCENDING), ("prix", DESCENDING)])

# 2. Index texte
db.produits.create_index([("nom", TEXT), ("description", TEXT)])

# 3. Analyse de performance
# Sans index
resultat_sans = db.produits.find({"marque": "Apple"}).explain()
print(f"Sans index: {resultat_sans['executionStats']['executionTimeMillis']}ms")

# Avec index
resultat_avec = db.produits.find({"marque": "Apple"}).explain()
print(f"Avec index: {resultat_avec['executionStats']['executionTimeMillis']}ms")

# 4. Index unique
db.clients.create_index([("email", ASCENDING)], unique=True)
```
</details>

### Exercice 2 : Transaction de commande

Implémentez une fonction Python qui :
1. Vérifie qu'un produit existe et a suffisamment de stock
2. Crée une commande dans la collection `commandes`
3. Décrémente le stock du produit
4. Utilise une transaction pour garantir l'atomicité

<details>
<summary>💡 Solution</summary>

Voir la section 5.4 pour la solution complète de la fonction `passer_commande()`.
</details>

### Exercice 3 : Recherche géospatiale

1. Ajoutez des coordonnées GPS à quelques documents de la collection `magasins`
2. Créez un index géospatial sur le champ `localisation`
3. Trouvez tous les magasins dans un rayon de 10 km autour d'un point donné

<details>
<summary>💡 Solution</summary>

```python
from pymongo import MongoClient, GEOSPHERE

client = MongoClient("mongodb://admin:admin123@localhost:27017/")
db = client.boutique_electronique

# 1. Ajouter des magasins avec coordonnées
db.magasins.insert_many([
    {
        "nom": "Apple Store Champs-Élysées",
        "localisation": {
            "type": "Point",
            "coordinates": [2.3074, 48.8698]  # [longitude, latitude]
        }
    },
    {
        "nom": "Apple Store Opéra",
        "localisation": {
            "type": "Point",
            "coordinates": [2.3319, 48.8708]
        }
    }
])

# 2. Créer l'index géospatial
db.magasins.create_index([("localisation", GEOSPHERE)])

# 3. Recherche dans un rayon de 10 km
magasins_proches = db.magasins.find({
    "localisation": {
        "$near": {
            "$geometry": {
                "type": "Point",
                "coordinates": [2.3522, 48.8566]  # Tour Eiffel
            },
            "$maxDistance": 10000  # 10 km en mètres
        }
    }
})

for magasin in magasins_proches:
    print(f"{magasin['nom']}")
```
</details>

---

## 7. Ressources complémentaires

### Documentation officielle
- [MongoDB Indexes](https://www.mongodb.com/docs/manual/indexes/)
- [MongoDB Sharding](https://www.mongodb.com/docs/manual/sharding/)
- [MongoDB Replication](https://www.mongodb.com/docs/manual/replication/)
- [MongoDB Transactions](https://www.mongodb.com/docs/manual/core/transactions/)
- [PyMongo Documentation](https://pymongo.readthedocs.io/)

### Outils de monitoring
- **MongoDB Atlas** : Service cloud avec monitoring intégré
- **MongoDB Compass** : Interface graphique avec analyse de performance
- **mongostat** : Statistiques en temps réel
- **mongotop** : Temps passé par collection

### Commandes utiles

```bash
# Statistiques du serveur
mongosh --eval "db.serverStatus()"

# Statistiques d'une base de données
mongosh --eval "db.stats()"

# Lister les index d'une collection
mongosh --eval "db.produits.getIndexes()"

# Profiler les requêtes lentes
mongosh --eval "db.setProfilingLevel(1, {slowms: 100})"
mongosh --eval "db.system.profile.find().sort({ts: -1}).limit(5)"
```

---

## 8. Résumé et bonnes pratiques

### Points clés à retenir

✅ **Index** :
- Créez des index sur les champs fréquemment interrogés
- Utilisez la règle ESR pour les index composés
- Analysez avec `explain()` pour vérifier l'utilisation des index
- Évitez trop d'index (ralentit les écritures)

✅ **Sharding** :
- Utilisez uniquement pour les très gros volumes (> 2 TB)
- Choisissez une shard key avec bonne cardinalité et distribution
- Commencez avec un replica set, passez au sharding si nécessaire

✅ **Réplication** :
- Utilisez toujours un replica set en production (minimum 3 nœuds)
- Configurez les read preferences selon vos besoins
- Utilisez `w: "majority"` pour les données critiques

✅ **Transactions** :
- Utilisez uniquement quand nécessaire (overhead de performance)
- Gardez les transactions courtes (< 60 secondes)
- Gérez les erreurs et implémentez des retry logic

✅ **PyMongo** :
- Réutilisez les connexions (connection pooling)
- Utilisez les transactions pour les opérations multi-documents critiques
- Profilez et optimisez vos requêtes régulièrement

### Checklist de production

Avant de déployer MongoDB en production :

- [ ] Replica set configuré (minimum 3 nœuds)
- [ ] Index créés sur les champs fréquemment interrogés
- [ ] Write concern configuré (`w: "majority"` pour données critiques)
- [ ] Monitoring activé (logs, métriques, alertes)
- [ ] Backups automatiques configurés
- [ ] Authentification et autorisation activées
- [ ] Connexions SSL/TLS configurées
- [ ] Limites de ressources définies (CPU, RAM, disque)
- [ ] Plan de disaster recovery documenté

---

**Félicitations !** Vous maîtrisez maintenant les concepts avancés de MongoDB. Continuez à pratiquer avec des cas d'usage réels pour approfondir vos compétences.
