#!/usr/bin/env ruby
# encoding: UTF-8
=begin

  Pour lancer ce script :

  * Régler les données du fichier config.rb
  * Ouvrir le Terminal
  * Se mettre dans le dossier de l'atelier
    > cd /Users/philippeperret/Sites/AlwaysData/Icare_2020
  * Jouer ce script (pour obtenir l'aide)
    > _dev_/_VERSION_2020_/_GET_OLD_DATA_/run.rb

Pour détruire toutes les tables online :
    > _dev_/_VERSION_2020_/_GET_OLD_DATA_/run.rb drop_all
=end
require_relative './xlib/required'
Runner.run
