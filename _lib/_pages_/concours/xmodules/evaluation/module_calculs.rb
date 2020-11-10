# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui contient toutes les méthodes de calcul utiles pour le concours
  de synopsis et notamment les évaluations.
  Ce module doit pouvoir être chargé par les modules Ajax (donc ne pas
  dépendre trop de librairie tiers)

  Algorithme
  ----------
  La difficulté du comptage tient au fait que les réponses ont une valeur
  différente en fonction de leur profondeur. Les questions de premier niveau
  ont un coefficiant de 1, les questions de deuxième niveau un coefficiant de
  0.9 (elles valent moins), les questions de troisième niveau un coefficiant de
  0.8 (elles valent encore moins), etc.

  Pour obtenir la note finale, on procède ainsi :
  CALCUL DE LA NOT E TOTALE
  - on additionne toutes les valeurs de réponses en leur appliquant leur
    coefficiant.
  - dans le même temps, on compte la note maximale, c'est-à-dire la note
    qu'obtiendrait le synopsis si toutes les réponses étaient au maximumn (5)
  CALCUL DU COEFFICIANT
    - Ensuite, d'après la note maximale (p.e. 47), on tire le "coefficiant 200"
      c'est-à-dire le coefficiant qu'il faut appliquer à cette note pour obtenir
      la valeur 200, la note "humaine" maximale.
  CALCUL NOTE RÉELLE FINALE
    - il suffit ensuite d'appliquer ce coefficiant 200 à la note réelle obtenue
      pour obtenir sa valeur "humaine"

=end
require './_lib/_pages_/concours/xrequired/constants_mini'

ResScore = Struct.new(:note, :note_abs, :pourcentage, :nb_questions, :nb_reponses, :nb_missings)

class ConcoursCalcul

# Coefficiant de profondeur.
# Plus une question est "profonde" (i.e. imbriquée dans une autre) moins elle
# possède d'influence sur la note finale.
# Les premiers niveaux sont faciles à établir :
#   1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4
#
DEEPNESS_COEF = {}
(1..20).each do |i|
  DEEPNESS_COEF.merge!( i => 1.0 - ( (i - 1).to_f / 10 )) # 1 => 1, 2 => 0.9, 3 => 0.8
end

