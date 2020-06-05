# encoding: UTF-8
class HTML
  def titre
    "🚨 Aide de l’atelier".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
  end
  def build_body
    # Construction du body
    @body = <<-HTML
#{aide_tdm}
    HTML
  end

  def aide_tdm
    ''
  end #/ aide_tdm

end #/HTML
