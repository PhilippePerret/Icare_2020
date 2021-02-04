# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module FicheLecture pour la gestion des "balises" dans les textes des
  fiches de lecture.
=end


class FicheLecture

#
# Traitement des balises “[[...]]” dans les textes de la fiche de lecture
#
def traite_balises_in(init_texte)
  init_texte || return
  init_texte.gsub(/\[\[(.+?)\]\]/){
    balise = $1.freeze
    method = "balise_#{balise.gsub(/ /,'_')}".to_sym.freeze
    if self.respond_to?(method)
      send(method)
    else
      "[[BALISE INCONNUE : #{balise}]]"
    end
  }
end #/ traite_balises_in

# Quand « [[histoire]] » est utilisé dans le texte
def balise_histoire
  case motSujet('projet').note_lettre
  when 'A'  then 'excellente histoire'
  when 'B' then 'bonne histoire'
  else 'histoire'
  end
end

def balise_ce_projet
  case motSujet('projet').note_lettre
  when 'A'  then 'cet excellent projet'
  when 'B' then 'ce bon projet'
  else 'ce projet'
  end
end

def balise_projet
  case motSujet('projet').note_lettre
  when 'A'  then 'excellent projet' # ATTENTION ARTICLE !
  when 'B' then 'bon projet'
  else 'projet'
  end
end

# Retourne le contenu pour la balise « [[interets_histoire]] »
def balise_interets_histoire
  # L'intérêt peut dépendre
  # ary = [motSujet('per'),motSujet('the'),motSujet('int'),motSujet('stt'), motSujet('uni'), motSujet('ori')]
  ary = ['per','the','int','stt', 'uni', 'ori']
  MotSujet.meilleurs_parmi(ary).collect do |motsujet|
    "#{motsujet.du}#{motsujet.sujet}"
  end.pretty_join
end

# Retourne le contenu pour la balise « [[deficience_histoire]] »
def balise_deficiences_histoire
  # ary = [motSujet('per'),motSujet('the'),motSujet('int'),motSujet('stt'), motSujet('uni'), motSujet('ori')]
  ary = ['per','the','int','stt', 'uni', 'ori']
  MotSujet.inferieurs_a_10_parmi(ary).collect do |motsujet|
    "#{motsujet.du}#{motsujet.sujet}"
  end.pretty_join
end

def balise_deficiences_personnages
  ary = ['p:co', 'p:fO', 'p:fU']
  MotSujet.inferieurs_a_10_parmi(ary).collect do |motsujet|
    "#{motsujet.du}#{motsujet.sujet}"
  end.pretty_join
end

end #/class FicheLecture
