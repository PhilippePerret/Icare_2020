# encoding: UTF-8
# frozen_string_literal: true
=begin
  Classe FicheLecture
  -------------------
  Pour la gestion de la fiche de lecture qui sera produite

  C'est cette fiche de lecture qui:
    - calcule les notes finales
    - calcule LA note générale du synopsis
    - produit la note en langage humain d'après les résultats

  CONTENU
  -------
    * Note générale
    * Position par rapport aux autres synopsis
    * Notes par grandes parties (Personnages, Forme/Intrigues, Thèmes, Rédaction)
    * Note de cohérence
      Rassembler les valeurs de toutes les "cohérences" pour faire un sujet
      général
    * Note d'adéquation au thème
      Rassembler toutes les valeurs d'adéquation avec le thème pour faire
      un sujet général
    * Note d'équilibre U/O (facteur U et facteur O)

=end
require 'yaml'
require_relative './constants'
require_relative './ENotesFL'

class FicheLecture

DATA_CATEGORIES = {
  p: {name: "Personnages"},
  f: {name: "Forme"},
  i: {name: "Intrigues"},
  t: {name: "Thèmes"},
  r: {name: "Rédaction"},
}

DATA_MAIN_PROPERTIES = YAML.load_file(DATA_MAIN_PROPERTIES_FILE)

class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :synopsis
attr_accessor :ENotes
def initialize(synopsis)
  @synopsis = synopsis
end #/ initialize

def bind; binding() end

# DO    Produit le fichier HTML de la fiche de lecture (ou peut-être aussi pdf)
def export
  log("---> Export fiche de lecture de “#{synopsis.titre}”")
  res = `/usr/local/bin/wkhtmltopdf "#{App::URL}/concours/fiche_lecture?cid=#{synopsis.concurrent_id}&an=#{Concours.current.annee}" "#{pdf_file_path}" 2>&1`
  log("     Res: #{res.inspect}")
end #/ export
def pdf_file_path
  @pdf_file_path ||=  File.join(TEMP_FOLDER,'concours',pdf_filename)
end #/ pdf_file_path
def pdf_filename
  @pdf_filename ||= "fiche-#{synopsis.concurrent_id}-#{Concours.current.annee}.pdf"
end #/ pdf_filename

# Sortie de la fiche de lecture du synopsis
def out(options = nil)
  rassemble_resultats
  dispatche_per_element
  case options[:format]
  when :concurrent
    out_for_concurrent
  else
    puts "Je ne sais pas encore faire ça"
  end
end #/ out

# OUT   True si la fiche de lecture est téléchargeable.
# Note  Pour qu'elle soit téléchargeable, il faut :
#       - qu'elle existe en tant que fichier pdf (dans tmp/concours)
#       - que le concours ne soit plus en phase 1, qu'il soit en phase
#         3 si le concurrent n'a pas été sélectionné pour la phase finale,
#         ou en phase 5 si le concurrent a été sélectionné.
def downloadable?
  Concours.current.phase > 1 && File.exists?(pdf_file_path)
end #/ downloadable?

def download_link
  "#{App::URL}/tmp/concours/#{pdf_filename}"
end #/ download_link

# OUT   Retourne le code HTML de la fiche de lecture complète pour le
#       synopsis.
def out_for_concurrent
  deserb('templates/fiche_lecture_template', self)
end #/ out_for_concurrent

def ecusson
  @ecusson ||= Emoji.new('objets/blason').regular
end #/ ecusson
def annee_edition ; ANNEE_CONCOURS_COURANTE end

def formated_auteurs
  synopsis.real_auteurs
end #/ auteurs

def all_enotes
  @all_enotes || begin
    rassemble_resultats
    dispatche_per_element
  end
  @all_enotes
end #/ all_enotes

# Pour la gestion du total
def total
  @total ||= ENotesFL.new(:total, all_enotes)
end #/ total

# Position du synopsis par rapport aux autres synopsis
def position
  @position ||= begin
    p = synopsis.position
    pstr = ""
    if not p.nil?
      pstr = p == 1 ? "1<exp>er</exp>" : "#{p}<exp>e</exp>"
      pstr = "#{pstr}#{ISPACE}🏆" if p < 4 # => S'il est primé
    end
    pstr
  end
end #/ position

def projet
  @projet ||= ENotesFL.new(:projet, @notes_categories[:projet])
end #/ projet

def personnages
  @personnages ||= ENotesFL.new(:personnages, @notes_categories[:p])
end #/ personnages

def intrigues
  @intrigues ||= ENotesFL.new(:intrigues, @notes_categories[:i])
end #/ intrigues

def themes
  @themes ||= ENotesFL.new(:themes, @notes_categories[:t])
end #/ themes

def forme
  @forme ||= ENotesFL.new(:forme, @notes_categories[:f])
end #/ forme_note

def facteurO
  @facteurO ||= ENotesFL.new(:fO, @notes_main_properties[:fO])
end #/ facteurO

