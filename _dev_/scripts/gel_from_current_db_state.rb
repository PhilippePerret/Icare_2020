# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module permet de produire un gel depuis l'état courant de la
  base de donnée icare_test (PAS icare)
=end
GEL_NAME = "real-icare-2020"
GEL_DESCRIPTION = <<-TEXT
Gel produit d'après les données courantes de l'atelier distant (en ligne).
Tout est mis, depuis les données utilisateurs, les données concours jusqu'aux
watchers et autres tickets.
Ce gel a été produit suivant l'état du site le 20 novembre 2020.
Pour reproduire ce gel :
  * uploader la base 'icare_db' entière du site distant
  * injecter les données dans 'icare_test' (mysql -u root icare_test < path/to/.sql)
  * lancer ce script par CMD-i
TEXT

RC = "\n"
RC2 = RC*2
require './spec/support/Gel/lib/Gel.rb'
gel(GEL_NAME, GEL_DESCRIPTION)
