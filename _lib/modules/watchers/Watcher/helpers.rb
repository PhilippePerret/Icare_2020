# encoding: UTF-8
# frozen_string_literal: true
=begin
  Helpers pour construire les notifications
=end
class Watcher < ContainerClass

  # Racourci pour les féminines
  def fem(key)
    owner.fem(key)
  end #/ fem

  def lien_operation method, titre, options = nil
    options ||= {}
    options.merge!(route:"#{route.to_s}?wid=#{id}&op=#{method}", text:titre)
    Tag.lien(options)
  end #/ lien_operation

  # Bouton pour jouer (runner) le watcher, c'est-à-dire jouer sa
  # commande 'run' (donc la méthode définie par objet_class#processus dans
  # le dossier des données du watcher)
  def button_run(titre, options = nil)
    css = if options && options.key?(:class)
            options[:class]
          else
            ['btn','main']
          end
    # On construit le lien et on le renvoie
    Tag.lien(route:"#{route.to_s}?op=run&wid=#{id}", titre: titre, class:'btn main', id:"run-button-#{objet_class.downcase}-#{processus.downcase}")
  end #/ button_run

  # Bouton pour contre-jouer (unrunner) le watcher, c'est-à-dire pour
  # jouer la méthode 'unrun' (donc la méthode définie par :
  # <objet_class>#contre_<processus>) dans le dossier des données du watcher
  def button_unrun(titre, options = nil)
    options ||= {}
    options.merge!({
      route:"#{route.to_s}?op=unrun&wid=#{id}",
      titre: titre,
      id:"unrun-button-#{id}"
    })
    Tag.lien(options)
  end #/ button_unrun

  def votre_bureau(titre = nil)
    Tag.lien(route: "bureau/home", text:titre||'votre bureau', full:true)
  end #/ votre_bureau

  def faq_de_latelier
    Tag.lien(route:"aide/home", text:"Foire Aux Questions de l’atelier", full:true)
  end #/ faq_de_latelier

  def contacter_phil
    require './_lib/data/secret/smtp'
    Tag.lien(route: "mailto:#{DATA_MAIL[:mail]}", text: 'contacter Phil')
  end #/ contacter_phil

# ---------------------------------------------------------------------
#   Méthodes de construction du watcher sur le bureau
# ---------------------------------------------------------------------

  # Méthode qui affiche le watcher
  # +options+
  #   :unread   Si true, c'est que la notification n'est pas vue
  #             on ajoute une petite pastille à son affichage pour l'indiquer
  def out(options = nil)
    require_folder_processus
    key = user.admin? ? :admin : :user
    css = ['watcher']
    erbpath = path_notification(key)
    if File.exists?(erbpath)
      body = _inner(erbpath)
      if options && options[:unread]
        # Quand c'est une notification qui n'est pas lue
        css << 'unread'
        body << Tag.span(text:'', class:'pastille-rouge')
      elsif options && options[:major]
        css << 'major'
      end
      Tag.div(id:"watcher-#{id}", text:body, class:css.join(' '))
    else '' end
  end #/ out

  def _inner(erbpath)
    Tag.div(text:bande_infos, class:'infos') + body(erbpath)
  end #/ _inner

  # Entête de la notification à afficher
  def bande_infos
    inf = []
    if user.admin?
      inf << "<span class='user'><strong>#{owner.linked}</strong> <span class='small'>(##{owner.id})</span></span>"
    end
    inf << Tag.span(text:titre, class:'titre')
    inf.join
  end #/ bande_infos

  # Corps de la notification
  def body(erbpath)
    b = [deserb(erbpath, self)]
    # Si c'est l'administrateur qui visite, on ajoute un bouton pour
    # détruire ou éditer le watcher
    if user.admin?
      btns = []
      btns << '<div style="clear:both"></div>'
      btns << Tag.lien(route:"#{route.to_s}?op=destroy&wid=#{id}", titre:'détruire', class:'btn tiny warning')
      btns << Tag.lien(route:"#{route.to_s}?op=edit&wid=#{id}", titre:'éditer', class:'btn tiny')
      btns = "<div class='discret-tool small right mt2'>#{btns.join}</div>"
      b << btns
    end
    return b.join
  end #/ body

end #/Watcher < ContainerClass
