# encoding: UTF-8
class User
  def pastille_messages_frigo_non_vus
    Tag.pastille_nombre(nombre_messages_frigo_non_vus)
  end

  # Retourne le nombre de messages non vus
  #
  # Un message "non vu" est un message M de la discussion donnée D qui a
  # été créé après le dernier check de l'user.
  #
  def nombre_messages_frigo_non_vus
    @nombre_messages_frigo_non_vus ||= begin
      request = <<-SQL
SELECT
  COUNT(mes.id)
  FROM `frigo_messages` AS mes
  INNER JOIN `frigo_users` AS fu ON fu.discussion_id = mes.discussion_id
  WHERE
    fu.user_id = #{id}
    AND mes.created_at > fu.last_checked_at
      SQL
      res = db_exec(request).first
      if res.nil? then 0 else res.values.first end
    end
  end #/ nombre_messages_frigo_non_vus

end #/User
