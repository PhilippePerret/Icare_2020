# encoding: UTF-8

class HTML
  def titre
    "#{EMO_PAPILLON.page_title+ISPACE}Les 10 bonnes raisons de choisir l’atelier Icare".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  def build_body
    # Construction du body
    @body = deserb('body', self)
  end
end #/HTML
