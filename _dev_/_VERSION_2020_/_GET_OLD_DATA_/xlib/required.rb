# encoding: UTF-8
# frozen_string_literal: true
require 'fileutils'
require 'json'

# Configuration courante
require_relative '../config.rb'

# ---------------------------------------------------------------------
#
#   Définition des paths
#
# ---------------------------------------------------------------------
THISFOLDER = File.dirname(__dir__)
require_relative './required/constants'

# ---------------------------------------------------------------------
#
#   Premiers requierments
#
# ---------------------------------------------------------------------
Dir["#{GOD_LIB_FOLDER}/required/**/*.rb"].each{|m|require(m)}
# Pour toutes les constantes String comme RC ou VGE
require './_lib/required/__first/constants/String'
# Pour les couleurs en console
require './_dev_/CLI/lib/required/String_CLI'

# ---------------------------------------------------------------------
#
#   Initialisation des données
#
# ---------------------------------------------------------------------

# On doit utiliser localement la table icare
MyDB.DBNAME = 'icare'

# Pour mettre tous les messages d'erreurs qui seront reproduit à la fin
# Note : ici, ce sont des erreurs non fatales qui n'ont pas empêché de
# faire le traitement des données.
ERRORS_TRANS_DATA = []
