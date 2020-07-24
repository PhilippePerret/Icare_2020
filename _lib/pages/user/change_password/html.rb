# encoding: UTF-8
class HTML
  def titre
    "#{Emoji.get('objets/cadenas-stylo').page_title+ISPACE}Changement du mot de passe"
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required

  end
  def build_body
    # Construction du body
    @body = <<-HTML

    HTML
  end
end #/HTML
