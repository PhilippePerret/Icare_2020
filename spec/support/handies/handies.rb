# encoding: UTF-8
=begin
  Méthodes pratiques pour les tests
=end

def require_folder(relpath)
  Dir["#{relpath}/**/*.rb"].each { |m| require m }
end #/ require_folder

# Pour vider et reconstruire les dossiers temporaires principaux
def vide_all_dossiers
  vide_dossier_signups
  vide_dossier_mails
  vide_dossier_downloads
  vide_dossier_forms
  vide_dossier_screenshots
  vide_dossier_logs
end #/ vide_all_dossiers

def vide_dossier_logs
  vide_and_rebuild('./tmp/logs')
end #/ vide_dossier_logs
def vide_dossier_signups
  vide_and_rebuild('./tmp/signups')
end #/ vide_dossier_signups
def vide_dossier_mails
  vide_and_rebuild('./tmp/mails')
end #/ vide_dossier_mails
def vide_dossier_forms
  vide_and_rebuild('./tmp/forms')
end #/ vide_dossier_forms
def vide_dossier_downloads
  vide_and_rebuild('./tmp/downloads')
end #/ vide_dossier_downloads
def vide_dossier_screenshots
  vide_and_rebuild('./spec/tmp/screenshots')
end #/ vide_dossier_screenshots

def vide_and_rebuild(dossier)
  FileUtils.rm_rf(dossier)
  `mkdir -p "#{File.expand_path(dossier)}"`
end #/ vide_and_rebuild
