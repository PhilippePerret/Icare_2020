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

#{aGoto(Tag.lien_bureau) unless user.guest?}

#{aGoto('<a href="user/profil">'+user.visage+' Profil</a>'.freeze) unless user.guest?}

#{aGoto('<a href="overview/home">'+EMO_TERRE+' L’ATELIER</a>'.freeze)}

#{aGoto('<a href="overview/reussites">'+EMO_POUCEUP+' Belles réussites</a>'.freeze)}

#{aGoto('<a href="modules/home">'+EMO_BOITE_DOSSIER+' Tous les modules</a>'.freeze, exergue:true)}

#{aGoto('<a href="user/signup">'+EMO_FICHIER_CRAYON+' S’inscrire</a>'.freeze, exergue:true) if user.guest?}
#{aGoto('<a href="user/login">'+EMO_CADENAS_CLE+' S’identifier</a>'.freeze) if user.guest?}

#{aGoto('<a href="overview/icariens">'+EMO_FILLE_ROUSSE_CARREE+EMO_HOMME_MARRON_MOUSTACHE+EMO_FEMME_VOILEE+EMO_EXTRATERRESTRE+EMO_HOMME_BARBE_NOIRE+EMO_JEUNE_HOMME_BLOND+'</a>'.freeze)}

#{aGoto('<a href="contact/mail">'+EMO_LETTRE_MAIL+' Contact</a>'.freeze)}

#{aGoto('<a href="qdd/home">'+EMO_PILE_LIVRES+' Quai de docs</a>'.freeze)}

#{divGoto(MAIN_LINKS[:aide])}

#{divGoto('<a href="overview/temoignages">'+EMO_TABLEAU_SOLEIL+' Témoignages</a>'.freeze)}

#{divGoto('<a href="overview/activity">'+EMO_SABLIER_COULE+' Activité</a>'.freeze)}

    HTML
  end
end #/HTML
