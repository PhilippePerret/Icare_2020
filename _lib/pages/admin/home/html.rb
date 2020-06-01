# encoding: UTF-8
=begin
  Accueil du bureau
  -----------------
  Résumé de l'état de l'icarien
=end
class HTML
  def titre
    "🎮 Tableau de bord administration"
  end #/ titre
  def exec
    admin_required
  end
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
