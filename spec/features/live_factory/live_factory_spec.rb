# encoding: UTF-8
=begin
  Ce module contient des pseudos méthodes pour préparer le site
  à un certain niveau. Il suffit de jouer `rspec spec/ -t <tag>` pour lancer
  la fabrication du stade voulu

  tag                 Stade
  ------------------------------------------
  up_to_signup              On se retrouve avec Marion qui vient de s'inscrire
                            sur le site (elle est la seule icarienne)

  mail_validated            Marion a validé son mail

  validation_inscription    Je valide l'inscription de Marion

  demarrage_module          Marion démarre son module d'apprentissage

  send_work                 Marion envoi ses documents de travail

=end
feature 'Préparation en live' do
  scenario 'Jusqu’à la fin de l’inscription', up_to_signup: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    require_relative 'lib'
    inscription_marion
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation du mail', mail_validated: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    require_relative 'lib'
    inscription_marion
    validation_du_mail
  end #/test d'une bonne candidate

  scenario 'Jusqu’à la validation de l’inscription pas l’administration', validation_inscription: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    require_relative 'lib'
    inscription_marion
    validation_du_mail
    admin_valide_inscription
  end #/test d'une bonne candidate

  scenario 'Jusqu’au démarrage du module', demarrage_module: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    require_relative 'lib'
    inscription_marion
    validation_du_mail
    admin_valide_inscription
    marion_demarre_module
  end #/test d'une bonne candidate

  scenario 'Jusqu’à l’envoi des documents de travail', send_work: true do
    # Les méthodes utiles
    extend SpecModuleNavigation
    extend SpecModuleFormulaire
    require_relative 'lib'
    inscription_marion
    validation_du_mail
    admin_valide_inscription
    marion_demarre_module
    marion_envoie_ses_documents
  end #/test d'une bonne candidate

end
