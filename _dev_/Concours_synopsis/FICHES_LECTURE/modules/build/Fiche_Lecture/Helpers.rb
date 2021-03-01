# encoding: UTF-8
# frozen_string_literal: true
=begin
  Helpers FicheLecture pour la construction des fiches de lecture
=end
class FicheLecture

# Retourne n'importe quel texte dans textes_fiches_lecture
def texte(key, subkey = nil)
  str = FicheLecture::DATA_MAIN_PROPERTIES[key]
  str = str[subkey] if subkey
  return str
end

def avertissement_subjectivite
  texte(:subjectivite)
end

def avertissement_divergence_note_gene_notes_details(note_gene, note_detail)
  diff = (note_gene - note_detail).abs
  str = texte(diff > 4 ? :forte_divergence_notes : :divergence_notes)
  str.gsub(/__note_generale__/, note_gene.to_s).gsub(/__note_details__/, note_detail.to_s)
end


def ecusson
  @ecusson ||= begin
    require './_lib/required/__first/constants/emojis'
    Emoji.new('objets/blason').regular
  end
end #/ ecusson

def formated_auteurs
  projet.real_auteurs
end #/ auteurs


# Position formatée du projet par rapport aux autres projet
def formated_position
  @formated_position ||= begin
    p = projet.position
    pstr = ""
    if not p.nil?
      pstr = p == 1 ? "1<exp>er</exp>" : "#{p}<exp>e</exp>"
      pstr = "#{pstr}#{ISPACE}<img src='/Users/philippeperret/Sites/AlwaysData/Icare_2020/img/Emojis/objets/coupe/coupe-regular.png' alt='Trophée' class='img-trophee' />" if p < 4 # => S'il est primé
    end
    "#{pstr} sur #{FLFactory.projets_valides.count} projets"
  end
end #/ position

end #/class FicheLecture
