# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de Cronjob pour faire le rapport complet

  Le rapport complet consiste à faire un point quotidien de l'atelier
  - erreurs du traceur (même celles déjà vues)
  - raccourcissement du traceur
=end
class Cronjob
class << self

  # Méthode appelée toutes les semaines pour nettoyer l'atelier
  def nettoyage_hebdomadaire
    # On nettoie les dossier principaux, principalement les dossiers temporaires
    nettoyage_dossiers
    # On détruit les factures de plus de 3 ans
    detruire_facture_3_ans

  end #/ nettoyage_hebdomadaire

  # Divers jobs à effectuer
  def divers_jobs
    reduce_traceur
  end #/ rapport_complet

  # ---------------------------------------------------------------------
  #
  #   Sous-méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------

  # Réduction du traceur avec récupération des erreurs rencontrées
  def reduce_traceur
    Report.add('Réduction du traceur', type: :operation)
    CJTraceur.reduce
  end #/ reduce_traceur

  # Nettoyage de tous les dossiers
  # ------------------------------
  # On détruit tous les fichiers qui datent de plus de 15 jours
  def nettoyage_dossiers
    Report.add('Nettoyage des dossiers…', type: :titre)
    [
      ["./tmp/signups",    'dossier des inscriptions (signups)'],
      ['./tmp/mails',      'dossier des mails locaux'],
      ['./tmp/forms',      'dossier des tokens de formulaire'],
      ['./tmp/downloads',  'dossier des téléchargements']
    ].each do |dossier_path, dossier_name|
      Report.add("Nettoyage du #{dossier_name}", type: :operation)
      CJFolders.nettoie(dossier_path)
    end
  end #/ nettoyage_dossiers

  # On doit détruire les factures plus vieilles de 3 ans
  def detruire_facture_3_ans
    now = Time.now
    ilya3ans = Time.new(now.year - 3, now.month, now.day).to_i
    nombre_factures_init = db_count('paiements')
    request = "DELETE FROM `paiements` WHERE created_at < #{ilya3ans}"
    db_exec(request)
    nombre_factures_new = db_count('paiements')
    if nombre_factures_init > nombre_factures_new
      # Des factures ont été détruites
      nombre_factures_detruites = nombre_factures_init - nombre_factures_new
      Report.add("Nombre de factures de plus de trois ans détruites : #{nombre_factures_detruites}.")
    end
  rescue Exception => e
    Report.add("ERREUR SURVENUE DANS detruire_facture_3_ans : #{e.message}#{RC}#{e.backtrace.join(RC)}")
  end #/ detruire_facture_3_ans
  
end # /<< self
end #/Cronjob
