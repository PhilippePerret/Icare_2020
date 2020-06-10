# encoding: UTF-8
=begin
  Ce module contient des pseudos méthodes pour préparer le site
  à un certain niveau. Il suffit de jouer `rspec spec/ -t <tag>` pour lancer
  la fabrication du stade voulu

  tag                 Stade
  ------------------------------------------
  inscription_marion        On se retrouve avec Marion qui vient de s'inscrire
                            sur le site (elle est la seule icarienne)

  mail_validated            Marion a validé son mail

  validation_inscription    Je valide l'inscription de Marion

  demarrage_module          Marion démarre son module d'apprentissage

  send_work                 Marion envoi ses documents de travail

=end
require_relative 'gels'

feature 'Préparation en live' do
  scenario 'Jusqu’à la fin de l’inscription', inscription_marion: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    inscription_marion
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation du mail', validation_mail: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    inscription_marion
    validation_mail
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation de l’inscription pas l’administration', validation_inscription: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    inscription_marion
    validation_mail
    validation_inscription
  end #/test d'une bonne candidate

  scenario 'Jusqu’au démarrage du module', demarrage_module: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    inscription_marion
    validation_mail
    validation_inscription
    demarrage_module
  end #/test d'une bonne candidate

  scenario 'Jusqu’à l’envoi des documents de travail', envoi_travail: true do
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    inscription_marion
    validation_mail
    validation_inscription
    demarrage_module
    envoi_travail
  end #/test d'une bonne candidate

  scenario 'jusqu’à la récupération du travail par Phil', recupere_travail: true do
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    inscription_marion
    validation_mail
    validation_inscription
    demarrage_module
    envoi_travail
    recupere_travail
  end
end
