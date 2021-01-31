# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def produce_fiches_lecture
    if Concours.current.phase >= 5
      require_xmodule('synopsis')
      Synopsis.exporter_les_fiches
    else
      erreur('Il est trop tôt pour produire les fiches de lecture… (attendre que le palmarès soit donné)')
    end
  end #/ produce_fiches_lecture
end #/Concours
