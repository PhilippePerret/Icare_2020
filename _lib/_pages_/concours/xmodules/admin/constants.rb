# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour l'administration

  Pour en disposer :
    require_xmodule('admin/constants')
=end

ADMIN_USEFULL_LINKS = [
  Tag.link(text:"LES SYNOPSIS", route:"concours/evaluation"),
  Tag.link(text:"Palmarès", route:"concours/palmares"),
  Tag.link(text:"Accueil public", route:"concours/accueil")
]
if user.admin?
  ADMIN_USEFULL_LINKS += [
    Tag.link(text:"Tableau de bord", route:"concours/admin"),
    Tag.link(text:"Fiches de lecture", route:"concours/admin?section=fiches_lecture"),
  ]
end

if html.evaluator
  ADMIN_USEFULL_LINKS += [
    Tag.link(text:"Se déconnecter", route:"concours/evaluation?op=logout")
  ]
end
