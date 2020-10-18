# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module Concours pour le Cron job
  Lorsque le concours est en place (TODO le déterminer par une variable de
  configuration)
=end

# Les constantes du site concernant le concours courant
require './_lib/_pages_/concours/xrequired/constants'

class Cronjob
class << self

  # Une fois par semaine (le samedi), transmettre les informations sur
  # le concours aux concurrents qui le souhaitent.
  def send_information_concours
    # Ces informations ne sont envoyées que le samedi
    return if not Time.now.saturday?
    return # pour le moment
    Concours.send_information
  end #/ send_information_concours
end # /<< self
class Concours
class << self
  def send_information

  end #/ send_information

  def template
    @template ||= begin
      MAIL_INFORMATIONS_TEMPLATE % {
        patronyme: "%{patronyme}",
        echeance_jours: echeance_jours,
        nombre_concurrents: nombre_concurrents,
        nombre_sent: nombre_sent
      }
    end
  end #/ template

  def echeance_jours
    @echeance_jours ||= begin
      now   = Time.now
      nowj  = Time.new(now.year, now.month, now.day, 0,0,0)
      eche  = Time.new(ANNEE_CONCOURS_COURANTE, 3, 1, 0,0,0)
      ((eche - nowj) / 3600*24).floor
    end
  end #/ echeance_jours

  def nombre_concurrents
    @nombre_concurrents ||= begin
      concurrents.count
    end
  end #/ nombre_concurrents

  def nombre_sent
    @nombre_sent ||= begin
      concurrents.select do |dc|
        dc[:specs][0] == "1"
      end.count
    end
  end #/ nombre_sent

  def pourcentage_sent
    @pourcentage_sent ||= begin
      if nombre_concurrents > 0
        "#{((nombre_sent.to_f / nombre_concurrents) * 100).round(2)} %"
      else
        "0 %"
      end
    end
  end #/ pourcentage_sent

  def concurrents
    @concurrents ||= begin
      db_exec(REQUEST_ALL_CONCURRENTS, [ANNEE_CONCOURS_COURANTE])
    end
  end #/ concurrents

end # /<< self

MAIL_INFORMATIONS_TEMPLATE = <<-HTML
<p>Bonjour %{patronyme},</p>
<p style="font-size:1.5em;">Nombre de jours avant l'échéance : %{echeance_jours}.</p>
<p>Nombre d'inscrits à ce jour : de %{nombre_concurrents}.</p>
<p>Nombre d’auteur·e·s ayant envoyé leur fichier de candidatures : %{nombre_sent} (%{pourcentage_sent}).</p>
<p>Bien à vous,</p>
<p>#{le_bot}</p>
HTML

end #/Concours

REQUEST_ALL_CONCURRENTS = <<-SQL
SELECT
  cc.*, cpc.id AS concours_id, cpc.specs AS specs
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTABLE_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ?
SQL
end #/Cronjob
