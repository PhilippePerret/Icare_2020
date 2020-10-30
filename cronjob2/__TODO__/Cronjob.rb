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

  # ---------------------------------------------------------------------
  #
  #   Sous-méthodes fonctionnelles
  #
  # ---------------------------------------------------------------------

  # Réduction du traceur avec récupération des erreurs rencontrées
  def reduce_traceur
    Report.add('Réduction de la taille du traceur', type: :operation)
    CJTraceur.reduce
  end #/ reduce_traceur

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
end # /<< self
end #/Cronjob
