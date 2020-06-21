# encoding: UTF-8
=begin
  Extension de la class User pour des méthodes d'helpers
=end
class User
class << self
  def menu_select(parameters = nil)
    parameters ||= {}
    parameters.key?(:titre) || parameters.merge!(titre: 'Choisir l’icarien·ne…'.freeze)
    parameters.merge!(options: menus_users(parameters))
    [:class, :id, :name].each { |p| parameters.key?(p) || parameters.merge!(p => '')}
    TAG_SELECT_SIMPLE % parameters
  end #/ menu_select


  def menus_users(pms)
    default_value = pms[:value] || pms[:default] || pms[:default_value]
    self.collect do |icarien|
      selected = (default_value == icarien.id) ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:icarien.id, selected:selected, titre:icarien.pseudo}
    end.unshift(TAG_OPTION % {value:'', selected:'', titre:pms[:titre]||'Choisir l’icarien·ne…'.freeze}).join
  end #/ menus_users
end # /<< self
end #/User
