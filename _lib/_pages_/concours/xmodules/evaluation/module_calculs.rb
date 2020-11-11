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

ResScore = Struct.new(:owners, :note, :note_abs, :pourcentage, :nb_questions, :nb_reponses, :nb_missings)

class ConcoursScore

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
      ns = note_et_pourcentage_from(score, true).note
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

end # << self

attr_reader :score_path
attr_reader :note, :note_abs, :pourcentage, :owners
attr_reader :nombre_questions, :nombre_reponses, :nombre_missings

# *** Initialisation ***
# On initialise un nouveau ConcoursScore avec le chemin d'accès à son
# fichier (appelé "fichier d'évaluation" ou "fichier score")
def initialize(score_path = nil)
  unless score_path.nil?
    @score_path ||= score_path
    parse
  end
end #/ initialize

# ---------------------------------------------------------------------
#
#   Propriétés du score
#
# ---------------------------------------------------------------------
def preselections?
  type == 'pres'
end #/ preselections?
def palmares?
  type = 'prix'
end #/ palmares?
def score_name
  @score_name ||= File.basename(score_path)
end #/ score_name
def type
  @type ||= score_name.split('-')[1]
end #/ type

# Donnée (Hash) du score
def score
  @score ||= begin
    if File.exists?(score_path)
      JSON.parse(File.read(score_path))
    else
      {}
    end
  end
end #/ score

# = main =
#
# Méthode qui parse le score s'il existe.
#
# IN    void ou la table d'un score (surtout pour les tests)
# OUT   void
# DO    Définit les propriétés de l'instance
#           :note      Le note sur 20.0 (donc 1 décimale)
#           :note_absolue       Contrairement à :note qui ne compte
#                               que les réponses qui ont été données, la note
#                               absolue tient compte des réponses non données
#           :owners  Les appartenances, en fonction de la clé de chaque
#               question. Cette table contient en clé l'élément de clé (par
#               exemple les clés "p", "cohe" et "adth" si la question porte
#               l'identifiant "p-cohe-adth") et en valeur :
#               total: le nombre de points pour cette clé, :totmax, la valeur
#               maximale qu'on pouvait obtenir, nombre: le nombre de notes
#               notes: les notes obtenues (juste pour historique)
#           :nombre_questions   Le nombre total de questions
#           :nombre_reponses    Le nombre de réponses données
#           :nombre_missings    Le nombre de questions non répondues
#           :pourcentages_reponses    Le % de réponses correspondant. Par ex.,
#               si l'évaluateur répond à un tiers des questions seulement, ce
#               nombre vaut 33.3. C'est le nombre qui sert pour la jauge.
#
def parse(sco = nil)
  @score = sco unless sco.nil?
  n     = 0.0 # pour la note générale
  na    = 0.0 # pour la note général absolues (où les "-" valent 0)
  nmax  = 0.0 # pour la note maximale possible
  namax = 0.0 # pour la note maximale avec les "-" qui sont comptabilisées
  naq   = self.class.nombre_absolu_questions.to_f
  nqs   = 0.0 # nombre de questions dans le score (répondues ou non)
  nr    = 0.0 # pour Nombre Réponses, le nombre de réponses données

  # Pour le dispatch des questions par "catégorie" (projet, personnage,
  # thème, etc.)
  owners = {} # maintenant, tout sera mis dans cette table

  if score.empty?
    n   = '---'
    na  = 0.0
    pct = 0.0
  else
    score.each do |k, v|
      nqs += 1.0
      # Les éléments de la clé, qui détermine les appartenances de la
      # question. Par exemple, si la clé contient "p-cohe-adth", la note
      # appartient aux personnage ("p"), à la cohérence ("cohe") et à
      # l'adéquation avec le thème ("adth"). On ajoutera la valeur de la note
      # à chaque élément.
      dk = k.split('-')
      # Le coefficiant à appliquer à la note de la réponse, en fonction
      # de sa profondeur
      coef = DEEPNESS_COEF[dk.count]
      maxcoef = 5.0 * coef
      unless v == "-"
        # <= Une note a été donnée
        v = v.to_f
        vcoef   = v * coef
        # On incrémente le nombre de réponses données
        nr += 1.0
        # On ajoute cette valeur de réponse à la note finale
        n    += vcoef
        nmax += maxcoef
      else
        vcoef = 0.0
      end
      # On comptabilise toujours pour la note absolue
      na    += vcoef
      namax += maxcoef

      # On règle toutes les appartenances grâce aux clés
      dk.each do |sk|
        if not owners.key?(sk)
          owners.merge!(sk =>{total:0, totmax:0, nombre:0, notes:[]})
        end
        owners[sk][:total]  += vcoef
        owners[sk][:totmax] += maxcoef
        owners[sk][:nombre] += 1
        owners[sk][:notes]  << vcoef.round(1)
      end

    end #/ fin de si cette note est définie
    # --- On a fini de calculer la note totale et la note maximale ---
    # --- ainsi que les notes pour chaque "catégorie"

    # Pour finaliser owners, on boucle et on arrondit les valeurs
    owners.each do |k, v|
      v[:total] = v[:total].round(1)
      v[:totmax] = v[:totmax].round(1)
    end

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
  # On dispatche les valeurs
  @owners = owners
  @note = n
  @note_abs = na
  @pourcentage = pct
  @nombre_questions = nqs
  @nombre_reponses = nr
  @nombre_missings = nu
  # Pour l'avoir aussi sous forme de table
  @table = {owners: owners, note:n, note_absolue:na, pourcentage_reponses:pct, nombre_questions:nqs, nombre_reponses:nr, nombre_missings:nu}
end #/ parse
# Pour la régression
alias :note_et_pourcentage_from :parse

# def note_et_pourcentage_from(score, as_struct = false)
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
#     return {note:n, note_absolue:na, pourcentage_reponses:pct, nombre_questions:nqs, nombre_reponses:nr, nombre_missings:nu}
#   end
# end #/ note_et_pourcentage_from



end #/ConcoursCalcul
