# encoding: UTF-8
# frozen_string_literal: true
=begin
  Helpers pour HTML (donc pour le body.erb)
=end


class HTML

  def prop_form(prop, name = nil)
    dataprop = DATA_PROPS[prop]
    field = case dataprop[:type]
    when 'text'
      INPUT_TEXT_TAG_S % {name:prop, id:"prop-#{prop}", value:icarien.send(prop)}
    when 'select'
      TAG_SELECT_S % {name:prop, id:"prop-#{prop}", options: send(dataprop[:options], icarien)}
    end

    button_edit = ''
    if dataprop[:editable]
      button_edit = BUTTON_EDIT_OBJET % {route:route.to_s, uid: icarien.id, objet: prop[0..-4], pid: icarien.send(prop)}
    end
    <<-HTML.strip
<form id="form-#{prop}" action="#{route.to_s}" class="noform nopadding" accept-charset="UTF-8" method="POST">
  <input type="hidden" name="route" value="#{route.to_s}">
  <input type="hidden" name="op" value="save-prop">
  <input type="hidden" name="uid" value="#{icarien.id}">
  <input type="hidden" name="prop" value="#{prop}">
  <span class="libelle">#{name || prop.capitalize}</span>
  <span class="value">#{field}</span>
  <span class="button"><input type="submit" value="changer" class="btn small"></span>
  #{button_edit}
</form>
    HTML
  end #/ prop_form

  def options_statuts(u)
    User::DATA_STATUT.collect do |key, dstate|
      next if key.is_a?(Integer)
      selected = key == u.statut ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:key.to_s, titre:dstate[:name], selected:selected}
    end.join
  end #/ menu_status
end #/HTML
