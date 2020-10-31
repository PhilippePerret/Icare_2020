# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class ENotesFL
  -----------------
  En rassemblant les résultats des différents projets pour chaque évaluateur,
  le programme produit des listes Array de ENote.
  Une ENote, c'est un point particulier noté, qui contient toutes les notes qui
  ont été attribuées par les différents évaluateur. Par exemple, un ENote
  contient tout ce qui concerne la structure du projet.

  La classe ENotesFL permet de gérer cet ensemble pour la fiche de lecture
  d'où le "FL" en fin de nom de classe.

=end

class ENotesFL
  attr_reader :key, :enotes
  # La note (Float) calculée
  attr_reader :note

  def initialize key, enotes
    @key    = key
    @enotes = enotes
    calcul_note
  end #/ initialize

  def undefined?
    @is_undefined == :true
  end #/ undefined?

  # OUT   La note flottante
  def note
    @note ||= begin
    end
  end

  # OUT   La note, au format humain (épurée de son zéro)
  def human_note
    @human_note ||= begin
      self.class.note_string(self)
    end
  end

  # OUT   Explication concernant l'élément courant
  def explication
    FicheLecture::DATA_MAIN_PROPERTIES[key][:explication]
  end

  # OUT   Explication propre en fonction de la note obtenue, par rang de 5
  def explication_per_note
    return "" if undefined?
    FicheLecture::DATA_MAIN_PROPERTIES[key][self.class.key_explication_per_note(note)]
  end

private

  def calcul_note
    n = self.class.calcul_note_from_enotes(enotes)
    # log("n pour #{key} : #{n.inspect}")
    @is_undefined = (n == '---') ? :true : :false
    # log("undefined? (#{key}) est #{undefined?.inspect}")
    n = 0 if n == '---'
    @note = n
  end #/ calcul_note

public

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

# La clé de l'explication humaine propre à la note
# --------------------------------------
# IN    La note au format flottant
# OUT   La clé correspondante dans le fichier data_main_properties.yaml
#       pour obtenir l'explication humaine plus précise de la note.
def key_explication_per_note(note)
  if    note > 15 then  :plus15
  elsif note > 9  then  :moins15
  elsif note > 4  then  :moins10
                  else  :moins5
  end
end #/ key_explication_per_note

# Calcul de la note d'après les ENote(s)
# --------------------------------------
# IN    Une liste (Array) d'ENote
# OUT   Note flottante sur 20
def calcul_note_from_enotes(enotes)
  n   = []
  enotes.each do |enote|
    if not enote.respond_to?(:values)
      raise "Devrait être une instance ENote : #{enote.inspect}"
    end
    n += enote.values
  end
  return '---' if n.empty?
  nr = n.count
  n  = n.inject(:+)
  coef = enotes.first.deepness_coefficiant
  (4 * coef) * (n.to_f / nr)
end #/ calcul_note_from_enotes

# Transformation en note String
# -----------------------------
# Entrée : la note en format flottant
# Sortie : la note string, épuré de son zéro final le cas échéant
def note_string(inst)
  return '---' if inst.undefined?
  n = inst.note.round(1)
  n = n.to_s
  n = n.split('.').first if n.end_with?('.0')
  return n
end #/ note_string

end # /<< self
end #/EnsembeENotes
