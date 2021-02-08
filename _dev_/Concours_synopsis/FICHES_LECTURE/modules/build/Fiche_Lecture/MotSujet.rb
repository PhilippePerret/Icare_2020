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
  def self.verbose?
    :true == @@verbose ||= (FLFactory.verbose? ? :true : :false)
  end

  # Retourne le texte type à copier dans la fiche pour remplacer une
  # balise
  # +params+
  #   :as       Pour l'ajout au bout (soit :defect soit :quality (défaut))
  #   :article  Soit :les/le, soit :des/:du (par défaut)
  #   :full_name    Si cette propriété est true et que le mot sujet contient
  #                 un sujet principal (par exemple "thèmes" pour l'originalité
  #                 des thèmes) alors c'est le nom complet qui doit être
  #                 employé (donc "originalité des thèmes" pour l'exemple)
  def self.formate_liste(ary, params = nil)
    method_as = "as_#{params[:as] || :quality}".to_sym
    params[:article] ||= :des
    full_name = !!params[:full_name]
    template = verbose? ? '%{article}%{sujet} (%{note})%{as}' : '%{article}%{sujet}%{as}'
    ary.collect do |motsujet|
      template % {
        article:  motsujet.article(params[:article]),
        sujet:    full_name ? motsujet.full_sujet : motsujet.sujet,
        note:     motsujet.note,
        as:       motsujet.send(method_as)
      }
    end.pretty_join
  end

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
  # Si +toujours_un+ est true, on revoit toujours le plus faible si aucun
  # en dessous de 10 n'a été trouvé.
  def self.inferieurs_a_10_parmi(ary, toujours_un = false)
    ary = list_from_key(ary) if ary.first.is_a?(String)
    moinsdix = ary.select { |ms| ms.note < 10 }.sort_by { |s| s.note }
    if moinsdix.empty? && toujours_un
      [ary.sort_by{|s|s.note}.first]
    else
      moinsdix
    end
  end

  # Méthode de class (MotSujet.meilleurs_parmi)
  #
  # Retourne une :
  #     Liste Array d'instances MotSujet (ou clés string)
  # des :
  #     +nombre+ meilleurs sujets (note > 14)
  # parmi :
  #     la liste Array d'instances MotSujet +ary+
  #
  # Retourne toujours au moins un sujet, même si ça note n'est pas
  # supérieure à 14.
  #
  def self.meilleurs_parmi(ary, nombre = 3)
    ary = list_from_key(ary) if ary.first.is_a?(String)
    sorted = ary.sort_by { |ms| - ms.note }
    lst = sorted.select { |s| s.note > 14 }[0...nombre]
    # Il en faut toujours un
    lst = [sorted.first] if lst.empty?
    inspect_list(lst, 'meilleurs parmi')
    return lst
  end

  # Retourne la liste Array des instances de MotSujet des sujets dont
  # la note est inférieure à 14 parmi les sujets +ary+
  def self.perfectibles_parmi(ary, min = 14)
    ary = list_from_key(ary) if ary.first.is_a?(String)
    ary = ary.select { |s| s.note < min.to_f }
    inspect_list(ary,'perfectibles')
    return ary
  end

  # Pour le débug des listes filtrées
  def self.inspect_list(ary, from)
    return unless verbose?
    puts "Sujets filtrés par “#{from}” : #{ary.collect{|s|s.sujet + ' => ' + s.note.to_s}}"
  end

  def self.list_from_key(keys)
    keys.collect do |key|
      ms = get(key, self.fiche)
      if ms.nil?
        raise "Problème avec la clé #{key.inspect} qui est introuvable dans les MotSujet(s)…".rouge
      else
        ms
      end
    end.compact
  end

  # Par exemple "cohérence des personnages" si :sujet = 'cohérence' et
  # :main = 'personnages'
  def full_sujet
    fs = sujet.dup
    return fs if main.nil?
    fs = "#{fs} #{main_subject.du}#{main_subject.sujet}".freeze
    return fs
  end
  def main_subject ; @main_subject ||= MotSujet.get(main, fiche) end

  def article(art)
    art = case art
    when :des, :de, :du then :du
    else :le
    end
    send(art)
  end

  def le
    @le ||= begin
      if pluriel          then 'les '
      elsif voyelle       then 'l’'
      elsif genre == 'F'  then 'la '
      elsif genre == 'M'  then 'le '
      else raise "Genre inconnu pour :le…"
      end
    end
  end

  def du
    @du ||= begin
      if pluriel          then 'des '
      elsif voyelle       then 'de l’'
      elsif genre == 'F'  then 'de la '
      elsif genre == 'M'  then 'du '
      else raise "Genre inconnu pour :du…"
      end
    end
  end #/ du

  # Retourne la note pour le mot sujet (un flottant sur 20.0)
  def note
    @note ||= begin
      evaluation[key][:note]
    rescue Exception => e
      puts "ERREUR NON FATALE : La clé #{key.inspect} est inconnue dans les clés de l'évaluation du dossier : #{evaluation.keys.inspect}\nLe mieux serait de définir le sujet “#{full_sujet}”. Je retourne 8.0 en attendant".rouge
      if FLFactory.option?(:verbose)
        puts "La table projet.evaluation complète :\n#{evaluation.pretty_inspect}"
      else
        puts "Ajouter l'option -v/--verbose pour voir l'intégralité de la table".bleu
      end
      8.0
    end
  end

  # Retourne le texte qui doit être ajouté quand le sujet est mentionné
  # comme une qualité
  def as_quality
    str = fiche.texte("#{key}") # p.e. 'p:cohe:quality'
    if str && str[:quality] then str[:quality].freeze
    else '' end
  end
  def as_defect
    str = fiche.texte(key)
    if str && str[:defect] then str[:defect].freeze
    else '' end
  end

  # Retourne 'A', 'B', 'C' ou 'D' en fonction de la note
  def note_lettre
    @note_lettre ||= fiche.key_per_note(note)
  end

