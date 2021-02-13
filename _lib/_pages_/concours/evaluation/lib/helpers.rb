# encoding: UTF-8
# frozen_string_literal: true
class HTML

  # OUT   Code HTML de la check-list
  def checklist
    deserb('../partials/checklist', self)
  end #/ checklist

  def formulaire_notes_manuelles
    code = deserb('../partials/notes-manuelles', self)
    return code.sub(/__OPTIONS__/, options_categories)
  end #/ formulaire_notes_manuelles

  def options_categories
    "<option value=''>Choisir…</option>" +
    TABLE_PROPERTIES_DETAIL.collect do |k, dk|
      "<option value='#{k}'>#{dk[:name]}</option>"
    end.join('')
  end #/ options_categories

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
    if user.admin?
      data_tools += [
        ["Classement final &gt;", 'total', 'desc'],
        ["Classement final &lt;", 'total', 'asc']
      ]
    end
    key ||= 'note'
    sens ||= 'desc'
    links = data_tools.collect do |text, ks, ss|
      dtool = {text:text, route:"#{route}?view=#{param(:view)}&ks=#{ks}&ss=#{ss}"}
      dtool.merge!(class:"discret bold") if key == ks && sens == ss
      Tag.link(dtool)
    end
    Tag.div(text:"Classement : #{links.join(' | ')} |", class:"top-buttons mb1 small")
  end #/ sorting_tools


end #/HTML
