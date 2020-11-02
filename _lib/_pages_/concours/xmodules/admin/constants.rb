# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour l'administration

  Pour en disposer :
    require_xmodule('admin/constants')
=end

ADMIN_USEFULL_LINKS = [
  Tag.link(text:"Tableau de bord", route:"concours/admin"),
  Tag.link(text:"Évaluation des synopsis", route:"concours/evaluation"),
  Tag.link(text:"Affichage des fiches", route:"concours/evaluation?view=body_fiches_lecture"),
  Tag.link(text:"Exporter les fiches", route:"concours/evaluation?view=body_fiches_lecture&op=exportfiches"),
  Tag.link(text:"Affichage palmarès", route:"concours/palmares")
]
