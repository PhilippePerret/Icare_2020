# encoding: UTF-8
class StateList
class << self

  def row libelle, value, options = nil
    options ||= {}
    css = ['row']
    css << (options[:class]||options[:css]) unless (options[:class]||options[:css]).nil?
    <<-HTML
<div id="#{options[:id]}" class="#{css.join(' ')}">
  <span class="libelle">#{libelle}</span>
  <span class="value">#{value}</span>
</div>
    HTML
  end #/ row

  # Bouton pour modifier
  # +route+ doit être la route qui permet de modifier la donnée contenue
  # dans le StateList
  def button_modify route, options = nil
    options ||= {}
    options[:title] ||= ""
    css = ['btn-modify']
    css << options[:class] if options.key?(:class)
    TAG_BUTTON_MODIFY % {route:route, class:css.join(' '), title:options[:title]}
  end #/ button_modify

end # /<< self
end #/StateList
