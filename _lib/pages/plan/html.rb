# encoding: UTF-8
=begin
  Plan du site
  -----------------

=end
class HTML
  def titre
    nil # @titre ||= 'Plan de l’atelier'.freeze
  end #/ titre
  def build_body
    # 👀
    @body = <<-HTML

#{divGoto('<a href="bureau/home">🏠 Bureau</a>'.freeze) if user.icarien?}

#{divGoto('<a href="user/profil">'+user.visage+' Profil</a>'.freeze) if user.icarien?}

#{divGoto('<a href="overview/home">🔬 Aperçu</a>'.freeze)}

#{divGoto('<a href="overview/reussites">👍 Belles réussites</a>'.freeze)}

#{divGoto('<a href="modules/home">🗃 Tous les modules</a>'.freeze, exergue:true)}

#{divGoto('<a href="user/signup">📝 S’inscrire</a>'.freeze, exergue:true) unless user.icarien?}
#{divGoto('<a href="user/login">🔐 S’identifier</a>'.freeze) unless user.icarien?}

#{divGoto('<a href="icariens/home">👩‍🦰🧑🏻👨🏾‍🦱🧕🏽👨🏼‍🦳👽👩🏻‍🌾🧔🏻</a>'.freeze)}

#{divGoto('<a href="contact">📧 Contact</a>'.freeze)}

#{divGoto("🔎 #{MAIN_LINKS[:aide]}".freeze)}

#{divGoto('<a href="overview/temoignages">🖼 Témoignages</a>'.freeze)}

    HTML
  end
end #/HTML
