# encoding: UTF-8

class HTML
  def titre
    "#{Emoji.get('gestes/femme-signe-main').page_title+Emoji.get('humain/jeune-homme-blond').page_title+Emoji.get('humain/femme-noire-carre').page_title+ISPACE}Parcours fictif de 3 icarien·ne·s".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  def build_body
    # Construction du body
    @body = deserb('body', self)
  end
end #/HTML
