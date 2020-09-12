# encoding: UTF-8
# frozen_string_literal: true

class HTML
  def titre
    "Modifications & nouveautés"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec

  end # /exec

  # Fabrication du body
  def build_body
    @body = presentation + nouveautes
  end # /build_body

  def nouveautes
    ilya1mois = Time.ilya(months:1).to_i
    current_date = nil # pour ne pas répéter l'affichage de la date
    lines = []
    File.readlines(full_path('updates.data')).each_with_index do |line, idx|
      line = safe(line.strip)
      next if line.empty? || line.start_with?('#')
      update = Update.new(line)
      break if idx > 20 && update.time < ilya1mois
      lines << update.output(current_date)
      current_date = update.date
    end
    lines.join(RC)
  end #/ nouveautes

  def presentation
    <<-HTML
<div class="explication">
  Cette page présente les dernières modifications et nouveautés de l'atelier Icare.
</div>
    HTML
  end #/ presentation

end #/HTML
