# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour les outils icariens.
=end
require 'json'
require './_lib/required/_classes/Actualite'
# Pour les données de toutes les opérations
require './_lib/modules/admin_operations/_data_operations_'

# On doit préparer ces données pour javascript
# On les met dans le fichier data.js s'il n'est pas à jour
DATA_JS_PATH = "#{FOLD_REL_PAGES}/admin/tools/data.js"
if !File.exists?(DATA_JS_PATH) || File.stat(__FILE__).mtime > File.stat(DATA_JS_PATH).mtime
  datajs = 'const DATA_OPERATIONS = {'+RC
  DATA_OPERATIONS_ICARIENS.each do |opid, dope|
    datajs << "'#{opid}': {for: #{dope[:for].to_json}, long_value:#{dope[:long_value] ? "#{dope[:long_value].inspect}" : 'null'}, medium_value:#{dope[:medium_value] ? "#{dope[:medium_value].inspect}" : 'null'}, short_value:#{dope[:short_value] ? "#{dope[:short_value].inspect}" : 'null'}, required:#{dope[:required].to_json}},#{RC}"
  end
  datajs << '};'
  File.open(DATA_JS_PATH,'wb'){|f|f.write datajs}
end

# Les constantes de l'UI
UI_TEXTS.merge!({
  btn_execute_operation: 'Exécuter l’opération',
})
