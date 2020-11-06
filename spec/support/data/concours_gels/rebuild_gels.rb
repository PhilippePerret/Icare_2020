# encoding: UTF-8
# frozen_string_literal: true
=begin
  Après avoir galéré énormément pour obtenir des données utiles pour les
  tests des concours, j'en vois à faire des données fixes qui permettront
  de tout gérer.

  Qu'est-ce qu'il faut ?

    - des évaluators dans les deux jurys et les deux jurys en même temps
        => fichier ./_lib/data/secret/concours.rb
        Question : faut-il faire la liste des évaluateurs des anciens
        concours ? Oui, il faut les garder, par année dans la constante
        CONCOURS_DATA[:evaluators][ANNNEE]
    - des fiches d'évaluation
        - anciennes et nouvelles (en fait, en fonction des fichiers conformes,
          en partant du principe que tout doit être fini : si un concurrent
          a déposé un fichier conforme pour le concours courant, il doit
          avoir ses évaluations de chacun des membres du jury courant
    - des données CONCURRENTS de toutes sortes (au moins 30) :
      En jouant sur les propriétés suivantes :
        - ancien / courant (ou les deux en même temps)
        - avec ou sans fichier
        - avec ou sans fichier confirmé

=end

# Note : des différences importantes sont faites. Par exemple, pour la phase
# 0, il n'y a aucun concurrent inscrit à la session courante
# Pour la phase 1, la propriété :preselected et :prix des concurrents est
# forcément nil.
# Pour la phase 2, la propriété :prix est nil
# Pour la phase 3, toutes les données sont définies

# *** requirements ***
ONLINE = false

require 'yaml'
require 'fileutils'
require './_lib/required/__first/Date_utils'
require './_lib/required/__first/extensions/Integer'
require './_lib/required/__first/constants/String'
require './_lib/required/__first/db'
MyDB.DBNAME = 'icare_test'
# Propre au concours
require './_lib/_pages_/concours/xrequired/constants_mini'
require_relative './constants'
require_relative './GConcurrent'
require_relative './GConcours'
require_relative './polyfill'
require_relative './String_CLI'

require './spec/support/Gel/lib/Gel'

FileUtils.rm_rf('./tmp') if File.exists?('./tmp')
['concours','downloads','forms','logs','mails','signups'].each do |dossier|
  `mkdir -p "./tmp/#{dossier}"`
end

[0,1,2,3,5,8,9].each do |phase|
  PHASE_GEL = phase
  GEL_NAME = "concours-phase-#{PHASE_GEL}"

  # *** Initialisation de tout ***

  GConcours.reset_all

  # *** Fabrication des concours ***
  CONCOURS_GEL_DATA[:concours].each do |data_concours|
    # puts "+ data_concours: #{data_concours}"
    gconcours = GConcours.new(data_concours)
    gconcours.build
    if gconcours.annee == ANNEE_CONCOURS_COURANTE
      GConcours.current = gconcours
    end
  end

  # *** Fabrication des concurrents ***
  CONCOURS_GEL_DATA[:concurrents].each do |data_concurrent|
    GConcurrent.new(data_concurrent).build
  end

  nb_selecteds = GConcurrent.nombre_selecteds.to_i
  if nb_selecteds == 10
    nb_selecteds = nb_selecteds.to_s.vert
  elsif nb_selecteds > 10
    nb_selecteds = nb_selecteds.to_s.rouge
  end
  nb_primeds = GConcurrent.nombre_primeds.to_i
  if nb_primeds == 3
    nb_primeds = nb_primeds.to_s.vert
  elsif nb_primeds > 3
    nb_primeds = nb_primeds.to_s.rouge
  end

  linesep = "-"*90
  puts linesep
  puts "PHASE : #{PHASE_GEL}"
  puts "NOMBRE CONCURRENTS (*)        : #{GConcurrent.nombre_courants.to_i}"
  puts "Nombre fichiers conformes (*) : #{GConcurrent.nombre_cur_file_conforme.to_i}"
  puts "Nombre sélectionnés (*)       : #{nb_selecteds}"
  puts "Nombre primés (*)             : #{nb_primeds}"
  puts "Nombre avec fiche lecture     : #{GConcurrent.nombre_avec_fiche_lecture.to_i}"
  puts "Nombre avec informations      : #{GConcurrent.nombre_avec_informations.to_i}"
  puts linesep
  puts "(*) Pour le concours courant"
  puts "\n\n"

  # On produit le gel
  gel(GEL_NAME)

  puts "GEL PHASE #{PHASE_GEL} (#{GEL_NAME}) PRODUIT AVEC SUCCÈS".vert
  puts "\n\n"
  # break

end #/fin de boucle sur toutes les phases
