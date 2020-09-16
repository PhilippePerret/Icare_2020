# encoding: UTF-8
# frozen_string_literal: true

# Pour tout recommencer
# ---------------------
# Si cette constante est true, toutes les tables préparées sont effacées
# pour repartir d'une donnée vierge. Sinon, le Runner poursuit son travail
# en fonction des tables présentes ou non.
RESET_ALL = true

# Pour produire le gel real-icare qui servira par exemple pour les
# tests pour obtenir de grandes données utilisateurs
PRODUCE_GEL_ICARE     = true

FORCE_ESSAI           = false # zappe toutes les méthodes de contrôle si TRUE

UPDATE_ICARE_TEST_DB  = true # pour que toutes les données soient chargées dans icare_test à la fin


DEBUG = 1 # Niveau de retour (jusqu'à 6)
