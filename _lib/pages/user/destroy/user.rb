# encoding: UTF-8
class User
  # = main =
  # Méthode principale de destruction du l'utilisateur courant
  def destroy
    # On anonymise ses éléments (user#9)
    tmp_request = "UPDATE `%{table}` SET user_id = 9 WHERE user_id = #{id}".freeze

    [
      'actualites', 'icdocuments', 'icetapes', 'icmodules',
      'frigo_discussions', 'frigo_messages',
      'lectures_qdd', 'minifaq', 'temoignages'
    ].each do |table|
      db_exec(tmp_request % {table: table})
    end

    # Destruction dans les discussions de frigo
    request_owner = "UPDATE `frigo_discussions` SET user_id = 9 WHERE user_id = #{id}".freeze
    db_exec(request_owner)

    # On détruit les éventuels tickets en cours
    request_delete = "DELETE FROM %{table} WHERE user_id = #{id}".freeze
    [
      'tickets', 'watchers'
    ].each do |table|
      db_exec(request_delete % {table: table})
    end

    # Et enfin dans la table users, on le détruit
    db_exec("DELETE FROM `users` WHERE id = #{id}".freeze)

    # On le déconnecte complètement
    deconnexion

    return true
  end #/ destroy

  # On ne laisse aucune trace dans la déconnextion de l'user
  def deconnexion
    session['user_id'] = nil
    session.delete('user_id')
    User.current = User.instantiate(DATA_GUEST)
  end #/ deconnexion
end #/User
