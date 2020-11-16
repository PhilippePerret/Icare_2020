# encoding: UTF-8
# frozen_string_literal: true
=begin

  Class Evaluation
  ----------------
  Classe qui permet d'évaluer un synopsis (i.e. de connaitre sa note) à partir
  d'un ou plusieurs "scores" (fiche d'évaluation de membre de jury).

  Notes
  -----
  Ce module doit pouvoir être chargé par les modules Ajax (donc ne pas
  dépendre trop de librairie tiers)

  Pour calculer un seul score, si on a les valeurs et pas le path, on peut
  utiliser :
    e = Evaluation.new
    e.parse({score}).calc
  Ensuite, on peut prendre e.note ou e.formated_note, e.pourcentage ou
  e.formated_pourcentage, etc. pour obtenir les valeurs.

  Algorithme
  ----------
  La difficulté du comptage tient au fait que les réponses ont une valeur
  différente en fonction de leur profondeur. Les questions de premier niveau
  ont un coefficiant de 1, les questions de deuxième niveau un coefficiant de
  0.9 (elles valent moins), les questions de troisième niveau un coefficiant de
  0.8 (elles valent encore moins), etc.

  Pour obtenir la note finale, on procède ainsi :
  PREMIERS CALCULS
  - on additionne toutes les valeurs de réponses en leur appliquant leur
    coefficiant.
  - dans le même temps, on compte la note maximale, c'est-à-dire la note
    qu'obtiendrait le synopsis si toutes les réponses étaient au maximumn (5)
  COEFFICIANT
    - Ensuite, de la note maximale (p.e. 47), on tire le "coefficiant 200"
      c'est-à-dire le coefficiant qu'il faut appliquer à cette note pour obtenir
      la valeur 200, la note "humaine" maximale.
  FINALISATION
    - il suffit ensuite d'appliquer ce coefficiant 200 à la note réelle obtenue
      pour obtenir sa valeur "humaine"

=end
require './_lib/_pages_/concours/xrequired/constants_mini'

class Evaluation

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

# # Nombre de questions aujourd'hui
# if not defined?(NOMBRE_ABSOLU_QUESTIONS) # pour les tests
#   NOMBRE_ABSOLU_QUESTIONS = File.read(NOMBRE_QUESTIONS_PATH).to_i
# end


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Les chemins d'accès aux fiches d'évaluation à prendre en compte
attr_reader :score_paths

# La note
attr_reader :note

# La note générale, comme la précédente, mais où les réponses non encore
# répondues ont été mises à zéro
attr_reader :note_abs

# Le pourcentage de réponses données sur l'ensemble des fiches fournies ou
# la fiche fournie.
attr_reader :pourcentage

# {Hash} Table des catégories, pour connaitre la note pour chaque catégorie.
# Par exemple, si la clé d'une question est "po-cohe-adth", cette question
# appartiendra aux catégories "po", "cohe" et "adth". On comptabilise les points
# pour chaque catégories, même la première qui est toujours le projet lui-même
# et correspond (?) à la note générale.
attr_reader :owners

# {Integer} Nombre de fiches d'évaluations fournies à l'instanciation
# Ce nombre est très important puisque c'est lui permettra de calculer les
# valeurs finale de sommes
attr_reader :nombre_scores

# Quelques nombres à garder, pas directement nécessaires
attr_reader :nombre_questions, :nombre_reponses, :nombre_missings

attr_accessor :coef200, :coefa200

# *** Initialisation ***
# On initialise un nouveau Evaluation avec le chemin d'accès à son
# fichier (appelé "fichier d'évaluation" ou "fichier score") ou des fichiers
# d'évaluation
#
# IN    {Array} Chemins d'accès ou NIL (dans ce cas, les données doivent
#       être transmises au parse)
def initialize(paths = nil)
  parse_scores(paths)
end #/ initialize

def self.NOMBRE_ABSOLU_QUESTIONS
  @nombre_absolu_questions ||= File.read(NOMBRE_QUESTIONS_PATH).to_i
end #/ NOMBRE_ABSOLU_QUESTIONS
def self.NOMBRE_ABSOLU_QUESTIONS=(val)
  @nombre_absolu_questions = val
end
# ---------------------------------------------------------------------
#
#   Méthodes publiques de traitement
#
# ---------------------------------------------------------------------
# Principalement pour les tests, prend le score +score+ et le traite
# jusqu'à produire les valeurs de l'instance
def parse_and_calc(score)
  parse(score)
  calculate_values
end #/ parse_and_calc

def parse_scores(paths)
  return if paths.nil? || paths.empty?
  paths = [paths] if paths.is_a?(String)
  @score_paths = paths
  @score_paths.each { |path| parse_score(path) }
  calculate_values
end #/ parse_scores

def calc_value(v)
  return nil if v.nil?
  (v.to_f / nombre_scores).round(1)
end

def calculate_values
  @note = calc_value(@sum_note)
  owners.each do |cate, dcate|
    rap = (dcate[:total].to_f / dcate[:totmax])
    dcate.merge!(note: (20.0 * rap).round(1))
  end
  @note_abs = calc_value(@sum_note_abs)
  @pourcentage = calc_value(@sum_pourcentage)
  @nombre_questions = calc_value(@sum_nombre_questions)
  @nombre_reponses = calc_value(@sum_nombre_reponses)
  @nombre_missings = calc_value(@sum_nombre_missings)
