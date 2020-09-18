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
  def nettoyage_quotidien
    # Réduire la taille du fichier traceur
    reduce_traceur
    # On détruit les ids à usage unique qui n'ont pas été supprimés (utilisés)
    detruire_ids_a_usage_unique
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
      ['./tmp/mails',      'dossier des mails'],
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
    request = "DELETE FROM paiements WHERE created_at < '#{ilya3ans}'"
    nombre_avant = db_count('paiements')
    db_exec(request)
    nombre_apres = db_count('paiements')
    Report.add("Nombre de factures de plus de trois ans détruites : #{nombre_avant - nombre_apres}.")
    end
  rescue Exception => e
    rapporter_erreur('detruire_facture_3_ans', e)
  end #/ detruire_facture_3_ans


  # Pour détruire les ids à usage unique vieux de la veille
  def detruire_ids_a_usage_unique
    now = Time.now
    laveille = Time.new(now.year, now.month, now.day - 1).to_i
    request = "DELETE FROM unique_usage_ids WHERE created_at < '#{laveille}'"
    nombre_avant = db_count('unique_usage_ids')
    db_exec(request)
    nombre_apres = db_count('unique_usage_ids')
    Report.add("Nombre d'ids à usage unique détruits : #{nombre_avant - nombre_apres}")
  rescue Exception => e
    rapporter_erreur('detruire_ids_a_usage_unique', e)
  end #/ detruire_ids_a_usage_unique


private

  def rapporter_erreur(from, e)
    Report.add("ERREUR SURVENUE DANS #{from} : #{e.message}#{RC}#{e.backtrace.join(RC)}")
  end #/ rapporter_erreur
end # /<< self
end #/Cronjob
