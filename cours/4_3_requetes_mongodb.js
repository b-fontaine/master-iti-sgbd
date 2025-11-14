// ============================================================================
// Fichier complémentaire : 10 requêtes MongoDB pour l'exercice de comparaison
// Thème : Système de gestion de bibliothèque
// ============================================================================

// Connexion : docker exec -it mongodb_sgbd mongosh -u admin -p admin123 --authenticationDatabase admin
// Puis : use bibliotheque

// ============================================================================
// Requête 1 : Tous les livres avec leurs auteurs et catégories
// ============================================================================
db.livres.aggregate([
  {
    $lookup: {
      from: "auteurs",
      localField: "auteur_id",
      foreignField: "_id",
      as: "auteur"
    }
  },
  {
    $lookup: {
      from: "categories",
      localField: "categorie_id",
      foreignField: "_id",
      as: "categorie"
    }
  },
  { $unwind: "$auteur" },
  { $unwind: "$categorie" },
  {
    $project: {
      titre: 1,
      auteur: { $concat: ["$auteur.nom", " ", "$auteur.prenom"] },
      categorie: "$categorie.nom",
      annee_publication: 1,
      _id: 0
    }
  },
  { $sort: { titre: 1 } }
])

// ============================================================================
// Requête 2 : Livres publiés après 2000
// ============================================================================
db.livres.aggregate([
  { $match: { annee_publication: { $gt: 2000 } } },
  {
    $lookup: {
      from: "auteurs",
      localField: "auteur_id",
      foreignField: "_id",
      as: "auteur"
    }
  },
  { $unwind: "$auteur" },
  {
    $project: {
      titre: 1,
      auteur: { $concat: ["$auteur.nom", " ", "$auteur.prenom"] },
      annee_publication: 1,
      _id: 0
    }
  },
  { $sort: { annee_publication: -1 } }
])

// ============================================================================
// Requête 3 : Nombre de livres par auteur
// ============================================================================
db.livres.aggregate([
  {
    $lookup: {
      from: "auteurs",
      localField: "auteur_id",
      foreignField: "_id",
      as: "auteur"
    }
  },
  { $unwind: "$auteur" },
  {
    $group: {
      _id: "$auteur_id",
      auteur: { $first: { $concat: ["$auteur.nom", " ", "$auteur.prenom"] } },
      nombre_livres: { $sum: 1 },
      pages_moyennes: { $avg: "$nombre_pages" }
    }
  },
  {
    $project: {
      _id: 0,
      auteur: 1,
      nombre_livres: 1,
      pages_moyennes: { $round: "$pages_moyennes" }
    }
  },
  { $sort: { nombre_livres: -1 } }
])

// ============================================================================
// Requête 4 : Nombre de livres par catégorie
// ============================================================================
db.livres.aggregate([
  {
    $lookup: {
      from: "categories",
      localField: "categorie_id",
      foreignField: "_id",
      as: "categorie"
    }
  },
  { $unwind: "$categorie" },
  {
    $group: {
      _id: "$categorie_id",
      categorie: { $first: "$categorie.nom" },
      nombre_livres: { $sum: 1 }
    }
  },
  {
    $project: {
      _id: 0,
      categorie: 1,
      nombre_livres: 1
    }
  },
  { $sort: { nombre_livres: -1 } }
])

// ============================================================================
// Requête 5 : Emprunts en cours avec détails
// ============================================================================
db.emprunts.aggregate([
  { $match: { statut: "en cours" } },
  {
    $lookup: {
      from: "livres",
      localField: "livre_id",
      foreignField: "_id",
      as: "livre"
    }
  },
  {
    $lookup: {
      from: "membres",
      localField: "membre_id",
      foreignField: "_id",
      as: "membre"
    }
  },
  { $unwind: "$livre" },
  { $unwind: "$membre" },
  {
    $project: {
      _id: 0,
      membre: { $concat: ["$membre.nom", " ", "$membre.prenom"] },
      livre: "$livre.titre",
      date_emprunt: 1,
      date_retour_prevue: 1,
      jours_retard: {
        $dateDiff: {
          startDate: "$date_retour_prevue",
          endDate: "$$NOW",
          unit: "day"
        }
      }
    }
  },
  { $sort: { date_emprunt: 1 } }
])

// ============================================================================
// Requête 6 : Membres les plus actifs (nombre d'emprunts)
// ============================================================================
db.emprunts.aggregate([
  {
    $lookup: {
      from: "membres",
      localField: "membre_id",
      foreignField: "_id",
      as: "membre"
    }
  },
  { $unwind: "$membre" },
  {
    $group: {
      _id: "$membre_id",
      membre: { $first: { $concat: ["$membre.nom", " ", "$membre.prenom"] } },
      email: { $first: "$membre.email" },
      nombre_emprunts: { $sum: 1 },
      emprunts_en_cours: {
        $sum: { $cond: [{ $eq: ["$statut", "en cours"] }, 1, 0] }
      }
    }
  },
  {
    $project: {
      _id: 0,
      membre: 1,
      email: 1,
      nombre_emprunts: 1,
      emprunts_en_cours: 1
    }
  },
  { $sort: { nombre_emprunts: -1 } },
  { $limit: 5 }
])

