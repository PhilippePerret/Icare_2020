# encoding: UTF-8

class HTML
  include StringHelpersMethods
  def titre
    "👮‍♀️ Politique de confidentialité".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  # Fabrication du body
  def build_body
    # @body = deserb('body', self)
    @body = kramdown('body', self)
  end
end #/HTML