class << self # MotCle.self

# Retourne une structure MotSujet de clé +key+ (qui peut être 'personnage',
# 'structure', etc.)
def get(key, fiche)
  key = real_key_for(key)
  @mots_sujets ||= {}
  @mots_sujets[key] ||= begin
    case key

    #  when <mot humain>, <clé réduite 3 lettres>, <clé évaluation>
    #
    #   MotSujet.new(fiche, <nom humain>, <clé évaluation>, <sexe>, <pluriel ?>, <voyelle ?>[, <sujet principal>])

    when 'projet'
      MotSujet.new(fiche, 'projet', 'po', 'M', false, false)
    when 'titre'
      MotSujet.new(fiche, 'titre', 'ti', 'M', false, false)

    # === PERSONNAGES ===
    when 'personnages'
      MotSujet.new(fiche, 'personnages', 'p', 'M', true, false)
    when 'p:adth'
      MotSujet.new(fiche, 'adéquation avec le thème du concours', 'p:adth', 'F', false, true, 'personnages')
    when 'p:cohe'
      MotSujet.new(fiche, 'cohérence', 'p:cohe', 'F', false, false, 'personnages')
    when 'p:fO'
      MotSujet.new(fiche, 'originalité', 'p:fO', 'F', false, true, 'personnages')
    when 'p:fU'
      MotSujet.new(fiche, 'universalité', 'p:fU', 'F', false, true, 'personnages')
    when 'p:idio'
      MotSujet.new(fiche, 'idiosyncrasie', 'p:idio', 'F', false, true, 'personnages')

    # === THÈMES ===
    when 'thèmes'
      MotSujet.new(fiche, 'thèmes', 't', 'M', true, false)
    when 't:fO'
      MotSujet.new(fiche, 'originalité', 't:fO', 'F', false, true, 'thèmes')
    when 't:fU'
      MotSujet.new(fiche, 'universalité', 't:fU', 'F', false, true, 'thèmes')
    when 't:adth'
      MotSujet.new(fiche, 'adéquation avec le thème', 't:adth', 'F', false, true, 'thèmes')
    when 't:cohe'
      MotSujet.new(fiche, 'cohérence', 't:adth', 'F', false, false, 'thèmes')

    # === INTRIGUES ===
    when 'intrigues'
      MotSujet.new(fiche, 'intrigues', 'i', 'F', true, true)
    when 'i:fO'
      MotSujet.new(fiche, 'originalité', 'i:fO', 'F', false, true, 'intrigues')
    when 'i:fU'
      MotSujet.new(fiche, 'universalité', 'i:fU', 'F', false, true, 'intrigues')
    when 'i:cohe'
      MotSujet.new(fiche, 'cohérence', 'i:cohe', 'F', false, false, 'intrigues')
    when 'i:adth'
      MotSujet.new(fiche, 'adéquation avec le thème', 'i:adth', 'F', false, true, 'intrigues')
    when 'predic'
      MotSujet.new(fiche, 'non prédictibilité', 'predic', 'F', false, false, 'intrigues')

    # === STRUCTURE ===
    when 'structure'
      MotSujet.new(fiche, 'structure', 'f', 'F', false, false)

    when 'universalité'
      MotSujet.new(fiche, 'universalité', 'fU', 'F', false, true)
    when 'originalité'
      MotSujet.new(fiche, 'originalité', 'fO', 'F', false, true)

    # === RÉDACTION ===
    when 'rédaction'
      MotSujet.new(fiche, 'rédaction', 'r', 'F', false, false)
    when 'r:cla'
      MotSujet.new(fiche, 'clarté rédaction', 'r:cla', 'F', false, false, 'rédaction')
    when 'r:ortho'
      MotSujet.new(fiche, 'orthographe', 'r:cla:ortho', 'F', false, true)
    when 'r:style'
      MotSujet.new(fiche, 'style', 'r:cla:style', 'M', false, false)
    when 'r:sim'
      MotSujet.new(fiche, 'simplicité', 'r:sim', 'F', false, false, 'rédaction')
    when 'r:emo'
      MotSujet.new(fiche, 'émotion révélée par la rédaction', 'r:emo', 'F', false, true)
    end
  end
