# encoding: UTF-8
=begin
  Accueil du bureau
  -----------------
  Résumé de l'état de l'icarien
=end
class HTML
  def titre
    "#{EMO_BUREAU.page_title}#{ISPACE}Votre bureau".freeze
  end
  def exec
    icarien_required
    if param(:op) == 'visitas'
      admin_required
      User.visit_as(param(:touid))
    end
  end
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
