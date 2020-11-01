# encoding: UTF-8
# frozen_string_literal: true
class User
  # = main =
  # Méthode principale de destruction du l'utilisateur courant
  def destroy
    # On anonymise ses éléments (user#9)
    tmp_request = "UPDATE `%{table}` SET user_id = 9 WHERE user_id = #{id}"
    [
      'actualites', 'icdocuments', 'icetapes', 'icmodules',
      'frigo_discussions', 'frigo_messages',
      'lectures_qdd', 'minifaq', 'temoignages'
    ].each do |table|
      db_exec(tmp_request % {table: table})
    end

    # Destruction dans les discussions de frigo
    request_owner = "UPDATE `frigo_discussions` SET user_id = 9 WHERE user_id = #{id}"
    db_exec(request_owner)

    # On détruit les éventuels tickets en cours
    request_delete = "DELETE FROM %{table} WHERE user_id = #{id}"
    [
      'tickets', 'watchers'
    ].each do |table|
      db_exec(request_delete % {table: table})
    end

    # On détruit toutes ses éventuelles participations aux concours
    begin
      log("--> Destruction des participations éventuelles aux concours")
      dc = db_exec("SELECT concurrent_id FROM concours_concurrents WHERE mail = ?", [mail]).first
      unless dc.nil?
        concurrent_id = dc[:concurrent_id]
        req_destroy_cpc = "DELETE FROM concurrents_per_concours WHERE concurrent_id = ?"
        db_exec(req_destroy_cpc, [concurrent_id])
        req_destroy_cc = "DELETE FROM concours_concurrents WHERE concurrent_id = ?"
        db_exec(req_destroy_cc, [concurrent_id])
        log("   Destruction des participations effectuée avec succès")
      else
        log("   Aucune participation n'a été trouvée")
      end
    rescue Exception => e
      log(e)
    end

    # Et enfin dans la table users, on le détruit
    db_exec("DELETE FROM `users` WHERE id = #{id}")

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
