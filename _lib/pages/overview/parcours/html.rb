# encoding: UTF-8

class HTML
  def titre
    "#{retour_base}👩‍💼👨🏾‍🦱👨‍⚕️ Parcours fictif de 3 icarien·ne·s".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  def build_body
    # Construction du body
    @body = deserb('body', self)
  end
end #/HTML
