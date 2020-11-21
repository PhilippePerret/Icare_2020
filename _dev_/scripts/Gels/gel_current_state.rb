# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module permet de produire un gel à partir de l'état actuel de la
  base locale icare_test.

  Note : pour un gel des données actuelles de l'atelier online, cf. le
  module 'gel_real_icare'
=end
GEL_NAME = "NOM_DU_GEL"
GEL_DESCRIPTION = <<-TEXT
DESCRIPTION_DU_GEL
TEXT

RC = "\n"
RC2 = RC*2
require './spec/support/Gel/lib/Gel.rb'
gel(GEL_NAME, GEL_DESCRIPTION)
