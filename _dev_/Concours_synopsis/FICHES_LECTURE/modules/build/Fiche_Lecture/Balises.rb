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

def balise_la_note_generale
  case motSujet('projet').note
  when (17..20)   then 'l’excellente note'
  when (14...17)  then 'la bonne note'
  when (11...14)  then 'la note honnorable'
  when (7...11)   then 'la note passable'
  else 'la mauvaise note'
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

def balise_estimation_titre
  texte(:titre, key_per_note(motSujet('titre').note))
end

# Retourne le contenu pour la balise « [[interets_histoire]] »
def balise_interets_histoire
  ary = ['per','the','int','stt', 'uni', 'ori']
  MotSujet.formate_liste(MotSujet.meilleurs_parmi(ary), as: :quality)
end

# Retourne le contenu pour la balise « [[deficience_histoire]] »
def balise_deficiences_histoire
  # ary = [motSujet('per'),motSujet('the'),motSujet('int'),motSujet('stt'), motSujet('uni'), motSujet('ori')]
  ary = ['per','the','int','stt', 'uni', 'ori']
  MotSujet.formate_liste(MotSujet.inferieurs_a_10_parmi(ary, true), as: :defect)
end

def balise_deficiences_originalite
  ary = ['p:fO', 't:fO', 'i:fO']
  MotSujet.formate_liste(MotSujet.inferieurs_a_10_parmi(ary, true), as: :defect, full_name:true)
end

def balise_mention_manque_universalite
  nfU = motSujet('fU').note
  if nfU < 8
    texte(:facteurO, :grand_manque_universalite)
  elsif nfU < 12
    texte(:facteurO, :manque_universalite)
  else
    ''
  end
end

def balise_mention_manque_originalite
  nfO = motSujet('fO').note
  if nfO < 8
    texte(:facteurO, :grand_manque_originalite)
  elsif nfO < 12
    texte(:facteurO, :manque_originalite)
  else
    ''
  end
end


def balise_deficiences_coherence
  ary = ['i:cohe','p:cohe','t:cohe']
  MotSujet.formate_liste( MotSujet.inferieurs_a_10_parmi(ary, true), as: :defect )
end

# La liste commune pour les personnages
def ary_personnages
  @ary_personnages ||= ary = ['p:fO', 'p:fU','p:cohe', 'p:idio', 'p:adth']
end

def balise_interets_personnages
  interets_et_regrets_dans(ary_personnages)
end

def balise_if_deficiences_personnages
  perf = MotSujet.perfectibles_parmi(ary_personnages)
  if not perf.empty?
    traite_balises_in(texte(:personnages, :perfectibility))
  end
end
def balise_perfectibilities_personnages
  MotSujet.formate_liste(MotSujet.perfectibles_parmi(ary_personnages), as: :defect)
end


def balise_deficiences_personnages
  ary = ['p:cohe', 'p:fO', 'p:fU']
  MotSujet.inferieurs_a_10_parmi(ary, true).collect do |motsujet|
    if verbose?
      "#{motsujet.du}#{motsujet.sujet} (#{motsujet.note})#{motsujet.as_defect}"
    else
      "#{motsujet.du}#{motsujet.sujet}#{motsujet.as_defect}"
    end
  end.pretty_join
end

def balise_raisons_bonnes_intrigues
  ary = ['predic', 'i:fO', 'i:fU', 'i:cohe', 'i:adth']
  interets_et_regrets_dans(ary)
end

def balise_raisons_mauvaises_intrigues

  raisons = []
  if motSujet('non prédictibilité').note < 10
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

def ary_themes
  @ary_themes ||= ['t:fO', 't:fU', 't:cohe', 't:adth']
end

def balise_raisons_bons_themes
  raisons = MotSujet.formate_liste(MotSujet.meilleurs_parmi(ary_themes), as: :quality, article: :le)
end

def balise_raisons_mauvais_themes
  MotSujet.formate_liste( MotSujet.inferieurs_a_10_parmi(ary_themes, true), as: :defect, aticle: :le )
end

def balise_if_ameliorations_themes
  lst = MotSujet.inferieurs_a_10_parmi(ary_themes)
  return '' if lst.empty?
  " Des améliorations pourraient cependant être apportées au niveau #{MotSujet.formate_liste(lst, {as: :defect, article: :de})}"
end

def balise_les_ameliorations_themes
  MotSujet.formate_liste(MotSujet.inferieurs_a_10_parmi(ary_themes, true), {as: :defect, article: :le})
end

def ary_redaction
  @ary_redaction ||= ['r:cla', 'r:ortho', 'r:style', 'r:sim', 'r:emo']
end

def balise_if_deficiences_redaction
  # S'il y a des notes < 10, on ajoute ", particulièrement au niveau [[...]]"
  surtouts = []
  # S'il y a des notes < 15, on ajoute "notamment au niveau"
  notammes = []
  ary_redaction.each do |key|
    mots = motSujet(key)
    if mots.note < 10
      surtouts << mots.du_sujet
    elsif mots.note < 15
      notammes << mots.du_sujet
    end
  end
  if surtouts.empty?
    ", notamment au niveau #{notammes.pretty_join}"
  else
    ", tout particulièrement au niveau #{surtouts.pretty_join}"
  end
end

def balise_deficiences_redaction
  MotSujet.formate_liste(MotSujet.inferieurs_a_10_parmi(ary_redaction, true), as: :defect, article: :de)
end
def balise_les_deficiences_redaction
  MotSujet.formate_liste(MotSujet.inferieurs_a_10_parmi(ary_redaction, true), as: :defect, article: :le)
end

def balise_importance_redaction
  texte(:redaction, :importance)
end

# Pour la mention à ajouter quand la clarté de la rédaction n'est pas bonne
def balise_mention_manque_clarte
  @nombre_iterations ||= 0
  note_redaction = motSujet('rédaction').note
  return "" if note_redaction > 12
  if note_redaction < 8
    # Note inférieure à 8
    @iterations_redac_nulle ||= FicheLecture::DATA_MAIN_PROPERTIES[:mentions_redaction_nulle].dup
    traite_balises_in(@iterations_redac_nulle.shift)
  else
    # Note entre 8 et 12
    @iterations_redac_bad ||= FicheLecture::DATA_MAIN_PROPERTIES[:mentions_redaction_bad].dup
    traite_balises_in(@iterations_redac_bad.shift)
  end
end

# Méthode générique qui établit la liste des points positifs et des regrets
# éventuels dans la liste de catégories +ary_cates+
def interets_et_regrets_dans(ary_cates, article = :de)
  # les bonnes raisons
  raisons = MotSujet.formate_liste(MotSujet.meilleurs_parmi(ary_cates), as: :quality, article:article)

  # éventuellement, les points à revoir
  malgres = MotSujet.inferieurs_a_10_parmi(ary_cates)
  if not malgres.empty?
    raisons = raisons + " malgré des manques peut-être au niveau " + MotSujet.formate_liste(malgres, as: :defect, article:article)
  end

  return raisons
end

end #/class FicheLecture
