# encoding: UTF-8
=begin
  Helpers pour l'affichage
=end
class HTML

  def menu_icariens_out
    @menu_icariens_out ||= build_menu_icariens
  end #/ menu_icariens

  def liste_statuts
    @liste_status ||= build_types_icarien
  end #/ liste_statuts

  def menu_operations
    @menu_operations ||= build_menu_operations
  end #/ menu_operations
  def menu_operations_out
    @menu_operations_out || build_menu_operations
    @menu_operations_out
  end #/ menu_operations_out

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
      cb = TAG_CHECKBOX_C % {titre: v[:name], id:"cb-statut-#{k}", name:k.to_s, class_cb:'cb-statut', class:STRINGS[:small], checked:''}
      "<div>#{cb}</div>".freeze
    end.compact.join
    TAG_DIV % {class:'div-status fleft border mr2', id:'div-statuts', text:cbs_statuts, style:''}
  end #/ build_types_icarien

  # Construction du menu des opérations
  def build_menu_operations
    opts_ops = []
    opts_ops_out = []
    DATA_OPERATIONS_ICARIENS.each do |opid, dope|
      sel = param(:operation) == opid.to_s ? SELECTED : EMPTY_STRING
      css = if dope[:for].is_a?(Array)
              dope[:for].collect{|e|e.to_s}.join(' ')
            else
              dope[:for].to_s
            end
      # On construit l'option
      opt = TAG_OPTION_C % {value:opid, selected:sel, titre:dope[:name].to_old_html, class:css}
      if dope[:for] == :all
        opts_ops << opt
      else
        opts_ops_out << opt
      end
    end
    @menu_operations_out = TAG_SELECT_SIMPLE % {id:'operations-out', name:'operations-out', options: opts_ops_out.join, class:'hidden'}
    TAG_SELECT_SIMPLE_SIZED % {id:'operations', name:'operation', options: opts_ops.join, size:9, class:'ml1'}
  end #/ build_menu_operations

end #/HTML
