# encoding: UTF-8
# frozen_string_literal: true

# Note : les commandes à jouer directement seront automatiquement ajoutées
DATA_COMMANDES = [
  {name: "Ajouter une notification ponctuelle", value:'add'},
  {name: "Lire le rapport du jour", value: 'report'},
  {name: "Lire le journal distant", value: 'log'},
  {name: "Jouer le cron distant", value: 'run'},
  {name: "Détruire le journal distant", value: 'remove-log'},
  {name: 'Renoncer', value: nil}
]
