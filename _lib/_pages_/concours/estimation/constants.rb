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
DATA_EVALUATION_PROJET = [{
  titre: "Évaluation générale du projet",
  id:'p',
  items: [
    {
      titre: "Projet dans sa globalité",
      id: 'g',
      items: [
        {titre:"Titre du projet",id: 'titre'},
      ]
    },
    {
      titre: "Les personnages",
      id: 'p',
      items: [
        {
          titre: "Le protagoniste",
          id:'prota',
        },
        {
          titre: "L'Antagoniste",
          id:'anta',
        },
        {
          titre: "Les personnages secondaires",
          id:'psec',
        },
        {
          titre: "Autre personnages",
          id:'autres',
        },
        {
          titre: "Les dialogues",
          id:'dial'
        }
      ],
      common_properties: [
        {
          titre: "Cohérence",
          common_properties: false,
          id:'cohe',
        },
        {
          titre: "Idiosyncrasie",
          id:'idio',
        }
      ]
    },
    {
      titre: "Les intrigues",
      id:'i',
      items: [
        {
          titre:"Construction générale",
          id:'form',
          common_properties: false,
          items:[
            {
              titre:"Utilisation nœuds classiques (PFA)",
              common_properties: false,
              id:'pfa'
            },
            {
              titre:"Clarté des 3 actes",
              common_properties: false,
              id:'3acts'
            }
          ]
        },
        {
          titre:"L'intrigue principale",
          id:'ip',
        },
        {
          titre:"L'intrigue secondaire",
          id:'is',
        }
      ],
      common_properties: [
        {
          titre:"Cohérence",
          id:'cohe',
        }
      ]
    },
    {
      titre: "Les thèmes",
      id:'th',
    },
    {
      titre: "Rédaction",
      common_properties: false,
      id:'r',
      items: [
        {
          titre:"Clarté",
          id:'cla',
          common_properties: false
        },
        {
          titre: "Simplicité",
          id:'sim',
          contraire: "Complexité",
          common_properties: false
        },
        {
          titre: "Émotion",
          id:'emo',
          common_properties: false
        }
      ]
    }
  ],
  common_properties: [
    {
      titre: "Facteur O (originalité)",
      id:'fo',
    },
    {
      titre: "Facteur U (universalité)",
      id:'fu',
    },
    {
      titre: "Adéquation avec le thème",
      id:'ade',
    }
  ]
}]
