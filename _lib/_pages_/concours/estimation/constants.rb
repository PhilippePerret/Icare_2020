# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour l'estimation
=end

# Première tentative de définition de la qualité du projet
#
# Pour le moment, chaque élément est composé d'1 clé et 3 propriétés
#   - key:      Sa clé, en clé de table
#   - titre:    Son titre humain
#   - items:    Table de ses sous-éléments
#   - common_properties:    Les sous-propriétés estimatives communes à chaque item
#
# Note : penser à ajouter partout :
#   le choix "adéquation avec le thème"
#
DATA_PROJET = {
  titre: "Évaluation du projet",
  items: {
    projet: {
      titre: "Projet dans sa globalité",
      items: {
        titre: {titre:"Titre du projet"}
      }
    },
    personnages: {
      titre: "Les personnages",
      items: {
        protagoniste: {titre: "Le protagoniste"},
        antagoniste: {titre: "L'Antagoniste"},
        persos_secondes: {titre: "Les personnages secondaires"},
        autres_perso: {titre: "Autre personnages"}
      },
      common_properties: {
        coherence: {titre: "Cohérence"},
        idiosyncrasie: {titre: "Idiosyncrasie"}
      }
    },
    intrigues: {
      titre: "Les intrigues",
      items: {
        intrigue_principale:{titre:"L'intrigue principale"},
        intrique_secondaire:{titre:"L'intrigue secondaire"}
      },
      common_properties: {
        coherence: {titre:"La cohérence"}
      }
    },
    themes: {
      titre: "Les thèmes"
    },
    redaction: {
      titre: "Rédaction",
      items: {
        clarte: {titre:"Clarté"},
        simplicite: {titre: "Simplicité", contraire: "Complexité"},
      }
    }
  },
  common_properties: {
    facteur_o: {titre: "Facteur O (originalité)"},
    facteur_u: {titre: "Facteur U (universalité)"},
    inexistant_neutre: {titre: "Inexistant (mais ne manque pas)"},
    inexistant_moins: {titre: "Inexistant (crée un manque)"},
    adequation_theme: {titre: "Adéquation avec le thème"},
  }
}
