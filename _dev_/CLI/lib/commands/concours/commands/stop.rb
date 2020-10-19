# encoding: UTF-8
# frozen_string_literal: true
class Concours
class << self
  def stop
    if not started?
      puts "Le concours n'est pas démarré. Impossible de l'arrêter (jouer #{'icare concours start [-s]'.jaune} pour le démarrer).".rouge
      return
    end
    puts "\n\nARRÊTER LE CONCOURS consiste à :"
    puts "  - Fermer en partie la section Concours du site."
    puts "  - Envoyer une lettre de remerciement aux concurrents (OPTIONNEL)."
    puts "  - Nettoyer le dossier des synopsis (i.e les mettre de côté)."
    puts "(On procède normalement à cette opération après l'annonce des résultats)"
    return if not Q.yes?("Dois-je procéder à l'arrêt du concours ?")
    proceed_stop
  end #/ stop

  def proceed_stop
    # On marque l'arrêt dans les configurations du concours
    config.merge!(started: false, started_at: nil)
    save_config
    # On envoie si nécessaire la lettre de remerciements
    if Q.yes?("Dois-je envoyer le mail de remerciements aux concurrents ?")
      send_remerciements
    end
    # On "gèle" les dossiers envoyés
    nettoyer_dossier_synopsis
  end #/ proceed_stop

  def send_remerciements # et félicitations
    require_module('mail')
    concurrents.each { |dc| send_mail_remerciements(dc) }
  end #/ send_remerciements

  def send_mail_remerciements(dc)
    msg = "Envoi du mail de remerciement à #{dc[:patronyme]}"
    STDOUT.write "#{msg}…".bleu
    Mail.send(data_mail(dc))
    STDOUT.write "\r√ #{msg}   \n".vert
  end #/ send_mail_remerciements


  # TODO Déterminer où mettre les synopsis
  def nettoyer_dossier_synopsis
    puts "[TODO Nettoyer le dossier synopsis #{__FILE__}:#{__LINE__}]"
  end #/ nettoyer_dossier_synopsis


  private

    # Mail modèle
    def template
      @template ||= deserb("stop/mail_stop.erb", self)
    end #/ template

    # Données pour le mail
    def data_mail(dc)
      {
        to: dc[:mail],
        subject: "Merci de votre participation !",
        message: (template % dc),
        force: true
      }
    end #/ data_mail


end # /<< self
end #/Concours
