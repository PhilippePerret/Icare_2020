# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class MotSujet
  --------------
  Permet de gérer les sujets et sous-sujets des évaluations.
  Un 'sujet' ou un 'sujet' est une des clés d'un fichier d'évaluation (p.e.
  'po:cohe' pour la "cohérence du projet") ou une clé du fichier
  textes_fiches_lecture.yml, par exemple 'personnages' ou 'thèmes'.

  Cette structure sert à deux choses (pour le moment) :
    - formater les textes
    - renvoyer les notes (pour des conditions)

  Il permet par exemple de récupérer facilement sa note pour le projet
  analysé (en vue d'établir sa fiche de lecture).
  Par exemple, “motSujet('personnages').note” va retourner la note générale
  concernant les personnages.

  On doit pouvoir obtenir chaque motSujet par trois moyens différents (qu'il
  faut définir explicitement dans la méthode motSujet ci-dessous). On les appel-
  le des clés et c'est le premier argument à passer à motSujet.
  Ces trois moyens sont :
    - un terme “humain explicite” (par exemple 'universalité thèmes')
    - un terme “réduit”, qui fonctionne toujours sur la base de trois lettres,
      pour mémoire. Par exemple :
        * 'the' pour 'thèmes'
        * 'uni the' pour l'universalité des thèmes.
    - la balise dans le fichier d'évaluation (par exemple 'th:fU' pour l'univer-
      salité des thèmes).
=end

=begin
  Initialisation
  --------------
    :fiche    Instance FicheLecture du projet
    :sujet    Le terme humain qui sera utilisé dans les texxtes
              P.e. 'originalité'
    :key      La clé dans le fichier d'évaluation (et donc dans le fichier
              data_evaluation.yml, mais pas toujours). Par exemple 'po:cohe'
    :genre    'M' pour masculin, 'F' pour féminin
    :pluriel  {Bool} True si le :sujet est pluriel
    :voyelle  {Bool} True si le :sujet commence par une voyelle
    :main     {String} Le sujet principal, s'il est défini. Ce doit obligatoi-
              rement être un :sujet d'un motSujet.
              Par exemple, 'personnages' est le sujet principal (le :main) du
              mot sujet 'cohérence personnages'

=end
class FicheLecture

MotSujet = Struct.new(:fiche, :sujet, :key, :genre, :pluriel, :voyelle, :main)

class MotSujet

  def self.fiche=(v) ; @@fiche = v end
  def self.fiche     ; @@fiche     end

  # Retourne une :
  #       Liste Array
  #   des
  #       Instances MotSujet (ou clés string)
  #   qui
  #       ont une note inférieur à 10
  #   dans
  #       La liste initiale +ary+
  #   qui est
  #       Une liste Array d'instances MotSujet
  #
  def self.inferieurs_a_10_parmi(ary)
    ary = list_from_key(ary) if ary.first.is_a?(String)
    ary.select { |ms| ms.note < 10 }.sort_by { |s| s.note }
  end

  # Méthode de class (MotSujet.meilleurs_parmi)
  #
  # Retourne une :
  #     Liste Array d'instances MotSujet (ou clés string)
  # des :
  #     +nombre+ meilleurs notes
  # parmi :
  #     la liste Array d'instances MotSujet +ary+
  #
  def self.meilleurs_parmi(ary, nombre = 3)
    ary = list_from_key(ary) if ary.first.is_a?(String)
    ary.sort_by { |ms| - ms.note }[0...nombre]
  end

  def self.list_from_key(keys)
    keys.collect { |key| get(key, self.fiche) }
  end

  # Par exemple "cohérence des personnages" si :sujet = 'cohérence' et
  # :main = 'personnages'
  def f_sujet ; @f_sujet ||= formate_sujet end
  def main_subject ; @main_subject ||= motSujet(main) end
  def du
    @du ||= begin
      if pluriel          then 'des '
      elsif voyelle       then 'de l’'
      elsif genre == 'F'  then 'de la '
      elsif genre == 'M'  then 'du '
      end
    end
  end #/ du

  # Retourne la note pour le mot sujet (un flottant sur 20.0)
  def note
    @note ||= begin
      evaluation[key][:note]
    rescue Exception => e
      puts "ERR: La clé #{key.inspect} est inconnue dans #{evaluation.keys.inspect}\nJe retourne 0.0".rouge
      if FLFactory.option?(:verbose)
        puts "La table projet.evaluation complète :\n#{evaluation.pretty_inspect}"
      else
        puts "Ajouter l'option -v/--verbose pour voir l'intégralité de la table".bleu
      end
      0.0
    end
  end

  # Retourne 'A', 'B', 'C' ou 'D' en fonction de la note
  def note_lettre
    @note_lettre ||= fiche.key_per_note(note)
  end

class << self # MotCle.self
# Retourne une structure MotSujet de clé +key+ (qui peut être 'personnage',
# 'structure', etc.)
def get(key, fiche)
  @mots_sujets ||= {}
  @mots_sujets[key] ||= begin
    case key

    #  when <mot humain>, <clé réduite 3 lettres>, <clé évaluation>
    #
    #   MotSujet.new(fiche, <nom humain>, <clé évaluation>, <sexe>, <pluriel ?>, <voyelle ?>[, <sujet principal>])

    when 'projet', 'pro', 'po'

      MotSujet.new(fiche, 'projet', 'po', 'M', false, false)

    when 'personnages', 'per', 'p'

      MotSujet.new(fiche, 'personnages', 'p', 'M', true, false)

    when 'cohérence personnages', 'coh per', 'p:co'

      MotSujet.new(fiche, 'cohérence', 'p:co', 'F', false, false, 'personnages')

    when 'originalité personnages', 'ori per', 'p:fO'

      MotSujet.new(fiche, 'originalité', 'p:fO', 'F', false, true, 'personnages')

    when 'universalité personnages', 'uni per', 'p:fU'

      MotSujet.new(fiche, 'universalité', 'p:fU', 'F', false, true, 'personnages')

    when 'thème', 'the', 't'

      MotSujet.new(fiche, 'thèmes', 't', 'M', true, false)

    when 'intrigues', 'int', 'i'

      MotSujet.new(fiche, 'intrigues', 'i', 'F', true, true)

    when 'structure', 'stt', 'f'

      MotSujet.new(fiche, 'structure', 'f', 'F', false, false)

    when 'universalité', 'uni', 'fU'

      MotSujet.new(fiche, 'universalité', 'fU', 'F', false, true)

    when 'originalité', 'ori', 'fO'

      MotSujet.new(fiche, 'originalité', 'fO', 'F', false, true)

    when 'rédaction', 'red', 'r'

      MotSujet.new(fiche, 'rédaction', 'r', 'F', false, false)

    when 'clarté', 'clarté rédaction', 'cla red', 'cla'

      MotSujet.new(fiche, 'clarté rédaction', 'r:cla', 'F', false, false, 'rédaction')

    end
  end
end #/ motSujet
end #/<< self class MotSujet

private

  def evaluation
    @evaluation ||= fiche.projet.evaluation.categories
  end

  def formate_sujet
    fs = sujet
    return fs unless main
    "#{fs} #{main_subject.du}#{main_subject.sujet}"
  end

end #/Class MotSujet

def motSujet(key, fiche = nil)
  return MotSujet.get(key, fiche || MotSujet.fiche)
end

end #/ Class FicheLecture
