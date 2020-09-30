#!/Users/philippeperret/.rbenv/versions/2.6.3/bin/ruby
# encoding: UTF-8
# frozen_string_literal: true
=begin
  Cronjob pour effectuer des tâches routinières sur le site, à commencer par :
  - envoyer les mails quotidiens d'activité si nécessaire
  - envoyer les mails de résumé hebdomadaire si nécessaire
  - faire des nettoyages réguliers de certains dossiers
  - faire un checkup de l'atelier pour voir les éventuelles erreurs, par
    exemple celles qui auraient pu survenir dans le traceur alors qu'il
    n'était pas surveillé.
=end

CRON_FOLDER = File.expand_path(__dir__)
APPFOLDER   = File.dirname(CRON_FOLDER)

# Note : pas de begin ici, pour traiter toutes les erreurs là où elles
# se produisent afin d'obtenir un mode sans erreur.
begin
  require_relative './_lib/required'
  Dir.chdir(APPFOLDER) do
    Cronjob.run
  end
rescue Exception => e
  puts "FATAL ERROR: #{e.message}"
  puts e.backtrace.join("\n")
end
