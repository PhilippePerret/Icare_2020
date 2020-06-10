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
    # Les méthodes utiles
    inscription_marion
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation du mail', validation_mail: true do
    # Les méthodes utiles
    validation_mail
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation de l’inscription pas l’administration', validation_inscription: true do
    validation_inscription
  end #/test d'une bonne candidate

  scenario 'Jusqu’au démarrage du module', demarrage_module: true do
    demarrage_module
  end #/test d'une bonne candidate

  scenario 'Jusqu’à l’envoi des documents de travail', envoi_travail: true do
    envoi_travail
  end #/test d'une bonne candidate

  scenario 'jusqu’à la récupération du travail par Phil', recupere_travail: true do
    recupere_travail
  end

  scenario 'jusqu’à l’envoi des commentaires', envoi_comments: true do
    envoi_comments
  end

end
