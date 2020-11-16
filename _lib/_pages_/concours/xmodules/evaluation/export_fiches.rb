# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module d'exportation des fiches de lecture
=end
class Synopsis
class << self
  def exporter_les_fiches
    Synopsis.evaluate_all_synopsis if not Synopsis.evaluated?
    Synopsis.all_courant.each do |synopsis|
      synopsis.fiche_lecture.export
    end
    message("Les fiches ont été exportées avec succès.")
  end #/ exporter_les_fiches
end # /<< self
end #/Synopsis
