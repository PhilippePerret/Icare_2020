# encoding: UTF-8
=begin
  Plan du site
  -----------------

=end
class HTML
  def titre
    @raw_titre = "Plan"
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

#{aGoto(MainLink[:bureau].with(picto:true, titleize:true)) unless user.guest?}

#{aGoto('<a href="user/profil">'+user.visage+' Profil</a>'.freeze) unless user.guest?}

#{aGoto('<a href="overview/home">'+Emoji.get('nature/terre').regular+' L’ATELIER</a>'.freeze)}

#{aGoto('<a href="overview/reussites">'+Emoji.get('gestes/pouceup').regular+' Belles réussites</a>'.freeze)}

#{aGoto('<a href="modules/home">'+Emoji.get('objets/boite-dossier').regular+' Les modules</a>'.freeze, exergue:true)}

#{aGoto('<a href="user/signup">'+Emoji.get('objets/fichier-crayon').regular+' S’inscrire</a>'.freeze, exergue:true) if user.guest?}
#{aGoto('<a href="user/login">'+Emoji.get('objets/cadenas-cle').regular+' S’identifier</a>'.freeze) if user.guest?}

#{aGoto(('<a href="overview/icariens">'+Emoji.get('humain/fille-rousse-carre').regular+Emoji.get('humain/homme-marron-moustache').regular+Emoji.get('humain/femme-voilee').regular+Emoji.get('humain/extraterrestre').regular+Emoji.get('humain/homme-barbe-noire').regular+Emoji.get('humain/jeune-homme-blond').regular+'</a>').freeze)}

#{aGoto('<a href="contact/mail">'+Emoji.get('objets/lettre-mail').regular+' Contact</a>'.freeze)}

#{aGoto('<a href="qdd/home">'+Emoji.get('objets/pile-livres').regular+' Quai de docs</a>'.freeze)}

#{divGoto(MainLink[:aide].with(picto: true, titleize:true))}

#{divGoto('<a href="overview/temoignages">'+Emoji.get('objets/tableau-soleil').regular+' Témoignages</a>'.freeze)}

#{divGoto('<a href="overview/activity">'+Emoji.get('objets/sablier-coule').regular+' Activité</a>'.freeze)}

    HTML
  end
end #/HTML
