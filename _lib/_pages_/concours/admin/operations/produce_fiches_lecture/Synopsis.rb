# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module d'exportation des fiches de lecture
=end
class Synopsis
class << self
  def exporter_les_fiches
    Synopsis.evaluated? || Synopsis.evaluate_all_synopsis(evaluator: user)
    Synopsis.all_courant.each do |synopsis|
      log("- Production de la fiche du synopsis : #{synopsis}")
      synopsis.fiche_lecture.export
    end
    message("Les fiches ont été exportées avec succès.")
  end #/ exporter_les_fiches
end # /<< self
end #/Synopsis
