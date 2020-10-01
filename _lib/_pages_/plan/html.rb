# encoding: UTF-8
# frozen_string_literal: true
=begin
  Plan du site
  -----------------

=end
class HTML
  def titre
    @raw_titre = "Plan"
    nil # @titre ||= 'Plan de l’atelier'
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

#{MainLink[:bureau].with(picto:true, titleize:true, class:'goto') unless user.guest?}

#{aGoto(user.visage+' Profil', route:'user/profil') unless user.guest?}

#{aGoto(Emoji.get('nature/terre').regular+' L’ATELIER', route: 'overview/home')}

#{aGoto(Emoji.get('gestes/pouceup').regular+ISPACE+UI_TEXTS[:les_belles_reussites], route:'overview/reussites')}

#{aGoto(Emoji.get('objets/boite-dossier').regular+ISPACE+UI_TEXTS[:les_modules], exergue:true, route:'modules/home')}

#{aGoto(Emoji.get('objets/fichier-crayon').regular+' S’inscrire', route:'user/signup', exergue:true) if user.guest?}
#{aGoto(Emoji.get('objets/cadenas-cle').regular+' S’identifier', route:'user/login') if user.guest?}

#{aGoto(Emoji.get('humain/fille-rousse-carre').regular+Emoji.get('humain/homme-marron-moustache').regular+Emoji.get('humain/femme-voilee').regular+Emoji.get('humain/extraterrestre').regular+Emoji.get('humain/homme-barbe-noire').regular+Emoji.get('humain/jeune-homme-blond').regular, route:'overview/icariens')}

#{aGoto(Emoji.get('objets/lettre-mail').regular+' Contact', route:'contact/mail')}

#{aGoto(Emoji.get('objets/pile-livres').regular+' Quai des Docs', route:'qdd/home')}

#{aGoto(EMO_OUTILS+ISPACE++' Outils d’écriture', route:'outils/home')}

#{MainLink[:aide].with(picto: true, titleize:true, class:'goto')}

#{divGoto(Emoji.get('objets/tableau-soleil').regular+' Témoignages', route:'overview/temoignages')}

#{divGoto(Emoji.get('objets/sablier-coule').regular+' Activité', route:'overview/activity')}

#{divGoto(Emoji.get('machine/validator').regular+' Nouveautés', route:'overview/nouveautes')}

#{divGoto(Emoji.get('objets/blason').regular+' Concours '+Emoji.get('objets/chronometre').regular, route:'concours/home', exergue:true)}

    HTML
  end
end #/HTML
