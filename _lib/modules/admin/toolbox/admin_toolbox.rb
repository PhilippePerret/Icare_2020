# encoding: UTF-8
=begin
  Boite à outils de l'administration
=end
require 'uri'
class Admin
class << self

end # /<< self
class Toolbox
class << self
  def out
    admin_required
    <<-HTML.strip.freeze
<div id="admin-toolbox">
<div class="titre"><img src="img/Emojis/machine/manette-jeu.png" style="width:40px;" /></div>
<div class="content">
#{link_operation(:essai, 'Essai toolbox')}
#{link_operation(:inspecter, 'Inspecter cette page')}
</div>
</div>
    HTML
  end #/ out

  LINK_OPERATION = "<a href=\"#{route.to_s}?adminop=%{op}&%{params}\" class=\"operation\">%{titre}</a>".freeze
  def link_operation(operation, titre, params = nil)
    params ||= {}
    params.merge!(route: route.to_s)
    params = params.collect{|k,v| "#{k}=#{uri_encode(v)}"}.join(ESPERLUETTE)
    LINK_OPERATION % {op:operation, params:params, titre: titre}
  end #/ link_operation
end # /<< self
end #/Toolbox
end #/Admin