class << self

  # Méthode qui produit la note final d'un synopsis à partir de toutes ses
  # évaluation.
  #
  # IN    {String} Identifiant du synopsis
  #       {Bool}    True si c'est pour la note du prix
  #
  # OUT   {Integer} Note global sur 200 du synopsis pour les présélections ou
  #           le prix.
  #
  def note_globale_synopsis(synopsis_id, pour_prix = false)
    log("-> note_globale_synopsis(synopsis_id=#{synopsis_id.inspect})")
    concurrent_id, annee = synopsis_id.split('-')
    dossier_evaluations = File.join("./_lib/data/concours/#{concurrent_id}/#{synopsis_id}")
    evaluations = Dir["#{dossier_evaluations}/evaluation-#{pour_prix ? 'prix' : 'pres'}-*.json"]
    n = 0.0
    # nombre_evaluations = evaluations.count
    nombre_evaluations = 0
    evaluations.each do |file_eval|
      score = YAML.load_file(file_eval)
      ns = note_generale_et_pourcentage_from(score, true).note
      log("ns = #{ns.inspect}")
      if ns != '---'
        n += ns
        nombre_evaluations += 1
      end
      log("n = #{n}")
    end
    if n > 0
      n = ((n / nombre_evaluations).round(1) * 10).to_i
    else
      n = nil
    end
    return n
  end #/ note_globale_synopsis

  # Méthode qui reçoit en entrée un score (tel qu'enregistré dans un fichier
  # unique ou envoyé par Aajx) et qui retourne une table de résultat (cf.
  # ci-dessous).
  #
  # IN    +score+ Table des scores, avec en clé la clé de la question (p.e. "po"
  #           ou "po-li") et en valeur la note attribuée, de 0 à 5 ou '-' quand
  #           elle n'est pas renseignée. Ces notes sont pondérées en fonction
  #           de leur profondeur. Plus elles sont profondes et moins elles ont
  #           de valeurs.
  # IN    +as_struct+   Si true, la méthode retourne plutôt une Structure
  #           qui répondra aux méthodes :note, :pourcentage, et les autres
  #           propriétés comme pour le Hash ci-dessous
  # OUT   {Hash} contenant :
  #           :note_generale      Le note sur 20.0 (donc 1 décimale)
  #           :note_absolue       Contrairement à :note_generale qui ne compte
  #                               que les réponses qui ont été données, la note
  #                               absolue tient compte des réponses non données
  #           :nombre_questions   Le nombre total de questions
  #           :nombre_reponses    Le nombre de réponses données
  #           :nombre_missings    Le nombre de questions non répondues
  #           :pourcentages_reponses    Le % de réponses correspondant. Par ex.,
  #               si l'évaluateur répond à un tiers des questions seulement, ce
  #               nombre vaut 33.3. C'est le nombre qui sert pour la jauge.
  #       OU
  #       {Struct} :note, :note_abs, :pourcentage, :nombre_questions, nombre_reponses,
  #           :nombre_missings
  #
  def note_generale_et_pourcentage_from(score, as_struct = false)
    n     = 0.0 # pour la note générale
    na    = 0.0 # pour la note général absolues (où les "-" valent 0)
    nmax  = 0.0 # pour la note maximale possible
    namax = 0.0 # pour la note maximale avec les "-" qui sont comptabilisées
    naq = nombre_absolu_questions.to_f
    nqs = 0.0 # nombre de questions dans le score (répondues ou non)
    nr  = 0.0 # pour Nombre Réponses, le nombre de réponses données

    if score.empty?
      n   = '---'
      na  = 0.0
      pct = 0.0
    else
      score.each do |k, v|
        nqs += 1.0
        # Le coefficiant à appliquer à la note de la réponse, en fonction
        # de sa profondeur
        coef = DEEPNESS_COEF[k.split('-').count]
        unless v == "-"
          # <= Une note a été donnée
          v = v.to_f
          # On incrémente le nombre de réponses données
          nr += 1.0
          # On ajoute cette valeur de réponse à la note finale
          n     += v   * coef
          nmax  += 5.0 * coef
        else
          v = 0.0
        end
        # On comptabilise toujours pour la note absolue
        na    += v   * coef
        namax += 5.0 * coef
      end
      # --- On a fini de calculer la note totale et la note maximal ---

      # Si le nombre de réponses dans le score (même celles à "-") est différent
      # du nombre absolu (quand, par exemple, des questions ont été créées après
      # l'établissement de cette évaluation)
      # Alors il faut ajouter à la note max possible
      if naq > nqs
        (naq - nqs).to_i.times do
          namax += 5.0
        end
      end

      # --- Coefficiant 200 ---
      coef200   = 20.0 / nmax
      coefa200  = 20.0 / namax


      if nr > 0
        n   = (n  * coef200 ).round(1)
        na  = (na * coefa200).round(1)
        pct = (100.0 / (naq / nr)).round(1)
      else
        n   = '---'
        na  = 0.0
        pct = 0.0
      end
    end
    nu  = naq - nr
    # Le nombre de réponses en integer
    nr  = nr.to_i
    nu  = nu.to_i
    nqs = nqs.to_i
    # Le résultat retourné, soit une structure, soit une table Hash
    if as_struct
      return ResScore.new(n, na, pct, nqs, nr, nu)
    else
      return {note_generale:n, note_absolue:na, pourcentage_reponses:pct, nombre_questions:nqs, nombre_reponses:nr, nombre_missings:nu}
    end
  end #/ note_generale_et_pourcentage_from
  # def note_generale_et_pourcentage_from(score, as_struct = false)
  #   n   = 0.0 # pour la note générale
  #   nq  = nombre_absolu_questions
  #   nqs = 0 # nombre de questions dans le score (répondues ou non)
  #   if score.empty?
  #     n   = '---'
  #     na  = 0
  #     pct = 0
  #     nr  = 0
  #   else
  #     nombre_reponses   = 0
  #     nbabs_reponses    = 0 # le nombre réel de réponses auquel on applique le coefficiant
  #     score.each do |k, v|
  #       nqs += 1
  #       unless v == "-"
  #         nombre_reponses += 1
  #         coef = DEEPNESS_COEF[k.split('-').count]
  #         n += v.to_f * coef
  #         # Combien vaut cette réponse en nombre absolu de réponse ?
  #         # Cela dépend du coeffiant
  #         nbabs_reponses += 1.0 * coef
  #       end
  #     end
  #     nr  = nombre_reponses
  #     if nr > 0
  #       n   = (4.0 * ( n.to_f / nbabs_reponses )).round(1)
  #       pct = (100.0 / (nq.to_f / nr)).round(1)
  #       na  = (n.to_f * pct / 100).round(1) # Calcul de la note absolue.
  #     else
  #       n   = '---'
  #       pct = 0.0
  #       na  = 0.0
  #     end
  #   end
  #   nu  = nq - nr
  #   if as_struct
  #     return ResScore.new(n, na, pct, nqs, nr, nu)
  #   else
  #     return {note_generale:n, note_absolue:na, pourcentage_reponses:pct, nombre_questions:nqs, nombre_reponses:nr, nombre_missings:nu}
  #   end
  # end #/ note_generale_et_pourcentage_from


  def nombre_absolu_questions
    @nombre_absolu_questions ||= begin
      if not File.exists?(NOMBRE_QUESTIONS_PATH)
        require_relative './rebuild_checklist'
        CheckList.rebuild_checklist
      end
      File.read(NOMBRE_QUESTIONS_PATH).to_i
    end
  end #/ nombre_absolu_questions

  # Pour les tests unitaires
  def nombre_absolu_questions=(val)
    @nombre_absolu_questions = val
  end #/ nombre_absolu_questions=

end # /<< self
end #/ConcoursCalcul
