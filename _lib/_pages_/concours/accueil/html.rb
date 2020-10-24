# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    "#{EMO_TITRE}#{UI_TEXTS[:concours_titre_home_page]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    try_reconnect_concurrent
  end # /exec

  # Fabrication du body
  def build_body
    step = Concours.current.step
    partial = case step
    when 0 then 'no_concours'
    when 1 then '1_en_cours'
    when 2 then '2_preselection'
    when 3 then '3_selection'
    when 5 then '5_palmares'
    when 8 then '8_acheved'
    when 9 then 'no_concours'
    end
    @body = deserb("partials/steps/#{partial}", self)
  end # /build_body

end #/HTML
