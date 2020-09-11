# encoding: UTF-8
=begin
  Accueil du bureau
  -----------------
  Résumé de l'état de l'icarien
=end
class HTML
  def titre
    "#{EMO_MANETTE_JEU.page_title}#{ISPACE}Tableau de bord administration".freeze
  end #/ titre
  def exec
    log('-> exec (home admin)')
    admin_required
  end
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
