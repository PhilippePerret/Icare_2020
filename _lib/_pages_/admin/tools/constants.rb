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

# Les fichiers dont il faut tenir compte pour savoir s'il faut actualiser
# le fichier data.js qui contient les données des opérations.
mtime_ope_admin = File.stat('./_lib/modules/admin/operations/operations_admin.rb').mtime
mtime_this_file = File.stat(__FILE__).mtime
mtime_data_opes = File.stat('./_lib/modules/admin_operations/_data_operations_.rb').mtime
plus_vieille = [mtime_ope_admin, mtime_this_file, mtime_data_opes].min
datajs_update_required = !File.exists?(DATA_JS_PATH) || begin
  mtime_final_js_file = File.stat(DATA_JS_PATH).mtime
  (plus_vieille > mtime_final_js_file)
end

# On doit préparer ces données pour javascript
# On les met dans le fichier data.js s'il n'est pas à jour
if datajs_update_required
  log("Actualisation des données opérations admin requises")
  datajs = 'const DATA_OPERATIONS = {'+RC
  DATA_OPERATIONS_ICARIENS.each do |opid, dope|
    datajs << "'#{opid}': {description:#{dope[:description] ? dope[:description].inspect : 'null'}, aide:#{dope[:aide] ? dope[:aide] : 'null'}, for: #{dope[:for].to_json}, select_value: #{dope[:select_value] ? dope[:select_value].to_json : 'null'}, long_value:#{dope[:long_value] ? "#{dope[:long_value].inspect}" : 'null'}, medium_value:#{dope[:medium_value] ? "#{dope[:medium_value].inspect}" : 'null'}, short_value:#{dope[:short_value] ? "#{dope[:short_value].inspect}" : 'null'}, required:#{dope[:required].to_json}},#{RC}"
  end
  datajs << '};'
  File.open(DATA_JS_PATH,'wb'){|f|f.write datajs}
end

# Les constantes de l'UI
UI_TEXTS.merge!({
  btn_execute_operation: 'Exécuter l’opération',
})
