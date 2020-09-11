# encoding: UTF-8
=begin
  Constantes message
=end
MESSAGES.merge!({

})
ERRORS.merge!({

})

=begin
  Cf. le manuel pour le détail de la définition des propriétés.
=end
DATA_PROPS = {
  pseudo:         {type: 'text'},
  mail:           {type: 'text'},
  statut:         {type: 'select',  vtype: 'symbol',    options: :options_statuts},
  icmodule_id:    {type: 'text',    vtype: 'integer',   editable: true},
  icetape_id:     {type: 'text',    vtype: 'integer',   editable: true},
  project_name:   {type: 'text'}
}
BUTTON_EDIT_OBJET = '<span class="button"><a href="%{route}?uid=%{uid}&op=edit-objet&objet=%{objet}&pid=%{pid}" class="small btn">Voir</a></span>'.freeze

BUTTON_RETOUR = Tag.retour({route:"admin/icarien?uid=#{param(:uid)}".freeze, titre:'Icarien'})
