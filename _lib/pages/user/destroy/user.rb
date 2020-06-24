# encoding: UTF-8
class User
  # = main =
  # Méthode principale de destruction du l'utilisateur courant
  def destroy
    # On anonymise ses éléments (user#9)
    # Dans les actualités
    # TODO
    # Dans les icdocuments
    # TODO
    # Dans les icetapes
    # TODO
    # Dans les icmodules
    # TODO
    # Dans les lectures du Quai des docs (lectures_qdd)
    # TODO
    # Dans la minifaq
    # TODO
    # Dans les témoignages
    # TODO
    # Dans les discussions de frigo (user_id et owner_id dans
    # `frigos_messages` et `frigos_discussions`)
    # TODO

    # On détruit les éventuels tickets en cours
    # TODO
    # On détruit ses éventuels watchers courants
    # TODO
    # On le détruit dans la base de données
    # TODO
    deconnexion
  end #/ destroy

  # On ne laisse aucune trace dans la déconnextion de l'user
  def deconnexion
    session['user_id'] = nil
    session.delete('user_id')
    User.current = User.new(DATA_GUEST)
  end #/ deconnexion
end #/User
