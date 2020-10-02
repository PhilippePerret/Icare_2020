# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour les outils icariens.
=end
require 'json'
require './_lib/required/_classes/Actualite'
# Pour les données de toutes les opérations
require './_lib/modules/admin_operations/_data_operations_'

# Le fichier qui doit contenir les données des opérations pour javascript
# Rappel : les outils fonctionnent avec javascript
DATA_JS_PATH = "#{FOLD_REL_PAGES}/admin/tools/data.js"

require_relative 'updater_data'
AdminToolsUpdater.update_if_required

# Les constantes de l'UI
UI_TEXTS.merge!({
  btn_execute_operation: 'Exécuter l’opération',
})