// ============================================================================
// Requête 7 : Livres jamais empruntés
// ============================================================================
// Méthode 1 : Avec distinct et $nin
const livresEmpruntes = db.emprunts.distinct("livre_id")
db.livres.aggregate([
  { $match: { _id: { $nin: livresEmpruntes } } },
  {
    $lookup: {
      from: "auteurs",
      localField: "auteur_id",
      foreignField: "_id",
      as: "auteur"
    }
  },
  { $unwind: "$auteur" },
  {
    $project: {
      _id: 0,
      titre: 1,
      auteur: { $concat: ["$auteur.nom", " ", "$auteur.prenom"] },
      isbn: 1
    }
  },
  { $sort: { titre: 1 } }
])

// Méthode 2 : Avec $lookup et $match (plus performant pour gros volumes)
db.livres.aggregate([
  {
    $lookup: {
      from: "emprunts",
      localField: "_id",
      foreignField: "livre_id",
      as: "emprunts"
    }
  },
  { $match: { emprunts: { $size: 0 } } },
  {
    $lookup: {
      from: "auteurs",
      localField: "auteur_id",
      foreignField: "_id",
      as: "auteur"
    }
  },
  { $unwind: "$auteur" },
  {
    $project: {
      _id: 0,
      titre: 1,
      auteur: { $concat: ["$auteur.nom", " ", "$auteur.prenom"] },
      isbn: 1
    }
  },
  { $sort: { titre: 1 } }
])

// ============================================================================
// Requête 8 : Livres les plus empruntés
// ============================================================================
db.emprunts.aggregate([
  {
    $group: {
      _id: "$livre_id",
      nombre_emprunts: { $sum: 1 }
    }
  },
  {
    $lookup: {
      from: "livres",
      localField: "_id",
      foreignField: "_id",
      as: "livre"
    }
  },
  { $unwind: "$livre" },
  {
    $lookup: {
      from: "auteurs",
      localField: "livre.auteur_id",
      foreignField: "_id",
      as: "auteur"
    }
  },
  { $unwind: "$auteur" },
  {
    $project: {
      _id: 0,
      titre: "$livre.titre",
      auteur: { $concat: ["$auteur.nom", " ", "$auteur.prenom"] },
      nombre_emprunts: 1
    }
  },
  { $sort: { nombre_emprunts: -1 } },
  { $limit: 5 }
])

// ============================================================================
// Requête 9 : Auteurs français avec leurs livres
// ============================================================================
db.auteurs.aggregate([
  { $match: { nationalite: "Française" } },
  {
    $lookup: {
      from: "livres",
      localField: "_id",
      foreignField: "auteur_id",
      as: "livres"
    }
  },
  { $unwind: "$livres" },
  {
    $sort: { "livres.annee_publication": 1 }
  },
  {
    $group: {
      _id: "$_id",
      auteur: { $first: { $concat: ["$nom", " ", "$prenom"] } },
      livres: { $push: "$livres.titre" }
    }
  },
  {
    $project: {
      _id: 0,
      auteur: 1,
      livres: { $reduce: { input: "$livres", initialValue: "", in: { $concat: ["$$value", { $cond: [{ $eq: ["$$value", ""] }, "", ", "] }, "$$this"] } } }
    }
  }
])

// ============================================================================
// Requête 10 : Statistiques globales
// ============================================================================
db.livres.aggregate([
  {
    $facet: {
      total_livres: [{ $count: "count" }],
      pages_moyennes: [{ $group: { _id: null, avg: { $avg: "$nombre_pages" } } }]
    }
  },
  {
    $project: {
      total_livres: { $arrayElemAt: ["$total_livres.count", 0] },
      pages_moyennes: { $round: [{ $arrayElemAt: ["$pages_moyennes.avg", 0] }] }
    }
  },
  {
    $addFields: {
      membres_actifs: { $literal: null },
      emprunts_en_cours: { $literal: null },
      emprunts_en_retard: { $literal: null }
    }
  }
]).toArray().then(result => {
  const stats = result[0]
  stats.membres_actifs = db.membres.countDocuments({ actif: true })
  stats.emprunts_en_cours = db.emprunts.countDocuments({ statut: "en cours" })
  stats.emprunts_en_retard = db.emprunts.countDocuments({ statut: "en retard" })
  return stats
})

// Version simplifiée (sans Promise)
print("=== Statistiques globales ===")
print("Total livres:", db.livres.countDocuments())
print("Membres actifs:", db.membres.countDocuments({ actif: true }))
print("Emprunts en cours:", db.emprunts.countDocuments({ statut: "en cours" }))
print("Emprunts en retard:", db.emprunts.countDocuments({ statut: "en retard" }))
print("Pages moyennes:", Math.round(db.livres.aggregate([{ $group: { _id: null, avg: { $avg: "$nombre_pages" } } }]).toArray()[0].avg))

