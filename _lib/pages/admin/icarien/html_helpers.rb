# encoding: UTF-8
=begin
  Helpers pour HTML (donc pour le body.erb)
=end

=begin
  Pour un type 'select', la propriété :options doit définir la méthode
  qui doit être appelée pour construire les options. Cette méthode doit recevoir
  en premier argument l'icarien.
  Quand la propriété est :editable, ça signifie qu'un bouton 'edit' sera
  ajouter pour éditer l'élément dans le détail. Par exemple, pour icmodule_id,
  on peut éditer l'IcModule. C'est une op 'edit-<prop>' qui est alors appelée,
  qui doit traiter l'édition en fonction de la propriété. Par exemple, on doit
  avoir op = 'edit-icmodule_id'
=end
DATA_PROPS = {
  pseudo:       {type: 'text'},
  statut:       {type: 'select', vtype: 'symbol', options: :options_statuts},
  icmodule_id:  {type: 'text', vtype: 'integer',  editable: true},
  icetape_id:   {type: 'text', vtype: 'integer',  editable: true}
}
BUTTON_EDIT = '<span class="button"><a href="%{route}?uid=%{uid}&op=edit-objet&objet=%{objet}&pid=%{pid}" class="small btn">Edit objet</a></span>'.freeze

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
      button_edit = BUTTON_EDIT % {route:route.to_s, uid: icarien.id, objet: prop[0..-4], pid: icarien.send(prop)}
    end
    <<-HTML.strip.freeze
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
