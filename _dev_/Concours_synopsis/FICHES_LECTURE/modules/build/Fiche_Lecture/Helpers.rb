# encoding: UTF-8
# frozen_string_literal: true
=begin
  Helpers FicheLecture pour la construction des fiches de lecture
=end
class FicheLecture

def avertissement_subjectivite
  FicheLecture::DATA_MAIN_PROPERTIES[:subjectivite]
end

def ecusson
  @ecusson ||= begin
    require './_lib/required/__first/constants/emojis'
    Emoji.new('objets/blason').regular
  end
end #/ ecusson
def annee_edition ; FLFactory.annee_courante end

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
