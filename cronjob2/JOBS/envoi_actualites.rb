# encoding: UTF-8
# frozen_string_literal: true
class Cronjob

  def data
    @data ||= {
      name: "Envoi des actualités",
      frequency: {hour: 3}
    }
  end #/ data

  def envoi_actualites
    require_module('mail')
    require_module('ticket')
    envoi_actualites_quotidiennes
    envoi_actualites_hebdomadaires if Cronjob.current_time.wday == 6
    return true
  end #/ send_actualites

  # ---------------------------------------------------------------------
  #   Méthodes d'envoi
  # ---------------------------------------------------------------------

  # DO    Transmet aux icariens qui le désirent les actualités de la veille
  #
  def envoi_actualites_quotidiennes
    if actualites_veille.count == 0
      Report << "Aucune actualité pour la veille."
      return
    else
      Report << "Nombre d'actualités de la veille : #{actualites_veille.count}."
    end
    destinataires = []
    Icarien.who_want_quotidien_news.each do |icarien|
      destinataires << icarien.data.merge(bouton_nomore_news: bouton_nomore_news(icarien))
    end
    if destinataires.empty?
      Report << "Aucun destinataire pour les actualités quotidiennes."
    else
      # --- On fait des mails pour des activités ---
      require_relative './envoi_actualites/Activites_helpers'
      news = actualites_veille
      Report << "Nombre de destinataires news veille : #{destinataires.count}."
      mail_path = File.join(__dir__,'envoi_actualites','mail_quotidien.erb')
      MailSender.send_mailing(to: destinataires, file: mail_path, bind: self, noop: Cronjob.noop?)
    end
  end #/ envoi_actualites_quotidiennes

  # DO    Transmet aux icariens qui le désirent les actualités de la semaine
  #
  def envoi_actualites_hebdomadaires
    if actualites_semaine.count == 0
      Report << "Aucune actualité pour la semaine."
      return
    else
      Report << "Nombre d'actualités de la semaine : #{actualites_semaine.count}."
    end
    destinataires = []
    Icarien.who_want_hebdo_news.each do |icarien|
      destinataires << icarien.data.merge(bouton_nomore_news: bouton_nomore_news(icarien))
    end
    if destinataires.empty?
      Report << "Aucun destinataires pour les actualités hebdomadaires."
    else
      # --- On fait des mails pour des activités ---
      require_relative './envoi_actualites/Activites_helpers'
      Report << "Nombre de destinataires news semaine : #{destinataires.count}."
      mail_path = File.join(__dir__,'envoi_actualites','mail_hebdomadaire.erb')
      MailSender.send_mailing(to:destinataires, file:mail_path, bind: self, noop: Cronjob.noop?)
    end
  end #/ envoi_actualites_hebdomadaires

  # ---------------------------------------------------------------------
  #   Méthodes pour les actualités
  # ---------------------------------------------------------------------

  # OUT   Retourne la liste des actualités de la veille
  def actualites_veille
    @actualites_veille ||= begin
      calc_veille_times
      db_exec(REQUEST_GET_ACTUALITES, [veille_start, veille_fin])
    end
  end #/ actualites_veille

  def veille_start  ; @veille_start end
  def veille_fin    ; @veille_fin   end
  def calc_veille_times
    now = Cronjob.current_time
    @veille_fin = Time.new(now.year, now.month, now.day, 0, 0, 0).to_i
    @veille_start = @veille_fin - 1.day
  end #/ calc_veille_times

  # OUT   Retourne la liste des actualités de la semaine
  #
  def actualites_semaine
    @actualites_semaine ||= begin
      calc_semaine_times
      db_exec(REQUEST_GET_ACTUALITES, [semaine_start, semaine_fin])
    end
  end #/ actualites_semaine

  def semaine_start  ; @semaine_start end
  def semaine_fin    ; @semaine_fin   end

  def calc_semaine_times
    now = Cronjob.current_time
    # Note : on fait toujours le mail le samedi, so :
    @semaine_fin = Time.new(now.year, now.month, now.day, 0, 0, 0).to_i + 1.day
    @semaine_start = @semaine_fin - 7.days
  end #/ calc_veille_times

# ---------------------------------------------------------------------
#
#   Helpers pour mails
#
# ---------------------------------------------------------------------
def veille_humaine
  @veille_humaine ||= begin
    formate_date(Time.at(veille_start))
  end
end #/ veille_humaine

def bouton_nomore_news(icarien)
  tck = Ticket.create(user_id: icarien.id, code:"User.get(#{icarien.id}).nomore_news", authentified: false)
  tck.lien("Ne plus recevoir ces annonces, merci", {route: ''})
end #/ bouton_nomore_news

# Requête pour relever les activités
# Note : l'ordre des colonnes doit correspondre à la définition de la
# structure Activite dans envoi_actualites/Activite_helpers.rb
REQUEST_GET_ACTUALITES = "SELECT id, type, user_id, message, created_at FROM actualites WHERE created_at >= ? AND created_at < ?"
end #/Cronjob
