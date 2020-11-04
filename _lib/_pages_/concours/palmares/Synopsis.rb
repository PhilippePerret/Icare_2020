# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la classe Synopsis pour la page du palmarès
=end
class Synopsis
class << self

  # OUT   Liste Array des {Synopsis} présélectionnés, classés par note obtenue
  def preselecteds
    request = <<-SQL
SELECT
  cc.patronyme AS pseudo, cc.concurrent_id, cc.mail,
  cpc.titre, cpc.auteurs,
  cpc.pre_note, cpc.fin_note
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE SUBSTRING(cpc.specs,3,1) = 1 AND cpc.annee = ?
    SQL
    db_exec(request, [Concours.current.annee]).collect do |dc|
      Synopsis.new(dc[:concurrent_id], dc[:annee], dc)
    end
  end #/ selecteds
end # /<< self

end #/Synopsis
