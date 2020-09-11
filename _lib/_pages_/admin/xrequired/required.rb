# encoding: UTF-8
# frozen_string_literal: true
=begin
  Requis pour tous les secteurs de l'administration
=end

# Notamment pour les méthodes de frigo
require "#{FOLD_REL_PAGES}/bureau/home/user"

RETOUR_ADMIN = Tag.retour(route:'admin/home', titre:'Dashboard')