end #/ motSujet

def real_key_for(key)
  case key
  when 'projet', 'pro', 'po'        then 'projet'
  when 'titre', 'tit', 'ti'         then 'titre'
  when 'personnages', 'per', 'p'    then 'personnages'
  when 'thèmes', 'the', 't'         then 'thèmes'
  when 'intrigues', 'int', 'i'      then 'intrigues'
  when 'structure', 'stt', 'f'      then 'structure'
  when 'rédaction', 'red', 'r'      then 'rédaction'
  when 'universalité', 'uni', 'fU'  then 'universalité'
  when 'originalité', 'ori', 'fO'   then 'originalité'
  when 'adéquation thème personnages', 'adq per', 'p:adth'  then 'p:adth'
  when 'cohérence personnages', 'coh per', 'p:cohe'         then 'p:cohe'
  when 'originalité personnages', 'ori per', 'p:fO'         then 'p:fO'
  when 'universalité personnages', 'uni per', 'p:fU'        then 'p:fU'
  when 'idiosyncrasie personnages', 'idi per', 'p:idio'     then 'p:idio'
  when 'originalité thèmes', 'ori the', 't:fO'              then 't:fO'
  when 'universalité thèmes', 'uni the', 't:fU'             then 't:fU'
  when 'adéquation thèmes', 'adq the', 't:adth'             then 't:adth'
  when 'cohérence thèmes', 'coh the', 't:cohe'              then 't:cohe'
  when 'originalité intrigues', 'ori int', 'i:fO'           then 'i:fO'
  when 'universalité intrigues', 'uni int', 'i:fU'          then 'i:fU'
  when 'cohérence intrigues', 'coh int', 'i:cohe'           then 'i:cohe'
  when 'adéquation thème intrigues', 'adq int', 'i:adth'    then 'i:adth'
  when 'non prédictibilité', 'prd', 'predic'                then 'predic'
  when 'clarté', 'clarté rédaction', 'cla', 'r:cla'         then 'r:cla'
  when 'orthographe', 'r:ortho'                             then 'r:ortho'
  when 'style', 'r:style'                                   then 'r:style'
  when 'simplicité', 'simplicité rédactionnelle', 'r:sim'   then 'r:sim'
  when 'émotion', 'r:emo'                                   then 'r:emo'
  end
end #/ real_key_for


end #/<< self class MotSujet

private

  def evaluation
    @evaluation ||= fiche.projet.evaluation.categories
  end

end #/Class MotSujet

def motSujet(key, fiche = nil)
  return MotSujet.get(key, fiche || MotSujet.fiche)
end

end #/ Class FicheLecture
