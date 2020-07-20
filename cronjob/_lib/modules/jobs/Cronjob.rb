# encoding: UTF-8
=begin
  Extension de Cronjob pour faire le rapport complet

  Le rapport complet consiste à faire un point quotidien de l'atelier
  - erreurs du traceur (même celles déjà vues)
  - raccourcissement du traceur
=end
class Cronjob
class << self

  # Divers jobs à effectuer
  def divers_jobs
    reduce_traceur
    nettoyage_dossiers
  end #/ rapport_complet

  # Réduction du traceur avec récupération des erreurs rencontrées
  def reduce_traceur
    Report.add('Réduction du traceur'.freeze, type: :operation)
    CJTraceur.reduce
  end #/ reduce_traceur

  # Nettoyage de tous les dossiers
  # ------------------------------
  # On détruit tous les fichiers qui datent de plus de 15 jours
  def nettoyage_dossiers
    Report.add('Nettoyage des dossiers…'.freeze, type: :titre)
    [
      ["./tmp/signups".freeze,    'dossier des inscriptions (signups)'.freeze],
      ['./tmp/mails'.freeze,      'dossier des mails locaux'.freeze],
      ['./tmp/forms'.freeze,      'dossier des tokens de formulaire'.freeze],
      ['./tmp/downloads'.freeze,  'dossier des téléchargements'.freeze]
    ].each do |dossier_path, dossier_name|
      Report.add("Nettoyage du #{dossier_name}".freeze, type: :operation)
      CJFolders.nettoie(dossier_path)
    end
  end #/ nettoyage_dossiers

end # /<< self
end #/Cronjob
