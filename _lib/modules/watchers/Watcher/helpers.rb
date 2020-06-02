# encoding: UTF-8
=begin
  Helpers pour construire les notifications
=end
class Watcher < ContainerClass

  # Bouton pour jouer (runner) le watcher, c'est-à-dire jouer sa
  # commande 'run' (donc la méthode définie par objet_class#processus dans
  # le dossier des données du watcher)
  def button_run(titre, options = nil)
    Tag.lien(route:"#{route.to_s}?op=run&wid=#{id}", titre: titre, class:'main')
  end #/ button_run

  # Bouton pour contre-jouer (unrunner) le watcher, c'est-à-dire pour
  # jouer la méthode 'unrun' (donc la méthode définie par :
  # <objet_class>#contre_<processus>) dans le dossier des données du watcher
  def button_unrun(titre, options = nil)
    Tag.lien(route:"#{route.to_s}?op=unrun&wid=#{id}", titre: titre)
  end #/ button_unrun

  def votre_bureau
    Tag.lien(route: "bureau/home", text:'votre bureau', full:true)
  end #/ votre_bureau

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
      body = inner(erbpath)
      if options && options[:unread]
        # Quand c'est une notification qui n'est pas lue
        css << 'unread'
        body << Tag.span(text:'', class:'pastille-rouge')
      end
      Tag.div(text:body, class:css.join(' '))
    else '' end
  end #/ out

  def inner(erbpath)
    Tag.div(text:bande_infos, class:'infos') + body(erbpath)
  end #/ inner

  # Entête de la notification à afficher
  def bande_infos
    inf = []
    inf << "<span class='user'><strong>#{owner.pseudo}</strong> <span class='small'>(##{owner.id})</span></span>" if user.admin?
    inf << Tag.span(text:titre, class:'titre')
    inf.join
  end #/ bande_infos

  # Corps de la notification
  def body(erbpath)
    b = deserb(erbpath, self)
    # Si c'est l'administrateur qui visite, on ajoute un bouton pour
    # détruire ou éditer le watcher
    if user.admin?
      btns = []
      btns << Tag.lien(route:"#{route.to_s}?op=destroy&wid=#{id}", titre:'détruire', class:'small warning')
      btns << Tag.lien(route:"#{route.to_s}?op=edit&wid=#{id}", titre:'éditer', class:'small')
      btns = "<span class='fleft'>#{btns.join}</span>".freeze
      b.sub!(/(class="buttons">)/, "\\1#{btns}")
    end
    return b
  end #/ body

end #/Watcher < ContainerClass
