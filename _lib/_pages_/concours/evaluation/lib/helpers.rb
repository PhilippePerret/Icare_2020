# encoding: UTF-8
# frozen_string_literal: true
class HTML

  # OUT   Code HTML de la check-list
  def checklist
    deserb('../partials/checklist', self)
  end #/ checklist

  # OUT   Code HTML de la ligne permettant de choisir l'ordre de classement
  #       des fiches
  # IN    key   La clé de classement actuelle ('note' ou 'progress')
  #       sens  Le sens de classement ('desc' ou 'asc')
  def sorting_tools(key, sens)
    data_tools = [
      ["Notes &gt;", "note", "desc"],
      ["Notes &lt;", "note", "asc"],
      ["Progression &gt;", "progress", "desc"],
      ["Progression &lt;", "progress", "asc"]
    ]
    links = data_tools.collect do |text, ks, ss|
      dtool = {text:text, route:"#{route}?view=#{param(:view)}&ks=#{ks}&ss=#{ss}"}
      dtool.merge!(class:"discret bold") if key == ks && sens == ss
      Tag.link(dtool)
    end
    Tag.div(text:"Classement : #{links.join(' | ')} |", class:"mb1 small")
  end #/ sorting_tools


end #/HTML
