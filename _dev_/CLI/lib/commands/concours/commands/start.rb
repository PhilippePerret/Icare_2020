# encoding: UTF-8
# frozen_string_literal: true
class Concours
class << self
  def start
    if started?
      puts "Le concours est déjà démarré… Pour l'arrêter, jouer la commande #{'icare concours stop'.jaune}".bleu
      return
    end
    puts "\n\nDÉMARRER LE CONCOURS consiste à :"
    puts "  - Ouvrir la section concours du site pour voir les conditions de l'année courante."
    puts "  - Envoyer un mail d'annonce à tous les inscrits."
    puts "  - Marquer le démarrage dans les configurations du concours (xrequired/config.json)."
    puts "Pour démarrer le concours, #{'il est impératif de'.rouge} :"
    puts "  - Avoir défini le thème (constante CONCOURS_THEME_COURANT — et sa description — dans concours/xrequired/constants.rb)"
    puts "  - Avoir produit le Réglement du concours propre à cette année."
    puts RC*2
    return if not Q.yes?("\tDois-je démarrer le concours de synopsis de l'année #{ANNEE_CONCOURS_COURANTE} ?")
    proceed_start_concours
  end #/ start

  def proceed_start_concours
    # Réglage des configurations
    config.merge!(started: true, started_at: Time.now.to_s)
    save_config
    # Envoi des mails
    send_mails_annonce_start
  end #/ proceed_start_concours

  # Attention : ici, il faut :
  #   1) prendre les inscriptions distantes
  #   2) forcer l'envoi des mails
  def send_mails_annonce_start
    # On envoie à tous les concurrents
    require_module('mail')
    # last: true pour ne prendre que ceux qui ont participé au dernier
    # concours
    concurrents(last: true).each { |dc| send_mail_to(dc) }
  end #/ send_mails_annonce_start

  def send_mail_to(dc)
    msg = "Envoi du mail à #{dc[:patronyme]}"
    STDOUT.write "#{msg}…".bleu
    Mail.send(default_data_mail.merge(to: dc[:mail], message:(template % dc)))
    STDOUT.write "\r√ #{msg}       \n".vert
  end #/ send_mail_to

  def default_data_mail
    @default_data_mail ||= {
      to: nil,
      subject: "Le nouveau Concours de Synopsis est lancé !",
      message: nil,
      force: true
    }
  end #/ default_data_mail

  def template
    @template ||= deserb('start/mail_start.erb')
  end #/ template

end # /<< self
end #/Concours
