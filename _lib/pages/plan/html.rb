# encoding: UTF-8
=begin
  Plan du site
  -----------------

=end
class HTML
  def titre
    nil # @titre ||= 'Plan de l’atelier'.freeze
  end #/ titre
  def aGoto content, options = nil
    options = {} if options.nil?
    simple = rand(25).to_f % 2 == 0
    options.merge!(class: simple ? 'simple' : nil)
    div = divGoto(content, options)
    if user.guest?
      # De façon aléatoire, on ajoute un div sans rien
      div += divGoto('', class:'empty') if rand(25).to_f % 3 == 0
    end
    div
  end #/ agoto
  def build_body
    # 👀
    @body = <<-HTML

#{aGoto(Tag.lien_bureau) unless user.guest?}

#{aGoto('<a href="user/profil">'+user.visage+' Profil</a>'.freeze) unless user.guest?}

#{aGoto('<a href="overview/home">🌎 Aperçu</a>'.freeze)}

#{aGoto('<a href="overview/reussites">👍 Belles réussites</a>'.freeze)}

#{aGoto('<a href="modules/home">🗃 Tous les modules</a>'.freeze, exergue:true)}

#{aGoto('<a href="user/signup">📝 S’inscrire</a>'.freeze, exergue:true) if user.guest?}
#{aGoto('<a href="user/login">🔐 S’identifier</a>'.freeze) if user.guest?}

#{aGoto('<a href="overview/icariens">👩‍🦰🧑🏻👨🏾‍🦱🧕🏽👨🏼‍🦳👽👩🏻‍🌾🧔🏻</a>'.freeze)}

#{aGoto('<a href="contact">📧 Contact</a>'.freeze)}

#{aGoto('<a href="qdd/home">📚 Quai de docs</a>'.freeze)}

#{divGoto(MAIN_LINKS[:aide])}

#{divGoto('<a href="overview/temoignages">🖼 Témoignages</a>'.freeze)}

#{divGoto('<a href="overview/activity">⏳ Activité</a>'.freeze)}

    HTML
  end
end #/HTML
