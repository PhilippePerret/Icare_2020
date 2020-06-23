# encoding: UTF-8
class User
  attr_reader :data

  DATA_GUEST = {
    'id': 0,
    'pseudo': 'Guest',
    'options': '001090000000000011090009'
  }

  def id        ; @id         ||= get(:id)        end
  def pseudo    ; @pseudo     ||= get(:pseudo)    end
  def mail      ; @mail       ||= get(:mail)      end
  def patronyme ; @patronyme  ||= get(:patronyme) end

  def get key
    @data ||= db_get('users', {id: id})
    @data[key.to_sym]
  end

  def set key, value = nil
    @data ||= db_get('users', {id: id})
    if key.is_a?(Hash)
      @data.merge!(key)
    else
      @data.merge!(key.to_sym => value)
      key = {key.to_sym => value}
    end
    save(key)
  end

  # Retourne le nombre de notifications non vues
  def unread_notifications_count
    return 0 if user.guest?
    where = if user.admin?
              "vu_admin = FALSE"
            else
              "user_id = #{id} AND vu_user = FALSE"
            end
    where << " AND ( triggered_at IS NULL OR triggered_at < #{Time.now.to_i})"
    return db_count('watchers', where)
  end #/ unread_notifications_count

end #/User
