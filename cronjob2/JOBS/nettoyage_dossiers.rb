# encoding: UTF-8
# frozen_string_literal: true
class Cronjob

  def data
    @data ||= {
      name:       "Nettoyage des dossiers",
      frequency:  {hour:1},
    }
  end #/ data

  def nettoyage_dossiers
    nettoie_dossier_forms
    nettoie_dossier_downloads
    nettoie_dossier_signups
    return true
  end #/ nettoyage_dossiers

  # Nettoyage du dossier qui contient les tokens des formulaires
  def nettoie_dossier_forms
    Logger << "-> nettoie_dossier_forms"
    ilya2jours = Time.now.to_i - 2.days
    files = Dir["#{FORMS_TMP_FOLDER}/*"]
    nombre_init = files.count.freeze
    nombre_supp = 0
    files.each do |fpath|
      if File.stat(fpath).mtime.to_i < ilya2jours
        File.delete(fpath)
        nombre_supp += 1
      end
    end
    Report << "= Nombre tokens de formulaire détruits : #{nombre_supp}/#{nombre_init}"
    Logger << "<- nettoie_dossier_forms"
  end #/ nettoie_dossier_forms

  # Nettoyage du dossier qui contient les téléchargements
  def nettoie_dossier_downloads
    Logger << "-> nettoie_dossier_downloads"
    ilya30jours = Time.now.to_i - 30.days
    nombre_total    = 0
    nombre_detruits = 0
    Dir["#{DOWNLOADS_TMP_FOLDER}/*"].each do |fpath|
      # Des dossiers ou des fichiers
      nombre_total += 1
      next if File.stat(fpath).mtime.to_i > ilya30jours
      if File.directory?(fpath)
        FileUtils.rm_rf(fpath)
      else
        File.delete(fpath)
      end
      nombre_detruits += 1
    end
    Report << "= Nombre éléments downloads détruits : #{nombre_detruits}/#{nombre_total}"
    Logger << "<- nettoie_dossier_downloads"
  end #/ nettoie_dossier_downloads

  # Nettoyage du dossier qui contient les dossiers d'inscription
  #
  # Noter que normalement, il se vide de lui-même lorsque l'inscription
  # ne rencontre pas de problème (i.e. que je peux charger le dossier signup
  # sans souci).
  def nettoie_dossier_signups
    Logger << "-> nettoie_dossier_signups"

    Logger << "<- nettoie_dossier_signups"
  end #/ nettoie_dossier_downloads

TMP_FOLDER = File.join(APPFOLDER,'tmp')
FORMS_TMP_FOLDER = File.join(TMP_FOLDER,'forms')
DOWNLOADS_TMP_FOLDER = File.join(TMP_FOLDER,'downloads')

end #/Cronjob
