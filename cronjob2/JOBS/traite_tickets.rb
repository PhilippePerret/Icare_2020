# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tout ce qui concerne le CONCOURS DE SCÉNARIO
=end
class Cronjob

  def data
    @data ||= {
      name: "Traitement des tickets",   # <==== RÉGLER LE TITRE
      frequency: {hour: 1}              # <==== RÉGLER LA FRÉQUENCE
    }
  end #/ data

  def traite_tickets
    supprimer_tickets_older_than_30_days
    update_auto_increment
    return true
  end #/


  def supprimer_tickets_older_than_30_days
    ilya30jours = Time.now.to_i - 30.days
    init_count = db_count('tickets').freeze
    res = db_delete('tickets', "created_at < '#{ilya30jours}'")
    nombre = init_count - db_count('tickets')
    Report << "=== Nombre de tickets détruits : #{nombre}"
  end #/ supprimer_tickets_older_than_30_days

  def update_auto_increment
    maxid = max_id_tickets
    db_exec("ALTER TABLE tickets AUTO_INCREMENT=#{maxid}") if not maxid.nil?
  end #/ update_auto_increment

  # OUT   Retourne le plus grand identifiant de ticket
  def max_id_tickets
    res = db_exec("SELECT id FROM tickets ORDER BY id DESC LIMIT 1").first
    if res.nil?
      return nil
    else
      res.first[:id]
    end
  end #/ max_id_tickets
end #/Cronjob
