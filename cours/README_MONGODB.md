# Guide de démarrage rapide - MongoDB

## 🚀 Démarrage rapide

### 1. Lancer MongoDB et Mongo Express

```bash
# Depuis la racine du projet
docker-compose up -d mongodb mongo-express
```

### 2. Vérifier que les services sont démarrés

```bash
docker-compose ps
```

Vous devriez voir :
- `mongodb_sgbd` - Status: Up (healthy)
- `mongo_express_sgbd` - Status: Up

### 3. Accéder aux interfaces

| Service | URL | Identifiants |
|---------|-----|--------------|
| **Mongo Express** (Interface web) | http://localhost:8081 | admin / admin |
| **MongoDB** (Shell) | `docker exec -it mongodb_sgbd mongosh -u admin -p admin123 --authenticationDatabase admin` | admin / admin123 |

## 📚 Fichiers de cours

- **`4_1_theorie_nosql.md`** : Cours théorique complet sur NoSQL (BASE vs ACID, types de bases, théorème CAP, etc.)
- **`4_2_atelier_mongodb.md`** : Atelier pratique MongoDB avec exercices

## 🎯 Objectifs de l'atelier

L'atelier MongoDB vous permettra de :
- ✅ Configurer MongoDB avec Docker
- ✅ Créer des bases de données et collections
- ✅ Insérer des documents JSON variés
- ✅ Effectuer des requêtes simples et avancées
- ✅ Utiliser le pipeline d'agrégation
- ✅ Manipuler les données avec Mongo Express

## 🛠️ Configuration Docker

Les services MongoDB ont été ajoutés au fichier `docker-compose.yaml` existant :

### Services ajoutés

1. **mongodb** (port 27017)
   - Image: `mongo:7.0`
   - Base de données initiale: `boutique_electronique`
   - Utilisateur admin: `admin` / `admin123`
   - Volumes persistants pour les données

2. **mongo-express** (port 8081)
   - Interface web d'administration
   - Accès: http://localhost:8081
   - Authentification: `admin` / `admin`

### Volumes créés

- `mongodb_data` : Stockage des données MongoDB
- `mongodb_config` : Configuration MongoDB

## 📖 Commandes utiles

### Gestion des services

```bash
# Démarrer MongoDB uniquement
docker-compose up -d mongodb

# Démarrer MongoDB + Mongo Express
docker-compose up -d mongodb mongo-express

# Arrêter les services
docker-compose stop mongodb mongo-express

# Voir les logs
docker-compose logs mongodb
docker-compose logs mongo-express

# Redémarrer les services
docker-compose restart mongodb mongo-express
```

### Connexion au shell MongoDB

```bash
# Via Docker exec (recommandé)
docker exec -it mongodb_sgbd mongosh -u admin -p admin123 --authenticationDatabase admin

# Commandes MongoDB de base
use boutique_electronique    # Sélectionner la base
show collections             # Lister les collections
db.produits.find()          # Afficher tous les produits
exit                        # Quitter le shell
```

## 🎓 Thème de l'atelier

L'atelier utilise le thème d'une **boutique en ligne de produits électroniques** avec :
- 📱 Collection `produits` : Smartphones, ordinateurs, audio
- 👥 Collection `clients` : Informations clients et adresses
- 📦 Collection `commandes` : Commandes avec articles et statuts

## 🔧 Dépannage

### MongoDB ne démarre pas

```bash
# Vérifier les logs
docker-compose logs mongodb

# Recréer le conteneur
docker-compose down mongodb
docker-compose up -d mongodb
```

### Erreur d'authentification

Vérifiez que vous utilisez les bons identifiants :
- Utilisateur : `admin`
- Mot de passe : `admin123`
- Base d'authentification : `admin`

### Mongo Express ne se connecte pas

```bash
# Vérifier que MongoDB est healthy
docker-compose ps

# Redémarrer Mongo Express
docker-compose restart mongo-express
```

### Supprimer toutes les données

```bash
# Arrêter et supprimer les volumes (⚠️ supprime toutes les données)
docker-compose down -v
```

## 📊 Ports utilisés

| Service | Port | Description |
|---------|------|-------------|
| PostgreSQL | 5432 | Base de données relationnelle |
| Metabase | 3000 | Interface de visualisation |
| pgAdmin | 8080 | Administration PostgreSQL |
| **MongoDB** | **27017** | **Base de données NoSQL** |
| **Mongo Express** | **8081** | **Interface web MongoDB** |

## 🎯 Prochaines étapes

1. Suivez le cours théorique : `4_1_theorie_nosql.md`
2. Réalisez l'atelier pratique : `4_2_atelier_mongodb.md`
3. Complétez les exercices pratiques
4. Explorez Mongo Express pour visualiser vos données

## 📚 Ressources complémentaires

- [Documentation MongoDB](https://www.mongodb.com/docs/manual/)
- [MongoDB University](https://university.mongodb.com/) - Cours gratuits
- [Mongo Express GitHub](https://github.com/mongo-express/mongo-express)

---

**Bon apprentissage ! 🚀**

