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

def balise_interets_personnages
  interets_et_regrets_dans(['p:fO', 'p:fU','p:cohe', 'p:idio', 'p:adth'])
end

def balise_deficiences_personnages
  ary = ['p:co', 'p:fO', 'p:fU']
  MotSujet.inferieurs_a_10_parmi(ary).collect do |motsujet|
    "#{motsujet.du}#{motsujet.sujet}"
  end.pretty_join
end

def balise_raisons_bonnes_intrigues
  ary = ['ori int', 'uni int', 'adq int', 'i:fO', 'i:fU', 'predic', 'i:cohe', 'i:adth']
  interets_et_regrets_dans(ary)
end

def balise_raisons_mauvaises_intrigues

  raisons = []
  if motSujet('non prédictabilité').note < 10
    raisons << texte(:trop_grande_predictabilite)
  end
  if motSujet('originalité intrigues').note < 10
    raisons << texte(:manque_originalite)
  end

  malgres = []
  if motSujet('adéquation thème intrigues').note > 10
    malgres << texte(:adequation_avec_theme)
  end

  unless malgres.empty?
    raisons << "malgré #{malgres.pretty_join}"
  end

  raisons.pretty_join
end

def balise_raisons_bons_themes
  interets_et_regrets_dans(['t:fO', 't:fU', 't:cohe', 't:adth'])
end

# Méthode générique qui établit la liste des points positifs et des regrets
# éventuels dans la liste de catégories +ary_cates+
def interets_et_regrets_dans(ary_cates)
  # les bonnes raisons
  raisons = MotSujet.meilleurs_parmi(ary_cates).collect do |motsujet|
    "#{motsujet.du}#{motsujet.sujet}"
  end
  # éventuellement, les points à revoir
  malgres = MotSujet.inferieurs_a_10_parmi(ary_cates).collect do |motsujet|
    "#{motsujet.du}#{motsujet.sujet}"
  end
  if not malgres.empty?
    raisons << "des manques peut-être au niveau #{malgres.pretty_join}"
  end

  return raisons.pretty_join
end

end #/class FicheLecture
