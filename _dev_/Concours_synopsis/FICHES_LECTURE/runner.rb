# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module principal de production des fiches de lecture
=end

require_relative './required/required'
FLFactory.build_fiches_lecture(IcareCLI.options, IcareCLI.params[2])
# params[2] contient éventuellement l'ID du concurrent dont il faut
# faire la fiche.