end #/ calculate_values
alias :calc :calculate_values

def parse_score(path)
  return if not File.exists?(path)
  parse(JSON.parse(File.read(path)))
end #/ parse_score
# ---------------------------------------------------------------------
#
#   Propriétés du score
#
# ---------------------------------------------------------------------
def no_scores?
  score_paths.nil? || score_paths.empty?
end
def preselections?
  no_scores? ? nil : (type == 'pres')
end #/ preselections?
def palmares?
  no_scores? ? nil : (type == 'prix')
end #/ palmares?
def first_score_name
  @score_name ||= begin
    File.basename(score_paths.first) unless no_scores?
  end
end #/ score_name
def type
  @type ||= first_score_name.split('-')[1] unless no_scores?
end #/ type

# = main =
#
# Méthode qui parse le score s'il existe.
#
# Noter que puisque l'instance peut recevoir plusieurs paths, on appelle cette
# méthode pour chaque table de paths
#
# IN    La table du score
# OUT   self (pour le chainage)
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
def parse(score)
  init_count if @sum_note.nil?
  # Dans tous les cas il faut incrémenter le nombre de scores
  @nombre_scores += 1
  # Si le score est vide, on peut s'arrêter
  return self if score.empty?

  n     = 0.0 # pour la note générale
  na    = 0.0 # pour la note général absolues (où les "-" valent 0)
  nmax  = 0.0 # pour la note maximale possible
  namax = 0.0 # pour la note maximale avec les "-" qui sont comptabilisées
  naq   = Evaluation.NOMBRE_ABSOLU_QUESTIONS
  nqs   = 0.0 # nombre de questions dans le score (répondues ou non)
  nr    = 0.0 # pour Nombre Réponses, le nombre de réponses données

  score.each do |k, v|
    nqs += 1.0
    # Les éléments de la clé, qui détermine les appartenances de la
    # question. Par exemple, si la clé contient "p-cohe-adth", la note
    # appartient aux personnage ("p"), à la cohérence ("cohe") et à
    # l'adéquation avec le thème ("adth"). On ajoutera la valeur de la note
    # à chaque élément.
    dk = k.to_s.split('-')
    # Le coefficiant à appliquer à la note de la réponse, en fonction
    # de sa profondeur
    coef = DEEPNESS_COEF[dk.count]
    maxcoef = 5.0 * coef
    unless v == "-"
      # <= Une note a été donnée
      v = v.to_f
      # On calcule la note en fonction de sa profondeur. Si elle est de profondeur
      # 2 par exemple, 1 point en vaut que 0.8. Donc la note max ne vaudra
      # que 5 * 0.8 donc 4.0 points
      vcoef   = v * coef
      # On incrémente le nombre de réponses données
      nr += 1.0
      # On ajoute cette valeur de réponse à la note finale
      n    += vcoef
      # On ajoute aussi à la note max la valeur max en fonction de la profondeur
      nmax += maxcoef
    else
      vcoef = 0.0
    end
    # On comptabilise toujours pour la note absolue
    na    += vcoef
    namax += maxcoef

    # On règle toutes les appartenances grâce aux clés
    dk.each do |sk|
      sk = sk.to_s
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
  # Pour les tests
  self.coef200 = coef200
  self.coefa200 = coefa200

  if nr > 0
    n   = (n  * coef200 ).round(1)
    na  = (na * coefa200).round(1)
    pct = (100.0 / (naq.to_f / nr)).round(1)
  else
    n   = 0.0
    na  = 0.0
    pct = 0.0
  end
  nu  = naq - nr
  # Le nombre de réponses en integer
  nr  = nr.to_i
  nu  = nu.to_i
  nqs = nqs.to_i
  # On incrémente les valeurs générales
  @sum_note += n
  @sum_note_abs += na
  @sum_pourcentage += pct
  @sum_nombre_questions += nqs
  @sum_nombre_reponses += nr
  @sum_nombre_missings += nu

  return self # chainage
end #/ parse

# Pour initialiser les valeurs au début du décompte
def init_count
  @nombre_scores = 0
  @owners = {}
  @sum_note = 0.0
  @sum_note_abs = 0.0
  @sum_pourcentage = 0.0
  @sum_nombre_questions = 0
  @sum_nombre_reponses = 0
  @sum_nombre_missings = 0
end #/ init_count


# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------

# IN    {Symbol} La catégorie, p.e. :coherence, :adequation, :personnages, :forme
# OUT   {Float} La note obtenue ou nil
def note_categorie(cate)
  # log("cate: #{cate.inspect}")
  # log("FicheLecture::DATA_MAIN_PROPERTIES[#{cate.inspect}]: #{FicheLecture::DATA_MAIN_PROPERTIES[cate].inspect}")
  dim_cate = FicheLecture::DATA_MAIN_PROPERTIES[cate][:diminutif]
  owners[dim_cate][:note]
end #/ fnote_categorie

#
# # IN    {Float} Une valeur réelle, normalement flottante
# # OUT   {String} Le nombre pour affichage. Principale, sans ".0" à la fin
# #       s'il y en a un
# def formate_float(v)
#   synopsis.formate_note
# end #/ formate_float
#
end #/Evaluation
