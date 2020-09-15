# encoding: UTF-8
=begin
  Helpers pour l'affichage
=end
require_module 'user/helpers/menus'
class HTML

  def menu_operations
    @menu_operations ||= build_menu_operations
  end #/ menu_operations
  def menu_operations_out
    @menu_operations_out || build_menu_operations
    @menu_operations_out
  end #/ menu_operations_out

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
