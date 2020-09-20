# encoding: UTF-8
=begin
  Helpers pour l'affichage
=end
require_module 'user/helpers/menus'
class HTML

  def menu_icariens_out
    @menu_icariens_out ||= build_menu_icariens
  end #/ menu_icariens

  def liste_statuts
    @liste_status ||= build_types_icarien
  end #/ liste_statuts

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
    table = User::DATA_STATUT.dup
    table.merge!(admin: {icarien: true, value:9, name:'admin'})
    cbs_statuts = table.collect do |k, v|
      next unless k.is_a?(Symbol)
      next unless v[:icarien]
      cb = TAG_CHECKBOX_C % {titre: v[:name], id:"cb-statut-#{k}", name:k.to_s, class_cb:'cb-statut', class:STRINGS[:small], checked:param(k.to_sym) ? CHECKED : ''}
      "<div>#{cb}</div>".freeze
    end.compact.join
    TAG_DIV % {class:'div-status fleft border mr2', id:'div-statuts', text:cbs_statuts, style:''}
  end #/ build_types_icarien

end #/HTML
