# encoding: UTF-8
=begin
  Ce module contient des pseudos méthodes pour préparer le site
  à un certain niveau. Il suffit de jouer `rspec spec/ -t <tag>` pour lancer
  la fabrication du stade voulu
=end
require_relative 'gels'
extend SpecModuleNavigation
extend SpecModuleFormulaire

feature 'Préparation en live' do
  scenario 'Jusqu’à la fin de l’inscription', inscription_marion: true do
    Gel.remove('inscription_marion') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    inscription_marion
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation du mail', validation_mail: true do
    Gel.remove('validation_mail') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    validation_mail
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation de l’inscription pas l’administration', validation_inscription: true do
    Gel.remove('validation_inscription') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    validation_inscription
  end #/test d'une bonne candidate

  scenario 'Jusqu’au démarrage du module', demarrage_module: true do
    Gel.remove('demarrage_module') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    demarrage_module
  end #/test d'une bonne candidate

  scenario 'Jusqu’à l’envoi des documents de travail', envoi_travail: true do
    Gel.remove('envoi_travail') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    envoi_travail
  end #/test d'une bonne candidate

  scenario 'jusqu’à la récupération du travail par Phil', recupere_travail: true do
    Gel.remove('recupere_travail') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    recupere_travail
  end

  scenario 'jusqu’à l’envoi des commentaires', envoi_comments: true do
    Gel.remove('envoi_comments') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    envoi_comments
  end

  scenario 'jusqu’à la récupération des commentaires par l’icarien', recupere_comments:true do
    Gel.remove('recupere_comments') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    recupere_comments
  end

  scenario 'jusqu’au dépôt des documents par moi', depot_qdd: true do
    Gel.remove('depot_qdd') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    depot_qdd
  end

  scenario 'jusqu’à la définition du partage par l’icarien', define_sharing: true do
    Gel.remove('define_sharing') if ENV['GEL_REMOVE_LAST'] || ENV['GEL_FORCE']
    define_sharing
  end
end
