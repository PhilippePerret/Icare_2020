# encoding: UTF-8
=begin

  [1] Cette page/section est un peu particulière dans le sens où elle est
      publique, c'est-à-dire qu'elle peut être visitée en gros par n'importe
      qui. On y distingue donc `user` qui est le visiteur invité ou identifié
      et `owner` qui est à proprement parler le propriétaire de cet histori-
      que. On utilise `owner` ici comme instance d'User.

=end

class HTML
  def titre
    "📆 Historique de travail#{user_is_owner? ? '' : " de #{owner.pseudo}"}".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required unless shares_with_world?

  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  # Lire [1] en haut de page
  def owner
    @owner ||= (param(:uid) && User.get(param(:uid))) || user
  end #/ owner

  # Retourne TRUE si le visiteur qui visite est le propriétaire de
  # l'historique de travail.
  def user_is_owner?
    owner.id == user.id
  end #/ user_is_owner?

  # Retourne TRUE si l'historique peut être affiché
  def displayable?
    user.admin? || user_is_owner? || (user.icarien? && shares_with_icariens?) || shares_with_world?
  end #/ displayable?

  # Retourne TRUE si l'historique est partagé avec le monde
  def shares_with_world?
    owner.option(21) & 8 > 0
  end #/ shares_with_world?

  def shares_with_icariens?
    owner.option(21) & 1 > 0
  end #/ shares_with_icariens?

end #/HTML
