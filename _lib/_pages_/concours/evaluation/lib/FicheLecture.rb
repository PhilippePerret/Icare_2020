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

# Sortie de la fiche de lecture du synopsis
def out(options = nil)
  rassemble_resultats
  dispatche_per_element
  case options[:format]
  when :data
    out_as_data
  when :concurrent
    out_for_concurrent
  else
    puts "Je ne sais pas encore faire ça"
  end
end #/ out

# Pour construire la fiche à destination du concurrent (mail et affichage
# dans son espace)
ECUSSON = Emoji.new('objets/blason').regular
FICHE_LECTURE_TEMPLATE = <<-HTML
<div class="fiche-lecture">
  <div class="header">
    <div class="grand-titre">#{ECUSSON}#{ISPACE}Concours de Synopsis de L'atelier Icare#{ISPACE}#{ECUSSON}</div>
    <div class="div-annee">Édition <span class="annee">#{ANNEE_CONCOURS_COURANTE}</span></div>
  </div>

  <div class="infos-projet">
    <div class="projet-titre">
      <span class="libelle">TITRE</span>
      <span class="value">%{titre}</span>
    </div>
    <div class="projet-auteur">
      <span class="libelle">AUTEUR·E(S)</span>
      <span class="value">%{auteur}</span>
    </div>
  </div>

  <div class="divnote note-totale">
    <span class="libelle">Note : </span>
    <span class="value">%{note_totale}</span>
  </div>

  <div class="detail">

    <div class="divnote note-projet">
      <span class="libelle">Projet dans sa globalité</span>
      <span class="value">%{note_projet}</span>
      <div class="explication">%{explication_projet}</div>
    </div>

    <div class="divnote note-personnages">
      <span class="libelle">Personnages</span>
      <span class="value">%{note_personnages}</span>
      <div class="explication">%{explication_personnages}</div>
    </div>

    <div class="divnote note-forme">
      <span class="libelle">Forme/structure</span>
      <span class="value">%{note_forme}</span>
      <div class="explication">%{explication_forme}</div>
    </div>

    <div class="divnote note-intrigues">
      <span class="libelle">Intrigues</span>
      <span class="value">%{note_intrigues}</span>
    </div>

    <div class="divnote note-themes">
      <span class="libelle">Thèmes</span>
      <span class="value">%{note_themes}</span>
    </div>

    <div class="divnote note-facteur-O">
      <span class="libelle">Facteur O</span>
      <span class="value">%{facteurO}</span>
      <div class="expli">
        <div class="explication">%{facteurO_explication}</div>
        <div>%{facteurO_explication_per_note}</div>
      </div>
    </div>

    <div class="divnote note-facteur-U">
      <span class="libelle">Facteur U</span>
      <span class="value">%{facteurU}</span>
      <div class="expli">
        <div class="explication">%{facteurU_explication}</div>
        <div>%{facteurU_explication_per_note}</div>
      </div>
    </div>

  </div><!-- div.details -->

</div>
HTML

def out_for_concurrent
  FICHE_LECTURE_TEMPLATE % {
    titre: synopsis.titre,
    auteur: synopsis.concurrent.pseudo,

    note_totale: human_note_from_enotes(@all_enotes),

    note_projet: note_projet_props,
    explication_projet: DATA_MAIN_PROPERTIES[:projet][:explication],

    note_personnages: human_note_from_enotes(@notes_categories[:p]),
    explication_personnages: DATA_MAIN_PROPERTIES[:personnages][:explication],

    note_forme: human_note_from_enotes(@notes_categories[:f]),
    explication_forme: DATA_MAIN_PROPERTIES[:personnages][:explication],

    note_intrigues: human_note_from_enotes(@notes_categories[:i]),
    note_themes: human_note_from_enotes(@notes_categories[:t]),

    facteurO: note_sur_vingt(facteurO_note),
    facteurO_explication: DATA_MAIN_PROPERTIES[:fO][:explication],
    facteurO_explication_per_note: facteurO_explication_per_note,

    facteurU: "#{facteurU_note}/20",
    facteurU_explication: DATA_MAIN_PROPERTIES[:fU][:explication],
    facteurU_explication_per_note: facteurU_explication_per_note,

    # coherence:

  }
