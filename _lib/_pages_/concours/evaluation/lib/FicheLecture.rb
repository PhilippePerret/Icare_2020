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
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :synopsis
def initialize(synopsis)
  @synopsis
end #/ initialize

# Méthode qui lit toutes les fiches de lecture et établit les
# notes générales, par grandes parties
#
# @produit
#   La table @table_resultats
#   qui contient en clé les id des rubriques principales (par exemple "g" pour
#   "globalité" ou "p" pour "personnages"). cf. DATA_EVALUATION_PROJET
#   qui contient en valeur une table ou :value est la note attribuée par
#   l'évaluateur.
def calculate_notes_generales
  @table_resultats = []
  # Rassembler toutes les fiches de lecture
  Dir["#{synopsis.folder}/evaluation-*.json"].each do |fpath|
    de = JSON.parse(File.read(fpath))
    de.each do |k, data|
      main_prop = k.split('-')[1] # le tout premier est toujours 'p' pour 'projet'
      @table_resultats.merge!(main_prop => 0) unless @table_resultats.key?(k)
      @table_resultats[k] += data['value']
    end
  end
end #/ calculate_notes_generales

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
  Dir["#{synopsis.folder}/evaluation-*.json"].each do |fpath|
    de = JSON.parse(File.read(fpath))
    de.each do |k, data|
      main_prop = k.split('-')[1] # le tout premier est toujours 'p' pour 'projet'
      @table_resultats.merge!(main_prop => 0) unless @table_resultats.key?(k)
      @table_resultats[k] += data['value']
    end
  end
end #/ rassemble_resultats

end #/FicheLecture

class ENote
  attr_reader :fullid, :value
  attr_reader :ids, :main_categorie
  def initialize(fullid, value)
    @fullid = fullid
    @value  = value
    decompose_fullid
  end #/ initialize


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
    fullid_splited = fullid[2..-1].split('-')
    @main_categorie = fullid_splited.first
    fullid_splited.each{|i| @ids.merge!(i.to_sym => true)}
  end #/ decompose_fullid
end #/ENote
