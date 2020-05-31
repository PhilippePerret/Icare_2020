# encoding: UTF-8

class HTML
  def titre
    "#{retour_qdd}📑 Liste des documents filtrés".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    # On constitue le filtre par rapport aux paramètres
    filtre = {}
    filtre.merge!(abs_etape_id: param(:aet)) unless param(:aet).nil?
    qdd.filtre= filtre
  end

  # L'instance QDD servant pour cette requête
  def qdd
    @qdd ||= QDD.new()
  end #/ qdd

  # Fabrication du body
  def build_body
    @body = <<-HTML
#{qdd.filtre_formated}
#{qdd.documents_filtred_formated}
    HTML
  end

end #/HTML
