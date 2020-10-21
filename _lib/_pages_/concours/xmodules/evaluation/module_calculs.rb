# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui contient toutes les méthodes de calcul utiles pour le concours
  de synopsis et notamment les évaluations.
  Ce module doit pouvoir être chargé par les modules Ajax (donc ne pas
  dépendre trop de librairie tiers)
=end
class ConcoursCalcul

# Coefficiant de profondeur.
# Plus une question est "profonde" (i.e. imbriquée dans une autre) moins elle
# possède d'influence sur la note finale.
DEEPNESS_COEF = {}
(1..20).each do |i|
  DEEPNESS_COEF.merge!( i => 1.0 - ( (i - 1).to_f / 10 )) # 1 => 1, 2 => 0.9, 3 => 0.8
end

class << self
  # Méthode qui reçoit en entrée un score (tel qu'enregistré dans un fichier
  # unique ou envoyé par Aajx) et qui retourne une table contenant :
  #   :note_generale      La note résultant du calcul, sur 20
  #   :pourcentages_reponses    Le taux de réponse en pourcentage
  #   :nombre_questions         Le nombre de questions testées
  #   :nombre_missings          Le nombre de questions non répondues
  def note_generale_et_pourcentage_from(score)
    n = 0.0
    nq = nombre_absolu_questions
    if score.empty?
      n   = '---'
      pct = "0"
      nr  = 0
    else
      nombre_reponses  = 0
      score.each do |k, v|
        if v == "-"
        else
          coef = DEEPNESS_COEF[k.split('-').count]
          n += v * coef
          nombre_reponses += 1
        end
      end
      nr = nombre_reponses
      n = (4 * ( n / nr )).round(1)
      pct = (100.0 / (nq.to_f / nr)).round(1)
    end
    return {note_generale: n, pourcentage_reponses: pct, nombre_questions:nq, nombre_missings: (nq - nr)}
  end #/ note_generale_et_pourcentage_from

  def nombre_absolu_questions
    @nombre_absolu_questions ||= File.read(NOMBRE_QUESTIONS_PATH).to_i
  end #/ nombre_absolu_questions
end # /<< self



end #/ConcoursCalcul
