# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la classe Synopsis pour la page du palmarès
=end
class Synopsis

class << self

  # OUT   Liste Array des {Synopsis} présélectionnés, classés par note obtenue
  def preselecteds
    @preselecteds ||= make_list_with_request(REQUEST_ALL_PRESELECTEDS_SORTED)
  end #/ selecteds

  def not_preselecteds
    @not_preselecteds ||= make_list_with_request(REQUEST_ALL_NOT_PRESELECTEDS_SORTED)
  end #/ not_preselecteds

  def make_list_with_request(request)
    db_exec(request, [Concours.current.annee]).collect do |dc|
      Synopsis.new(dc[:concurrent_id], dc[:annee], dc)
    end
  end #/ make_list_with_request
end # /<< self


# Requête pour remonter tous les synopsis présélectionnés, dans l'ordre
REQUEST_ALL_PRESELECTEDS_SORTED = <<-SQL
SELECT
cc.patronyme AS pseudo, cc.concurrent_id, cc.mail,
cpc.titre, cpc.auteurs,
cpc.pre_note, cpc.fin_note
FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
WHERE cpc.annee = ? AND SUBSTRING(cpc.specs,3,1) = 1
ORDER BY cpc.pre_note DESC
SQL

# Requête pour remonter tous les synopsis non présélectionnés, dans l'ordre
REQUEST_ALL_NOT_PRESELECTEDS_SORTED = <<-SQL
SELECT
cc.patronyme AS pseudo, cc.concurrent_id, cc.mail,
cpc.titre, cpc.auteurs,
cpc.pre_note, cpc.fin_note
FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
-- Le projet doit être de l'année, le fichier doit être conforme, le projet non présélectionné
WHERE cpc.annee = ? AND SUBSTRING(cpc.specs,2,1) = 1 AND SUBSTRING(cpc.specs,3,1) = 0
ORDER BY cpc.pre_note DESC
SQL

end #/Synopsis
