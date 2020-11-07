# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour l'administration

  Pour en disposer :
    require_xmodule('admin/constants')
=end

ADMIN_USEFULL_LINKS = [
  Tag.link(text:"LES SYNOPSIS", route:"concours/evaluation"),
  Tag.link(text:"Fiches de lecture", route:"concours/evaluation?view=fiches_lecture"),
  Tag.link(text:"Palmarès", route:"concours/palmares")
]
if user.admin?
  ADMIN_USEFULL_LINKS += [
    Tag.link(text:"Tableau de bord", route:"concours/admin"),
    Tag.link(text:"Exporter les fiches", route:"concours/evaluation?view=fiches_lecture&op=exportfiches")
  ]
end
