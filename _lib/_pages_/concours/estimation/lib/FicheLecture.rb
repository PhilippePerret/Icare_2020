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
end #/FicheLecture
