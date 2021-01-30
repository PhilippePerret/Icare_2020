# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def produce_fiches_lecture
    message("Je lance le module de production des fiches de lecture")
    require_xmodule('synopsis')
    Synopsis.exporter_les_fiches
  end #/ produce_fiches_lecture
end #/Concours
