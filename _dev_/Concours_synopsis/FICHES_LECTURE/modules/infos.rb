# encoding: UTF-8
# frozen_string_literal: true
class FLFactory
class << self
  # = main =
  #
  # Méthode principale affichant les informations concernant les fiches
  # de lecture
  def show_infos_fiches_lecture
    puts "\n\n"
    line_info('Nombre total de concurrents', concurrents.count)
    line_info('Concurrents avec projets', concurrents(:with_projet).count)
    line_info('Concurrents avec projets conformes', concurrents(:with_projet_conforme).count)
    puts "\n\n"
    Q.select("Que veux-tu faire maintenant ?") do |q|
      q.choices [{name:'Produire les fiches', value:'build'}, {name:'Uploader les fiches',value:'upload'}, {name:'S’arrêter là', value:'none'}]
      q.per_page 3
    end
  end #/ proceed_build_fiches_lecture

end # /<< self
end #/FLFactory
