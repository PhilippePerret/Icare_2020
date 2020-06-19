# encoding: UTF-8

class HTML
  def titre
    "#{retour_base}⏳ Activité de l'atelier Icare".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    add_css('_lib/pages/home/actualites.css')
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  def activites_from_for()
    first_id = param(:first_activity_id)&.to_i
    per_page = param(:per_page)&.to_i
    Activity.get_formated_from_for(first_id, per_page)
  end #/ activites_from_for
end #/HTML

class Activity < ContainerClass # attention, ce n'est pas Actualite
class << self
  def get_formated_from_for(first_id, per_page)
    log("per_page: #{per_page.inspect}")
    request = "SELECT * FROM #{table} ORDER BY created_at LIMIT #{per_page || 40}"
    db_exec(request).collect do |dactu|
      Actualite.instantiate(dactu).out
    end.join
  end #/ get_from_for
  def table
    @table ||= 'actualites'
  end #/ table
end # /<< self
end #/Activity