def facteurU
  @facteurU ||= ENotesFL.new(:fU, @notes_main_properties[:fU])
end #/ facteurU


# Méthode qui prend tous les fichiers d'évaluation du synopsis et produit
# la table de résultats qui va permettre d'établir la fiche de lecture
# Cette table de résultats contiendra :
#   - date:         La date d'établissement de cette table
#   - evaluators:   Les ID des évaluateurs trouvés par rapport aux fichiers
#   - note_generale   La note générale
#   - coherence:
#       - nombre_questions:   Nombre totale de questions
#       - nombre_done:        Nombre de questions répondu
#       - notes
#       - note_generale
#   - adequation_theme
#       - nombre_questions
#       - nombre_done
#       - notes
#       - note_generale
#
def rassemble_resultats(pour_prix = false)
  @ENotes = {}
  @all_enotes = []
  key_eval = pour_prix ? 'prix' : 'pres'
  Dir["#{synopsis.folder}/evaluation-#{key_eval}-*.json"].each do |fpath|
    evaluation_id = File.basename(fpath,File.extname(fpath)).split("-")
    concurrent_id, evaluator_id = evaluation_id
    JSON.parse(File.read(fpath)).each do |k, note|
      if not @ENotes.key?(k)
        enote = ENote.new(k)
        @ENotes.merge!(k => enote)
        @all_enotes << enote
      end
      # On ajoute cette valeur (même si c'est "-")
      @ENotes[k].add_value(note)
    end
  end #/fin boucle sur tous les fichiers d'évaluation du synopsis
  # log("ENotes : #{@ENotes}")
  # log("@all_enotes: #{@all_enotes.inspect}")
end #/ rassemble_resultats

# Après avoir ramassé toutes les notes dans <FicheLecture>@ENotes, on peut
# rassemble par élément
def dispatche_per_element
  cohe = []
  adth = []
  facO = []
  facU = []
  cates = {p: [], f:[], i: [], t: [], r: [], projet: []}
  @ENotes.each do |k, enote|
    cohe << enote if enote.coherence?
    adth << enote if enote.adequation_theme?
    # log("(k = #{k}) enote.facteurO? est #{enote.facteurO?.inspect}")
    facO << enote if enote.facteurO?
    facU << enote if enote.facteurU?
    # Catégories
    cates[enote.main_categorie] << enote
  end

  # Les noms ci-dessous doivent correspondre aux :id dans data_main_properties.yaml
  @notes_main_properties = {cohe:nil, adth:nil, fO:nil, fU:nil}
  @notes_main_properties[:cohe] = cohe
  @notes_main_properties[:adth] = adth
  @notes_main_properties[:fO]   = facO
  @notes_main_properties[:fU]   = facU

  @notes_categories = cates
end #/ rassemble_per_element


end #/FicheLecture

class ENote
  attr_reader :fullid, :values
  attr_reader :ids, :main_categorie
  def initialize(fullid)
    @fullid = fullid
    decompose_fullid
    @values = []
  end #/ initialize

  # Pour ajouter une valeur
  def add_value(val)
    return if val == "-"
    @values << val
  end #/ add_value

  # ---------------------------------------------------------------------
  #
  #   Properties
  #
  # ---------------------------------------------------------------------

  # Cette question, suivant sa profondeur, vaut TANT de question (une demi
  # question, un tiers de question, etc.)
  def part_question
    @part_question ||= deepness_coefficiant
  end #/ part_question

  # Coefficiant de profondeur (il faut multiplier la valeur par ce coefficiant)
  def deepness_coefficiant
    @deepness_coefficiant ||= begin
      dness = deepness > 0 ? deepness : 1
      1.0 - ( (dness - 1).to_f / 10 )
    end
  end #/ deepness_coefficiant

  def deepness
    @deepness ||= fullid.split('-').count - 1
  end #/ deepness

  # Retourne TRUE si la note concerne le facteur O
  def facteurO? ; ids[:fO] end
  def facteurU? ; ids[:fU] end
  def coherence? ; ids[:cohe] end
  def adequation_theme? ; ids[:adth] end

  # Retourne true si la note est définie
  def defined?
    (@is_defined ||= begin
      value != "-" ? :true : :false
    end) == :true
  end #/ defined?


private

  # Décompose le fullid de la question
  # Produit une table :ids qui contient en clé les identifiants individuels
  # des questions (par exemple :fO ou :cohe) et en valeur TRUE (juste pour
  # savoir si la catégorie existe)
  # Produit :main_categorie, la lettre qui correspond à la catégorie principale
  #
  def decompose_fullid
    @ids = {}
    fullid_splited = fullid.split('-')
    if FicheLecture::DATA_CATEGORIES.key?(fullid_splited[1]&.to_sym)
      @main_categorie = fullid_splited[1].to_sym # :p, :i etc.
    else
      @main_categorie = :projet
    end
    fullid_splited.each{|i| @ids.merge!(i.to_sym => true)}
    # log("@ids = #{@ids.inspect}")
  end #/ decompose_fullid
end #/ENote
