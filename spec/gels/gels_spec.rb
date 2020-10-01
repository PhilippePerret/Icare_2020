# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module contient des pseudos méthodes pour préparer le site
  à un certain niveau. Il suffit de jouer `rspec spec/ -t <tag>` pour lancer
  la fabrication du stade voulu
=end
require_relative 'gels'
extend SpecModuleNavigation
extend SpecModuleFormulaire

GEL_REMOVE_LAST = 'GEL_REMOVE_LAST'
GEL_FORCE       = 'GEL_FORCE'
GEL_REMOVE_FROM = 'GEL_REMOVE_FROM'

def removed_required?()
  ENV[GEL_REMOVE_LAST]  || ENV[GEL_FORCE]
end #/ removed_required?

feature 'Préparation en live' do
  scenario 'Jusqu’à la fin de l’inscription', inscription_marion: true do
    Gel.remove('inscription_marion') if removed_required?
    inscription_marion
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation du mail', validation_mail: true do
    Gel.remove('validation_mail') if removed_required?
    validation_mail
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation de l’inscription pas l’administration', validation_inscription: true do
    Gel.remove('validation_inscription') if removed_required?
    validation_inscription
  end #/test d'une bonne candidate

  scenario 'Jusqu’au démarrage du module', demarrage_module: true do
    Gel.remove('demarrage_module') if removed_required?
    demarrage_module
  end #/test d'une bonne candidate

  scenario 'Jusqu’à l’envoi des documents de travail', envoi_travail: true do
    Gel.remove('envoi_travail') if removed_required?
    envoi_travail
  end #/test d'une bonne candidate

  scenario 'jusqu’à la récupération du travail par Phil', recupere_travail: true do
    Gel.remove('recupere_travail') if removed_required?
    recupere_travail
  end

  scenario 'jusqu’à l’envoi des commentaires', envoi_comments: true do
    Gel.remove('envoi_comments') if removed_required?
    envoi_comments
  end

  scenario 'jusqu’à la récupération des commentaires par l’icarien', recupere_comments:true do
    Gel.remove('recupere_comments') if removed_required?
    recupere_comments
  end

  scenario 'jusqu’au dépôt changement d’étape', change_etape: true do
    Gel.remove('change_etape') if removed_required?
    change_etape
  end

  scenario 'jusqu’au dépôt des documents par moi', depot_qdd: true do
    Gel.remove('depot_qdd') if removed_required?
    depot_qdd
  end

  scenario 'jusqu’à la définition du partage par Marion', define_sharing: true do
    Gel.remove('define_sharing') if removed_required?
    define_sharing
  end

  scenario 'jusqu’à l’inscription de Benoit', inscription_benoit: true do
    Gel.remove('inscription_benoit') if removed_required?
    inscription_benoit
  end

  scenario 'jusqu’à l’inscription d’Élie', inscription_elie: true do
    Gel.remove('inscription_elie') if removed_required?
    inscription_elie
  end

  scenario 'jusqu’à la validation du mail par Benoit', benoit_valide_son_mail:true do
    Gel.remove('benoit_valide_son_mail') if removed_required?
    benoit_valide_son_mail
  end

  scenario 'jusqu’à la validation du mail par Élie', elie_valide_son_mail:true do
    Gel.remove('elie_valide_son_mail') if removed_required?
    elie_valide_son_mail
  end

  scenario 'jusqu’à la validation des deux inscriptions', validation_deux_inscriptions:true do
    Gel.remove('validation_deux_inscriptions') if removed_required?
    validation_deux_inscriptions
  end

  scenario 'jusqu’au contact frigo de Benoit', benoit_frigote_phil_marion_et_elie: true do
    Gel.remove('benoit_frigote_phil_marion_et_elie') if removed_required?
    benoit_frigote_phil_marion_et_elie
  end

  scenario 'Phil, Marion et Elie répondent au message de Benoit', phil_marion_elie_repondent_benoit:true do
    Gel.remove('phil_marion_elie_repondent_benoit') if removed_required?
    phil_marion_elie_repondent_benoit
  end

  scenario 'jusqu’à l’inscription du futur détruit', inscription_destroyed: true do
    Gel.remove('inscription_destroyed') if removed_required?
    inscription_destroyed
  end

  scenario 'jusqu’à la validation du mail du futur détruit', destroyed_valide_son_mail: true do
    Gel.remove('destroyed_valide_son_mail') if removed_required?
    destroyed_valide_son_mail
  end

  scenario 'jusqu’à la validation de l’inscription de destroyed', phil_valide_inscription_destroyed: true do
    Gel.remove('phil_valide_inscription_destroyed') if removed_required?
    phil_valide_inscription_destroyed
  end

  scenario 'jusqu’au démarrage de son module par destroyed', destroyed_demarre_son_module: true do
    Gel.remove('destroyed_demarre_son_module') if removed_required?
    destroyed_demarre_son_module
  end

  scenario 'jusqu’à la destruction par destroyed', destroyed_se_detruit: true do
    Gel.remove('destroyed_se_detruit') if removed_required?
    destroyed_se_detruit
  end

  scenario 'jusqu’au démarrage du module d’Élie', elie_demarre_son_module: true do
    Gel.remove('elie_demarre_son_module') if removed_required?
    elie_demarre_son_module
  end

  scenario 'jusqu’au démarrage du module de Benoit', benoit_demarre_son_module: true do
    Gel.remove('benoit_demarre_son_module') if removed_required?
    benoit_demarre_son_module
  end

  scenario 'tout un cycle de document pour Marion', marion_envoie_deux_autres_documents_cycle_complet: true do
    Gel.remove('marion_envoie_deux_autres_documents_cycle_complet') if removed_required?
    marion_envoie_deux_autres_documents_cycle_complet
  end

  scenario 'marion paie son module d’apprentissage (devient une vraie icarienne)', marion_paie_son_module: true do
    Gel.remove('marion_paie_son_module') if removed_required?
    marion_paie_son_module
  end

  scenario 'L’admin passe marion à sa dernière étape', phil_passe_marion_a_etape_fin: true do
    Gel.remove('phil_passe_marion_a_etape_fin') if removed_required?
    phil_passe_marion_a_etape_fin
  end

  scenario 'marion termine son module (devient inactive)', phil_arrete_module_marion: true do
    Gel.remove('phil_arrete_module_marion') if removed_required?
    phil_arrete_module_marion
  end

end
