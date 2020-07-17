#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  Cronjob pour effectuer des tâches routinières sur le site, à commencer par :
  - envoyer les mails quotidiens d'activité si nécessaire
  - envoyer les mails de résumé hebdomadaire si nécessaire
  - faire des nettoyages réguliers de certains dossiers
  - faire un checkup de l'atelier pour voir les éventuelles erreurs, par
    exemple celles qui auraient pu survenir dans le traceur alors qu'il
    n'était pas surveillé.
=end

THISFOLDER  = File.expand_path(File.dirname(__FILE__)).freeze
APPFOLDER   = File.dirname(THISFOLDER).freeze

# Note : pas de begin ici, pour traiter toutes les erreurs là où elles
# se produisent afin d'obtenir un mode sans erreur.
require_relative './_lib/required'
Dir.chdir(APPFOLDER) do
  Cronjob.run
end
