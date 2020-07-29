# encoding: UTF-8
=begin
  Module permettant de jouer les opérations icariens
=end
begin
  Dir.chdir(APP_FOLDER) do
    # On se place toujours dans le dossier de l'application
    require './_lib/required'
    require_module('admin/operations')
    Admin.operation(Ajax.param(:operation))
  end
rescue Exception => e
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
