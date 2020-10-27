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
    runnable? || return
    require_module('mail')
    envoi_actualites_hebdomadaires if Cronjob.current_time.wday == 6
    envoi_actualites_quotidiennes
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
      destinataires << icarien.data
    end
    if destinataires.empty?
      Report << "Aucun destinataires pour les actualités quotidiennes."
    else

      news = actualites_veille
      puts "news veille : #{news}"

      Report << "Nombre de destinataires news veille : #{destinataires.count}."
      mail_path = File.join(__dir__,'envoi_actualites','mail_hebdomadaire.erb')
      MailSender.send_mailing(to: destinataires, file: mail_path, bind: self)
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
      destinataires << icarien.data
    end
    if destinataires.empty?
      Report << "Aucun destinataires pour les actualités hebdomadaires."
    else
      Report << "Nombre de destinataires news semaine : #{destinataires.count}."
      mail_path = File.join(__dir__,'envoi_actualites','mail_hebdomadaire.erb')
      MailSender.send_mailing(to:destinataires, file:mail_path, bind: self)
    end
  end #/ envoi_actualites_hebdomadaires

  # ---------------------------------------------------------------------
  #   Méthodes pour les actualités
  # ---------------------------------------------------------------------

  # OUT   Code HTML de la section des actualités quotidiennes (en fait,
  #       les actualités de la veille)
  #
  def section_actualites_quotidienne
    news = actualites_veille
    puts "news veille : #{news}"
    return "[ACTUALITES VEILLE]"
  end #/ section_actualites_quotidienne

  # OUT   Code HTML de l'actualité de la semaine
  #
  def section_actualites_semaine
    news = actualites_semaine
    puts "news semaine : #{news}"
    return "[ACTUALITES SEMAINE]"
  end #/ section_actualites_semaine

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


REQUEST_GET_ACTUALITES = "SELECT * FROM actualites WHERE created_at >= ? AND created_at < ?"
end #/Cronjob