end #/ out_for_concurrent

# Retourne la note sur le projet, mais pas la note finale qui fait le total
# de toutes les notes mais la note sur le menu "Projet" et ses propriétés
# La difficulté est de les retrouver dans les ENotes, sans utiliser les
# clés explicitement
def note_projet_props
  human_note_from_enotes(@notes_categories[:projet])
end #/ note_projet_props

def facteurO_note
  @facteurO_note ||= calcul_note_from_enotes(@notes_main_properties[:fO])
end #/ facteurO_note
def facteurO_explication_per_note
  k = key_explication_per_note(facteurU_note)
  DATA_MAIN_PROPERTIES[:fO][k]
end #/ facteurO_explication_per_note

def facteurU_note
  @facteurU_note ||= calcul_note_from_enotes(@notes_main_properties[:fU])
end #/ facteurU_note
def facteurU_explication_per_note
  k = key_explication_per_note(facteurU_note)
  DATA_MAIN_PROPERTIES[:fU][k]
end #/ facteurU_explication_per_note

def key_explication_per_note(note)
  if    note > 15 then  :plus15
  elsif note > 9  then  :moins15
  elsif note > 4  then  :moins10
                  else  :moins5
  end
end #/ key_explication_per_note

# En entrée : une liste (Array) d'ENote
# En sortie : note sur 20
def calcul_note_from_enotes(enotes)
  n   = []
  enotes.each do |enote|
    n += enote.values
  end
  return '---' if n.empty?
  nr = n.count
  n  = n.inject(:+)
  coef = enotes.first.deepness_coefficiant
  n20 = ((4 * coef) * (n.to_f / nr)).round(1)
end #/ calcul_note_from_enotes

def human_note_from_enotes(enotes)
  note_sur_vingt(calcul_note_from_enotes(enotes))
end #/ human_note_from_enotes

def note_sur_vingt(n)
  return n if n == "---"
  n = n.to_s
  n = n.split('.').first if n.end_with?('.0')
  "#{n} / 20"
end #/ note_sur_vingt

=begin
  Version "data" de l'affichage de la fiche
  Principalement pour avoir une vision sans "parasite" (sans explication)
=end
LARGEUR_DATA = 40
def out_as_data
  lines = []
  lines << '<pre>'
  lines << line_data('Note principale générale', @ENotes['po'].values.inspect)

  # Les propriétés principales (cohérence, facteurO, facteur U etc.)
  DATA_MAIN_PROPERTIES.each do |kmp, dmprop|
    lines << line_data(dmprop[:short_name], human_note_from_enotes(@notes_main_properties[kmp]))
    lines << "<div class='justify'>#{dmprop[:explication]}</div>"
  end

  DATA_CATEGORIES.each do |kcate, dcate|
    lines << line_data("Note #{dcate[:name]}", human_note_from_enotes(@notes_categories[kcate]))
  end
  lines << RC * 2
  self.ENotes.each do |k, enote|
    lines << "#{k}/#{enote.fullid} : Coefficiant DeepNess: #{enote.deepness_coefficiant}#{RC}"
  end
  lines << '</pre>'
  return lines.join('')
end #/ out_as_data

def line_data(libelle, value)
  libelle.ljust(LARGEUR_DATA,'.') + ' ' + value.to_s + RC
end #/ line_data

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
def rassemble_resultats
  self.ENotes = {}
  @all_enotes = []
  Dir["#{synopsis.folder}/evaluation-*.json"].each do |fpath|
    evaluation_id = File.basename(fpath,File.extname(fpath)).split("-")
    concurrent_id, evaluator_id = evaluation_id
    JSON.parse(File.read(fpath)).each do |k, note|
      if not self.ENotes.key?(k)
        enote = ENote.new(k)
        self.ENotes.merge!(k => enote)
        @all_enotes << enote
      end
      # On ajoute cette valeur (même si c'est "-")
      self.ENotes[k].add_value(note)
    end
  end #/fin boucle sur tous les fichiers d'évaluation du synopsis
  # log("ENotes : #{self.ENotes}")
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
    @deepness_coefficiant ||= 1.0 - ( (deepness - 1).to_f / 10 )
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
