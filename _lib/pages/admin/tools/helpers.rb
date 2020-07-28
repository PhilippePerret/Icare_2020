# encoding: UTF-8
=begin
  Helpers pour l'affichage
=end
class HTML

  def menu_icariens
    @menu_icariens ||= build_menu_icariens
  end #/ menu_icariens

  def liste_statuts
    @liste_status ||= build_types_icarien
  end #/ liste_statuts

  def menu_operations
    @menu_operations ||= build_menu_operations
  end #/ menu_operations

  # Méthode qui construit le menu des icariens.
  # On les met tous, avec une classe qui définira leur statut, pour
  # une sélection facile
  # Noter que c'est le menu 'icariens-out' qu'on remplit ici.
  def build_menu_icariens
    opts_users = User.collect(order:'pseudo') do |cu|
      next if cu.statut == :undefined || cu.admin? || cu.guest?
      sel = cu.id.to_s == param(:uid) ? SELECTED : EMPTY_STRING
      idf = cu.id.to_s.rjust(3,'0')
      TAG_OPTION_C % {value: cu.id, selected:sel, titre:"#{idf} #{cu.pseudo.capitalize}", class:"#{cu.statut.to_s}"}
    end.join
    TAG_SELECT_SIMPLE % {id:'icariens-out', name:'uid', options: opts_users, class:'hidden'}
  end #/ build_menu_icariens

  def build_types_icarien
    cbs_statuts = User::DATA_STATUT.collect do |k, v|
      next unless k.is_a?(Symbol)
      next unless v[:icarien]
      cb = TAG_CHECKBOX % {titre: v[:name], id:"cb-statut-#{k}", name:k.to_s, class:"small cb-statut".freeze, checked:''}
      "<div>#{cb}</div>".freeze
    end.compact.join
    TAG_DIV_S % {class:'div-status fleft border mr2', text:cbs_statuts}
  end #/ build_types_icarien

  # Construction du menu des opérations
  def build_menu_operations
    opts_ops = DATA_OPERATIONS_ICARIENS.collect do |opid, dope|
      sel = param(:operation) == opid.to_s ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:opid, selected:sel, titre:dope[:name].to_old_html}
    end
    TAG_SELECT_SIMPLE_SIZED % {id:'operations', name:'operation', options: opts_ops, size:20, class:'small ml2'}
  end #/ build_menu_operations

end #/HTML
