# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de la classe Synopsis pour la page du palmarès
=end
class Synopsis
class << self

  # OUT   Liste Array des {Synopsis} présélectionnés, classés par note obtenue
  def selecteds
    request = <<-SQL
SELECT
  cpc.titre, cpc.auteurs, cc.patronyme AS pseudo,
  cpc.note_jury1
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE SUBSTRING(cpc.specs,3,1) = 1
    SQL
  end #/ selecteds
end # /<< self

end #/Synopsis
